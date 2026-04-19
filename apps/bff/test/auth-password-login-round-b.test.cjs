const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  AuthService,
} = require('../dist/apps/bff/src/routes/auth/auth.service.js');

function createAxiosError(status, code, message) {
  return {
    isAxiosError: true,
    code: 'ERR_BAD_REQUEST',
    message: `Request failed with status code ${status}`,
    response: {
      status,
      data: {
        code,
        message,
        source: 'server',
      },
    },
  };
}

function createService({
  onPost,
  buildAuthTransportHeaders = () => ({ 'x-request-id': 'req-id' }),
  buildReadOnlyForwardHeaders = () => ({ 'x-request-id': 'req-id' }),
} = {}) {
  return new AuthService(
    {
      async post(path, body, options) {
        return onPost(path, body, options);
      },
    },
    {
      buildAuthTransportHeaders,
      buildReadOnlyForwardHeaders,
    },
    new ErrorNormalizerService(),
  );
}

test('password/login forwards required fields and deviceId fallback', async () => {
  let captured = null;
  const service = createService({
    onPost(path, body, options) {
      captured = { path, body, headers: options.headers };
      return {
        accessToken: 'a',
        refreshToken: 'r',
        expiresInSeconds: 3600,
        shellBootstrapState: 'authenticated',
      };
    },
  });

  const result = await service.loginWithPassword(
    {
      mobile: '13800000000',
      password: ' P@ssw0rd ',
      consentAccepted: true,
      deviceName: 'iPhone 15',
      osType: 'ios',
    },
    {
      'x-device-id': 'header-device-id',
    },
  );

  assert.equal(captured.path, '/server/auth/password/login');
  assert.equal(captured.body.mobile, '13800000000');
  assert.equal(captured.body.password, 'P@ssw0rd');
  assert.equal(captured.body.consentAccepted, true);
  assert.equal(captured.body.deviceName, 'iPhone 15');
  assert.equal(captured.body.osType, 'ios');
  assert.equal(captured.body.deviceId, 'header-device-id');
  assert.equal(result.shellBootstrapState, 'authenticated');
  assert.equal(captured.headers['x-request-id'], 'req-id');
});

test('password/login maps AUTH_PASSWORD_LOGIN_INVALID and AUTH_PASSWORD_NOT_SET without account enumeration split', async () => {
  const notSetService = createService({
    onPost: async () => {
      throw createAxiosError(
        400,
        'AUTH_PASSWORD_NOT_SET',
        'Password is not set.',
      );
    },
  });
  const loginInvalidService = createService({
    onPost: async () => {
      throw createAxiosError(
        400,
        'AUTH_PASSWORD_LOGIN_INVALID',
        'Password is wrong.',
      );
    },
  });

  await assert.rejects(
    () =>
      notSetService.loginWithPassword(
        {
          mobile: '13800000000',
          password: 'wrong',
          consentAccepted: true,
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'AUTH_PASSWORD_NOT_SET');
      assert.equal(
        error.getResponse().message,
        '手机号或密码错误，请检查后重试。',
      );
      return true;
    },
  );

  await assert.rejects(
    () =>
      loginInvalidService.loginWithPassword(
        {
          mobile: '13800000000',
          password: 'wrong',
          consentAccepted: true,
        },
        {},
      ),
    (error) => {
      assert.equal(error.getResponse().code, 'AUTH_PASSWORD_LOGIN_INVALID');
      assert.equal(
        error.getResponse().message,
        '手机号或密码错误，请检查后重试。',
      );
      return true;
    },
  );
});

test('password/login maps AUTH_CONSENT_REQUIRED message', async () => {
  const service = createService({
    onPost: async () => {
      throw createAxiosError(
        400,
        'AUTH_CONSENT_REQUIRED',
        'consent required',
      );
    },
  });

  await assert.rejects(
    () =>
      service.loginWithPassword(
        {
          mobile: '13800000000',
          password: 'wrong',
          consentAccepted: false,
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'AUTH_CONSENT_REQUIRED');
      assert.equal(
        error.getResponse().message,
        '请先阅读并同意《用户协议》《隐私政策》。',
      );
      return true;
    },
  );
});

