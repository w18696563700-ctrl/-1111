const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  ProjectService,
} = require('../dist/apps/bff/src/routes/project/project.service.js');

function createService(overrides = {}) {
  const serverClient = {
    async post() {
      throw new Error('post mock missing');
    },
    async get() {
      throw new Error('get mock missing');
    },
    ...overrides.serverClient,
  };

  const authContext = {
    buildForwardHeaders() {
      return { authorization: 'Bearer smoke' };
    },
    buildPublicHeadersWithOptionalActorHints() {
      return { 'x-request-id': 'req-smoke' };
    },
    ...overrides.authContext,
  };

  return new ProjectService(serverClient, authContext, new ErrorNormalizerService());
}

test('project/create forwards dual-field mode without truncating exhibitionName and brandName', async () => {
  let capturedPayload = null;

  const service = createService({
    serverClient: {
      async post(_path, payload) {
        capturedPayload = payload;
        return { projectId: 'project-dual', state: 'draft' };
      },
    },
  });

  const response = await service.createProject(
    {
      exhibitionName: '中国家居展',
      brandName: '木作品牌A',
      buildingType: 'exhibition',
      budgetAmount: 88000,
      provinceCode: '650000',
      cityCode: '650100',
    },
    {},
  );

  assert.deepEqual(response, { projectId: 'project-dual', state: 'draft' });
  assert.deepEqual(capturedPayload, {
    exhibitionName: '中国家居展',
    brandName: '木作品牌A',
    buildingType: 'exhibition',
    budgetAmount: 88000,
    provinceCode: '650000',
    cityCode: '650100',
  });
});

test('project/create keeps legacy-title mode available and rejects partial dual-field payloads', async () => {
  let capturedPayload = null;

  const service = createService({
    serverClient: {
      async post(_path, payload) {
        capturedPayload = payload;
        return { projectId: 'project-legacy', state: 'draft' };
      },
    },
  });

  const legacyResponse = await service.createProject(
    {
      title: '传统标题项目',
      buildingType: 'exhibition',
      budgetAmount: 66000,
    },
    {},
  );

  assert.deepEqual(legacyResponse, { projectId: 'project-legacy', state: 'draft' });
  assert.deepEqual(capturedPayload, {
    title: '传统标题项目',
    buildingType: 'exhibition',
    budgetAmount: 66000,
  });

  await assert.rejects(
    () =>
      service.createProject(
        {
          exhibitionName: '只有展会',
          buildingType: 'exhibition',
          budgetAmount: 66000,
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'PROJECT_CREATE_INVALID');
      assert.equal(
        error.getResponse().message,
        '展会名称与品牌名称必须同时提供，或仅使用传统标题模式。',
      );
      return true;
    },
  );
});

test('project/list forwards four filter queries and project/detail preserves dual-field read model', async () => {
  const getCalls = [];

  const service = createService({
    serverClient: {
      async get(path, config) {
        getCalls.push({ path, config });

        if (path === '/server/projects') {
          return {
            items: [
              {
                projectId: 'project-list-1',
                projectNo: 'PJ-001',
                title: '展会 / 品牌',
                exhibitionName: '中国建博会',
                brandName: '品牌B',
                buildingType: 'exhibition',
                budgetAmount: 120000,
                areaSqm: 36,
                provinceCode: '650000',
                provinceName: '新疆',
                cityCode: '650100',
                cityName: '乌鲁木齐',
                plannedStartAt: '2026-05-01',
                plannedEndAt: '2026-05-05',
                publishedAt: '2026-04-30T08:15:00.000Z',
                state: 'published',
                summary: { teaser: 'summary' },
              },
            ],
            pagination: {
              page: 2,
              pageSize: 1,
              total: 3,
              hasMore: true,
            },
          };
        }

        return {
          projectId: 'project-detail-1',
          projectNo: 'PJ-002',
          title: '展会 / 品牌',
          exhibitionName: '中国建博会',
          brandName: '品牌C',
          buildingType: 'exhibition',
          budgetAmount: 180000,
          areaSqm: 54,
          provinceCode: '710000',
          provinceName: '台湾省',
          cityCode: '710100',
          cityName: '台北市',
          districtCode: null,
          districtName: null,
          detailAddress: null,
          scopeSummary: null,
          plannedStartAt: '2026-06-01',
          plannedEndAt: '2026-06-03',
          publishedAt: '2026-04-30T09:00:00.000Z',
          buildingTypeRemark: null,
          scheduleDetail: null,
          viewerProjectRelation: 'non_owner',
          description: null,
          state: 'published',
          summary: { teaser: 'detail-summary' },
        };
      },
    },
  });

  const listResponse = await service.getProjectList(
    {},
    {
      provinceCode: '650000',
      cityCode: '650100',
      areaBucket: '36_sqm',
      budgetBucket: '8_10w',
      page: '2',
      pageSize: '1',
    },
  );
  const detailResponse = await service.getProjectDetail('project-detail-1', {});

  assert.equal(getCalls[0].path, '/server/projects');
  assert.deepEqual(getCalls[0].config.params, {
    provinceCode: '650000',
    cityCode: '650100',
    areaBucket: '36_sqm',
    budgetBucket: '8_10w',
    page: '2',
    pageSize: '1',
  });
  assert.equal(listResponse.items[0].exhibitionName, '中国建博会');
  assert.equal(listResponse.items[0].brandName, '品牌B');
  assert.equal(listResponse.items[0].plannedStartAt, '2026-05-01');
  assert.equal(listResponse.items[0].plannedEndAt, '2026-05-05');
  assert.equal(listResponse.items[0].publishedAt, '2026-04-30T08:15:00.000Z');
  assert.deepEqual(listResponse.pagination, {
    page: 2,
    pageSize: 1,
    total: 3,
    hasMore: true,
  });
  assert.equal(detailResponse.exhibitionName, '中国建博会');
  assert.equal(detailResponse.brandName, '品牌C');
  assert.equal(detailResponse.plannedStartAt, '2026-06-01');
  assert.equal(detailResponse.plannedEndAt, '2026-06-03');
  assert.equal(detailResponse.viewerProjectRelation, 'non_owner');
});

