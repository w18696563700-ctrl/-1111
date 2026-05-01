const path = require('path');
require('ts-node').register({
  transpileOnly: true,
  project: path.resolve(__dirname, '../tsconfig.json'),
});
require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');
const { AxiosError } = require('axios');

const {
  ProfileMembershipPurchaseService,
} = require('../src/routes/profile/profile-membership-purchase.service.ts');
const {
  ProfileMembershipPurchaseErrorService,
} = require('../src/routes/profile/profile-membership-purchase-error.service.ts');
const { AuthContextService } = require('../src/core/auth/auth-context.service.ts');
const { ErrorNormalizerService } = require('../src/core/errors/error-normalizer.service.ts');

function createServerError(status, data) {
  return new AxiosError('upstream failed', 'ERR_BAD_REQUEST', {}, null, {
    status,
    statusText: 'error',
    headers: {},
    config: {},
    data,
  });
}

function createService(serverClient) {
  return new ProfileMembershipPurchaseService(
    serverClient,
    new AuthContextService(),
    new ProfileMembershipPurchaseErrorService(new ErrorNormalizerService()),
  );
}

const headers = {
  authorization: 'Bearer token',
  'x-user-id': 'user-1',
  'x-actor-id': 'actor-1',
  'x-organization-id': 'org-1',
  'x-request-id': 'req-1',
  'x-trace-id': 'trace-1',
};

test('membership purchase BFF forwards app calls to Server and only shapes returned truth', async () => {
  const calls = [];
  const serverClient = {
    async get(path, options) {
      calls.push(['GET', path, options.headers]);
      if (path === '/server/profile/membership/purchase-offers') {
        return {
          offers: [
            {
              skuCode: 'membership_standard_year_v1',
              skuName: '标准会员年付版',
              membershipTier: 'standard',
              durationMonths: 12,
              priceAmount: 2599,
              currency: 'CNY',
              entitlementSummary: ['平台服务费 9 折'],
              serviceFeeDiscountSummary: '平台服务费 9 折，作用于 baseFeeAmount，单项目封顶 3600。',
              isRenewable: false,
              isUpgradable: true,
              status: 'available',
            },
          ],
          currentOrganizationMembershipContext: {
            organizationId: 'org-1',
            paidMembershipTier: null,
            purchaseEligible: true,
            ineligibleReasonCode: null,
          },
          channelCandidates: ['alipay_candidate', 'wechat_candidate'],
          commercialDisclosure: 'server disclosure',
          updatedAt: '2026-05-01T00:00:00.000Z',
        };
      }
      return {
        membershipOrderId: 'order-1',
        organizationId: 'org-1',
        orderStatus: 'active',
        paymentStatus: 'succeeded',
        entitlementStatus: 'active',
        skuSnapshot: {
          skuCode: 'membership_standard_year_v1',
          skuName: '标准会员年付版',
          membershipTier: 'standard',
          durationMonths: 12,
          serviceFeeDiscountSummary: '平台服务费 9 折，作用于 baseFeeAmount，单项目封顶 3600。',
        },
        amountSummary: { payableAmount: 2599, currency: 'CNY' },
        channelSummary: {
          payChannel: 'alipay_candidate',
          paymentReferenceId: 'MEM_PAY_1',
          callbackAwaiting: false,
        },
        effectiveAt: '2026-05-01T00:00:00.000Z',
        expiresAt: '2027-05-01T00:00:00.000Z',
        failureReasonCode: null,
        updatedAt: '2026-05-01T00:00:00.000Z',
      };
    },
    async post(path, body, options) {
      calls.push(['POST', path, body, options.headers]);
      if (path === '/server/profile/membership/orders') {
        return {
          membershipOrderId: 'order-1',
          orderStatus: 'created',
          payableAmount: 2599,
          currency: 'CNY',
          entitlementPreview: {
            skuCode: 'membership_standard_year_v1',
            skuName: '标准会员年付版',
            membershipTier: 'standard',
            durationMonths: 12,
            serviceFeeDiscountSummary: '平台服务费 9 折，作用于 baseFeeAmount，单项目封顶 3600。',
          },
          channelCandidates: ['alipay_candidate', 'wechat_candidate'],
          expiresAt: '2026-05-01T00:30:00.000Z',
          updatedAt: '2026-05-01T00:00:00.000Z',
        };
      }
      return {
        paymentInitStatus: 'pending_user_confirm',
        membershipOrderId: 'order-1',
        paymentReferenceId: 'MEM_PAY_1',
        channelActionType: 'sdk_payload',
        channelPayload: { provider: 'alipay', orderString: 'server-owned' },
        callbackAwaiting: true,
        expiresAt: '2026-05-01T00:30:00.000Z',
        updatedAt: '2026-05-01T00:01:00.000Z',
      };
    },
  };
  const service = createService(serverClient);

  const offers = await service.getPurchaseOffers(headers);
  const created = await service.createOrder({
    skuCode: 'membership_standard_year_v1',
    purchaseIntentType: 'new_purchase',
    expectedAmount: 2599,
    expectedCurrency: 'CNY',
    idempotencyKey: 'create-key',
  }, headers);
  const payInit = await service.payInit('order-1', {
    payChannel: 'alipay_candidate',
    clientPlatform: 'android',
    idempotencyKey: 'pay-key',
  }, headers);
  const result = await service.getOrder('order-1', headers);

  assert.equal(offers.offers[0].priceAmount, 2599);
  assert.equal(created.orderStatus, 'created');
  assert.equal(payInit.channelPayload.provider, 'alipay');
  assert.equal(result.entitlementStatus, 'active');
  assert.deepEqual(
    calls.map((item) => item[1]),
    [
      '/server/profile/membership/purchase-offers',
      '/server/profile/membership/orders',
      '/server/profile/membership/orders/order-1/pay-init',
      '/server/profile/membership/orders/order-1',
    ],
  );
  assert.ok(calls.every((item) => item[1].startsWith('/server/profile/membership/')));
});

test('membership purchase BFF preserves controlled Server error families', async () => {
  const service = createService({
    async get() {
      throw createServerError(404, {
        code: 'MEMBERSHIP_ORDER_NOT_FOUND',
        message: 'missing',
        source: 'server',
      });
    },
    async post() {
      throw createServerError(400, {
        code: 'MEMBERSHIP_ORDER_CREATE_REJECTED',
        message: 'bad order',
        source: 'server',
      });
    },
  });

  await assert.rejects(
    () => service.getOrder('missing-order', headers),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.equal(error.getResponse().code, 'MEMBERSHIP_ORDER_NOT_FOUND');
      return true;
    },
  );
  await assert.rejects(
    () => service.createOrder({}, headers),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'MEMBERSHIP_ORDER_CREATE_REJECTED');
      return true;
    },
  );
});
