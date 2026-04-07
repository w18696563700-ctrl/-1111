import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_contract.dart';
import 'package:mobile/core/auth/auth_http_fallback_message.dart';

export 'package:mobile/core/auth/auth_contract.dart';

class AuthConsumerLayer {
  AuthConsumerLayer._(this._client);

  factory AuthConsumerLayer({AppApiClient? client}) {
    return AuthConsumerLayer._(client ?? AppApiClient());
  }

  static AuthConsumerLayer _instance = AuthConsumerLayer();

  static AuthConsumerLayer get instance => _instance;

  static void install(AuthConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = AuthConsumerLayer();
  }

  final AppApiClient _client;

  Future<AuthActionResult<OtpSendView>> sendOtp({
    required String mobile,
    String scene = 'login',
    String? captchaToken,
  }) async {
    return _post(
      canonicalPath: AuthCanonicalPaths.otpSend,
      body: <String, Object?>{
        'mobile': mobile.trim(),
        'scene': scene,
        'deviceId': AppSessionStore.instance.ensureDeviceId(),
        if (captchaToken case final String value when value.trim().isNotEmpty)
          'captchaToken': value.trim(),
      },
      parser: _parseOtpSendView,
    );
  }

  Future<AuthActionResult<SessionEnvelope>> loginWithOtp({
    required String mobile,
    required String otpCode,
  }) async {
    final deviceId = AppSessionStore.instance.ensureDeviceId();
    final result = await _post(
      canonicalPath: AuthCanonicalPaths.otpLogin,
      body: <String, Object?>{
        'mobile': mobile.trim(),
        'otpCode': otpCode.trim(),
        'deviceId': deviceId,
        'deviceName': 'Frontend Steward',
        'osType': Platform.operatingSystem,
      },
      parser: _parseSessionEnvelope,
    );

    final session = result.data;
    if (result.state == AppPageState.content && session != null) {
      AppSessionStore.instance.establishSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresInSeconds: session.expiresInSeconds,
        deviceId: deviceId,
      );
    }
    return result;
  }

  Future<AuthActionResult<SessionEnvelope>> refreshSession() async {
    final refreshToken = AppSessionStore.instance.refreshToken;
    if (refreshToken == null) {
      return const AuthActionResult<SessionEnvelope>(
        state: AppPageState.unauthorized,
        method: 'POST',
        path: AuthCanonicalPaths.refresh,
        message: '当前没有可用刷新会话。',
      );
    }

    final result = await _post(
      canonicalPath: AuthCanonicalPaths.refresh,
      body: <String, Object?>{
        'refreshToken': refreshToken,
        'deviceId': AppSessionStore.instance.ensureDeviceId(),
      },
      parser: _parseRefreshSessionEnvelope,
    );

    final session = result.data;
    if (result.state == AppPageState.content && session != null) {
      AppSessionStore.instance.establishSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresInSeconds: session.expiresInSeconds,
        deviceId: AppSessionStore.instance.deviceId,
      );
    } else if (result.state == AppPageState.unauthorized) {
      AppSessionStore.instance.clearSession();
    }

    return result;
  }

  Future<AuthActionResult<ActionAckView>> logout({
    bool revokeAllOtherDevices = false,
  }) async {
    final result = await _post(
      canonicalPath: AuthCanonicalPaths.logout,
      body: <String, Object?>{
        if (revokeAllOtherDevices) 'revokeAllOtherDevices': true,
        'deviceId': AppSessionStore.instance.deviceId,
      },
      parser: _parseActionAckView,
    );

    if (result.state == AppPageState.content ||
        result.state == AppPageState.unauthorized) {
      AppSessionStore.instance.clearSession();
    }
    return result;
  }

  Future<AuthActionResult<T>> _post<T>({
    required String canonicalPath,
    required Object? body,
    required T? Function(Object? payload) parser,
  }) async {
    try {
      final response = await _client.post(canonicalPath, body: body);
      return _mapResponse(
        response,
        method: 'POST',
        canonicalPath: canonicalPath,
        parser: parser,
      );
    } on SocketException {
      return _result<T>(
        state: AppPageState.errorRetryable,
        method: 'POST',
        path: canonicalPath,
        message: 'network error while requesting auth path',
      );
    } on HttpException {
      return _result<T>(
        state: AppPageState.errorRetryable,
        method: 'POST',
        path: canonicalPath,
        message: 'http error while requesting auth path',
      );
    } on FormatException {
      return _result<T>(
        state: AppPageState.errorNonRetryable,
        method: 'POST',
        path: canonicalPath,
        message: 'response decoding failed for auth path',
      );
    }
  }

  AuthActionResult<T> _mapResponse<T>(
    AppApiResponse response, {
    required String method,
    required String canonicalPath,
    required T? Function(Object? payload) parser,
  }) {
    final errorCode = _extractErrorCode(response.body);
    final message = _extractMessage(response.body);

    if (response.statusCode == 401) {
      return _failureResult<T>(
        state: AppPageState.unauthorized,
        method: method,
        path: canonicalPath,
        statusCode: response.statusCode,
        message: message,
        errorCode: errorCode,
      );
    }

    if (response.statusCode == 403) {
      return _failureResult<T>(
        state: AppPageState.forbidden,
        method: method,
        path: canonicalPath,
        statusCode: response.statusCode,
        message: message,
        errorCode: errorCode,
      );
    }

    if (response.statusCode == 404) {
      return _failureResult<T>(
        state: AppPageState.notFound,
        method: method,
        path: canonicalPath,
        statusCode: response.statusCode,
        message: message,
        errorCode: errorCode,
      );
    }

    if (response.statusCode == 400) {
      return _failureResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        statusCode: response.statusCode,
        message: message,
        errorCode: errorCode,
      );
    }

    if (response.statusCode == 429) {
      return _failureResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        statusCode: response.statusCode,
        message: message,
        errorCode: errorCode,
      );
    }

    if (response.statusCode == 503) {
      return _failureResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        statusCode: response.statusCode,
        message: message,
        errorCode: errorCode,
      );
    }

    if (response.statusCode >= 500) {
      return _failureResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        statusCode: response.statusCode,
        message: message,
        errorCode: errorCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return _failureResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        statusCode: response.statusCode,
        message: message,
        errorCode: errorCode,
      );
    }

    final data = parser(response.body);
    if (data == null) {
      return _result<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: 'auth response is missing required fields',
      );
    }

    return _result<T>(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: data,
    );
  }

  static AuthActionResult<T> _result<T>({
    required AppPageState state,
    required String method,
    required String path,
    T? data,
    String? message,
    String? errorCode,
  }) {
    return AuthActionResult<T>(
      state: state,
      method: method,
      path: path,
      data: data,
      message: message,
      errorCode: errorCode,
    );
  }

  static AuthActionResult<T> _failureResult<T>({
    required AppPageState state,
    required String method,
    required String path,
    required int statusCode,
    String? message,
    String? errorCode,
  }) {
    return _result<T>(
      state: state,
      method: method,
      path: path,
      message:
          message ??
          authFallbackMessage(canonicalPath: path, statusCode: statusCode),
      errorCode: errorCode,
    );
  }

  static OtpSendView? _parseOtpSendView(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final body = payload.map(
      (Object? key, Object? value) => MapEntry('$key', value),
    );
    final cooldownSeconds = _readInt(body['cooldownSeconds']);
    final traceId = _readString(body['traceId']);
    if (cooldownSeconds == null || traceId == null) {
      return null;
    }

    return OtpSendView(cooldownSeconds: cooldownSeconds, traceId: traceId);
  }

  static SessionEnvelope? _parseSessionEnvelope(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final body = payload.map(
      (Object? key, Object? value) => MapEntry('$key', value),
    );
    final accessToken = _readString(body['accessToken']);
    final refreshToken = _readString(body['refreshToken']);
    final expiresInSeconds = _readInt(body['expiresInSeconds']);
    final shellBootstrapState = _readString(body['shellBootstrapState']);
    if (accessToken == null ||
        refreshToken == null ||
        expiresInSeconds == null ||
        shellBootstrapState == null) {
      return null;
    }

    return SessionEnvelope(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresInSeconds: expiresInSeconds,
      shellBootstrapState: shellBootstrapState,
    );
  }

  static SessionEnvelope? _parseRefreshSessionEnvelope(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final body = payload.map(
      (Object? key, Object? value) => MapEntry('$key', value),
    );
    final accessToken = _readString(body['accessToken']);
    final refreshToken = _readString(body['refreshToken']);
    final expiresInSeconds = _readInt(body['expiresInSeconds']);
    if (accessToken == null ||
        refreshToken == null ||
        expiresInSeconds == null) {
      return null;
    }

    return SessionEnvelope(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresInSeconds: expiresInSeconds,
    );
  }

  static ActionAckView? _parseActionAckView(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final body = payload.map(
      (Object? key, Object? value) => MapEntry('$key', value),
    );
    final ok = body['ok'];
    final traceId = _readString(body['traceId']);
    if (ok is! bool || traceId == null) {
      return null;
    }

    return ActionAckView(ok: ok, traceId: traceId);
  }

  static String? _readString(Object? value) {
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  static String? _extractErrorCode(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    return _readString(payload['code']);
  }

  static String? _extractMessage(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    return _readString(payload['message']);
  }
}
