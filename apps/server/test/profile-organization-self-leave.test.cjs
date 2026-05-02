const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ProfileOrganizationSelfLeaveService,
} = require('../dist/modules/profile/profile-organization-self-leave.service.js');

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

function matchesValue(value, expected) {
  if (expected && typeof expected === 'object' && '_type' in expected) {
    if (expected._type === 'in') {
      return expected._value.includes(value);
    }
    if (expected._type === 'not') {
      return value !== expected._value;
    }
  }
  return value === expected;
}

function matchesCriteria(item, criteria) {
  return Object.entries(criteria).every(([key, expected]) =>
    matchesValue(item[key], expected),
  );
}

function createRepository(state, table) {
  const rows = state[table];
  return {
    async findOneBy(criteria) {
      return rows.find((item) => matchesCriteria(item, criteria)) ?? null;
    },
    async count(options) {
      return rows.filter((item) => matchesCriteria(item, options.where)).length;
    },
    async find(options) {
      const filtered = rows.filter((item) => matchesCriteria(item, options.where));
      if (options.order?.joinedAt === 'DESC') {
        filtered.sort((left, right) => {
          const rightTime = right.joinedAt?.getTime?.() ?? 0;
          const leftTime = left.joinedAt?.getTime?.() ?? 0;
          return rightTime - leftTime || String(left.id).localeCompare(String(right.id));
        });
      }
      return filtered;
    },
    async findBy(criteria) {
      return rows.filter((item) => matchesCriteria(item, criteria));
    },
    async save(value) {
      const index = rows.findIndex((item) => item.id === value.id);
      if (index >= 0) {
        rows[index] = value;
      } else {
        rows.push(value);
      }
      return value;
    },
    async update(criteria, patch) {
      let affected = 0;
      for (const item of rows) {
        if (matchesCriteria(item, criteria)) {
          Object.assign(item, patch);
          affected += 1;
        }
      }
      return { affected };
    },
  };
}

function createHarness(state, currentOrganizationId = 'org-current') {
  const manager = {
    getRepository(entity) {
      if (entity.name === 'OrganizationMemberEntity') {
        return createRepository(state, 'members');
      }
      if (entity.name === 'OrganizationEntity') {
        return createRepository(state, 'organizations');
      }
      if (entity.name === 'SessionEntity') {
        return createRepository(state, 'sessions');
      }
      if (entity.name === 'IdentityAuditLogEntity') {
        return createRepository(state, 'audits');
      }
      throw new Error(`unexpected repository: ${entity.name}`);
    },
  };

  const service = new ProfileOrganizationSelfLeaveService(
    {
      async transaction(callback) {
        return callback(manager);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-current',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: currentOrganizationId,
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
  );

  return { service };
}

test('profile organization self leave removes membership and rebinds valid sessions', async () => {
  const state = {
    organizations: [
      { id: 'org-current', name: 'Current Org', organizationType: 'both' },
      { id: 'org-next', name: 'Next Org', organizationType: 'supplier' },
      { id: 'org-platform', name: 'Platform Org', organizationType: 'platform' },
    ],
    members: [
      {
        id: 'member-current',
        organizationId: 'org-current',
        userId: 'user-1',
        roleKey: 'buyer_member(scoped)',
        memberStatus: 'active',
        joinedAt: new Date('2026-04-01T00:00:00.000Z'),
        disabledAt: null,
      },
      {
        id: 'member-next',
        organizationId: 'org-next',
        userId: 'user-1',
        roleKey: 'supplier_member(scoped)',
        memberStatus: 'active',
        joinedAt: new Date('2026-04-03T00:00:00.000Z'),
        disabledAt: null,
      },
      {
        id: 'member-platform',
        organizationId: 'org-platform',
        userId: 'user-1',
        roleKey: 'platform_reviewer',
        memberStatus: 'active',
        joinedAt: new Date('2026-04-04T00:00:00.000Z'),
        disabledAt: null,
      },
    ],
    sessions: [
      { id: 'session-current', userId: 'user-1', organizationId: 'org-current', status: 'valid' },
      { id: 'session-other-device', userId: 'user-1', organizationId: 'org-current', status: 'valid' },
      { id: 'session-revoked', userId: 'user-1', organizationId: 'org-current', status: 'revoked' },
      { id: 'session-other-user', userId: 'user-2', organizationId: 'org-current', status: 'valid' },
    ],
    audits: [],
  };
  const { service } = createHarness(state);

  const result = await service.leaveCurrent(
    { reason: 'left company' },
    createContext('leave-success'),
  );

  assert.deepEqual(result, {
    leftOrganizationId: 'org-current',
    nextOrganizationId: 'org-next',
    shellBootstrapState: 'authenticated',
    traceId: 'trace-leave-success',
  });
  assert.equal(state.members[0].memberStatus, 'removed');
  assert.ok(state.members[0].disabledAt instanceof Date);
  assert.equal(state.sessions[0].organizationId, 'org-next');
  assert.equal(state.sessions[1].organizationId, 'org-next');
  assert.equal(state.sessions[2].organizationId, 'org-current');
  assert.equal(state.sessions[3].organizationId, 'org-current');
  assert.equal(state.audits.length, 1);
  assert.equal(state.audits[0].action, 'OrganizationMemberLeft');
  assert.equal(state.audits[0].afterState, 'removed');
});

test('profile organization self leave blocks the last active admin', async () => {
  const state = {
    organizations: [{ id: 'org-current', name: 'Current Org', organizationType: 'demand' }],
    members: [
      {
        id: 'member-current',
        organizationId: 'org-current',
        userId: 'user-1',
        roleKey: 'buyer_admin',
        memberStatus: 'active',
        joinedAt: new Date('2026-04-01T00:00:00.000Z'),
        disabledAt: null,
      },
      {
        id: 'member-other',
        organizationId: 'org-current',
        userId: 'user-2',
        roleKey: 'buyer_member(scoped)',
        memberStatus: 'active',
        joinedAt: new Date('2026-04-02T00:00:00.000Z'),
        disabledAt: null,
      },
    ],
    sessions: [
      { id: 'session-current', userId: 'user-1', organizationId: 'org-current', status: 'valid' },
    ],
    audits: [],
  };
  const { service } = createHarness(state);

  await assert.rejects(
    () => service.leaveCurrent({}, createContext('leave-last-admin')),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'ORG_LAST_ADMIN_LEAVE_BLOCKED');
      return true;
    },
  );
  assert.equal(state.members[0].memberStatus, 'active');
  assert.equal(state.sessions[0].organizationId, 'org-current');
  assert.equal(state.audits.length, 0);
});
