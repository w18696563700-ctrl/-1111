const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  EnterpriseHubService,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.js');
const {
  EnterpriseHubPublishedChangeService,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub-published-change.service.js');
const {
  toEnterpriseHubWorkbenchResponse,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub-workbench.read-model.js');

function createEnterpriseHubService(onPut) {
  return new EnterpriseHubService(
    {
      async put(path, payload, options) {
        return onPut(path, payload, options);
      },
    },
    {
      buildPublicHeadersWithOptionalActorHints() {
        return {};
      },
    },
    new ErrorNormalizerService(),
    {
      async buildCommandHeaders() {
        return {
          authorization: 'Bearer smoke',
          'x-organization-id': 'org-smoke',
        };
      },
    },
  );
}

function createPublishedChangeService(onPut) {
  return new EnterpriseHubPublishedChangeService(
    {
      async put(path, payload, options) {
        return onPut(path, payload, options);
      },
    },
    new ErrorNormalizerService(),
    {
      async buildCommandHeaders() {
        return {
          authorization: 'Bearer smoke',
          'x-organization-id': 'org-smoke',
        };
      },
    },
  );
}

test('workbench read-model keeps albumImageFileAssetIds on basic payload', () => {
  const response = toEnterpriseHubWorkbenchResponse({
    organizationId: 'org-1',
    enterpriseId: 'enterprise-1',
    boardType: 'company',
    latestApplication: null,
    basic: {
      name: '示例公司',
      logoFileAssetId: 'logo-1',
      albumImageFileAssetIds: ['album-1', 'album-2'],
      cooperationModes: [],
      contactVisible: false,
    },
    boardProfile: {},
    primaryContact: null,
    cases: [],
    certification: null,
    readiness: {
      hasApplication: false,
      draftEditable: false,
      basicCompleted: false,
      profileCompleted: false,
      hasCase: false,
      hasContact: false,
      certificationApproved: false,
      submitReady: false,
      blockers: [],
    },
  });

  assert.deepEqual(response.basic.albumImageFileAssetIds, ['album-1', 'album-2']);
});

test('updateBasic forwards albumImageFileAssetIds through the canonical basic save path', async () => {
  let captured = null;
  const service = createEnterpriseHubService(async (path, payload, options) => {
    captured = { path, payload, options };
    return { ok: true, traceId: 'trace-stage2-basic' };
  });

  await service.updateBasic(
    'enterprise-1',
    {
      logoFileAssetId: 'logo-1',
      albumImageFileAssetIds: ['album-1', 'album-2'],
      shortIntro: '简介',
    },
    {},
  );

  assert.equal(
    captured.path,
    '/server/exhibition/enterprise-hub/enterprises/enterprise-1/basic',
  );
  assert.deepEqual(captured.payload, {
    logoFileAssetId: 'logo-1',
    albumImageFileAssetIds: ['album-1', 'album-2'],
    shortIntro: '简介',
  });
  assert.equal(captured.options.headers['x-organization-id'], 'org-smoke');
});

test('published change basic save also forwards albumImageFileAssetIds', async () => {
  let captured = null;
  const service = createPublishedChangeService(async (path, payload, options) => {
    captured = { path, payload, options };
    return { ok: true, traceId: 'trace-stage2-change' };
  });

  await service.updateCurrentBasic(
    'enterprise-1',
    {
      albumImageFileAssetIds: ['album-1', 'album-2', 'album-3'],
    },
    {},
  );

  assert.equal(
    captured.path,
    '/server/exhibition/enterprise-hub/enterprises/enterprise-1/changes/current/basic',
  );
  assert.deepEqual(captured.payload, {
    albumImageFileAssetIds: ['album-1', 'album-2', 'album-3'],
  });
  assert.equal(captured.options.headers.authorization, 'Bearer smoke');
});
