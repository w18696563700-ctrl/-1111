import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  type ProfileSafetyAuditStatus,
  type ProfileSafetyStatusView,
  type ProfileSafetySubmissionView,
  type ProfileSafetySubmitAcceptedView,
  type SubmitProfileAvatarSafetyDto,
  type SubmitProfileBioSafetyDto,
  type SubmitProfileNicknameSafetyDto,
  readProfileSafetyAuditStatus,
  readProfileSafetyFieldKey,
} from './profile-safety.read-model';
import { ProfileSafetyErrorService } from './profile-safety-error.service';

@Injectable()
export class ProfileSafetyService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly safetyErrors: ProfileSafetyErrorService,
  ) {}

  async submitNickname(
    body: SubmitProfileNicknameSafetyDto,
    headers: IncomingHttpHeaders,
  ): Promise<ProfileSafetySubmitAcceptedView> {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/personal/nickname',
        body as Record<string, unknown>,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      const accepted = this.toSubmitAcceptedView(
        this.requireRecord(result, 'Profile nickname safety response must be an object.'),
      );
      return this.withStatusReadback(accepted, headers);
    } catch (error) {
      throw this.safetyErrors.normalizeNicknameError(error);
    }
  }

  async submitAvatar(
    body: SubmitProfileAvatarSafetyDto,
    headers: IncomingHttpHeaders,
  ): Promise<ProfileSafetySubmitAcceptedView> {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/personal/avatar',
        body as Record<string, unknown>,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      const accepted = this.toSubmitAcceptedView(
        this.requireRecord(result, 'Profile avatar safety response must be an object.'),
      );
      return this.withStatusReadback(accepted, headers);
    } catch (error) {
      throw this.safetyErrors.normalizeAvatarError(error);
    }
  }

  async submitBio(
    body: SubmitProfileBioSafetyDto,
    headers: IncomingHttpHeaders,
  ): Promise<ProfileSafetySubmitAcceptedView> {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/profile/personal/intro',
        this.toServerIntroPayload(body),
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      const accepted = this.toSubmitAcceptedView(
        this.requireRecord(result, 'Profile bio safety response must be an object.'),
      );
      return this.withStatusReadback(accepted, headers);
    } catch (error) {
      throw this.safetyErrors.normalizeBioError(error);
    }
  }

  async getSafetyStatus(headers: IncomingHttpHeaders): Promise<ProfileSafetyStatusView> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>('/server/profile/personal/safety', {
        headers: this.authContext.buildReadOnlyForwardHeaders(headers),
      });
      return this.toStatusView(
        this.requireRecord(result, 'Profile safety status response must be an object.'),
      );
    } catch (error) {
      throw this.safetyErrors.normalizeStatusError(error);
    }
  }

  private toServerIntroPayload(body: SubmitProfileBioSafetyDto): Record<string, unknown> {
    const record = this.requireRecord(body, 'Profile bio safety body must be an object.');
    return {
      ...record,
      intro: Object.prototype.hasOwnProperty.call(record, 'bio') ? record.bio : record.intro,
    };
  }

  private async withStatusReadback(
    accepted: ProfileSafetySubmitAcceptedView,
    headers: IncomingHttpHeaders,
  ): Promise<ProfileSafetySubmitAcceptedView> {
    try {
      const status = await this.getSafetyStatus(headers);
      const readbackSubmission = status.submissions.find(
        (item) => item.submissionId === accepted.safetySubmission.submissionId,
      );
      if (!readbackSubmission) {
        return accepted;
      }
      return {
        ...accepted,
        pendingNickname: status.pendingNickname,
        pendingAvatarUrl: status.pendingAvatarUrl,
        pendingBio: status.pendingBio,
        auditStatus: status.auditStatus,
        rejectReason: status.rejectReason,
        submissions: status.submissions,
        safetySubmission: {
          ...accepted.safetySubmission,
          pendingNickname: readbackSubmission.pendingNickname,
          pendingAvatarUrl: readbackSubmission.pendingAvatarUrl,
          pendingBio: readbackSubmission.pendingBio,
        },
      };
    } catch {
      return accepted;
    }
  }

  private toSubmitAcceptedView(
    result: Record<string, unknown>,
  ): ProfileSafetySubmitAcceptedView {
    if (result.ok !== true) {
      throw new Error('Profile safety submit response is missing ok=true.');
    }
    const traceId = this.asString(result.traceId);
    if (!traceId) {
      throw new Error('Profile safety submit response is missing traceId.');
    }

    const submission = this.toSubmissionView(result.safetySubmission, traceId);
    const currentNickname = this.asNullableString(result.displayName);
    const currentAvatarUrl = this.asNullableString(result.avatarUrl);
    const currentBio = this.asNullableString(result.profileIntro);

    return {
      ok: true,
      displayName: currentNickname,
      currentNickname,
      avatarUrl: currentAvatarUrl,
      currentAvatarUrl,
      bio: currentBio,
      currentBio,
      pendingNickname: submission.pendingNickname,
      pendingAvatarUrl: submission.pendingAvatarUrl,
      pendingBio: submission.pendingBio,
      auditStatus: submission.auditStatus,
      rejectReason: submission.rejectReason,
      traceId,
      submissions: [submission],
      safetySubmission: submission,
    };
  }

  private toStatusView(result: Record<string, unknown>): ProfileSafetyStatusView {
    const currentApproved = this.requireRecord(
      result.currentApproved,
      'Profile safety status response is missing currentApproved.',
    );
    const submissions = this.readSubmissions(result.submissions);
    const pending = this.toPendingSummary(submissions);
    const auditStatus = this.toOverallAuditStatus(currentApproved.status, submissions);
    const rejectReason = this.findLatestRejectReason(submissions);
    const currentNickname = this.asNullableString(currentApproved.nickname);
    const currentAvatarUrl = this.asNullableString(currentApproved.avatarUrl);
    const currentBio = this.asNullableString(currentApproved.intro);

    return {
      displayName: currentNickname,
      currentNickname,
      avatarUrl: currentAvatarUrl,
      currentAvatarUrl,
      bio: currentBio,
      currentBio,
      ...pending,
      auditStatus,
      rejectReason,
      traceId: null,
      submissions,
    };
  }

  private toSubmissionView(value: unknown, traceId: string | null): ProfileSafetySubmissionView {
    const submission = this.requireRecord(value, 'Profile safety submission response must be an object.');
    const submissionId = this.asString(submission.submissionId);
    const fieldKey = readProfileSafetyFieldKey(
      submission.fieldKey,
      'Profile safety submission response contains an invalid fieldKey.',
    );
    const auditStatus = readProfileSafetyAuditStatus(
      submission.status,
      'Profile safety submission response contains an invalid status.',
    );
    if (!submissionId) {
      throw new Error('Profile safety submission response is missing submissionId.');
    }

    const proposedValue = this.asNullableString(submission.proposedValue);
    const pendingValue = auditStatus === 'pending_review' ? proposedValue : null;
    const proposedAvatarUrl = this.asNullableString(submission.proposedAvatarUrl);

    return {
      submissionId,
      fieldKey,
      auditStatus,
      pendingNickname: fieldKey === 'nickname' ? pendingValue : null,
      pendingAvatarUrl: fieldKey === 'avatar' && auditStatus === 'pending_review' ? proposedAvatarUrl : null,
      pendingBio: fieldKey === 'bio' ? pendingValue : null,
      rejectReason: this.asNullableString(submission.rejectReason),
      traceId,
      submittedAt: this.asNullableString(submission.submittedAt),
      reviewedAt: this.asNullableString(submission.reviewedAt),
    };
  }

  private readSubmissions(value: unknown): ProfileSafetySubmissionView[] {
    if (!Array.isArray(value)) {
      throw new Error('Profile safety status response is missing submissions.');
    }
    return value.map((item) => this.toSubmissionView(item, null));
  }

  private toPendingSummary(submissions: ProfileSafetySubmissionView[]) {
    return {
      pendingNickname: this.findLatestPending(submissions, 'nickname'),
      pendingAvatarUrl: this.findLatestPending(submissions, 'avatar'),
      pendingBio: this.findLatestPending(submissions, 'bio'),
    };
  }

  private findLatestPending(
    submissions: ProfileSafetySubmissionView[],
    fieldKey: ProfileSafetySubmissionView['fieldKey'],
  ) {
    const match = submissions.find(
      (item) => item.fieldKey === fieldKey && item.auditStatus === 'pending_review',
    );
    if (!match) {
      return null;
    }
    if (fieldKey === 'nickname') {
      return match.pendingNickname;
    }
    if (fieldKey === 'avatar') {
      return match.pendingAvatarUrl;
    }
    return match.pendingBio;
  }

  private toOverallAuditStatus(
    currentStatus: unknown,
    submissions: ProfileSafetySubmissionView[],
  ): ProfileSafetyAuditStatus {
    const latestActive = submissions.find((item) => item.auditStatus === 'pending_review');
    if (latestActive) {
      return latestActive.auditStatus;
    }
    const latestRejected = submissions.find((item) => item.auditStatus === 'rejected');
    if (latestRejected) {
      return latestRejected.auditStatus;
    }
    return readProfileSafetyAuditStatus(
      currentStatus,
      'Profile safety status response contains an invalid currentApproved.status.',
    );
  }

  private findLatestRejectReason(submissions: ProfileSafetySubmissionView[]) {
    return submissions.find((item) => item.auditStatus === 'rejected' && item.rejectReason)?.rejectReason ?? null;
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private asNullableString(value: unknown) {
    if (value === null || value === undefined) {
      return null;
    }
    return this.asString(value) || null;
  }
}
