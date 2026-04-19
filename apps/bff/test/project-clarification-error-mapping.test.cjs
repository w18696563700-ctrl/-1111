const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  TradingImService,
} = require('../dist/apps/bff/src/routes/trading_im/trading-im.service.js');

function createAxiosError(status, payload) {
  return {
    isAxiosError: true,
    code: 'ERR_BAD_REQUEST',
    message: `Request failed with status code ${status}`,
    response: {
      status,
      data: payload,
    },
  };
}

function createService(error) {
  return new TradingImService(
    {
      async get() {
        throw error;
      },
      async post() {
        throw error;
      },
    },
    {
      buildForwardHeaders() {
        return { 'x-actor-id': 'actor-1' };
      },
    },
    new ErrorNormalizerService(),
  );
}

test('project clarification 404 hides raw upstream route message', async () => {
  const service = createService(
    createAxiosError(404, {
      statusCode: 404,
      message: 'Cannot GET /server/trading-im/project/clarification/list',
      error: 'Not Found',
      source: 'server',
    }),
  );

  await assert.rejects(
    () => service.listProjectClarifications('project-1', {}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.deepEqual(error.getResponse(), {
        statusCode: 404,
        code: 'PROJECT_CLARIFICATION_UNAVAILABLE',
        message: '当前项目澄清入口暂不可用，请稍后再试。',
        source: 'server',
      });
      return true;
    },
  );
});
