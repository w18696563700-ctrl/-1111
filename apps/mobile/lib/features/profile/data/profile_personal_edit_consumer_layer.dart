import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/features/profile/data/profile_personal_edit_models.dart';
import 'package:mobile/features/profile/data/profile_personal_edit_parser.dart';
import 'package:mobile/features/profile/data/profile_personal_edit_upload_models.dart';

export 'package:mobile/features/profile/data/profile_personal_edit_models.dart';
export 'package:mobile/features/profile/data/profile_personal_edit_upload_models.dart';

final class ProfilePersonalEditCanonicalPaths {
  const ProfilePersonalEditCanonicalPaths._();

  static const String nickname = '/api/app/profile/personal/nickname';
  static const String avatar = '/api/app/profile/personal/avatar';
  static const String bio = '/api/app/profile/personal/bio';
  static const String safetyStatus = '/api/app/profile/personal/safety';
  static const String uploadInit = ProfileFileUploadCanonicalPaths.uploadInit;
  static const String uploadConfirm =
      ProfileFileUploadCanonicalPaths.uploadConfirm;
}

class ProfilePersonalEditConsumerLayer {
  ProfilePersonalEditConsumerLayer({AppApiClient? client})
    : _client = client ?? AppApiClient();

  static const String _profileBusinessType = 'profile';
  static const String _avatarFileKind = 'avatar';

  static ProfilePersonalEditConsumerLayer _instance =
      ProfilePersonalEditConsumerLayer();

  static ProfilePersonalEditConsumerLayer get instance => _instance;

  static void install(ProfilePersonalEditConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ProfilePersonalEditConsumerLayer();
  }

  final AppApiClient _client;

