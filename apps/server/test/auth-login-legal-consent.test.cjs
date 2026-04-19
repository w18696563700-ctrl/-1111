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
    authorization: '',
    actorId: null,
    userId: null,
    organizationId: null,
    actorRole: '',
    requestId: 'request-consent-1',
    traceId: 'trace-consent-1',
    userAgent: 'test-agent',
    remoteIp: '127.0.0.1',
  };
}

function matchesWhere(record, where) {
  return Object.entries(where).every(([key, value]) => record[key] === value);
}

function makeHarness() {
  const { AuthSessionService } = require('../dist/modules/auth/auth-session.service.js');
  const { AuthCommandParser } = require('../dist/modules/auth/auth-command.parser.js');
  const { AuthPresenter } = require('../dist/modules/auth/auth.presenter.js');
  const { RuntimeConfigService } = require('../dist/core/runtime-config.service.js');
  const { UserEntity } = require('../dist/modules/identity/entities/user.entity.js');
  const { SessionEntity } = require('../dist/modules/identity/entities/session.entity.js');
  const { DeviceEntity } = require('../dist/modules/identity/entities/device.entity.js');
  const {
    OrganizationMemberEntity,
  } = require('../dist/modules/organization/entities/organization-member.entity.js');

  const state = {
    users: [],
    sessions: [],
    devices: [],
    memberships: [],
    loginSuccessEvents: [],
    loginFailureEvents: [],
  };

  const userRepository = {
    findOneBy: async (where) => state.users.find((item) => matchesWhere(item, where)) ?? null,
    create: (value) => ({ ...value }),
    save: async (value) => {
      const index = state.users.findIndex((item) => item.id === value.id);
      if (index >= 0) {
        state.users[index] = { ...state.users[index], ...value };
        return state.users[index];
      }
      state.users.push({ ...value });
      return value;
    },
  };

  const sessionRepository = {
    create: (value) => ({ ...value }),
    save: async (value) => {
      const index = state.sessions.findIndex((item) => item.id === value.id);
      if (index >= 0) {
        state.sessions[index] = { ...state.sessions[index], ...value };
        return state.sessions[index];
      }
      state.sessions.push({ ...value });
      return value;
    },
  };

  const deviceRepository = {
    findOneBy: async (where) => state.devices.find((item) => matchesWhere(item, where)) ?? null,
    create: (value) => ({ ...value }),
    save: async (value) => {
      const index = state.devices.findIndex((item) => item.id === value.id);
      if (index >= 0) {
        state.devices[index] = { ...state.devices[index], ...value };
        return state.devices[index];
      }
      state.devices.push({ ...value });
      return value;
    },
  };

  const membershipRepository = {
    findOne: async () => null,
  };

  const manager = {
    getRepository(entity) {
      if (entity === UserEntity) {
        return userRepository;
      }
      if (entity === SessionEntity) {
        return sessionRepository;
      }
      if (entity === DeviceEntity) {
        return deviceRepository;
      }
      if (entity === OrganizationMemberEntity) {
        return membershipRepository;
      }
      throw new Error(`Unexpected repository request: ${entity?.name ?? 'unknown'}`);
    },
  };

  const service = new AuthSessionService(
    userRepository,
    sessionRepository,
    membershipRepository,
    {
      transaction: async (callback) => callback(manager),
    },
    new AuthCommandParser(),
    {
      consumeLoginOtp: async () => undefined,
    },
    {
      issue: ({ sessionId }) => `access-${sessionId}`,
    },
    {},
    new AuthPresenter(),
    new RuntimeConfigService(),
    {
      assertLoginAllowed: async () => undefined,
    },
    {
      recordLoginSuccess: async (payload) => {
        state.loginSuccessEvents.push(payload);
      },
      recordLoginFailure: async (payload) => {
        state.loginFailureEvents.push(payload);
      },
      recordSessionRefresh: async () => undefined,
      recordLogout: async () => undefined,
    },
  );

  return { service, state };
}

test('auth login rejects when legal consent is missing', async () => {
  await withEnv(
    {
      AUTH_USER_AGREEMENT_VERSION: 'ua-v2026-04-13',
      AUTH_PRIVACY_POLICY_VERSION: 'pp-v2026-04-13',
      SESSION_REFRESH_TOKEN_PEPPER: 'test-pepper',
    },
    async () => {
      const { service } = makeHarness();

      await assert.rejects(
        () =>
          service.login(
            {
              mobile: '13800000000',
              otpCode: '123456',
              deviceId: 'device-1',
            },
            makeContext(),
          ),
        (error) => {
          assert.equal(error.getStatus(), 400);
          assert.equal(error.getResponse().code, 'AUTH_CONSENT_REQUIRED');
          return true;
        },
      );
    },
  );
});

test('auth login persists legal consent snapshot into session truth and audit payload', async () => {
  await withEnv(
    {
      AUTH_USER_AGREEMENT_VERSION: 'ua-v2026-04-13',
      AUTH_PRIVACY_POLICY_VERSION: 'pp-v2026-04-13',
      SESSION_REFRESH_TOKEN_PEPPER: 'test-pepper',
    },
    async () => {
      const { service, state } = makeHarness();

      const result = await service.login(
        {
          mobile: '13800000000',
          otpCode: '123456',
          deviceId: 'device-1',
          consentAccepted: true,
          deviceName: 'iPhone 15',
          osType: 'ios',
        },
        makeContext(),
      );

      assert.equal(result.shellBootstrapState, 'no_organization');
      assert.equal(state.sessions.length, 1);
      assert.equal(state.loginSuccessEvents.length, 1);
      assert.equal(state.loginFailureEvents.length, 0);

      const session = state.sessions[0];
      assert.equal(session.agreementVersion, 'ua-v2026-04-13');
      assert.equal(session.privacyVersion, 'pp-v2026-04-13');
      assert.ok(session.agreedAt instanceof Date);

      const auditPayload = state.loginSuccessEvents[0];
      assert.equal(auditPayload.agreementVersion, 'ua-v2026-04-13');
      assert.equal(auditPayload.privacyVersion, 'pp-v2026-04-13');
      assert.ok(auditPayload.agreedAt instanceof Date);
    },
  );
});
