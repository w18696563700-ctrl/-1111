import 'package:mobile/core/api/app_ui_contracts.dart';

enum ProfilePersonalSafetyFieldKey { nickname, avatar, bio }

enum ProfilePersonalSafetyUiState {
  currentApproved,
  pendingReview,
  approved,
  rejected,
  resubmittable,
}

class ProfilePersonalReadResult<T> {
  const ProfilePersonalReadResult({
    required this.state,
    this.data,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final T? data;
  final String? message;
  final String? errorCode;
}

class ProfilePersonalSafetySubmissionView {
  const ProfilePersonalSafetySubmissionView({
    required this.submissionId,
    required this.fieldKey,
    required this.uiState,
    this.pendingNickname,
    this.pendingAvatarUrl,
    this.pendingBio,
    this.rejectReason,
    this.traceId,
    this.submittedAt,
    this.reviewedAt,
  });

  final String submissionId;
  final ProfilePersonalSafetyFieldKey fieldKey;
  final ProfilePersonalSafetyUiState uiState;
  final String? pendingNickname;
  final String? pendingAvatarUrl;
  final String? pendingBio;
  final String? rejectReason;
  final String? traceId;
  final String? submittedAt;
  final String? reviewedAt;

  bool get isPendingReview =>
      uiState == ProfilePersonalSafetyUiState.pendingReview;
  bool get isRejected => uiState == ProfilePersonalSafetyUiState.rejected;
  bool get isResubmittable =>
      uiState == ProfilePersonalSafetyUiState.resubmittable;
}

class ProfilePersonalSafetyStatusView {
  const ProfilePersonalSafetyStatusView({
    required this.uiState,
    required this.submissions,
    this.displayName,
    this.currentNickname,
    this.avatarUrl,
    this.currentAvatarUrl,
    this.bio,
    this.currentBio,
    this.pendingNickname,
    this.pendingAvatarUrl,
    this.pendingBio,
    this.rejectReason,
    this.traceId,
  });

  final ProfilePersonalSafetyUiState uiState;
  final List<ProfilePersonalSafetySubmissionView> submissions;
  final String? displayName;
  final String? currentNickname;
  final String? avatarUrl;
  final String? currentAvatarUrl;
  final String? bio;
  final String? currentBio;
  final String? pendingNickname;
  final String? pendingAvatarUrl;
  final String? pendingBio;
  final String? rejectReason;
  final String? traceId;

  ProfilePersonalSafetySubmissionView? latestSubmissionFor(
    ProfilePersonalSafetyFieldKey fieldKey,
  ) {
    for (final submission in submissions) {
      if (submission.fieldKey == fieldKey) {
        return submission;
      }
    }
    return null;
  }
}

class ProfilePersonalWriteResult<T> {
  const ProfilePersonalWriteResult({
    required this.state,
    this.data,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final T? data;
  final String? message;
  final String? errorCode;
}

class ProfilePersonalNicknameAcceptedView {
  const ProfilePersonalNicknameAcceptedView({
    required this.ok,
    this.traceId,
    this.displayName,
    this.safetySubmission,
  });

  final bool ok;
  final String? traceId;
  final String? displayName;
  final ProfilePersonalSafetySubmissionView? safetySubmission;
}

class ProfilePersonalAvatarAcceptedView {
  const ProfilePersonalAvatarAcceptedView({
    required this.ok,
    this.traceId,
    this.avatarUrl,
    this.safetySubmission,
  });

  final bool ok;
  final String? traceId;
  final String? avatarUrl;
  final ProfilePersonalSafetySubmissionView? safetySubmission;
}
