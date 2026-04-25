const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildShadowAggregateSnapshot,
  resolveShadowRatingScoreValue,
} = require('../dist/modules/credit_scoring_shadow/credit-scoring-shadow.engine.js');
const {
  CreditScoringShadowAggregationService,
} = require('../dist/modules/credit_scoring_shadow/credit-scoring-shadow.aggregation.service.js');

function createShadowDataSourceMock({
  columns = ['score'],
  ratingRows = [],
  existingAggregate = null,
} = {}) {
  const state = {
    aggregateSaved: null,
    ledgerSaved: null,
    triggerSaved: null,
    triggerUpdated: null,
    queries: [],
  };

  const aggregateRepo = {
    findOneBy: async () => (existingAggregate ? { ...existingAggregate } : null),
    create: (value) => ({ ...value }),
    save: async (value) => {
      state.aggregateSaved = { ...value };
      return value;
    },
  };

  const ledgerRepo = {
    create: (value) => ({ ...value }),
    save: async (value) => {
      state.ledgerSaved = { ...value };
      return value;
    },
  };

  const triggerRepo = {
    create: (value) => ({ ...value }),
    save: async (value) => {
      state.triggerSaved = { ...value };
      return value;
    },
    update: async (triggerId, patch) => {
      state.triggerUpdated = { triggerId, patch: { ...patch } };
    },
  };

  const manager = {
    getRepository(entity) {
      switch (entity?.name) {
        case 'OrganizationCreditShadowAggregateEntity':
          return aggregateRepo;
        case 'OrganizationCreditShadowLedgerEntryEntity':
          return ledgerRepo;
        case 'OrganizationCreditShadowRecomputeTriggerEntity':
          return triggerRepo;
        default:
          throw new Error(`Unexpected repository request: ${entity?.name ?? 'unknown'}`);
      }
    },
    async query(sql) {
      state.queries.push(sql);
      if (sql.includes('information_schema.columns')) {
        return columns.map((columnName) => ({
          columnName,
          dataType: columnName.includes('level') || columnName.includes('grade') ? 'text' : 'numeric',
        }));
      }
      if (sql.includes('candidate_ratings')) {
        return ratingRows;
      }
      throw new Error(`Unexpected SQL branch: ${sql}`);
    },
  };

  return {
    state,
    dataSource: {
      async transaction(callback) {
        return callback(manager);
      },
    },
  };
}

test('shadow engine keeps samples insufficient below 5 and resolves label scores', () => {
  const snapshot = buildShadowAggregateSnapshot('org-1', [
    { orderId: 'o1', ratingId: 'r1', submittedAt: new Date('2026-04-14T08:00:00Z'), scoreValue: null, scoreLabel: 'very_satisfied' },
    { orderId: 'o2', ratingId: 'r2', submittedAt: new Date('2026-04-14T08:01:00Z'), scoreValue: null, scoreLabel: 'satisfied' },
    { orderId: 'o3', ratingId: 'r3', submittedAt: new Date('2026-04-14T08:02:00Z'), scoreValue: null, scoreLabel: 'passable' },
    { orderId: 'o4', ratingId: 'r4', submittedAt: new Date('2026-04-14T08:03:00Z'), scoreValue: null, scoreLabel: 'negative' },
  ], new Date('2026-04-14T09:00:00Z'));

  assert.equal(snapshot.sampleStatus, 'insufficient');
  assert.equal(snapshot.tierCode, 'T0');
  assert.equal(snapshot.publicScore, null);
  assert.equal(snapshot.verySatisfiedCount, 1);
  assert.equal(snapshot.satisfiedCount, 1);
  assert.equal(snapshot.passableCount, 1);
  assert.equal(snapshot.negativeCount, 1);
  assert.deepEqual(snapshot.tierReasonCodes, ['SAMPLE_INSUFFICIENT']);
  assert.deepEqual(snapshot.postureReasonCodes, ['SAMPLE_INSUFFICIENT', 'RATING_ONLY_MODE_ACTIVE']);
  assert.equal(resolveShadowRatingScoreValue({ scoreValue: null, scoreLabel: 'negative' }), 30);
});

test('shadow engine computes ready aggregate and observe posture for 5+ samples', () => {
  const snapshot = buildShadowAggregateSnapshot('org-1', [
    { orderId: 'o1', ratingId: 'r1', submittedAt: new Date('2026-04-14T08:00:00Z'), scoreValue: 100, scoreLabel: null },
    { orderId: 'o2', ratingId: 'r2', submittedAt: new Date('2026-04-14T08:01:00Z'), scoreValue: 70, scoreLabel: null },
    { orderId: 'o3', ratingId: 'r3', submittedAt: new Date('2026-04-14T08:02:00Z'), scoreValue: 70, scoreLabel: null },
    { orderId: 'o4', ratingId: 'r4', submittedAt: new Date('2026-04-14T08:03:00Z'), scoreValue: 70, scoreLabel: null },
    { orderId: 'o5', ratingId: 'r5', submittedAt: new Date('2026-04-14T08:04:00Z'), scoreValue: 70, scoreLabel: null },
  ], new Date('2026-04-14T09:00:00Z'));

  assert.equal(snapshot.sampleStatus, 'ready');
  assert.equal(snapshot.ratedCompletedOrderCount, 5);
  assert.equal(snapshot.effectiveScore, 76);
  assert.equal(snapshot.publicScore, 76);
  assert.equal(snapshot.tierCode, 'T2');
  assert.equal(snapshot.riskPosture, 'observe');
  assert.deepEqual(snapshot.tierReasonCodes, ['RATING_SCORE_70_79']);
  assert.deepEqual(snapshot.postureReasonCodes, ['RATING_ONLY_MODE_ACTIVE', 'POSITIVE_RATE_BELOW_80']);
});

