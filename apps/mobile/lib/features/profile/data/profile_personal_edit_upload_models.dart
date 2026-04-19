import 'package:mobile/core/api/app_ui_contracts.dart';

final class ProfileFileUploadCanonicalPaths {
  const ProfileFileUploadCanonicalPaths._();

  static const String uploadInit = '/api/app/file/upload/init';
  static const String uploadConfirm = '/api/app/file/upload/confirm';
}

class ProfileFileUploadDirective {
  const ProfileFileUploadDirective({
    required this.uploadSessionId,
    required this.directUploadUrl,
    required this.directUploadMethod,
    required this.directUploadHeaders,
    required this.confirmEndpoint,
  });

  final String uploadSessionId;
  final String directUploadUrl;
  final String directUploadMethod;
  final Map<String, String> directUploadHeaders;
  final String confirmEndpoint;
}

class ProfileFileUploadResult {
  const ProfileFileUploadResult({
    required this.state,
    this.controlledState,
    this.directive,
    this.fileAssetId,
    this.message,
    this.errorCode,
  });

  final AppUploadState state;
  final AppPageState? controlledState;
  final ProfileFileUploadDirective? directive;
  final String? fileAssetId;
  final String? message;
  final String? errorCode;
}

typedef ProfilePersonalAvatarUploadDirective = ProfileFileUploadDirective;
typedef ProfilePersonalAvatarUploadResult = ProfileFileUploadResult;
