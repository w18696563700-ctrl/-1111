export type SubmitProfileNicknameSafetyDto = {
  nickname: string;
};

export type SubmitProfileAvatarSafetyDto = {
  fileAssetId: string;
};

export type SubmitProfileBioSafetyDto = {
  bio: string;
};

export type ProfileSafetyFieldKey = 'nickname' | 'avatar' | 'bio';

export type ProfileSafetyAuditStatus =
  | 'current_approved'
  | 'pending_review'
  | 'approved'
  | 'rejected'
  | 'resubmitted';

export type ProfileSafetySubmissionView = {
  submissionId: string;
  fieldKey: ProfileSafetyFieldKey;
  auditStatus: ProfileSafetyAuditStatus;
  pendingNickname: string | null;
  pendingAvatarUrl: string | null;
  pendingBio: string | null;
  rejectReason: string | null;
  traceId: string | null;
  submittedAt: string | null;
  reviewedAt: string | null;
};

export type ProfileSafetyStatusView = {
  displayName: string | null;
  currentNickname: string | null;
  avatarUrl: string | null;
  currentAvatarUrl: string | null;
  bio: string | null;
  currentBio: string | null;
  pendingNickname: string | null;
  pendingAvatarUrl: string | null;
  pendingBio: string | null;
  auditStatus: ProfileSafetyAuditStatus;
  rejectReason: string | null;
  traceId: string | null;
  submissions: ProfileSafetySubmissionView[];
};

export type ProfileSafetySubmitAcceptedView = ProfileSafetyStatusView & {
  ok: true;
  safetySubmission: ProfileSafetySubmissionView;
};

const PROFILE_SAFETY_AUDIT_STATUSES = new Set<string>([
  'current_approved',
  'pending_review',
  'approved',
  'rejected',
  'resubmitted',
]);

export function readProfileSafetyAuditStatus(
  value: unknown,
  message: string,
): ProfileSafetyAuditStatus {
  if (typeof value === 'string' && PROFILE_SAFETY_AUDIT_STATUSES.has(value)) {
    return value as ProfileSafetyAuditStatus;
  }
  throw new Error(message);
}

export function readProfileSafetyFieldKey(
  value: unknown,
  message: string,
): ProfileSafetyFieldKey {
  if (value === 'nickname' || value === 'avatar') {
    return value;
  }
  if (value === 'intro' || value === 'bio') {
    return 'bio';
  }
  throw new Error(message);
}