test('project/list and project/detail keep legacy title-only fallback readable', async () => {
  const service = createService({
    serverClient: {
      async get(path) {
        if (path === '/server/projects') {
          return {
            items: [
              {
                projectId: 'legacy-project',
                projectNo: 'PJ-LEGACY',
                title: '历史标题项目',
                exhibitionName: null,
                brandName: null,
                buildingType: 'exhibition',
                budgetAmount: 90000,
                areaSqm: null,
                provinceCode: null,
                provinceName: null,
                cityCode: null,
                cityName: null,
                plannedStartAt: null,
                plannedEndAt: null,
                publishedAt: '2026-04-30T08:15:00.000Z',
                state: 'published',
                summary: { teaser: 'legacy-summary' },
              },
            ],
            pagination: {
              page: 1,
              pageSize: 20,
              total: 1,
              hasMore: false,
            },
          };
        }

        return {
          projectId: 'legacy-project',
          projectNo: 'PJ-LEGACY',
          title: '历史标题项目',
          exhibitionName: null,
          brandName: null,
          buildingType: 'exhibition',
          budgetAmount: 90000,
          areaSqm: null,
          provinceCode: null,
          provinceName: null,
          cityCode: null,
          cityName: null,
          districtCode: null,
          districtName: null,
          detailAddress: null,
          scopeSummary: null,
          plannedStartAt: null,
          plannedEndAt: null,
          publishedAt: '2026-04-30T08:15:00.000Z',
          buildingTypeRemark: null,
          scheduleDetail: null,
          viewerProjectRelation: 'owner',
          description: null,
          state: 'published',
          summary: { teaser: 'legacy-detail' },
        };
      },
    },
  });

  const listResponse = await service.getProjectList({}, {});
  const detailResponse = await service.getProjectDetail('legacy-project', {});

  assert.equal(listResponse.items[0].title, '历史标题项目');
  assert.equal(listResponse.items[0].exhibitionName, null);
  assert.equal(listResponse.items[0].brandName, null);
  assert.equal(listResponse.pagination.total, 1);
  assert.equal(detailResponse.title, '历史标题项目');
  assert.equal(detailResponse.exhibitionName, null);
  assert.equal(detailResponse.brandName, null);
});

test('project/list rejects server items without publishedAt', async () => {
  const service = createService({
    serverClient: {
      async get(path) {
        assert.equal(path, '/server/projects');
        return {
          items: [
            {
              projectId: 'project-without-published-at',
              projectNo: 'PJ-MISSING-PUBLISHED',
              title: '缺发布时间项目',
              exhibitionName: '缺发布时间展会',
              brandName: '缺发布时间品牌',
              buildingType: 'exhibition',
              budgetAmount: 90000,
              areaSqm: 36,
              provinceCode: '500000',
              provinceName: '重庆市',
              cityCode: '500100',
              cityName: '重庆市',
              plannedStartAt: '2026-05-01',
              plannedEndAt: '2026-05-05',
              state: 'published',
              summary: { teaser: 'missing-publishedAt' },
            },
          ],
          pagination: {
            page: 1,
            pageSize: 20,
            total: 1,
            hasMore: false,
          },
        };
      },
    },
  });

  await assert.rejects(
    () => service.getProjectList({}, {}),
    (error) => {
      assert.equal(error.getStatus(), 502);
      assert.match(
        error.getResponse().details.message,
        /Project list response is missing publishedAt/,
      );
      return true;
    },
  );
});
