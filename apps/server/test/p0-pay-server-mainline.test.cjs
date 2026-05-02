const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { createSign, generateKeyPairSync } = require('node:crypto');

test('P0-Pay migration registers inquiry deposit, internal-test feedback, callback, contract confirmation and charge truth', () => {
  const { p0PayMigrations } = require('../dist/core/migrations/migrations.js');
  const sql = p0PayMigrations.flatMap((item) => item.statements).join('\n');

  assert.ok(p0PayMigrations.some((item) => item.key === '20260604_platform_pricing_sp1_kernel_normalization'));
  assert.ok(p0PayMigrations.some((item) => item.key === '20260606_project_authenticity_sincerity_internal_test_feedback'));
  assert.match(sql, /CREATE TABLE IF NOT EXISTS inquiry_quote_deposits/);
  assert.match(sql, /CREATE TABLE IF NOT EXISTS project_authenticity_sincerity_freeze_feedback/);
  assert.match(sql, /idx_project_auth_sincerity_feedback_user_project/);
  assert.match(sql, /support_freeze/);
  assert.match(sql, /oppose_freeze/);
  assert.match(sql, /amount numeric\(12,2\) NOT NULL DEFAULT 200/);
  assert.match(sql, /CREATE TABLE IF NOT EXISTS payment_callback_events/);
  assert.match(sql, /verification_status/);
  assert.match(sql, /apply_status/);
  assert.match(sql, /CREATE TABLE IF NOT EXISTS contract_confirmations/);
  assert.match(sql, /CREATE TABLE IF NOT EXISTS platform_service_fee_charges/);
  assert.match(sql, /fee_rate_source varchar\(32\)/);
  assert.match(sql, /membership_tier_snapshot varchar\(32\)/);
  assert.match(sql, /fee_rate_rule_version varchar\(64\)/);
  assert.match(sql, /fee_rate_snapshot_hash varchar\(128\)/);
  assert.match(sql, /fee_calculated_at timestamptz/);
  assert.match(sql, /platform_service_fee_charge/);
  assert.match(sql, /withheld_at timestamptz/);
  assert.match(sql, /withhold_reason_code varchar\(96\)/);
  assert.match(sql, /authorization_quota_amount numeric\(12,2\)/);
  assert.match(sql, /charged_amount_used numeric\(12,2\)/);
  assert.match(sql, /released_amount numeric\(12,2\)/);
  assert.match(sql, /frozen_at timestamptz/);
  assert.match(sql, /base_fee_amount numeric\(12,2\)/);
  assert.match(sql, /membership_discount_rate numeric\(8,4\)/);
  assert.match(sql, /cap_amount numeric\(12,2\)/);
  assert.match(sql, /released_remainder_amount numeric\(12,2\)/);
  assert.match(sql, /project_authenticity_sincerity_payment/);
  assert.match(sql, /bid_service_fee_authorization_freeze/);
  assert.match(sql, /pending_freeze/);
  assert.match(sql, /confirmed_deal/);
  assert.match(sql, /idx_platform_service_fee_auth_one_active_project_bidder/);
  assert.doesNotMatch(sql, /DROP TABLE/i);
  assert.doesNotMatch(sql, /DROP COLUMN/i);
  assert.doesNotMatch(sql, /RENAME/i);
  assert.doesNotMatch(sql, /wallet_pending/);
  assert.doesNotMatch(sql, /guarantee_freezing/);
});