test('shadow engine upgrades to risk alert when negative posture exceeds threshold', () => {
  const snapshot = buildShadowAggregateSnapshot('org-1', [
    { orderId: 'o1', ratingId: 'r1', submittedAt: new Date('2026-04-14T08:00:00Z'), scoreValue: 100, scoreLabel: null },
    { orderId: 'o2', ratingId: 'r2', submittedAt: new Date('2026-04-14T08:01:00Z'), scoreValue: 100, scoreLabel: null },
    { orderId: 'o3', ratingId: 'r3', submittedAt: new Date('2026-04-14T08:02:00Z'), scoreValue: 30, scoreLabel: null },
    { orderId: 'o4', ratingId: 'r4', submittedAt: new Date('2026-04-14T08:03:00Z'), scoreValue: 30, scoreLabel: null },
    { orderId: 'o5', ratingId: 'r5', submittedAt: new Date('2026-04-14T08:04:00Z'), scoreValue: 30, scoreLabel: null },
  ], new Date('2026-04-14T09:00:00Z'));

  assert.equal(snapshot.sampleStatus, 'ready');
  assert.equal(snapshot.riskPosture, 'risk_alert');
  assert.equal(snapshot.recentConsecutiveNegativeCount, 3);
  assert.equal(snapshot.last20RatedNegativeRate, 60);
  assert.deepEqual(snapshot.postureReasonCodes, [
    'RATING_ONLY_MODE_ACTIVE',
    'LAST20_NEGATIVE_RATE_AT_LEAST_30',
    'NEGATIVE_RATE_AT_LEAST_20',
    'CONSECUTIVE_NEGATIVE_3',
  ]);
});

test('shadow aggregation service persists aggregate, ledger, and recompute trigger rows', async () => {
  const { state, dataSource } = createShadowDataSourceMock({
    columns: ['score'],
    existingAggregate: {
      organizationId: 'supplier-org',
      aggregationMode: 'formal_rating_only_shadow',
      sampleStatus: 'ready',
      ratedCompletedOrderCount: 5,
      verySatisfiedCount: 3,
      satisfiedCount: 1,
      passableCount: 1,
      negativeCount: 0,
      positiveRate: 80,
      negativeRate: 0,
      recentConsecutiveNegativeCount: 0,
      last20RatedNegativeRate: 0,
      baseScore: 60,
      rawScore: 72,
      effectiveScore: 72,
      publicScore: 72,
      tierCode: 'T2',
      riskPosture: 'observe',
      tierReasonCodes: ['RATING_SCORE_70_79'],
      postureReasonCodes: ['RATING_ONLY_MODE_ACTIVE', 'POSITIVE_RATE_BELOW_80'],
      reasonSummary: 'before',
      version: 1,
      lastRatedOrderId: 'order-prev',
      lastRatedAt: new Date('2026-04-14T07:00:00Z'),
      updatedAt: new Date('2026-04-14T07:10:00Z'),
    },
    ratingRows: [
      {
        orderId: 'order-5',
        ratingId: 'rating-5',
        submittedAt: new Date('2026-04-14T08:14:00Z'),
        scoreValue: 100,
        scoreLabel: null,
      },
      {
        orderId: 'order-4',
        ratingId: 'rating-4',
        submittedAt: new Date('2026-04-14T08:13:00Z'),
        scoreValue: 100,
        scoreLabel: null,
      },
      {
        orderId: 'order-3',
        ratingId: 'rating-3',
        submittedAt: new Date('2026-04-14T08:12:00Z'),
        scoreValue: 100,
        scoreLabel: null,
      },
      {
        orderId: 'order-2',
        ratingId: 'rating-2',
        submittedAt: new Date('2026-04-14T08:11:00Z'),
        scoreValue: 100,
        scoreLabel: null,
      },
      {
        orderId: 'order-1',
        ratingId: 'rating-1',
        submittedAt: new Date('2026-04-14T08:10:00Z'),
        scoreValue: 100,
        scoreLabel: null,
      },
    ],
  });

  const service = new CreditScoringShadowAggregationService(dataSource);
  const snapshot = await service.recomputeAfterFormalRatingSubmit({
    organizationId: 'supplier-org',
    sourceOrderId: 'order-5',
    sourceRatingId: 'rating-5',
    triggeredAt: new Date('2026-04-14T09:00:00Z'),
  });

  assert.equal(snapshot.organizationId, 'supplier-org');
  assert.equal(snapshot.sampleStatus, 'ready');
  assert.equal(snapshot.publicScore, 100);
  assert.equal(snapshot.tierCode, 'T4');
  assert.equal(snapshot.riskPosture, 'normal');

  assert.ok(state.aggregateSaved);
  assert.equal(state.aggregateSaved.organizationId, 'supplier-org');
  assert.equal(state.aggregateSaved.publicScore, 100);
  assert.equal(state.aggregateSaved.tierCode, 'T4');
  assert.ok(state.ledgerSaved);
  assert.equal(state.ledgerSaved.triggerType, 'formal_rating_submitted');
  assert.equal(state.ledgerSaved.sourceType, 'order_rating');
  assert.equal(state.ledgerSaved.sourceOrderId, 'order-5');
  assert.equal(state.ledgerSaved.sourceRatingId, 'rating-5');
  assert.equal(state.ledgerSaved.beforeScore, 72);
  assert.equal(state.ledgerSaved.afterScore, 100);
  assert.equal(state.ledgerSaved.beforeTierCode, 'T2');
  assert.equal(state.ledgerSaved.afterTierCode, 'T4');
  assert.equal(state.ledgerSaved.beforeRiskPosture, 'observe');
  assert.equal(state.ledgerSaved.afterRiskPosture, 'normal');
  assert.ok(state.triggerSaved);
  assert.equal(state.triggerSaved.triggerType, 'formal_rating_submitted');
  assert.equal(state.triggerSaved.sourceType, 'order_rating');
  assert.equal(state.triggerSaved.sourceOrderId, 'order-5');
  assert.equal(state.triggerSaved.sourceRatingId, 'rating-5');
  assert.equal(state.triggerSaved.triggerStatus, 'pending');
  assert.deepEqual(state.triggerSaved.reasonCodes, ['RATING_ONLY_MODE_ACTIVE']);
  assert.ok(state.triggerUpdated);
  assert.equal(state.triggerUpdated.patch.triggerStatus, 'processed');
  assert.ok(
    state.queries.some((sql) => sql.includes('public.project_counterparty_ratings')),
  );
});

