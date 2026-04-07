import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/profile/data/profile_personal_edit_models.dart';
import 'package:mobile/features/profile/data/profile_personal_edit_upload_models.dart';

final class ProfilePersonalEditParser {
  const ProfilePersonalEditParser._();

  static bool isSuccessful(int statusCode) =>
      statusCode >= 200 && statusCode < 300;

  static ProfilePersonalWriteResult<T> writeFailure<T>({
    required AppPageState state,
    required Object? body,
    required String fallbackMessage,
  }) {
    return ProfilePersonalWriteResult<T>(
      state: state,
      message: readString(readMap(body)?['message']) ?? fallbackMessage,
      errorCode: readString(readMap(body)?['code']),
    );
  }

  static ProfilePersonalReadResult<T> readFailure<T>({
    required AppPageState state,
    required Object? body,
    required String fallbackMessage,
  }) {
    return ProfilePersonalReadResult<T>(
      state: state,
      message: readString(readMap(body)?['message']) ?? fallbackMessage,
      errorCode: readString(readMap(body)?['code']),
    );
  }

  static ProfilePersonalAvatarUploadResult uploadFailure({
    required AppUploadState state,
    required AppPageState controlledState,
    required Object? body,
    required String fallbackMessage,
  }) {
    return ProfilePersonalAvatarUploadResult(
      state: state,
      controlledState: controlledState,
      message: readString(readMap(body)?['message']) ?? fallbackMessage,
      errorCode: readString(readMap(body)?['code']),
    );
  }

  static ProfilePersonalSafetyStatusView? parseSafetyStatus(Object? body) {
    final payload = readMap(body);
    if (payload == null) {
      return null;
    }
    final uiState = _readSafetyUiState(payload['auditStatus']);
    final submissions = _readSafetySubmissions(payload['submissions']);
    if (uiState == null || submissions == null) {
      return null;
    }
    return ProfilePersonalSafetyStatusView(
      uiState: uiState,
      submissions: submissions,
      displayName: readString(payload['displayName']),
      currentNickname: readString(payload['currentNickname']),
      avatarUrl: readString(payload['avatarUrl']),
      currentAvatarUrl: readString(payload['currentAvatarUrl']),
      bio: readString(payload['bio']),
      currentBio: readString(payload['currentBio']),
      pendingNickname: readString(payload['pendingNickname']),
      pendingAvatarUrl: readString(payload['pendingAvatarUrl']),
      pendingBio: readString(payload['pendingBio']),
      rejectReason: readString(payload['rejectReason']),
      traceId: readString(payload['traceId']),
    );
  }

  static ProfilePersonalNicknameAcceptedView? parseNicknameAccepted(
    Object? raw,
  ) {
    final body = readMap(raw);
    final ok = body?['ok'] == true;
    final traceId = readString(body?['traceId']);
    if (!ok || traceId == null) {
      return null;
    }
    return ProfilePersonalNicknameAcceptedView(
      ok: true,
      traceId: traceId,
      displayName: readString(body?['displayName']),
      safetySubmission: parseSafetySubmission(
        body?['safetySubmission'],
        fallbackTraceId: traceId,
      ),
    );
  }

  static ProfilePersonalAvatarAcceptedView? parseAvatarAccepted(Object? raw) {
    final body = readMap(raw);
    final ok = body?['ok'] == true;
    final traceId = readString(body?['traceId']);
    if (!ok || traceId == null) {
      return null;
    }
    return ProfilePersonalAvatarAcceptedView(
      ok: true,
      traceId: traceId,
      avatarUrl: readString(body?['avatarUrl']),
      safetySubmission: parseSafetySubmission(
        body?['safetySubmission'],
        fallbackTraceId: traceId,
      ),
    );
  }

  static ProfilePersonalSafetySubmissionView? parseSafetySubmission(
    Object? raw, {
    String? fallbackTraceId,
  }) {
    final payload = readMap(raw);
    if (payload == null) {
      return null;
    }
    final submissionId = readString(payload['submissionId']);
    final fieldKey = _readSafetyFieldKey(payload['fieldKey']);
    final uiState =
        _readSafetyUiState(payload['auditStatus']) ??
        _readSafetyUiState(payload['status']);
    if (submissionId == null || fieldKey == null || uiState == null) {
      return null;
    }
    return ProfilePersonalSafetySubmissionView(
      submissionId: submissionId,
      fieldKey: fieldKey,
      uiState: uiState,
      pendingNickname: readString(payload['pendingNickname']),
      pendingAvatarUrl: readString(payload['pendingAvatarUrl']),
      pendingBio: readString(payload['pendingBio']),
      rejectReason: readString(payload['rejectReason']),
      traceId: readString(payload['traceId']) ?? fallbackTraceId,
      submittedAt: readString(payload['submittedAt']),
      reviewedAt: readString(payload['reviewedAt']),
    );
  }

