const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId) {
  return {
    authorization: '',
    actorId: '',
    userId: '',
    organizationId: '',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

function createConfig(overrides = {}) {
  return {
    authWhitelistTestSessionEnabled: true,
    authWhitelistTestSessionMobiles: ['13800138000'],
    sessionRefreshTokenPepper: 'pepper',
    ...overrides,
  };
}

test('whitelist test session issues a real session and access carrier under env flag plus mobile whitelist', async () => {
  const { AuthWhitelistTestSessionService } = require('../dist/modules/auth/auth-whitelist-test-session.service.js');
  const { AuthPresenter } = require('../dist/modules/auth/auth.presenter.js');
  const { AccessCarrierService } = require('../dist/modules/auth/access-carrier.service.js');

  const savedSessions = [];
  const auditCalls = [];
  const service = new AuthWhitelistTestSessionService(
    {},
    {
      create(input) {
        return input;
      }
    },
    {
      async findOneBy() {
        return {
          id: 'member-1',
          organizationId: 'org-1',
          userId: 'user-1',
          roleKey: 'supplier_admin',
          memberStatus: 'active'
        };
      }
    },
    {
      async findOne() {
        return {
          certificationStatus: 'approved'
        };
      }
    },
    {
      async transaction(callback) {
        return callback({
          getRepository(entity) {
            return {
              async findOneBy(criteria) {
                if (entity.name === 'UserEntity') {
                  if (criteria.id === 'user-1' || criteria.mobile === '13800138000') {
                    return { id: 'user-1', mobile: '13800138000', status: 'active' };
                  }
                  return null;
                }
                if (entity.name === 'OrganizationMemberEntity') {
                  return {
                    id: 'member-1',
                    organizationId: 'org-1',
                    userId: 'user-1',
                    roleKey: 'supplier_admin',
                    memberStatus: 'active'
                  };
                }
                return null;
              },
              async findOne() {
                if (entity.name === 'OrganizationCertificationEntity') {
                  return { certificationStatus: 'approved' };
                }
                return null;
              },
              create(input) {
                return input;
              },
              async save(value) {
                if (entity.name === 'SessionEntity') {
                  savedSessions.push(value);
                  return value;
                }
                return value;
              }
            };
          }
        });
      }
    },
    {
      parseWhitelistTestSession(payload) {
        return {
          userId: payload.userId ?? null,
          mobile: payload.mobile ?? null,
          organizationId: payload.organizationId,
          roleKey: payload.roleKey,
          certificationStatus: payload.certificationStatus ?? null,
          expiresAt: new Date(payload.expiresAt),
          reason: payload.reason,
          deviceId: payload.deviceId ?? null,
          deviceName: payload.deviceName ?? null
        };
      }
    },
    new AccessCarrierService({
      authAccessTokenSecret: 'a',
      sessionSigningSecret: 'b',
      sessionOpaqueVerifierSecret: 'c'
    }),
    new AuthPresenter(),
    createConfig(),
    {
      async recordWhitelistTestSessionIssued(input) {
        auditCalls.push(input);
      }
    }
  );

  const result = await service.issue(
    {
      mobile: '13800138000',
      organizationId: 'org-1',
      roleKey: 'supplier_admin',
      certificationStatus: 'approved',
      expiresAt: '2026-04-11T00:00:00.000Z',
      reason: '联调白名单会话'
    },
    createContext('whitelist-issue')
  );

  assert.equal(savedSessions.length, 1);
  assert.equal(savedSessions[0].organizationId, 'org-1');
  assert.equal(savedSessions[0].authMode, 'whitelist_test');
  assert.equal(savedSessions[0].issueReason, '联调白名单会话');
  assert.equal(auditCalls.length, 1);
  assert.equal(auditCalls[0].organizationId, 'org-1');
  assert.equal(result.organizationId, 'org-1');
  assert.equal(result.roleKey, 'supplier_admin');
  assert.equal(result.certificationStatus, 'approved');
  assert.equal(result.authMode, 'whitelist_test');
  assert.ok(typeof result.accessToken === 'string' && result.accessToken.length > 0);
  assert.ok(typeof result.refreshToken === 'string' && result.refreshToken.length > 0);
});

test('whitelist test session denies issuance when env flag is off or mobile is removed from whitelist', async () => {
  const { AuthWhitelistTestSessionService } = require('../dist/modules/auth/auth-whitelist-test-session.service.js');
  const { AuthPresenter } = require('../dist/modules/auth/auth.presenter.js');
  const { AccessCarrierService } = require('../dist/modules/auth/access-carrier.service.js');

  const createService = (config) =>
    new AuthWhitelistTestSessionService(
      {},
      { create(input) { return input; } },
      {},
      {},
      {
        async transaction(callback) {
          return callback({
            getRepository(entity) {
              return {
                async findOneBy() {
                  if (entity.name === 'UserEntity') {
                    return { id: 'user-1', mobile: '13800138000', status: 'active' };
                  }
                  if (entity.name === 'OrganizationMemberEntity') {
                    return {
                      id: 'member-1',
                      organizationId: 'org-1',
                      userId: 'user-1',
                      roleKey: 'supplier_admin',
                      memberStatus: 'active'
                    };
                  }
                  return null;
                },
                async findOne() {
                  if (entity.name === 'OrganizationCertificationEntity') {
                    return { certificationStatus: 'approved' };
                  }
                  return null;
                },
                async save() {
                  throw new Error('should not save session');
                }
              };
            }
          });
        }
      },
      {
        parseWhitelistTestSession(payload) {
          return {
            userId: null,
            mobile: payload.mobile,
            organizationId: payload.organizationId,
            roleKey: payload.roleKey,
            certificationStatus: payload.certificationStatus ?? null,
            expiresAt: new Date(payload.expiresAt),
            reason: payload.reason,
            deviceId: null,
            deviceName: null
          };
        }
      },
      new AccessCarrierService({
        authAccessTokenSecret: 'a',
        sessionSigningSecret: 'b',
        sessionOpaqueVerifierSecret: 'c'
      }),
      new AuthPresenter(),
      config,
      {
        async recordWhitelistTestSessionIssued() {
          throw new Error('should not audit');
        }
      }
    );

  await assert.rejects(
    () =>
      createService(createConfig({ authWhitelistTestSessionEnabled: false })).issue(
        {
          mobile: '13800138000',
          organizationId: 'org-1',
          roleKey: 'supplier_admin',
          expiresAt: '2026-04-11T00:00:00.000Z',
          reason: 'disabled'
        },
        createContext('disabled')
      ),
    (error) => error?.response?.code === 'AUTH_RESOURCE_UNAVAILABLE'
  );

  await assert.rejects(
    () =>
      createService(createConfig({ authWhitelistTestSessionMobiles: [] })).issue(
        {
          mobile: '13800138000',
          organizationId: 'org-1',
          roleKey: 'supplier_admin',
          expiresAt: '2026-04-11T00:00:00.000Z',
          reason: 'not-whitelisted'
        },
        createContext('not-whitelisted')
      ),
    (error) => error?.response?.code === 'AUTH_PERMISSION_INSUFFICIENT'
  );
});

test('current session verification revokes whitelist test session when env flag is off or whitelist is removed', async () => {
  const { CurrentSessionVerificationService } = require('../dist/modules/auth/current-session-verification.service.js');

  const session = {
    id: 'session-1',
    userId: 'user-1',
    organizationId: 'org-1',
    authMode: 'whitelist_test',
    status: 'valid',
    revokedAt: null,
    expiresAt: new Date('2026-04-11T00:00:00.000Z')
  };
  let revoked = false;
  const service = new CurrentSessionVerificationService(
    {
      async findOneBy() {
        return session;
      },
      async save(value) {
        revoked = true;
        Object.assign(session, value);
        return value;
      }
    },
    {
      async findOneBy() {
        return { id: 'user-1', mobile: '13800138000', status: 'active' };
      }
    },
    {
      verify() {
        return {
          outcome: 'verified',
          payload: {
            sessionId: 'session-1',
            organizationId: 'org-1',
            expiresAt: '2026-04-10T12:00:00.000Z',
            nonce: 'nonce'
          }
        };
      },
      mapFailureReason(reason) {
        return reason.reason;
      }
    },
    createConfig({ authWhitelistTestSessionEnabled: false })
  );

  const result = await service.verifyCurrentSessionContext({
    ...createContext('verify'),
    authorization: 'Bearer any'
  });

  assert.equal(result.outcome, 'failed');
  assert.equal(result.reason, 'current_session_revoked');
  assert.equal(revoked, true);
  assert.equal(session.status, 'revoked');
});
