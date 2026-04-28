const path = require('path');
require('ts-node').register({
  transpileOnly: true,
  project: path.resolve(__dirname, '../tsconfig.json'),
});
require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');
const { AxiosError } = require('axios');
const { Module, RequestMethod } = require('@nestjs/common');
const { METHOD_METADATA, PATH_METADATA } = require('@nestjs/common/constants');
const { NestFactory } = require('@nestjs/core');

const {
  AppExhibitionP0PayController,
} = require('../src/routes/exhibition_p0_pay/app-exhibition-p0-pay.controller.ts');
const {
  ExhibitionP0PayService,
} = require('../src/routes/exhibition_p0_pay/exhibition-p0-pay.service.ts');
const {
  ExhibitionP0PayPayloadService,
} = require('../src/routes/exhibition_p0_pay/exhibition-p0-pay-payload.service.ts');
const {
  ExhibitionP0PayErrorService,
} = require('../src/routes/exhibition_p0_pay/exhibition-p0-pay-error.service.ts');
const { ErrorNormalizerService } = require('../src/core/errors/error-normalizer.service.ts');
const { AuthContextService } = require('../src/core/auth/auth-context.service.ts');
const { ServerClientService } = require('../src/core/http/server-client.service.ts');

const p0PayPostRoutes = [
  '/api/app/exhibition/trade-tasks',
  '/api/app/exhibition/trade-tasks/task-1/authenticity-materials',
  '/api/app/exhibition/trade-tasks/task-1/fixed-price-bids',
  '/api/app/exhibition/trade-tasks/task-1/fixed-price-bids/bid-1/service-fee-authorizations',
  '/api/app/exhibition/trade-tasks/task-1/fixed-price-bids/bid-1/service-fee-authorizations/auth-1/authorize-init',
  '/api/app/exhibition/trade-tasks/task-1/inquiry-deposit/orders',
  '/api/app/exhibition/trade-tasks/task-1/inquiry-deposit/orders/deposit-1/pay-init',
  '/api/app/exhibition/trade-tasks/task-1/inquiry-quotations',
  '/api/app/exhibition/trade-tasks/task-1/inquiry-result',
  '/api/app/exhibition/trade-tasks/task-1/contract-confirmations',
  '/api/app/exhibition/trade-tasks/task-1/p0-pay-actions/release-non-winning',
  '/api/app/exhibition/trade-tasks/task-1/p0-pay-actions/publisher-breach-release',
  '/api/app/exhibition/trade-tasks/task-1/p0-pay-actions/factory-refusal-breach-hold',
];

const p0PayGetRoutes = [
  '/api/app/exhibition/trade-tasks/task-1',
  '/api/app/exhibition/trade-tasks/task-1/fixed-price-bids/bid-1/service-fee-authorizations/auth-1',
  '/api/app/exhibition/trade-tasks/task-1/inquiry-deposit/orders/deposit-1',
  '/api/app/exhibition/trade-tasks/task-1/p0-pay-summary',
];

function createAxiosResponseError(status, data, message = `Request failed with status code ${status}`) {
  return new AxiosError(message, 'ERR_BAD_REQUEST', {}, null, {
    status,
    statusText: 'error',
    headers: {},
    config: {},
    data,
  });
}

function createService(serverClient) {
  return new ExhibitionP0PayService(
    serverClient,
    {
      buildForwardHeaders() {
        return {
          authorization: 'Bearer token',
          'x-organization-id': 'org-1',
          'x-actor-role': 'publisher',
        };
      },
    },
    new ExhibitionP0PayPayloadService(),
    new ExhibitionP0PayErrorService(new ErrorNormalizerService()),
  );
}

