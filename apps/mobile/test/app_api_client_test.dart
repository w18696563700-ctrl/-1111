import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_entry_mode.dart';
import 'package:mobile/core/api/app_api_client.dart';

const _compileTimeBaseUrl = String.fromEnvironment('APP_BFF_BASE_URL');
const _compileTimeCloudBaseUrl = String.fromEnvironment(
  'APP_FORMAL_CLOUD_BFF_BASE_URL',
);
const _compileTimeEntryMode = String.fromEnvironment('APP_RUNTIME_ENTRY_MODE');

final bool _hasRuntimeApiOverrides =
    (Platform.environment['APP_BFF_BASE_URL']?.isNotEmpty ?? false) ||
    (Platform.environment['APP_FORMAL_CLOUD_BFF_BASE_URL']?.isNotEmpty ??
        false) ||
    (Platform.environment['APP_RUNTIME_ENTRY_MODE']?.isNotEmpty ?? false);

final bool _hasCompileTimeApiOverrides =
    _compileTimeBaseUrl.isNotEmpty ||
    _compileTimeCloudBaseUrl.isNotEmpty ||
    _compileTimeEntryMode.isNotEmpty;

void main() {
  tearDown(AppApiConfig.resetRuntimeBaseUrlOverride);

  test('default entry mode stays on ssh tunnel even when cloud url exists', () {
    expect(
      AppApiEntryTarget.defaultEntryMode(
        configuredCloudBaseUrl: 'http://formal-cloud.test/api/app',
      ),
      AppApiEntryMode.sshTunnel,
    );
  });

  test(
    'default entry mode falls back to ssh tunnel when cloud url is absent',
    () {
      expect(
        AppApiEntryTarget.defaultEntryMode(configuredCloudBaseUrl: ''),
        AppApiEntryMode.sshTunnel,
      );
      expect(
        AppApiEntryTarget.defaultBaseUrlForMode(
          AppApiEntryTarget.defaultEntryMode(configuredCloudBaseUrl: ''),
        ),
        AppApiEntryTarget.sshTunnelBaseUrl,
      );
    },
  );

  test(
    'fromEnvironment defaults to ssh tunnel when no api entry overrides exist',
    () {
      final config = AppApiConfig.fromEnvironment();

      expect(config.effectiveEntryMode, AppApiEntryMode.sshTunnel);
      expect(config.effectiveBaseUrl, AppApiEntryTarget.sshTunnelBaseUrl);
    },
    skip: _hasRuntimeApiOverrides || _hasCompileTimeApiOverrides
        ? 'This expectation only holds when the test process has no API entry overrides.'
        : false,
  );

  test('runtime base url override rewires effective endpoint resolution', () {
    const cloudBaseUrl = 'http://formal-cloud.test/api/app';
    AppApiConfig.installRuntimeBaseUrlOverride(cloudBaseUrl);
    final config = AppApiConfig(
      baseUrl: 'http://placeholder.test/api/app',
      entryMode: AppApiEntryMode.cloud,
    );

    expect(config.effectiveBaseUrl, cloudBaseUrl);
    expect(
      config.resolveCanonicalPath('/api/app/auth/otp/login').toString(),
      'http://formal-cloud.test/api/app/auth/otp/login',
    );
  });

  test('entry mode labels distinguish cloud and tunnel runtimes', () {
    expect(
      AppApiConfig(
        baseUrl: 'http://formal-cloud.test/api/app',
        entryMode: AppApiEntryMode.cloud,
      ).userFacingEnvironmentLabel,
      '正式云端',
    );
    expect(
      AppApiConfig(
        baseUrl: AppApiEntryTarget.sshTunnelBaseUrl,
      ).userFacingEnvironmentLabel,
      'SSH隧道',
    );
    expect(
      () => AppApiConfig(baseUrl: AppApiEntryTarget.localDevelopmentBaseUrl),
      throwsStateError,
    );
  });

  test('local development mode is rejected for runtime configs', () {
    expect(
      () => AppApiEntryTarget.defaultBaseUrlForMode(AppApiEntryMode.localDev),
      throwsStateError,
    );
    expect(
      () => AppApiConfig(baseUrl: AppApiEntryTarget.localDevelopmentBaseUrl),
      throwsStateError,
    );
    expect(
      () => AppApiConfig.installRuntimeBaseUrlOverride(
        AppApiEntryTarget.localDevelopmentBaseUrl,
      ),
      throwsStateError,
    );
  });
}
