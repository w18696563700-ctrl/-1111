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

test('P0-Pay membership service fee policy maps organization tier snapshots', async () => {
  const {
    P0PayServiceFeeRatePolicy,
  } = require('../dist/modules/p0_pay/p0-pay-service-fee-rate.policy.js');

  const tiers = new Map([
    ['org-free', 'free_certified'],
    ['org-standard', 'standard'],
    ['org-professional', 'professional'],
    ['org-ka', 'ka'],
    ['org-flagship', 'flagship'],
    ['org-expired', null],
  ]);
  const policy = new P0PayServiceFeeRatePolicy({
    async getPaidMembershipTierSnapshotForOrganization(organizationId) {
      return {
        tierCode: tiers.get(organizationId) ?? null,
        effectiveAt: null,
        expiresAt: null,
        sourceType: null,
        sourceRef: null,
      };
    },
  });

  const free = await policy.buildRequirement({ factoryOrganizationId: 'org-free', quotedAmount: '100000.00' });
  assert.equal(free.feeRate, '0.030000');
  assert.equal(free.feeRateSource, 'fixed_default');
  assert.equal(free.membershipTierSnapshot, 'free_certified');
  assert.equal(free.estimatedFeeAmount, '1650.00');
  assert.equal(free.membershipDiscountRate, '1.0000');
  assert.equal(free.capAmount, '4000.00');
  assert.equal(free.authorizationQuotaAmount, '4000.00');

  const standard = await policy.buildRequirement({ factoryOrganizationId: 'org-standard', quotedAmount: '188880.00' });
  assert.equal(standard.feeRate, '0.030000');
  assert.equal(standard.feeRateLabel, '标准会员 9折（作用于 baseFeeAmount）');
  assert.equal(standard.feeRateSource, 'paid_membership_tier');
  assert.equal(standard.membershipTierSnapshot, 'standard');
  assert.equal(standard.baseFeeAmount, '2538.80');
  assert.equal(standard.membershipDiscountRate, '0.9000');
  assert.equal(standard.capAmount, '3600.00');
  assert.equal(standard.estimatedFeeAmount, '2284.92');

  const professional = await policy.buildRequirement({ factoryOrganizationId: 'org-professional', quotedAmount: '100000.00' });
  assert.equal(professional.feeRate, '0.030000');
  assert.equal(professional.feeRateLabel, '专业会员 8折（作用于 baseFeeAmount）');
  assert.equal(professional.feeRateSource, 'paid_membership_tier');
  assert.equal(professional.membershipTierSnapshot, 'professional');
  assert.equal(professional.membershipDiscountRate, '0.8000');
  assert.equal(professional.capAmount, '3200.00');
  assert.equal(professional.estimatedFeeAmount, '1320.00');

  await assert.rejects(
    () => policy.buildRequirement({ factoryOrganizationId: 'org-ka', quotedAmount: '100000.00' }),
    /Current paid membership tier is not supported/,
  );
  await assert.rejects(
    () => policy.buildRequirement({ factoryOrganizationId: 'org-flagship', quotedAmount: '100000.00' }),
    /Current paid membership tier is not supported/,
  );

  const expired = await policy.buildRequirement({ factoryOrganizationId: 'org-expired', quotedAmount: '100000.00' });
  assert.equal(expired.feeRate, '0.030000');
  assert.equal(expired.membershipTierSnapshot, 'none');

  const unknownTierPolicy = new P0PayServiceFeeRatePolicy({
    async getPaidMembershipTierSnapshotForOrganization() {
      return { tierCode: 'surprise-tier' };
    },
  });
  await assert.rejects(
    () => unknownTierPolicy.buildRequirement({ factoryOrganizationId: 'org-unknown', quotedAmount: '100000.00' }),
    /Current paid membership tier is not supported/,
  );

  const failingPolicy = new P0PayServiceFeeRatePolicy({
    async getPaidMembershipTierSnapshotForOrganization() {
      throw new Error('membership query down');
    },
  });
  await assert.rejects(
    () => failingPolicy.buildRequirement({ factoryOrganizationId: 'org-fail', quotedAmount: '100000.00' }),
    /Current paid membership tier is unavailable/,
  );
});

