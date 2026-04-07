const test = require('node:test');
const assert = require('node:assert/strict');

const context = {
  authorization: 'Bearer test',
  organizationId: '',
  actorRole: '',
  requestId: 'request-block-p0a',
  traceId: 'trace-block-p0a',
};

function makeService(options = {}) {
  const relations = [...(options.relations ?? [])];
  const users = new Map(
    Object.entries({
      'user-target': { id: 'user-target', status: 'active' },
      ...(options.users ?? {}),
    })
  );
  let saveCount = 0;

  const relationRepository = {
    create: (value) => ({ ...value }),
    findOneBy: async (criteria) =>
      relations.find((relation) =>
        Object.entries(criteria).every(([key, value]) => relation[key] === value)
      ) ?? null,
    save: async (relation) => {
      saveCount += 1;
      const index = relations.findIndex((item) => item.id === relation.id);
      if (index >= 0) {
        relations[index] = relation;
      } else {
        relations.push(relation);
      }
      return relation;
    },
  };
  const userRepository = {
    findOneBy: async ({ id }) => users.get(id) ?? null,
  };
  const verifier = {
    verifyCurrentSessionContext: async () => ({
      outcome: 'verified',
      currentSession: {
        sessionId: 'session-actor',
        actorId: 'user-actor',
        userId: 'user-actor',
        organizationId: null,
        requestId: context.requestId,
        traceId: context.traceId,
      },
    }),
  };
  const eligibility = {
    requireAuthenticatedActor: async (session) => ({ id: session.userId, status: 'active' }),
  };

  const { ProfileBlockService } = require('../dist/modules/profile/profile-block.service.js');
  const { ProfileBlockPresenter } = require('../dist/modules/profile/profile-block.presenter.js');
  return {
    relations,
    get saveCount() {
      return saveCount;
    },
    service: new ProfileBlockService(
      relationRepository,
      userRepository,
      verifier,
      eligibility,
      new ProfileBlockPresenter()
    ),
  };
}

function hasErrorCode(expectedCode) {
  return (error) => error?.getResponse?.().code === expectedCode;
}

test('block rejects missing, malformed, and self target with controlled invalid error', async () => {
  const { service } = makeService();

  await assert.rejects(
    () => service.block({}, context),
    hasErrorCode('GOVERNANCE_BLOCK_INVALID')
  );
  await assert.rejects(
    () => service.getStatus(' '.repeat(2), context),
    hasErrorCode('GOVERNANCE_BLOCK_INVALID')
  );
  await assert.rejects(
    () => service.block({ targetUserId: 'user-actor' }, context),
    hasErrorCode('GOVERNANCE_BLOCK_INVALID')
  );
});

test('block rejects inactive or absent target user with controlled unavailable error', async () => {
  const { service } = makeService({
    users: {
      'user-target': { id: 'user-target', status: 'disabled' },
    },
  });

  await assert.rejects(
    () => service.block({ targetUserId: 'user-target' }, context),
    hasErrorCode('GOVERNANCE_BLOCK_TARGET_UNAVAILABLE')
  );
  await assert.rejects(
    () => service.getStatus('missing-user', context),
    hasErrorCode('GOVERNANCE_BLOCK_TARGET_UNAVAILABLE')
  );
});

test('duplicate active block is idempotent and does not create another relation', async () => {
  const createdAt = new Date('2026-04-07T00:00:00.000Z');
  const fixture = makeService({
    relations: [
      {
        id: 'relation-existing',
        blockerUserId: 'user-actor',
        blockedUserId: 'user-target',
        relationStatus: 'active',
        endedAt: null,
        createdAt,
        updatedAt: createdAt,
      },
    ],
  });

  const result = await fixture.service.block({ targetUserId: 'user-target' }, context);

  assert.deepEqual(result, {
    targetUserId: 'user-target',
    blockedByMe: true,
    canInteract: false,
    effectiveAt: createdAt.toISOString(),
  });
  assert.equal(fixture.saveCount, 0);
  assert.equal(
    fixture.relations.filter((relation) => relation.relationStatus === 'active').length,
    1
  );
});

test('unblock deactivates only current direction and preserves reverse block relation', async () => {
  const createdAt = new Date('2026-04-07T01:00:00.000Z');
  const fixture = makeService({
    relations: [
      {
        id: 'relation-forward',
        blockerUserId: 'user-actor',
        blockedUserId: 'user-target',
        relationStatus: 'active',
        endedAt: null,
        createdAt,
        updatedAt: createdAt,
      },
      {
        id: 'relation-reverse',
        blockerUserId: 'user-target',
        blockedUserId: 'user-actor',
        relationStatus: 'active',
        endedAt: null,
        createdAt,
        updatedAt: createdAt,
      },
    ],
  });

  const result = await fixture.service.unblock({ targetUserId: 'user-target' }, context);

  assert.equal(result.targetUserId, 'user-target');
  assert.equal(result.blockedByMe, false);
  assert.equal(result.canInteract, false);
  assert.equal(fixture.saveCount, 1);
  assert.equal(fixture.relations.find((relation) => relation.id === 'relation-forward').relationStatus, 'inactive');
  assert.equal(fixture.relations.find((relation) => relation.id === 'relation-reverse').relationStatus, 'active');
});

test('absent unblock is idempotent success', async () => {
  const fixture = makeService();

  const result = await fixture.service.unblock({ targetUserId: 'user-target' }, context);

  assert.equal(result.targetUserId, 'user-target');
  assert.equal(result.blockedByMe, false);
  assert.equal(result.canInteract, true);
  assert.equal(fixture.saveCount, 0);
});

test('status query returns only single-target minimum projection', async () => {
  const createdAt = new Date('2026-04-07T02:00:00.000Z');
  const { service } = makeService({
    relations: [
      {
        id: 'relation-status',
        blockerUserId: 'user-actor',
        blockedUserId: 'user-target',
        relationStatus: 'active',
        endedAt: null,
        createdAt,
        updatedAt: createdAt,
      },
    ],
  });

  const result = await service.getStatus('user-target', context);

  assert.deepEqual(Object.keys(result).sort(), [
    'blockedByMe',
    'canInteract',
    'interactionBlockedReason',
    'targetUserId',
  ]);
  assert.deepEqual(result, {
    targetUserId: 'user-target',
    blockedByMe: true,
    canInteract: false,
    interactionBlockedReason: 'blocked_relation',
  });
});

test('Block P0-A migration registry includes active-pair uniqueness only', () => {
  const { blockP0AMigrations, serverMigrations } = require('../dist/core/migrations/migrations.js');
  const migration = blockP0AMigrations.find(
    (item) => item.key === '20260407_block_p0a_user_block_relation_truth'
  );

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  assert.match(migration.statements.join('\n'), /CREATE TABLE IF NOT EXISTS user_block_relations/);
  assert.match(migration.statements.join('\n'), /CREATE UNIQUE INDEX IF NOT EXISTS idx_user_block_relations_active_pair/);
  assert.match(migration.statements.join('\n'), /WHERE relation_status = 'active'/);
});