async function createRealRouteApp(serverClient) {
  class TestModule {}
  Module({
    controllers: [AppExhibitionP0PayController],
    providers: [
      ExhibitionP0PayService,
      ExhibitionP0PayPayloadService,
      ExhibitionP0PayErrorService,
      ErrorNormalizerService,
      AuthContextService,
      { provide: ServerClientService, useValue: serverClient },
    ],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, '127.0.0.1');
  return app;
}

test('P0-Pay app-facing routes are materialized under exhibition trade-tasks only', async () => {
  const calls = [];
  const service = {
    createTradeTask(payload, headers, idempotencyKey) {
      calls.push(['createTradeTask', payload.taskType, idempotencyKey ?? null]);
      return { taskId: 'task-1', taskType: payload.taskType };
    },
    getTradeTaskDetail(taskId) {
      calls.push(['detail', taskId]);
      return { taskId, p0PaySummary: { readOnly: true } };
    },
    bindAuthenticityMaterials(taskId) {
      calls.push(['materials', taskId]);
      return { taskId, materialCount: 1 };
    },
    submitFixedPriceBid(taskId) {
      calls.push(['fixedBid', taskId]);
      return { bidId: 'bid-1' };
    },
    createServiceFeeAuthorization(taskId, bidId) {
      calls.push(['authCreate', taskId, bidId]);
      return { authorizationId: 'auth-1' };
    },
    authorizeServiceFee(taskId, bidId, authorizationId) {
      calls.push(['authInit', taskId, bidId, authorizationId]);
      return { authorizationId };
    },
    getServiceFeeAuthorization(taskId, bidId, authorizationId) {
      calls.push(['authStatus', taskId, bidId, authorizationId]);
      return { authorizationId };
    },
    createInquiryDepositOrder(taskId) {
      calls.push(['depositCreate', taskId]);
      return { depositOrderId: 'deposit-1' };
    },
    initInquiryDepositPay(taskId, depositOrderId) {
      calls.push(['depositPay', taskId, depositOrderId]);
      return { depositOrderId };
    },
    getInquiryDepositOrder(taskId, depositOrderId) {
      calls.push(['depositStatus', taskId, depositOrderId]);
      return { depositOrderId };
    },
    submitInquiryQuotation(taskId) {
      calls.push(['quote', taskId]);
      return { quotationId: 'quotation-1' };
    },
    processInquiryResult(taskId) {
      calls.push(['result', taskId]);
      return { taskId };
    },
    createContractConfirmation(taskId) {
      calls.push(['contract', taskId]);
      return { contractConfirmationId: 'contract-1' };
    },
    getP0PaySummary(taskId) {
      calls.push(['summary', taskId]);
      return {
        taskId,
        messageDisplaySummary: { readOnly: true },
      };
    },
    releaseNonWinning(taskId) {
      calls.push(['releaseNonWinning', taskId]);
      return { action: 'release_non_winning_authorizations', changed: 1 };
    },
    releasePublisherBreach(taskId) {
      calls.push(['publisherBreachRelease', taskId]);
      return { action: 'publisher_breach_release', changed: 1 };
    },
    holdFactoryRefusal(taskId) {
      calls.push(['factoryRefusalHold', taskId]);
      return { action: 'factory_refusal_breach_hold', changed: 1 };
    },
  };

  class TestModule {}
  Module({
    controllers: [AppExhibitionP0PayController],
    providers: [{ provide: ExhibitionP0PayService, useValue: service }],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, '127.0.0.1');

  try {
    const url = await app.getUrl();
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, AppExhibitionP0PayController),
      'api/app/exhibition/trade-tasks',
    );
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, AppExhibitionP0PayController.prototype.getP0PaySummary),
      RequestMethod.GET,
    );

    const createResponse = await fetch(`${url}/api/app/exhibition/trade-tasks`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-idempotency-key': 'idem-create',
      },
      body: JSON.stringify({ taskType: 'inquiry_quote' }),
    });
    assert.equal(createResponse.status, 202);
    assert.equal((await createResponse.json()).taskId, 'task-1');

    const authResponse = await fetch(
      `${url}/api/app/exhibition/trade-tasks/task-1/fixed-price-bids/bid-1/service-fee-authorizations/auth-1/authorize-init`,
      { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({}) },
    );
    assert.equal(authResponse.status, 202);

    const summaryResponse = await fetch(
      `${url}/api/app/exhibition/trade-tasks/task-1/p0-pay-summary`,
    );
    assert.equal(summaryResponse.status, 200);
    assert.equal((await summaryResponse.json()).messageDisplaySummary.readOnly, true);

    const releaseResponse = await fetch(
      `${url}/api/app/exhibition/trade-tasks/task-1/p0-pay-actions/release-non-winning`,
      { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({}) },
    );
    assert.equal(releaseResponse.status, 202);
    assert.equal((await releaseResponse.json()).action, 'release_non_winning_authorizations');
  } finally {
    await app.close();
  }

  assert.deepEqual(calls, [
    ['createTradeTask', 'inquiry_quote', 'idem-create'],
    ['authInit', 'task-1', 'bid-1', 'auth-1'],
    ['summary', 'task-1'],
    ['releaseNonWinning', 'task-1'],
  ]);
});

