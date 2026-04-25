const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId = 'project-counterparty-rating-test') {
  return {
    authorization: 'Bearer project-counterparty-rating-test',
    actorId: '',
    userId: '',
    organizationId: '',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

function createActorServices(organizationId = 'buyer-org') {
  return {
    verifier: {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'actor-1',
            userId: 'user-1',
            organizationId,
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    eligibility: {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return {
          organization: { id: organizationId },
          membership: { roleKey: 'member' },
          certification: { certificationStatus: 'approved' },
          roleKeys: ['member'],
        };
      },
    },
  };
}

function createOrder(state = 'completed') {
  return {
    orderId: 'order-1',
    projectId: 'project-1',
    buyerOrganizationId: 'buyer-org',
    supplierOrganizationId: 'supplier-org',
    orderState: state,
  };
}

function createHarness({
  actorOrganizationId = 'buyer-org',
  order = createOrder(),
  existing = null,
  saveError = null,
} = {}) {
  const saved = [];
  const audits = [];
  const shadowCalls = [];
  const { verifier, eligibility } = createActorServices(actorOrganizationId);
  const repository = {
    async findOneBy() {
      return existing;
    },
    create(value) {
      return value;
    },
    async save(value) {
      if (saveError) {
        throw saveError;
      }
      saved.push(value);
      return value;
    },
  };
  const manager = {
    async query(sql, params) {
      if (sql.includes('from public.orders "order"')) {
        return order && params[0] === order.orderId && params[1] === order.projectId
          ? [order]
          : [];
      }
      throw new Error(`Unexpected SQL: ${sql}`);
    },
    getRepository() {
      return repository;
    },
  };
  const dataSource = {
    manager,
    async transaction(callback) {
      return callback(manager);
    },
  };
  const auditService = {
    async record(event) {
      audits.push(event);
    },
  };
  const shadowAggregationService = {
    async recomputeAfterFormalRatingSubmit(input) {
      shadowCalls.push({ ...input });
      return { organizationId: input.organizationId };
    },
  };

  return {
    verifier,
    eligibility,
    repository,
    dataSource,
    auditService,
    shadowAggregationService,
    saved,
    audits,
    shadowCalls,
  };
}

function createService(harness) {
  const {
    ProjectCounterpartyRatingPresenter,
  } = require('../dist/modules/project_counterparty_rating/project-counterparty-rating.presenter.js');
  const {
    ProjectCounterpartyRatingService,
  } = require('../dist/modules/project_counterparty_rating/project-counterparty-rating.service.js');

  return new ProjectCounterpartyRatingService(
    harness.repository,
    harness.dataSource,
    harness.verifier,
    harness.eligibility,
    new ProjectCounterpartyRatingPresenter(),
    harness.auditService,
    harness.shadowAggregationService,
  );
}

test('project counterparty rating entry requires orderId, projectId, and rateeOrganizationId', async () => {
  const harness = createHarness();
  const service = createService(harness);

  await assert.rejects(
    () => service.getEntry({ orderId: 'order-1', projectId: 'project-1' }, createContext('rating-entry-invalid')),
    (error) => error?.response?.code === 'PROJECT_COUNTERPARTY_RATING_INVALID',
  );
});

test('project counterparty rating entry opens only on completed order without existing direction', async () => {
  const harness = createHarness();
  const service = createService(harness);

  const result = await service.getEntry(
    {
      orderId: 'order-1',
      projectId: 'project-1',
      rateeOrganizationId: 'supplier-org',
    },
    createContext('rating-entry-ok'),
  );

  assert.deepEqual(result, {
    orderId: 'order-1',
    projectId: 'project-1',
    raterOrganizationId: 'buyer-org',
    rateeOrganizationId: 'supplier-org',
    canRate: true,
    reason: null,
    ratingState: null,
  });
});

test('project counterparty rating entry is read-only before order completed', async () => {
  const harness = createHarness({ order: createOrder('active') });
  const service = createService(harness);

  const result = await service.getEntry(
    {
      orderId: 'order-1',
      projectId: 'project-1',
      rateeOrganizationId: 'supplier-org',
    },
    createContext('rating-entry-active-order'),
  );

  assert.deepEqual(result, {
    orderId: 'order-1',
    projectId: 'project-1',
    raterOrganizationId: 'buyer-org',
    rateeOrganizationId: 'supplier-org',
    canRate: false,
    reason: '当前项目/订单尚未完成，双方互评入口不会开放。',
    ratingState: null,
  });
});

test('project counterparty rating entry is read-only after same direction submitted', async () => {
  const harness = createHarness({
    existing: {
      id: 'rating-1',
      orderId: 'order-1',
      projectId: 'project-1',
      raterOrganizationId: 'buyer-org',
      rateeOrganizationId: 'supplier-org',
      ratingState: 'submitted',
    },
  });
  const service = createService(harness);

  const result = await service.getEntry(
    {
      orderId: 'order-1',
      projectId: 'project-1',
      rateeOrganizationId: 'supplier-org',
    },
    createContext('rating-entry-duplicate-direction'),
  );

  assert.deepEqual(result, {
    orderId: 'order-1',
    projectId: 'project-1',
    raterOrganizationId: 'buyer-org',
    rateeOrganizationId: 'supplier-org',
    canRate: false,
    reason: '当前方向已经提交过评价，不允许重复提交。',
    ratingState: 'submitted',
  });
});

test('project counterparty rating submit persists direction truth and audit', async () => {
  const harness = createHarness();
  const service = createService(harness);

  const result = await service.submit(
    {
      orderId: 'order-1',
      projectId: 'project-1',
      rateeOrganizationId: 'supplier-org',
      scoreLabel: 'very_satisfied',
      commentText: '合作顺畅',
    },
    createContext('rating-submit-ok'),
  );

  assert.equal(harness.saved.length, 1);
  assert.equal(harness.saved[0].orderId, 'order-1');
  assert.equal(harness.saved[0].projectId, 'project-1');
  assert.equal(harness.saved[0].raterOrganizationId, 'buyer-org');
  assert.equal(harness.saved[0].rateeOrganizationId, 'supplier-org');
  assert.equal(harness.saved[0].scoreValue, 5);
  assert.equal(harness.saved[0].scoreLabel, 'very_satisfied');
  assert.equal(harness.saved[0].ratingState, 'submitted');
  assert.equal(harness.audits.length, 1);
  assert.equal(harness.audits[0].eventType, 'ProjectCounterpartyRatingSubmitted');
  assert.equal(harness.shadowCalls.length, 1);
  assert.equal(harness.shadowCalls[0].organizationId, 'supplier-org');
  assert.equal(harness.shadowCalls[0].sourceType, 'project_counterparty_rating');
  assert.equal(harness.shadowCalls[0].sourceOrderId, 'order-1');
  assert.equal(harness.shadowCalls[0].sourceRatingId, harness.saved[0].id);
  assert.equal(result.ratingId, harness.saved[0].id);
  assert.equal(result.state, 'submitted');
});

test('project counterparty rating submit rejects active order before writing truth or credit trigger', async () => {
  const harness = createHarness({ order: createOrder('active') });
  const service = createService(harness);

  await assert.rejects(
    () =>
      service.submit(
        {
          orderId: 'order-1',
          projectId: 'project-1',
          rateeOrganizationId: 'supplier-org',
          scoreLabel: 'very_satisfied',
        },
        createContext('rating-submit-active-order'),
      ),
    (error) => error?.response?.code === 'PROJECT_COUNTERPARTY_RATING_UNAVAILABLE',
  );

  assert.equal(harness.saved.length, 0);
  assert.equal(harness.audits.length, 0);
  assert.equal(harness.shadowCalls.length, 0);
});

test('project counterparty rating submit allows reverse supplier-to-buyer direction', async () => {
  const harness = createHarness({ actorOrganizationId: 'supplier-org' });
  const service = createService(harness);

  const result = await service.submit(
    {
      orderId: 'order-1',
      projectId: 'project-1',
      rateeOrganizationId: 'buyer-org',
      scoreLabel: 'satisfied',
    },
    createContext('rating-submit-reverse-ok'),
  );

  assert.equal(result.raterOrganizationId, 'supplier-org');
  assert.equal(result.rateeOrganizationId, 'buyer-org');
  assert.equal(harness.shadowCalls.length, 1);
  assert.equal(harness.shadowCalls[0].organizationId, 'buyer-org');
  assert.equal(harness.shadowCalls[0].sourceType, 'project_counterparty_rating');
});

test('project counterparty rating submit rejects duplicate direction', async () => {
  const harness = createHarness({
    existing: {
      id: 'rating-1',
      orderId: 'order-1',
      projectId: 'project-1',
      raterOrganizationId: 'buyer-org',
      rateeOrganizationId: 'supplier-org',
      ratingState: 'submitted',
    },
  });
  const service = createService(harness);

  await assert.rejects(
    () =>
      service.submit(
        {
          orderId: 'order-1',
          projectId: 'project-1',
          rateeOrganizationId: 'supplier-org',
          scoreLabel: 'very_satisfied',
        },
        createContext('rating-submit-duplicate'),
      ),
    (error) => error?.response?.code === 'PROJECT_COUNTERPARTY_RATING_DUPLICATE',
  );
});

test('project counterparty rating submit maps unique direction race to duplicate', async () => {
  const harness = createHarness({ saveError: { code: '23505' } });
  const service = createService(harness);

  await assert.rejects(
    () =>
      service.submit(
        {
          orderId: 'order-1',
          projectId: 'project-1',
          rateeOrganizationId: 'supplier-org',
          scoreLabel: 'very_satisfied',
        },
        createContext('rating-submit-unique-race'),
      ),
    (error) => error?.response?.code === 'PROJECT_COUNTERPARTY_RATING_DUPLICATE',
  );

  assert.equal(harness.saved.length, 0);
  assert.equal(harness.audits.length, 0);
  assert.equal(harness.shadowCalls.length, 0);
});

test('project counterparty rating submit rejects outside order boundary', async () => {
  const harness = createHarness();
  const service = createService(harness);

  await assert.rejects(
    () =>
      service.submit(
        {
          orderId: 'order-1',
          projectId: 'project-1',
          rateeOrganizationId: 'outside-org',
          scoreLabel: 'very_satisfied',
        },
        createContext('rating-submit-outside'),
      ),
    (error) => error?.response?.code === 'PROJECT_COUNTERPARTY_RATING_FORBIDDEN',
  );
});