test('platform pricing deal fee policy uses tiered base fee, membership discount and cap', () => {
  const {
    P0PayServiceFeeRatePolicy,
  } = require('../dist/modules/p0_pay/p0-pay-service-fee-rate.policy.js');
  const policy = new P0PayServiceFeeRatePolicy(null);

  assert.deepEqual(
    policy.calculateDealServiceFee({
      finalConfirmedAmount: '11000.00',
      membershipTierSnapshot: 'none',
      authorizationQuotaAmount: '4000.00',
    }),
    {
      finalConfirmedAmount: '11000.00',
      baseFeeAmount: '220.00',
      membershipDiscountRate: '1.0000',
      capAmount: '4000.00',
      finalFeeAmount: '220.00',
      releasedRemainderAmount: '3780.00',
    },
  );
  assert.deepEqual(
    policy.calculateDealServiceFee({
      finalConfirmedAmount: '40000.00',
      membershipTierSnapshot: 'standard',
      authorizationQuotaAmount: '4000.00',
    }),
    {
      finalConfirmedAmount: '40000.00',
      baseFeeAmount: '750.00',
      membershipDiscountRate: '0.9000',
      capAmount: '3600.00',
      finalFeeAmount: '675.00',
      releasedRemainderAmount: '3325.00',
    },
  );
  assert.deepEqual(
    policy.calculateDealServiceFee({
      finalConfirmedAmount: '1000000.00',
      membershipTierSnapshot: 'professional',
      authorizationQuotaAmount: '4000.00',
    }),
    {
      finalConfirmedAmount: '1000000.00',
      baseFeeAmount: '4000.00',
      membershipDiscountRate: '0.8000',
      capAmount: '3200.00',
      finalFeeAmount: '3200.00',
      releasedRemainderAmount: '800.00',
    },
  );
});

test('P0-Pay authorization factory writes the Server fee snapshot into authorization truth', async () => {
  const {
    P0PayServiceFeeFactory,
  } = require('../dist/modules/p0_pay/p0-pay-service-fee.factory.js');

  const feeRequirement = {
    feeRate: '0.030000',
    feeRateLabel: '标准会员 9折（作用于 baseFeeAmount）',
    feeRateSource: 'paid_membership_tier',
    membershipTierSnapshot: 'standard',
    feeRateRuleVersion: 'p0_pay_membership_service_fee_v1',
    feeRateSnapshotHash: 'snapshot-hash',
    feeCalculatedAt: new Date('2026-05-10T10:00:00.000Z'),
    quotedAmount: '188880.00',
    estimatedFeeAmount: '2284.92',
    baseFeeAmount: '2538.80',
    membershipDiscountRate: '0.9000',
    capAmount: '3600.00',
    authorizationQuotaAmount: '4000.00',
    quotaAmount: '4000.00',
    currency: 'CNY',
    authorizationRequired: true,
    authorizationStatus: 'pending_freeze',
  };
  const factory = new P0PayServiceFeeFactory(
    { create: (value) => value },
    { create: (value) => value },
    { buildMerchantOrderNo: () => 'merchant-1', hashKey: (value) => `hash:${value}` },
    { buildRequirement: async () => feeRequirement },
  );
  const bid = {
    id: 'bid-1',
    bidderOrganizationId: 'factory-1',
    quoteAmount: '188880.00',
  };

  await factory.assertExpectedAmounts(
      {
        expectedQuotedAmount: '188880.00',
        expectedFeeRate: '0.030000',
        expectedAuthorizationAmount: '4000.00',
        currency: 'CNY',
    },
    bid,
  );
  await assert.rejects(
    () => factory.assertExpectedAmounts(
      {
        expectedQuotedAmount: '188880.00',
        expectedFeeRate: '0.025000',
        expectedAuthorizationAmount: '4000.00',
        currency: 'CNY',
      },
      bid,
    ),
    /expectedFeeRate/,
  );

  const authorization = factory.buildAuthorization({
    bid,
    project: { id: 'task-1', organizationId: 'publisher-1' },
    currentSession: { userId: 'user-1', actorId: 'actor-1' },
    context: { requestId: 'req-1', traceId: 'trace-1' },
    feeRequirement,
  });

  assert.equal(authorization.feeRate, '0.030000');
  assert.equal(authorization.estimatedFeeAmount, '2284.92');
  assert.equal(authorization.baseFeeAmount, '2538.80');
  assert.equal(authorization.membershipDiscountRate, '0.9000');
  assert.equal(authorization.capAmount, '3600.00');
  assert.equal(authorization.authorizationQuotaAmount, '4000.00');
  assert.equal(authorization.status, 'pending_freeze');
  assert.equal(authorization.feeRateLabel, '标准会员 9折（作用于 baseFeeAmount）');
  assert.equal(authorization.feeRateSource, 'paid_membership_tier');
  assert.equal(authorization.membershipTierSnapshot, 'standard');
  assert.equal(authorization.feeRateRuleVersion, 'p0_pay_membership_service_fee_v1');
  assert.equal(authorization.feeRateSnapshotHash, 'snapshot-hash');
  assert.deepEqual(authorization.feeCalculatedAt, feeRequirement.feeCalculatedAt);
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
