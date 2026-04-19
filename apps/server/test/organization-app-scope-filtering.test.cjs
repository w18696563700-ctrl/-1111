const test = require('node:test');
const assert = require('node:assert/strict');

const {
  CurrentActorEligibilityService,
} = require('../dist/modules/organization/current-actor-eligibility.service.js');
const {
  OrganizationWriteService,
} = require('../dist/modules/organization/organization-write.service.js');
const {
  OrganizationWritePresenter,
} = require('../dist/modules/organization/organization-write.presenter.js');

function createContext(requestId) {
  return {
    authorization: 'Bearer carrier',
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

test('profile organization list keeps only active app-facing organizations', async () => {
  const service = new CurrentActorEligibilityService(
    {},
    {
      async findBy(criteria) {
        assert.deepEqual(criteria.id._value, ['org-app', 'org-platform', 'org-internal']);
        return [
          { id: 'org-app', name: '重庆坤特展览展示有限公司', organizationType: 'both' },
          { id: 'org-platform', name: 'Smoke Admin Review P0 Platform Org', organizationType: 'platform' },
          { id: 'org-internal', name: 'Internal Demand Org', organizationType: 'demand' },
        ];
      },
    },
    {
      async find(criteria) {
        assert.equal(criteria.where.userId, 'user-1');
        assert.equal(criteria.where.memberStatus, 'active');
        return [
          {
            organizationId: 'org-app',
            roleKey: 'buyer_admin',
            memberStatus: 'active',
            joinedAt: new Date('2026-04-11T00:00:00.000Z'),
          },
          {
            organizationId: 'org-platform',
            roleKey: 'platform_reviewer',
            memberStatus: 'active',
            joinedAt: new Date('2026-04-10T00:00:00.000Z'),
          },
          {
            organizationId: 'org-internal',
            roleKey: 'platform_super_admin',
            memberStatus: 'active',
            joinedAt: new Date('2026-04-09T00:00:00.000Z'),
          },
        ];
      },
    },
    {
      async findBy(criteria) {
        assert.deepEqual(criteria.organizationId._value, ['org-app', 'org-platform', 'org-internal']);
        return [];
      },
    },
  );

  const organizations = await service.listAccessibleOrganizations('user-1');

  assert.equal(organizations.length, 1);
  assert.equal(organizations[0].organization.id, 'org-app');
  assert.deepEqual(organizations[0].roleKeys, ['buyer_admin']);
  assert.equal(organizations[0].membershipStatus, 'active');
  assert.equal(organizations[0].certificationStatus, 'not_submitted');
});

test('organization switch rejects platform reviewer scopes for the app-facing handoff', async () => {
  const service = new OrganizationWriteService(
    {
      async findOneBy(criteria) {
        assert.equal(criteria.id, 'org-platform');
        return {
          id: 'org-platform',
          name: 'Smoke Admin Review P0 Platform Org',
          organizationType: 'platform',
        };
      },
    },
    {
      async findOneBy(criteria) {
        assert.equal(criteria.organizationId, 'org-platform');
        assert.equal(criteria.userId, 'user-1');
        assert.equal(criteria.memberStatus, 'active');
        return {
          id: 'member-platform',
          organizationId: 'org-platform',
          userId: 'user-1',
          roleKey: 'platform_reviewer',
          memberStatus: 'active',
        };
      },
    },
    {
      async findOne() {
        return null;
      },
    },
    {},
    {},
    {
      async transaction() {
        throw new Error('transaction should not run for rejected switch');
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'org-app',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor(currentSession) {
        assert.equal(currentSession.userId, 'user-1');
        return { id: 'user-1', status: 'active' };
      },
    },
    new OrganizationWritePresenter(),
  );

  await assert.rejects(
    () =>
      service.switch(
        {
          organizationId: 'org-platform',
        },
        createContext('organization-switch-platform'),
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'ORG_SWITCH_INVALID');
      assert.match(
        error.getResponse().message,
        /cannot switch to the requested organization/i,
      );
      return true;
    },
  );
});
