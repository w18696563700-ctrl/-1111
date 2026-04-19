const path = require('path');
require('ts-node').register({
  transpileOnly: true,
  project: path.resolve(__dirname, '../tsconfig.json'),
});
require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');
const { AxiosError } = require('axios');
const { Module } = require('@nestjs/common');
const { NestFactory } = require('@nestjs/core');

const { AppProfileReadController } = require('../src/routes/profile/app-profile-read.controller.ts');
const { ProfileBlockService } = require('../src/routes/profile/profile-block.service.ts');
const { ProfileCreditConstraintsService } = require('../src/routes/profile/profile-credit-constraints.service.ts');
const { ProfileGovernanceAppealsService } = require('../src/routes/profile/profile-governance-appeals.service.ts');
const { ProfileGovernanceStatusService } = require('../src/routes/profile/profile-governance-status.service.ts');
const { ProfileMembershipService } = require('../src/routes/profile/profile-membership.service.ts');
const { ProfileMembersService } = require('../src/routes/profile/profile-members.service.ts');
const { ProfileOrganizationCreditScoringErrorService } = require('../src/routes/profile/profile-organization-credit-scoring-error.service.ts');
const { ProfileOrganizationCreditScoringService } = require('../src/routes/profile/profile-organization-credit-scoring.service.ts');
const { ProfilePaymentBillingStatusService } = require('../src/routes/profile/profile-payment-billing-status.service.ts');
const { ProfileReadService } = require('../src/routes/profile/profile-read.service.ts');
const { ProfileSafetyService } = require('../src/routes/profile/profile-safety.service.ts');
const { ProfileSecurityService } = require('../src/routes/profile/profile-security.service.ts');
const { ProfileCreditConstraintsErrorService } = require('../src/routes/profile/profile-credit-constraints-error.service.ts');
const { ErrorNormalizerService } = require('../src/core/errors/error-normalizer.service.ts');

function createAxiosResponseError(
  status,
  data,
  message = `Request failed with status code ${status}`,
) {
  return new AxiosError(message, 'ERR_BAD_REQUEST', {}, null, {
    status,
    statusText: 'error',
    headers: {},
    config: {},
    data,
  });
}

function createCurrentStatusPayload() {
  return {
    privateSummary: {
      entryKey: 'entry-1',
      summaryStatus: 'active',
      creditConstraintStatus: 'normal',
      depositPostureStatus: 'normal',
      transactionGuaranteeEligibilityStatus: 'eligible',
      updatedAt: '2026-04-14T10:00:00.000Z',
    },
    creditConstraint: {
      creditConstraintStatus: 'normal',
      performanceConstraintStatus: 'normal',
      executionAvailabilityStatus: 'available',
      restrictionReasonCode: null,
      advisoryReasonCode: 'observe',
      updatedAt: '2026-04-14T10:00:00.000Z',
    },
    deposit: {
      depositRequirementStatus: 'not_required',
      depositEligibilityStatus: 'eligible',
      depositRestrictionStatus: 'none',
      depositPostureStatus: 'normal',
      depositHandoffKey: 'deposit_handoff',
      depositDependencyKey: null,
      updatedAt: '2026-04-14T10:00:00.000Z',
    },
    transactionGuarantee: {
      transactionGuaranteeEligibilityStatus: 'eligible',
      transactionGuaranteeRestrictionStatus: 'none',
      transactionGuaranteeExplanationKey: 'guarantee_explanation',
      transactionGuaranteeHandoffKey: 'guarantee_handoff',
      transactionGuaranteeDependencyKey: null,
      updatedAt: '2026-04-14T10:00:00.000Z',
    },
    dependencyReference: null,
  };
}

function createCurrentExplanationPayload() {
  return {
    creditExplanation: {
      explanationKey: 'credit_explanation',
      title: '信用状态',
      body: '当前信用状态正常。',
    },
    depositExplanation: {
      explanationKey: 'deposit_explanation',
      title: '保证金状态',
      body: '当前保证金状态正常。',
    },
    transactionGuaranteeExplanation: {
      explanationKey: 'guarantee_explanation',
      title: '交易保障状态',
      body: '当前交易保障状态正常。',
    },
    dependencyExplanation: null,
    disclaimer: 'current-v21',
  };
}

