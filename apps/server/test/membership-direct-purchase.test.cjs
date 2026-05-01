const test = require('node:test');
const assert = require('node:assert/strict');

function createRepository(store) {
  return {
    create(value) {
      return { ...value };
    },
    async save(value) {
      const now = new Date();
      if (!value.createdAt) value.createdAt = now;
      value.updatedAt = now;
      const index = store.findIndex((item) => item.id === value.id);
      if (index >= 0) {
        store[index] = { ...store[index], ...value };
        return store[index];
      }
      store.push(value);
      return value;
    },
    async findOneBy(where) {
      return store.find((item) =>
        Object.entries(where).every(([key, value]) => item[key] === value)
      ) ?? null;
    },
    async update(where, patch) {
      for (const item of store) {
        if (Object.entries(where).every(([key, value]) => item[key] === value)) {
          Object.assign(item, patch);
          item.updatedAt = new Date();
        }
      }
    },
    async count(options = {}) {
      return this.applyWhere(options.where).length;
    },
    async find(options = {}) {
      let rows = this.applyWhere(options.where);
      if (options.order) {
        const [[field, direction]] = Object.entries(options.order);
        rows = rows.sort((left, right) => {
          const leftValue = left[field] instanceof Date ? left[field].getTime() : left[field];
          const rightValue = right[field] instanceof Date ? right[field].getTime() : right[field];
          return direction === 'DESC'
            ? Number(rightValue > leftValue) - Number(rightValue < leftValue)
            : Number(leftValue > rightValue) - Number(leftValue < rightValue);
        });
      }
      const start = options.skip ?? 0;
      const end = options.take ? start + options.take : undefined;
      return rows.slice(start, end);
    },
    applyWhere(where = {}) {
      return store.filter((item) =>
        Object.entries(where).every(([key, value]) => item[key] === value)
      );
    },
  };
}

function createHarness() {
  const {
    MembershipPurchaseService,
  } = require('../dist/modules/membership/membership.purchase.service.js');
  const {
    MembershipAdminQueryService,
  } = require('../dist/modules/membership/membership-admin-query.service.js');
  const {
    MembershipPurchasePresenter,
  } = require('../dist/modules/membership/membership.purchase.presenter.js');
  const {
    MembershipOrderEntity,
  } = require('../dist/modules/membership/entities/membership-order.entity.js');
  const {
    OrganizationPaidMembershipEntity,
  } = require('../dist/modules/membership/entities/organization-paid-membership.entity.js');
  const {
    PaymentOrderEntity,
  } = require('../dist/modules/p0_pay/entities/payment-order.entity.js');
  const {
    PaymentIdempotencyRecordEntity,
  } = require('../dist/modules/p0_pay/entities/payment-idempotency-record.entity.js');

  const stores = {
    membershipOrders: [],
    paidMemberships: [],
    paymentOrders: [],
    idempotencyRecords: [],
  };
  const repositories = new Map([
    [MembershipOrderEntity, createRepository(stores.membershipOrders)],
    [OrganizationPaidMembershipEntity, createRepository(stores.paidMemberships)],
    [PaymentOrderEntity, createRepository(stores.paymentOrders)],
    [PaymentIdempotencyRecordEntity, createRepository(stores.idempotencyRecords)],
  ]);
  const dataSource = {
    async transaction(work) {
      return work({
        getRepository(entity) {
          const repository = repositories.get(entity);
          if (!repository) throw new Error(`missing repo for ${entity.name}`);
          return repository;
        },
      });
    },
  };
  const auth = {
    async verifyCurrentSessionContext(context) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'actor-1',
          userId: 'user-1',
          organizationId: 'org-1',
          requestId: context.requestId,
          traceId: context.traceId,
        },
      };
    },
  };
  const eligibility = {
    async requireAuthenticatedActor() {
      return { id: 'user-1', status: 'active' };
    },
    async getCurrentOrganizationScope() {
      return { organization: { id: 'org-1' } };
    },
    async requireReviewer() {
      return { userId: 'user-1', roleKey: 'platform_reviewer' };
    },
  };
  const membershipQuery = {
    async getPaidMembershipTierSnapshotForOrganization() {
      return {
        tierCode: null,
        effectiveAt: null,
        expiresAt: null,
        sourceType: null,
        sourceRef: null,
      };
    },
  };
  const paymentChannelService = {
    buildChannelAction(input) {
      return {
        channelActionType: input.channel === 'alipay' ? 'sdk_payload' : 'web_redirect',
        channelPayload: {
          paymentOrderId: input.paymentOrderId,
          merchantOrderNo: input.merchantOrderNo,
          amount: input.amount,
          currency: input.currency,
          channel: input.channel,
          clientPlatform: input.clientPlatform,
        },
        callbackAwaiting: true,
      };
    },
  };
  const service = new MembershipPurchaseService(
    repositories.get(MembershipOrderEntity),
    repositories.get(OrganizationPaidMembershipEntity),
    repositories.get(PaymentOrderEntity),
    repositories.get(PaymentIdempotencyRecordEntity),
    dataSource,
    auth,
    eligibility,
    membershipQuery,
    paymentChannelService,
    new MembershipPurchasePresenter(),
  );
  const adminService = new MembershipAdminQueryService(
    repositories.get(MembershipOrderEntity),
    repositories.get(OrganizationPaidMembershipEntity),
    repositories.get(PaymentOrderEntity),
    auth,
    eligibility,
  );
  const context = {
    authorization: 'Bearer token',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'org-1',
    actorRole: 'buyer_admin',
    requestId: 'req-1',
    traceId: 'trace-1',
    userAgent: '',
    remoteIp: '',
  };
  return {
    service,
    adminService,
    stores,
    repositories,
    dataSource,
    context,
    PaymentOrderEntity,
  };
}

