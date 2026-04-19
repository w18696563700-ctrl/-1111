const test = require('node:test');
const assert = require('node:assert/strict');

const context = {
  authorization: 'Bearer test',
  actorId: 'reviewer-user',
  userId: 'reviewer-user',
  organizationId: 'platform-org',
  actorRole: 'platform_reviewer',
  requestId: 'request-cs027',
  traceId: 'trace-cs027',
};

const organizationId = '11111111-1111-4111-8111-111111111111';
const memberId = '22222222-2222-4222-8222-222222222222';

function makeService(options = {}) {
  const penalties = [...(options.penalties ?? [])];
  const auditRecords = [];
  const organizations = new Map([[organizationId, { id: organizationId }]]);
  const members = new Map([[memberId, { id: memberId }]]);

  const penaltyRepository = {
    findOneBy: async ({ id }) => penalties.find((item) => item.id === id) ?? null,
    createQueryBuilder: () => makeQueryBuilder(penalties),
  };
  const txPenaltyRepository = {
    create: (value) => ({ ...value }),
    save: async (penalty) => {
      penalties.push(penalty);
      return penalty;
    },
  };
  const organizationRepository = {
    findOneBy: async ({ id }) => organizations.get(id) ?? null,
  };
  const organizationMemberRepository = {
    findOneBy: async ({ id }) => members.get(id) ?? null,
  };
  const verifier = {
    verifyCurrentSessionContext: async () => ({
      outcome: 'verified',
      currentSession: {
        sessionId: 'session-1',
        actorId: 'reviewer-user',
        userId: 'reviewer-user',
        organizationId: 'platform-org',
        requestId: context.requestId,
        traceId: context.traceId,
      },
    }),
  };
  const eligibility = {
    requireReviewer: async () => ({ actorRole: 'platform_reviewer' }),
  };
  const auditService = {
    record: async (input) => {
      auditRecords.push(input);
      return { id: 'audit-1', ...input };
    },
  };
  const dataSource = {
    transaction: async (callback) => callback({ getRepository: () => txPenaltyRepository }),
  };

  const { GovernancePenaltyService } = require('../dist/modules/governance/governance-penalty.service.js');
  const { GovernancePenaltyPresenter } = require('../dist/modules/governance/governance-penalty.presenter.js');
  return {
    penalties,
    auditRecords,
    service: new GovernancePenaltyService(
      penaltyRepository,
      organizationRepository,
      organizationMemberRepository,
      verifier,
      eligibility,
      auditService,
      dataSource,
      new GovernancePenaltyPresenter()
    ),
  };
}

function makeQueryBuilder(items) {
  const state = { offset: 0, limit: 20 };
  const qb = {
    andWhere: () => qb,
    orderBy: () => qb,
    offset: (value) => {
      state.offset = value;
      return qb;
    },
    limit: (value) => {
      state.limit = value;
      return qb;
    },
    getCount: async () => items.length,
    getMany: async () =>
      [...items]
        .sort((left, right) => right.createdAt.getTime() - left.createdAt.getTime())
        .slice(state.offset, state.offset + state.limit),
  };
  return qb;
}

function hasErrorCode(expectedCode) {
  return (error) => error?.getResponse?.().code === expectedCode;
}

test('CS-027 list and detail expose minimum admin governance penalty projections', async () => {
  const createdAt = new Date('2026-04-08T01:00:00.000Z');
  const { service } = makeService({
    penalties: [
      {
        id: 'penalty-1',
        subjectType: 'organization',
        subjectId: organizationId,
        penaltyType: 'blacklist',
        status: 'active',
        reasonCode: 'manual_review_violation',
        reasonSummary: 'Manual governance violation.',
        evidenceFileAssetIds: ['asset-1'],
        effectiveFrom: createdAt,
        effectiveUntil: null,
        createdBy: 'reviewer-user',
        createdAt,
        updatedAt: createdAt,
      },
    ],
  });

  const list = await service.list({ page: '1', pageSize: '10' }, context);
  const detail = await service.detail('penalty-1', context);

  assert.equal(list.pagination.total, 1);
  assert.deepEqual(list.items[0], {
    penaltyId: 'penalty-1',
    subjectType: 'organization',
    subjectId: organizationId,
    penaltyType: 'blacklist',
    status: 'active',
    effectiveFrom: createdAt.toISOString(),
    effectiveUntil: null,
  });
  assert.equal(detail.reasonCode, 'manual_review_violation');
  assert.deepEqual(detail.evidenceFileAssetIds, ['asset-1']);
  assert.equal(detail.createdBy, 'reviewer-user');
});

test('CS-027 apply records operator, target, effective state, and safety audit evidence', async () => {
  const { service, penalties, auditRecords } = makeService();

  const result = await service.apply(
    {
      subjectType: 'organization_member',
      subjectId: memberId,
      penaltyType: 'restrict_publish',
      reasonCode: 'manual_review_violation',
      reasonSummary: 'Manual governance violation.',
      evidenceFileAssetIds: ['asset-1'],
    },
    context
  );

  assert.equal(result.ok, true);
  assert.equal(result.traceId, context.traceId);
  assert.equal(result.status, 'active');
  assert.equal(penalties.length, 1);
  assert.equal(penalties[0].subjectType, 'organization_member');
  assert.equal(penalties[0].subjectId, memberId);
  assert.equal(penalties[0].penaltyType, 'restrict_publish');
  assert.equal(penalties[0].createdBy, 'reviewer-user');
  assert.equal(penalties[0].operatorUserId, 'reviewer-user');
  assert.equal(penalties[0].operatorRole, 'platform_reviewer');
  assert.equal(auditRecords.length, 1);
  assert.equal(auditRecords[0].subjectType, 'governance_penalty');
  assert.equal(auditRecords[0].action, 'governance_penalty_apply');
  assert.equal(auditRecords[0].engineType, 'manual');
  assert.equal(auditRecords[0].metadata.penaltyType, 'restrict_publish');
});

test('CS-027 apply rejects out-of-bound penalty and appeal/precheck-style payloads', async () => {
  const { service } = makeService();

  await assert.rejects(
    () =>
      service.apply(
        {
          subjectType: 'organization',
          subjectId: organizationId,
          penaltyType: 'permanent_ban',
          reasonCode: 'manual_review_violation',
        },
        context
      ),
    hasErrorCode('GOVERNANCE_PENALTY_APPLY_INVALID')
  );
  await assert.rejects(
    () => service.apply({ appealCaseId: 'appeal-1', reasonCode: 'bad' }, context),
    hasErrorCode('GOVERNANCE_PENALTY_APPLY_INVALID')
  );
});

test('CS-027 migration registry includes governance_penalties truth only', () => {
  const { governancePenaltyP1AMigrations, serverMigrations } = require('../dist/core/migrations/migrations.js');
  const migration = governancePenaltyP1AMigrations.find(
    (item) => item.key === '20260408_governance_penalty_p1a_truth'
  );

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  const joined = migration.statements.join('\n');
  assert.match(joined, /CREATE TABLE IF NOT EXISTS governance_penalties/);
  assert.match(joined, /operator_actor_id varchar\(64\) NOT NULL/);
  assert.doesNotMatch(joined, /appeal_cases/);
  assert.doesNotMatch(joined, /permanent_bans/);
});
