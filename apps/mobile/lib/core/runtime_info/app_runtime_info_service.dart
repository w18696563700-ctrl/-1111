import 'package:flutter/foundation.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_api_entry_mode.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppRuntimeInfo {
  const AppRuntimeInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.environmentLabel,
    required this.entryModeLabel,
    required this.apiBaseSummary,
    required this.debugModeLabel,
  });

  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String environmentLabel;
  final String entryModeLabel;
  final String apiBaseSummary;
  final String debugModeLabel;

  String get versionSummary => '$version+$buildNumber';
}

class AppRuntimeInfoService {
  AppRuntimeInfoService();

  static const String _fallbackVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
  static const String _fallbackBuildNumber = String.fromEnvironment(
    'APP_BUILD_NUMBER',
    defaultValue: '1',
  );

  static AppRuntimeInfoService _instance = AppRuntimeInfoService();

  static AppRuntimeInfoService get instance => _instance;

  static void install(AppRuntimeInfoService service) {
    _instance = service;
  }

  static void reset() {
    _instance = AppRuntimeInfoService();
  }

  Future<AppRuntimeInfo> load() async {
    PackageInfo? packageInfo;
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } on Exception {
      packageInfo = null;
    }
    final config = AppApiConfig.fromEnvironment();
    final entryMode = config.effectiveEntryMode;
    return AppRuntimeInfo(
      appName: packageInfo?.appName ?? '展览装修之家',
      packageName: packageInfo?.packageName ?? 'mobile',
      version: packageInfo?.version ?? _fallbackVersion,
      buildNumber: packageInfo?.buildNumber ?? _fallbackBuildNumber,
      environmentLabel: config.userFacingEnvironmentLabel,
      entryModeLabel: _entryModeLabel(entryMode),
      apiBaseSummary: _apiBaseSummary(config.effectiveBaseUrl),
      debugModeLabel: kDebugMode ? 'debug' : 'release',
    );
  }

  String _entryModeLabel(AppApiEntryMode mode) {
    return switch (mode) {
      AppApiEntryMode.cloud => 'cloud',
      AppApiEntryMode.sshTunnel => 'ssh_tunnel',
      AppApiEntryMode.localDev => 'local_dev_disabled',
      AppApiEntryMode.custom => 'custom',
    };
  }

  String _apiBaseSummary(String baseUrl) {
    final uri = Uri.tryParse(baseUrl.trim());
    if (uri == null) {
      return '入口待确认';
    }

    final host = uri.host.isEmpty ? 'unknown-host' : uri.host;
    final port = uri.hasPort ? ':${uri.port}' : '';
    final path = uri.path.isEmpty ? '' : uri.path;
    final loopback = host == '127.0.0.1' || host == 'localhost';
    if (loopback) {
      return '$host$port$path';
    }

    return '${uri.scheme}://$host$path';
  }
}
