const test = require('node:test');
const assert = require('node:assert/strict');

function isFindOperator(value) {
  return value && typeof value === 'object' && value._type;
}

function matchesExpected(actual, expected) {
  if (isFindOperator(expected)) {
    if (expected._type === 'in') {
      return expected._value.includes(actual);
    }
    return false;
  }
  return actual === expected;
}

function matchesWhere(item, where = {}) {
  return Object.entries(where).every(([field, expected]) =>
    matchesExpected(item[field], expected),
  );
}

function createRepository(initialItems = [], key = 'id') {
  const items = initialItems.map((item) => ({ ...item }));

  return {
    items,
    create(input) {
      return { ...input };
    },
    async findOne(options = {}) {
      const where = options.where ?? {};
      const order = options.order ?? {};
      const matched = items.filter((item) => matchesWhere(item, where));
      const sorted = sortItems(matched, order);
      return sorted[0] ? { ...sorted[0] } : null;
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
    async findBy(where) {
      return items.filter((item) => matchesWhere(item, where)).map((item) => ({ ...item }));
    },
    async findOneBy(where) {
      const found = items.find((item) => matchesWhere(item, where));
      return found ? { ...found } : null;
    },
    async find(options = {}) {
      const where = options.where ?? {};
      const order = options.order ?? {};
      const matched = items.filter((item) => matchesWhere(item, where));
      return sortItems(matched, order).map((item) => ({ ...item }));
    },
  };
}

function sortItems(items, order = {}) {
  if (!Object.keys(order).length) {
    return [...items];
  }
  return [...items].sort((left, right) => {
    for (const [field, direction] of Object.entries(order)) {
      const leftValue = left[field] instanceof Date ? left[field].getTime() : left[field] ?? '';
      const rightValue = right[field] instanceof Date ? right[field].getTime() : right[field] ?? '';
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
}

function createListingRepository(initialItems = [], factoryRepository = null) {
  const repository = createRepository(initialItems);

  repository.createQueryBuilder = () => {
    const predicates = [];
    let order = {};
    let skipCount = 0;
    let takeCount = null;

    const queryBuilder = {
      where(sql, params) {
        predicates.push(createPredicate(sql, params, factoryRepository));
        return queryBuilder;
      },
      andWhere(sql, params) {
        predicates.push(createPredicate(sql, params, factoryRepository));
        return queryBuilder;
      },
      leftJoin() {
        return queryBuilder;
      },
      orderBy(field, direction) {
        order = { [field.split('.').at(-1)]: direction };
        return queryBuilder;
      },
      addOrderBy(field, direction) {
        order[field.split('.').at(-1)] = direction;
        return queryBuilder;
      },
      skip(value) {
        skipCount = value;
        return queryBuilder;
      },
      take(value) {
        takeCount = value;
        return queryBuilder;
      },
      async getCount() {
        return applyPredicates().length;
      },
      async getMany() {
        const ordered = sortItems(applyPredicates(), order);
        const sliced = ordered.slice(skipCount, takeCount == null ? undefined : skipCount + takeCount);
        return sliced.map((item) => ({ ...item }));
      },
    };

    function applyPredicates() {
      return repository.items.filter((item) =>
        predicates.every((predicate) => predicate(item)),
      );
    }

    return queryBuilder;
  };

  return repository;
}

function createPredicate(sql, params, factoryRepository) {
  if (sql.includes('listing.primaryBoardType = :boardType')) {
    return (item) => item.primaryBoardType === params.boardType;
  }
  if (sql.includes('listing.enterpriseStatus = :enterpriseStatus')) {
    return (item) => item.enterpriseStatus === params.enterpriseStatus;
  }
  if (sql.includes('listing.displayStatus = :displayStatus')) {
    return (item) => item.displayStatus === params.displayStatus;
  }
  if (sql.includes('listing.name ILIKE :keyword OR listing.shortIntro ILIKE :keyword')) {
    const keyword = String(params.keyword ?? '').toLowerCase().replace(/%/g, '');
    return (item) =>
      String(item.name ?? '').toLowerCase().includes(keyword) ||
      String(item.shortIntro ?? '').toLowerCase().includes(keyword);
  }
  if (sql.includes('listing.provinceCode = :provinceCode')) {
    return (item) => item.provinceCode === params.provinceCode;
  }
  if (sql.includes('listing.cityCode = :cityCode')) {
    return (item) => item.cityCode === params.cityCode;
  }
  if (sql.includes('factory.plantAreaSqm >= :plantAreaMin')) {
    return (item) => {
      const factory = factoryRepository?.items.find((entry) => entry.enterpriseId === item.id);
      return (factory?.plantAreaSqm ?? Number.NEGATIVE_INFINITY) >= params.plantAreaMin;
    };
  }
  if (sql.includes('factory.plantAreaSqm < :plantAreaMax')) {
    return (item) => {
      const factory = factoryRepository?.items.find((entry) => entry.enterpriseId === item.id);
      return (factory?.plantAreaSqm ?? Number.POSITIVE_INFINITY) < params.plantAreaMax;
    };
  }
  return () => true;
}

function createQueryHarness(overrides = {}) {
  const { EnterpriseHubQueryService } = require('../dist/modules/enterprise_hub/enterprise-hub-query.service.js');
  const { EnterpriseHubPresenter } = require('../dist/modules/enterprise_hub/enterprise-hub.presenter.js');
  const { EnterpriseHubLocationService } = require('../dist/modules/enterprise_hub/enterprise-hub-location.service.js');
  const {
    EnterpriseHubMediaProjectionService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-media-projection.service.js');

  const factoryRepository = createRepository(overrides.factories ?? [], 'enterpriseId');
  const listingRepository = createListingRepository(overrides.listings ?? [], factoryRepository);
  const caseRepository = createRepository(overrides.cases ?? []);
  const fileAssetRepository = createRepository(overrides.fileAssets ?? []);
  const mediaTruthService = {
    isEnterpriseDisplayImageFileAsset(fileAsset) {
      return !!fileAsset?.objectKey && String(fileAsset.mimeType ?? '').toLowerCase().startsWith('image/');
    },
  };
  const mediaProjectionService = new EnterpriseHubMediaProjectionService(
    fileAssetRepository,
    {
      async buildObjectAccessUrl(objectKey) {
        return `https://cdn.example.test/${objectKey}`;
      },
      buildObjectUrl(objectKey) {
        return `https://cdn.example.test/${objectKey}`;
      },
    },
    mediaTruthService,
  );
  const locationService = new EnterpriseHubLocationService(
    { async verifyCurrentSessionContext() { return null; } },
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

  const service = new EnterpriseHubQueryService(
    listingRepository,
    createRepository(overrides.companies ?? [], 'enterpriseId'),
    factoryRepository,
    createRepository(overrides.suppliers ?? [], 'enterpriseId'),
    caseRepository,
    createRepository(overrides.certificationSnapshots ?? []),
    createRepository(overrides.contacts ?? []),
    createRepository(overrides.applications ?? []),
    createRepository(overrides.reviewSummaries ?? [], 'enterpriseId'),
    createRepository(overrides.recommendationSlots ?? []),
    createRepository(overrides.serviceAreas ?? []),
    new EnterpriseHubPresenter(locationService),
    mediaProjectionService,
  );

  return {
    service,
    repositories: {
      listingRepository,
      caseRepository,
      factoryRepository,
      fileAssetRepository,
    },
  };
}

test('public list counts only approved cases and projects logoUrl from fileAsset truth', async () => {
  const harness = createQueryHarness({
    listings: [
      {
        id: 'enterprise-1',
        organizationId: 'org-1',
        primaryBoardType: 'company',
        secondaryCapabilities: [],
        name: '坤特展览',
        shortIntro: '展台执行',
        logoFileAssetId: 'logo-1',
        coverFileAssetId: 'cover-1',
        albumImageFileAssetIds: ['album-1', 'album-2'],
        provinceName: '四川省',
        cityName: '成都市',
        provinceCode: '510000',
        cityCode: '510100',
        verificationStatusSnapshot: 'verified',
        enterpriseStatus: 'published',
        displayStatus: 'visible',
        publishedAt: new Date('2026-04-11T10:00:00.000Z'),
        updatedAt: new Date('2026-04-11T10:00:00.000Z'),
      },
    ],
    cases: [
      {
        id: 'case-approved',
        enterpriseId: 'enterprise-1',
        boardType: 'company',
        caseCoverFileAssetId: 'case-cover-approved',
        caseStatus: 'approved',
      },
      {
        id: 'case-draft',
        enterpriseId: 'enterprise-1',
        boardType: 'company',
        caseCoverFileAssetId: 'case-cover-draft',
        caseStatus: 'draft',
      },
    ],
    reviewSummaries: [
      {
        enterpriseId: 'enterprise-1',
        avgScore: 4.8,
        keywordTags: ['执行快'],
      },
    ],
    fileAssets: [
      {
        id: 'logo-1',
        objectKey: 'enterprise/logo-1.png',
        mimeType: 'image/png',
      },
    ],
  });

  const response = await harness.service.getEnterprises({
    boardType: 'company',
    page: 1,
    pageSize: 20,
  });

  assert.equal(response.items.length, 1);
  assert.equal(response.items[0].caseCount, 1);
  assert.equal(
    response.items[0].logoUrl,
    'https://cdn.example.test/enterprise/logo-1.png',
  );
});

test('public detail returns only approved cases and projects case cover display urls', async () => {
  const harness = createQueryHarness({
    listings: [
      {
        id: 'enterprise-1',
        organizationId: 'org-1',
        primaryBoardType: 'company',
        secondaryCapabilities: [],
        name: '坤特展览',
        shortIntro: '展台执行',
        logoFileAssetId: 'logo-1',
        coverFileAssetId: 'cover-1',
        albumImageFileAssetIds: ['album-1', 'album-2'],
        provinceName: '四川省',
        cityName: '成都市',
        provinceCode: '510000',
        cityCode: '510100',
        legalNameSnapshot: '坤特展览有限公司',
        verificationStatusSnapshot: 'verified',
        enterpriseStatus: 'published',
        displayStatus: 'visible',
        publishedAt: new Date('2026-04-11T10:00:00.000Z'),
        updatedAt: new Date('2026-04-11T10:00:00.000Z'),
      },
    ],
    cases: [
      {
        id: 'case-approved',
        enterpriseId: 'enterprise-1',
        boardType: 'company',
        title: '春季展案例',
        summary: '从方案到落地',
        eventTime: '2026-03-01',
        caseCoverFileAssetId: 'case-cover-approved',
        caseStatus: 'approved',
      },
      {
        id: 'case-hidden',
        enterpriseId: 'enterprise-1',
        boardType: 'company',
        title: '草稿案例',
        summary: '不应进入公域',
        eventTime: '2026-02-01',
        caseCoverFileAssetId: 'case-cover-hidden',
        caseStatus: 'draft',
      },
    ],
    fileAssets: [
      {
        id: 'logo-1',
        objectKey: 'enterprise/logo-1.png',
        mimeType: 'image/png',
      },
      {
        id: 'album-1',
        objectKey: 'enterprise/album-1.png',
        mimeType: 'image/png',
      },
      {
        id: 'album-2',
        objectKey: 'enterprise/album-2.png',
        mimeType: 'image/png',
      },
      {
        id: 'case-cover-approved',
        objectKey: 'enterprise/cases/case-cover-approved.png',
        mimeType: 'image/png',
      },
      {
        id: 'case-cover-hidden',
        objectKey: 'enterprise/cases/case-cover-hidden.png',
        mimeType: 'image/png',
      },
    ],
  });

  const response = await harness.service.getEnterpriseDetail(
    'enterprise-1',
    'company',
  );

  assert.equal(
    response.header.logoUrl,
    'https://cdn.example.test/enterprise/logo-1.png',
  );
  assert.deepEqual(response.visualGallery, {
    albumImageUrls: [
      'https://cdn.example.test/enterprise/album-1.png',
      'https://cdn.example.test/enterprise/album-2.png',
    ],
    source: 'enterprise_album',
  });
  assert.equal(response.cases.length, 1);
  assert.equal(response.cases[0].id, 'case-approved');
  assert.equal(response.cases[0].caseStatus, 'approved');
  assert.equal(
    response.cases[0].coverImageUrl,
    'https://cdn.example.test/enterprise/cases/case-cover-approved.png',
  );
});

test('public factory list and detail ignore approved cases from other board types under the same enterprise id', async () => {
  const harness = createQueryHarness({
    listings: [
      {
        id: 'enterprise-1',
        organizationId: 'org-1',
        primaryBoardType: 'factory',
        secondaryCapabilities: [],
        name: '重庆坤特展览展示有限公司',
        shortIntro: '工厂板块',
        logoFileAssetId: null,
        coverFileAssetId: null,
        albumImageFileAssetIds: [],
        provinceName: '重庆市',
        cityName: '重庆市',
        provinceCode: '500000',
        cityCode: '500100',
        legalNameSnapshot: '重庆坤特展览展示有限公司',
        verificationStatusSnapshot: 'verified',
        enterpriseStatus: 'published',
        displayStatus: 'visible',
        publishedAt: new Date('2026-04-11T10:00:00.000Z'),
        updatedAt: new Date('2026-04-11T10:00:00.000Z'),
      },
    ],
    factories: [
      {
        enterpriseId: 'enterprise-1',
        factoryName: '重庆海川展览工厂',
        processTypes: ['木作'],
        coreProducts: ['展台搭建'],
        equipmentList: [],
        showcaseImageFileAssetIds: [],
      },
    ],
    cases: [
      {
        id: 'case-factory-approved',
        enterpriseId: 'enterprise-1',
        boardType: 'factory',
        title: '工厂案例',
        summary: '应进入工厂详情',
        eventTime: '2026-03-01',
        caseCoverFileAssetId: 'factory-cover',
        caseStatus: 'approved',
      },
      {
        id: 'case-company-approved',
        enterpriseId: 'enterprise-1',
        boardType: 'company',
        title: '公司案例',
        summary: '不应进入工厂详情',
        eventTime: '2026-02-01',
        caseCoverFileAssetId: 'company-cover',
        caseStatus: 'approved',
      },
    ],
    fileAssets: [
      {
        id: 'factory-cover',
        objectKey: 'enterprise/factory/factory-cover.png',
        mimeType: 'image/png',
      },
      {
        id: 'company-cover',
        objectKey: 'enterprise/company/company-cover.png',
        mimeType: 'image/png',
      },
    ],
  });

  const listResponse = await harness.service.getEnterprises({
    boardType: 'factory',
    page: 1,
    pageSize: 20,
  });
  assert.equal(listResponse.items.length, 1);
  assert.equal(listResponse.items[0].caseCount, 1);

  const detailResponse = await harness.service.getEnterpriseDetail(
    'enterprise-1',
    'factory',
  );
  assert.equal(detailResponse.cases.length, 1);
  assert.equal(detailResponse.cases[0].id, 'case-factory-approved');
  assert.equal(
    detailResponse.cases[0].coverImageUrl,
    'https://cdn.example.test/enterprise/factory/factory-cover.png',
  );
});

test('public case detail only exposes approved visible cases and hydrates image urls', async () => {
  const harness = createQueryHarness({
    listings: [
      {
        id: 'enterprise-1',
        organizationId: 'org-1',
        primaryBoardType: 'company',
        secondaryCapabilities: [],
        name: '坤特展览',
        shortIntro: '展台执行',
        provinceName: '四川省',
        cityName: '成都市',
        provinceCode: '510000',
        cityCode: '510100',
        verificationStatusSnapshot: 'verified',
        enterpriseStatus: 'published',
        displayStatus: 'visible',
      },
    ],
    cases: [
      {
        id: 'case-approved',
        enterpriseId: 'enterprise-1',
        boardType: 'company',
        title: '春季展案例',
        exhibitionType: '展陈施工',
        city: '成都',
        eventTime: '2026-03-01',
        summary: '从方案到落地',
        caseCoverFileAssetId: 'case-cover-approved',
        caseMediaFileAssetIds: ['case-cover-approved', 'case-media-approved'],
        isFeatured: true,
        caseStatus: 'approved',
      },
      {
        id: 'case-hidden',
        enterpriseId: 'enterprise-1',
        boardType: 'company',
        title: '草稿案例',
        summary: '不应进入公域',
        caseCoverFileAssetId: 'case-cover-hidden',
        caseMediaFileAssetIds: ['case-cover-hidden'],
        isFeatured: false,
        caseStatus: 'draft',
      },
    ],
    fileAssets: [
      {
        id: 'case-cover-approved',
        objectKey: 'enterprise/cases/case-cover-approved.png',
        mimeType: 'image/png',
      },
      {
        id: 'case-media-approved',
        objectKey: 'enterprise/cases/case-media-approved.png',
        mimeType: 'image/png',
      },
      {
        id: 'case-cover-hidden',
        objectKey: 'enterprise/cases/case-cover-hidden.png',
        mimeType: 'image/png',
      },
    ],
  });

  const detail = await harness.service.getPublicCaseDetail('case-approved');

  assert.equal(detail.caseId, 'case-approved');
  assert.equal(detail.caseStatus, 'approved');
  assert.equal(
    detail.caseImageUrlMap['case-cover-approved'],
    'https://cdn.example.test/enterprise/cases/case-cover-approved.png',
  );
  assert.equal(
    detail.caseImageUrlMap['case-media-approved'],
    'https://cdn.example.test/enterprise/cases/case-media-approved.png',
  );
  await assert.rejects(() => harness.service.getPublicCaseDetail('case-hidden'));
});

test('public case detail repairs stale case status from approved history before enforcing visibility', async () => {
  const harness = createQueryHarness({
    listings: [
      {
        id: 'enterprise-2',
        organizationId: 'org-2',
        primaryBoardType: 'company',
        secondaryCapabilities: [],
        name: '重庆坤特展览',
        shortIntro: '展陈执行',
        provinceName: '重庆市',
        cityName: '重庆市',
        provinceCode: '500000',
        cityCode: '500100',
        verificationStatusSnapshot: 'verified',
        enterpriseStatus: 'published',
        displayStatus: 'visible',
        publishedAt: new Date('2026-04-10T10:00:00.000Z'),
        updatedAt: new Date('2026-04-12T10:00:00.000Z'),
      },
    ],
    cases: [
      {
        id: 'case-stale-approved-history',
        enterpriseId: 'enterprise-2',
        boardType: 'company',
        title: '发布历史案例',
        exhibitionType: '展陈施工',
        city: '重庆',
        eventTime: '2026-04-01',
        summary: '详情页已能看到，但详情读链之前会误判不可用。',
        caseCoverFileAssetId: 'case-stale-cover',
        caseMediaFileAssetIds: ['case-stale-cover'],
        isFeatured: false,
        caseStatus: 'draft',
      },
    ],
    applications: [
      {
        id: 'app-approved-history',
        enterpriseId: 'enterprise-2',
        applyBoardType: 'company',
        applicationStatus: 'approved',
        reviewedAt: new Date('2026-04-10T10:00:00.000Z'),
        createdAt: new Date('2026-04-10T10:00:00.000Z'),
        updatedAt: new Date('2026-04-10T10:00:00.000Z'),
      },
      {
        id: 'app-submitted-latest',
        enterpriseId: 'enterprise-2',
        applyBoardType: 'company',
        applicationStatus: 'submitted',
        reviewedAt: null,
        createdAt: new Date('2026-04-12T10:00:00.000Z'),
        updatedAt: new Date('2026-04-12T10:00:00.000Z'),
      },
    ],
    fileAssets: [
      {
        id: 'case-stale-cover',
        objectKey: 'enterprise/cases/case-stale-cover.png',
        mimeType: 'image/png',
      },
    ],
  });

  const detail = await harness.service.getPublicCaseDetail(
    'case-stale-approved-history',
  );

  assert.equal(detail.caseId, 'case-stale-approved-history');
  assert.equal(detail.caseStatus, 'approved');
  assert.equal(
    detail.caseImageUrlMap['case-stale-cover'],
    'https://cdn.example.test/enterprise/cases/case-stale-cover.png',
  );
  assert.equal(
    harness.repositories.caseRepository.items.find(
      (item) => item.id === 'case-stale-approved-history',
    )?.caseStatus,
    'approved',
  );
});

test('factory public detail keeps factory title separate from legal name, projects showcase display urls, and treats empty cases as empty only', async () => {
  const harness = createQueryHarness({
    listings: [
      {
        id: 'factory-enterprise-1',
        organizationId: 'org-factory-1',
        primaryBoardType: 'factory',
        secondaryCapabilities: [],
        name: '重庆坤特展览展示有限公司',
        shortIntro: '工厂详情首屏摘要',
        logoFileAssetId: 'factory-logo-1',
        coverFileAssetId: null,
        albumImageFileAssetIds: ['album-1'],
        provinceName: '四川省',
        cityName: '成都市',
        provinceCode: '500000',
        cityCode: '500100',
        publicDisplayAddress: '重庆市江北区港城工业园 8 号',
        address: '重庆市江北区港城工业园 8 号',
        legalNameSnapshot: '重庆坤特展览展示有限公司',
        verificationStatusSnapshot: 'verified',
        enterpriseStatus: 'published',
        displayStatus: 'visible',
        publishedAt: new Date('2026-04-18T10:00:00.000Z'),
        updatedAt: new Date('2026-04-18T10:00:00.000Z'),
      },
    ],
    factories: [
      {
        enterpriseId: 'factory-enterprise-1',
        factoryName: '重庆海川展览工厂',
        processTypes: ['木作'],
        coreProducts: ['展台'],
        equipmentList: ['雕刻机'],
        showcaseImageFileAssetIds: ['showcase-1', 'showcase-2'],
        plantAreaSqm: 2400,
        monthlyCapacityDesc: null,
        urgentOrderCapability: null,
        urgentCycleDesc: null,
        warehouseCapability: true,
        transportCapability: null,
        maxOrderCapacityDesc: null,
        productionQualificationDesc: null,
        deliveryRadiusDesc: '重庆主城',
      },
    ],
    fileAssets: [
      {
        id: 'factory-logo-1',
        objectKey: 'enterprise/factory-logo-1.png',
        mimeType: 'image/png',
      },
      {
        id: 'showcase-1',
        objectKey: 'enterprise/factory/showcase-1.png',
        mimeType: 'image/png',
      },
      {
        id: 'showcase-2',
        objectKey: 'enterprise/factory/showcase-2.png',
        mimeType: 'image/png',
      },
      {
        id: 'album-1',
        objectKey: 'enterprise/factory/album-1.png',
        mimeType: 'image/png',
      },
    ],
  });

  const response = await harness.service.getEnterpriseDetail(
    'factory-enterprise-1',
    'factory',
  );

  assert.equal(response.header.name, '重庆海川展览工厂');
  assert.equal(response.basicInfo.legalName, '重庆坤特展览展示有限公司');
  assert.equal(response.header.provinceName, '重庆市');
  assert.equal(response.header.cityName, '重庆市');
  assert.equal(
    response.location.publicDisplayAddress,
    '重庆市江北区港城工业园 8 号',
  );
  assert.deepEqual(response.boardProfile.showcaseImageUrls, [
    'https://cdn.example.test/enterprise/factory/showcase-1.png',
    'https://cdn.example.test/enterprise/factory/showcase-2.png',
  ]);
  assert.equal(response.casesState, 'empty');
  assert.deepEqual(response.cases, []);
});

test('public factory list, detail, and recommendations share the same factory display name policy', async () => {
  const now = new Date('2026-04-18T10:00:00.000Z');
  const harness = createQueryHarness({
    listings: [
      {
        id: 'factory-enterprise-1',
        organizationId: 'org-factory-1',
        primaryBoardType: 'factory',
        secondaryCapabilities: [],
        name: '重庆坤特展览展示有限公司',
        shortIntro: '工厂详情首屏摘要',
        logoFileAssetId: null,
        coverFileAssetId: null,
        provinceName: '重庆市',
        cityName: '重庆市',
        provinceCode: '500000',
        cityCode: '500100',
        legalNameSnapshot: '重庆坤特展览展示有限公司',
        verificationStatusSnapshot: 'verified',
        enterpriseStatus: 'published',
        displayStatus: 'visible',
        publishedAt: now,
        updatedAt: now,
      },
    ],
    factories: [
      {
        enterpriseId: 'factory-enterprise-1',
        factoryName: '重庆海川展览工厂',
        processTypes: ['木作'],
        coreProducts: ['展台'],
        equipmentList: ['雕刻机'],
        showcaseImageFileAssetIds: [],
      },
    ],
    recommendationSlots: [
      {
        id: 'slot-factory-1',
        boardType: 'factory',
        slotPosition: 1,
        enterpriseId: 'factory-enterprise-1',
        slotStatus: 'active',
        startAt: new Date('2020-01-01T00:00:00.000Z'),
        endAt: new Date('2030-01-01T00:00:00.000Z'),
        sourceType: 'manual',
        scoreSnapshot: null,
        createdAt: now,
      },
    ],
  });

  const listResponse = await harness.service.getEnterprises({
    boardType: 'factory',
    page: 1,
    pageSize: 20,
  });
  assert.equal(listResponse.items[0].name, '重庆海川展览工厂');

  const detail = await harness.service.getEnterpriseDetail(
    'factory-enterprise-1',
    'factory',
  );
  assert.equal(detail.header.name, '重庆海川展览工厂');

  const recommendations = await harness.service.getRecommendations({
    boardType: 'factory',
  });
  assert.equal(recommendations.items[0].name, '重庆海川展览工厂');
});

test('public list, detail, and recommendations share the same published plus visible listing boundary', async () => {
  const now = new Date('2026-04-11T10:00:00.000Z');
  const harness = createQueryHarness({
    listings: [
      {
        id: 'visible-enterprise',
        organizationId: 'org-1',
        primaryBoardType: 'company',
        secondaryCapabilities: [],
        name: '可见企业',
        shortIntro: '允许公域读取',
        logoFileAssetId: null,
        coverFileAssetId: null,
        provinceName: '四川省',
        cityName: '成都市',
        provinceCode: '510000',
        cityCode: '510100',
        verificationStatusSnapshot: 'verified',
        enterpriseStatus: 'published',
        displayStatus: 'visible',
        publishedAt: now,
        updatedAt: now,
      },
      {
        id: 'hidden-enterprise',
        organizationId: 'org-2',
        primaryBoardType: 'company',
        secondaryCapabilities: [],
        name: '隐藏企业',
        shortIntro: '不允许公域读取',
        logoFileAssetId: null,
        coverFileAssetId: null,
        provinceName: '四川省',
        cityName: '成都市',
        provinceCode: '510000',
        cityCode: '510100',
        verificationStatusSnapshot: 'verified',
        enterpriseStatus: 'published',
        displayStatus: 'hidden',
        publishedAt: now,
        updatedAt: now,
      },
      {
        id: 'unpublished-enterprise',
        organizationId: 'org-3',
        primaryBoardType: 'company',
        secondaryCapabilities: [],
        name: '未发布企业',
        shortIntro: '不允许公域读取',
        logoFileAssetId: null,
        coverFileAssetId: null,
        provinceName: '四川省',
        cityName: '成都市',
        provinceCode: '510000',
        cityCode: '510100',
        verificationStatusSnapshot: 'verified',
        enterpriseStatus: 'unpublished',
        displayStatus: 'visible',
        publishedAt: null,
        updatedAt: now,
      },
    ],
    recommendationSlots: [
      {
        id: 'slot-visible',
        boardType: 'company',
        slotPosition: 1,
        enterpriseId: 'visible-enterprise',
        slotStatus: 'active',
        startAt: new Date('2020-01-01T00:00:00.000Z'),
        endAt: new Date('2030-01-01T00:00:00.000Z'),
        sourceType: 'manual',
        scoreSnapshot: null,
        createdAt: now,
      },
      {
        id: 'slot-hidden',
        boardType: 'company',
        slotPosition: 2,
        enterpriseId: 'hidden-enterprise',
        slotStatus: 'active',
        startAt: new Date('2020-01-01T00:00:00.000Z'),
        endAt: new Date('2030-01-01T00:00:00.000Z'),
        sourceType: 'manual',
        scoreSnapshot: null,
        createdAt: now,
      },
      {
        id: 'slot-unpublished',
        boardType: 'company',
        slotPosition: 3,
        enterpriseId: 'unpublished-enterprise',
        slotStatus: 'active',
        startAt: new Date('2020-01-01T00:00:00.000Z'),
        endAt: new Date('2030-01-01T00:00:00.000Z'),
        sourceType: 'manual',
        scoreSnapshot: null,
        createdAt: now,
      },
    ],
  });

  const listResponse = await harness.service.getEnterprises({
    boardType: 'company',
    page: 1,
    pageSize: 20,
  });
  assert.deepEqual(
    listResponse.items.map((item) => item.enterpriseId),
    ['visible-enterprise'],
  );

  const detail = await harness.service.getEnterpriseDetail(
    'visible-enterprise',
    'company',
  );
  assert.equal(detail.header.enterpriseId, 'visible-enterprise');

  await assert.rejects(
    () => harness.service.getEnterpriseDetail('hidden-enterprise', 'company'),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
  );
  await assert.rejects(
    () => harness.service.getEnterpriseDetail('unpublished-enterprise', 'company'),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
  );

  const recommendations = await harness.service.getRecommendations({
    boardType: 'company',
  });
  assert.deepEqual(
    recommendations.items.map((item) => item.enterpriseId),
    ['visible-enterprise'],
  );
});
