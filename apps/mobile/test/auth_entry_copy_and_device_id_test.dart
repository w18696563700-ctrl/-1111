import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_action_result_presenter.dart';
import 'package:mobile/core/auth/auth_contract.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('session store creates a stable non-legacy device id', () {
    final store = AppSessionStore();

    final first = store.ensureDeviceId();
    final second = store.ensureDeviceId();

    expect(second, first);
    expect(first, startsWith('mobile-'));
    expect(first, isNot('mobile-local-device'));
  });

  test(
    'session store restores persisted refresh token without access token',
    () async {
      final store = AppSessionStore(
        persistSession: true,
        storageNamespace: 'day0606_uat',
      );
      store.establishSession(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        expiresInSeconds: 3600,
        deviceId: 'device-1',
        localLoginSource: AppSessionLoginSource.passwordLogin,
      );

      final preferences = await SharedPreferences.getInstance();
      String? raw;
      for (var attempts = 0; attempts < 10 && raw == null; attempts += 1) {
        await Future<void>.delayed(Duration.zero);
        raw = preferences.getString('auth.app_session_store.v1.day0606_uat');
      }

      expect(raw, isNotNull);
      expect(raw, contains('refresh-token'));
      expect(raw, isNot(contains('access-token')));

      final restored = AppSessionStore(
        persistSession: true,
        storageNamespace: 'day0606_uat',
      );
      await restored.restorePersistedSession();

      expect(restored.refreshToken, 'refresh-token');
      expect(restored.deviceId, 'device-1');
      expect(restored.authorizationHeaders, isEmpty);
      expect(restored.shouldRefresh, isTrue);
    },
  );

  test('auth entry copy localizes error and status details', () {
    const failure = AuthActionResult<void>(
      state: AppPageState.errorRetryable,
      method: 'POST',
      path: AuthCanonicalPaths.otpLogin,
      message: '当前登录能力暂不可用，请稍后再试。',
      errorCode: 'AUTH_RESOURCE_UNAVAILABLE',
    );

    expect(
      authActionFailureMessage(failure, kind: AuthActionKind.login),
      '当前登录能力暂不可用，请稍后再试。（原因：服务暂不可用）',
    );

    expect(
      authActionSuccessMessageForOtpSend(
        mobile: '18696563700',
        remainingSeconds: 31,
        traceId: '7fe8d83a-8487-4b96-aa01-68c5d8e5b2f2',
      ),
      '验证码已发送至 186****3700，31 秒后可重新发送。受理编号：7fe8d8...b2f2。',
    );

    expect(
      authActionSuccessMessageForShell(
        const SessionEnvelope(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresInSeconds: 900,
          shellBootstrapState: 'no_organization',
        ),
      ),
      '登录已完成，页面将进入展览首页。',
    );
  });

  test('auth entry copy keeps otp send limit reached message precise', () {
    const failure = AuthActionResult<void>(
      state: AppPageState.errorRetryable,
      method: 'POST',
      path: AuthCanonicalPaths.otpSend,
      message: '当前手机号今日验证码次数已达上限，请明日再试或更换其他手机号。',
      errorCode: 'AUTH_OTP_SEND_LIMIT_REACHED',
    );

    expect(
      authActionFailureTitle(failure, kind: AuthActionKind.sendOtp),
      '当前手机号验证码次数已达上限',
    );
    expect(
      authActionFailureMessage(failure, kind: AuthActionKind.sendOtp),
      '当前手机号今日验证码次数已达上限，请明日再试或更换其他手机号。',
    );
  });
}
