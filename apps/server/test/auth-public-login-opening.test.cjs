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
          continue;
        }
        process.env[key] = value;
      }
    });
}

function makeContext() {
  return {
    authorization: 'Bearer test',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'org-1',
    actorRole: 'member',
    requestId: 'request-1',
    traceId: 'trace-1',
    userAgent: 'test-agent',
    remoteIp: '127.0.0.1',
  };
}

function makeService() {
  const otpRepository = {
    count: async () => 0,
  };
  const auditRepository = {
    count: async () => 0,
  };
  const events = {
    recordOtpRateLimitBreach: async () => undefined,
  };

  const { RuntimeConfigService } = require('../dist/core/runtime-config.service.js');
  const { AuthAntiAbuseService } = require('../dist/modules/auth/auth-anti-abuse.service.js');

  return new AuthAntiAbuseService(
    otpRepository,
    auditRepository,
    new RuntimeConfigService(),
    events
  );
}

test('S1-R01 public OTP send opens in public mode without whitelist dependency', async () => {
  await withEnv(
    {
      NODE_ENV: 'production',
      AUTH_PUBLIC_OTP_SEND_ENABLED: '1',
      OTP_TEST_WHITELIST_ENABLED: '0',
      OTP_TEST_WHITELIST_MOBILES: '',
      AUTH_DEV_LOGIN_WHITELIST_ENABLED: '0',
      AUTH_DEV_LOGIN_WHITELIST_MOBILE: '',
      AUTH_DEV_LOGIN_WHITELIST_CODE: '',
    },
    async () => {
      const service = makeService();

      assert.equal(service.resolveOtpSendAccessMode('13800138000'), 'public');
      await assert.doesNotReject(() =>
        service.assertOtpSendAllowed(
          {
            mobile: '13800138000',
            scene: 'login',
            deviceId: 'device-1',
          },
          makeContext()
        )
      );
    }
  );
});

test('S1-R01 isolated whitelist remains a closed fallback when public mode is off', async () => {
  await withEnv(
    {
      NODE_ENV: 'development',
      AUTH_PUBLIC_OTP_SEND_ENABLED: '0',
      OTP_TEST_WHITELIST_ENABLED: '1',
      OTP_TEST_WHITELIST_MOBILES: '13800138000',
      AUTH_DEV_LOGIN_WHITELIST_ENABLED: '0',
      AUTH_DEV_LOGIN_WHITELIST_MOBILE: '',
      AUTH_DEV_LOGIN_WHITELIST_CODE: '',
    },
    async () => {
      const service = makeService();

      assert.equal(service.resolveOtpSendAccessMode('13800138000'), 'isolated_whitelist');
      await assert.doesNotReject(() =>
        service.assertOtpSendAllowed(
          {
            mobile: '13800138000',
            scene: 'login',
            deviceId: 'device-2',
          },
          makeContext()
        )
      );
    }
  );
});

test('S1-R01 closes OTP send for non-whitelisted mobiles when public mode is off', async () => {
  await withEnv(
    {
      NODE_ENV: 'development',
      AUTH_PUBLIC_OTP_SEND_ENABLED: '0',
      OTP_TEST_WHITELIST_ENABLED: '1',
      OTP_TEST_WHITELIST_MOBILES: '13800138000',
      AUTH_DEV_LOGIN_WHITELIST_ENABLED: '0',
      AUTH_DEV_LOGIN_WHITELIST_MOBILE: '',
      AUTH_DEV_LOGIN_WHITELIST_CODE: '',
    },
    async () => {
      const service = makeService();

      assert.equal(service.resolveOtpSendAccessMode('13900139000'), 'closed');
      await assert.rejects(
        () =>
          service.assertOtpSendAllowed(
            {
              mobile: '13900139000',
              scene: 'login',
              deviceId: 'device-3',
            },
            makeContext()
          ),
        (error) =>
          typeof error?.getResponse === 'function' &&
          error.getResponse().code === 'AUTH_RESOURCE_UNAVAILABLE'
      );
    }
  );
});
