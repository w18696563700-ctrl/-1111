const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  TradingReadCorridorErrorService,
} = require('../dist/apps/bff/src/routes/trading_read_corridor/trading-read-corridor.error.service.js');
const {
  TradingReadCorridorService,
} = require('../dist/apps/bff/src/routes/trading_read_corridor/trading-read-corridor.service.js');

function createService({ onGet } = {}) {
  return new TradingReadCorridorService(
    {
      async get(path, options) {
        return onGet(path, options);
      },
    },
    {
      buildReadOnlyForwardHeaders() {
        return { authorization: 'Bearer smoke' };
      },
    },
    new TradingReadCorridorErrorService(new ErrorNormalizerService()),
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

test('order/detail fails closed on missing orderId and does not forward upstream', async () => {
  let forwarded = false;
  const service = createService({
    async onGet() {
      forwarded = true;
      return {};
    },
  });

  await assert.rejects(
    () => service.getOrderDetail(undefined, undefined, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'ORDER_DETAIL_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前订单标识缺失，请重新进入订单详情后再试。',
      );
      return true;
    },
  );
  assert.equal(forwarded, false);
});

test('contract/detail fails closed on missing orderId and does not forward upstream', async () => {
  let forwarded = false;
  const service = createService({
    async onGet() {
      forwarded = true;
      return {};
    },
  });

  await assert.rejects(
    () => service.getContractDetail('', {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'CONTRACT_DETAIL_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前合同标识缺失，请重新进入合同详情后再试。',
      );
      return true;
    },
  );
  assert.equal(forwarded, false);
});

test('order/detail translates upstream technical query failure into stable app-facing invalid message', async () => {
  const service = createService({
    async onGet() {
      throw createAxiosError(
        400,
        'ORDER_QUERY_INVALID',
        'Query parameter `orderId` failed validation.',
      );
    },
  });

  await assert.rejects(
    () => service.getOrderDetail('order-1', undefined, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'ORDER_DETAIL_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前订单详情参数无效，请检查后再试。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('order/detail forwards optional projectId when present', async () => {
  let captured = null;
  const service = createService({
    async onGet(path, options) {
      captured = { path, options };
      return {
        orderId: 'order-1',
        orderNo: 'ORD-1',
        projectId: 'project-1',
        bidId: 'bid-1',
        buyerOrganizationId: 'buyer-org',
        supplierOrganizationId: 'supplier-org',
        sellerOrganizationId: 'supplier-org',
        state: 'active',
        completionRequestState: 'none',
        summary: { heading: '订单详情' },
        milestones: [],
      };
    },
  });

  const result = await service.getOrderDetail(' order-1 ', ' project-1 ', {});

  assert.equal(result.orderId, 'order-1');
  assert.equal(result.buyerOrganizationId, 'buyer-org');
  assert.equal(result.supplierOrganizationId, 'supplier-org');
  assert.equal(result.sellerOrganizationId, 'supplier-org');
  assert.equal(result.completionRequestState, 'none');
  assert.equal(captured.path, '/server/order/detail');
  assert.deepEqual(captured.options.params, {
    orderId: 'order-1',
    projectId: 'project-1',
  });
});

test('contract/detail translates upstream unavailable into stable app-facing unavailable message', async () => {
  const service = createService({
    async onGet() {
      throw createAxiosError(
        404,
        'CONTRACT_NOT_FOUND',
        'Current contract detail record is unavailable.',
      );
    },
  });

  await assert.rejects(
    () => service.getContractDetail('order-2', {}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.equal(error.getResponse().code, 'AUTH_RESOURCE_UNAVAILABLE');
      assert.equal(
        error.getResponse().message,
        '当前合同详情暂不可用，请稍后再试。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});
