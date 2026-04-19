const test = require('node:test');
const assert = require('node:assert/strict');
const argon2 = require('argon2');

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

function makeContext(overrides = {}) {
  return {
    authorization: overrides.authorization ?? '',
    actorId: overrides.actorId ?? null,
    userId: overrides.userId ?? null,
    organizationId: overrides.organizationId ?? null,
    actorRole: overrides.actorRole ?? '',
    requestId: overrides.requestId ?? 'request-password-1',
    traceId: overrides.traceId ?? 'trace-password-1',
    userAgent: overrides.userAgent ?? 'test-agent',
    remoteIp: overrides.remoteIp ?? '127.0.0.1'
  };
}

function matchesWhere(record, where) {
  return Object.entries(where).every(([key, value]) => record[key] === value);
}

function makeRepository(stateSlice, getId) {
  return {
    findOneBy: async (where) => stateSlice.find((item) => matchesWhere(item, where)) ?? null,
    findOne: async ({ where, order } = {}) => {
      let items = [...stateSlice];
      if (where) {
        items = items.filter((item) => matchesWhere(item, where));
      }
      if (order?.joinedAt === 'DESC') {
        items.sort((left, right) => new Date(right.joinedAt).getTime() - new Date(left.joinedAt).getTime());
      }
      return items[0] ?? null;
    },
    create: (value) => ({ ...value }),
    save: async (value) => {
      const id = getId(value);
      const index = stateSlice.findIndex((item) => getId(item) === id);
      if (index >= 0) {
        stateSlice[index] = { ...stateSlice[index], ...value };
        return stateSlice[index];
      }
      stateSlice.push({ ...value });
      return value;
    }
  };
}

function makeHarness(options = {}) {
  const { AuthPasswordService } = require('../dist/modules/auth/auth-password.service.js');
  const { AuthCommandParser } = require('../dist/modules/auth/auth-command.parser.js');
  const { AuthPresenter } = require('../dist/modules/auth/auth.presenter.js');
  const { RuntimeConfigService } = require('../dist/core/runtime-config.service.js');
  const { UserEntity } = require('../dist/modules/identity/entities/user.entity.js');
  const { SessionEntity } = require('../dist/modules/identity/entities/session.entity.js');
  const { DeviceEntity } = require('../dist/modules/identity/entities/device.entity.js');
  const {
    PasswordCredentialEntity
  } = require('../dist/modules/identity/entities/password-credential.entity.js');
  const {
    OrganizationMemberEntity
  } = require('../dist/modules/organization/entities/organization-member.entity.js');

  const state = {
    users: [...(options.users ?? [])],
    sessions: [...(options.sessions ?? [])],
    devices: [...(options.devices ?? [])],
    memberships: [...(options.memberships ?? [])],
    passwordCredentials: [...(options.passwordCredentials ?? [])],
    passwordLoginSuccessEvents: [],
    passwordLoginFailureEvents: [],
    passwordSetEvents: [],
    passwordSetFailureEvents: [],
    passwordResetSuccessEvents: [],
    passwordResetFailureEvents: [],
    otpConsumptions: []
  };

  const userRepository = makeRepository(state.users, (item) => item.id);
  const sessionRepository = makeRepository(state.sessions, (item) => item.id);
  const deviceRepository = makeRepository(state.devices, (item) => item.id);
  const membershipRepository = makeRepository(state.memberships, (item) => `${item.userId}:${item.organizationId}`);
  const credentialRepository = makeRepository(state.passwordCredentials, (item) => item.userId);

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
      if (entity === PasswordCredentialEntity) {
        return credentialRepository;
      }
      throw new Error(`Unexpected repository request: ${entity?.name ?? 'unknown'}`);
    }
  };

  const otpService = {
    consumeResetOtp: async (mobile, otpCode) => {
      state.otpConsumptions.push({ mobile, otpCode });
      if (typeof options.consumeResetOtp === 'function') {
        return options.consumeResetOtp(mobile, otpCode);
      }
      return undefined;
    }
  };

  const verifier = {
    verifyCurrentSessionContext: async () =>
      options.currentSessionResult ?? {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-otp-1',
          actorId: 'actor-1',
          userId: 'user-1',
          organizationId: null,
          requestId: 'request-password-1',
          traceId: 'trace-password-1'
        }
      }
  };

  const service = new AuthPasswordService(
    userRepository,
    sessionRepository,
    deviceRepository,
    membershipRepository,
    credentialRepository,
    {
      transaction: async (callback) => callback(manager)
    },
    new AuthCommandParser(),
    {
      assertLoginAllowed: async () => undefined
    },
    otpService,
    {
      issue: ({ sessionId }) => `access-${sessionId}`
    },
    new RuntimeConfigService(),
    new AuthPresenter(),
    verifier,
    {
      recordPasswordLoginSuccess: async (payload) => {
        state.passwordLoginSuccessEvents.push(payload);
      },
      recordPasswordLoginFailure: async (payload) => {
        state.passwordLoginFailureEvents.push(payload);
      },
      recordPasswordSet: async (payload) => {
        state.passwordSetEvents.push(payload);
      },
      recordPasswordSetFailure: async (payload) => {
        state.passwordSetFailureEvents.push(payload);
      },
      recordPasswordResetRequested: async () => undefined,
      recordPasswordResetSuccess: async (payload) => {
        state.passwordResetSuccessEvents.push(payload);
      },
      recordPasswordResetFailure: async (payload) => {
        state.passwordResetFailureEvents.push(payload);
      }
    }
  );

  return { service, state };
}

