const test = require('node:test');
const assert = require('node:assert/strict');

test('P0-Pay service fee calculator uses final server rate truth', () => {
  const {
    calculatePlatformServiceFeeAmount,
    normalizeFeeRate,
    normalizePositiveMoney,
  } = require('../dist/modules/p0_pay/p0-pay-calculator.js');

  assert.equal(normalizePositiveMoney('80000'), '80000.00');
  assert.equal(normalizeFeeRate(0.03), '0.030000');
  assert.equal(calculatePlatformServiceFeeAmount('80000.00', '0.030000'), '2400.00');
  assert.equal(calculatePlatformServiceFeeAmount('92000.00', '0.030000'), '2760.00');
});

test('P0-Pay idempotency hashes are stable and request-order insensitive', () => {
  const {
    P0PayIdempotencyService,
  } = require('../dist/modules/p0_pay/p0-pay-idempotency.service.js');

  const service = new P0PayIdempotencyService();
  const key = service.normalizeKey('service-fee-auth-001');
  assert.equal(key, 'service-fee-auth-001');
  assert.equal(service.hashKey(key), service.hashKey('service-fee-auth-001'));
  assert.equal(
    service.hashRequest({ taskId: 'task-1', bidId: 'bid-1', amount: '2400.00' }),
    service.hashRequest({ amount: '2400.00', bidId: 'bid-1', taskId: 'task-1' }),
  );
});
