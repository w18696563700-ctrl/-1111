const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../src/core/errors/error-normalizer.service.ts');
const {
  ProfileCommandErrorService,
} = require('../src/routes/profile/profile-command-error.service.ts');
const {
  ProfileCommandService,
} = require('../src/routes/profile/profile-command.service.ts');

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
  return new ProfileCommandService(
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
    new ProfileCommandErrorService(new ErrorNormalizerService()),
  );
}

async function expectOcrError(error, expectedMessage, expectedReason) {
  const service = createService(error);
  await assert.rejects(
    () =>
      service.recognizeCertificationLicense(
        {
          organizationId: 'org-1',
          fileAssetId: 'file-1',
        },
        {},
      ),
    (thrown) => {
      assert.equal(thrown.getStatus(), 403);
      assert.equal(thrown.getResponse().code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(thrown.getResponse().message, expectedMessage);
      assert.equal(thrown.getResponse().details.reason, expectedReason);
      return true;
    },
  );
}

test('BFF OCR error mapping explains organization scope mismatch precisely', async () => {
  await expectOcrError(
    createAxiosError(
      403,
      'AUTH_PERMISSION_INSUFFICIENT',
      'Current actor lacks the required organization scope.',
      {
        reason: 'organization_scope_mismatch',
        currentOrganizationId: 'org-1',
        requestedOrganizationId: 'org-2',
      },
    ),
    '当前组织上下文已变化，请返回“公司与组织”重新确认后再试。',
    'organization_scope_mismatch',
  );
});

test('BFF OCR error mapping explains admin-role requirement precisely', async () => {
  await expectOcrError(
    createAxiosError(
      403,
      'AUTH_PERMISSION_INSUFFICIENT',
      'Current actor lacks the required organization admin role.',
      {
        reason: 'organization_admin_role_missing',
        currentRoleKeys: ['buyer_member(scoped)'],
      },
    ),
    '当前仅组织管理员可识别营业执照，请切换到需求管理员或供应商管理员后再试。',
    'organization_admin_role_missing',
  );
});

test('BFF OCR error mapping explains active-membership absence precisely', async () => {
  await expectOcrError(
    createAxiosError(
      403,
      'AUTH_PERMISSION_INSUFFICIENT',
      'Current actor does not hold an active membership in this organization.',
      {
        reason: 'organization_active_membership_missing',
        organizationId: 'org-1',
      },
    ),
    '当前账号不在该组织的有效成员列表中，暂不能识别营业执照。',
    'organization_active_membership_missing',
  );
});