test('membership purchase catalog freezes standard/professional annual SKU prices', () => {
  const {
    MEMBERSHIP_PURCHASE_SKUS,
    MEMBERSHIP_PURCHASE_CHANNEL_CANDIDATES,
  } = require('../dist/modules/membership/membership.purchase.catalog.js');

  assert.deepEqual(
    MEMBERSHIP_PURCHASE_SKUS.map((sku) => ({
      skuCode: sku.skuCode,
      priceAmount: sku.priceAmount,
      durationMonths: sku.durationMonths,
      status: sku.status,
    })),
    [
      {
        skuCode: 'membership_standard_year_v1',
        priceAmount: '2599.00',
        durationMonths: 12,
        status: 'available',
      },
      {
        skuCode: 'membership_professional_year_v1',
        priceAmount: '4599.00',
        durationMonths: 12,
        status: 'available',
      },
    ],
  );
  assert.deepEqual(MEMBERSHIP_PURCHASE_CHANNEL_CANDIDATES, [
    'alipay_candidate',
    'wechat_candidate',
  ]);
});

test('membership direct purchase creates order, initializes payment and grants entitlement only after success callback', async () => {
  const { service, stores, repositories, dataSource, context, PaymentOrderEntity } = createHarness();

  const offers = await service.getPurchaseOffers(context);
  assert.equal(offers.offers[0].skuCode, 'membership_standard_year_v1');
  assert.equal(offers.offers[0].priceAmount, 2599);
  assert.deepEqual(offers.channelCandidates, ['alipay_candidate', 'wechat_candidate']);

  const created = await service.createOrder({
    skuCode: 'membership_standard_year_v1',
    purchaseIntentType: 'new_purchase',
    expectedAmount: 2599,
    expectedCurrency: 'CNY',
    idempotencyKey: 'create-key',
  }, context);
  assert.equal(created.orderStatus, 'created');
  assert.equal(created.payableAmount, 2599);
  assert.equal(stores.paidMemberships.length, 0);

  const duplicateCreated = await service.createOrder({
    skuCode: 'membership_standard_year_v1',
    purchaseIntentType: 'new_purchase',
    expectedAmount: 2599,
    expectedCurrency: 'CNY',
    idempotencyKey: 'create-key',
  }, context);
  assert.equal(duplicateCreated.membershipOrderId, created.membershipOrderId);
  assert.equal(stores.membershipOrders.length, 1);

  await assert.rejects(
    () => service.createOrder({
      skuCode: 'membership_standard_year_v1',
      purchaseIntentType: 'new_purchase',
      expectedAmount: 2999,
      expectedCurrency: 'CNY',
      idempotencyKey: 'bad-price',
    }, context),
    /price echo/,
  );

  const payInit = await service.payInit(created.membershipOrderId, {
    payChannel: 'alipay_candidate',
    clientPlatform: 'android',
    idempotencyKey: 'pay-key',
  }, context);
  assert.equal(payInit.paymentInitStatus, 'pending_user_confirm');
  assert.equal(payInit.channelActionType, 'sdk_payload');
  assert.equal(stores.paymentOrders.length, 1);

  const beforeSuccess = await service.getOrder(created.membershipOrderId, context);
  assert.equal(beforeSuccess.paymentStatus, 'pending');
  assert.equal(beforeSuccess.entitlementStatus, 'not_granted');
  assert.equal(stores.paidMemberships.length, 0);

  const paymentOrder = await repositories.get(PaymentOrderEntity).findOneBy({
    id: stores.paymentOrders[0].id,
  });
  await dataSource.transaction((manager) =>
    service.applyPaymentSuccess(manager, paymentOrder, context)
  );
  await dataSource.transaction((manager) =>
    service.applyPaymentSuccess(manager, paymentOrder, context)
  );

  const afterSuccess = await service.getOrder(created.membershipOrderId, context);
  assert.equal(afterSuccess.orderStatus, 'active');
  assert.equal(afterSuccess.paymentStatus, 'succeeded');
  assert.equal(afterSuccess.entitlementStatus, 'active');
  assert.equal(afterSuccess.skuSnapshot.membershipTier, 'standard');
  assert.equal(stores.paidMemberships.length, 1);
});

