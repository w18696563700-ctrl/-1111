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
  AppProjectPricingController,
} = require('../src/routes/exhibition_p0_pay/app-project-pricing.controller.ts');
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

const projectPricingPostRoutes = [
  '/api/app/project/project-1/authenticity-sincerity/orders',
  '/api/app/project/project-1/authenticity-sincerity/orders/order-1/pay-init',
  '/api/app/project/project-1/authenticity-sincerity/freeze-feedback',
  '/api/app/project/project-1/authenticity-sincerity/orders/order-1/refund-init',
  '/api/app/project/project-1/bid-service-fee-authorizations',
  '/api/app/project/project-1/bid-service-fee-authorizations/auth-1/freeze-init',
  '/api/app/project/project-1/bid-service-fee-authorizations/auth-1/release',
  '/api/app/project/project-1/deal-confirmations',
];

const p0PayGetRoutes = [
  '/api/app/exhibition/trade-tasks/task-1',
  '/api/app/exhibition/trade-tasks/task-1/fixed-price-bids/bid-1/service-fee-authorizations/auth-1',
  '/api/app/exhibition/trade-tasks/task-1/inquiry-deposit/orders/deposit-1',
  '/api/app/exhibition/trade-tasks/task-1/p0-pay-summary',
];

const projectPricingGetRoutes = [
  '/api/app/project/project-1/pricing-summary',
  '/api/app/project/project-1/authenticity-sincerity/orders/order-1',
  '/api/app/project/project-1/authenticity-sincerity/orders/order-1/refund',
  '/api/app/project/project-1/bid-service-fee-authorizations/auth-1',
  '/api/app/project/project-1/deal-confirmations/deal-1',
  '/api/app/project/project-1/settlement/summary',
  '/api/app/project/project-1/settlement/reconciliation',
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
    controllers: [AppExhibitionP0PayController, AppProjectPricingController],
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

test('pricing app-facing routes expose project family and keep legacy trade-task aliases bounded', async () => {
  const calls = [];
  const service = {
    createTradeTask(payload, headers, idempotencyKey) {
      calls.push(['createTradeTask', payload.taskType, idempotencyKey ?? null]);
      return { taskId: 'task-1', taskType: payload.taskType };
    },
    getTradeTaskDetail(taskId) {
      calls.push(['detail', taskId]);
      return { taskId, pricingSummary: { readOnly: true } };
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
      calls.push(['legacySummary', taskId]);
      return {
        projectId: taskId,
        readOnly: true,
      };
    },
    getProjectPricingSummary(projectId) {
      calls.push(['pricingSummary', projectId]);
      return {
        projectId,
        readOnly: true,
      };
    },
    createProjectAuthenticitySincerityOrder(projectId) {
      calls.push(['sincerityCreate', projectId]);
      return { orderId: 'order-1' };
    },
    initProjectAuthenticitySincerityPayment(projectId, orderId) {
      calls.push(['sincerityPay', projectId, orderId]);
      return { orderId };
    },
    getProjectAuthenticitySincerityOrder(projectId, orderId) {
      calls.push(['sincerityStatus', projectId, orderId]);
      return {
        orderId,
        orderStatus: 'paid',
      };
    },
    submitProjectAuthenticitySincerityFreezeFeedback(projectId) {
      calls.push(['sincerityFeedback', projectId]);
      return {
        projectId,
        myChoice: 'support_freeze',
        supportFreezeCount: 1,
        opposeFreezeCount: 0,
      };
    },
    initProjectAuthenticitySincerityRefund(projectId, orderId) {
      calls.push(['sincerityRefund', projectId, orderId]);
      return {
        orderId,
        refundStatus: 'refund_pending',
      };
    },
    getProjectAuthenticitySincerityRefund(projectId, orderId) {
      calls.push(['sincerityRefundStatus', projectId, orderId]);
      return {
        orderId,
        refundStatus: 'refund_pending',
      };
    },
    createBidServiceFeeAuthorization(projectId) {
      calls.push(['bidAuthCreate', projectId]);
      return { authorizationId: 'auth-1' };
    },
    initBidServiceFeeAuthorizationFreeze(projectId, authorizationId) {
      calls.push(['bidAuthFreeze', projectId, authorizationId]);
      return { authorizationId };
    },
    getBidServiceFeeAuthorization(projectId, authorizationId) {
      calls.push(['bidAuthStatus', projectId, authorizationId]);
      return { authorizationId, authorizationStatus: 'frozen' };
    },
    releaseBidServiceFeeAuthorization(projectId, authorizationId) {
      calls.push(['bidAuthRelease', projectId, authorizationId]);
      return { authorizationId, authorizationStatus: 'released' };
    },
    createDealConfirmation(projectId) {
      calls.push(['dealCreate', projectId]);
      return { dealConfirmationId: 'deal-1' };
    },
    getDealConfirmation(projectId, dealConfirmationId) {
      calls.push(['dealDetail', projectId, dealConfirmationId]);
      return { dealConfirmationId, dealStatus: 'confirmed_deal' };
    },
    getProjectSettlementSummary(projectId) {
      calls.push(['settlementSummary', projectId]);
      return { projectId, settlementSummary: { settlementStatus: 'draft' } };
    },
    createProjectSettlementBatchDraft(projectId) {
      calls.push(['settlementBatchDraft', projectId]);
      return { projectId, batchDraft: { status: 'draft' } };
    },
    getProjectSettlementReconciliation(projectId) {
      calls.push(['settlementReconciliation', projectId]);
      return { projectId, reconciliationSummary: { status: 'balanced' } };
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
    controllers: [AppExhibitionP0PayController, AppProjectPricingController],
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
      Reflect.getMetadata(PATH_METADATA, AppProjectPricingController),
      'api/app/project',
    );
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, AppProjectPricingController.prototype.getProjectPricingSummary),
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
      `${url}/api/app/project/project-1/pricing-summary`,
    );
    assert.equal(summaryResponse.status, 200);
    assert.equal((await summaryResponse.json()).readOnly, true);

    const sincerityResponse = await fetch(
      `${url}/api/app/project/project-1/authenticity-sincerity/orders/order-1`,
    );
    assert.equal(sincerityResponse.status, 200);
    assert.equal((await sincerityResponse.json()).orderStatus, 'paid');

    const feedbackResponse = await fetch(
      `${url}/api/app/project/project-1/authenticity-sincerity/freeze-feedback`,
      {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ choice: 'support_freeze' }),
      },
    );
    assert.equal(feedbackResponse.status, 202);
    assert.equal((await feedbackResponse.json()).supportFreezeCount, 1);

    const refundResponse = await fetch(
      `${url}/api/app/project/project-1/authenticity-sincerity/orders/order-1/refund-init`,
      { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({}) },
    );
    assert.equal(refundResponse.status, 202);
    assert.equal((await refundResponse.json()).refundStatus, 'refund_pending');

    const bidAuthorizationResponse = await fetch(
      `${url}/api/app/project/project-1/bid-service-fee-authorizations`,
      { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({}) },
    );
    assert.equal(bidAuthorizationResponse.status, 202);
    assert.equal((await bidAuthorizationResponse.json()).authorizationId, 'auth-1');

    const dealResponse = await fetch(
      `${url}/api/app/project/project-1/deal-confirmations/deal-1`,
    );
    assert.equal(dealResponse.status, 200);
    assert.equal((await dealResponse.json()).dealStatus, 'confirmed_deal');

    const settlementResponse = await fetch(
      `${url}/api/app/project/project-1/settlement/summary`,
    );
    assert.equal(settlementResponse.status, 200);
    assert.equal((await settlementResponse.json()).settlementSummary.settlementStatus, 'draft');

    const batchDraftResponse = await fetch(
      `${url}/api/app/project/project-1/settlement/batch-draft`,
      { method: 'POST' },
    );
    assert.equal(batchDraftResponse.status, 202);
    assert.equal((await batchDraftResponse.json()).batchDraft.status, 'draft');

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
    ['pricingSummary', 'project-1'],
    ['sincerityStatus', 'project-1', 'order-1'],
    ['sincerityFeedback', 'project-1'],
    ['sincerityRefund', 'project-1', 'order-1'],
    ['bidAuthCreate', 'project-1'],
    ['dealDetail', 'project-1', 'deal-1'],
    ['settlementSummary', 'project-1'],
    ['settlementBatchDraft', 'project-1'],
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
        expectedFeeRate: '0.030',
        expectedAuthorizationAmount: '4000',
        currency: 'CNY',
        idempotencyKey: 'idem-auth',
      });
      assert.equal(options.headers['x-idempotency-key'], 'idem-auth');
      return {
        authorization: {
          authorizationId: 'auth-1',
          status: 'pending_authorization',
          quotedAmount: '80000.00',
          feeRate: '0.030000',
          feeRateLabel: '标准会员 9折（作用于 baseFeeAmount）',
          feeRateSource: 'paid_membership_tier',
          membershipTierSnapshot: 'standard',
          baseFeeAmount: '1350.00',
          membershipDiscountRate: '0.9000',
          capAmount: '3600.00',
          estimatedFeeAmount: '1215.00',
          feeRateRuleVersion: 'p0_pay_membership_service_fee_v1',
          feeRateSnapshotHash: 'snapshot-hash',
          feeCalculatedAt: '2026-05-10T09:59:00.000Z',
          authorizationQuotaAmount: '4000.00',
          quotaAmount: '4000.00',
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
      expectedFeeRate: '0.030',
      expectedAuthorizationAmount: '4000',
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
    estimatedFeeAmount: '1215.00',
    feeRate: '0.030000',
    feeRateLabel: '标准会员 9折（作用于 baseFeeAmount）',
    feeRateSource: 'paid_membership_tier',
    membershipTierSnapshot: 'standard',
    baseFeeAmount: '1350.00',
    membershipDiscountRate: '0.9000',
    capAmount: '3600.00',
    finalFeeAmount: undefined,
    feeRateRuleVersion: 'p0_pay_membership_service_fee_v1',
    feeRateSnapshotHash: 'snapshot-hash',
    feeCalculatedAt: '2026-05-10T09:59:00.000Z',
    authorizationQuotaAmount: '4000.00',
    quotaAmount: '4000.00',
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
          feeRate: '0.030000',
          feeRateLabel: '标准会员 9折（作用于 baseFeeAmount）',
          feeRateSource: 'paid_membership_tier',
          membershipTierSnapshot: 'standard',
          baseFeeAmount: '2500.00',
          membershipDiscountRate: '0.9000',
          capAmount: '3600.00',
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

  assert.equal(result.platformServiceFeeCharge.feeRate, '0.030000');
  assert.equal(result.platformServiceFeeCharge.membershipDiscountRate, '0.9000');
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

    for (const route of projectPricingPostRoutes) {
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

    for (const route of [...p0PayGetRoutes, ...projectPricingGetRoutes]) {
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

test('pricing summary is read-only and no longer exposes old P0-Pay authority shape', async () => {
  const service = createService({
    async get(pathName) {
      assert.equal(pathName, '/server/projects/task-1/pricing-summary');
      return {
        projectId: 'task-1',
        pricingRuleVersion: 'platform_pricing_rules_master_v1',
        projectAuthenticitySincerity: {
          orderId: 'sincerity-task-1',
          status: 'paid',
          amount: '200.00',
          currency: 'CNY',
          channelCandidates: ['alipay_candidate'],
        },
        bidServiceFeeAuthorization: {
          status: 'frozen',
          quotaAmount: '4000.00',
        },
        dealConfirmation: { status: 'not_confirmed' },
        messageDisplaySummary: {
          displayAllowed: true,
          readOnly: false,
          statusTextKey: 'frozen',
          routeTarget: {
            objectType: 'project_pricing',
            actionKey: 'pricing_summary.read',
            canonicalPath: '/api/app/project/task-1/pricing-summary',
            params: { projectId: 'task-1' },
          },
          payNowAction: { forbidden: true },
        },
        updatedAt: '2026-05-11T10:00:00.000Z',
      };
    },
  });

  const result = await service.getP0PaySummary('task-1', {});
  assert.deepEqual(result, {
    projectId: 'task-1',
    publisherPricing: {
      authenticitySincerityRequired: true,
      authenticitySincerityAmount: '200.00',
      authenticitySincerityStatus: 'paid',
      authenticitySincerityOrderId: 'sincerity-task-1',
      authenticitySincerityCurrency: 'CNY',
      authenticitySincerityChannelCandidates: ['alipay_candidate'],
      authenticitySincerityExpiresAt: null,
      publishGateStatus: 'satisfied',
      formalResultProcessingRequired: true,
      nextAction: {
        actionKey: 'pricing_summary.read',
        routeTarget: {
          objectType: 'project_pricing',
          actionKey: 'pricing_summary.read',
          canonicalPath: '/api/app/project/task-1/pricing-summary',
          params: { projectId: 'task-1' },
        },
      },
    },
    bidderPricing: {
      bidParticipationRequestId: null,
      authorizationRequired: true,
      authorizationQuotaAmount: '4000.00',
      authorizationStatus: 'frozen',
      bidSubmissionEligible: true,
      nextAction: {
        actionKey: 'pricing_summary.read',
        routeTarget: {
          objectType: 'project_pricing',
          actionKey: 'pricing_summary.read',
          canonicalPath: '/api/app/project/task-1/pricing-summary',
          params: { projectId: 'task-1' },
        },
      },
    },
    dealSummary: {
      dealConfirmationId: null,
      dealStatus: 'not_confirmed',
      selectedBidId: null,
      finalConfirmedAmount: null,
      platformServiceFeeAmount: null,
      serviceFeeChargeStatus: null,
    },
    updatedAt: '2026-05-11T10:00:00.000Z',
    readOnly: true,
  });
  assert.equal(result.platformServiceFee, undefined);
  assert.equal(result.inquiryDeposit, undefined);
});

test('project pricing canonical routes forward 4000 authorization, sincerity feedback and deal confirmation without local fee truth', async () => {
  const calls = [];
  const service = createService({
    async post(pathName, body, options) {
      calls.push({ method: 'POST', pathName, body, headers: options.headers });
      if (pathName.endsWith('/authenticity-sincerity/orders')) {
        assert.deepEqual(body, {
          expectedAmount: '200',
          expectedCurrency: 'CNY',
          ruleVersion: 'project_authenticity_sincerity_v1',
          ruleSnapshotHash: 'hash-sincerity',
          idempotencyKey: 'idem-sincerity',
        });
        return {
          orderId: 'sincerity-1',
          orderStatus: 'pending_payment',
          amount: '200.00',
          currency: 'CNY',
          updatedAt: '2026-06-01T09:59:00.000Z',
        };
      }
      if (pathName.endsWith('/authenticity-sincerity/orders/sincerity-1/pay-init')) {
        assert.deepEqual(body, {
          payChannel: 'alipay_candidate',
          clientPlatform: 'flutter',
          idempotencyKey: 'idem-sincerity-pay',
        });
        return {
          paymentInitStatus: 'pending_user_confirm',
          orderId: 'sincerity-1',
          paymentReferenceId: 'P0PAY_DEP_1',
          channelActionType: 'unavailable',
          callbackAwaiting: true,
          updatedAt: '2026-06-01T09:59:30.000Z',
        };
      }
      if (pathName.endsWith('/authenticity-sincerity/freeze-feedback')) {
        assert.deepEqual(body, { choice: 'support_freeze' });
        return {
          projectId: 'project-1',
          myChoice: 'support_freeze',
          supportFreezeCount: 4,
          opposeFreezeCount: 2,
          updatedAt: '2026-06-01T09:59:40.000Z',
        };
      }
      if (pathName.endsWith('/bid-service-fee-authorizations')) {
        assert.deepEqual(body, {
          bidParticipationRequestId: 'request-1',
          expectedAmount: '4000',
          expectedCurrency: 'CNY',
          ruleVersion: 'platform_pricing_rules_master_v1',
          ruleSnapshotHash: 'hash-1',
          idempotencyKey: 'idem-auth',
        });
        return {
          authorizationId: 'auth-1',
          authorizationStatus: 'pending_freeze',
          authorizationQuotaAmount: '4000.00',
          currency: 'CNY',
          channelCandidates: ['alipay_candidate'],
          updatedAt: '2026-06-01T10:00:00.000Z',
        };
      }
      if (pathName.endsWith('/freeze-init')) {
        return {
          freezeInitStatus: 'pending_user_confirm',
          authorizationId: 'auth-1',
          paymentReferenceId: 'P0PAY_AUTH_1',
          channelActionType: 'sdk_payload',
          channelPayload: { opaque: true },
          callbackAwaiting: true,
          updatedAt: '2026-06-01T10:01:00.000Z',
        };
      }
      if (pathName.endsWith('/release')) {
        return {
          authorizationId: 'auth-1',
          authorizationStatus: 'released',
          bidSubmissionEligible: false,
          updatedAt: '2026-06-01T10:02:00.000Z',
        };
      }
      if (pathName.endsWith('/refund-init')) {
        assert.deepEqual(body, {
          refundReasonCode: 'publisher_cancelled',
          refundReasonText: '发布方取消项目。',
          idempotencyKey: 'idem-refund',
        });
        return {
          orderId: 'sincerity-1',
          refundOrderId: 'refund-1',
          refundStatus: 'refund_pending',
          amount: '200.00',
          currency: 'CNY',
          updatedAt: '2026-06-01T10:02:30.000Z',
        };
      }
      if (pathName.endsWith('/settlement/batch-draft')) {
        return {
          projectId: 'project-1',
          settlementSummary: {
            settlementStatus: 'draft',
            platformIncomeAmount: '675.00',
          },
          batchDraft: { status: 'draft', autoPayoutEnabled: false },
          updatedAt: '2026-06-01T10:05:00.000Z',
        };
      }
      if (pathName.endsWith('/deal-confirmations')) {
        return {
          dealConfirmationId: 'deal-1',
          dealStatus: 'confirmed_deal',
          selectedBidId: 'bid-1',
          finalConfirmedAmount: '40000.00',
          platformServiceFeeCalculation: {
            ruleVersion: 'platform_pricing_rules_master_v1',
            baseFeeAmount: '750.00',
            finalFeeAmount: '675.00',
          },
          serviceFeeChargeStatus: 'charged',
          updatedAt: '2026-06-01T10:03:00.000Z',
        };
      }
      throw new Error(`Unexpected post path ${pathName}`);
    },
    async get(pathName, options) {
      calls.push({ method: 'GET', pathName, headers: options.headers });
      if (pathName.includes('/bid-service-fee-authorizations/')) {
        return {
          authorizationId: 'auth-1',
          authorizationStatus: 'frozen',
          authorizationQuotaAmount: '4000.00',
          currency: 'CNY',
          chargeStatus: 'not_charged',
          releaseStatus: 'not_released',
          updatedAt: '2026-06-01T10:04:00.000Z',
        };
      }
      if (pathName.endsWith('/inquiry-deposit/orders/sincerity-1/refund')) {
        return {
          orderId: 'sincerity-1',
          refundStatus: 'refund_pending',
          amount: '200.00',
          currency: 'CNY',
          updatedAt: '2026-06-01T10:04:30.000Z',
        };
      }
      if (pathName.endsWith('/settlement/summary')) {
        return {
          projectId: 'project-1',
          settlementSummary: {
            settlementStatus: 'draft',
            platformIncomeAmount: '675.00',
            pendingSettlementAmount: '675.00',
            autoPayoutEnabled: false,
          },
          charges: [],
          updatedAt: '2026-06-01T10:06:00.000Z',
        };
      }
      if (pathName.endsWith('/settlement/reconciliation')) {
        return {
          projectId: 'project-1',
          reconciliationSummary: {
            status: 'balanced',
            differenceAmount: '0.00',
          },
          updatedAt: '2026-06-01T10:07:00.000Z',
        };
      }
      return {
        dealConfirmationId: 'deal-1',
        dealStatus: 'confirmed_deal',
        selectedBidId: 'bid-1',
        finalConfirmedAmount: '40000.00',
        platformServiceFeeCalculation: { finalFeeAmount: '675.00' },
        serviceFeeChargeStatus: 'charged',
        publisherConfirmedAt: null,
        factoryConfirmedAt: null,
        publisherAuthenticitySincerityStatus: 'refunded',
        updatedAt: '2026-06-01T10:05:00.000Z',
      };
    },
  });

  const created = await service.createBidServiceFeeAuthorization(
    'project-1',
    {
      bidParticipationRequestId: 'request-1',
      expectedAmount: 4000,
      expectedCurrency: 'CNY',
      ruleVersion: 'platform_pricing_rules_master_v1',
      ruleSnapshotHash: 'hash-1',
      idempotencyKey: 'idem-auth',
      estimatedFeeAmount: 'must-not-forward',
    },
    {},
  );
  const sincerity = await service.createProjectAuthenticitySincerityOrder(
    'project-1',
    {
      expectedAmount: 200,
      expectedCurrency: 'CNY',
      ruleVersion: 'project_authenticity_sincerity_v1',
      ruleSnapshotHash: 'hash-sincerity',
      idempotencyKey: 'idem-sincerity',
    },
    {},
  );
  const sincerityPay = await service.initProjectAuthenticitySincerityPayment(
    'project-1',
    'sincerity-1',
    { payChannel: 'alipay_candidate', clientPlatform: 'flutter', idempotencyKey: 'idem-sincerity-pay' },
    {},
  );
  const feedback = await service.submitProjectAuthenticitySincerityFreezeFeedback(
    'project-1',
    { choice: 'support_freeze' },
    {},
  );
  const freeze = await service.initBidServiceFeeAuthorizationFreeze(
    'project-1',
    'auth-1',
    { payChannel: 'alipay_candidate', clientPlatform: 'flutter', idempotencyKey: 'idem-freeze' },
    {},
  );
  const status = await service.getBidServiceFeeAuthorization('project-1', 'auth-1', {});
  const released = await service.releaseBidServiceFeeAuthorization(
    'project-1',
    'auth-1',
    {
      releaseReasonCode: 'bidder_withdraw',
      releaseReasonText: '主动退出竞标',
      idempotencyKey: 'idem-release',
    },
    {},
  );
  const refund = await service.initProjectAuthenticitySincerityRefund(
    'project-1',
    'sincerity-1',
    {
      refundReasonCode: 'publisher_cancelled',
      refundReasonText: '发布方取消项目。',
      idempotencyKey: 'idem-refund',
    },
    {},
  );
  const refundStatus = await service.getProjectAuthenticitySincerityRefund(
    'project-1',
    'sincerity-1',
    {},
  );
  const deal = await service.createDealConfirmation(
    'project-1',
    {
      selectedBidId: 'bid-1',
      finalConfirmedAmount: '40000.00',
      currency: 'CNY',
      contractFileAssetIds: ['file-1'],
      confirmationRole: 'publisher',
      idempotencyKey: 'idem-deal',
    },
    {},
  );
  const detail = await service.getDealConfirmation('project-1', 'deal-1', {});
  const settlement = await service.getProjectSettlementSummary('project-1', {});
  const settlementDraft = await service.createProjectSettlementBatchDraft('project-1', {});
  const reconciliation = await service.getProjectSettlementReconciliation('project-1', {});

  assert.equal(created.authorizationQuotaAmount, '4000.00');
  assert.equal(sincerity.orderStatus, 'pending_payment');
  assert.equal(sincerityPay.channelActionType, 'unavailable');
  assert.equal(feedback.supportFreezeCount, 4);
  assert.equal(freeze.freezeInitStatus, 'pending_user_confirm');
  assert.equal(status.authorizationStatus, 'frozen');
  assert.equal(released.bidSubmissionEligible, false);
  assert.equal(refund.refundStatus, 'refund_pending');
  assert.equal(refundStatus.refundStatus, 'refund_pending');
  assert.equal(deal.platformServiceFeeCalculation.finalFeeAmount, '675.00');
  assert.equal(detail.publisherAuthenticitySincerityStatus, 'refunded');
  assert.equal(settlement.settlementSummary.platformIncomeAmount, '675.00');
  assert.equal(settlementDraft.batchDraft.status, 'draft');
  assert.equal(reconciliation.reconciliationSummary.status, 'balanced');
  assert.deepEqual(calls.map((item) => [item.method, item.pathName]), [
    ['POST', '/server/projects/project-1/bid-service-fee-authorizations'],
    ['POST', '/server/projects/project-1/authenticity-sincerity/orders'],
    ['POST', '/server/projects/project-1/authenticity-sincerity/orders/sincerity-1/pay-init'],
    ['POST', '/server/projects/project-1/authenticity-sincerity/freeze-feedback'],
    ['POST', '/server/projects/project-1/bid-service-fee-authorizations/auth-1/freeze-init'],
    ['GET', '/server/projects/project-1/bid-service-fee-authorizations/auth-1'],
    ['POST', '/server/projects/project-1/bid-service-fee-authorizations/auth-1/release'],
    ['POST', '/server/exhibition/trade-tasks/project-1/inquiry-deposit/orders/sincerity-1/refund-init'],
    ['GET', '/server/exhibition/trade-tasks/project-1/inquiry-deposit/orders/sincerity-1/refund'],
    ['POST', '/server/projects/project-1/deal-confirmations'],
    ['GET', '/server/projects/project-1/deal-confirmations/deal-1'],
    ['GET', '/server/project/project-1/settlement/summary'],
    ['POST', '/server/project/project-1/settlement/batch-draft'],
    ['GET', '/server/project/project-1/settlement/reconciliation'],
  ]);
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
        message: 'Cannot GET /server/project/task-1/pricing-summary',
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
        code: 'PROJECT_PRICING_SUMMARY_UNAVAILABLE',
        message: '当前交易资金状态暂不可用，请稍后再试。',
        source: 'server',
      });
      return true;
    },
  );
});
