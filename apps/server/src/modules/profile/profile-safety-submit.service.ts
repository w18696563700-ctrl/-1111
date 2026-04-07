import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import { DataSource, EntityManager } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { ContentSafetyProfileField } from '../content_safety/content-safety.constants';
import { ContentSafetyAuditService } from '../content_safety/content-safety-audit.service';
import { ContentSafetySnapshotService } from '../content_safety/content-safety-snapshot.service';
import { profileSafetyRuleBlocked } from '../content_safety/content-safety.errors';
import {
  ContentSafetyRuleEngine,
  ContentSafetyRuleResult
} from '../content_safety/content-safety-rule.engine';
import { UserEntity } from '../identity/entities/user.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ProfileSafetySubmissionEntity } from './entities/profile-safety-submission.entity';
import { ProfileSafetyAvatarFileService } from './profile-safety-avatar-file.service';
import {
  readProfileSafetyFileAssetId,
  readProfileSafetyIntro,
  readProfileSafetyNickname
} from './profile-safety-input.parser';
import { ProfileSafetyResponsePresenter } from './profile-safety-response.presenter';

type ProfileValueInput =
  | {
      fieldKey: 'nickname';
      proposedValue: string;
      currentValue: string | null;
      fileAsset: null;
      proposedAvatarUrl: null;
      metadata?: Record<string, unknown>;
    }
  | {
      fieldKey: 'intro';
      proposedValue: string;
      currentValue: string | null;
      fileAsset: null;
      proposedAvatarUrl: null;
      metadata?: Record<string, unknown>;
    }
  | {
      fieldKey: 'avatar';
      proposedValue: string;
      currentValue: string | null;
      fileAsset: FileAssetEntity;
      proposedAvatarUrl: string;
      metadata?: Record<string, unknown>;
    };

type SubmitResult =
  | {
      outcome: 'pending';
      submission: ProfileSafetySubmissionEntity;
      user: UserEntity;
    }
  | {
      outcome: 'blocked';
      submission: ProfileSafetySubmissionEntity;
      reason: string;
      reasonCode: string | null;
      matchedRuleIds: string[];
    };

@Injectable()
export class ProfileSafetySubmitService {
  constructor(
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly avatarFileService: ProfileSafetyAvatarFileService,
    private readonly ruleEngine: ContentSafetyRuleEngine,
    private readonly auditService: ContentSafetyAuditService,
    private readonly snapshotService: ContentSafetySnapshotService,
    private readonly presenter: ProfileSafetyResponsePresenter
  ) {}

  async updateNickname(payload: Record<string, unknown>, context: RequestContext) {
    const nickname = readProfileSafetyNickname(payload);
    const user = await this.requireCurrentUser(context);
    const result = await this.submitProfileValue(
      {
        fieldKey: 'nickname',
        proposedValue: nickname,
        currentValue: user.nickname,
        fileAsset: null,
        proposedAvatarUrl: null
      },
      user,
      context
    );
    return this.resolveSubmitResult(result, context);
  }

  async updateAvatar(payload: Record<string, unknown>, context: RequestContext) {
    const fileAssetId = readProfileSafetyFileAssetId(payload);
    const user = await this.requireCurrentUser(context);
    const fileAsset = await this.avatarFileService.loadProfileAvatarFileAsset(fileAssetId, user.id);
    const stableAvatarUrl = this.avatarFileService.requireAvatarUrl(fileAsset);
    const result = await this.submitProfileValue(
      {
        fieldKey: 'avatar',
        proposedValue: fileAsset.id,
        currentValue: user.avatarUrl,
        fileAsset,
        proposedAvatarUrl: stableAvatarUrl,
        metadata: {
          objectKey: fileAsset.objectKey,
          mimeType: fileAsset.mimeType,
          size: fileAsset.size
        }
      },
      user,
      context
    );
    return this.resolveSubmitResult(result, context);
  }

  async updateIntro(payload: Record<string, unknown>, context: RequestContext) {
    const intro = readProfileSafetyIntro(payload);
    const user = await this.requireCurrentUser(context);
    const result = await this.submitProfileValue(
      {
        fieldKey: 'intro',
        proposedValue: intro,
        currentValue: user.profileIntro,
        fileAsset: null,
        proposedAvatarUrl: null
      },
      user,
      context
    );
    return this.resolveSubmitResult(result, context);
  }

  private async requireCurrentUser(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    return this.eligibilityService.requireAuthenticatedActor(currentSession);
  }

  private async submitProfileValue(
    input: ProfileValueInput,
    user: UserEntity,
    context: RequestContext
  ): Promise<SubmitResult> {
    const ruleResult = await this.evaluateRules(input);
    return this.dataSource.transaction(async (manager) => {
      const resubmittedFromId = await this.markLatestRejectedAsResubmitted(
        user.id,
        input.fieldKey,
        context,
        manager
      );
      const submission = await this.createSubmission(input, user, ruleResult, resubmittedFromId, manager);
      await this.captureSubmissionSnapshot(input, user, submission, manager);
      await this.recordSubmitAudit(input.fieldKey, user.id, submission, resubmittedFromId, context, manager);
      await this.recordRuleAudit(input.fieldKey, user.id, submission, ruleResult, context, manager);
      if (ruleResult.decision === 'block') {
        return this.toBlockedSubmitResult(submission, ruleResult);
      }
      return { outcome: 'pending' as const, submission, user };
    });
  }

