const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  BidOrderSelectionService,
} = require('../dist/apps/bff/src/routes/bid/bid-order-selection.service.js');

function createService({ onPost } = {}) {
  return new BidOrderSelectionService(
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
    new ErrorNormalizerService(),
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
        source: 'server',
      },
    },
  };
}

test('select-bid-and-create-order forwards canonical payload and returns order routeTarget', async () => {
  let capturedPayload = null;
  let capturedHeaders = null;
  const service = createService({
    async onPost(path, payload, options) {
      assert.equal(path, '/server/bid/select-bid-and-create-order');
      capturedPayload = payload;
      capturedHeaders = options.headers;
      return {
        bidAwardId: 'award-1',
        projectId: 'project-1',
        winningBidId: 'bid-1',
        orderId: 'order-1',
        contractId: 'contract-1',
        state: 'converted_to_order',
      };
    },
  });

  const result = await service.selectBidAndCreateOrder(
    {
      projectId: ' project-1 ',
      winningBidId: ' bid-1 ',
      reasonCode: ' best_fit ',
      reasonText: ' Overall best fit. ',
      extra: 'must-not-forward',
    },
    {
      authorization: 'Bearer smoke',
      'x-organization-id': 'buyer-org',
    },
  );

  assert.deepEqual(capturedPayload, {
    projectId: 'project-1',
    winningBidId: 'bid-1',
    reasonCode: 'best_fit',
    reasonText: 'Overall best fit.',
  });
  assert.deepEqual(capturedHeaders, {
    authorization: 'Bearer smoke',
    'x-organization-id': 'buyer-org',
  });
  assert.deepEqual(result, {
    bidAwardId: 'award-1',
    projectId: 'project-1',
    winningBidId: 'bid-1',
    orderId: 'order-1',
    contractId: 'contract-1',
    state: 'converted_to_order',
    actionKey: 'bid_select_create_order.submit',
    routeTarget: {
      objectType: 'order',
      actionKey: 'order_detail.open',
      canonicalPath: '/api/app/order/detail',
      params: {
        orderId: 'order-1',
        projectId: 'project-1',
        winningBidId: 'bid-1',
        bidAwardId: 'award-1',
        contractId: 'contract-1',
      },
    },
  });
});

test('select-bid-and-create-order rejects missing winningBidId locally', async () => {
  const service = createService({
    async onPost() {
      throw new Error('must not forward');
    },
  });

  await assert.rejects(
    () =>
      service.selectBidAndCreateOrder(
        {
          projectId: 'project-1',
          reasonCode: 'best_fit',
          reasonText: 'Overall best fit.',
        },
        { authorization: 'Bearer smoke' },
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'BID_AWARD_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前选择合作方参数无效，请检查后再试。',
      );
      return true;
    },
  );
});

test('select-bid-and-create-order maps route drift to stable unavailable message', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        404,
        'AUTH_RESOURCE_UNAVAILABLE',
        'Cannot POST /server/bid/select-bid-and-create-order',
      );
    },
  });

  await assert.rejects(
    () =>
      service.selectBidAndCreateOrder(
        {
          projectId: 'project-1',
          winningBidId: 'bid-1',
          reasonCode: 'best_fit',
          reasonText: 'Overall best fit.',
        },
        { authorization: 'Bearer smoke' },
      ),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.equal(error.getResponse().code, 'AUTH_RESOURCE_UNAVAILABLE');
      assert.equal(
        error.getResponse().message,
        '当前选择合作方入口暂不可用，请稍后再试。',
      );
      return true;
    },
  );
});
