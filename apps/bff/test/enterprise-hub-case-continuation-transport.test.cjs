const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  EnterpriseHubService,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.js');
const {
  AppEnterpriseHubController,
} = require('../dist/apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.js');
const {
  EnterpriseHubController,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.js');

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

function createService({ onGet, onPut } = {}) {
  return new EnterpriseHubService(
    {
      async get(path, options) {
        return onGet(path, options);
      },
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

test('app-facing and internal controllers both expose direct case continuation surface', async () => {
  const calls = [];
  const service = {
    async getCaseDetail(caseId, headers) {
      calls.push(['get', caseId, headers]);
      return { caseId, caseStatus: 'draft' };
    },
    async getPublicCaseDetail(caseId, headers) {
      calls.push(['getPublic', caseId, headers]);
      return { caseId, caseStatus: 'approved' };
    },
    async updateCase(caseId, payload, headers) {
      calls.push(['put', caseId, payload, headers]);
      return { caseId, caseStatus: 'draft' };
    },
  };

  const appController = new AppEnterpriseHubController(service, {});
  const bffController = new EnterpriseHubController(service, {});

  await appController.getCaseDetail('case-1', { a: '1' });
  await appController.getPublicCaseDetail('case-public-1', { aa: '11' });
  await appController.updateCase('case-1', { title: '标题', summary: '摘要' }, { b: '2' });
  await bffController.getCaseDetail('case-2', { c: '3' });
  await bffController.getPublicCaseDetail('case-public-2', { cc: '33' });
  await bffController.updateCase('case-2', { title: '标题2', summary: '摘要2' }, { d: '4' });

  assert.deepEqual(calls, [
    ['get', 'case-1', { a: '1' }],
    ['getPublic', 'case-public-1', { aa: '11' }],
    ['put', 'case-1', { title: '标题', summary: '摘要' }, { b: '2' }],
    ['get', 'case-2', { c: '3' }],
    ['getPublic', 'case-public-2', { cc: '33' }],
    ['put', 'case-2', { title: '标题2', summary: '摘要2' }, { d: '4' }],
  ]);
});

test('service forwards direct case detail and update through canonical caseId paths', async () => {
  let capturedGet = null;
  let capturedPublicGet = null;
  let capturedPut = null;
  const service = createService({
    async onGet(path, options) {
      if (path.includes('/public-cases/')) {
        capturedPublicGet = { path, options };
      return {
        caseId: 'case-public-1',
        enterpriseId: 'enterprise-1',
        boardType: 'factory',
        title: '公开案例标题',
          exhibitionType: '展陈施工',
          city: '上海',
          eventTime: '2026-03',
        summary: '公开案例摘要',
        caseCoverFileAssetId: 'cover-public-1',
        caseMediaFileAssetIds: ['media-public-1'],
        caseImageUrlMap: {
          'cover-public-1': 'https://cdn.example.test/case-public-cover-1.png',
          'media-public-1': 'https://cdn.example.test/case-public-media-1.png',
        },
        isFeatured: false,
        caseStatus: 'approved',
      };
    }
      capturedGet = { path, options };
      return {
        caseId: 'case-1',
        enterpriseId: 'enterprise-1',
        boardType: 'factory',
        title: '案例标题',
        exhibitionType: '展陈施工',
        city: '上海',
        eventTime: '2026-03',
        summary: '案例摘要',
        caseCoverFileAssetId: 'cover-1',
        caseMediaFileAssetIds: ['media-1', 'media-2'],
        caseImageUrlMap: {
          'cover-1': 'https://cdn.example.test/case-cover-1.png',
          'media-1': 'https://cdn.example.test/case-media-1.png',
          'media-2': 'https://cdn.example.test/case-media-2.png',
        },
        isFeatured: true,
        caseStatus: 'draft',
      };
    },
    async onPut(path, payload, options) {
      capturedPut = { path, payload, options };
      return {
        caseId: 'case-1',
        caseStatus: 'draft',
      };
    },
  });

  const detail = await service.getCaseDetail('case-1', {});
  const publicDetail = await service.getPublicCaseDetail('case-public-1', {});
  const update = await service.updateCase(
    'case-1',
    {
      title: '案例标题',
      exhibitionType: '展陈施工',
      city: '上海',
      eventTime: '2026-03',
      summary: '案例摘要',
      caseCoverFileAssetId: 'cover-1',
      caseMediaFileAssetIds: ['media-1', 'media-2'],
      isFeatured: true,
    },
    {},
  );

  assert.deepEqual(detail, {
    caseId: 'case-1',
    enterpriseId: 'enterprise-1',
    boardType: 'factory',
    title: '案例标题',
    exhibitionType: '展陈施工',
    city: '上海',
    eventTime: '2026-03',
    summary: '案例摘要',
    caseCoverFileAssetId: 'cover-1',
    caseMediaFileAssetIds: ['media-1', 'media-2'],
    caseImageUrlMap: {
      'cover-1': 'https://cdn.example.test/case-cover-1.png',
      'media-1': 'https://cdn.example.test/case-media-1.png',
      'media-2': 'https://cdn.example.test/case-media-2.png',
    },
    isFeatured: true,
    caseStatus: 'draft',
  });
  assert.deepEqual(update, {
    caseId: 'case-1',
    caseStatus: 'draft',
  });
  assert.deepEqual(publicDetail, {
    caseId: 'case-public-1',
    enterpriseId: 'enterprise-1',
    boardType: 'factory',
    title: '公开案例标题',
    exhibitionType: '展陈施工',
    city: '上海',
    eventTime: '2026-03',
    summary: '公开案例摘要',
    caseCoverFileAssetId: 'cover-public-1',
    caseMediaFileAssetIds: ['media-public-1'],
    caseImageUrlMap: {
      'cover-public-1': 'https://cdn.example.test/case-public-cover-1.png',
      'media-public-1': 'https://cdn.example.test/case-public-media-1.png',
    },
    isFeatured: false,
    caseStatus: 'approved',
  });
  assert.equal(
    capturedGet.path,
    '/server/exhibition/enterprise-hub/cases/case-1',
  );
  assert.equal(
    capturedPublicGet.path,
    '/server/exhibition/enterprise-hub/public-cases/case-public-1',
  );
  assert.equal(
    capturedPut.path,
    '/server/exhibition/enterprise-hub/cases/case-1',
  );
  assert.equal(capturedGet.options.headers['x-organization-id'], 'org-smoke');
  assert.equal(
    capturedPublicGet.options.headers['x-organization-id'],
    undefined,
  );
  assert.equal(capturedPut.options.headers['x-organization-id'], 'org-smoke');
});

test('service updateCase rejects boardType and does not reintroduce it into the direct update path', async () => {
  const service = createService({
    async onPut() {
      throw new Error('should not call upstream when boardType is present');
    },
  });

  await assert.rejects(
    () =>
      service.updateCase(
        'case-1',
        {
          boardType: 'factory',
          title: '案例标题',
          summary: '案例摘要',
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(
        error.getResponse().code,
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
      );
      assert.equal(
        error.getResponse().message,
        '当前继续编辑不接受 boardType，请直接编辑当前案例内容。',
      );
      return true;
    },
  );
});

test('service updateCase preserves ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED for published cases', async () => {
  const service = createService({
    async onPut() {
      throw createAxiosError(
        400,
        'ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED',
        'Current case must continue in published change corridor.',
      );
    },
  });

  await assert.rejects(
    () =>
      service.updateCase(
        'case-1',
        {
          title: '案例标题',
          summary: '案例摘要',
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(
        error.getResponse().code,
        'ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED',
      );
      assert.equal(
        error.getResponse().message,
        '当前案例已进入正式展示变更流程，请改走变更通道继续处理。',
      );
      return true;
    },
  );
});
