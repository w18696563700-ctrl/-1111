const test = require('node:test');
const assert = require('node:assert/strict');

const context = { authorization: 'Bearer test', organizationId: '', actorRole: '', requestId: 'request-block-p0a', traceId: 'trace-block-p0a' };

function makeService(options = {}) {
  const relations = [...(options.relations ?? [])];
  const users = new Map(Object.entries({ 'user-target': { id: 'user-target', status: 'active' }, ...(options.users ?? {}) }));
  let saveCount = 0;

  const relationRepository = {
    create: (value) => ({ ...value }),
    findOneBy: async (criteria) => relations.find((relation) => Object.entries(criteria).every(([key, value]) => relation[key] === value)) ?? null,
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
  const userRepository = { findOneBy: async ({ id }) => users.get(id) ?? null };
  const verifier = {
    verifyCurrentSessionContext: async () => ({
      outcome: 'verified',
      currentSession: { sessionId: 'session-actor', actorId: 'user-actor', userId: 'user-actor', organizationId: null, requestId: context.requestId, traceId: context.traceId },
    }),
  };
  const eligibility = { requireAuthenticatedActor: async (session) => ({ id: session.userId, status: 'active' }) };

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

function readFindOperatorValue(value) {
  if (!value || typeof value !== 'object') {
    return null;
  }
  if (value._type === 'in') {
    return value._value;
  }
  return null;
}

function makeProfileGovernanceAppealsQueryService(options = {}) {
  const appeals = [...(options.appeals ?? [])];
  const penalties = [...(options.penalties ?? [])];
  const currentUserId = options.currentUserId ?? 'user-actor';
  const currentSessionVerificationService = {
    verifyCurrentSessionContext: async (receivedContext) => ({
      outcome: 'verified',
      currentSession: {
        sessionId: 'session-profile-appeal',
        actorId: currentUserId,
        userId: currentUserId,
        organizationId: null,
        requestId: receivedContext.requestId,
        traceId: receivedContext.traceId,
      },
    }),
  };
  const eligibilityService = {
    requireAuthenticatedActor: async (session) => ({ id: session.userId, status: 'active' }),
  };
  const privateOperatingSystemService = { getProfileIndexProjection: () => { throw new Error('Profile index projection is not used in governance appeals tests.'); } };
  const avatarUrlService = { buildAccessUrlFromObjectUrl: async (value) => value };
  const appealRepository = {
    async findAndCount(options = {}) {
      const where = options.where ?? {};
      const filtered = appeals.filter((appeal) =>
        Object.entries(where).every(([key, expected]) => appeal[key] === expected)
      );
      const sorted = [...filtered].sort((left, right) => {
        const submittedDelta = right.submittedAt.getTime() - left.submittedAt.getTime();
        if (submittedDelta !== 0) {
          return submittedDelta;
        }
        return right.createdAt.getTime() - left.createdAt.getTime();
      });
      const skip = options.skip ?? 0;
      const take = options.take ?? sorted.length;
      return [sorted.slice(skip, skip + take), filtered.length];
    },
    async findOneBy(where) {
      return appeals.find((appeal) => Object.entries(where).every(([key, expected]) => appeal[key] === expected)) ?? null;
    },
  };
  const penaltyRepository = {
    async findBy(where) {
      const expectedIds = readFindOperatorValue(where.id) ?? [];
      return penalties.filter((penalty) => expectedIds.includes(penalty.id));
    },
    async findOneBy(where) {
      return penalties.find((penalty) => Object.entries(where).every(([key, expected]) => penalty[key] === expected)) ?? null;
    },
  };

  const { ProfileQueryService } = require('../dist/modules/profile/profile-query.service.js');
  const { ProfilePresenter } = require('../dist/modules/profile/profile.presenter.js');
  return {
    service: new ProfileQueryService(
      currentSessionVerificationService,
      eligibilityService,
      privateOperatingSystemService,
      avatarUrlService,
      new ProfilePresenter(),
      appealRepository,
      penaltyRepository
    ),
  };
}

test('block rejects missing, malformed, and self target with controlled invalid error', async () => {
  const { service } = makeService();

  await assert.rejects(() => service.block({}, context), hasErrorCode('GOVERNANCE_BLOCK_INVALID'));
  await assert.rejects(() => service.getStatus(' '.repeat(2), context), hasErrorCode('GOVERNANCE_BLOCK_INVALID'));
  await assert.rejects(() => service.block({ targetUserId: 'user-actor' }, context), hasErrorCode('GOVERNANCE_BLOCK_INVALID'));
});

test('block rejects inactive or absent target user with controlled unavailable error', async () => {
  const { service } = makeService({
    users: {
      'user-target': { id: 'user-target', status: 'disabled' },
    },
  });

  await assert.rejects(() => service.block({ targetUserId: 'user-target' }, context), hasErrorCode('GOVERNANCE_BLOCK_TARGET_UNAVAILABLE'));
  await assert.rejects(() => service.getStatus('missing-user', context), hasErrorCode('GOVERNANCE_BLOCK_TARGET_UNAVAILABLE'));
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
  assert.equal(fixture.relations.filter((relation) => relation.relationStatus === 'active').length, 1);
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

  assert.deepEqual(Object.keys(result).sort(), ['blockedByMe', 'canInteract', 'interactionBlockedReason', 'targetUserId']);
  assert.deepEqual(result, {
    targetUserId: 'user-target',
    blockedByMe: true,
    canInteract: false,
    interactionBlockedReason: 'blocked_relation',
  });
});

test('Block P0-A migration registry includes active-pair uniqueness only', () => {
  const { blockP0AMigrations, serverMigrations } = require('../dist/core/migrations/migrations.js');
  const migration = blockP0AMigrations.find((item) => item.key === '20260407_block_p0a_user_block_relation_truth');

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  assert.match(migration.statements.join('\n'), /CREATE TABLE IF NOT EXISTS user_block_relations/);
  assert.match(migration.statements.join('\n'), /CREATE UNIQUE INDEX IF NOT EXISTS idx_user_block_relations_active_pair/);
  assert.match(migration.statements.join('\n'), /WHERE relation_status = 'active'/);
});

test('S1-R05 current actor governance appeals list and detail expose bounded profile projections', async () => {
  const submittedAt = new Date('2026-04-09T01:00:00.000Z');
  const decidedAt = new Date('2026-04-10T01:00:00.000Z');
  const effectiveFrom = new Date('2026-04-08T01:00:00.000Z');
  const effectiveUntil = new Date('2026-04-20T01:00:00.000Z');
  const { service } = makeProfileGovernanceAppealsQueryService({
    appeals: [
      {
        id: 'appeal-own',
        penaltyId: 'penalty-own',
        status: 'revoked',
        reason: 'Requesting revoke.',
        decision: 'revoke',
        decisionNote: 'Accepted.',
        evidenceFileAssetIds: ['asset-1'],
        submittedBy: 'user-actor',
        submittedAt,
        decidedBy: 'reviewer-user',
        decidedAt,
        metadata: {},
        createdAt: submittedAt,
        updatedAt: decidedAt,
      },
      {
        id: 'appeal-other',
        penaltyId: 'penalty-other',
        status: 'submitted',
        reason: 'Other actor appeal.',
        decision: null,
        decisionNote: null,
        evidenceFileAssetIds: [],
        submittedBy: 'other-user',
        submittedAt: new Date('2026-04-11T01:00:00.000Z'),
        decidedBy: null,
        decidedAt: null,
        metadata: {},
        createdAt: new Date('2026-04-11T01:00:00.000Z'),
        updatedAt: new Date('2026-04-11T01:00:00.000Z'),
      },
    ],
    penalties: [
      {
        id: 'penalty-own',
        penaltyType: 'blacklist',
        status: 'lifted',
        reasonSummary: 'Penalty summary.',
        effectiveFrom,
        effectiveUntil,
      },
      {
        id: 'penalty-other',
        penaltyType: 'watchlist',
        status: 'active',
        reasonSummary: 'Other penalty.',
        effectiveFrom,
        effectiveUntil: null,
      },
    ],
  });

  const list = await service.getGovernanceAppeals(
    { page: '1', pageSize: '10', status: 'revoked' },
    context
  );
  const detail = await service.getGovernanceAppealDetail('appeal-own', context);

  assert.deepEqual(list, {
    items: [
      {
        appealCaseId: 'appeal-own',
        penaltyId: 'penalty-own',
        penaltyType: 'blacklist',
        penaltyStatus: 'lifted',
        status: 'revoked',
        reasonSummary: 'Penalty summary.',
        submittedAt: submittedAt.toISOString(),
        decidedAt: decidedAt.toISOString(),
        effectiveFrom: effectiveFrom.toISOString(),
        effectiveUntil: effectiveUntil.toISOString(),
      },
    ],
    pagination: {
      page: 1,
      pageSize: 10,
      total: 1,
      hasMore: false,
    },
  });
  assert.deepEqual(detail, {
    appealCaseId: 'appeal-own',
    penaltyId: 'penalty-own',
    penaltyType: 'blacklist',
    penaltyStatus: 'lifted',
    status: 'revoked',
    reason: 'Requesting revoke.',
    reasonSummary: 'Penalty summary.',
    submittedAt: submittedAt.toISOString(),
    evidenceFileAssetIds: ['asset-1'],
    decision: 'revoke',
    decisionNote: 'Accepted.',
    decidedAt: decidedAt.toISOString(),
    effectiveFrom: effectiveFrom.toISOString(),
    effectiveUntil: effectiveUntil.toISOString(),
    penalty: {
      penaltyId: 'penalty-own',
      penaltyType: 'blacklist',
      status: 'lifted',
      reasonSummary: 'Penalty summary.',
      effectiveFrom: effectiveFrom.toISOString(),
      effectiveUntil: effectiveUntil.toISOString(),
    },
  });
});

test('S1-R05 current actor governance appeal detail fail-closes on other actor records', async () => {
  const { service } = makeProfileGovernanceAppealsQueryService({
    appeals: [
      {
        id: 'appeal-other',
        penaltyId: 'penalty-other',
        status: 'submitted',
        reason: 'Other actor appeal.',
        decision: null,
        decisionNote: null,
        evidenceFileAssetIds: [],
        submittedBy: 'other-user',
        submittedAt: new Date('2026-04-11T01:00:00.000Z'),
        decidedBy: null,
        decidedAt: null,
        metadata: {},
        createdAt: new Date('2026-04-11T01:00:00.000Z'),
        updatedAt: new Date('2026-04-11T01:00:00.000Z'),
      },
    ],
    penalties: [
      {
        id: 'penalty-other',
        penaltyType: 'watchlist',
        status: 'active',
        reasonSummary: 'Other penalty.',
        effectiveFrom: new Date('2026-04-10T01:00:00.000Z'),
        effectiveUntil: null,
      },
    ],
  });

  await assert.rejects(() => service.getGovernanceAppealDetail('appeal-other', context), hasErrorCode('GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE'));
});