test('P0-Pay payment channel supports controlled HMAC callbacks and Alipay APP Pay RSA2 payload', () => {
  const {
    P0PayPaymentChannelService,
  } = require('../dist/modules/p0_pay/p0-pay-payment-channel.service.js');

  process.env.P0_PAY_CALLBACK_SECRET = 'test-secret';
  const service = new P0PayPaymentChannelService();
  const payload = {
    merchantOrderNo: 'P0PAY_DEP_1',
    channelOrderId: 'channel-1',
    providerEventId: 'event-1',
    eventType: 'payment_succeeded',
    eventStatus: 'succeeded',
    amount: '200.00',
    currency: 'CNY',
  };
  const signature = service.signPayload(payload);
  assert.deepEqual(service.verifyCallback(payload, signature, 'other'), {
    verified: true,
    reasonCode: '',
  });
  assert.equal(service.verifyCallback(payload, 'sha256=bad', 'other').verified, false);

  const action = service.buildChannelAction({
    paymentOrderId: 'order-1',
    merchantOrderNo: 'P0PAY_DEP_1',
    amount: '200.00',
    currency: 'CNY',
    channel: 'other',
    clientPlatform: 'flutter',
  });
  assert.equal(action.channelPayload.accountBindingRequired, false);

  const unavailable = service.buildChannelAction({
    paymentOrderId: 'order-1',
    merchantOrderNo: 'P0PAY_DEP_1',
    amount: '200.00',
    currency: 'CNY',
    channel: 'alipay',
    clientPlatform: 'flutter',
  });
  assert.equal(unavailable.channelActionType, 'unavailable');

  const { privateKey, publicKey } = generateKeyPairSync('rsa', {
    modulusLength: 2048,
    publicKeyEncoding: { type: 'spki', format: 'pem' },
    privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
  });
  process.env.P0_PAY_ALIPAY_APP_PAY_ENABLED = 'true';
  process.env.P0_PAY_ALIPAY_APP_ID = '2021000000000000';
  process.env.P0_PAY_ALIPAY_APP_PRIVATE_KEY = privateKey;
  process.env.P0_PAY_ALIPAY_PUBLIC_KEY = publicKey;
  process.env.P0_PAY_ALIPAY_NOTIFY_URL = 'https://example.com/server/exhibition/p0-pay/payment-callbacks/alipay';

  const alipayAction = service.buildChannelAction({
    paymentOrderId: 'order-1',
    merchantOrderNo: 'P0PAY_DEP_1',
    amount: '200.00',
    currency: 'CNY',
    channel: 'alipay',
    clientPlatform: 'android',
  });
  assert.equal(alipayAction.channelActionType, 'sdk_payload');
  assert.match(alipayAction.channelPayload.orderString, /method=alipay\.trade\.app\.pay/);
  assert.match(alipayAction.channelPayload.orderString, /sign=/);

  const alipayCallback = {
    app_id: '2021000000000000',
    out_trade_no: 'P0PAY_DEP_1',
    trade_no: '2026043000000001',
    notify_id: 'notify-1',
    notify_type: 'trade_status_sync',
    trade_status: 'TRADE_SUCCESS',
    total_amount: '200.00',
    charset: 'utf-8',
    sign_type: 'RSA2',
  };
  const signContent = Object.keys(alipayCallback)
    .filter((key) => key !== 'sign' && key !== 'sign_type')
    .sort()
    .map((key) => `${key}=${alipayCallback[key]}`)
    .join('&');
  const alipaySign = createSign('RSA-SHA256').update(signContent, 'utf8').sign(privateKey, 'base64');
  assert.deepEqual(service.verifyCallback({ ...alipayCallback, sign: alipaySign }, '', 'alipay'), {
    verified: true,
    reasonCode: '',
  });
  assert.equal(service.verifyCallback({ ...alipayCallback, sign: 'bad' }, '', 'alipay').verified, false);

  delete process.env.P0_PAY_ALIPAY_APP_PAY_ENABLED;
  delete process.env.P0_PAY_ALIPAY_APP_ID;
  delete process.env.P0_PAY_ALIPAY_APP_PRIVATE_KEY;
  delete process.env.P0_PAY_ALIPAY_PUBLIC_KEY;
  delete process.env.P0_PAY_ALIPAY_NOTIFY_URL;
});

test('P0-Pay server exposes BFF-forwarded trade task routes and controlled state actions', () => {
  const controller = fs.readFileSync(
    path.join(__dirname, '../src/modules/p0_pay/p0-pay.controller.ts'),
    'utf8',
  );
  const stateActions = fs.readFileSync(
    path.join(__dirname, '../src/modules/p0_pay/p0-pay-state-action.service.ts'),
    'utf8',
  );

  [
    "Post('server/exhibition/trade-tasks')",
    "Get('server/exhibition/trade-tasks/:taskId')",
    "Post('server/exhibition/trade-tasks/:taskId/authenticity-materials')",
    "Post('server/exhibition/trade-tasks/:taskId/fixed-price-bids')",
    "Post('server/exhibition/trade-tasks/:taskId/inquiry-quotations')",
    "Post('server/exhibition/trade-tasks/:taskId/inquiry-result')",
    "Post('server/projects/:projectId/authenticity-sincerity/orders')",
    "Post('server/projects/:projectId/authenticity-sincerity/orders/:orderId/pay-init')",
    "Get('server/projects/:projectId/authenticity-sincerity/orders/:orderId')",
    "Post('server/projects/:projectId/authenticity-sincerity/freeze-feedback')",
    "Get('server/exhibition/trade-tasks/:taskId/p0-pay-summary')",
    "Get('server/project/:projectId/pricing-summary')",
    "Get('server/projects/:projectId/pricing-summary')",
    "Post('server/exhibition/trade-tasks/:taskId/p0-pay-actions/release-non-winning')",
    "Post('server/exhibition/trade-tasks/:taskId/p0-pay-actions/publisher-breach-release')",
    "Post('server/exhibition/trade-tasks/:taskId/p0-pay-actions/factory-refusal-breach-hold')",
    "Post('server/exhibition/trade-tasks/:taskId/inquiry-deposit/orders/:depositOrderId/refund-init')",
    "Get('server/exhibition/trade-tasks/:taskId/inquiry-deposit/orders/:depositOrderId/refund')",
    "Get('server/project/:projectId/settlement/summary')",
    "Post('server/project/:projectId/settlement/batch-draft')",
    "Get('server/project/:projectId/settlement/reconciliation')",
  ].forEach((route) => assert.match(controller, new RegExp(escapeRegExp(route))));

  assert.match(stateActions, /releaseNonWinningAuthorizations/);
  assert.match(stateActions, /releaseForPublisherBreach/);
  assert.match(stateActions, /holdForFactoryRefusal/);
  assert.match(stateActions, /released/);
  assert.match(stateActions, /bidServiceFeeAuthorizationReleased/);
  assert.match(stateActions, /breach_hold/);
});

