import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { UserEntity } from '../identity/entities/user.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProfileSafetySubmissionEntity } from './entities/profile-safety-submission.entity';

@Injectable()
export class ProfileSafetyQueryService {
  constructor(
    @InjectRepository(ProfileSafetySubmissionEntity)
    private readonly submissionRepository: Repository<ProfileSafetySubmissionEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService
  ) {}

  async getCurrentSafetyState(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const user = await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const submissions = await this.submissionRepository.find({
      where: { userId: user.id },
      order: { createdAt: 'DESC' },
      take: 30
    });
    return {
      currentApproved: this.toCurrentApproved(user),
      submissions: submissions.map((item) => this.toSubmissionView(item))
    };
  }

  private toCurrentApproved(user: UserEntity) {
    return {
      nickname: user.nickname,
      avatarUrl: user.avatarUrl,
      avatarFileAssetId: user.avatarFileAssetId,
      intro: user.profileIntro,
      status: 'current_approved'
    };
  }

  private toSubmissionView(submission: ProfileSafetySubmissionEntity) {
    return {
      submissionId: submission.id,
      fieldKey: submission.fieldKey,
      status: submission.status,
      proposedValue: submission.fieldKey === 'avatar' ? null : submission.proposedValue,
      fileAssetId: submission.proposedFileAssetId,
      proposedAvatarUrl: submission.proposedAvatarUrl,
      rejectReasonCode: submission.rejectReasonCode,
      rejectReason: submission.rejectReason,
      matchedRuleIds: submission.matchedRuleIds,
      engineType: submission.engineType,
      ruleDecision: submission.ruleDecision,
      resubmittedFromId: submission.resubmittedFromId,
      submittedAt: submission.createdAt.toISOString(),
      reviewedAt: submission.reviewedAt?.toISOString() ?? null
    };
  }
}
