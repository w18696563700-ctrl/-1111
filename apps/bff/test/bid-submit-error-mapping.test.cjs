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
      async post() {
        throw error;
      },
    },
    {
      buildForwardHeaders() {
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

function createValidPayload() {
  return {
    projectId: 'project-1',
    quoteAmount: 88888,
    proposalSummary: '供应商最小报价与执行方案',
  };
}

async function expectSubmitError(error, expectedStatus, expectedCode, expectedMessage) {
  const service = createService(error);
  await assert.rejects(
    () => service.submitBid(createValidPayload(), {}),
    (thrown) => {
      assert.equal(thrown.getStatus(), expectedStatus);
      assert.deepEqual(thrown.getResponse().code, expectedCode);
      assert.deepEqual(thrown.getResponse().message, expectedMessage);
      return true;
    },
  );
}

test('BFF bid/submit maps session invalid to login-specific app-facing message', async () => {
  await expectSubmitError(
    createAxiosError(401, 'AUTH_SESSION_INVALID', 'Current session is invalid.'),
    401,
    'AUTH_SESSION_INVALID',
    '当前登录态不可用，请重新登录后再试。',
  );
});

test('BFF bid/submit maps missing organization scope to organization-specific message', async () => {
  await expectSubmitError(
    createAxiosError(
      403,
      'AUTH_PERMISSION_INSUFFICIENT',
      'Current actor lacks the required organization scope for bid submit.',
    ),
    403,
    'AUTH_PERMISSION_INSUFFICIENT',
    '当前组织身份不可用，请先进入可投标的组织后再试。',
  );
});

test('BFF bid/submit maps organization-type blocker to the new bid eligibility message', async () => {
  await expectSubmitError(
    createAxiosError(
      403,
      'AUTH_PERMISSION_INSUFFICIENT',
      'Current organization type is not allowed for bid submit.',
    ),
    403,
    'AUTH_PERMISSION_INSUFFICIENT',
    '当前组织类型未开放竞标资格，请切换到供应商或需求方/供应商主体后再试。',
  );
});

test('BFF bid/submit maps unavailable project to resource-specific message', async () => {
  await expectSubmitError(
    createAxiosError(
      404,
      'AUTH_RESOURCE_UNAVAILABLE',
      'Current project is unavailable for bid submit.',
    ),
    404,
    'AUTH_RESOURCE_UNAVAILABLE',
    '当前项目不可用，暂时无法提交投标。',
  );
});

test('BFF bid/submit maps quoteAmount validation to exact Chinese message', async () => {
  await expectSubmitError(
    createAxiosError(
      400,
      'BID_SUBMIT_INVALID',
      'Field `quoteAmount` must be a positive number for bid submit.',
    ),
    400,
    'BID_SUBMIT_INVALID',
    '请先填写有效报价金额后再提交。',
  );
});

test('BFF bid/submit maps duplicate submission to controlled duplicate message', async () => {
  await expectSubmitError(
    createAxiosError(
      409,
      'BID_DUPLICATE_SUBMISSION',
      'Current actor has already submitted a bid for this project.',
    ),
    409,
    'BID_DUPLICATE_SUBMISSION',
    '当前项目已提交过投标，请勿重复提交。',
  );
});
