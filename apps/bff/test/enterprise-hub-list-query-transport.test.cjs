const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  EnterpriseHubService,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.js');

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

function createService(overrides = {}) {
  return new EnterpriseHubService(
    {
      async get() {
        throw new Error('get mock missing');
      },
      ...overrides.serverClient,
    },
    {
      buildPublicHeadersWithOptionalActorHints() {
        return { 'x-request-id': 'req-smoke' };
      },
    },
    new ErrorNormalizerService(),
    {
      async buildCommandHeaders() {
        return {};
      },
    },
  );
}

test('enterprise public list forwards only the trimmed contract query set', async () => {
  let captured = null;
  const service = createService({
    serverClient: {
      async get(path, options) {
        captured = { path, options };
        return { items: [] };
      },
    },
  });

  await service.listEnterprises(
    {},
    {
      boardType: 'factory',
      keyword: '木作',
      provinceCode: '510000',
      cityCode: '510100',
      plantAreaRange: '2000_plus',
      page: '2',
      pageSize: '10',
      certifiedOnly: 'true',
      sortBy: 'hot',
      exhibitionType: 'expo',
      serviceCity: '成都',
      caseCountRange: '10_plus',
      reputationLevel: 'A',
      processType: 'spray',
      urgentCapability: 'true',
      warehouseCapability: 'true',
      supplyCategory: 'board',
      supplyMode: 'spot',
      responseLevel: 'fast',
    },
  );

  assert.equal(captured.path, '/server/exhibition/enterprise-hub/enterprises');
  assert.deepEqual(captured.options.params, {
    boardType: 'factory',
    keyword: '木作',
    provinceCode: '510000',
    cityCode: '510100',
    plantAreaRange: '2000_plus',
    page: '2',
    pageSize: '10',
  });
});

test('enterprise public list keeps plantAreaRange passthrough and strips deleted legacy filters', async () => {
  let capturedParams = null;
  const service = createService({
    serverClient: {
      async get(_path, options) {
        capturedParams = options.params;
        return { items: [] };
      },
    },
  });

  await service.listEnterprises(
    {},
    {
      boardType: 'factory',
      plantAreaRange: '500_2000',
      keyword: '',
      certifiedOnly: 'true',
      serviceCity: '上海',
      urgentCapability: 'true',
    },
  );

  assert.equal(capturedParams.plantAreaRange, '500_2000');
  assert.equal('certifiedOnly' in capturedParams, false);
  assert.equal('serviceCity' in capturedParams, false);
  assert.equal('urgentCapability' in capturedParams, false);
});

test('listEnterprisesForBoard fixes boardType without requiring caller query carrier', async () => {
  let captured = null;
  const service = createService({
    serverClient: {
      async get(path, options) {
        captured = { path, options };
        return { items: [], recommended: [], pagination: {} };
      },
    },
  });

  await service.listEnterprisesForBoard(
    {},
    'supplier',
    {
      keyword: '木料',
      page: '3',
    },
  );

  assert.equal(captured.path, '/server/exhibition/enterprise-hub/enterprises');
  assert.deepEqual(captured.options.params, {
    boardType: 'supplier',
    keyword: '木料',
    provinceCode: undefined,
    cityCode: undefined,
    plantAreaRange: undefined,
    page: '3',
    pageSize: undefined,
  });
});

test('enterprise public list keeps summary fields but trims weak review-summary fields', async () => {
  const service = createService({
    serverClient: {
      async get() {
        return {
          items: [
            {
              enterpriseId: 'enterprise-1',
              boardType: 'company',
              name: '样本企业',
              provinceName: '四川省',
              cityName: '成都市',
              primaryBoardLabel: '优秀公司',
              secondaryCapabilityLabels: [],
              shortIntro: '主打展台搭建',
              certificationLabel: '已认证',
              caseCount: 2,
              avgScore: 4.8,
              keywordTags: ['执行快'],
              boardHighlights: {
                company: {
                  exhibitionTypes: ['特装展台'],
                  serviceItems: ['策划设计'],
                },
              },
            },
          ],
          recommended: [],
          pagination: { page: 1, pageSize: 20, total: 1, hasMore: false },
        };
      },
    },
  });

  const response = await service.listEnterprises({}, { boardType: 'company' });

  assert.equal(response.items.length, 1);
  assert.equal(response.items[0].avgScore, null);
  assert.deepEqual(response.items[0].keywordTags, []);
  assert.equal(response.items[0].caseCount, 2);
});

