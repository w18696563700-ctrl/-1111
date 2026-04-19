const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  ProjectService,
} = require('../dist/apps/bff/src/routes/project/project.service.js');

function createAxiosError(status, code, message, details) {
  return {
    isAxiosError: true,
    code: 'ERR_BAD_REQUEST',
    message: `Request failed with status code ${status}`,
    response: {
      status,
      data: {
        code,
        message,
        ...(details ? { details } : {}),
        source: 'server',
      },
    },
  };
}

function createService(error) {
  return new ProjectService(
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
    new ErrorNormalizerService(),
  );
}

function createValidPayload() {
  return {
    title: '春季品牌展项目',
    buildingType: 'exhibition',
    budgetAmount: 120000,
    provinceCode: '310000',
    provinceName: '上海市',
    cityCode: '310100',
    cityName: '上海市',
    detailAddress: '浦东新区龙阳路 1 号',
    scopeSummary: '主场展位搭建与灯光优化',
  };
}

async function expectCreateError(error, expectedStatus, expectedCode, expectedMessage) {
  const service = createService(error);
  await assert.rejects(
    () => service.createProject(createValidPayload(), {}),
    (thrown) => {
      assert.equal(thrown.getStatus(), expectedStatus);
      assert.deepEqual(thrown.getResponse().code, expectedCode);
      assert.deepEqual(thrown.getResponse().message, expectedMessage);
      return true;
    },
  );
}

test('BFF project/create maps session invalid to login-specific app-facing message', async () => {
  await expectCreateError(
    createAxiosError(401, 'AUTH_SESSION_INVALID', 'Current session is invalid.'),
    401,
    'AUTH_SESSION_INVALID',
    '当前登录态不可用，请重新登录后再试。',
  );
});

test('BFF project/create maps missing organization scope to organization-specific message', async () => {
  await expectCreateError(
    createAxiosError(
      403,
      'AUTH_PERMISSION_INSUFFICIENT',
      'Forbidden by upstream.',
      { reason: 'organization_scope_missing' },
    ),
    403,
    'AUTH_PERMISSION_INSUFFICIENT',
    '当前组织身份不可用，请先进入可发布项目的组织后再试。',
  );
});

test('BFF project/create maps role-specific eligibility rejection to role message', async () => {
  await expectCreateError(
    createAxiosError(
      403,
      'AUTH_PERMISSION_INSUFFICIENT',
      'Forbidden by upstream.',
      { reason: 'buyer_role_not_allowed' },
    ),
    403,
    'AUTH_PERMISSION_INSUFFICIENT',
    '当前组织角色不具备项目发布资格，请切换到买方侧可发布角色后再试。',
  );
});

test('BFF project/create maps certification-specific eligibility rejection to certification message', async () => {
  await expectCreateError(
    createAxiosError(
      403,
      'AUTH_PERMISSION_INSUFFICIENT',
      'Forbidden by upstream.',
      { reason: 'certification_not_approved' },
    ),
    403,
    'AUTH_PERMISSION_INSUFFICIENT',
    '当前组织认证尚未通过，暂不可创建项目。',
  );
});

test('BFF project/create falls back to generic permission message when structured reason is absent', async () => {
  await expectCreateError(
    createAxiosError(
      403,
      'AUTH_PERMISSION_INSUFFICIENT',
      'Forbidden by upstream.',
    ),
    403,
    'AUTH_PERMISSION_INSUFFICIENT',
    '当前组织不具备项目发布资格，请确认组织身份后再试。',
  );
});

test('BFF project/create maps unavailable organization scope to organization-unavailable message', async () => {
  await expectCreateError(
    createAxiosError(
      404,
      'AUTH_RESOURCE_UNAVAILABLE',
      'Current organization scope is unavailable.',
    ),
    404,
    'AUTH_RESOURCE_UNAVAILABLE',
    '当前组织不可用，请切换到可发布项目的组织后再试。',
  );
});