async function hashPassword(password, pepper) {
  return argon2.hash(password, {
    type: argon2.argon2id,
    secret: Buffer.from(pepper, 'utf8'),
    salt: Buffer.from('1234567890abcdef'),
    timeCost: 3,
    memoryCost: 65536,
    parallelism: 1
  });
}

test('Round B password-reset parser accepts the frozen three-field contract without scene', async () => {
  const { AuthCommandParser } = require('../dist/modules/auth/auth-command.parser.js');
  const parser = new AuthCommandParser();

  const command = parser.parsePasswordReset({
    mobile: '13800000000',
    otpCode: '123456',
    newPassword: 'Newpass456'
  });

  assert.deepEqual(command, {
    mobile: '13800000000',
    otpCode: '123456',
    newPassword: 'Newpass456'
  });
});

test('Round B reset OTP consumption stays fixed to password_reset scene inside the server', async () => {
  const { AuthOtpService } = require('../dist/modules/auth/auth-otp.service.js');
  const service = new AuthOtpService(
    {},
    {},
    {},
    {},
    {
      recordOtpSendAttempt: async () => undefined,
      recordPasswordResetRequested: async () => undefined
    },
    {}
  );

  const consumptions = [];
  service.consumeOtp = async (mobile, scene, otpCode) => {
    consumptions.push({ mobile, scene, otpCode });
  };

  await service.consumeResetOtp('13800000000', '123456');
  assert.deepEqual(consumptions, [
    {
      mobile: '13800000000',
      scene: 'password_reset',
      otpCode: '123456'
    }
  ]);
});

test('Round B password login rejects when legal consent is missing', async () => {
  await withEnv(
    {
      AUTH_PASSWORD_PEPPER: 'pepper-round-b',
      AUTH_USER_AGREEMENT_VERSION: 'ua-2026-04-13',
      AUTH_PRIVACY_POLICY_VERSION: 'pp-2026-04-13',
      SESSION_REFRESH_TOKEN_PEPPER: 'refresh-pepper'
    },
    async () => {
      const { service } = makeHarness();
      await assert.rejects(
        () =>
          service.login(
            {
              mobile: '13800000000',
              password: 'Password123',
              deviceId: 'device-1'
            },
            makeContext()
          ),
        (error) => {
          assert.equal(error.getStatus(), 400);
          assert.equal(error.getResponse().code, 'AUTH_CONSENT_REQUIRED');
          return true;
        }
      );
    }
  );
});

test('Round B password login keeps public failure unified when password credential is missing', async () => {
  await withEnv(
    {
      AUTH_PASSWORD_PEPPER: 'pepper-round-b',
      AUTH_USER_AGREEMENT_VERSION: 'ua-2026-04-13',
      AUTH_PRIVACY_POLICY_VERSION: 'pp-2026-04-13',
      SESSION_REFRESH_TOKEN_PEPPER: 'refresh-pepper'
    },
    async () => {
      const { service, state } = makeHarness({
        users: [
          {
            id: 'user-1',
            mobile: '13800000000',
            status: 'active'
          }
        ]
      });

      await assert.rejects(
        () =>
          service.login(
            {
              mobile: '13800000000',
              password: 'Password123',
              consentAccepted: true,
              deviceId: 'device-1'
            },
            makeContext()
          ),
        (error) => {
          assert.equal(error.getStatus(), 401);
          assert.equal(error.getResponse().code, 'AUTH_PASSWORD_LOGIN_INVALID');
          return true;
        }
      );

      assert.equal(state.passwordLoginFailureEvents.length, 1);
      assert.equal(state.passwordLoginFailureEvents[0].failureReason, 'AUTH_PASSWORD_LOGIN_INVALID');
    }
  );
});

