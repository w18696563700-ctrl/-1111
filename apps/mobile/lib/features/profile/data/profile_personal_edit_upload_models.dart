import 'package:mobile/core/api/app_ui_contracts.dart';

class ProfilePersonalAvatarUploadDirective {
  const ProfilePersonalAvatarUploadDirective({
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

class ProfilePersonalAvatarUploadResult {
  const ProfilePersonalAvatarUploadResult({
    required this.state,
    this.controlledState,
    this.directive,
    this.fileAssetId,
    this.message,
    this.errorCode,
  });

  final AppUploadState state;
  final AppPageState? controlledState;
  final ProfilePersonalAvatarUploadDirective? directive;
  final String? fileAssetId;
  final String? message;
  final String? errorCode;
}