test('enterprise public list error normalization remains stable after query trim', async () => {
  const service = createService({
    serverClient: {
      async get() {
        throw createAxiosError(
          403,
          'ENTERPRISE_HUB_PERMISSION_DENIED',
          'Current enterprise listing is not visible to the actor.',
        );
      },
    },
  });

  await assert.rejects(
    () => service.listEnterprises({}, { boardType: 'company' }),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(
        error.getResponse().code,
        'ENTERPRISE_HUB_PERMISSION_DENIED',
      );
      assert.equal(
        error.getResponse().message,
        'Current enterprise listing is not visible to the actor.',
      );
      return true;
    },
  );
});

test('enterprise public detail trims private location fields and keeps map preview carrier', async () => {
  const service = createService({
    serverClient: {
      async get(path, options) {
        assert.equal(
          path,
          '/server/exhibition/enterprise-hub/enterprises/enterprise-location-1',
        );
        assert.equal(options.params.boardType, 'company');
        return {
          header: {
            enterpriseId: 'enterprise-location-1',
            name: '位置样本公司',
            primaryBoardType: 'company',
            shortIntro: '位置能力样本',
            provinceName: '重庆市',
            cityName: '重庆市',
          },
          basicInfo: {
            address: '重庆市渝北区金开大道 1 号',
          },
          visualGallery: {
            albumImageUrls: [
              'https://cdn.example.test/enterprise/album-1.png',
            ],
            source: 'enterprise_album',
          },
          location: {
            addressText: '完整私域地址',
            publicDisplayAddress: '重庆市渝北区金开大道 1 号',
            provinceCode: '500000',
            provinceName: '重庆市',
            cityCode: '500100',
            cityName: '重庆市',
            districtCode: '500112',
            districtName: '渝北区',
            latitude: 29.7,
            longitude: 106.5,
            geoSource: 'manual_address_geocode',
            geoStatus: 'resolved',
            lastGeocodedAt: '2026-04-16T10:00:00.000Z',
            mapProvider: 'amap',
            mapPreviewUrl: 'https://maps.example/preview.png',
            mapLinkUrl: 'https://uri.amap.com/marker?position=106.5,29.7',
          },
          boardProfile: {},
          serviceAreas: [],
          cases: [],
          certifications: [],
          reviewSummary: {},
          contacts: [],
        };
      },
    },
  });

  const detail = await service.getEnterpriseDetail(
    'enterprise-location-1',
    'company',
    {},
  );

  assert.deepEqual(detail.location, {
    provinceName: '重庆市',
    cityName: '重庆市',
    districtName: '渝北区',
    publicDisplayAddress: '重庆市渝北区金开大道 1 号',
    latitude: 29.7,
    longitude: 106.5,
    geoStatus: 'resolved',
    mapProvider: 'amap',
    mapPreviewUrl: 'https://maps.example/preview.png',
    mapLinkUrl: 'https://uri.amap.com/marker?position=106.5,29.7',
  });
  assert.equal(Object.hasOwn(detail.location, 'addressText'), false);
  assert.equal(Object.hasOwn(detail.location, 'provinceCode'), false);
  assert.equal(Object.hasOwn(detail.location, 'geoSource'), false);
  assert.equal(Object.hasOwn(detail.location, 'lastGeocodedAt'), false);
  assert.deepEqual(detail.visualGallery, {
    albumImageUrls: ['https://cdn.example.test/enterprise/album-1.png'],
    source: 'enterprise_album',
  });
});

test('getEnterpriseDetailForBoard fixes boardType without query carrier from caller', async () => {
  let captured = null;
  const service = createService({
    serverClient: {
      async get(path, options) {
        captured = { path, options };
        return {
          header: {
            enterpriseId: 'enterprise-company-1',
            name: '企业 A',
            primaryBoardType: 'company',
          },
          basicInfo: {},
          visualGallery: {},
          location: null,
          boardProfile: {},
          serviceAreas: [],
          cases: [],
          certifications: [],
          reviewSummary: {},
          contacts: [],
        };
      },
    },
  });

  await service.getEnterpriseDetailForBoard('enterprise-company-1', 'company', {});

  assert.equal(
    captured.path,
    '/server/exhibition/enterprise-hub/enterprises/enterprise-company-1',
  );
  assert.equal(captured.options.params.boardType, 'company');
});

test('getRecommendationsForBoard fixes boardType without query carrier from caller', async () => {
  let captured = null;
  const service = createService({
    serverClient: {
      async get(path, options) {
        captured = { path, options };
        return { items: [] };
      },
    },
  });

  await service.getRecommendationsForBoard({}, 'factory');

  assert.equal(
    captured.path,
    '/server/exhibition/enterprise-hub/recommendations',
  );
  assert.equal(captured.options.params.boardType, 'factory');
});