  static ProfilePersonalAvatarUploadDirective? parseUploadDirective(
    Object? body,
  ) {
    final payload = readMap(body);
    final uploadSessionId = readString(payload?['uploadSessionId']);
    final directUpload = readMap(payload?['directUpload']);
    final confirm = readMap(payload?['confirm']);
    final url = readString(directUpload?['url']);
    final method = readString(directUpload?['method']);
    final confirmEndpoint = readString(confirm?['endpoint']);
    if (uploadSessionId == null ||
        url == null ||
        method == null ||
        confirmEndpoint == null) {
      return null;
    }

    return ProfilePersonalAvatarUploadDirective(
      uploadSessionId: uploadSessionId,
      directUploadUrl: url,
      directUploadMethod: method.toUpperCase(),
      directUploadHeaders: readHeaders(directUpload?['headers']),
      confirmEndpoint: confirmEndpoint,
    );
  }

  static String? readFileAssetId(Object? body) {
    final payload = readMap(body);
    final topLevel = readString(payload?['fileAssetId']);
    if (topLevel != null) {
      return topLevel;
    }
    final fileAsset = readMap(payload?['fileAsset']);
    return readString(fileAsset?['id']) ??
        readString(fileAsset?['fileAssetId']);
  }

  static Map<String, String> readHeaders(Object? raw) {
    final headers = readMap(raw);
    if (headers == null) {
      return const <String, String>{};
    }
    final resolved = <String, String>{};
    headers.forEach((String key, Object? value) {
      final normalizedValue = readString(value);
      if (normalizedValue != null) {
        resolved[key] = normalizedValue;
      }
    });
    return resolved;
  }

  static AppPageState mapPageState(int statusCode) {
    if (statusCode == 401) {
      return AppPageState.unauthorized;
    }
    if (statusCode == 403) {
      return AppPageState.forbidden;
    }
    if (statusCode == 404) {
      return AppPageState.notFound;
    }
    if (statusCode >= 500) {
      return AppPageState.errorRetryable;
    }
    return AppPageState.errorNonRetryable;
  }

  static Map<String, Object?>? readMap(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    return raw.map((Object? key, Object? value) => MapEntry('$key', value));
  }

  static String? readString(Object? raw) {
    if (raw is! String) {
      return null;
    }
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  static List<ProfilePersonalSafetySubmissionView>? _readSafetySubmissions(
    Object? raw,
  ) {
    if (raw is! List) {
      return null;
    }
    final submissions = <ProfilePersonalSafetySubmissionView>[];
    for (final item in raw) {
      final submission = parseSafetySubmission(item);
      if (submission != null) {
        submissions.add(submission);
      }
    }
    return List<ProfilePersonalSafetySubmissionView>.unmodifiable(submissions);
  }

  static ProfilePersonalSafetyFieldKey? _readSafetyFieldKey(Object? raw) {
    final value = readString(raw);
    return switch (value) {
      'nickname' => ProfilePersonalSafetyFieldKey.nickname,
      'avatar' => ProfilePersonalSafetyFieldKey.avatar,
      'bio' || 'intro' => ProfilePersonalSafetyFieldKey.bio,
      _ => null,
    };
  }

  static ProfilePersonalSafetyUiState? _readSafetyUiState(Object? raw) {
    final value = readString(raw);
    return switch (value) {
      'current_approved' ||
      'currentApproved' => ProfilePersonalSafetyUiState.currentApproved,
      'pending_review' ||
      'pendingReview' => ProfilePersonalSafetyUiState.pendingReview,
      'approved' => ProfilePersonalSafetyUiState.approved,
      'rejected' => ProfilePersonalSafetyUiState.rejected,
      'resubmitted' ||
      'resubmittable' => ProfilePersonalSafetyUiState.resubmittable,
      _ => null,
    };
  }
}