test('P0-Pay fixed-price bid submission seeds the approved message interaction carrier', () => {
  const service = fs.readFileSync(
    path.join(__dirname, '../src/modules/p0_pay/p0-pay-trade-task.service.ts'),
    'utf8',
  );
  const moduleSource = fs.readFileSync(
    path.join(__dirname, '../src/modules/p0_pay/p0-pay.module.ts'),
    'utf8',
  );

  assert.match(service, /BidSubmittedSeedService/);
  assert.match(service, /createForSubmittedBid/);
  assert.match(service, /dataSource\.transaction/);
  assert.match(moduleSource, /TradingImModule/);
});

test('P0-Pay contract confirmation charges with deal-only tiered fee calculation', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '../src/modules/p0_pay/p0-pay-contract-confirmation.service.ts'),
    'utf8',
  );

  assert.match(source, /const lockedFeeRate = ownership\.authorization\.feeRate/);
  assert.match(source, /feeRateSource: ownership\.authorization\.feeRateSource/);
  assert.match(source, /feeRateSnapshotHash: ownership\.authorization\.feeRateSnapshotHash/);
  assert.match(source, /calculateDealServiceFee/);
  assert.match(source, /finalFeeAmount: feeCalculation\.finalFeeAmount/);
  assert.match(source, /releasedRemainderAmount: feeCalculation\.releasedRemainderAmount/);
  assert.doesNotMatch(source, /P0_PAY_DEFAULT_SERVICE_FEE_RATE/);
});