test('P0-Pay service forwards Server paths, trims command payload, and keeps idempotency as carrier only', async () => {
  const calls = [];
  const service = createService({
    async post(pathName, body, options) {
      calls.push({ pathName, body, headers: options.headers });
      assert.equal(
        pathName,
        '/server/exhibition/trade-tasks/task-1/fixed-price-bids/bid-1/service-fee-authorizations',
      );
      assert.deepEqual(body, {
        expectedQuotedAmount: '80000',
        expectedFeeRate: '0.025',
        expectedAuthorizationAmount: '2000',
        currency: 'CNY',
        idempotencyKey: 'idem-auth',
      });
      assert.equal(options.headers['x-idempotency-key'], 'idem-auth');
      return {
        authorization: {
          authorizationId: 'auth-1',
          status: 'pending_authorization',
          quotedAmount: '80000.00',
          feeRate: '0.025000',
          feeRateLabel: '标准会员 2.5%',
          feeRateSource: 'paid_membership_tier',
          membershipTierSnapshot: 'standard',
          feeRateRuleVersion: 'p0_pay_membership_service_fee_v1',
          feeRateSnapshotHash: 'snapshot-hash',
          feeCalculatedAt: '2026-05-10T09:59:00.000Z',
          estimatedFeeAmount: '2000.00',
          currency: 'CNY',
          updatedAt: '2026-05-10T10:00:00.000Z',
        },
        channelCandidates: ['alipay_candidate', 'wechat_candidate'],
        internalAuditId: 'hidden',
      };
    },
  });

  const result = await service.createServiceFeeAuthorization(
    'task-1',
    'bid-1',
    {
      expectedQuotedAmount: 80000,
      expectedFeeRate: '0.025',
      expectedAuthorizationAmount: '2000',
      currency: 'CNY',
      idempotencyKey: 'idem-auth',
      objectKey: 'must-not-forward',
      walletId: 'must-not-forward',
    },
    {},
  );

  assert.deepEqual(result, {
    authorizationId: 'auth-1',
    authorizationStatus: 'pending_authorization',
    quotedAmount: '80000.00',
    feeRate: '0.025000',
    feeRateLabel: '标准会员 2.5%',
    feeRateSource: 'paid_membership_tier',
    membershipTierSnapshot: 'standard',
    feeRateRuleVersion: 'p0_pay_membership_service_fee_v1',
    feeRateSnapshotHash: 'snapshot-hash',
    feeCalculatedAt: '2026-05-10T09:59:00.000Z',
    estimatedFeeAmount: '2000.00',
    currency: 'CNY',
    channelCandidates: ['alipay_candidate', 'wechat_candidate'],
    expiresAt: null,
    updatedAt: '2026-05-10T10:00:00.000Z',
  });
  assert.equal(calls.length, 1);
});

