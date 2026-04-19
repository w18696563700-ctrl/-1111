import 'package:mobile/core/api/app_ui_contracts.dart';

final class AuthCanonicalPaths {
  const AuthCanonicalPaths._();

  static const String otpSend = '/api/app/auth/otp/send';
  static const String otpLogin = '/api/app/auth/otp/login';
  static const String passwordLogin = '/api/app/auth/password/login';
  static const String passwordSet = '/api/app/auth/password/set';
  static const String passwordReset = '/api/app/auth/password/reset';
  static const String refresh = '/api/app/auth/refresh';
  static const String logout = '/api/app/auth/logout';
}

class AuthActionResult<T> {
  const AuthActionResult({
    required this.state,
    required this.method,
    required this.path,
    this.data,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final T? data;
  final String? message;
  final String? errorCode;
}

class OtpSendView {
  const OtpSendView({required this.cooldownSeconds, required this.traceId});

  final int cooldownSeconds;
  final String traceId;
}

class SessionEnvelope {
  const SessionEnvelope({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
    this.shellBootstrapState,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;
  final String? shellBootstrapState;
}

class ActionAckView {
  const ActionAckView({required this.ok, required this.traceId});

  final bool ok;
  final String traceId;
}
