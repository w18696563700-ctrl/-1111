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

test('milestone/list strips upstream details while keeping stable invalid code and message', async () => {
  const service = createService({
    async onGet() {
      throw createAxiosError(
        400,
        'MILESTONE_QUERY_INVALID',
        'Query parameter `orderId` failed validation.',
      );
    },
  });

  await assert.rejects(
    () => service.getMilestoneList('order-1', {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'MILESTONE_LIST_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前里程碑列表参数无效，请检查后再试。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('inspection/detail strips upstream details while keeping stable unavailable code and message', async () => {
  const service = createService({
    async onGet() {
      throw createAxiosError(
        409,
        'INSPECTION_NOT_AVAILABLE',
        'Current inspection detail is unavailable for this milestone.',
      );
    },
  });

  await assert.rejects(
    () => service.getInspectionDetail('milestone-1', {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'INSPECTION_ENTRY_UNAVAILABLE');
      assert.equal(
        error.getResponse().message,
        '当前验收详情暂不可用，请稍后再试。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});