test('P0-Pay BFF read model projects Server fee snapshots without calculating fee rate', async () => {
  const service = createService({
    async post(pathName) {
      assert.equal(pathName, '/server/exhibition/trade-tasks/task-1/contract-confirmations');
      return {
        contractConfirmationId: 'contract-1',
        contractStatus: 'confirmed',
        finalConfirmedAmount: '90000.00',
        platformServiceFeeFinalAmount: '2250.00',
        platformServiceFeeStatus: 'charged',
        platformServiceFeeCharge: {
          finalConfirmedAmount: '90000.00',
          feeRate: '0.025000',
          feeRateLabel: '标准会员 2.5%',
          feeRateSource: 'paid_membership_tier',
          membershipTierSnapshot: 'standard',
          feeRateRuleVersion: 'p0_pay_membership_service_fee_v1',
          feeRateSnapshotHash: 'snapshot-hash',
          feeCalculatedAt: '2026-05-10T09:59:00.000Z',
          finalFeeAmount: '2250.00',
          currency: 'CNY',
          chargeStatus: 'charged',
        },
        nextAction: 'enter_fulfillment',
        updatedAt: '2026-05-10T10:00:00.000Z',
        serverInternalFeeDebug: 'must-not-forward',
      };
    },
  });

  const result = await service.createContractConfirmation(
    'task-1',
    {
      selectedBidId: 'bid-1',
      finalConfirmedAmount: '90000.00',
      currency: 'CNY',
      contractFileAssetIds: [],
      confirmationRole: 'factory',
      platformServiceFeeRecalculationAwarenessConfirmed: true,
      idempotencyKey: 'idem-contract',
    },
    {},
  );

  assert.equal(result.platformServiceFeeCharge.feeRate, '0.025000');
  assert.equal(result.platformServiceFeeCharge.membershipTierSnapshot, 'standard');
  assert.equal(result.serverInternalFeeDebug, undefined);
});

test('P0-Pay app routes resolve to controlled 400 or 401 instead of Nest route 404', async () => {
  const app = await createRealRouteApp({
    async get() {
      throw new Error('GET should fail at BFF auth gate without reaching Server.');
    },
    async post() {
      throw new Error('POST should fail at BFF payload gate without reaching Server.');
    },
  });

  try {
    const url = await app.getUrl();
    for (const route of p0PayPostRoutes) {
      const response = await fetch(`${url}${route}`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({}),
      });
      const body = await response.json();
      assert.equal(response.status, 400, route);
      assert.equal(body.code, 'P0_PAY_REQUEST_INVALID', route);
      assert.equal(body.source, 'bff', route);
    }

    for (const route of p0PayGetRoutes) {
      const response = await fetch(`${url}${route}`);
      const body = await response.json();
      assert.equal(response.status, 401, route);
      assert.equal(body.code, 'AUTH_SESSION_INVALID', route);
      assert.equal(body.source, 'bff', route);
    }
  } finally {
    await app.close();
  }
});