test('membership direct purchase payment failure does not grant entitlement', async () => {
  const { service, stores, repositories, dataSource, context, PaymentOrderEntity } = createHarness();
  const created = await service.createOrder({
    skuCode: 'membership_professional_year_v1',
    purchaseIntentType: 'new_purchase',
    expectedAmount: 4599,
    expectedCurrency: 'CNY',
    idempotencyKey: 'create-pro-key',
  }, context);
  await service.payInit(created.membershipOrderId, {
    payChannel: 'wechat_candidate',
    clientPlatform: 'android',
    idempotencyKey: 'pay-pro-key',
  }, context);
  const paymentOrder = await repositories.get(PaymentOrderEntity).findOneBy({
    id: stores.paymentOrders[0].id,
  });
  await dataSource.transaction((manager) =>
    service.applyPaymentFailure(manager, paymentOrder)
  );
  const result = await service.getOrder(created.membershipOrderId, context);
  assert.equal(result.orderStatus, 'failed');
  assert.equal(result.paymentStatus, 'failed');
  assert.equal(result.entitlementStatus, 'not_granted');
  assert.equal(stores.paidMemberships.length, 0);
});

test('membership admin query is read-only for orders and current organization status', async () => {
  const {
    service,
    adminService,
    stores,
    repositories,
    dataSource,
    context,
    PaymentOrderEntity,
  } = createHarness();
  const created = await service.createOrder({
    skuCode: 'membership_standard_year_v1',
    purchaseIntentType: 'new_purchase',
    expectedAmount: 2599,
    expectedCurrency: 'CNY',
    idempotencyKey: 'admin-create-key',
  }, context);
  await service.payInit(created.membershipOrderId, {
    payChannel: 'alipay_candidate',
    clientPlatform: 'android',
    idempotencyKey: 'admin-pay-key',
  }, context);
  const paymentOrder = await repositories.get(PaymentOrderEntity).findOneBy({
    id: stores.paymentOrders[0].id,
  });
  await dataSource.transaction((manager) =>
    service.applyPaymentSuccess(manager, paymentOrder, context)
  );

  const list = await adminService.listOrders({
    organizationId: 'org-1',
    page: 1,
    pageSize: 10,
  }, context);
  assert.equal(list.readOnly, true);
  assert.equal(list.writeActionsEnabled, false);
  assert.equal(list.items.length, 1);
  assert.equal(list.items[0].membershipOrderId, created.membershipOrderId);
  assert.equal(list.items[0].governanceBoundary.refundEnabled, false);
  assert.equal(list.items[0].channelSummary.payChannel, 'alipay_candidate');

  const detail = await adminService.getOrderDetail(created.membershipOrderId, context);
  assert.equal(detail.order.entitlementStatus, 'active');
  assert.equal(detail.currentMembership.paidMembershipTier, 'standard');
  assert.equal(detail.writeActionsEnabled, false);

  const status = await adminService.getOrganizationMembershipStatus('org-1', context);
  assert.equal(status.membershipStatus.paidMembershipTier, 'standard');
  assert.equal(status.writeActionsEnabled, false);
});

test('membership purchase migration creates membership_orders and admits payment business type', () => {
  const { membershipPurchaseMigrations, serverMigrations } = require('../dist/core/migrations/migrations.js');
  const sql = membershipPurchaseMigrations.flatMap((item) => item.statements).join('\n');

  assert.ok(membershipPurchaseMigrations.some((item) => item.key === '20260501_membership_direct_purchase_minimum_loop'));
  assert.ok(serverMigrations.includes(membershipPurchaseMigrations[0]));
  assert.match(sql, /CREATE TABLE IF NOT EXISTS membership_orders/);
  assert.match(sql, /membership_direct_purchase/);
  assert.match(sql, /CHECK \(business_type IN/);
  assert.doesNotMatch(sql, /DROP TABLE/i);
  assert.doesNotMatch(sql, /DROP COLUMN/i);
});