function createCurrentHandoffPayload() {
  return {
    creditHandoff: {
      handoffKey: 'credit_handoff',
      title: '信用引导',
      body: '继续保持。',
    },
    depositHandoff: {
      handoffKey: 'deposit_handoff',
      title: '保证金引导',
      body: '无需处理。',
    },
    transactionGuaranteeHandoff: {
      handoffKey: 'guarantee_handoff',
      title: '交易保障引导',
      body: '无需处理。',
    },
    dependencyHandoff: null,
  };
}

function createReserveStatusPayload() {
  return {
    score: 76,
    tierCode: 'T2',
    tierLabel: '70-79',
    sampleStatus: 'SUFFICIENT',
    riskPosture: 'MEDIUM',
    ratedCompletedOrderCount: 5,
    positiveRate: 80,
    negativeRate: 20,
    verySatisfiedCount: 3,
    satisfiedCount: 1,
    passableCount: 0,
    negativeCount: 1,
    actionableState: 'watch',
    updatedAt: '2026-04-14T10:00:00.000Z',
  };
}

function createReserveExplanationPayload() {
  return {
    reasonSummary: '当前评分处于关注区间。',
    reasonCodes: ['RATING_ONLY_MODE_ACTIVE', 'POSITIVE_RATE_BELOW_80'],
    sampleStatus: 'SUFFICIENT',
    riskPosture: 'MEDIUM',
    ratedCompletedOrderCount: 5,
    positiveRate: 80,
    negativeRate: 20,
    verySatisfiedCount: 3,
    satisfiedCount: 1,
    passableCount: 0,
    negativeCount: 1,
    updatedAt: '2026-04-14T10:00:00.000Z',
  };
}

function createReserveHandoffPayload() {
  return {
    actionableState: 'watch',
    sampleStatus: 'SUFFICIENT',
    riskPosture: 'MEDIUM',
    primaryActionCode: 'reserve_watch',
    primaryActionLabel: '持续关注',
    handoffMessage: '当前评分处于关注区间。',
    updatedAt: '2026-04-14T10:00:00.000Z',
  };
}

async function createProfileReadApp({
  reserveService,
  currentCreditConstraintsService,
}) {
  class TestProfileReadModule {}
  Module({
    controllers: [AppProfileReadController],
    providers: [
      {
        provide: ProfileReadService,
        useValue: { getProfileIndex() {}, getOrganizations() {}, getCurrentCertification() {} },
      },
      { provide: ProfileBlockService, useValue: { getStatus() {} } },
      { provide: ProfileCreditConstraintsService, useValue: currentCreditConstraintsService },
      { provide: ProfileOrganizationCreditScoringService, useValue: reserveService },
      {
        provide: ProfilePaymentBillingStatusService,
        useValue: { getStatus() {}, getExplanation() {}, getHandoff() {} },
      },
      {
        provide: ProfileMembershipService,
        useValue: { getCurrent() {}, getExplanation() {}, getQuota() {}, getUpgradeGuide() {} },
      },
      { provide: ProfileMembersService, useValue: { getOrganizationMembers() {} } },
      { provide: ProfileSafetyService, useValue: { getSafetyStatus() {} } },
      { provide: ProfileSecurityService, useValue: { getSecurityDevices() {} } },
      {
        provide: ProfileGovernanceAppealsService,
        useValue: { getAppeals() {}, getAppealDetail() {} },
      },
      { provide: ProfileGovernanceStatusService, useValue: { getStatus() {} } },
    ],
  })(TestProfileReadModule);

  const app = await NestFactory.create(TestProfileReadModule, { logger: false });
  await app.listen(0, '127.0.0.1');
  return app;
}