test('P0-Pay idempotent command conflicts are normalized to controlled 409', async () => {
  const app = await createRealRouteApp({
    async post(pathName, body, options) {
      assert.equal(pathName, '/server/exhibition/trade-tasks');
      assert.equal(body.idempotencyKey, 'idem-conflict');
      assert.equal(options.headers['x-idempotency-key'], 'idem-conflict');
      throw createAxiosResponseError(409, {
        statusCode: 409,
        message: 'Idempotency key conflicts with a different request payload.',
        source: 'server',
      });
    },
  });

  try {
    const response = await fetch(`${await app.getUrl()}/api/app/exhibition/trade-tasks`, {
      method: 'POST',
      headers: {
        authorization: 'Bearer token',
        'content-type': 'application/json',
        'x-idempotency-key': 'idem-conflict',
      },
      body: JSON.stringify({
        taskType: 'fixed_price_bid',
        projectName: 'Probe project',
        cityCode: '310000',
        projectType: 'booth',
        exhibitionName: 'Probe expo',
        area: 36,
        buildStartAt: '2026-06-01T00:00:00.000Z',
        dismantleAt: '2026-06-05T00:00:00.000Z',
        requirementDescription: 'Probe only',
        budgetAmount: '10000',
        budgetRange: '10000-20000',
        quoteDeadlineAt: '2026-05-20T00:00:00.000Z',
        contactId: 'contact-1',
        authenticityMaterialFileAssetIds: ['file-1'],
        authenticityDeclarations: {
          demandExistsConfirmed: true,
          authorizationConfirmed: true,
          noQuoteHarvestingConfirmed: true,
          resultProcessingConfirmed: true,
          creditImpactAcknowledged: true,
        },
      }),
    });
    const body = await response.json();
    assert.equal(response.status, 409);
    assert.equal(body.code, 'IDEMPOTENCY_KEY_CONFLICT');
    assert.equal(body.source, 'server');
  } finally {
    await app.close();
  }
});

test('P0-Pay summary is read-only for task detail and message-building display', async () => {
  const service = createService({
    async get(pathName) {
      assert.equal(pathName, '/server/exhibition/trade-tasks/task-1/p0-pay-summary');
      return {
        taskId: 'task-1',
        taskType: 'fixed_price_bid',
        platformServiceFee: {
          status: 'authorized',
          feeRate: '0.025000',
          feeRateLabel: '标准会员 2.5%',
          feeRateSource: 'paid_membership_tier',
          membershipTierSnapshot: 'standard',
          feeRateRuleVersion: 'p0_pay_membership_service_fee_v1',
          feeRateSnapshotHash: 'snapshot-hash',
          feeCalculatedAt: '2026-05-10T09:59:00.000Z',
        },
        inquiryDeposit: null,
        contractConfirmation: { status: 'pending' },
        messageDisplaySummary: {
          displayAllowed: true,
          readOnly: false,
          statusTextKey: 'service_fee_authorized',
          routeTarget: { objectType: 'trade_task', taskId: 'task-1' },
          payNowAction: { forbidden: true },
        },
        updatedAt: '2026-05-11T10:00:00.000Z',
      };
    },
  });

  const result = await service.getP0PaySummary('task-1', {});
  assert.deepEqual(result.messageDisplaySummary, {
    displayAllowed: true,
    readOnly: true,
    statusTextKey: 'service_fee_authorized',
    routeTarget: { objectType: 'trade_task', taskId: 'task-1' },
  });
  assert.equal(result.platformServiceFee.feeRate, '0.025000');
  assert.equal(result.platformServiceFee.membershipTierSnapshot, 'standard');
});

