const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  ProjectPublicResourceService,
} = require('../dist/apps/bff/src/routes/project/project-public-resource.service.js');

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

function createService(overrides = {}) {
  return new ProjectPublicResourceService(
    {
      async get() {
        throw new Error('get mock missing');
      },
      ...overrides.serverClient,
    },
    {
      buildPublicHeadersWithOptionalActorHints(headers) {
        if (overrides.buildHeaders) {
          return overrides.buildHeaders(headers);
        }
        return {
          authorization: headers.authorization,
          'x-request-id': 'req-public-resource',
        };
      },
    },
    new ErrorNormalizerService(),
  );
}

test('project public resources maps to server path and shapes response', async () => {
  let captured = null;
  const service = createService({
    buildHeaders(headers) {
      captured = { headers };
      return {
        authorization: headers.authorization,
        'x-user-id': headers['x-user-id'],
      };
    },
    serverClient: {
      async get(path, options) {
        captured = {
          ...captured,
          path,
          options,
        };
        return {
          resources: [
            {
              resourceId: 'resource-1',
              resourceCategory: 'contract_template',
              title: '标准合同模板',
              summary: '   ',
              fileAssetId: 'file-1',
              fileName: 'template.pdf',
              mimeType: 'application/pdf',
              visibility: 'app_shared',
              sortOrder: '2',
              publishedAt: '2026-04-14T09:00:00.000Z',
            },
          ],
        };
      },
    },
  });

  const result = await service.getPublicResources({
    authorization: 'Bearer public-resource-token',
    'x-user-id': 'user-1',
  });

  assert.equal(captured.path, '/server/projects/public-resources');
  assert.deepEqual(captured.options.headers, {
    authorization: 'Bearer public-resource-token',
    'x-user-id': 'user-1',
  });
  assert.deepEqual(result, {
    resources: [
      {
        resourceId: 'resource-1',
        resourceCategory: 'contract_template',
        title: '标准合同模板',
        summary: null,
        fileAssetId: 'file-1',
        fileName: 'template.pdf',
        mimeType: 'application/pdf',
        visibility: 'app_shared',
        sortOrder: 2,
        publishedAt: '2026-04-14T09:00:00.000Z',
      },
    ],
  });
});

test('project public resources rewrites session invalid to login-specific message', async () => {
  const service = createService({
    serverClient: {
      async get() {
        throw createAxiosError(401, {
          code: 'AUTH_SESSION_INVALID',
          message: 'Current session is invalid.',
          source: 'server',
        });
      },
    },
  });

  await assert.rejects(
    () => service.getPublicResources({}),
    (error) => {
      assert.equal(error.getStatus(), 401);
      assert.equal(error.getResponse().code, 'AUTH_SESSION_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前登录态不可用，请重新登录或刷新后再试。',
      );
      return true;
    },
  );
});

test('project public resources fail-closes raw upstream 404 into controlled unavailable', async () => {
  const service = createService({
    serverClient: {
      async get() {
        throw createAxiosError(404, {
          statusCode: 404,
          message: 'Cannot GET /server/projects/public-resources',
        });
      },
    },
  });

  await assert.rejects(
    () => service.getPublicResources({}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.equal(error.getResponse().code, 'AUTH_RESOURCE_UNAVAILABLE');
      assert.equal(
        error.getResponse().message,
        '当前公共资源目录暂不可用，请稍后再试。',
      );
      return true;
    },
  );
});
