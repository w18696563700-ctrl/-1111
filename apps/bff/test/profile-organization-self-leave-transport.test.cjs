const path = require('path');
require('ts-node').register({
  transpileOnly: true,
  project: path.resolve(__dirname, '../tsconfig.json'),
});
require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../src/core/errors/error-normalizer.service.ts');
const {
  ProfileOrganizationLeaveErrorService,
} = require('../src/routes/profile/profile-organization-leave-error.service.ts');
const {
  ProfileOrganizationLeaveService,
} = require('../src/routes/profile/profile-organization-leave.service.ts');

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

function createService(serverClient) {
  return new ProfileOrganizationLeaveService(
    serverClient,
    {
      buildForwardHeaders(headers) {
        return {
          authorization: headers.authorization,
          'x-request-id': headers['x-request-id'],
          'x-trace-id': headers['x-trace-id'],
        };
      },
    },
    new ProfileOrganizationLeaveErrorService(new ErrorNormalizerService()),
  );
}

test('BFF forwards current organization self-leave to Server and shapes returned truth', async () => {
  const calls = [];
  const service = createService({
    async post(pathname, body, options) {
      calls.push([pathname, body, options.headers]);
      return {
        leftOrganizationId: 'org-current',
        nextOrganizationId: 'org-next',
        shellBootstrapState: 'authenticated',
        traceId: 'trace-leave',
      };
    },
  });

  const result = await service.leaveCurrentOrganization(
    { reason: '离职' },
    {
      authorization: 'Bearer token',
      'x-request-id': 'req-leave',
      'x-trace-id': 'trace-leave',
    },
  );

  assert.deepEqual(result, {
    leftOrganizationId: 'org-current',
    nextOrganizationId: 'org-next',
    shellBootstrapState: 'authenticated',
    traceId: 'trace-leave',
  });
  assert.deepEqual(calls, [
    [
      '/server/profile/organization/current/leave',
      { reason: '离职' },
      {
        authorization: 'Bearer token',
        'x-request-id': 'req-leave',
        'x-trace-id': 'trace-leave',
      },
    ],
  ]);
});

test('BFF maps last-admin self-leave block to user-readable copy', async () => {
  const service = createService({
    async post() {
      throw createAxiosError(
        409,
        'ORG_LAST_ADMIN_LEAVE_BLOCKED',
        'Current actor is the last active administrator and cannot leave.',
      );
    },
  });

  await assert.rejects(
    () => service.leaveCurrentOrganization({}, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'ORG_LAST_ADMIN_LEAVE_BLOCKED');
      assert.equal(
        error.getResponse().message,
        '你是当前组织最后一位管理员，需先添加或转交另一位管理员后才能退出。',
      );
      return true;
    },
  );
});

test('BFF maps missing organization scope for self-leave without inventing state', async () => {
  const service = createService({
    async post() {
      throw createAxiosError(
        403,
        'ORG_SCOPE_REQUIRED',
        'Current organization scope is required.',
      );
    },
  });

  await assert.rejects(
    () => service.leaveCurrentOrganization(undefined, {}),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(error.getResponse().code, 'ORG_SCOPE_REQUIRED');
      assert.equal(
        error.getResponse().message,
        '当前还没有可退出的公司/组织，请先确认当前主体。',
      );
      return true;
    },
  );
});