test('P0-Pay payment callbacks preserve locked authorization fee snapshot across success, duplicate and failure', async () => {
  const {
    P0PayCallbackService,
  } = require('../dist/modules/p0_pay/p0-pay-callback.service.js');

  async function runCallbackScenario({ eventStatus, eventType, duplicate = false }) {
    const originalSnapshot = {
      feeRate: '0.030000',
      feeRateLabel: '标准会员 9折（作用于 baseFeeAmount）',
      feeRateSource: 'paid_membership_tier',
      membershipTierSnapshot: 'standard',
      feeRateRuleVersion: 'p0_pay_membership_service_fee_v1',
      feeRateSnapshotHash: 'snapshot-hash',
      feeCalculatedAt: new Date('2026-05-10T10:00:00.000Z'),
    };
    const authorization = {
      id: 'auth-1',
      status: 'pending_authorization',
      authorizedAt: null,
      chargedAt: null,
      ...originalSnapshot,
    };
    const order = {
      id: 'order-1',
      businessType: 'platform_service_fee_authorization',
      businessId: authorization.id,
      merchantOrderNo: 'P0PAY_AUTH_1',
      paymentChannel: 'alipay',
      orderRole: 'authorization',
      amount: '2500.00',
      status: 'pending_user_confirm',
      channelOrderId: null,
    };
    const savedTransactions = [];
    let transactionCalled = false;

    const manager = {
      getRepository(entity) {
        if (entity?.name === 'PaymentCallbackEventEntity') {
          return { async save(value) { return value; } };
        }
        if (entity?.name === 'PaymentOrderEntity') {
          return {
            async findOneBy() { return order; },
            async save(value) { return value; },
          };
        }
        if (entity?.name === 'PaymentTransactionEntity') {
          return {
            async save(value) { savedTransactions.push({ ...value }); return value; },
          };
        }
        if (entity?.name === 'PlatformServiceFeeAuthorizationEntity') {
          return {
            async findOneBy() { return authorization; },
            async save(value) { return value; },
            async update(_where, patch) { Object.assign(authorization, patch); },
          };
        }
        return {
          async findOneBy() { return null; },
          async save(value) { return value; },
          async update() { return undefined; },
        };
      },
    };

    const callbackRepository = {
      async findOneBy() {
        return duplicate
          ? {
              id: 'callback-duplicate',
              verificationStatus: 'verified',
              applyStatus: 'applied',
              rejectedReasonCode: '',
              receivedAt: new Date('2026-05-10T10:00:00.000Z'),
              processedAt: new Date('2026-05-10T10:00:01.000Z'),
            }
          : null;
      },
      create(value) { return value; },
    };
    const service = new P0PayCallbackService(
      callbackRepository,
      {
        async transaction(callback) {
          transactionCalled = true;
          return callback(manager);
        },
      },
      {
        verifyCallback() { return { verified: true, reasonCode: '' }; },
        hashPayload() { return 'payload-hash'; },
      },
      { async record() { return undefined; } },
    );

    const response = await service.handleCallback(
      'alipay',
      {
        merchantOrderNo: order.merchantOrderNo,
        channelOrderId: 'channel-1',
        providerEventId: `provider-${eventStatus}`,
        channelEventId: `event-${eventStatus}`,
        eventType,
        eventStatus,
        amount: order.amount,
        currency: 'CNY',
      },
      'sha256=test',
      { requestId: 'req-1', traceId: 'trace-1' },
    );

    assert.deepEqual(
      {
        feeRate: authorization.feeRate,
        feeRateLabel: authorization.feeRateLabel,
        feeRateSource: authorization.feeRateSource,
        membershipTierSnapshot: authorization.membershipTierSnapshot,
        feeRateRuleVersion: authorization.feeRateRuleVersion,
        feeRateSnapshotHash: authorization.feeRateSnapshotHash,
        feeCalculatedAt: authorization.feeCalculatedAt,
      },
      originalSnapshot,
    );
    return { authorization, order, response, transactionCalled, savedTransactions };
  }

  const success = await runCallbackScenario({
    eventStatus: 'succeeded',
    eventType: 'authorization_succeeded',
  });
  assert.equal(success.authorization.status, 'authorized');
  assert.equal(success.order.status, 'succeeded');
  assert.equal(success.savedTransactions.length, 1);
  assert.equal(success.response.applyStatus, 'applied');

  const duplicate = await runCallbackScenario({
    eventStatus: 'succeeded',
    eventType: 'authorization_succeeded',
    duplicate: true,
  });
  assert.equal(duplicate.transactionCalled, false);
  assert.equal(duplicate.authorization.status, 'pending_authorization');
  assert.equal(duplicate.savedTransactions.length, 0);
  assert.equal(duplicate.response.duplicate, true);
  assert.equal(duplicate.response.applyStatus, 'duplicate');

  const failure = await runCallbackScenario({
    eventStatus: 'failed',
    eventType: 'authorization_failed',
  });
  assert.equal(failure.authorization.status, 'failed');
  assert.equal(failure.order.status, 'failed');
  assert.equal(failure.savedTransactions.length, 1);
  assert.equal(failure.response.applyStatus, 'applied');
});

test('P0-Pay callback signature rejection records event without applying money state', async () => {
  const {
    P0PayCallbackService,
  } = require('../dist/modules/p0_pay/p0-pay-callback.service.js');

  let paymentOrderTouched = false;
  const savedCallbacks = [];
  const manager = {
    getRepository(entity) {
      if (entity?.name === 'PaymentCallbackEventEntity') {
        return {
          async save(value) {
            savedCallbacks.push({ ...value });
            return value;
          },
        };
      }
      if (entity?.name === 'PaymentOrderEntity') {
        paymentOrderTouched = true;
      }
      return {
        async findOneBy() { return null; },
        async save(value) { return value; },
      };
    },
  };
  const service = new P0PayCallbackService(
    {
      async findOneBy() { return null; },
      create(value) { return value; },
    },
    {
      async transaction(callback) {
        return callback(manager);
      },
    },
    {
      verifyCallback() { return { verified: false, reasonCode: 'callback_signature_invalid' }; },
      hashPayload() { return 'payload-hash'; },
    },
    { async record() { return undefined; } },
  );

  const response = await service.handleCallback(
    'alipay',
    {
      merchantOrderNo: 'P0PAY_DEP_REJECTED',
      channelOrderId: 'channel-rejected',
      providerEventId: 'provider-rejected',
      channelEventId: 'event-rejected',
      eventType: 'payment_succeeded',
      eventStatus: 'succeeded',
      amount: '200.00',
      currency: 'CNY',
    },
    'sha256=bad',
    { requestId: 'req-1', traceId: 'trace-1' },
  );

  assert.equal(response.verificationStatus, 'rejected');
  assert.equal(response.applyStatus, 'not_applied');
  assert.equal(response.rejectedReasonCode, 'callback_signature_invalid');
  assert.equal(paymentOrderTouched, false);
  assert.ok(savedCallbacks.some((item) => item.verificationStatus === 'rejected'));
});

