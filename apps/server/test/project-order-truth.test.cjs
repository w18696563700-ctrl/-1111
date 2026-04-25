const test = require('node:test');
const assert = require('node:assert/strict');

test('ProjectOrder truth state machine admits only production order transitions', () => {
  const {
    PROJECT_ORDER_ACTIVE_STATE,
    PROJECT_ORDER_COMPLETED_STATE,
    PROJECT_ORDER_CANCELLED_STATE,
    canTransitionProjectOrderState,
    isProjectOrderState,
    isProjectOrderCompletionRequestState,
    normalizeProjectOrderState,
  } = require('../dist/modules/order/project-order.state.js');

  assert.equal(isProjectOrderState(PROJECT_ORDER_ACTIVE_STATE), true);
  assert.equal(isProjectOrderState(PROJECT_ORDER_COMPLETED_STATE), true);
  assert.equal(isProjectOrderState(PROJECT_ORDER_CANCELLED_STATE), true);
  assert.equal(isProjectOrderState('竞标中'), false);
  assert.equal(normalizeProjectOrderState(' completed '), PROJECT_ORDER_COMPLETED_STATE);
  assert.equal(canTransitionProjectOrderState('active', 'completed'), true);
  assert.equal(canTransitionProjectOrderState('active', 'cancelled'), true);
  assert.equal(canTransitionProjectOrderState('completed', 'active'), false);
  assert.equal(canTransitionProjectOrderState('cancelled', 'active'), false);
  assert.equal(isProjectOrderCompletionRequestState('requested'), true);
  assert.equal(isProjectOrderCompletionRequestState('dispute_reserved'), true);
  assert.equal(isProjectOrderCompletionRequestState('completed'), false);
});

test('ProjectOrder truth anchor requires project, buyer, and seller organizations', () => {
  const {
    normalizeProjectOrderAnchor,
  } = require('../dist/modules/order/project-order.state.js');

  assert.deepEqual(
    normalizeProjectOrderAnchor({
      projectId: ' project-1 ',
      buyerOrganizationId: ' buyer-org ',
      sellerOrganizationId: ' seller-org ',
    }),
    {
      projectId: 'project-1',
      buyerOrganizationId: 'buyer-org',
      sellerOrganizationId: 'seller-org',
    },
  );
  assert.equal(
    normalizeProjectOrderAnchor({
      projectId: 'project-1',
      buyerOrganizationId: 'buyer-org',
      sellerOrganizationId: '',
    }),
    null,
  );
});

test('ProjectOrderService skeleton enforces anchor and state gates', () => {
  const { ProjectOrderService } = require('../dist/modules/order/project-order.service.js');
  const service = new ProjectOrderService({
    async findOne() {
      throw new Error('repository should not be called in this skeleton gate test');
    },
  });

  assert.deepEqual(
    service.requireTruthAnchor({
      projectId: 'project-1',
      buyerOrganizationId: 'buyer-org',
      sellerOrganizationId: 'seller-org',
    }),
    {
      projectId: 'project-1',
      buyerOrganizationId: 'buyer-org',
      sellerOrganizationId: 'seller-org',
    },
  );
  assert.throws(
    () => service.requireTruthAnchor({
      projectId: 'project-1',
      buyerOrganizationId: 'buyer-org',
      sellerOrganizationId: null,
    }),
    /ProjectOrder requires projectId/,
  );
  assert.equal(service.requireStateTransition('active', 'completed'), 'completed');
  assert.throws(
    () => service.requireStateTransition('completed', 'active'),
    /ProjectOrder state transition is not allowed/,
  );
});