test('shadow aggregation service accepts project counterparty rating rows as bridge input', async () => {
  const { state, dataSource } = createShadowDataSourceMock({
    columns: ['score'],
    ratingRows: [
      {
        orderId: 'order-counterparty-1',
        ratingId: 'project-counterparty-rating-1',
        submittedAt: new Date('2026-05-08T08:00:00Z'),
        scoreValue: null,
        scoreLabel: 'very_satisfied',
      },
      {
        orderId: 'order-counterparty-2',
        ratingId: 'project-counterparty-rating-2',
        submittedAt: new Date('2026-05-08T08:01:00Z'),
        scoreValue: null,
        scoreLabel: 'satisfied',
      },
      {
        orderId: 'order-counterparty-3',
        ratingId: 'project-counterparty-rating-3',
        submittedAt: new Date('2026-05-08T08:02:00Z'),
        scoreValue: null,
        scoreLabel: 'passable',
      },
      {
        orderId: 'order-counterparty-4',
        ratingId: 'project-counterparty-rating-4',
        submittedAt: new Date('2026-05-08T08:03:00Z'),
        scoreValue: null,
        scoreLabel: 'very_satisfied',
      },
      {
        orderId: 'order-counterparty-5',
        ratingId: 'project-counterparty-rating-5',
        submittedAt: new Date('2026-05-08T08:04:00Z'),
        scoreValue: null,
        scoreLabel: 'very_satisfied',
      },
    ],
  });

  const service = new CreditScoringShadowAggregationService(dataSource);
  const snapshot = await service.recomputeAfterFormalRatingSubmit({
    organizationId: 'ratee-org',
    sourceType: 'project_counterparty_rating',
    sourceOrderId: 'order-counterparty-5',
    sourceRatingId: 'project-counterparty-rating-5',
    triggeredAt: new Date('2026-05-08T09:00:00Z'),
  });

  assert.equal(snapshot.organizationId, 'ratee-org');
  assert.equal(snapshot.sampleStatus, 'ready');
  assert.equal(snapshot.ratedCompletedOrderCount, 5);
  assert.equal(snapshot.publicScore, 91);
  assert.ok(state.triggerSaved);
  assert.equal(state.triggerSaved.triggerType, 'formal_rating_submitted');
  assert.equal(state.triggerSaved.sourceType, 'project_counterparty_rating');
  assert.equal(state.triggerSaved.sourceOrderId, 'order-counterparty-5');
  assert.equal(state.triggerSaved.sourceRatingId, 'project-counterparty-rating-5');
  assert.ok(state.ledgerSaved);
  assert.equal(state.ledgerSaved.triggerType, 'formal_rating_submitted');
  assert.equal(state.ledgerSaved.sourceType, 'project_counterparty_rating');
  assert.equal(state.ledgerSaved.sourceOrderId, 'order-counterparty-5');
  assert.equal(state.ledgerSaved.sourceRatingId, 'project-counterparty-rating-5');
  assert.ok(
    state.queries.some((sql) => sql.includes('public.project_counterparty_ratings')),
  );
});