test('password/set forwards newPassword and reuses action ack response', async () => {
  let captured = null;
  const service = createService({
    buildAuthTransportHeaders: () => {
      throw new Error('buildAuthTransportHeaders should not be used by setPassword');
    },
    buildReadOnlyForwardHeaders: () => ({
      authorization: 'Bearer actor',
    }),
    onPost(path, body, options) {
      captured = { path, body, headers: options.headers };
      return {
        ok: true,
        traceId: 'set-trace',
      };
    },
  });

  const result = await service.setPassword(
    {
      newPassword: 'new-secret',
      mobile: '13800000000',
    },
    { authorization: 'Bearer actor' },
  );

  assert.equal(captured.path, '/server/auth/password/set');
  assert.deepEqual(captured.body, { newPassword: 'new-secret' });
  assert.equal(captured.headers.authorization, 'Bearer actor');
  assert.equal(result.ok, true);
  assert.equal(result.traceId, 'set-trace');
});

test('password/set maps AUTH_PASSWORD_SET_NOT_ALLOWED', async () => {
  const service = createService({
    onPost: async () => {
      throw createAxiosError(
        400,
        'AUTH_PASSWORD_SET_NOT_ALLOWED',
        'set not allowed',
      );
    },
  });

  await assert.rejects(
    () =>
      service.setPassword({ newPassword: 'new-secret' }, {
        authorization: 'Bearer actor',
      }),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'AUTH_PASSWORD_SET_NOT_ALLOWED');
      assert.equal(
        error.getResponse().message,
        '当前场景不允许设置密码。',
      );
      return true;
    },
  );
});

test('password/reset forwards mobile, otpCode, newPassword', async () => {
  let captured = null;
  const service = createService({
    onPost(path, body, options) {
      captured = { path, body, headers: options.headers };
      return {
        ok: true,
        traceId: 'reset-trace',
      };
    },
  });

  const result = await service.resetPassword(
    {
      mobile: '13800000000',
      otpCode: '123456',
      newPassword: 'new-pass',
    },
    {
      'x-device-id': 'device-reset',
    },
  );

  assert.equal(captured.path, '/server/auth/password/reset');
  assert.deepEqual(captured.body, {
    mobile: '13800000000',
    otpCode: '123456',
    newPassword: 'new-pass',
  });
  assert.equal(captured.headers['x-request-id'], 'req-id');
  assert.equal(result.ok, true);
  assert.equal(result.traceId, 'reset-trace');
});

test('password/reset maps AUTH_PASSWORD_RESET_OTP_INVALID and AUTH_PASSWORD_POLICY_INVALID', async () => {
  const otpInvalidService = createService({
    onPost: async () => {
      throw createAxiosError(
        400,
        'AUTH_PASSWORD_RESET_OTP_INVALID',
        'otp invalid',
      );
    },
  });
  const policyService = createService({
    onPost: async () => {
      throw createAxiosError(
        400,
        'AUTH_PASSWORD_POLICY_INVALID',
        'policy invalid',
      );
    },
  });

  await assert.rejects(
    () =>
      otpInvalidService.resetPassword(
        { mobile: '13800000000', otpCode: '123456', newPassword: 'short' },
        {},
      ),
    (error) => {
      assert.equal(error.getResponse().code, 'AUTH_PASSWORD_RESET_OTP_INVALID');
      assert.equal(
        error.getResponse().message,
        '验证码无效或已过期，请重新获取后重试。',
      );
      return true;
    },
  );
  await assert.rejects(
    () =>
      policyService.resetPassword(
        { mobile: '13800000000', otpCode: '123456', newPassword: 'short' },
        {},
      ),
    (error) => {
      assert.equal(error.getResponse().code, 'AUTH_PASSWORD_POLICY_INVALID');
      assert.equal(
        error.getResponse().message,
        '密码不符合要求，请检查后重试。',
      );
      return true;
    },
  );
});

test('otp/send keeps scene=password_reset transport payload unchanged except device normalization', async () => {
  let capturedBody = null;
  const service = createService({
    onPost(path, body) {
      if (path === '/server/auth/otp/send') {
        capturedBody = body;
        return {
          cooldownSeconds: 60,
          traceId: 'otp-send-trace',
        };
      }
      throw new Error('unexpected path');
    },
  });

  await service.sendOtp(
    {
      scene: 'password_reset',
      mobile: '13800000000',
      deviceId: 'body-device',
    },
    {},
  );

  assert.equal(capturedBody.scene, 'password_reset');
  assert.equal(capturedBody.deviceId, 'body-device');
});
