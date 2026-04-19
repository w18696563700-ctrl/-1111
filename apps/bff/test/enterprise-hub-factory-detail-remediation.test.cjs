const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  EnterpriseHubService,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub.service.js');
const {
  EnterpriseHubFormalInfoService,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub-formal-info.service.js');

function createEnterpriseHubService(onGet) {
  return new EnterpriseHubService(
    {
      async get(path, options) {
        return onGet(path, options);
      },
    },
    {
      buildPublicHeadersWithOptionalActorHints(headers) {
        return {
          ...headers,
          authorization: 'Bearer detail-smoke',
        };
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

function createFormalInfoService(onGet) {
  return new EnterpriseHubFormalInfoService(
    {
      async get(path, options) {
        return onGet(path, options);
      },
    },
    {
      buildReadOnlyForwardHeaders(headers) {
        return {
          ...headers,
          authorization: 'Bearer formal-info-smoke',
        };
      },
    },
    new ErrorNormalizerService(),
  );
}

test('factory detail surface prefers public location truth, showcase display urls, and controlled cases state', async () => {
  let captured = null;
  const service = createEnterpriseHubService(async (path, options) => {
    captured = { path, options };
    return {
      header: {
        enterpriseId: 'enterprise-factory-1',
        name: '重庆坤特展览展示有限公司',
        primaryBoardType: 'factory',
        shortIntro: '西南展陈工厂',
        provinceName: '四川省',
        cityName: '成都市',
        verificationStatus: 'verified',
      },
      basicInfo: {
        legalName: '重庆坤特展览展示有限公司',
        address: '四川省成都市高新区天府大道 1 号',
      },
      location: {
        provinceName: '重庆市',
        cityName: '重庆市',
        districtName: '江北区',
        publicDisplayAddress: '重庆市江北区洋河二村 73 号',
        latitude: 29.58,
        longitude: 106.53,
        geoStatus: 'resolved',
      },
      boardProfile: {
        factoryName: '重庆海川展览工厂',
        showcaseImageFileAssetIds: ['file-showcase-1'],
      },
      showcaseImageUrls: ['https://cdn.example.test/showcase-1.png'],
      visualGallery: {
        albumImageUrls: ['https://cdn.example.test/album-1.png'],
        source: 'empty',
      },
      casesState: 'unavailable',
      cases: [],
      certifications: [],
      reviewSummary: {},
      contacts: [],
    };
  });

  const detail = await service.getEnterpriseDetail(
    'enterprise-factory-1',
    'factory',
    { 'x-request-id': 'req-factory-1' },
  );

  assert.equal(
    captured.path,
    '/server/exhibition/enterprise-hub/enterprises/enterprise-factory-1',
  );
  assert.deepEqual(captured.options.params, {
    boardType: 'factory',
  });
  assert.equal(detail.header.name, '重庆海川展览工厂');
  assert.equal(detail.header.provinceName, '重庆市');
  assert.equal(detail.header.cityName, '重庆市');
  assert.equal(detail.basicInfo.legalName, '重庆坤特展览展示有限公司');
  assert.equal(detail.basicInfo.address, '重庆市江北区洋河二村 73 号');
  assert.deepEqual(detail.boardProfile.showcaseImageUrls, [
    'https://cdn.example.test/showcase-1.png',
  ]);
  assert.deepEqual(detail.boardProfile.showcaseImageFileAssetIds, [
    'file-showcase-1',
  ]);
  assert.deepEqual(detail.visualGallery, {
    albumImageUrls: ['https://cdn.example.test/album-1.png'],
    source: 'showcase',
  });
  assert.equal(detail.casesState, 'unavailable');
  assert.deepEqual(detail.cases, []);
});

test('formal-info service forwards to the canonical server path and shapes the read response', async () => {
  let captured = null;
  const service = createFormalInfoService(async (path, options) => {
    captured = { path, options };
    return {
      legalName: '重庆坤特展览展示有限公司',
      uscc: '91500105MA61TEST9Q',
      legalPerson: '张三',
      businessType: '有限责任公司',
      address: '重庆市江北区洋河二村 73 号',
      registeredCapital: '500 万人民币',
      establishedAt: '2018-06-01',
      businessTerm: '2018-06-01 至 长期',
      businessScope: '展览展示工程设计施工',
      certificationStatus: 'approved',
    };
  });

  const result = await service.getTargetEnterpriseFormalInfo(
    'enterprise-factory-1',
    { 'x-organization-id': 'org-factory-1' },
  );

  assert.equal(
    captured.path,
    '/server/exhibition/enterprise-hub/enterprises/enterprise-factory-1/formal-info',
  );
  assert.equal(
    captured.options.headers.authorization,
    'Bearer formal-info-smoke',
  );
  assert.deepEqual(result, {
    enterpriseId: 'enterprise-factory-1',
    legalName: '重庆坤特展览展示有限公司',
    uscc: '91500105MA61TEST9Q',
    legalPerson: '张三',
    businessType: '有限责任公司',
    address: '重庆市江北区洋河二村 73 号',
    registeredCapital: '500 万人民币',
    establishedAt: '2018-06-01',
    businessTerm: '2018-06-01 至 长期',
    businessScope: '展览展示工程设计施工',
    certificationStatus: 'approved',
  });
});