test('reserve BFF family is readable and current V2.1 family stays registered', async () => {
  const reserveCalls = [];
  const currentCalls = [];

  const app = await createProfileReadApp({
    reserveService: {
      getStatus() {
        reserveCalls.push('status');
        return createReserveStatusPayload();
      },
      getExplanation() {
        reserveCalls.push('explanation');
        return createReserveExplanationPayload();
      },
      getHandoff() {
        reserveCalls.push('handoff');
        return createReserveHandoffPayload();
      },
    },
    currentCreditConstraintsService: {
      getStatus() {
        currentCalls.push('status');
        return createCurrentStatusPayload();
      },
      getExplanation() {
        currentCalls.push('explanation');
        return createCurrentExplanationPayload();
      },
      getHandoff() {
        currentCalls.push('handoff');
        return createCurrentHandoffPayload();
      },
    },
  });

  try {
    const url = await app.getUrl();

    const reserveStatus = await fetch(`${url}/api/app/profile/organization-credit-scoring/status`);
    assert.equal(reserveStatus.status, 200);
    const reserveStatusBody = await reserveStatus.json();
    assert.equal(reserveStatusBody.score, 76);
    assert.equal(reserveStatusBody.tierCode, 'T2');

    const reserveExplanation = await fetch(`${url}/api/app/profile/organization-credit-scoring/explanation`);
    assert.equal(reserveExplanation.status, 200);
    const reserveExplanationBody = await reserveExplanation.json();
    assert.equal(reserveExplanationBody.reasonSummary, '当前评分处于关注区间。');

    const reserveHandoff = await fetch(`${url}/api/app/profile/organization-credit-scoring/handoff`);
    assert.equal(reserveHandoff.status, 200);
    const reserveHandoffBody = await reserveHandoff.json();
    assert.equal(reserveHandoffBody.primaryActionCode, 'reserve_watch');

    const currentStatus = await fetch(`${url}/api/app/profile/credit-and-constraints/status`);
    assert.equal(currentStatus.status, 200);
    const currentStatusBody = await currentStatus.json();
    assert.equal(currentStatusBody.privateSummary.entryKey, 'entry-1');

    const currentExplanation = await fetch(`${url}/api/app/profile/credit-and-constraints/explanation`);
    assert.equal(currentExplanation.status, 200);
    const currentExplanationBody = await currentExplanation.json();
    assert.equal(currentExplanationBody.disclaimer, 'current-v21');

    const currentHandoff = await fetch(`${url}/api/app/profile/credit-and-constraints/handoff`);
    assert.equal(currentHandoff.status, 200);
    const currentHandoffBody = await currentHandoff.json();
    assert.equal(currentHandoffBody.creditHandoff.handoffKey, 'credit_handoff');
  } finally {
    await app.close();
  }

  assert.deepEqual(reserveCalls, ['status', 'explanation', 'handoff']);
  assert.deepEqual(currentCalls, ['status', 'explanation', 'handoff']);
});

test('reserve organization-credit-scoring service forwards to server and trims payload to reserve contract', async () => {
  const calls = [];
  const service = new ProfileOrganizationCreditScoringService(
    {
      async get(pathName, options) {
        calls.push({ pathName, options });
        if (pathName === '/server/profile/organization-credit-scoring/status') {
          return {
            ...createReserveStatusPayload(),
            reasonSummary: 'trim-me',
            internalScoreVersion: 12,
          };
        }
        if (pathName === '/server/profile/organization-credit-scoring/explanation') {
          return {
            ...createReserveExplanationPayload(),
            internalReasonVersion: 3,
          };
        }
        return {
          ...createReserveHandoffPayload(),
          reasonSummary: 'trim-me',
          internalHandoffVersion: 4,
        };
      },
    },
    {
      buildReadOnlyForwardHeaders() {
        return {
          authorization: 'Bearer token',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
          'x-actor-id': 'actor-1',
        };
      },
    },
    new ProfileOrganizationCreditScoringErrorService(new ErrorNormalizerService()),
  );

  const status = await service.getStatus({});
  const explanation = await service.getExplanation({});
  const handoff = await service.getHandoff({});

  assert.deepEqual(status, createReserveStatusPayload());
  assert.ok(!Object.prototype.hasOwnProperty.call(status, 'reasonSummary'));
  assert.deepEqual(explanation, createReserveExplanationPayload());
  assert.deepEqual(handoff, createReserveHandoffPayload());

  assert.deepEqual(calls, [
    {
      pathName: '/server/profile/organization-credit-scoring/status',
      options: {
        headers: {
          authorization: 'Bearer token',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
          'x-actor-id': 'actor-1',
        },
      },
    },
    {
      pathName: '/server/profile/organization-credit-scoring/explanation',
      options: {
        headers: {
          authorization: 'Bearer token',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
          'x-actor-id': 'actor-1',
        },
      },
    },
    {
      pathName: '/server/profile/organization-credit-scoring/handoff',
      options: {
        headers: {
          authorization: 'Bearer token',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
          'x-actor-id': 'actor-1',
        },
      },
    },
  ]);
});

