const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  BidService,
} = require('../dist/apps/bff/src/routes/bid/bid.service.js');

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

function createService(error) {
  return new BidService(
    {
      async get() {
        throw error;
      },
    },
    {
      buildForwardHeaders() {
        return {};
      },
      buildReadOnlyForwardHeaders() {
        return {};
      },
    },
    {
      async getCached() {
        return null;
      },
      async remember() {},
    },
    new ErrorNormalizerService(),
  );
}

test('BFF bid/result maps organization-type blocker to explicit bid-result message', async () => {
  const service = createService(
    createAxiosError(
      403,
      'AUTH_PERMISSION_INSUFFICIENT',
      'Current organization type is not allowed for bid result.',
    ),
  );

  await assert.rejects(
    () => service.getBidResult('project-1', {}),
    (thrown) => {
      assert.equal(thrown.getStatus(), 403);
      assert.equal(thrown.getResponse().code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(
        thrown.getResponse().message,
        '当前组织类型未开放竞标结果读取权限，请切换到供应商或需求方/供应商主体后再试。',
      );
      return true;
    },
  );
});
