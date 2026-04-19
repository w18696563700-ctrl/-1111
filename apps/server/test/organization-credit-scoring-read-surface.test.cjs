const test = require('node:test');
const assert = require('node:assert/strict');
const { PATH_METADATA, METHOD_METADATA } = require('@nestjs/common/constants');
const { RequestMethod } = require('@nestjs/common');

function createContext(requestId) {
  return {
    authorization: 'Bearer token',
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

function createReserveServices({ aggregate = null, scope = null } = {}) {
  return {
    verifier: {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: scope?.organization?.id ?? 'org-1',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    eligibility: {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return scope;
      },
    },
    repository: {
      async findOneBy() {
        return aggregate;
      },
    },
  };
}

test('reserve read surface exposes future organization credit scoring status explanation and handoff', async () => {
  const { OrganizationCreditScoringQueryService } = require('../dist/modules/credit_scoring_shadow/organization-credit-scoring.query.service.js');
  const { OrganizationCreditScoringPresenter } = require('../dist/modules/credit_scoring_shadow/organization-credit-scoring.presenter.js');

  const { verifier, eligibility, repository } = createReserveServices({
    scope: { organization: { id: 'org-1' } },
    aggregate: {
      organizationId: 'org-1',
      aggregationMode: 'formal_rating_only_shadow',
      sampleStatus: 'ready',
      ratedCompletedOrderCount: 8,
      verySatisfiedCount: 4,
      satisfiedCount: 3,
      passableCount: 1,
      negativeCount: 0,
      positiveRate: 87.5,
      negativeRate: 12.5,
      recentConsecutiveNegativeCount: 0,
      last20RatedNegativeRate: 0,
      baseScore: 60,
      rawScore: 83.6,
      effectiveScore: 83.6,
      publicScore: 83.6,
      tierCode: 'T3',
      riskPosture: 'observe',
      tierReasonCodes: ['RATING_SCORE_80_89'],
      postureReasonCodes: ['RATING_ONLY_MODE_ACTIVE', 'POSITIVE_RATE_BELOW_80'],
      reasonSummary: 'shadow@2026-04-14T09:00:00Z | 样本=8 | effectiveScore=83.60 | tier=T3 | risk=observe',
      version: 1,
      lastRatedOrderId: 'order-8',
      lastRatedAt: new Date('2026-04-14T08:59:00Z'),
      updatedAt: new Date('2026-04-14T09:00:00Z'),
    },
  });

  const service = new OrganizationCreditScoringQueryService(
    repository,
    verifier,
    eligibility,
    new OrganizationCreditScoringPresenter(),
  );

  const status = await service.getStatus(createContext('reserve-status'));
  assert.deepEqual(status, {
    score: 84,
    tierCode: 'T3',
    tierLabel: '80-89',
    sampleStatus: 'SUFFICIENT',
    riskPosture: 'MEDIUM',
    ratedCompletedOrderCount: 8,
    positiveRate: 87.5,
    negativeRate: 12.5,
    verySatisfiedCount: 4,
    satisfiedCount: 3,
    passableCount: 1,
    negativeCount: 0,
    reasonSummary: 'shadow@2026-04-14T09:00:00Z | 样本=8 | effectiveScore=83.60 | tier=T3 | risk=observe',
    actionableState: 'watch',
    updatedAt: '2026-04-14T09:00:00.000Z',
  });

  const explanation = await service.getExplanation(createContext('reserve-explanation'));
  assert.deepEqual(explanation, {
    reasonSummary: 'shadow@2026-04-14T09:00:00Z | 样本=8 | effectiveScore=83.60 | tier=T3 | risk=observe',
    reasonCodes: ['RATING_SCORE_80_89', 'RATING_ONLY_MODE_ACTIVE', 'POSITIVE_RATE_BELOW_80'],
    sampleStatus: 'SUFFICIENT',
    riskPosture: 'MEDIUM',
    ratedCompletedOrderCount: 8,
    positiveRate: 87.5,
    negativeRate: 12.5,
    verySatisfiedCount: 4,
    satisfiedCount: 3,
    passableCount: 1,
    negativeCount: 0,
    updatedAt: '2026-04-14T09:00:00.000Z',
  });

  const handoff = await service.getHandoff(createContext('reserve-handoff'));
  assert.deepEqual(handoff, {
    actionableState: 'watch',
    sampleStatus: 'SUFFICIENT',
    riskPosture: 'MEDIUM',
    primaryActionCode: 'reserve_watch',
    primaryActionLabel: '持续关注',
    handoffMessage: 'shadow@2026-04-14T09:00:00Z | 样本=8 | effectiveScore=83.60 | tier=T3 | risk=observe',
    updatedAt: '2026-04-14T09:00:00.000Z',
  });
});

test('reserve read surface fail-closes with shadow result unavailable when aggregate is missing', async () => {
  const { OrganizationCreditScoringQueryService } = require('../dist/modules/credit_scoring_shadow/organization-credit-scoring.query.service.js');
  const { OrganizationCreditScoringPresenter } = require('../dist/modules/credit_scoring_shadow/organization-credit-scoring.presenter.js');

  const { verifier, eligibility, repository } = createReserveServices({
    scope: { organization: { id: 'org-1' } },
    aggregate: null,
  });

  const service = new OrganizationCreditScoringQueryService(
    repository,
    verifier,
    eligibility,
    new OrganizationCreditScoringPresenter(),
  );

  await assert.rejects(
    () => service.getStatus(createContext('reserve-missing')),
    (error) => error?.response?.code === 'SHADOW_RESULT_UNAVAILABLE',
  );
});

test('reserve read surface returns insufficient sample projection without polluting current V2.1', async () => {
  const { OrganizationCreditScoringQueryService } = require('../dist/modules/credit_scoring_shadow/organization-credit-scoring.query.service.js');
  const { OrganizationCreditScoringPresenter } = require('../dist/modules/credit_scoring_shadow/organization-credit-scoring.presenter.js');
  const { CreditConstraintsController } = require('../dist/modules/credit_constraints/credit-constraints.controller.js');
  const { OrganizationCreditScoringController } = require('../dist/modules/credit_scoring_shadow/organization-credit-scoring.controller.js');

  const { verifier, eligibility, repository } = createReserveServices({
    scope: { organization: { id: 'org-1' } },
    aggregate: {
      organizationId: 'org-1',
      aggregationMode: 'formal_rating_only_shadow',
      sampleStatus: 'insufficient',
      ratedCompletedOrderCount: 4,
      verySatisfiedCount: 1,
      satisfiedCount: 1,
      passableCount: 1,
      negativeCount: 1,
      positiveRate: 50,
      negativeRate: 25,
      recentConsecutiveNegativeCount: 1,
      last20RatedNegativeRate: 25,
      baseScore: 60,
      rawScore: 71,
      effectiveScore: 71,
      publicScore: null,
      tierCode: 'T0',
      riskPosture: 'normal',
      tierReasonCodes: ['SAMPLE_INSUFFICIENT'],
      postureReasonCodes: ['SAMPLE_INSUFFICIENT', 'RATING_ONLY_MODE_ACTIVE'],
      reasonSummary: 'shadow@2026-04-14T09:00:00Z | 样本不足:4/5 | tier=T0 | risk=normal',
      version: 1,
      lastRatedOrderId: 'order-4',
      lastRatedAt: new Date('2026-04-14T08:45:00Z'),
      updatedAt: new Date('2026-04-14T09:00:00Z'),
    },
  });

  const service = new OrganizationCreditScoringQueryService(
    repository,
    verifier,
    eligibility,
    new OrganizationCreditScoringPresenter(),
  );

  const status = await service.getStatus(createContext('reserve-insufficient'));
  assert.deepEqual(status, {
    score: null,
    tierCode: null,
    tierLabel: null,
    sampleStatus: 'INSUFFICIENT',
    riskPosture: null,
    ratedCompletedOrderCount: 4,
    positiveRate: null,
    negativeRate: null,
    verySatisfiedCount: 1,
    satisfiedCount: 1,
    passableCount: 1,
    negativeCount: 1,
    reasonSummary: 'shadow@2026-04-14T09:00:00Z | 样本不足:4/5 | tier=T0 | risk=normal',
    actionableState: null,
    updatedAt: '2026-04-14T09:00:00.000Z',
  });

  const explanation = await service.getExplanation(createContext('reserve-insufficient-explanation'));
  assert.deepEqual(explanation, {
    reasonSummary: 'shadow@2026-04-14T09:00:00Z | 样本不足:4/5 | tier=T0 | risk=normal',
    reasonCodes: ['SAMPLE_INSUFFICIENT', 'RATING_ONLY_MODE_ACTIVE'],
    sampleStatus: 'INSUFFICIENT',
    riskPosture: null,
    ratedCompletedOrderCount: 4,
    positiveRate: null,
    negativeRate: null,
    verySatisfiedCount: 1,
    satisfiedCount: 1,
    passableCount: 1,
    negativeCount: 1,
    updatedAt: '2026-04-14T09:00:00.000Z',
  });

  const handoff = await service.getHandoff(createContext('reserve-insufficient-handoff'));
  assert.deepEqual(handoff, {
    actionableState: null,
    sampleStatus: 'INSUFFICIENT',
    riskPosture: null,
    primaryActionCode: null,
    primaryActionLabel: null,
    handoffMessage: null,
    updatedAt: '2026-04-14T09:00:00.000Z',
  });

  assert.deepEqual(Reflect.getMetadata(PATH_METADATA, CreditConstraintsController), 'server/profile/credit-and-constraints');
  assert.equal(Reflect.getMetadata(PATH_METADATA, OrganizationCreditScoringController), 'server/profile/organization-credit-scoring');
  assert.equal(Reflect.getMetadata(PATH_METADATA, OrganizationCreditScoringController.prototype.getStatus), 'status');
  assert.equal(Reflect.getMetadata(METHOD_METADATA, OrganizationCreditScoringController.prototype.getStatus), RequestMethod.GET);
  assert.equal(Reflect.getMetadata(PATH_METADATA, OrganizationCreditScoringController.prototype.getExplanation), 'explanation');
  assert.equal(Reflect.getMetadata(METHOD_METADATA, OrganizationCreditScoringController.prototype.getExplanation), RequestMethod.GET);
  assert.equal(Reflect.getMetadata(PATH_METADATA, OrganizationCreditScoringController.prototype.getHandoff), 'handoff');
  assert.equal(Reflect.getMetadata(METHOD_METADATA, OrganizationCreditScoringController.prototype.getHandoff), RequestMethod.GET);
});

test('reserve read surface fail-closes when visibility or authorization is unavailable', async () => {
  const { OrganizationCreditScoringQueryService } = require('../dist/modules/credit_scoring_shadow/organization-credit-scoring.query.service.js');
  const { OrganizationCreditScoringPresenter } = require('../dist/modules/credit_scoring_shadow/organization-credit-scoring.presenter.js');

  const { verifier, eligibility, repository } = createReserveServices({
    scope: null,
    aggregate: null,
  });

  const service = new OrganizationCreditScoringQueryService(
    repository,
    verifier,
    eligibility,
    new OrganizationCreditScoringPresenter(),
  );

  await assert.rejects(
    () => service.getExplanation(createContext('reserve-auth-missing')),
    (error) => error?.response?.code === 'FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE',
  );
});
