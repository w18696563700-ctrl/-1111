const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  OrderCompletionErrorService,
} = require('../dist/apps/bff/src/routes/order/order-completion.error.service.js');
const {
  OrderCompletionService,
} = require('../dist/apps/bff/src/routes/order/order-completion.service.js');

function createService({ onPost } = {}) {
  return new OrderCompletionService(
    {
      async post(path, payload, options) {
        return onPost(path, payload, options);
      },
    },
    {
      buildForwardHeaders(headers) {
        return {
          authorization: headers.authorization,
          'x-organization-id': headers['x-organization-id'],
        };
      },
    },
    new OrderCompletionErrorService(new ErrorNormalizerService()),
  );
}

function createAxiosError(status, code, message) {
  return {
    isAxiosError: true,
    code: 'ERR_BAD_REQUEST',
    message: `Request failed with status code ${status}`,
    response: {
      status,
      data: {
        code,
        message,
        details: {
          upstream: 'must-strip',
        },
        source: 'server',
      },
    },
  };
}

test('order/complete/request forwards canonical payload and returns order routeTarget', async () => {
  let capturedPayload = null;
  const service = createService({
    async onPost(path, payload) {
      assert.equal(path, '/server/order/complete/request');
      capturedPayload = payload;
      return {
        orderId: 'order-1',
        projectId: 'project-1',
        state: 'active',
        completionRequestState: 'requested',
        summary: { heading: '完工申请已提交，等待发布方确认。' },
      };
    },
  });

  const result = await service.requestCompletion(
    {
      orderId: ' order-1 ',
      note: ' Ready for acceptance. ',
      extra: 'must-not-forward',
    },
    {
      authorization: 'Bearer smoke',
      'x-organization-id': 'seller-org',
    },
  );

  assert.deepEqual(capturedPayload, {
    orderId: 'order-1',
    note: 'Ready for acceptance.',
  });
  assert.equal(result.actionKey, 'order_completion_request.submit');
  assert.deepEqual(result.routeTarget, {
    objectType: 'order',
    actionKey: 'order_detail.open',
    canonicalPath: '/api/app/order/detail',
    params: {
      orderId: 'order-1',
      projectId: 'project-1',
    },
  });
});

test('order/complete/confirm forwards orderId and exposes completed state', async () => {
  let capturedPayload = null;
  const service = createService({
    async onPost(path, payload) {
      assert.equal(path, '/server/order/complete/confirm');
      capturedPayload = payload;
      return {
        orderId: 'order-1',
        projectId: 'project-1',
        state: 'completed',
        completionRequestState: 'confirmed',
        summary: {
          heading: '订单已确认完成，双方互评入口将以 completed 订单真值开放。',
        },
      };
    },
  });

  const result = await service.confirmCompletion(
    { orderId: ' order-1 ', extra: 'must-not-forward' },
    { authorization: 'Bearer smoke' },
  );

  assert.deepEqual(capturedPayload, { orderId: 'order-1' });
  assert.equal(result.state, 'completed');
  assert.equal(result.completionRequestState, 'confirmed');
  assert.equal(result.actionKey, 'order_completion_confirm.submit');
});

test('order/complete/reject forwards reason and reserveDispute only', async () => {
  let capturedPayload = null;
  const service = createService({
    async onPost(path, payload) {
      assert.equal(path, '/server/order/complete/reject');
      capturedPayload = payload;
      return {
        orderId: 'order-1',
        projectId: 'project-1',
        state: 'active',
        completionRequestState: 'dispute_reserved',
        summary: { heading: '完工申请已拒绝，并保留争议入口。' },
      };
    },
  });

  const result = await service.rejectCompletion(
    {
      orderId: ' order-1 ',
      reason: ' Need one more fix. ',
      reserveDispute: true,
      extra: 'must-not-forward',
    },
    { authorization: 'Bearer smoke' },
  );

  assert.deepEqual(capturedPayload, {
    orderId: 'order-1',
    reason: 'Need one more fix.',
    reserveDispute: true,
  });
  assert.equal(result.actionKey, 'order_completion_reject.submit');
  assert.equal(result.completionRequestState, 'dispute_reserved');
});

test('order/complete/confirm rejects missing orderId locally', async () => {
  const service = createService({
    async onPost() {
      throw new Error('must not forward');
    },
  });

  await assert.rejects(
    () => service.confirmCompletion({ state: 'requested' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'PROJECT_ORDER_COMPLETE_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前完工确认参数无效，请检查后再试。',
      );
      return true;
    },
  );
});

test('order/complete/confirm strips upstream details and keeps stable invalid-state semantics', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        409,
        'PROJECT_ORDER_COMPLETE_INVALID_STATE',
        'Completion confirm requires a pending completion request.',
      );
    },
  });

  await assert.rejects(
    () => service.confirmCompletion({ orderId: 'order-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'PROJECT_ORDER_COMPLETE_INVALID_STATE');
      assert.equal(
        error.getResponse().message,
        '当前订单状态暂不支持确认完工。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});
