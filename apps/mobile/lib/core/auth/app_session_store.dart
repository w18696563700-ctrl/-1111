import 'dart:math';

import 'package:flutter/foundation.dart';

final class AppSessionLoginSource {
  const AppSessionLoginSource._();

  static const String otpLogin = 'otp_login';
  static const String passwordLogin = 'password_login';
}

class AppSessionSnapshot {
  const AppSessionSnapshot({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.deviceId,
    required this.localLoginSource,
  });

  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? deviceId;
  final String? localLoginSource;

  bool get hasAccessToken =>
      accessToken != null && accessToken!.trim().isNotEmpty;

  bool get hasRefreshToken =>
      refreshToken != null && refreshToken!.trim().isNotEmpty;

  bool get isAccessTokenFresh {
    final expiry = expiresAt;
    if (!hasAccessToken || expiry == null) {
      return false;
    }

    return expiry.isAfter(DateTime.now().add(const Duration(seconds: 30)));
  }
}

class AppSessionStore extends ChangeNotifier {
  static AppSessionStore _instance = AppSessionStore();
  static final Random _deviceRandom = Random();

  static AppSessionStore get instance => _instance;

  static void install(AppSessionStore store) {
    _instance = store;
  }

  static void reset() {
    _instance = AppSessionStore();
  }

  String? _accessToken;
  String? _refreshToken;
  DateTime? _expiresAt;
  String? _deviceId;
  String? _localLoginSource;
  bool _passwordSetupPromptDismissed = false;

  AppSessionSnapshot get snapshot => AppSessionSnapshot(
    accessToken: _accessToken,
    refreshToken: _refreshToken,
    expiresAt: _expiresAt,
    deviceId: _deviceId,
    localLoginSource: _localLoginSource,
  );

  bool get hasAnySession => snapshot.hasAccessToken || snapshot.hasRefreshToken;

  bool get hasRefreshToken => snapshot.hasRefreshToken;

  bool get shouldRefresh =>
      snapshot.hasRefreshToken && !snapshot.isAccessTokenFresh;

  Map<String, String> get authorizationHeaders {
    final token = _accessToken?.trim();
    if (token == null || token.isEmpty) {
      return const <String, String>{};
    }

    return <String, String>{'authorization': 'Bearer $token'};
  }

  String ensureDeviceId() {
    final current = _deviceId?.trim();
    if (current != null && current.isNotEmpty) {
      return current;
    }

    _deviceId = _buildLocalDeviceId();
    notifyListeners();
    return _deviceId!;
  }

  void establishSession({
    required String accessToken,
    required String refreshToken,
    required int expiresInSeconds,
    String? deviceId,
    String? localLoginSource,
  }) {
    _accessToken = accessToken.trim();
    _refreshToken = refreshToken.trim();
    _expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
    _localLoginSource = _normalizeLocalLoginSource(localLoginSource);
    _passwordSetupPromptDismissed = false;
    if (deviceId case final String value when value.trim().isNotEmpty) {
      _deviceId = value.trim();
    } else {
      ensureDeviceId();
    }
    notifyListeners();
  }

  void clearSession() {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;
    _localLoginSource = null;
    _passwordSetupPromptDismissed = false;
    notifyListeners();
  }

  String? get refreshToken {
    final token = _refreshToken?.trim();
    return token == null || token.isEmpty ? null : token;
  }

  String? get deviceId {
    final value = _deviceId?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String? get localLoginSource {
    final value = _localLoginSource?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  bool get isOtpLoginSession =>
      hasAnySession && localLoginSource == AppSessionLoginSource.otpLogin;

  bool get isPasswordSetupPromptDismissed => _passwordSetupPromptDismissed;

  bool get shouldShowPasswordSetupPrompt =>
      hasAnySession && isOtpLoginSession && !_passwordSetupPromptDismissed;

  void markPasswordSetupPromptDismissed() {
    if (_passwordSetupPromptDismissed) {
      return;
    }

    _passwordSetupPromptDismissed = true;
    notifyListeners();
  }

  String _buildLocalDeviceId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final entropy = _deviceRandom.nextInt(0x7fffffff).toRadixString(36);
    return 'mobile-$timestamp-$entropy';
  }

  String? _normalizeLocalLoginSource(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    if (normalized == AppSessionLoginSource.otpLogin ||
        normalized == AppSessionLoginSource.passwordLogin) {
      return normalized;
    }
    return null;
  }
}