  Future<ProfilePersonalReadResult<ProfilePersonalSafetyStatusView>>
  loadSafetyStatus() async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.get(ProfilePersonalEditCanonicalPaths.safetyStatus),
      );
      if (!ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return ProfilePersonalEditParser.readFailure<
          ProfilePersonalSafetyStatusView
        >(
          state: ProfilePersonalEditParser.mapPageState(response.statusCode),
          body: response.body,
          fallbackMessage: '当前资料安全状态暂不可用，请稍后再试。',
        );
      }

      final status = ProfilePersonalEditParser.parseSafetyStatus(response.body);
      if (status == null) {
        return const ProfilePersonalReadResult<ProfilePersonalSafetyStatusView>(
          state: AppPageState.errorNonRetryable,
          message: '资料安全状态响应缺少必要字段，页面保持受控展示。',
        );
      }

      return ProfilePersonalReadResult<ProfilePersonalSafetyStatusView>(
        state: AppPageState.content,
        data: status,
      );
    } on SocketException {
      return const ProfilePersonalReadResult<ProfilePersonalSafetyStatusView>(
        state: AppPageState.errorRetryable,
        message: '当前资料安全状态网络异常，请检查后重试。',
      );
    } on HttpException {
      return const ProfilePersonalReadResult<ProfilePersonalSafetyStatusView>(
        state: AppPageState.errorRetryable,
        message: '当前资料安全状态请求失败，请稍后再试。',
      );
    } on FormatException {
      return const ProfilePersonalReadResult<ProfilePersonalSafetyStatusView>(
        state: AppPageState.errorNonRetryable,
        message: '当前资料安全状态响应解析失败，页面保持受控展示。',
      );
    }
  }

  Future<ProfilePersonalWriteResult<ProfilePersonalNicknameAcceptedView>>
  updateNickname({required String nickname}) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.post(
          ProfilePersonalEditCanonicalPaths.nickname,
          body: <String, Object?>{'nickname': nickname},
        ),
      );
      if (!ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return ProfilePersonalEditParser.writeFailure<
          ProfilePersonalNicknameAcceptedView
        >(
          state: ProfilePersonalEditParser.mapPageState(response.statusCode),
          body: response.body,
          fallbackMessage: '当前昵称保存暂不可用，请稍后再试。',
        );
      }

      final accepted = ProfilePersonalEditParser.parseNicknameAccepted(
        response.body,
      );
      if (accepted == null) {
        return const ProfilePersonalWriteResult<
          ProfilePersonalNicknameAcceptedView
        >(
          state: AppPageState.errorNonRetryable,
          message: '昵称保存响应缺少必要字段，页面保持受控失败。',
        );
      }

      return ProfilePersonalWriteResult<ProfilePersonalNicknameAcceptedView>(
        state: AppPageState.content,
        data: accepted,
      );
    } on SocketException {
      return const ProfilePersonalWriteResult<
        ProfilePersonalNicknameAcceptedView
      >(state: AppPageState.errorRetryable, message: '当前昵称保存网络异常，请检查后重试。');
    } on HttpException {
      return const ProfilePersonalWriteResult<
        ProfilePersonalNicknameAcceptedView
      >(state: AppPageState.errorRetryable, message: '当前昵称保存请求失败，请稍后再试。');
    } on FormatException {
      return const ProfilePersonalWriteResult<
        ProfilePersonalNicknameAcceptedView
      >(
        state: AppPageState.errorNonRetryable,
        message: '当前昵称保存响应解析失败，页面保持受控失败。',
      );
    }
  }

  Future<ProfilePersonalAvatarUploadResult> initAvatarUpload({
    required String? currentUserId,
    required String fileName,
    required String mimeType,
    required List<int> bodyBytes,
  }) async {
    final normalizedUserId = ProfilePersonalEditParser.readString(
      currentUserId,
    );
    final normalizedFileName = ProfilePersonalEditParser.readString(fileName);
    final normalizedMimeType = ProfilePersonalEditParser.readString(mimeType);
    if (normalizedUserId == null ||
        normalizedFileName == null ||
        normalizedMimeType == null ||
        bodyBytes.isEmpty) {
      return const ProfilePersonalAvatarUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前头像上传参数不完整，请刷新页面后重试。',
        errorCode: 'FILE_UPLOAD_INIT_INVALID',
      );
    }

    try {
      final response = await runProtectedAppRequest(
        () => _client.post(
          ProfilePersonalEditCanonicalPaths.uploadInit,
          body: <String, Object?>{
            'businessType': _profileBusinessType,
            'businessId': normalizedUserId,
            'fileKind': _avatarFileKind,
            'mimeType': normalizedMimeType,
            'size': bodyBytes.length,
            'checksum': sha256.convert(bodyBytes).toString(),
          },
        ),
      );

      if (!ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return ProfilePersonalEditParser.uploadFailure(
          state: AppUploadState.uploadFailedRetryable,
          controlledState: ProfilePersonalEditParser.mapPageState(
            response.statusCode,
          ),
          body: response.body,
          fallbackMessage: '当前头像上传入口暂不可用，请稍后再试。',
        );
      }

      final directive = ProfilePersonalEditParser.parseUploadDirective(
        response.body,
      );
      if (directive == null) {
        return const ProfilePersonalAvatarUploadResult(
          state: AppUploadState.uploadFailedRetryable,
          controlledState: AppPageState.errorNonRetryable,
          message: '头像上传初始化响应缺少必要字段，页面保持受控失败。',
        );
      }
      if (directive.confirmEndpoint !=
          ProfilePersonalEditCanonicalPaths.uploadConfirm) {
        return const ProfilePersonalAvatarUploadResult(
          state: AppUploadState.uploadFailedRetryable,
          controlledState: AppPageState.errorNonRetryable,
          message: '头像上传确认路由漂移到非 app-facing canonical path，页面保持受控失败。',
        );
      }

      return ProfilePersonalAvatarUploadResult(
        state: AppUploadState.signedReady,
        controlledState: AppPageState.content,
        directive: directive,
      );
    } on SocketException {
      return const ProfilePersonalAvatarUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前头像上传初始化网络异常，请检查后重试。',
      );
    } on HttpException {
      return const ProfilePersonalAvatarUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前头像上传初始化请求失败，请稍后再试。',
      );
    } on FormatException {
      return const ProfilePersonalAvatarUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前头像上传初始化响应解析失败，页面保持受控失败。',
      );
    }
  }

  Future<ProfilePersonalAvatarUploadResult> directUpload({
    required ProfilePersonalAvatarUploadDirective directive,
    required List<int> bodyBytes,
  }) async {
    return directFileUpload(directive: directive, bodyBytes: bodyBytes);
  }

  Future<ProfileFileUploadResult> directFileUpload({
    required ProfileFileUploadDirective directive,
    required List<int> bodyBytes,
  }) async {
    try {
      final response = await _client.upload(
        method: directive.directUploadMethod,
        url: directive.directUploadUrl,
        headers: directive.directUploadHeaders,
        bodyBytes: bodyBytes,
      );
      if (ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return const ProfileFileUploadResult(
          state: AppUploadState.uploadConfirming,
          controlledState: AppPageState.content,
        );
      }

      return ProfilePersonalEditParser.uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: ProfilePersonalEditParser.mapPageState(
          response.statusCode,
        ),
        body: response.body,
        fallbackMessage: '当前头像图片上传失败，请稍后再试。',
      );
    } on SocketException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前头像图片上传网络异常，请检查后重试。',
      );
    } on HttpException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前头像图片上传请求失败，请稍后再试。',
      );
    }
  }

  Future<ProfilePersonalAvatarUploadResult> confirmAvatarUpload({
    required ProfilePersonalAvatarUploadDirective directive,
  }) async {
    return confirmFileUpload(directive: directive);
  }

  Future<ProfileFileUploadResult> confirmFileUpload({
    required ProfileFileUploadDirective directive,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.post(
          ProfileFileUploadCanonicalPaths.uploadConfirm,
          body: <String, Object?>{'uploadSessionId': directive.uploadSessionId},
        ),
      );
      if (!ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return ProfilePersonalEditParser.uploadFailure(
          state: AppUploadState.uploadConfirmFailed,
          controlledState: ProfilePersonalEditParser.mapPageState(
            response.statusCode,
          ),
          body: response.body,
          fallbackMessage: '当前头像上传确认失败，请稍后再试。',
        );
      }

      final fileAssetId = ProfilePersonalEditParser.readFileAssetId(
        response.body,
      );
      if (fileAssetId == null) {
        return const ProfileFileUploadResult(
          state: AppUploadState.uploadConfirmFailed,
          controlledState: AppPageState.errorNonRetryable,
          message: '头像上传确认响应缺少 fileAssetId，页面保持受控失败。',
        );
      }

      return ProfileFileUploadResult(
        state: AppUploadState.uploadBound,
        controlledState: AppPageState.content,
        fileAssetId: fileAssetId,
      );
    } on SocketException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadConfirmFailed,
        controlledState: AppPageState.errorRetryable,
        message: '当前头像上传确认网络异常，请检查后重试。',
      );
    } on HttpException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadConfirmFailed,
        controlledState: AppPageState.errorRetryable,
        message: '当前头像上传确认请求失败，请稍后再试。',
      );
    } on FormatException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadConfirmFailed,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前头像上传确认响应解析失败，页面保持受控失败。',
      );
    }
  }

  Future<ProfilePersonalWriteResult<ProfilePersonalAvatarAcceptedView>>
  commitAvatar({required String fileAssetId}) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.post(
          ProfilePersonalEditCanonicalPaths.avatar,
          body: <String, Object?>{'fileAssetId': fileAssetId},
        ),
      );
      if (!ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return ProfilePersonalEditParser.writeFailure<
          ProfilePersonalAvatarAcceptedView
        >(
          state: ProfilePersonalEditParser.mapPageState(response.statusCode),
          body: response.body,
          fallbackMessage: '当前头像保存暂不可用，请稍后再试。',
        );
      }

      final accepted = ProfilePersonalEditParser.parseAvatarAccepted(
        response.body,
      );
      if (accepted == null) {
        return const ProfilePersonalWriteResult<
          ProfilePersonalAvatarAcceptedView
        >(
          state: AppPageState.errorNonRetryable,
          message: '头像保存响应缺少必要字段，页面保持受控失败。',
        );
      }

      return ProfilePersonalWriteResult<ProfilePersonalAvatarAcceptedView>(
        state: AppPageState.content,
        data: accepted,
      );
    } on SocketException {
      return const ProfilePersonalWriteResult<
        ProfilePersonalAvatarAcceptedView
      >(state: AppPageState.errorRetryable, message: '当前头像保存网络异常，请检查后重试。');
    } on HttpException {
      return const ProfilePersonalWriteResult<
        ProfilePersonalAvatarAcceptedView
      >(state: AppPageState.errorRetryable, message: '当前头像保存请求失败，请稍后再试。');
    } on FormatException {
      return const ProfilePersonalWriteResult<
        ProfilePersonalAvatarAcceptedView
      >(
        state: AppPageState.errorNonRetryable,
        message: '当前头像保存响应解析失败，页面保持受控失败。',
      );
    }
  }
}
