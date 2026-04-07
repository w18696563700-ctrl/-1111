import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';

void main() {
  tearDown(AppApiConfig.resetRuntimeBaseUrlOverride);

  test(
    'app api default base url stays aligned with development tunnel address',
    () {
      expect(AppApiConfig.defaultBaseUrl, 'http://127.0.0.1:8080/api/app');
    },
  );

  test('runtime base url override rewires effective endpoint resolution', () {
    const cloudBaseUrl = 'http://47.108.180.198/api/app';
    AppApiConfig.installRuntimeBaseUrlOverride(cloudBaseUrl);
    final config = AppApiConfig(baseUrl: AppApiConfig.defaultBaseUrl);

    expect(config.effectiveBaseUrl, cloudBaseUrl);
    expect(
      config.resolveCanonicalPath('/api/app/auth/otp/login').toString(),
      'http://47.108.180.198/api/app/auth/otp/login',
    );
  });
}
