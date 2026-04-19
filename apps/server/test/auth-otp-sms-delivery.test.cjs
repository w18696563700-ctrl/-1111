const test = require('node:test');
const assert = require('node:assert/strict');

function withEnv(patch, run) {
  const previous = new Map();
  for (const [key, value] of Object.entries(patch)) {
    previous.set(key, process.env[key]);
    process.env[key] = value;
  }
  return Promise.resolve()
    .then(run)
    .finally(() => {
      for (const [key, value] of previous.entries()) {
        if (value === undefined) {
          delete process.env[key];
        } else {
          process.env[key] = value;
        }
      }
    });
}

test('Aliyun BUSINESS_LIMIT_CONTROL maps to AUTH_OTP_SEND_LIMIT_REACHED', async () => {
  await withEnv(
    {
      ALIYUN_SMS_ACCESS_KEY_ID: 'test-ak',
      ALIYUN_SMS_ACCESS_KEY_SECRET: 'test-sk',
      ALIYUN_SMS_SIGN_NAME: '重庆晶芯科科技',
      ALIYUN_SMS_TEMPLATE_CODE: 'SMS_333410671',
      ALIYUN_SMS_REGION_ID: 'cn-hangzhou',
    },
    async () => {
      const {
        RuntimeConfigService,
      } = require('../dist/core/runtime-config.service.js');
      const {
        AuthOtpSmsDeliveryService,
      } = require('../dist/modules/auth/auth-otp-sms-delivery.service.js');

      const service = new AuthOtpSmsDeliveryService(new RuntimeConfigService());
      service.getClient = () => ({
        sendSms: async () => ({
          body: {
            code: 'isv.BUSINESS_LIMIT_CONTROL',
            message: '触发天级流控Permits:10',
            requestId: 'provider-request-1',
          },
        }),
      });

      await assert.rejects(
        () =>
          service.sendLoginOtp({
            mobile: '16623725916',
            otpCode: '123456',
            traceId: 'trace-otp-1',
          }),
        (error) => {
          assert.equal(error.getStatus(), 429);
          const response = error.getResponse();
          assert.equal(response.code, 'AUTH_OTP_SEND_LIMIT_REACHED');
          assert.equal(
            response.message,
            'The current mobile has reached the upstream OTP send limit.',
          );
          assert.equal(
            response.details.providerCode,
            'isv.BUSINESS_LIMIT_CONTROL',
          );
          assert.equal(
            response.details.providerRequestId,
            'provider-request-1',
          );
          return true;
        },
      );
    },
  );
});