test('P0-Pay project sincerity callback pays pricing object without auto-publishing project', async () => {
  const {
    P0PayCallbackService,
  } = require('../dist/modules/p0_pay/p0-pay-callback.service.js');

  const deposit = {
    id: 'sincerity-1',
    status: 'pending_payment',
    paidAt: null,
  };
  const order = {
    id: 'order-sincerity-1',
    businessType: 'project_authenticity_sincerity_payment',
    businessId: deposit.id,
    merchantOrderNo: 'P0PAY_DEP_1',
    paymentChannel: 'alipay',
    orderRole: 'payment',
    amount: '200.00',
    status: 'pending_user_confirm',
    channelOrderId: null,
  };
  const auditRecords = [];
  let projectRepositoryTouched = false;

  const manager = {
    getRepository(entity) {
      if (entity?.name === 'PaymentCallbackEventEntity') {
        return { async save(value) { return value; } };
      }
      if (entity?.name === 'PaymentOrderEntity') {
        return {
          async findOneBy() { return order; },
          async save(value) { return value; },
        };
      }
      if (entity?.name === 'PaymentTransactionEntity') {
        return { async save(value) { return value; } };
      }
      if (entity?.name === 'InquiryQuoteDepositEntity') {
        return {
          async findOneBy() { return deposit; },
          async save(value) { return value; },
          async update(_where, patch) { Object.assign(deposit, patch); },
        };
      }
      if (entity?.name === 'ProjectEntity') {
        projectRepositoryTouched = true;
      }
      return {
        async findOneBy() { return null; },
        async save(value) { return value; },
        async update() { return undefined; },
      };
    },
  };

  const service = new P0PayCallbackService(
    {
      async findOneBy() { return null; },
      create(value) { return value; },
    },
    {
      async transaction(callback) {
        return callback(manager);
      },
    },
    {
      verifyCallback() { return { verified: true, reasonCode: '' }; },
      hashPayload() { return 'payload-hash'; },
    },
    { async record(input) { auditRecords.push(input); } },
  );

  const response = await service.handleCallback(
    'alipay',
    {
      merchantOrderNo: order.merchantOrderNo,
      channelOrderId: 'channel-1',
      providerEventId: 'provider-sincerity-paid',
      channelEventId: 'event-sincerity-paid',
      eventType: 'payment_succeeded',
      eventStatus: 'succeeded',
      amount: order.amount,
      currency: 'CNY',
    },
    'sha256=test',
    { requestId: 'req-1', traceId: 'trace-1' },
  );

  assert.equal(response.applyStatus, 'applied');
  assert.equal(order.status, 'succeeded');
  assert.equal(deposit.status, 'paid');
  assert.ok(deposit.paidAt instanceof Date);
  assert.equal(projectRepositoryTouched, false);
  assert.equal(
    auditRecords.some((item) => item.action === 'InquiryTaskPublishedAfterDepositPaid' || item.objectType === 'trade_task'),
    false,
  );
  assert.ok(auditRecords.some((item) => item.action === 'project_authenticity_sincerity_paid'));
});