  private async resolveSubmitResult(result: SubmitResult, context: RequestContext) {
    if (result.outcome === 'blocked') {
      throw profileSafetyRuleBlocked(result.reason, {
        submissionId: result.submission.id,
        fieldKey: result.submission.fieldKey,
        status: result.submission.status,
        reasonCode: result.reasonCode,
        matchedRuleIds: result.matchedRuleIds
      });
    }
    return this.presenter.toSubmitResponse(result.submission, result.user, context);
  }

  private async evaluateRules(input: ProfileValueInput): Promise<ContentSafetyRuleResult> {
    if (input.fieldKey === 'avatar') {
      return {
        decision: 'allow',
        engineType: 'rule',
        matchedRules: [],
        reasonCode: null,
        reasonText: null
      };
    }
    return this.ruleEngine.evaluateProfileText({
      fieldKey: input.fieldKey,
      content: input.proposedValue
    });
  }

  private async createSubmission(
    input: ProfileValueInput,
    user: UserEntity,
    ruleResult: ContentSafetyRuleResult,
    resubmittedFromId: string | null,
    manager: EntityManager
  ) {
    const repository = manager.getRepository(ProfileSafetySubmissionEntity);
    const submission = repository.create({
      id: randomUUID(),
      userId: user.id,
      fieldKey: input.fieldKey,
      status: ruleResult.decision === 'block' ? 'rejected' : 'pending_review',
      currentValue: input.currentValue,
      proposedValue: input.proposedValue,
      proposedFileAssetId: input.fileAsset?.id ?? null,
      proposedAvatarUrl: input.proposedAvatarUrl,
      engineType: 'rule',
      ruleDecision: ruleResult.decision,
      matchedRuleIds: ruleResult.matchedRules.map((rule) => rule.id),
      rejectReasonCode: ruleResult.reasonCode,
      rejectReason: ruleResult.reasonText,
      submittedBy: user.id,
      reviewedBy: null,
      reviewedAt: ruleResult.decision === 'block' ? new Date() : null,
      resubmittedFromId,
      metadata: input.metadata ?? {}
    });
    return repository.save(submission);
  }

  private async markLatestRejectedAsResubmitted(
    userId: string,
    fieldKey: ContentSafetyProfileField,
    context: RequestContext,
    manager: EntityManager
  ) {
    const repository = manager.getRepository(ProfileSafetySubmissionEntity);
    const latestRejected = await repository.findOne({
      where: { userId, fieldKey, status: 'rejected' },
      order: { updatedAt: 'DESC' }
    });
    if (!latestRejected) {
      return null;
    }
    latestRejected.status = 'resubmitted';
    await repository.save(latestRejected);
    await this.auditService.record(
      {
        subjectType: 'profile_safety_submission',
        subjectId: latestRejected.id,
        userId,
        actorId: userId,
        action: 'resubmit_previous_rejection_closed',
        engineType: 'manual',
        decision: 'resubmitted',
        metadata: { fieldKey }
      },
      context,
      manager
    );
    return latestRejected.id;
  }

  private async captureSubmissionSnapshot(
    input: ProfileValueInput,
    user: UserEntity,
    submission: ProfileSafetySubmissionEntity,
    manager: EntityManager
  ) {
    await this.snapshotService.captureProfileSubmission(
      {
        submissionId: submission.id,
        userId: user.id,
        fieldKey: input.fieldKey,
        currentValue: input.currentValue,
        proposedValue: input.proposedValue,
        fileAssetId: input.fileAsset?.id ?? null,
        metadata: input.metadata
      },
      manager
    );
  }

  private async recordSubmitAudit(
    fieldKey: ContentSafetyProfileField,
    userId: string,
    submission: ProfileSafetySubmissionEntity,
    resubmittedFromId: string | null,
    context: RequestContext,
    manager: EntityManager
  ) {
    await this.auditService.record(
      {
        subjectType: 'profile_safety_submission',
        subjectId: submission.id,
        userId,
        actorId: userId,
        action: resubmittedFromId ? 'resubmit_action' : 'submit_action',
        engineType: 'manual',
        decision: submission.status,
        metadata: { fieldKey, resubmittedFromId }
      },
      context,
      manager
    );
  }

  private async recordRuleAudit(
    fieldKey: ContentSafetyProfileField,
    userId: string,
    submission: ProfileSafetySubmissionEntity,
    ruleResult: ContentSafetyRuleResult,
    context: RequestContext,
    manager: EntityManager
  ) {
    await this.auditService.record(
      {
        subjectType: 'profile_safety_submission',
        subjectId: submission.id,
        userId,
        actorId: userId,
        action: 'rule_result',
        engineType: 'rule',
        decision: ruleResult.decision,
        reasonCode: ruleResult.reasonCode,
        reason: ruleResult.reasonText,
        matchedRuleIds: ruleResult.matchedRules.map((rule) => rule.id),
        metadata: {
          fieldKey,
          ruleKeys: ruleResult.matchedRules.map((rule) => rule.ruleKey)
        }
      },
      context,
      manager
    );
  }

  private toBlockedSubmitResult(
    submission: ProfileSafetySubmissionEntity,
    ruleResult: ContentSafetyRuleResult
  ): SubmitResult {
    return {
      outcome: 'blocked',
      submission,
      reason: ruleResult.reasonText ?? 'Profile safety rule blocked the submission.',
      reasonCode: ruleResult.reasonCode,
      matchedRuleIds: ruleResult.matchedRules.map((rule) => rule.id)
    };
  }
}
