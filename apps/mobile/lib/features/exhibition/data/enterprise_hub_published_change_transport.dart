part of 'enterprise_hub_published_change_consumer_layer.dart';

Future<EnterpriseHubLoadResult<T>> _publishedChangeLoad<T>({
  required AppApiClient client,
  required String method,
  required String canonicalPath,
  required Future<AppApiResponse> Function() request,
  required T Function(Map<String, Object?> payload) parser,
}) async {
  try {
    final response = await request();
    final payload = _asMap(response.body);
    final failureState = _mapFailureState(response.statusCode);
    if (failureState != null) {
      return EnterpriseHubLoadResult<T>(
        state: failureState,
        method: method,
        path: canonicalPath,
        payload: payload ?? response.body,
        message: _messageFromPayload(payload),
        errorCode: _errorCodeFromPayload(payload),
      );
    }
    if (payload == null) {
      return EnterpriseHubLoadResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        payload: response.body,
        message: '响应体不是对象，当前无法完成 published-change 合同映射。',
      );
    }
    return EnterpriseHubLoadResult<T>(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: parser(payload),
      payload: payload,
    );
  } on SocketException {
    return EnterpriseHubLoadResult<T>(
      state: AppPageState.errorRetryable,
      method: method,
      path: canonicalPath,
      message: '网络未就绪，当前无法读取已发布展示变更链路。',
    );
  } on StateError {
    return EnterpriseHubLoadResult<T>(
      state: AppPageState.errorRetryable,
      method: method,
      path: canonicalPath,
      message: '当前 fake transport 尚未提供已发布展示变更 canonical path。',
    );
  } on FormatException catch (error) {
    return EnterpriseHubLoadResult<T>(
      state: AppPageState.errorNonRetryable,
      method: method,
      path: canonicalPath,
      message: error.message,
    );
  }
}

Future<EnterpriseHubActionResult<T>> _publishedChangeSubmit<T>({
  required AppApiClient client,
  required String method,
  required String canonicalPath,
  required Future<AppApiResponse> Function() request,
  required T? Function(Map<String, Object?> payload) parser,
}) async {
  try {
    final response = await request();
    final payload = _asMap(response.body);
    final failureState = _mapFailureState(response.statusCode);
    if (failureState != null) {
      return EnterpriseHubActionResult<T>(
        isSuccess: false,
        method: method,
        path: canonicalPath,
        controlledState: failureState,
        payload: payload ?? response.body,
        message: _messageFromPayload(payload),
        errorCode: _errorCodeFromPayload(payload),
      );
    }
    if (payload == null) {
      return EnterpriseHubActionResult<T>(
        isSuccess: true,
        method: method,
        path: canonicalPath,
        payload: response.body,
      );
    }
    return EnterpriseHubActionResult<T>(
      isSuccess: true,
      method: method,
      path: canonicalPath,
      data: parser(payload),
      payload: payload,
    );
  } on SocketException {
    return EnterpriseHubActionResult<T>(
      isSuccess: false,
      method: method,
      path: canonicalPath,
      controlledState: AppPageState.errorRetryable,
      message: '网络未就绪，当前无法提交已发布展示变更。',
    );
  } on StateError {
    return EnterpriseHubActionResult<T>(
      isSuccess: false,
      method: method,
      path: canonicalPath,
      controlledState: AppPageState.errorRetryable,
      message: '当前 fake transport 尚未提供已发布展示变更 canonical path。',
    );
  } on FormatException catch (error) {
    return EnterpriseHubActionResult<T>(
      isSuccess: false,
      method: method,
      path: canonicalPath,
      controlledState: AppPageState.errorNonRetryable,
      message: error.message,
    );
  }
}

Future<EnterpriseHubActionResult<bool>> _publishedChangeAckPut({
  required AppApiClient client,
  required String canonicalPath,
  required Map<String, Object?> body,
}) {
  return _publishedChangeSubmit(
    client: client,
    method: 'PUT',
    canonicalPath: canonicalPath,
    request: () => client.put(canonicalPath, body: body),
    parser: (_) => true,
  );
}

Future<EnterpriseHubActionResult<bool>> _publishedChangeAckDelete({
  required AppApiClient client,
  required String canonicalPath,
}) {
  return _publishedChangeSubmit(
    client: client,
    method: 'DELETE',
    canonicalPath: canonicalPath,
    request: () => client.delete(canonicalPath),
    parser: (_) => true,
  );
}

AppPageState? _mapFailureState(int statusCode) {
  if (statusCode >= 200 && statusCode < 300) {
    return null;
  }
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

String? _messageFromPayload(Map<String, Object?>? payload) {
  if (payload == null) {
    return null;
  }
  return _readString(payload['message']) ??
      _readString(payload['errorMessage']) ??
      _readString(payload['detail']);
}

String? _errorCodeFromPayload(Map<String, Object?>? payload) {
  if (payload == null) {
    return null;
  }
  return _readString(payload['code']) ?? _readString(payload['errorCode']);
}
