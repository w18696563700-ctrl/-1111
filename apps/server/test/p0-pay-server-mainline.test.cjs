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

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