test('P0-Pay project sincerity refund callback handles success, duplicate and failure without extra money mutation', async () => {
  const {
    P0PayCallbackService,
  } = require('../dist/modules/p0_pay/p0-pay-callback.service.js');

  async function runRefundCallbackScenario({ eventStatus, eventType, duplicate = false }) {
    const deposit = {
      id: 'sincerity-refund-1',
      taskId: 'project-1',
      amount: '200.00',
      status: 'refund_pending',
      paidAt: new Date('2026-06-01T08:00:00.000Z'),
      refundedAt: null,
    };
    const refundOrder = {
      id: 'refund-order-1',
      businessType: 'project_authenticity_sincerity_refund',
      businessId: deposit.id,
      merchantOrderNo: 'P0PAY_REF_1',
      paymentChannel: 'alipay',
      orderRole: 'refund',
      amount: '200.00',
      status: 'refund_pending',
      channelOrderId: null,
    };
    const savedTransactions = [];
    const auditRecords = [];
    let transactionCalled = false;
    let depositUpdateCalled = false;

    const manager = {
      getRepository(entity) {
        if (entity?.name === 'PaymentCallbackEventEntity') {
          return { async save(value) { return value; } };
        }
        if (entity?.name === 'PaymentOrderEntity') {
          return {
            async findOneBy() { return refundOrder; },
            async save(value) { return value; },
          };
        }
        if (entity?.name === 'PaymentTransactionEntity') {
          return {
            async save(value) { savedTransactions.push({ ...value }); return value; },
          };
        }
        if (entity?.name === 'InquiryQuoteDepositEntity') {
          return {
            async findOneBy() { return deposit; },
            async save(value) { return value; },
            async update(where, patch) {
              depositUpdateCalled = true;
              if (where.id === deposit.id && where.status === deposit.status) {
                Object.assign(deposit, patch);
              }
            },
          };
        }
        return {
          async findOneBy() { return null; },
          async save(value) { return value; },
          async update() { return undefined; },
        };
      },
    };

    const service = new P0PayCallbackService(
      {
        async findOneBy() {
          return duplicate
            ? {
                id: 'callback-duplicate',
                verificationStatus: 'verified',
                applyStatus: 'applied',
                rejectedReasonCode: '',
                receivedAt: new Date('2026-06-01T10:00:00.000Z'),
                processedAt: new Date('2026-06-01T10:00:01.000Z'),
              }
            : null;
        },
        create(value) { return value; },
      },
      {
        async transaction(callback) {
          transactionCalled = true;
          return callback(manager);
        },
      },
      {
        verifyCallback() { return { verified: true, reasonCode: '' }; },
        hashPayload() { return 'payload-hash'; },
      },
      { async record(input) { auditRecords.push(input); } },
    );

    const response = await service.handleCallback(
      'alipay',
      {
        merchantOrderNo: refundOrder.merchantOrderNo,
        channelOrderId: 'channel-refund-1',
        providerEventId: `provider-refund-${eventStatus}`,
        channelEventId: `event-refund-${eventStatus}`,
        eventType,
        eventStatus,
        amount: refundOrder.amount,
        currency: 'CNY',
      },
      'sha256=test',
      { requestId: 'req-1', traceId: 'trace-1' },
    );

    return {
      deposit,
      refundOrder,
      response,
      savedTransactions,
      auditRecords,
      transactionCalled,
      depositUpdateCalled,
    };
  }

  const success = await runRefundCallbackScenario({
    eventStatus: 'succeeded',
    eventType: 'refund_succeeded',
  });
  assert.equal(success.response.applyStatus, 'applied');
  assert.equal(success.refundOrder.status, 'refunded');
  assert.equal(success.deposit.status, 'refunded');
  assert.ok(success.deposit.refundedAt instanceof Date);
  assert.equal(success.savedTransactions.length, 1);
  assert.equal(success.savedTransactions[0].transactionType, 'refund');
  assert.equal(success.savedTransactions[0].confirmedAmount, '200.00');
  assert.ok(success.auditRecords.some((item) => item.action === 'project_authenticity_sincerity_refunded'));

  const duplicate = await runRefundCallbackScenario({
    eventStatus: 'succeeded',
    eventType: 'refund_succeeded',
    duplicate: true,
  });
  assert.equal(duplicate.response.duplicate, true);
  assert.equal(duplicate.response.applyStatus, 'duplicate');
  assert.equal(duplicate.transactionCalled, false);
  assert.equal(duplicate.savedTransactions.length, 0);
  assert.equal(duplicate.deposit.status, 'refund_pending');

  const failure = await runRefundCallbackScenario({
    eventStatus: 'failed',
    eventType: 'refund_failed',
  });
  assert.equal(failure.response.applyStatus, 'applied');
  assert.equal(failure.refundOrder.status, 'failed');
  assert.equal(failure.deposit.status, 'paid');
  assert.equal(failure.depositUpdateCalled, true);
  assert.equal(failure.savedTransactions.length, 1);
  assert.equal(failure.savedTransactions[0].transactionType, 'refund');
  assert.equal(failure.savedTransactions[0].status, 'failed');
});

