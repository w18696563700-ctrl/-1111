const test = require('node:test');
const assert = require('node:assert/strict');

const context = {
  authorization: 'Bearer test',
  actorId: 'reviewer-user',
  userId: 'reviewer-user',
  organizationId: 'platform-org',
  actorRole: 'platform_reviewer',
  requestId: 'request-cs028',
  traceId: 'trace-cs028'
};

function makeService(options = {}) {
  const appeals = [...(options.appeals ?? [])];
  const penalties = [...(options.penalties ?? [])];
  const auditRecords = [];
  const penaltyById = new Map(penalties.map((item) => [item.id, item]));
  const appealById = new Map(appeals.map((item) => [item.id, item]));

  const appealRepository = {
    findOneBy: async ({ id }) => appealById.get(id) ?? null,
    createQueryBuilder: () => makeQueryBuilder(appeals)
  };
  const penaltyRepository = {
    findOneBy: async ({ id }) => penaltyById.get(id) ?? null
  };
  const txAppealRepository = {
    findOneBy: async ({ id }) => appealById.get(id) ?? null,
    save: async (appeal) => {
      appealById.set(appeal.id, appeal);
      return appeal;
    }
  };
  const txPenaltyRepository = {
    findOneBy: async ({ id }) => penaltyById.get(id) ?? null,
    save: async (penalty) => {
      penaltyById.set(penalty.id, penalty);
      return penalty;
    }
  };
  const verifier = {
    verifyCurrentSessionContext: async () => ({
      outcome: 'verified',
      currentSession: {
        sessionId: 'session-1',
        actorId: context.actorId,
        userId: context.userId,
        organizationId: context.organizationId,
        requestId: context.requestId,
        traceId: context.traceId
      }
    })
  };
  const eligibility = {
    requireReviewer: async () => ({ actorRole: 'platform_reviewer' })
  };
  const auditService = {
    record: async (input) => {
      auditRecords.push(input);
      return { id: 'audit-1', ...input };
    }
  };

  const {
    GovernanceAppealCaseEntity
  } = require('../dist/modules/governance/entities/governance-appeal-case.entity.js');
  const {
    GovernancePenaltyEntity
  } = require('../dist/modules/governance/entities/governance-penalty.entity.js');
  const dataSource = {
    transaction: async (callback) =>
      callback({
        getRepository: (entity) => {
          if (entity === GovernanceAppealCaseEntity) {
            return txAppealRepository;
          }
          if (entity === GovernancePenaltyEntity) {
            return txPenaltyRepository;
          }
          throw new Error(`Unexpected transaction repository: ${entity?.name ?? 'unknown'}`);
        }
      })
  };

  const { GovernanceAppealService } = require('../dist/modules/governance/governance-appeal.service.js');
  const { GovernanceAppealPresenter } = require('../dist/modules/governance/governance-appeal.presenter.js');

  return {
    service: new GovernanceAppealService(
      appealRepository,
      penaltyRepository,
      verifier,
      eligibility,
      auditService,
      dataSource,
      new GovernanceAppealPresenter()
    ),
    appeals,
    penalties,
    auditRecords
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
        .sort((left, right) => right.submittedAt.getTime() - left.submittedAt.getTime())
        .slice(state.offset, state.offset + state.limit)
  };
  return qb;
}

function hasErrorCode(expectedCode) {
  return (error) => error?.getResponse?.().code === expectedCode;
}

test('CS-028 list and detail expose minimum governance appeal projections', async () => {
  const submittedAt = new Date('2026-04-08T03:00:00.000Z');
  const { service } = makeService({
    appeals: [
      {
        id: 'appeal-1',
        penaltyId: 'penalty-1',
        status: 'submitted',
        reason: 'Requesting reconsideration.',
        decision: null,
        decisionNote: null,
        evidenceFileAssetIds: ['asset-1'],
        submittedBy: 'reporter-user',
        submittedAt,
        decidedBy: null,
        decidedAt: null,
        metadata: {},
        createdAt: submittedAt,
        updatedAt: submittedAt
      }
    ],
    penalties: [{ id: 'penalty-1', status: 'active', effectiveUntil: null }]
  });

  const list = await service.list({ page: '1', pageSize: '10' }, context);
  const detail = await service.detail('appeal-1', context);

  assert.equal(list.pagination.total, 1);
  assert.deepEqual(list.items[0], {
    appealCaseId: 'appeal-1',
    penaltyId: 'penalty-1',
    status: 'submitted',
    submittedAt: submittedAt.toISOString()
  });
  assert.equal(detail.reason, 'Requesting reconsideration.');
  assert.deepEqual(detail.evidenceFileAssetIds, ['asset-1']);
  assert.equal(detail.submittedAt, submittedAt.toISOString());
});