test('P0-Pay state actions forward as controlled BFF operations', async () => {
  const calls = [];
  const service = createService({
    async post(pathName, body, options) {
      calls.push({ pathName, body, headers: options.headers });
      if (pathName.endsWith('/release-non-winning')) {
        return {
          action: 'release_non_winning_authorizations',
          changed: 2,
          authorizationIds: ['auth-1', 'auth-2'],
          updatedAt: '2026-05-17T10:00:00.000Z',
        };
      }
      if (pathName.endsWith('/publisher-breach-release')) {
        return {
          action: 'publisher_breach_release',
          changed: 1,
          authorizationIds: ['auth-3'],
          bidId: 'bid-breach',
          updatedAt: '2026-05-18T10:00:00.000Z',
        };
      }
      if (pathName.endsWith('/factory-refusal-breach-hold')) {
        return {
          action: 'factory_refusal_breach_hold',
          changed: 1,
          authorizationIds: ['auth-4'],
          bidId: 'bid-refusal',
          updatedAt: '2026-05-18T11:00:00.000Z',
        };
      }
      throw new Error(`Unexpected state action path: ${pathName}`);
    },
  });

  const releaseResult = await service.releaseNonWinning(
    'task-1',
    { winningBidId: 'bid-winner', idempotencyKey: 'idem-release', walletId: 'must-not-forward' },
    {},
  );
  const publisherBreachResult = await service.releasePublisherBreach(
    'task-1',
    {
      bidId: 'bid-breach',
      reasonCode: 'publisher_cancelled_after_award',
      reasonText: ' Publisher changed scope after selecting factory. ',
      idempotencyKey: 'idem-publisher-breach',
      walletId: 'must-not-forward',
    },
    {},
  );
  const refusalResult = await service.holdFactoryRefusal(
    'task-1',
    {
      bidId: 'bid-refusal',
      reasonCode: 'factory_refused_contract_confirmation',
      reasonText: ' Factory refused to sign after award. ',
      idempotencyKey: 'idem-refusal-hold',
      paymentAccountId: 'must-not-forward',
    },
    {},
  );

  assert.deepEqual(releaseResult, {
    action: 'release_non_winning_authorizations',
    changed: 2,
    authorizationIds: ['auth-1', 'auth-2'],
    bidId: undefined,
    updatedAt: '2026-05-17T10:00:00.000Z',
  });
  assert.deepEqual(publisherBreachResult, {
    action: 'publisher_breach_release',
    changed: 1,
    authorizationIds: ['auth-3'],
    bidId: 'bid-breach',
    updatedAt: '2026-05-18T10:00:00.000Z',
  });
  assert.deepEqual(refusalResult, {
    action: 'factory_refusal_breach_hold',
    changed: 1,
    authorizationIds: ['auth-4'],
    bidId: 'bid-refusal',
    updatedAt: '2026-05-18T11:00:00.000Z',
  });
  assert.deepEqual(calls, [
    {
      pathName: '/server/exhibition/trade-tasks/task-1/p0-pay-actions/release-non-winning',
      body: { winningBidId: 'bid-winner', idempotencyKey: 'idem-release' },
      headers: {
        authorization: 'Bearer token',
        'x-organization-id': 'org-1',
        'x-actor-role': 'publisher',
        'x-idempotency-key': 'idem-release',
      },
    },
    {
      pathName: '/server/exhibition/trade-tasks/task-1/p0-pay-actions/publisher-breach-release',
      body: {
        bidId: 'bid-breach',
        reasonCode: 'publisher_cancelled_after_award',
        reasonText: 'Publisher changed scope after selecting factory.',
        idempotencyKey: 'idem-publisher-breach',
      },
      headers: {
        authorization: 'Bearer token',
        'x-organization-id': 'org-1',
        'x-actor-role': 'publisher',
        'x-idempotency-key': 'idem-publisher-breach',
      },
    },
    {
      pathName: '/server/exhibition/trade-tasks/task-1/p0-pay-actions/factory-refusal-breach-hold',
      body: {
        bidId: 'bid-refusal',
        reasonCode: 'factory_refused_contract_confirmation',
        reasonText: 'Factory refused to sign after award.',
        idempotencyKey: 'idem-refusal-hold',
      },
      headers: {
        authorization: 'Bearer token',
        'x-organization-id': 'org-1',
        'x-actor-role': 'publisher',
        'x-idempotency-key': 'idem-refusal-hold',
      },
    },
  ]);
});

test('P0-Pay service maps upstream route drift to controlled BFF error without empty success', async () => {
  const service = createService({
    async get() {
      throw createAxiosResponseError(404, {
        statusCode: 404,
        message: 'Cannot GET /server/exhibition/trade-tasks/task-1/p0-pay-summary',
        source: 'server',
      });
    },
  });

  await assert.rejects(
    () => service.getP0PaySummary('task-1', {}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.deepEqual(error.getResponse(), {
        statusCode: 404,
        code: 'P0_PAY_SUMMARY_UNAVAILABLE',
        message: '当前交易资金状态暂不可用，请稍后再试。',
        source: 'server',
      });
      return true;
    },
  );
});