test('P0-Pay contract confirmation charges from tiered fee, discount and cap instead of quote fee rate', async () => {
  const {
    P0PayContractConfirmationService,
  } = require('../dist/modules/p0_pay/p0-pay-contract-confirmation.service.js');

  const scenarios = [
    {
      tier: 'none',
      feeRate: '0.030000',
      label: '基础平台定价规则',
      expected: '1500.00',
      discount: '1.0000',
      cap: '4000.00',
      source: 'fixed_default',
    },
    {
      tier: 'free_certified',
      feeRate: '0.030000',
      label: '免费认证版无会员折扣',
      expected: '1500.00',
      discount: '1.0000',
      cap: '4000.00',
      source: 'fixed_default',
    },
    {
      tier: 'standard',
      feeRate: '0.030000',
      label: '标准会员 9折（作用于 baseFeeAmount）',
      expected: '1350.00',
      discount: '0.9000',
      cap: '3600.00',
      source: 'paid_membership_tier',
    },
    {
      tier: 'professional',
      feeRate: '0.030000',
      label: '专业会员 8折（作用于 baseFeeAmount）',
      expected: '1200.00',
      discount: '0.8000',
      cap: '3200.00',
      source: 'paid_membership_tier',
    },
  ];

  for (const scenario of scenarios) {
    const savedCharges = [];
    const service = new P0PayContractConfirmationService(
      null,
      null,
      { create: (value) => value },
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      {
        calculateDealServiceFee({ finalConfirmedAmount, membershipTierSnapshot, authorizationQuotaAmount }) {
          const baseFeeAmount = '1500.00';
          const byTier = scenarios.find((item) => item.tier === membershipTierSnapshot);
          return {
            finalConfirmedAmount: String(finalConfirmedAmount),
            baseFeeAmount,
            membershipDiscountRate: byTier.discount,
            capAmount: byTier.cap,
            finalFeeAmount: byTier.expected,
            releasedRemainderAmount: (Number(authorizationQuotaAmount) - Number(byTier.expected)).toFixed(2),
          };
        },
      },
    );
    service.createChargePaymentOrder = async () => ({ id: `order-${scenario.tier}` });
    service.saveChargeTransaction = async () => undefined;
    service.markAuthorizationCharged = async () => undefined;
    service.recordChargeAudit = async () => undefined;

    const manager = {
      getRepository(entity) {
        if (entity?.name === 'PlatformServiceFeeChargeEntity') {
          return {
            async findOneBy() { return null; },
            async save(value) { savedCharges.push(value); return value; },
          };
        }
        return { async save(value) { return value; } };
      },
    };
    const authorization = {
      id: `auth-${scenario.tier}`,
      paymentChannel: 'alipay',
      authorizationOrderId: `merchant-auth-${scenario.tier}`,
      authorizationQuotaAmount: '4000.00',
      feeRate: scenario.feeRate,
      feeRateLabel: scenario.label,
      feeRateSource: scenario.source,
      membershipTierSnapshot: scenario.tier,
      feeRateRuleVersion: 'p0_pay_membership_service_fee_v1',
      feeRateSnapshotHash: `snapshot-hash-${scenario.tier}`,
      feeCalculatedAt: new Date('2026-05-10T10:00:00.000Z'),
    };
    const charge = await service.ensureCharge(
      manager,
      {
        id: `contract-${scenario.tier}`,
        taskId: `task-${scenario.tier}`,
        finalConfirmedAmount: '90000.00',
        contractStatus: 'confirmed_deal',
        platformServiceFeeChargeId: null,
      },
      {
        authorization,
        bid: { id: `bid-${scenario.tier}`, bidderOrganizationId: 'factory-1' },
        project: { projectNo: 'EXH-1' },
        scope: { membership: { roleKey: 'factory' } },
        currentSession: { userId: 'user-1' },
      },
      { requestId: 'req-1', traceId: 'trace-1' },
    );

    assert.equal(charge.feeRate, scenario.feeRate);
    assert.equal(charge.baseFeeAmount, '1500.00');
    assert.equal(charge.membershipDiscountRate, scenario.discount);
    assert.equal(charge.capAmount, scenario.cap);
    assert.equal(charge.finalFeeAmount, scenario.expected);
    assert.equal(charge.releasedRemainderAmount, (4000 - Number(scenario.expected)).toFixed(2));
    assert.equal(charge.feeRateLabel, scenario.label);
    assert.equal(charge.feeRateSource, scenario.source);
    assert.equal(charge.membershipTierSnapshot, scenario.tier);
    assert.equal(charge.feeRateSnapshotHash, `snapshot-hash-${scenario.tier}`);
    assert.equal(savedCharges.length, 1);
  }
});

test('P0-Pay contract final charge returns existing charge idempotently', async () => {
  const {
    P0PayContractConfirmationService,
  } = require('../dist/modules/p0_pay/p0-pay-contract-confirmation.service.js');

  const existingCharge = {
    id: 'charge-existing',
    contractConfirmationId: 'contract-1',
    chargeStatus: 'charged',
    finalFeeAmount: '1200.00',
  };
  const service = new P0PayContractConfirmationService(
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    {
      calculateDealServiceFee() {
        throw new Error('fee policy must not run for existing charge');
      },
    },
  );
  service.createChargePaymentOrder = async () => {
    throw new Error('payment order must not be created twice');
  };

  const manager = {
    getRepository(entity) {
      if (entity?.name === 'PlatformServiceFeeChargeEntity') {
        return {
          async findOneBy() { return existingCharge; },
          async save(value) { return value; },
        };
      }
      return { async save(value) { return value; } };
    },
  };

  const charge = await service.ensureCharge(
    manager,
    {
      id: 'contract-1',
      taskId: 'task-1',
      finalConfirmedAmount: '60000.00',
      contractStatus: 'confirmed_deal',
    },
    {
      authorization: { id: 'auth-1', paymentChannel: 'alipay' },
      bid: { id: 'bid-1', bidderOrganizationId: 'factory-1' },
      project: { projectNo: 'EXH-1' },
      scope: { membership: { roleKey: 'factory' } },
      currentSession: { userId: 'user-1' },
    },
    { requestId: 'req-1', traceId: 'trace-1' },
  );

  assert.equal(charge, existingCharge);
});