test('Round B password login reuses session envelope and writes password-login session truth', async () => {
  await withEnv(
    {
      AUTH_PASSWORD_PEPPER: 'pepper-round-b',
      AUTH_USER_AGREEMENT_VERSION: 'ua-2026-04-13',
      AUTH_PRIVACY_POLICY_VERSION: 'pp-2026-04-13',
      SESSION_REFRESH_TOKEN_PEPPER: 'refresh-pepper'
    },
    async () => {
      const storedHash = await hashPassword('Password123', 'pepper-round-b');
      const { service, state } = makeHarness({
        users: [
          {
            id: 'user-1',
            mobile: '13800000000',
            status: 'active'
          }
        ],
        passwordCredentials: [
          {
            userId: 'user-1',
            passwordHash: storedHash,
            passwordAlgo: 'argon2id',
            passwordSetAt: new Date('2026-04-13T00:00:00.000Z'),
            passwordUpdatedAt: new Date('2026-04-13T00:00:00.000Z')
          }
        ]
      });

      const result = await service.login(
        {
          mobile: '13800000000',
          password: 'Password123',
          consentAccepted: true,
          deviceId: 'device-1',
          deviceName: 'iPhone 15',
          osType: 'ios'
        },
        makeContext()
      );

      assert.equal(result.shellBootstrapState, 'no_organization');
      assert.match(result.accessToken, /^access-/);
      assert.equal(state.sessions.length, 1);
      assert.equal(state.passwordLoginSuccessEvents.length, 1);
      assert.equal(state.passwordLoginFailureEvents.length, 0);
      assert.equal(state.sessions[0].authMode, 'password_login');
      assert.equal(state.sessions[0].agreementVersion, 'ua-2026-04-13');
      assert.equal(state.sessions[0].privacyVersion, 'pp-2026-04-13');
      assert.ok(state.sessions[0].agreedAt instanceof Date);
    }
  );
});

test('Round B set-password only allows one-time credential creation from current OTP session', async () => {
  await withEnv(
    {
      AUTH_PASSWORD_PEPPER: 'pepper-round-b',
      AUTH_USER_AGREEMENT_VERSION: 'ua-2026-04-13',
      AUTH_PRIVACY_POLICY_VERSION: 'pp-2026-04-13',
      SESSION_REFRESH_TOKEN_PEPPER: 'refresh-pepper'
    },
    async () => {
      const { service, state } = makeHarness({
        users: [
          {
            id: 'user-1',
            mobile: '13800000000',
            status: 'active'
          }
        ],
        sessions: [
          {
            id: 'session-otp-1',
            userId: 'user-1',
            status: 'valid',
            authMode: 'otp_login',
            deviceId: 'device-1'
          }
        ]
      });

      const result = await service.set(
        {
          newPassword: 'Password123'
        },
        makeContext({
          authorization: 'Bearer current-session',
          actorId: 'actor-1',
          userId: 'user-1'
        })
      );

      assert.equal(result.ok, true);
      assert.equal(state.passwordCredentials.length, 1);
      assert.equal(state.passwordSetEvents.length, 1);
      assert.equal(state.passwordSetFailureEvents.length, 0);
      assert.equal(state.passwordCredentials[0].passwordAlgo, 'argon2id');

      const verified = await argon2.verify(state.passwordCredentials[0].passwordHash, 'Password123', {
        secret: Buffer.from('pepper-round-b', 'utf8')
      });
      assert.equal(verified, true);
    }
  );
});

test('Round B reset-password consumes password_reset OTP and does not auto-create session', async () => {
  await withEnv(
    {
      AUTH_PASSWORD_PEPPER: 'pepper-round-b',
      AUTH_USER_AGREEMENT_VERSION: 'ua-2026-04-13',
      AUTH_PRIVACY_POLICY_VERSION: 'pp-2026-04-13',
      SESSION_REFRESH_TOKEN_PEPPER: 'refresh-pepper'
    },
    async () => {
      const oldHash = await hashPassword('Password123', 'pepper-round-b');
      const { service, state } = makeHarness({
        users: [
          {
            id: 'user-1',
            mobile: '13800000000',
            status: 'active'
          }
        ],
        passwordCredentials: [
          {
            userId: 'user-1',
            passwordHash: oldHash,
            passwordAlgo: 'argon2id',
            passwordSetAt: new Date('2026-04-13T00:00:00.000Z'),
            passwordUpdatedAt: new Date('2026-04-13T00:00:00.000Z')
          }
        ]
      });

      const result = await service.reset(
        {
          mobile: '13800000000',
          otpCode: '123456',
          newPassword: 'Newpass456'
        },
        makeContext()
      );

      assert.equal(result.ok, true);
      assert.deepEqual(state.otpConsumptions, [{ mobile: '13800000000', otpCode: '123456' }]);
      assert.equal(state.sessions.length, 0);
      assert.equal(state.passwordResetSuccessEvents.length, 1);
      assert.equal(state.passwordResetFailureEvents.length, 0);

      const verified = await argon2.verify(state.passwordCredentials[0].passwordHash, 'Newpass456', {
        secret: Buffer.from('pepper-round-b', 'utf8')
      });
      assert.equal(verified, true);
    }
  );
});
