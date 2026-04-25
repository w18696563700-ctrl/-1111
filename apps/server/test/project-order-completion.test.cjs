const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId) {
  return {
    authorization: 'Bearer order-completion-token',
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

function createOrder(overrides = {}) {
  return {
    orderId: 'order-1',
    orderNo: 'ORD-1',
    projectId: 'project-1',
    buyerOrganizationId: 'buyer-org',
    sellerOrganizationId: 'seller-org',
    state: 'active',
    completionRequestState: 'none',
    ...overrides,
  };
}

function createHarness(initialOrder = createOrder()) {
  const state = {
    order: structuredClone(initialOrder),
    audits: [],
  };

  return {
    state,
    repository: {
      manager: {
        async transaction(callback) {
          const draft = structuredClone(state);
          const manager = {
            async query(sql, params) {
              if (sql.includes('from public.orders "order"') && sql.includes('for update')) {
                return draft.order && draft.order.orderId === params[0] ? [draft.order] : [];
              }
              if (sql.includes('completion_request_state = $2') && sql.includes('completion_requested_at')) {
                draft.order.completionRequestState = params[1];
                draft.order.completionRequestedBy = params[2];
                draft.order.completionRequestedByOrganizationId = params[3];
                draft.order.completionRequestNote = params[4];
                return [];
              }
              if (sql.includes('state = $2') && sql.includes('completion_confirmed_at')) {
                draft.order.state = params[1];
                draft.order.completionRequestState = params[2];
                draft.order.completionConfirmedBy = params[3];
                draft.order.completionConfirmedByOrganizationId = params[4];
                return [];
              }
              if (sql.includes('completion_request_state = $2') && sql.includes('completion_rejected_at')) {
                draft.order.completionRequestState = params[1];
                draft.order.completionRejectedBy = params[2];
                draft.order.completionRejectedByOrganizationId = params[3];
                draft.order.completionRejectionReason = params[4];
                return [];
              }
              throw new Error(`unexpected sql: ${sql}`);
            },
            getRepository(entity) {
              if (entity.name === 'IdentityAuditLogEntity') {
                return {
                  async save(value) {
                    draft.audits.push(value);
                    return value;
                  },
                };
              }
              throw new Error(`unexpected repository ${entity?.name ?? 'unknown'}`);
            },
          };
          const result = await callback(manager);
          Object.assign(state, draft);
          return result;
        },
      },
    },
  };
}

function createEligibilityService(organizationId, roleKey = 'member') {
  return {
    async requireAuthenticatedActor() {
      return { id: `${organizationId}-user`, status: 'active' };
    },
    async getCurrentOrganizationScope() {
      return {
        organization: { id: organizationId },
        membership: { roleKey },
      };
    },
  };
}

function createVerifier(organizationId) {
  return {
    async verifyCurrentSessionContext(context) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: `session-${organizationId}`,
          actorId: `${organizationId}-actor`,
          userId: `${organizationId}-user`,
          organizationId,
          requestId: context.requestId,
          traceId: context.traceId,
        },
      };
    },
  };
}

function createService(harness, organizationId, roleKey = 'member') {
  const {
    ProjectOrderCompletionPresenter,
  } = require('../dist/modules/order/project-order-completion.presenter.js');
  const {
    ProjectOrderCompletionService,
  } = require('../dist/modules/order/project-order-completion.service.js');

  return new ProjectOrderCompletionService(
    harness.repository,
    createVerifier(organizationId),
    createEligibilityService(organizationId, roleKey),
    new ProjectOrderCompletionPresenter(),
  );
}

test('ProjectOrder completion request is seller-only and keeps order active', async () => {
  const harness = createHarness();
  const service = createService(harness, 'seller-org', 'supplier_admin');

  const result = await service.requestCompletion(
    { orderId: 'order-1', note: '现场已完成，请确认。' },
    createContext('completion-request'),
  );

  assert.equal(result.orderId, 'order-1');
  assert.equal(result.state, 'active');
  assert.equal(result.completionRequestState, 'requested');
  assert.equal(harness.state.order.state, 'active');
  assert.equal(harness.state.order.completionRequestState, 'requested');
  assert.equal(harness.state.audits.length, 1);
  assert.equal(harness.state.audits[0].action, 'OrderCompletionRequested');
});

test('ProjectOrder completion confirm is buyer-only and opens completed-order rating gate', async () => {
  const harness = createHarness(createOrder({ completionRequestState: 'requested' }));
  const service = createService(harness, 'buyer-org', 'buyer_admin');

  const result = await service.confirmCompletion(
    { orderId: 'order-1' },
    createContext('completion-confirm'),
  );

  assert.equal(result.state, 'completed');
  assert.equal(result.completionRequestState, 'confirmed');
  assert.equal(harness.state.order.state, 'completed');
  assert.equal(harness.state.order.completionRequestState, 'confirmed');
  assert.equal(harness.state.audits.length, 1);
  assert.equal(harness.state.audits[0].action, 'OrderCompleted');
});

test('ProjectOrder completion confirm rejects active orders without a pending request', async () => {
  const harness = createHarness(createOrder({ completionRequestState: 'none' }));
  const service = createService(harness, 'buyer-org', 'buyer_admin');

  await assert.rejects(
    () => service.confirmCompletion({ orderId: 'order-1' }, createContext('completion-no-request')),
    (error) => error?.response?.code === 'PROJECT_ORDER_COMPLETE_INVALID_STATE',
  );
  assert.equal(harness.state.order.state, 'active');
  assert.equal(harness.state.audits.length, 0);
});

test('ProjectOrder completion reject can reserve dispute without completing order', async () => {
  const harness = createHarness(createOrder({ completionRequestState: 'requested' }));
  const service = createService(harness, 'buyer-org', 'buyer_admin');

  const result = await service.rejectCompletion(
    { orderId: 'order-1', reason: '现场仍需整改', reserveDispute: true },
    createContext('completion-reject'),
  );

  assert.equal(result.state, 'active');
  assert.equal(result.completionRequestState, 'dispute_reserved');
  assert.equal(harness.state.order.state, 'active');
  assert.equal(harness.state.order.completionRequestState, 'dispute_reserved');
  assert.equal(harness.state.audits.length, 1);
  assert.equal(harness.state.audits[0].action, 'OrderCompletionDisputeReserved');
});

test('ProjectOrder completion request rejects buyer actor', async () => {
  const harness = createHarness();
  const service = createService(harness, 'buyer-org', 'buyer_admin');

  await assert.rejects(
    () => service.requestCompletion({ orderId: 'order-1' }, createContext('completion-wrong-side')),
    (error) => error?.response?.code === 'AUTH_PERMISSION_INSUFFICIENT',
  );
  assert.equal(harness.state.audits.length, 0);
});
