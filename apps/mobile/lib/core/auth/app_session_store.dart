import 'package:flutter/foundation.dart';

class AppSessionSnapshot {
  const AppSessionSnapshot({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.deviceId,
  });

  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? deviceId;

  bool get hasAccessToken =>
      accessToken != null && accessToken!.trim().isNotEmpty;

  bool get hasRefreshToken =>
      refreshToken != null && refreshToken!.trim().isNotEmpty;

  bool get isAccessTokenFresh {
    final expiry = expiresAt;
    if (!hasAccessToken || expiry == null) {
      return false;
    }

    return expiry.isAfter(
      DateTime.now().add(const Duration(seconds: 30)),
    );
  }
}

class AppSessionStore extends ChangeNotifier {
  static AppSessionStore _instance = AppSessionStore();

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

  AppSessionSnapshot get snapshot => AppSessionSnapshot(
    accessToken: _accessToken,
    refreshToken: _refreshToken,
    expiresAt: _expiresAt,
    deviceId: _deviceId,
  );

  bool get hasAnySession => snapshot.hasAccessToken || snapshot.hasRefreshToken;

  bool get hasRefreshToken => snapshot.hasRefreshToken;

  bool get shouldRefresh => snapshot.hasRefreshToken && !snapshot.isAccessTokenFresh;

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

    _deviceId = 'mobile-local-device';
    notifyListeners();
    return _deviceId!;
  }

  void establishSession({
    required String accessToken,
    required String refreshToken,
    required int expiresInSeconds,
    String? deviceId,
  }) {
    _accessToken = accessToken.trim();
    _refreshToken = refreshToken.trim();
    _expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
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
}
