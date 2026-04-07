part of '../exhibition_consumer_layer.dart';

class _ExhibitionUploadService {
  const _ExhibitionUploadService(this._client);

  final AppApiClient _client;

  Future<UploadFlowResult> uploadInit(UploadInitCommand command) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.post(
          ExhibitionCanonicalPaths.uploadInit,
          body: command.toJson(),
        ),
      );

      if (response.statusCode >= 500) {
        return _uploadFailure(
          state: AppUploadState.uploadFailedRetryable,
          path: ExhibitionCanonicalPaths.uploadInit,
          controlledState: _mapHttpFailureState(response.statusCode),
          message: _failureMessage(
            response.body,
            'upload init failed with retryable server response',
          ),
          errorCode: _extractErrorCode(response.body),
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _uploadFailure(
          state: AppUploadState.uploadFailedRetryable,
          path: ExhibitionCanonicalPaths.uploadInit,
          controlledState: _mapHttpFailureState(response.statusCode),
          message: _failureMessage(response.body, 'upload init failed'),
          errorCode: _extractErrorCode(response.body),
        );
      }

      final directive = _parseUploadDirective(response.body);
      if (directive == null) {
        return _uploadFailure(
          state: AppUploadState.uploadFailedRetryable,
          path: ExhibitionCanonicalPaths.uploadInit,
          message:
              'upload init response is missing uploadSessionId or direct upload directive',
        );
      }

      if (directive.confirmEndpoint != ExhibitionCanonicalPaths.uploadConfirm) {
        return _uploadFailure(
          state: AppUploadState.uploadFailedRetryable,
          path: ExhibitionCanonicalPaths.uploadInit,
          message:
              'upload init response confirm endpoint drifted outside app-facing canonical path',
        );
      }

      return UploadFlowResult(
        state: AppUploadState.signedReady,
        method: 'POST',
        path: ExhibitionCanonicalPaths.uploadInit,
        directive: directive,
        message: 'upload init accepted by canonical BFF path',
      );
    } on SocketException {
      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: ExhibitionCanonicalPaths.uploadInit,
        message: 'upload init network error',
      );
    } on HttpException {
      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: ExhibitionCanonicalPaths.uploadInit,
        message: 'upload init http error',
      );
    } on FormatException {
      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: ExhibitionCanonicalPaths.uploadInit,
        message: 'upload init response decode failed',
      );
    }
  }

  Future<UploadFlowResult> directUpload({
    required UploadDirective directive,
    required List<int> bodyBytes,
  }) async {
    try {
      final response = await _client.upload(
        method: directive.directUploadMethod,
        url: directive.directUploadUrl,
        headers: directive.directUploadHeaders,
        bodyBytes: bodyBytes,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return UploadFlowResult(
          state: AppUploadState.uploadConfirming,
          method: directive.directUploadMethod,
          path: directive.confirmEndpoint,
          directive: directive,
          message: 'direct upload completed, waiting for confirm',
        );
      }

      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: directive.directUploadUrl,
        message: 'direct upload failed before confirm',
      );
    } on SocketException {
      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: directive.directUploadUrl,
        message: 'direct upload network error',
      );
    } on HttpException {
      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: directive.directUploadUrl,
        message: 'direct upload http error',
      );
    }
  }

  Future<UploadFlowResult> uploadConfirm({
    required UploadDirective directive,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.postEndpoint(
          directive.confirmEndpoint,
          body: <String, Object?>{'uploadSessionId': directive.uploadSessionId},
        ),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final fileAssetId = _extractConfirmedFileAssetId(response.body);
        return UploadFlowResult(
          state: AppUploadState.uploadBound,
          method: 'POST',
          path: directive.confirmEndpoint,
          fileAssetId: fileAssetId,
          message: 'upload confirm succeeded',
        );
      }

      return _uploadFailure(
        state: AppUploadState.uploadConfirmFailed,
        path: directive.confirmEndpoint,
        controlledState: _mapHttpFailureState(response.statusCode),
        message: _failureMessage(response.body, 'upload confirm failed'),
        errorCode: _extractErrorCode(response.body),
      );
    } on SocketException {
      return _uploadFailure(
        state: AppUploadState.uploadConfirmFailed,
        path: directive.confirmEndpoint,
        message: 'upload confirm network error',
      );
    } on HttpException {
      return _uploadFailure(
        state: AppUploadState.uploadConfirmFailed,
        path: directive.confirmEndpoint,
        message: 'upload confirm http error',
      );
    }
  }

  UploadFlowResult _uploadFailure({
    required AppUploadState state,
    required String path,
    required String message,
    AppPageState? controlledState,
    String? errorCode,
  }) {
    return UploadFlowResult(
      state: state,
      method: 'POST',
      path: path,
      controlledState: controlledState,
      message: message,
      errorCode: errorCode,
    );
  }

  UploadDirective? _parseUploadDirective(Object? body) {
    if (body is! Map<String, Object?>) {
      return null;
    }

    final uploadSessionId = _normalize(body['uploadSessionId'] as String?);
    final directUpload = body['directUpload'];
    final confirm = body['confirm'];
    if (uploadSessionId == null ||
        directUpload is! Map<String, Object?> ||
        confirm is! Map<String, Object?>) {
      return null;
    }

    final url = _normalize(directUpload['url'] as String?);
    final method = _normalize(directUpload['method'] as String?);
    final confirmEndpoint = _normalize(confirm['endpoint'] as String?);
    if (url == null || method == null || confirmEndpoint == null) {
      return null;
    }

    final headers = <String, String>{};
    final rawHeaders = directUpload['headers'];
    if (rawHeaders is Map<String, Object?>) {
      rawHeaders.forEach((String key, Object? value) {
        if (value != null) {
          headers[key] = '$value';
        }
      });
    }

    return UploadDirective(
      uploadSessionId: uploadSessionId,
      directUploadUrl: url,
      directUploadMethod: method.toUpperCase(),
      directUploadHeaders: headers,
      confirmEndpoint: confirmEndpoint,
    );
  }

  String? _extractConfirmedFileAssetId(Object? body) {
    final map = _readMap(body);
    final topLevelFileAssetId = _normalize(map?['fileAssetId'] as String?);
    if (topLevelFileAssetId != null) {
      return topLevelFileAssetId;
    }

    final fileAsset = _readMap(map?['fileAsset']);
    return _normalize(
      fileAsset?['id'] as String? ?? fileAsset?['fileAssetId'] as String?,
    );
  }

  Map<String, Object?>? _readMap(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    return raw.map((Object? key, Object? value) => MapEntry('$key', value));
  }

  String? _normalize(String? raw) {
    final value = raw?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  AppPageState _mapHttpFailureState(int statusCode) {
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
}
