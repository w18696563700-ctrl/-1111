import 'dart:io';

enum AppApiEntryMode { cloud, sshTunnel, localDev, custom }

final class AppApiEntryTarget {
  static const String _formalCloudEnvKey = 'APP_FORMAL_CLOUD_BFF_BASE_URL';
  static const String sshTunnelBaseUrl = 'http://127.0.0.1:8080/api/app';
  static const String localDevelopmentBaseUrl = 'http://127.0.0.1:3000/api/app';

  static String get cloudBaseUrl {
    const compileTimeBaseUrl = String.fromEnvironment(_formalCloudEnvKey);
    if (compileTimeBaseUrl.isNotEmpty) {
      return compileTimeBaseUrl;
    }

    final runtimeBaseUrl = Platform.environment[_formalCloudEnvKey]?.trim();
    return runtimeBaseUrl == null || runtimeBaseUrl.isEmpty
        ? ''
        : runtimeBaseUrl;
  }

  static AppApiEntryMode defaultEntryMode({String? configuredCloudBaseUrl}) {
    final resolvedCloudBaseUrl =
        configuredCloudBaseUrl?.trim() ?? cloudBaseUrl.trim();
    return resolvedCloudBaseUrl.isNotEmpty
        ? AppApiEntryMode.cloud
        : AppApiEntryMode.sshTunnel;
  }

  static String get defaultBaseUrl => defaultBaseUrlForMode(defaultEntryMode());

  static AppApiEntryMode? parse(String? raw) {
    final normalized = raw?.trim().toLowerCase() ?? '';
    switch (normalized) {
      case 'cloud':
      case 'formal_cloud':
        return AppApiEntryMode.cloud;
      case 'ssh_tunnel':
      case 'tunnel':
        return AppApiEntryMode.sshTunnel;
      case 'local_dev':
      case 'local':
        return AppApiEntryMode.localDev;
      case 'custom':
        return AppApiEntryMode.custom;
      default:
        return null;
    }
  }

  static String defaultBaseUrlForMode(AppApiEntryMode mode) {
    switch (mode) {
      case AppApiEntryMode.cloud:
        return requireCloudBaseUrl();
      case AppApiEntryMode.sshTunnel:
        return sshTunnelBaseUrl;
      case AppApiEntryMode.localDev:
        return localDevelopmentBaseUrl;
      case AppApiEntryMode.custom:
        return defaultBaseUrl;
    }
  }

  static String requireCloudBaseUrl() {
    final baseUrl = cloudBaseUrl;
    if (baseUrl.isNotEmpty) {
      return baseUrl;
    }

    throw StateError(
      'APP_FORMAL_CLOUD_BFF_BASE_URL is not configured. Launch through the repository runtime scripts or pass --dart-define=APP_FORMAL_CLOUD_BFF_BASE_URL=<formal-cloud-bff-base-url>.',
    );
  }

  static AppApiEntryMode inferFromBaseUrl(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    final host = uri?.host.toLowerCase() ?? '';
    final port = uri?.hasPort == true ? uri!.port : null;

    if (_matchesConfiguredCloudBaseUrl(baseUrl)) {
      return AppApiEntryMode.cloud;
    }
    if ((host == '127.0.0.1' || host == 'localhost') && port == 8080) {
      return AppApiEntryMode.sshTunnel;
    }
    if (host == '127.0.0.1' || host == 'localhost') {
      return AppApiEntryMode.localDev;
    }
    return AppApiEntryMode.custom;
  }

  static bool isStagingLikeEnvironment(
    String baseUrl, {
    AppApiEntryMode? entryMode,
  }) {
    switch (entryMode ?? inferFromBaseUrl(baseUrl)) {
      case AppApiEntryMode.cloud:
        return false;
      case AppApiEntryMode.sshTunnel:
      case AppApiEntryMode.localDev:
        return true;
      case AppApiEntryMode.custom:
        final normalized = baseUrl.toLowerCase();
        return normalized.contains('127.0.0.1') ||
            normalized.contains('localhost') ||
            normalized.contains('staging') ||
            normalized.contains('dev') ||
            normalized.contains('test');
    }
  }

  static String userFacingLabel(String baseUrl, {AppApiEntryMode? entryMode}) {
    switch (entryMode ?? inferFromBaseUrl(baseUrl)) {
      case AppApiEntryMode.cloud:
        return '正式云端';
      case AppApiEntryMode.sshTunnel:
        return 'SSH隧道';
      case AppApiEntryMode.localDev:
        return '本地开发';
      case AppApiEntryMode.custom:
        return isStagingLikeEnvironment(baseUrl) ? '自定义联调' : '自定义入口';
    }
  }

  static bool _matchesConfiguredCloudBaseUrl(String baseUrl) {
    final configuredCloudBaseUrl = cloudBaseUrl;
    if (configuredCloudBaseUrl.isEmpty) {
      return false;
    }

    return _normalizeBaseUrl(baseUrl) ==
        _normalizeBaseUrl(configuredCloudBaseUrl);
  }

  static String _normalizeBaseUrl(String value) {
    return value.trim().toLowerCase().replaceFirst(RegExp(r'/+$'), '');
  }
}