test('P0-Pay contract final charge fail-closes without locked payment channel', async () => {
  const {
    P0PayContractConfirmationService,
  } = require('../dist/modules/p0_pay/p0-pay-contract-confirmation.service.js');

  const service = new P0PayContractConfirmationService(
    null,
    null,
    { create: (value) => value },
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    {
      calculateDealServiceFee() {
        throw new Error('fee policy must not run when payment channel is missing');
      },
    },
  );
  const manager = {
    getRepository(entity) {
      if (entity?.name === 'PlatformServiceFeeChargeEntity') {
        return {
          async findOneBy() { return null; },
          async save(value) { return value; },
        };
      }
      return { async save(value) { return value; } };
    },
  };

  await assert.rejects(
    () => service.ensureCharge(
      manager,
      {
        id: 'contract-1',
        taskId: 'task-1',
        finalConfirmedAmount: '60000.00',
        contractStatus: 'confirmed_deal',
      },
      {
        authorization: { id: 'auth-1', paymentChannel: null },
        bid: { id: 'bid-1', bidderOrganizationId: 'factory-1' },
        project: { projectNo: 'EXH-1' },
        scope: { membership: { roleKey: 'factory' } },
        currentSession: { userId: 'user-1' },
      },
      { requestId: 'req-1', traceId: 'trace-1' },
    ),
    /no payment channel/,
  );
});

test('message interaction bid-thread projection carries only read-only pricing summary', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '../src/modules/message_interaction/counterpart-conversation.bid-thread-source.ts'),
    'utf8',
  );
  const moduleSource = fs.readFileSync(
    path.join(__dirname, '../src/modules/message_interaction/message-interaction.module.ts'),
    'utf8',
  );

  assert.match(source, /PlatformServiceFeeAuthorizationEntity/);
  assert.match(source, /InquiryQuoteDepositEntity/);
  assert.match(source, /pricingSummary: this\.buildPricingSummary/);
  assert.match(source, /readOnly: true/);
  assert.match(source, /objectType: 'project_pricing'/);
  assert.match(source, /actionKey: 'pricing_summary\.read'/);
  assert.match(source, /canonicalPath: `\/api\/app\/project\/\$\{project\.id\}\/pricing-summary`/);
  assert.doesNotMatch(source, /p0PaySummary/);
  assert.doesNotMatch(source, /buildP0PaySummary/);
  assert.doesNotMatch(source, /estimatedFeeAmount/);
  assert.doesNotMatch(source, /\.save\(/);
  assert.match(moduleSource, /PlatformServiceFeeAuthorizationEntity/);
  assert.match(moduleSource, /InquiryQuoteDepositEntity/);
});

test('pricing summary carries only quota, sincerity and deal status for read-only BFF projection', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '../src/modules/p0_pay/p0-pay-trade-task.service.ts'),
    'utf8',
  );

  [
    'pricingSummary: await this.buildInlinePricingSummary(project, context)',
    'bidServiceFeeAuthorization',
    "quotaAmount: authorization.authorizationQuotaAmount ?? '4000.00'",
    'projectAuthenticitySincerity',
    'dealConfirmation',
    "objectType: 'project_pricing'",
    "actionKey: 'pricing_summary.read'",
    'canonicalPath: `/api/app/project/${project.id}/pricing-summary`',
  ].forEach((snippet) => assert.match(source, new RegExp(escapeRegExp(snippet))));

  assert.doesNotMatch(source, /p0PaySummary/);
  assert.doesNotMatch(source, /buildP0PaySummary/);
  assert.doesNotMatch(source, /inquiryDeposit:/);
  assert.doesNotMatch(source, /estimatedFeeAmount:/);
});

test('P0-Pay presenter surfaces 4000 authorization quota instead of estimated fee authority', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '../src/modules/p0_pay/p0-pay.presenter.ts'),
    'utf8',
  );

  assert.match(source, /authorizationQuotaAmount: quotaAmount/);
  assert.match(source, /quotaAmount/);
  assert.doesNotMatch(source, /estimatedFeeAmount: authorization\.estimatedFeeAmount/);
});

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
