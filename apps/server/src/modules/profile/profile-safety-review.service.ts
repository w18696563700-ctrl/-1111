import { Injectable } from '@nestjs/common';
import { DataSource, EntityManager } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { ContentSafetyAuditService } from '../content_safety/content-safety-audit.service';
import { UserEntity } from '../identity/entities/user.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ProfileSafetySubmissionEntity } from './entities/profile-safety-submission.entity';
import { ProfileSafetyAvatarFileService } from './profile-safety-avatar-file.service';
import {
  readProfileSafetyOptionalReason,
  readProfileSafetyRequiredReason
} from './profile-safety-input.parser';
import { ProfileSafetyResponsePresenter } from './profile-safety-response.presenter';
import {
  personalAvatarFileUnavailable,
  profileSafetyReviewStateInvalid,
  profileSafetySubmissionInvalid,
  profileSafetySubmissionUnavailable
} from './profile.errors';

const MANUAL_REVIEWER_ROLES = new Set(['safety_reviewer', 'platform_reviewer', 'platform_super_admin']);

@Injectable()
export class ProfileSafetyReviewService {
  constructor(
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly avatarFileService: ProfileSafetyAvatarFileService,
    private readonly auditService: ContentSafetyAuditService,
    private readonly presenter: ProfileSafetyResponsePresenter
  ) {}

  async approveSubmission(
    submissionId: string,
    body: Record<string, unknown>,
    context: RequestContext
  ) {
    const reviewNote = readProfileSafetyOptionalReason(body);
    const reviewer = await this.requireManualReviewer(context);
    return this.dataSource.transaction(async (manager) => {
      const submission = await this.loadSubmissionForReview(submissionId, manager);
      const user = await this.loadSubmissionUser(submission, manager);
      await this.applyApprovedSubmission(user, submission, manager);
      submission.status = 'approved';
      submission.reviewedBy = reviewer.userId;
      submission.reviewedAt = new Date();
      if (reviewNote) {
        submission.metadata = { ...submission.metadata, reviewNote };
      }
      await manager.getRepository(ProfileSafetySubmissionEntity).save(submission);
      await this.recordManualReviewAudit(submission, reviewer, reviewNote, context, manager);
      await this.recordReplacementAudit(submission, reviewer, context, manager);
      return this.presenter.toReviewResponse(submission, user, context);
    });
  }

  async rejectSubmission(
    submissionId: string,
    body: Record<string, unknown>,
    context: RequestContext
  ) {
    const reason = readProfileSafetyRequiredReason(body);
    const reviewer = await this.requireManualReviewer(context);
    return this.dataSource.transaction(async (manager) => {
      const submission = await this.loadSubmissionForReview(submissionId, manager);
      const user = await this.loadSubmissionUser(submission, manager);
      submission.status = 'rejected';
      submission.reviewedBy = reviewer.userId;
      submission.reviewedAt = new Date();
      submission.rejectReasonCode = 'manual_reject';
      submission.rejectReason = reason;
      await manager.getRepository(ProfileSafetySubmissionEntity).save(submission);
      await this.recordManualRejectAudit(submission, reviewer, reason, context, manager);
      return this.presenter.toReviewResponse(submission, user, context);
    });
  }

  private async loadSubmissionForReview(submissionId: string, manager: EntityManager) {
    const normalized = submissionId.trim();
    if (!normalized) {
      throw profileSafetySubmissionInvalid('submissionId is required for profile safety review.');
    }
    const submission = await manager.getRepository(ProfileSafetySubmissionEntity).findOneBy({
      id: normalized
    });
    if (!submission) {
      throw profileSafetySubmissionUnavailable('Profile safety submission is unavailable.');
    }
    if (submission.status !== 'pending_review') {
      throw profileSafetyReviewStateInvalid('Current profile safety submission state does not allow manual review.');
    }
    return submission;
  }

  private async loadSubmissionUser(submission: ProfileSafetySubmissionEntity, manager: EntityManager) {
    const user = await manager.getRepository(UserEntity).findOneBy({ id: submission.userId });
    if (!user || user.status !== 'active') {
      throw profileSafetySubmissionUnavailable('Profile safety submission user is unavailable.');
    }
    return user;
  }

  private async applyApprovedSubmission(
    user: UserEntity,
    submission: ProfileSafetySubmissionEntity,
    manager: EntityManager
  ) {
    if (submission.fieldKey === 'nickname') {
      user.nickname = submission.proposedValue;
    } else if (submission.fieldKey === 'intro') {
      user.profileIntro = submission.proposedValue;
    } else if (submission.fieldKey === 'avatar') {
      await this.applyApprovedAvatarSubmission(user, submission, manager);
    }
    await manager.getRepository(UserEntity).save(user);
  }

  private async applyApprovedAvatarSubmission(
    user: UserEntity,
    submission: ProfileSafetySubmissionEntity,
    manager: EntityManager
  ) {
    const fileAsset = await manager.getRepository(FileAssetEntity).findOneBy({
      id: submission.proposedFileAssetId ?? ''
    });
    if (!fileAsset) {
      throw personalAvatarFileUnavailable('Current avatar FileAsset is unavailable for approval.');
    }
    this.avatarFileService.assertProfileAvatarFileAsset(fileAsset, user.id);
    user.avatarFileAssetId = fileAsset.id;
    user.avatarUrl = submission.proposedAvatarUrl ?? this.avatarFileService.buildAvatarUrl(fileAsset);
  }

  private async requireManualReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const actorRole = context.actorRole.trim();
    if (!MANUAL_REVIEWER_ROLES.has(actorRole)) {
      throw profileSafetyReviewStateInvalid('Current actor lacks the P0 manual review role.');
    }
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    return { userId: currentSession.userId, actorRole };
  }

  private async recordManualReviewAudit(
    submission: ProfileSafetySubmissionEntity,
    reviewer: { userId: string; actorRole: string },
    reviewNote: string | null,
    context: RequestContext,
    manager: EntityManager
  ) {
    await this.recordAudit(
      submission,
      reviewer,
      'manual_review_result',
      'approved',
      context,
      manager,
      { fieldKey: submission.fieldKey, reviewNote: reviewNote ?? null }
    );
  }

  private async recordReplacementAudit(
    submission: ProfileSafetySubmissionEntity,
    reviewer: { userId: string; actorRole: string },
    context: RequestContext,
    manager: EntityManager
  ) {
    await this.recordAudit(submission, reviewer, 'replacement_action', 'approved', context, manager, {
      fieldKey: submission.fieldKey
    });
  }

  private async recordManualRejectAudit(
    submission: ProfileSafetySubmissionEntity,
    reviewer: { userId: string; actorRole: string },
    reason: string,
    context: RequestContext,
    manager: EntityManager
  ) {
    await this.recordAudit(
      submission,
      reviewer,
      'manual_review_result',
      'rejected',
      context,
      manager,
      { fieldKey: submission.fieldKey },
      'manual_reject',
      reason
    );
  }

  private async recordAudit(
    submission: ProfileSafetySubmissionEntity,
    reviewer: { userId: string; actorRole: string },
    action: string,
    decision: string,
    context: RequestContext,
    manager: EntityManager,
    metadata: Record<string, unknown>,
    reasonCode?: string,
    reason?: string
  ) {
    await this.auditService.record(
      {
        subjectType: 'profile_safety_submission',
        subjectId: submission.id,
        userId: submission.userId,
        actorId: reviewer.userId,
        actorRole: reviewer.actorRole,
        action,
        engineType: 'manual',
        decision,
        reasonCode,
        reason,
        metadata
      },
      context,
      manager
    );
  }
}
