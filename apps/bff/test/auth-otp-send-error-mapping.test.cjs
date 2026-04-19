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

function createService({ onPost }) {
  return new AuthService(
    {
      async post(path, body, options) {
        return onPost(path, body, options);
      },
    },
    {
      buildAuthTransportHeaders() {
        return { 'x-request-id': 'req-id' };
      },
      buildReadOnlyForwardHeaders() {
        return { 'x-request-id': 'req-id' };
      },
    },
    new ErrorNormalizerService(),
  );
}

test('otp/send maps AUTH_OTP_SEND_LIMIT_REACHED to a precise app-facing message', async () => {
  const service = createService({
    onPost: async () => {
      throw createAxiosError(
        429,
        'AUTH_OTP_SEND_LIMIT_REACHED',
        'The current mobile has reached the upstream OTP send limit.',
      );
    },
  });

  await assert.rejects(
    () =>
      service.sendOtp(
        {
          mobile: '16623725916',
          scene: 'login',
          deviceId: 'device-1',
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 429);
      assert.equal(error.getResponse().code, 'AUTH_OTP_SEND_LIMIT_REACHED');
      assert.equal(
        error.getResponse().message,
        '当前手机号今日验证码次数已达上限，请明日再试或更换其他手机号。',
      );
      return true;
    },
  );
});
