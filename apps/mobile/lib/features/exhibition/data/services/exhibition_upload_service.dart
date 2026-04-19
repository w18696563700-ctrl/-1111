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
          message: _translateUploadInitMessage(
            businessType: command.businessType,
            payload: response.body,
            fallbackMessage: '当前上传初始化暂时失败，请稍后再试。',
          ),
          errorCode: _extractErrorCode(response.body),
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _uploadFailure(
          state: AppUploadState.uploadFailedRetryable,
          path: ExhibitionCanonicalPaths.uploadInit,
          controlledState: _mapHttpFailureState(response.statusCode),
          message: _translateUploadInitMessage(
            businessType: command.businessType,
            payload: response.body,
            fallbackMessage: '当前上传初始化失败，请稍后再试。',
          ),
          errorCode: _extractErrorCode(response.body),
        );
      }

      final directive = _parseUploadDirective(response.body);
      if (directive == null) {
        return _uploadFailure(
          state: AppUploadState.uploadFailedRetryable,
          path: ExhibitionCanonicalPaths.uploadInit,
          message: '当前上传初始化响应缺少上传会话或直传指令。',
        );
      }

      if (directive.confirmEndpoint != ExhibitionCanonicalPaths.uploadConfirm) {
        return _uploadFailure(
          state: AppUploadState.uploadFailedRetryable,
          path: ExhibitionCanonicalPaths.uploadInit,
          message: '当前上传确认路径异常，请稍后再试。',
        );
      }

      return UploadFlowResult(
        state: AppUploadState.signedReady,
        method: 'POST',
        path: ExhibitionCanonicalPaths.uploadInit,
        directive: directive,
        message: '当前上传初始化已受理。',
      );
    } on SocketException {
      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: ExhibitionCanonicalPaths.uploadInit,
        message: '当前上传初始化网络异常，请检查网络后重试。',
      );
    } on HttpException {
      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: ExhibitionCanonicalPaths.uploadInit,
        message: '当前上传初始化请求失败，请稍后再试。',
      );
    } on FormatException {
      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: ExhibitionCanonicalPaths.uploadInit,
        message: '当前上传初始化响应解析失败，请稍后再试。',
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
          message: '当前文件已直传完成，正在确认绑定。',
        );
      }

      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: directive.directUploadUrl,
        message: '当前文件直传失败，请重新选择后再试。',
      );
    } on SocketException {
      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: directive.directUploadUrl,
        message: '当前文件直传网络异常，请检查网络后重试。',
      );
    } on HttpException {
      return _uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        path: directive.directUploadUrl,
        message: '当前文件直传请求失败，请稍后再试。',
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
          message: '当前文件已完成上传绑定。',
        );
      }

      return _uploadFailure(
        state: AppUploadState.uploadConfirmFailed,
        path: directive.confirmEndpoint,
        controlledState: _mapHttpFailureState(response.statusCode),
        message: _translateUploadConfirmMessage(
          payload: response.body,
          fallbackMessage: '当前上传确认失败，请稍后再试。',
        ),
        errorCode: _extractErrorCode(response.body),
      );
    } on SocketException {
      return _uploadFailure(
        state: AppUploadState.uploadConfirmFailed,
        path: directive.confirmEndpoint,
        message: '当前上传确认网络异常，请检查网络后重试。',
      );
    } on HttpException {
      return _uploadFailure(
        state: AppUploadState.uploadConfirmFailed,
        path: directive.confirmEndpoint,
        message: '当前上传确认请求失败，请稍后再试。',
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

  String _translateUploadInitMessage({
    required String businessType,
    required Object? payload,
    required String fallbackMessage,
  }) {
    final code = _rawErrorCode(payload);
    final message = _extractMessage(payload);
    if (code == 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }
    if (code == 'FILE_UPLOAD_INIT_INVALID') {
      if (businessType == 'enterprise_display') {
        if (message?.contains('listing id') == true) {
          return '当前企业展示图片上传缺少企业草稿，请先创建草稿后再试。';
        }
        if (message?.contains('owned by the current organization') == true) {
          return '当前企业展示图片只能绑定到本组织自己的展示草稿。';
        }
        if (message?.contains('active organization scope') == true) {
          return '当前缺少组织上下文，暂时无法上传企业展示图片。';
        }
        if (message?.contains('supports project/evidence') == true) {
          return '当前上传通道还未切到企业展示图片绑定，请先联调最新后端。';
        }
        if (message?.contains('image mime types') == true) {
          return '当前企业展示图片只支持常见图片格式。';
        }
        return '当前企业展示图片上传参数无效，请稍后再试。';
      }
      if (message?.contains('businessType, businessId') == true) {
        return '当前上传参数不完整，请稍后再试。';
      }
      return '当前上传初始化参数无效，请稍后再试。';
    }
    return _failureMessage(payload, fallbackMessage);
  }

  String _translateUploadConfirmMessage({
    required Object? payload,
    required String fallbackMessage,
  }) {
    final code = _rawErrorCode(payload);
    final message = _extractMessage(payload);
    if (code == 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }
    if (code == 'FILE_UPLOAD_CONFIRM_REQUIRED') {
      if (message?.contains('uploadSessionId is required') == true) {
        return '当前上传确认缺少会话参数，请重新上传后再试。';
      }
      if (message?.contains('Upload session does not exist') == true) {
        return '当前上传会话已失效，请重新上传后再试。';
      }
      return '当前上传确认尚未完成，请重新上传后再试。';
    }
    return _failureMessage(payload, fallbackMessage);
  }
}
