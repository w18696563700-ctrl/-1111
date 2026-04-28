const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

test('P0-Pay migration registers inquiry deposit, callback, contract confirmation and charge truth', () => {
  const { p0PayMigrations } = require('../dist/core/migrations/migrations.js');
  const sql = p0PayMigrations.flatMap((item) => item.statements).join('\n');

  assert.match(sql, /CREATE TABLE IF NOT EXISTS inquiry_quote_deposits/);
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
  assert.doesNotMatch(sql, /wallet_pending/);
  assert.doesNotMatch(sql, /guarantee_freezing/);
});

test('P0-Pay payment channel callback verification is HMAC based and does not require account binding', () => {
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
  assert.deepEqual(service.verifyCallback(payload, signature), {
    verified: true,
    reasonCode: '',
  });
  assert.equal(service.verifyCallback(payload, 'sha256=bad').verified, false);

  const action = service.buildChannelAction({
    paymentOrderId: 'order-1',
    merchantOrderNo: 'P0PAY_DEP_1',
    amount: '200.00',
    currency: 'CNY',
    channel: 'alipay',
    clientPlatform: 'flutter',
  });
  assert.equal(action.channelPayload.accountBindingRequired, false);
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
    "Get('server/exhibition/trade-tasks/:taskId/p0-pay-summary')",
    "Post('server/exhibition/trade-tasks/:taskId/p0-pay-actions/release-non-winning')",
    "Post('server/exhibition/trade-tasks/:taskId/p0-pay-actions/publisher-breach-release')",
    "Post('server/exhibition/trade-tasks/:taskId/p0-pay-actions/factory-refusal-breach-hold')",
  ].forEach((route) => assert.match(controller, new RegExp(escapeRegExp(route))));

  assert.match(stateActions, /releaseNonWinningAuthorizations/);
  assert.match(stateActions, /releaseForPublisherBreach/);
  assert.match(stateActions, /holdForFactoryRefusal/);
  assert.match(stateActions, /authorization_released/);
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

test('P0-Pay contract confirmation charges with authorization locked fee snapshot', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '../src/modules/p0_pay/p0-pay-contract-confirmation.service.ts'),
    'utf8',
  );

  assert.match(source, /const lockedFeeRate = ownership\.authorization\.feeRate/);
  assert.match(source, /feeRateSource: ownership\.authorization\.feeRateSource/);
  assert.match(source, /feeRateSnapshotHash: ownership\.authorization\.feeRateSnapshotHash/);
  assert.match(source, /finalFeeAmount = calculatePlatformServiceFeeAmount\(confirmation\.finalConfirmedAmount, lockedFeeRate\)/);
  assert.doesNotMatch(source, /P0_PAY_DEFAULT_SERVICE_FEE_RATE/);
});

test('P0-Pay contract confirmation behavior copies locked authorization snapshot into charge', async () => {
  const {
    P0PayContractConfirmationService,
  } = require('../dist/modules/p0_pay/p0-pay-contract-confirmation.service.js');

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
  );
  service.createChargePaymentOrder = async () => ({ id: 'order-1' });
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
    id: 'auth-1',
    paymentChannel: 'alipay',
    authorizationOrderId: 'merchant-auth-1',
    feeRate: '0.025000',
    feeRateLabel: '标准会员 2.5%',
    feeRateSource: 'paid_membership_tier',
    membershipTierSnapshot: 'standard',
    feeRateRuleVersion: 'p0_pay_membership_service_fee_v1',
    feeRateSnapshotHash: 'snapshot-hash',
    feeCalculatedAt: new Date('2026-05-10T10:00:00.000Z'),
  };
  const charge = await service.ensureCharge(
    manager,
    {
      id: 'contract-1',
      taskId: 'task-1',
      finalConfirmedAmount: '90000.00',
      platformServiceFeeChargeId: null,
    },
    {
      authorization,
      bid: { id: 'bid-1', bidderOrganizationId: 'factory-1' },
      project: { projectNo: 'EXH-1' },
      scope: { membership: { roleKey: 'factory' } },
      currentSession: { userId: 'user-1' },
    },
    { requestId: 'req-1', traceId: 'trace-1' },
  );

  assert.equal(charge.feeRate, '0.025000');
  assert.equal(charge.finalFeeAmount, '2250.00');
  assert.equal(charge.feeRateSource, 'paid_membership_tier');
  assert.equal(charge.membershipTierSnapshot, 'standard');
  assert.equal(charge.feeRateSnapshotHash, 'snapshot-hash');
  assert.equal(savedCharges.length, 1);
});

test('message interaction bid-thread projection carries only read-only P0-Pay summary', () => {
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
  assert.match(source, /p0PaySummary: this\.buildP0PaySummary/);
  assert.match(source, /readOnly: true/);
  assert.doesNotMatch(source, /\.save\(/);
  assert.match(moduleSource, /PlatformServiceFeeAuthorizationEntity/);
  assert.match(moduleSource, /InquiryQuoteDepositEntity/);
});

test('P0-Pay summary carries fee snapshot fields for read-only BFF projection', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '../src/modules/p0_pay/p0-pay-trade-task.service.ts'),
    'utf8',
  );

  [
    'quotedAmount: authorization.quotedAmount',
    'feeRate: authorization.feeRate',
    'feeRateLabel: authorization.feeRateLabel',
    'feeRateSource: authorization.feeRateSource',
    'membershipTierSnapshot: authorization.membershipTierSnapshot',
    'feeRateRuleVersion: authorization.feeRateRuleVersion',
    'feeRateSnapshotHash: authorization.feeRateSnapshotHash',
    'feeCalculatedAt: authorization.feeCalculatedAt',
  ].forEach((snippet) => assert.match(source, new RegExp(escapeRegExp(snippet))));
});

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
