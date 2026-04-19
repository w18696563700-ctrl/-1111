const test = require('node:test');
const assert = require('node:assert/strict');

function createRepository(initialItems = [], key = 'id') {
  const items = initialItems.map((item) => ({ ...item }));
  return {
    items,
    async findOne(options) {
      const where = options?.where ?? {};
      const matched = items.filter((item) =>
        Object.entries(where).every(([field, expected]) => item[field] === expected),
      );
      const order = Object.entries(options?.order ?? {});
      const sorted = [...matched].sort((left, right) => {
        for (const [field, direction] of order) {
          const leftValue =
            left[field] instanceof Date ? left[field].getTime() : left[field] ?? '';
          const rightValue =
            right[field] instanceof Date ? right[field].getTime() : right[field] ?? '';
          if (leftValue === rightValue) {
            continue;
          }
          return direction === 'DESC'
            ? rightValue > leftValue
              ? 1
              : -1
            : leftValue > rightValue
              ? 1
              : -1;
        }
        return 0;
      });
      return sorted[0] ?? null;
    },
    async findOneBy(where) {
      return (
        items.find((item) =>
          Object.entries(where).every(([field, expected]) => item[field] === expected),
        ) ?? null
      );
    },
    async findBy(where) {
      return items
        .filter((item) =>
          Object.entries(where).every(([field, expected]) => item[field] === expected),
        )
        .map((item) => ({ ...item }));
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

function createLocationService() {
  const { EnterpriseHubLocationService } = require('../dist/modules/enterprise_hub/enterprise-hub-location.service.js');
  return new EnterpriseHubLocationService(
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: context.actorId ?? 'actor-1',
            userId: context.userId ?? 'user-1',
            organizationId: 'org-1',
            requestId: context.requestId ?? 'req-1',
            traceId: context.traceId ?? 'trace-1',
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

function createMediaProjectionService() {
  return {
    async buildDisplayUrlMap(fileAssetIds) {
      return new Map(
        fileAssetIds
          .filter((item) => typeof item === 'string' && item.trim().length > 0)
          .map((item) => [item, `https://example.com/${item}.png`]),
      );
    },
    readDisplayUrl(fileAssetId, urlMap) {
      if (!fileAssetId) {
        return null;
      }
      return urlMap.get(fileAssetId) ?? null;
    },
  };
}

test('public factory detail repairs approved application drift and exposes approved cases', async () => {
  const { EnterpriseHubQueryService } = require('../dist/modules/enterprise_hub/enterprise-hub-query.service.js');
  const { EnterpriseHubPresenter } = require('../dist/modules/enterprise_hub/enterprise-hub.presenter.js');

  const listingRepository = createRepository([
    {
      id: 'enterprise-1',
      organizationId: 'org-1',
      primaryBoardType: 'factory',
      secondaryCapabilities: [],
      name: '重庆坤特展览展示有限公司',
      shortIntro: '主打木作制作。',
      fullIntro: '完整介绍',
      logoFileAssetId: 'logo-1',
      albumImageFileAssetIds: [],
      provinceCode: '500000',
      provinceName: '重庆市',
      cityCode: '500100',
      cityName: '重庆市',
      address: '重庆市江北区洋河二村 73 号',
      foundedAt: '2019-09-09',
      teamSizeRange: '31-100',
      cooperationModes: [],
      legalNameSnapshot: '重庆坤特展览展示有限公司',
      verificationStatusSnapshot: 'verified',
      enterpriseStatus: 'published',
      displayStatus: 'visible',
      contactVisible: true,
      publishedAt: new Date('2026-04-10T08:00:00.000Z'),
    },
  ]);
  const factoryRepository = createRepository(
    [
      {
        enterpriseId: 'enterprise-1',
        factoryName: '重庆海川展览工厂',
        processTypes: ['木作'],
        coreProducts: ['展台搭建'],
        equipmentList: ['推台锯'],
        showcaseImageFileAssetIds: [],
        plantAreaSqm: 5000,
      },
    ],
    'enterpriseId',
  );
  const caseRepository = createRepository([
    {
      id: 'case-1',
      enterpriseId: 'enterprise-1',
      boardType: 'factory',
      title: '重庆车展展台搭建',
      exhibitionType: '展台搭建',
      city: '重庆',
      eventTime: '2026-03-01',
      summary: '双层木作结构与现场执行案例。',
      caseCoverFileAssetId: 'case-cover-1',
      caseMediaFileAssetIds: ['case-cover-1'],
      isFeatured: true,
      sortOrder: null,
      caseStatus: 'draft',
      reviewNote: null,
      createdAt: new Date('2026-04-10T08:00:00.000Z'),
      updatedAt: new Date('2026-04-10T08:00:00.000Z'),
    },
  ]);
  const applicationRepository = createRepository([
    {
      id: 'app-1',
      enterpriseId: 'enterprise-1',
      applyBoardType: 'factory',
      applicationStatus: 'approved',
      reviewedAt: new Date('2026-04-12T10:00:00.000Z'),
      createdAt: new Date('2026-04-12T10:00:00.000Z'),
      updatedAt: new Date('2026-04-12T10:00:00.000Z'),
    },
  ]);

  const locationService = createLocationService();
  const service = new EnterpriseHubQueryService(
    listingRepository,
    createRepository([], 'enterpriseId'),
    factoryRepository,
    createRepository([], 'enterpriseId'),
    caseRepository,
    createRepository([]),
    createRepository([]),
    applicationRepository,
    createRepository([], 'enterpriseId'),
    createRepository([]),
    createRepository([]),
    new EnterpriseHubPresenter(locationService),
    createMediaProjectionService(),
    {
      async ensureFactoryRecommendationSlot() {
        return true;
      },
    },
    {
      async repairListingFromCertificationIfNeeded() {},
      async repairListingsFromCertificationIfNeeded() {},
    },
  );

  const detail = await service.getEnterpriseDetail('enterprise-1', 'factory');

  assert.equal(detail.cases.length, 1);
  assert.equal(detail.cases[0].id, 'case-1');
  assert.equal(detail.cases[0].caseStatus, 'approved');
  assert.equal(caseRepository.items[0].caseStatus, 'approved');
});

test('public company detail repairs live-case drift from approved history even when latest application is submitted', async () => {
  const { EnterpriseHubQueryService } = require('../dist/modules/enterprise_hub/enterprise-hub-query.service.js');
  const { EnterpriseHubPresenter } = require('../dist/modules/enterprise_hub/enterprise-hub.presenter.js');

  const listingRepository = createRepository([
    {
      id: 'enterprise-2',
      organizationId: 'org-1',
      primaryBoardType: 'company',
      secondaryCapabilities: [],
      name: '重庆坤特展览展示有限公司',
      shortIntro: '主打展陈搭建。',
      fullIntro: '完整介绍',
      logoFileAssetId: 'logo-2',
      albumImageFileAssetIds: [],
      provinceCode: '500000',
      provinceName: '重庆市',
      cityCode: '500100',
      cityName: '重庆市',
      address: '重庆市江北区洋河二村 73 号',
      foundedAt: '2019-09-09',
      teamSizeRange: '31-100',
      cooperationModes: [],
      legalNameSnapshot: '重庆坤特展览展示有限公司',
      verificationStatusSnapshot: 'verified',
      enterpriseStatus: 'published',
      displayStatus: 'visible',
      contactVisible: true,
      publishedAt: new Date('2026-04-10T08:00:00.000Z'),
    },
  ]);
  const caseRepository = createRepository([
    {
      id: 'case-2',
      enterpriseId: 'enterprise-2',
      boardType: 'company',
      title: '机械展',
      exhibitionType: '展台搭建',
      city: '重庆',
      eventTime: '2026-03-01',
      summary: '已发布公司的历史案例。',
      caseCoverFileAssetId: 'case-cover-2',
      caseMediaFileAssetIds: ['case-cover-2'],
      isFeatured: false,
      sortOrder: null,
      caseStatus: 'draft',
      reviewNote: null,
      createdAt: new Date('2026-04-10T08:00:00.000Z'),
      updatedAt: new Date('2026-04-10T08:00:00.000Z'),
    },
  ]);
  const applicationRepository = createRepository([
    {
      id: 'app-approved',
      enterpriseId: 'enterprise-2',
      applyBoardType: 'company',
      applicationStatus: 'approved',
      reviewedAt: new Date('2026-04-10T10:00:00.000Z'),
      createdAt: new Date('2026-04-10T10:00:00.000Z'),
      updatedAt: new Date('2026-04-10T10:00:00.000Z'),
    },
    {
      id: 'app-submitted',
      enterpriseId: 'enterprise-2',
      applyBoardType: 'company',
      applicationStatus: 'submitted',
      reviewedAt: null,
      createdAt: new Date('2026-04-12T10:00:00.000Z'),
      updatedAt: new Date('2026-04-12T10:00:00.000Z'),
    },
  ]);

  const locationService = createLocationService();
  const service = new EnterpriseHubQueryService(
    listingRepository,
    createRepository([], 'enterpriseId'),
    createRepository([], 'enterpriseId'),
    createRepository([], 'enterpriseId'),
    caseRepository,
    createRepository([]),
    createRepository([]),
    applicationRepository,
    createRepository([], 'enterpriseId'),
    createRepository([]),
    createRepository([]),
    new EnterpriseHubPresenter(locationService),
    createMediaProjectionService(),
    {
      async ensureFactoryRecommendationSlot() {
        return true;
      },
    },
    {
      async repairListingFromCertificationIfNeeded() {},
      async repairListingsFromCertificationIfNeeded() {},
    },
  );

  const detail = await service.getEnterpriseDetail('enterprise-2', 'company');

  assert.equal(detail.cases.length, 1);
  assert.equal(detail.cases[0].id, 'case-2');
  assert.equal(detail.cases[0].caseStatus, 'approved');
  assert.equal(caseRepository.items[0].caseStatus, 'approved');
});

test('published change snapshot rehydrates case image url map from saved file asset ids', async () => {
  const {
    EnterpriseHubPublishedChangeSnapshotService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change-snapshot.service.js');

  const snapshotService = new EnterpriseHubPublishedChangeSnapshotService(
    createRepository([], 'enterpriseId'),
    createRepository([], 'enterpriseId'),
    createRepository([], 'enterpriseId'),
    createRepository([]),
    createRepository([]),
    createLocationService(),
    createMediaProjectionService(),
  );

  const hydrated = await snapshotService.hydrateSnapshotMedia(
    {
      id: 'enterprise-1',
      primaryBoardType: 'factory',
    },
    {
      basic: {
        name: '重庆海川展览工厂',
        logoFileAssetId: 'logo-1',
        logoUrl: null,
        albumImageFileAssetIds: ['album-1'],
        albumImageUrlMap: {},
        shortIntro: '工厂简介',
        fullIntro: '完整介绍',
        provinceCode: '500000',
        provinceName: '重庆市',
        cityCode: '500100',
        cityName: '重庆市',
        address: '重庆市江北区洋河二村 73 号',
        location: null,
        foundedAt: '2019-09-09',
        teamSizeRange: '31-100',
        cooperationModes: [],
        contactVisible: true,
      },
      boardProfile: {
        factoryName: '重庆海川展览工厂',
        processTypes: ['木作'],
        coreProducts: ['展台搭建'],
        equipmentList: ['推台锯'],
        showcaseImageFileAssetIds: ['showcase-1'],
      },
      primaryContact: null,
      cases: [
        {
          caseId: 'case-1',
          boardType: 'factory',
          title: '重庆车展展台搭建',
          exhibitionType: '展台搭建',
          city: '重庆',
          eventTime: '2026-03-01',
          summary: '双层木作结构与现场执行案例。',
          caseCoverFileAssetId: 'case-cover-1',
          caseMediaFileAssetIds: ['case-media-1'],
          caseImageUrlMap: {},
          isFeatured: true,
          caseStatus: 'draft',
        },
      ],
    },
  );

  assert.equal(
    hydrated.basic.albumImageUrlMap['album-1'],
    'https://example.com/album-1.png',
  );
  assert.equal(
    hydrated.boardProfile.showcaseImageUrlMap['showcase-1'],
    'https://example.com/showcase-1.png',
  );
  assert.equal(
    hydrated.cases[0].caseImageUrlMap['case-cover-1'],
    'https://example.com/case-cover-1.png',
  );
  assert.equal(
    hydrated.cases[0].caseImageUrlMap['case-media-1'],
    'https://example.com/case-media-1.png',
  );
});
