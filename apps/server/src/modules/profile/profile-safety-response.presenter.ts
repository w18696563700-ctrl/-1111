import { Injectable } from '@nestjs/common';
import { RequestContext } from '../../shared/request-context';
import { UserEntity } from '../identity/entities/user.entity';
import { ProfileSafetySubmissionEntity } from './entities/profile-safety-submission.entity';

@Injectable()
export class ProfileSafetyResponsePresenter {
  toSubmitResponse(
    submission: ProfileSafetySubmissionEntity,
    user: UserEntity,
    context: RequestContext
  ) {
    return {
      ok: true,
      traceId: context.traceId,
      displayName: this.toDisplayName(user),
      avatarUrl: this.readAvatarUrl(user),
      profileIntro: this.readIntroValue(user),
      safetySubmission: this.toSubmissionView(submission, true)
    };
  }

  toReviewResponse(
    submission: ProfileSafetySubmissionEntity,
    user: UserEntity,
    context: RequestContext
  ) {
    return {
      ok: true,
      traceId: context.traceId,
      displayName: this.toDisplayName(user),
      avatarUrl: this.readAvatarUrl(user),
      profileIntro: this.readIntroValue(user),
      safetySubmission: this.toSubmissionView(submission, false)
    };
  }

  private toSubmissionView(
    submission: ProfileSafetySubmissionEntity,
    publicValueStillCurrent: boolean
  ) {
    return {
      submissionId: submission.id,
      fieldKey: submission.fieldKey,
      status: submission.status,
      publicValueStillCurrent,
      proposedValue: submission.fieldKey === 'avatar' ? null : submission.proposedValue,
      fileAssetId: submission.proposedFileAssetId,
      rejectReasonCode: submission.rejectReasonCode,
      rejectReason: submission.rejectReason,
      matchedRuleIds: submission.matchedRuleIds,
      engineType: submission.engineType,
      ruleDecision: submission.ruleDecision,
      submittedAt: submission.createdAt.toISOString(),
      reviewedAt: submission.reviewedAt?.toISOString() ?? null
    };
  }

  private toDisplayName(user: UserEntity) {
    const nickname = user.nickname?.trim() ?? '';
    if (nickname) {
      return nickname;
    }
    const mobileSuffix = user.mobile.trim().slice(-4);
    return mobileSuffix ? `用户${mobileSuffix}` : `用户${user.id.slice(0, 6)}`;
  }

  private readAvatarUrl(user: UserEntity) {
    const avatarUrl = user.avatarUrl?.trim() ?? '';
    return avatarUrl ? avatarUrl : null;
  }

  private readIntroValue(user: UserEntity) {
    const intro = user.profileIntro?.trim() ?? '';
    return intro ? intro : null;
  }
}
