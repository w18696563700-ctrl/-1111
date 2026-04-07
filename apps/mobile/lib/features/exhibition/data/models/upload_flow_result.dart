part of '../exhibition_consumer_layer.dart';

class UploadFlowResult {
  const UploadFlowResult({
    required this.state,
    required this.method,
    required this.path,
    this.directive,
    this.fileAssetId,
    this.controlledState,
    this.message,
    this.errorCode,
  });

  final AppUploadState state;
  final String method;
  final String path;
  final UploadDirective? directive;
  final String? fileAssetId;
  final AppPageState? controlledState;
  final String? message;
  final String? errorCode;
}
