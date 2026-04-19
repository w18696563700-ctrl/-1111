const test = require('node:test');
const assert = require('node:assert/strict');

const {
  CurrentActorEligibilityService,
} = require('../dist/modules/organization/current-actor-eligibility.service.js');

function createService({
  user = { id: 'user-1', status: 'active' },
  organization = { id: 'org-1' },
  membership,
} = {}) {
  return new CurrentActorEligibilityService(
    {
      async findOneBy() {
        return user;
      },
    },
    {
      async findOneBy() {
        return organization;
      },
    },
    {
      async findOneBy() {
        return membership ?? null;
      },
    },
    {
      async findOne() {
        return null;
      },
    },
  );
}

test('organization admin gate emits a structured reason when the current role is not admin', async () => {
  const service = createService({
    membership: {
      organizationId: 'org-1',
      userId: 'user-1',
      memberStatus: 'active',
      roleKey: 'buyer_member(scoped)',
    },
  });

  await assert.rejects(
    () =>
      service.requireOrganizationAdmin(
        {
          sessionId: 'session-1',
          actorId: 'user-1',
          userId: 'user-1',
          organizationId: 'org-1',
          requestId: 'request-1',
          traceId: 'trace-1',
        },
        'org-1',
      ),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(error.getResponse().code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(
        error.getResponse().details.reason,
        'organization_admin_role_missing',
      );
      assert.deepEqual(error.getResponse().details.currentRoleKeys, [
        'buyer_member(scoped)',
      ]);
      return true;
    },
  );
});

test('organization admin gate emits a structured reason when requested organization mismatches current scope', async () => {
  const service = createService({
    organization: { id: 'org-1' },
    membership: {
      organizationId: 'org-1',
      userId: 'user-1',
      memberStatus: 'active',
      roleKey: 'buyer_admin',
    },
  });

  await assert.rejects(
    () =>
      service.requireOrganizationAdmin(
        {
          sessionId: 'session-1',
          actorId: 'user-1',
          userId: 'user-1',
          organizationId: 'org-1',
          requestId: 'request-1',
          traceId: 'trace-1',
        },
        'org-2',
      ),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(error.getResponse().code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(
        error.getResponse().details.reason,
        'organization_scope_mismatch',
      );
      assert.equal(error.getResponse().details.currentOrganizationId, 'org-1');
      assert.equal(
        error.getResponse().details.requestedOrganizationId,
        'org-2',
      );
      return true;
    },
  );
});
