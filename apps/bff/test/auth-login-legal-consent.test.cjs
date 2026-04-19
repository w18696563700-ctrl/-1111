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

function createService({ postImpl } = {}) {
  return new AuthService(
    {
      async post(path, body) {
        return postImpl(path, body);
      },
    },
    {
      buildAuthTransportHeaders() {
        return {};
      },
    },
    new ErrorNormalizerService(),
    {},
  );
}

test('BFF otp/login forwards consentAccepted to the server login path', async () => {
  let capturedPath = null;
  let capturedBody = null;
  const service = createService({
    postImpl: async (path, body) => {
      capturedPath = path;
      capturedBody = body;
      return {
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        expiresInSeconds: 3600,
        shellBootstrapState: 'authenticated',
      };
    },
  });

  const result = await service.loginWithOtp(
    {
      mobile: '13800000000',
      otpCode: '123456',
      deviceId: 'device-1',
      consentAccepted: true,
    },
    {},
  );

  assert.equal(capturedPath, '/server/auth/otp/login');
  assert.equal(capturedBody.consentAccepted, true);
  assert.equal(result.accessToken, 'access-token');
});

test('BFF otp/login maps AUTH_CONSENT_REQUIRED to the exact app-facing message', async () => {
  const service = createService({
    postImpl: async () => {
      throw createAxiosError(
        400,
        'AUTH_CONSENT_REQUIRED',
        '请先阅读并同意《用户协议》《隐私政策》。',
      );
    },
  });

  await assert.rejects(
    () =>
      service.loginWithOtp(
        {
          mobile: '13800000000',
          otpCode: '123456',
          deviceId: 'device-1',
          consentAccepted: true,
        },
        {},
      ),
    (thrown) => {
      assert.equal(thrown.getStatus(), 400);
      assert.equal(thrown.getResponse().code, 'AUTH_CONSENT_REQUIRED');
      assert.equal(
        thrown.getResponse().message,
        '请先阅读并同意《用户协议》《隐私政策》。',
      );
      return true;
    },
  );
});
