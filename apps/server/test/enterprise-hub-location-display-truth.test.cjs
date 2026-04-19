const test = require('node:test');
const assert = require('node:assert/strict');

function createLocationService() {
  const {
    EnterpriseHubLocationService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-location.service.js');

  return new EnterpriseHubLocationService(
    {
      async verifyCurrentSessionContext() {
        return null;
      },
    },
    {
      async requireAuthenticatedActor() {
        return null;
      },
      async getCurrentOrganizationScope() {
        return null;
      },
    },
    {
      buildMapPreviewUrl() {
        return null;
      },
      buildMapLinkUrl() {
        return null;
      },
      requireProviderConfig() {},
      async geocodeAddress() {
        return null;
      },
      async reverseGeocode() {
        return null;
      },
    },
  );
}

function createRepository(initialItems = [], key = 'id') {
  const items = initialItems.map((item) => ({ ...item }));
  return {
    items,
    async findOneBy(where) {
      return (
        items.find((item) =>
          Object.entries(where).every(([field, expected]) => item[field] === expected),
        ) ?? null
      );
    },
    async findOne(options) {
      const where = options?.where ?? {};
      const matched = items.filter((item) =>
        Object.entries(where).every(([field, expected]) => item[field] === expected),
      );
      return matched[0] ?? null;
    },
    async find() {
      return items.map((item) => ({ ...item }));
    },
    create(input) {
      return { ...input };
    },
    async save(value) {
      const next = { ...value };
      const index = items.findIndex((item) => item[key] === next[key]);
      if (index >= 0) {
        items[index] = next;
      } else {
        items.push(next);
      }
      return next;
    },
  };
}

function createContext(requestId) {
  return {
    authorization: 'Bearer carrier',
    actorId: '',
    userId: '',
    organizationId: 'header-only-org',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

test('region display truth resolver backfills blank names and corrects stale names from canonical code lookup', () => {
  const {
    resolveEnterpriseHubRegionDisplayTruth,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-region-lookup.js');

  const blank = resolveEnterpriseHubRegionDisplayTruth({
    provinceCode: '510000',
    provinceName: null,
    cityCode: '510100',
    cityName: null,
  });
  assert.equal(blank.provinceName, '四川省');
  assert.equal(blank.cityName, '成都市');

  const stale = resolveEnterpriseHubRegionDisplayTruth({
    provinceCode: '510000',
    provinceName: '四川',
    cityCode: '510100',
    cityName: '成都',
  });
  assert.equal(stale.provinceName, '四川省');
  assert.equal(stale.cityName, '成都市');
});

test('workbench read uses canonical location display truth for basic payload and readiness', async () => {
  const { EnterpriseHubWorkbenchQueryService } = require('../dist/modules/enterprise_hub/enterprise-hub-workbench.query.service.js');
  const { EnterpriseHubWorkbenchPresenter } = require('../dist/modules/enterprise_hub/enterprise-hub-workbench.presenter.js');

  const locationService = createLocationService();
  const listingRepository = createRepository([
    {
      id: 'enterprise-1',
      organizationId: 'org-1',
      primaryBoardType: 'company',
      secondaryCapabilities: [],
      name: '测试企业',
      shortIntro: '一句话简介',
      fullIntro: null,
      logoFileAssetId: null,
      coverFileAssetId: null,
      albumImageFileAssetIds: [],
      provinceCode: '510000',
      provinceName: '',
      cityCode: '510100',
      cityName: '成都',
      address: null,
      foundedAt: null,
      teamSizeRange: null,
      cooperationModes: [],
      contactVisible: true,
    },
  ]);

  const service = new EnterpriseHubWorkbenchQueryService(
    listingRepository,
    createRepository([
      {
        id: 'application-1',
        enterpriseId: 'enterprise-1',
        applicationStatus: 'draft',
      },
    ]),
    createRepository([
      {
        enterpriseId: 'enterprise-1',
        exhibitionTypes: ['expo'],
        serviceItems: ['design'],
        serviceCities: ['成都'],
      },
    ], 'enterpriseId'),
    createRepository([], 'enterpriseId'),
    createRepository([], 'enterpriseId'),
    createRepository([
      {
        id: 'case-1',
        enterpriseId: 'enterprise-1',
      },
    ]),
    createRepository([
      {
        id: 'contact-1',
        enterpriseId: 'enterprise-1',
        contactName: '李四',
        mobile: '13800000000',
        isPrimary: true,
        visibleToPublic: true,
      },
    ]),
    createRepository([
      {
        id: 'cert-1',
        organizationId: 'org-1',
        certificationStatus: 'approved',
        legalName: '测试企业',
        uscc: '91310000TEST00001',
        licenseFileId: 'license-1',
        address: '成都市高新区天府大道 1 号',
        establishedAt: '2020-04-09',
      },
    ]),
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'session-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return {
          organization: { id: 'org-1' },
          membership: { roleKey: 'supplier_admin', memberStatus: 'active' },
          certification: { certificationStatus: 'approved' },
          roleKeys: ['supplier_admin'],
        };
      },
    },
    new EnterpriseHubWorkbenchPresenter(locationService),
  );

  const response = await service.getWorkbench(createContext('location-display-workbench'), 'company');

  assert.equal(response.basic.provinceName, '四川省');
  assert.equal(response.basic.cityName, '成都市');
  assert.equal(response.basic.location.provinceName, '四川省');
  assert.equal(response.basic.location.cityName, '成都市');
  assert.equal(response.readiness.basicCompleted, true);
});

test('published change basic merge stores canonical province/city display names from server lookup', () => {
  const {
    EnterpriseHubPublishedChangeAppService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change-app.service.js');

  const service = new EnterpriseHubPublishedChangeAppService(
    {},
    {},
    createLocationService(),
  );

  const next = service.mergeBasic(
    {
      name: '示例公司',
      logoFileAssetId: null,
      coverFileAssetId: null,
      albumImageFileAssetIds: [],
      shortIntro: '简介',
      fullIntro: null,
      provinceCode: '510000',
      provinceName: '四川',
      cityCode: '510100',
      cityName: '成都',
      address: null,
      location: {
        addressText: null,
        publicDisplayAddress: null,
        provinceCode: '510000',
        provinceName: '四川',
        cityCode: '510100',
        cityName: '成都',
        districtCode: null,
        districtName: null,
        latitude: null,
        longitude: null,
        geoSource: 'unknown',
        geoStatus: 'not_provided',
        lastGeocodedAt: null,
        mapProvider: null,
        mapPreviewUrl: null,
        mapLinkUrl: null,
      },
      foundedAt: null,
      teamSizeRange: null,
      cooperationModes: [],
      contactVisible: true,
    },
    {
      provinceCode: '510000',
      provinceName: '四川',
      cityCode: '510100',
      cityName: '成都',
      location: {
        provinceCode: '510000',
        provinceName: '四川',
        cityCode: '510100',
        cityName: '成都',
      },
    },
  );

  assert.equal(next.provinceName, '四川省');
  assert.equal(next.cityName, '成都市');
  assert.equal(next.location.provinceName, '四川省');
  assert.equal(next.location.cityName, '成都市');
});
