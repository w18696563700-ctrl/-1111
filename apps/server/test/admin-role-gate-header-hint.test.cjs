const test = require('node:test');
const assert = require('node:assert/strict');

const {
  EnterpriseHubAdminService,
} = require('../dist/modules/enterprise_hub/enterprise-hub-admin.service.js');
const {
  CurrentActorEligibilityService,
} = require('../dist/modules/organization/current-actor-eligibility.service.js');

test('raw x-actor-role cannot bypass DB-backed platform reviewer membership', async () => {
  const recommendationSlotRepository = createFailIfTouchedRepository('recommendationSlotRepository');
  const service = createEnterpriseHubAdminService({
    eligibilityService: createDbBackedEligibilityService({
      memberships: [],
    }),
    recommendationSlotRepository,
  });

  await assert.rejects(
    () =>
      service.listRecommendationSlots(
        {},
        createRequestContext({
          actorId: 'spoofed-header-actor',
          userId: 'spoofed-header-user',
          actorRole: 'platform_super_admin',
        }),
      ),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(error.getResponse().code, 'AUTH_PERMISSION_INSUFFICIENT');
      return true;
    },
  );
});

test('DB-backed platform membership passes reviewer gate regardless of raw role header hint', async () => {
  const recommendationSlotRepository = {
    async find(criteria) {
      assert.deepEqual(criteria.where, {});
      return [];
    },
  };
  const service = createEnterpriseHubAdminService({
    eligibilityService: createDbBackedEligibilityService({
      memberships: [
        {
          organizationId: 'platform-org',
          userId: 'session-user',
          memberStatus: 'active',
          roleKey: 'platform_reviewer',
          joinedAt: new Date('2026-05-01T00:00:00.000Z'),
        },
      ],
      platformOrganizations: [
        {
          id: 'platform-org',
          organizationType: 'platform',
        },
      ],
    }),
    recommendationSlotRepository,
  });

  const result = await service.listRecommendationSlots(
    {},
    createRequestContext({
      actorId: 'spoofed-header-actor',
      userId: 'spoofed-header-user',
      actorRole: 'buyer_admin',
    }),
  );

  assert.deepEqual(result, { items: [] });
});

function createEnterpriseHubAdminService({
  eligibilityService,
  recommendationSlotRepository = createFailIfTouchedRepository('recommendationSlotRepository'),
} = {}) {
  return new EnterpriseHubAdminService(
    createFailIfTouchedRepository('applicationRepository'),
    createFailIfTouchedRepository('listingRepository'),
    recommendationSlotRepository,
    {
      toAdminRecommendationSlotItem(value) {
        return value;
      },
    },
    createVerificationService(),
    eligibilityService ?? createDbBackedEligibilityService(),
  );
}

function createVerificationService() {
  return {
    async verifyCurrentSessionContext(context) {
      assert.equal(context.authorization, 'Bearer valid-current-session');
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'session-user',
          userId: 'session-user',
          organizationId: null,
          requestId: context.requestId,
          traceId: context.traceId,
        },
      };
    },
  };
}

function createDbBackedEligibilityService({
  memberships = [],
  platformOrganizations = [],
} = {}) {
  return new CurrentActorEligibilityService(
    {
      async findOneBy(criteria) {
        assert.equal(criteria.id, 'session-user');
        return { id: 'session-user', status: 'active' };
      },
    },
    {
      async findBy(criteria) {
        const requestedIds = criteria.id?._value ?? [];
        return platformOrganizations.filter((organization) =>
          requestedIds.includes(organization.id),
        );
      },
    },
    {
      async find(criteria) {
        assert.equal(criteria.where.userId, 'session-user');
        assert.equal(criteria.where.memberStatus, 'active');
        const acceptedRoles = criteria.where.roleKey?._value ?? [];
        assert.deepEqual(
          new Set(acceptedRoles),
          new Set(['platform_reviewer', 'platform_super_admin']),
        );
        return memberships;
      },
    },
    {},
    {},
  );
}

function createFailIfTouchedRepository(name) {
  return new Proxy(
    {},
    {
      get(_target, propertyKey) {
        return async () => {
          throw new Error(`${name}.${String(propertyKey)} must not run before reviewer gate passes.`);
        };
      },
    },
  );
}

function createRequestContext(overrides = {}) {
  return {
    authorization: 'Bearer valid-current-session',
    actorId: '',
    userId: '',
    organizationId: '',
    actorRole: '',
    requestId: 'request-1',
    traceId: 'trace-1',
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
    ...overrides,
  };
}
