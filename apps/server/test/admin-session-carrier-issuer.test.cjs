const test = require('node:test');
const assert = require('node:assert/strict');

const {
  AdminSessionCarrierIssuerService,
} = require('../dist/modules/auth/admin-session-carrier-issuer.service.js');

test('Admin carrier issuer returns a Server Auth carrier for DB-backed platform reviewer', async () => {
  const harness = createHarness({
    memberships: [
      {
        userId: 'user-1',
        organizationId: 'platform-org',
        roleKey: 'platform_reviewer',
        memberStatus: 'active',
        joinedAt: new Date('2026-05-01T00:00:00.000Z'),
      },
    ],
    organizations: [
      {
        id: 'platform-org',
        organizationType: 'platform',
      },
    ],
  });

  const result = await harness.service.issueWithPassword(
    {
      mobile: '13800000000',
      password: 'password-value',
      consentAccepted: true,
      deviceId: 'admin-carrier-browser',
    },
    createRequestContext(),
  );

  assert.deepEqual(result, {
    adminSessionCarrier: 'issued-access-carrier',
    expiresInSeconds: 899,
    roleKey: 'platform_reviewer',
    platformOrganizationId: 'platform-org',
    nextPath: '/audit',
    issuer: 'server_auth',
  });
  assert.equal(result.refreshToken, undefined);
  assert.equal(harness.passwordLogins.length, 1);
  assert.equal(
    harness.verifiedContexts[0].authorization,
    'Bearer issued-access-carrier',
  );
});

test('Admin carrier issuer rejects valid Server Auth user without platform membership', async () => {
  const harness = createHarness({
    memberships: [
      {
        userId: 'user-1',
        organizationId: 'supplier-org',
        roleKey: 'supplier_admin',
        memberStatus: 'active',
        joinedAt: new Date('2026-05-01T00:00:00.000Z'),
      },
    ],
    organizations: [
      {
        id: 'supplier-org',
        organizationType: 'supplier',
      },
    ],
  });

  await assert.rejects(
    () =>
      harness.service.issueWithPassword(
        {
          mobile: '13800000000',
          password: 'password-value',
          consentAccepted: true,
        },
        createRequestContext(),
      ),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(error.getResponse().code, 'AUTH_PERMISSION_INSUFFICIENT');
      return true;
    },
  );
});

test('Admin carrier issuer ignores raw role hints and requires DB-backed platform membership', async () => {
  const harness = createHarness();

  await assert.rejects(
    () =>
      harness.service.issueWithPassword(
        {
          mobile: '13800000000',
          password: 'password-value',
          consentAccepted: true,
        },
        createRequestContext({
          actorRole: 'platform_super_admin',
          actorId: 'spoofed-header-actor',
          userId: 'spoofed-header-user',
        }),
      ),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(error.getResponse().code, 'AUTH_PERMISSION_INSUFFICIENT');
      return true;
    },
  );
});

function createHarness({ memberships = [], organizations = [] } = {}) {
  const passwordLogins = [];
  const verifiedContexts = [];
  const service = new AdminSessionCarrierIssuerService(
    {
      async login(payload, context) {
        passwordLogins.push({ payload, context });
        return {
          accessToken: 'issued-access-carrier',
          refreshToken: 'server-refresh-token-not-returned',
          expiresInSeconds: 899,
          shellBootstrapState: 'authenticated',
        };
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        verifiedContexts.push(context);
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'org-1',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    createMembershipRepository(memberships),
    createOrganizationRepository(organizations),
  );
  return { service, passwordLogins, verifiedContexts };
}

function createMembershipRepository(items) {
  return {
    async find(criteria) {
      const acceptedRoles = readInValues(criteria.where.roleKey);
      return items.filter(
        (item) =>
          item.userId === criteria.where.userId &&
          item.memberStatus === criteria.where.memberStatus &&
          acceptedRoles.includes(item.roleKey),
      );
    },
  };
}

function createOrganizationRepository(items) {
  return {
    async findBy(criteria) {
      const acceptedIds = readInValues(criteria.id);
      return items.filter(
        (item) =>
          acceptedIds.includes(item.id) &&
          item.organizationType === criteria.organizationType,
      );
    },
  };
}

function readInValues(value) {
  if (value && Array.isArray(value._value)) {
    return value._value;
  }
  if (value && Array.isArray(value.value)) {
    return value.value;
  }
  return [];
}

function createRequestContext(overrides = {}) {
  return {
    authorization: '',
    actorId: '',
    userId: '',
    organizationId: '',
    actorRole: '',
    requestId: 'request-admin-carrier-issuer',
    traceId: 'trace-admin-carrier-issuer',
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
    ...overrides,
  };
}