test('CS-028 decide revoke updates penalty status and writes appeal decision audit', async () => {
  const submittedAt = new Date('2026-04-08T02:00:00.000Z');
  const appeal = {
    id: 'appeal-2',
    penaltyId: 'penalty-2',
    status: 'submitted',
    reason: 'Appeal reason.',
    decision: null,
    decisionNote: null,
    evidenceFileAssetIds: [],
    submittedBy: 'reporter-user',
    submittedAt,
    decidedBy: null,
    decidedAt: null,
    metadata: {},
    createdAt: submittedAt,
    updatedAt: submittedAt
  };
  const penalty = {
    id: 'penalty-2',
    status: 'active',
    effectiveUntil: null,
    updatedAt: submittedAt
  };
  const { service, auditRecords } = makeService({
    appeals: [appeal],
    penalties: [penalty]
  });

  const ack = await service.decide(
    'appeal-2',
    {
      decision: 'revoke',
      decisionNote: 'Decision note.'
    },
    context
  );

  assert.deepEqual(ack, { ok: true, traceId: context.traceId });
  assert.equal(appeal.status, 'revoked');
  assert.equal(appeal.decision, 'revoke');
  assert.equal(appeal.decisionNote, 'Decision note.');
  assert.equal(appeal.decidedBy, context.actorId);
  assert.equal(penalty.status, 'lifted');
  assert.ok(penalty.effectiveUntil instanceof Date);
  assert.equal(auditRecords.length, 1);
  assert.equal(auditRecords[0].subjectType, 'governance_appeal');
  assert.equal(auditRecords[0].action, 'governance_appeal_decide');
  assert.equal(auditRecords[0].metadata.previousStatus, 'submitted');
  assert.equal(auditRecords[0].metadata.nextStatus, 'revoked');
  assert.equal(auditRecords[0].metadata.penaltyStatusAfterDecision, 'lifted');
});

test('CS-028 decide rejects invalid payload and invalid state', async () => {
  const submittedAt = new Date('2026-04-08T04:00:00.000Z');
  const { service } = makeService({
    appeals: [
      {
        id: 'appeal-3',
        penaltyId: 'penalty-3',
        status: 'upheld',
        reason: 'Appeal reason.',
        decision: 'uphold',
        decisionNote: null,
        evidenceFileAssetIds: [],
        submittedBy: 'reporter-user',
        submittedAt,
        decidedBy: 'reviewer-user',
        decidedAt: submittedAt,
        metadata: {},
        createdAt: submittedAt,
        updatedAt: submittedAt
      }
    ],
    penalties: [{ id: 'penalty-3', status: 'active', effectiveUntil: null }]
  });

  await assert.rejects(
    () => service.decide('appeal-3', { decision: 'close' }, context),
    hasErrorCode('GOVERNANCE_APPEAL_DECIDE_INVALID')
  );
  await assert.rejects(
    () => service.decide('appeal-3', { decision: 'uphold' }, context),
    hasErrorCode('GOVERNANCE_INVALID_STATE')
  );
});

test('CS-028 decide returns controlled not-found when penalty truth is unavailable', async () => {
  const submittedAt = new Date('2026-04-08T05:00:00.000Z');
  const { service } = makeService({
    appeals: [
      {
        id: 'appeal-4',
        penaltyId: 'penalty-missing',
        status: 'submitted',
        reason: 'Appeal reason.',
        decision: null,
        decisionNote: null,
        evidenceFileAssetIds: [],
        submittedBy: 'reporter-user',
        submittedAt,
        decidedBy: null,
        decidedAt: null,
        metadata: {},
        createdAt: submittedAt,
        updatedAt: submittedAt
      }
    ],
    penalties: []
  });

  await assert.rejects(
    () => service.decide('appeal-4', { decision: 'uphold' }, context),
    hasErrorCode('GOVERNANCE_PENALTY_RESOURCE_UNAVAILABLE')
  );
});

test('CS-028 migration registry includes governance_appeal_cases truth and unresolved guard', () => {
  const { governanceAppealP1AMigrations, serverMigrations } = require('../dist/core/migrations/migrations.js');
  const migration = governanceAppealP1AMigrations.find(
    (item) => item.key === '20260408_governance_appeal_p1a_truth'
  );

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  const joined = migration.statements.join('\n');
  assert.match(joined, /CREATE TABLE IF NOT EXISTS governance_appeal_cases/);
  assert.match(joined, /status IN \('submitted', 'under_review'\)/);
  assert.doesNotMatch(joined, /permanent_bans/);
});