test('reserve organization-credit-scoring errors are mapped into canonical reserve error family', async () => {
  const makeService = (serverClient) =>
    new ProfileOrganizationCreditScoringService(
      serverClient,
      {
        buildReadOnlyForwardHeaders() {
          return {
            authorization: 'Bearer token',
            'x-request-id': 'request-1',
            'x-trace-id': 'trace-1',
          };
        },
      },
      new ProfileOrganizationCreditScoringErrorService(new ErrorNormalizerService()),
    );

  await assert.rejects(
    () =>
      makeService({
        async get() {
          throw createAxiosResponseError(404, {
            code: 'SHADOW_RESULT_UNAVAILABLE',
            message: 'Future reserve shadow result is unavailable.',
            source: 'server',
          });
        },
      }).getStatus({}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.deepEqual(error.getResponse(), {
        statusCode: 404,
        code: 'SHADOW_RESULT_UNAVAILABLE',
        message: '当前组织信用评分状态暂不可用，请稍后再试。',
        details: undefined,
        source: 'server',
      });
      return true;
    },
  );

  await assert.rejects(
    () =>
      makeService({
        async get() {
          throw createAxiosResponseError(404, {
            code: 'AUTH_RESOURCE_UNAVAILABLE',
            message: 'Cannot GET /server/profile/organization-credit-scoring/explanation',
            source: 'server',
          });
        },
      }).getExplanation({}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.deepEqual(error.getResponse(), {
        statusCode: 404,
        code: 'FUTURE_CREDIT_FAMILY_UNAVAILABLE',
        message: '当前组织信用评分入口暂不可用，请稍后再试。',
        details: undefined,
        source: 'server',
      });
      return true;
    },
  );

  await assert.rejects(
    () =>
      makeService({
        async get() {
          throw new Error('socket hang up');
        },
      }).getHandoff({}),
    (error) => {
      assert.equal(error.getStatus(), 502);
      assert.deepEqual(error.getResponse(), {
        statusCode: 502,
        code: 'FUTURE_RESERVE_DEPENDENCY_UNAVAILABLE',
        message: '当前组织信用评分引导暂不可用，请稍后再试。',
        details: undefined,
        source: 'bff',
      });
      return true;
    },
  );
});

test('current V2.1 credit-and-constraints family still maps to original server paths unchanged', async () => {
  const calls = [];
  const service = new ProfileCreditConstraintsService(
    {
      async get(pathName, options) {
        calls.push({ pathName, options });
        if (pathName.endsWith('/status')) {
          return createCurrentStatusPayload();
        }
        if (pathName.endsWith('/explanation')) {
          return createCurrentExplanationPayload();
        }
        return createCurrentHandoffPayload();
      },
    },
    {
      buildReadOnlyForwardHeaders() {
        return {
          authorization: 'Bearer token',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
        };
      },
    },
    new ProfileCreditConstraintsErrorService(new ErrorNormalizerService()),
  );

  const status = await service.getStatus({});
  const explanation = await service.getExplanation({});
  const handoff = await service.getHandoff({});

  assert.equal(status.privateSummary.entryKey, 'entry-1');
  assert.ok(!Object.prototype.hasOwnProperty.call(status, 'score'));
  assert.equal(explanation.creditExplanation.explanationKey, 'credit_explanation');
  assert.equal(handoff.creditHandoff.handoffKey, 'credit_handoff');

  assert.deepEqual(calls, [
    {
      pathName: '/server/profile/credit-and-constraints/status',
      options: {
        headers: {
          authorization: 'Bearer token',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
        },
      },
    },
    {
      pathName: '/server/profile/credit-and-constraints/explanation',
      options: {
        headers: {
          authorization: 'Bearer token',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
        },
      },
    },
    {
      pathName: '/server/profile/credit-and-constraints/handoff',
      options: {
        headers: {
          authorization: 'Bearer token',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
        },
      },
    },
  ]);
});
