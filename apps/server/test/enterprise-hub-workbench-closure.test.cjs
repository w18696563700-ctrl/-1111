const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId, overrides = {}) {
  return {
    authorization: 'Bearer carrier',
    actorId: '',
    userId: '',
    organizationId: 'raw-header-org',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
    ...overrides,
  };
}

function createRepository(initialItems = [], key = 'id') {
  const items = initialItems.map((item) => ({ ...item }));

  return {
    items,
    create(input) {
      return { ...input };
    },
    async save(value) {
      const index = items.findIndex((item) => item[key] === value[key]);
      const next = { ...value };
      if (index >= 0) {
        items[index] = next;
      } else {
        items.push(next);
      }
      return next;
    },
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
      if (matched.length === 0) {
        return null;
      }
      const order = options?.order ?? {};
      const ordered = [...matched].sort((left, right) => {
        for (const [field, direction] of Object.entries(order)) {
          const leftValue = left[field];
          const rightValue = right[field];
          const leftTime =
            leftValue instanceof Date ? leftValue.getTime() : leftValue ?? '';
          const rightTime =
            rightValue instanceof Date ? rightValue.getTime() : rightValue ?? '';
          if (leftTime === rightTime) {
            continue;
          }
          return direction === 'DESC'
            ? rightTime > leftTime
              ? 1
              : -1
            : leftTime > rightTime
              ? 1
              : -1;
        }
        return 0;
      });
      return ordered[0] ?? null;
    },
    async find(options) {
      const where = options?.where ?? {};
      const matched = items.filter((item) =>
        Object.entries(where).every(([field, expected]) => item[field] === expected),
      );
      const order = options?.order ?? {};
      if (!Object.keys(order).length) {
        return matched.map((item) => ({ ...item }));
      }
      return [...matched].sort((left, right) => {
        for (const [field, direction] of Object.entries(order)) {
          const leftValue = left[field];
          const rightValue = right[field];
          const leftTime =
            leftValue instanceof Date ? leftValue.getTime() : leftValue ?? '';
          const rightTime =
            rightValue instanceof Date ? rightValue.getTime() : rightValue ?? '';
          if (leftTime === rightTime) {
            continue;
          }
          return direction === 'DESC'
            ? rightTime > leftTime
              ? 1
              : -1
            : leftTime > rightTime
              ? 1
              : -1;
        }
        return 0;
      });
    },
    async findBy(where) {
      return items
        .filter((item) =>
          Object.entries(where).every(([field, expected]) => item[field] === expected),
        )
        .map((item) => ({ ...item }));
    },
    async count(options) {
      const where = options?.where;
      if (Array.isArray(where)) {
        return items.filter((item) =>
          where.some((candidate) =>
            Object.entries(candidate).every(([field, expected]) => item[field] === expected),
          ),
        ).length;
      }
      return items.filter((item) =>
        Object.entries(where ?? {}).every(([field, expected]) => item[field] === expected),
      ).length;
    },
    async countBy(where) {
      return items.filter((item) =>
        Object.entries(where).every(([field, expected]) => item[field] === expected),
      ).length;
    },
    async delete(where) {
      const predicate = (item) =>
        Object.entries(where).every(([field, expected]) => item[field] === expected);
      for (let index = items.length - 1; index >= 0; index -= 1) {
        if (predicate(items[index])) {
          items.splice(index, 1);
        }
      }
    },
  };
}

function createHarness(overrides = {}) {
  const { EnterpriseHubWriteService } = require('../dist/modules/enterprise_hub/enterprise-hub-write.service.js');
  const {
    EnterpriseHubContactWriteService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-contact-write.service.js');
  const {
    EnterpriseHubListingWriteSupportService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-listing-write-support.service.js');
  const {
    EnterpriseHubLocationService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-location.service.js');
  const { EnterpriseHubWorkbenchQueryService } = require('../dist/modules/enterprise_hub/enterprise-hub-workbench.query.service.js');
  const { EnterpriseHubWorkbenchPresenter } = require('../dist/modules/enterprise_hub/enterprise-hub-workbench.presenter.js');

  const baseListing = {
    id: 'enterprise-1',
    organizationId: 'org-1',
    primaryBoardType: 'company',
    secondaryCapabilities: [],
    name: '',
    shortIntro: '',
    fullIntro: null,
    logoFileAssetId: null,
    coverFileAssetId: null,
    provinceCode: '',
    provinceName: '',
    cityCode: '',
    cityName: '',
    address: null,
    foundedAt: null,
    teamSizeRange: null,
    cooperationModes: [],
    legalNameSnapshot: null,
    unifiedSocialCreditCodeSnapshot: null,
    verificationStatusSnapshot: 'verified',
    enterpriseStatus: 'unpublished',
    displayStatus: 'hidden',
    contactVisible: false,
    publishedAt: null,
    createdAt: new Date('2026-04-10T08:00:00.000Z'),
    updatedAt: new Date('2026-04-10T08:00:00.000Z'),
  };

  const repositories = {
    listingRepository: createRepository([overrides.listing ?? baseListing]),
    companyRepository: createRepository(overrides.company ? [overrides.company] : [], 'enterpriseId'),
    factoryRepository: createRepository(overrides.factory ? [overrides.factory] : [], 'enterpriseId'),
    supplierRepository: createRepository(overrides.supplier ? [overrides.supplier] : [], 'enterpriseId'),
    caseRepository: createRepository(overrides.cases ?? []),
    contactRepository: createRepository(overrides.contacts ?? []),
    applicationRepository: createRepository(overrides.applications ?? []),
    certificationSnapshotRepository: createRepository(overrides.certificationSnapshots ?? []),
    serviceAreaRepository: createRepository(overrides.serviceAreas ?? []),
    reviewSummaryRepository: createRepository(overrides.reviewSummaries ?? []),
    organizationCertificationRepository: createRepository(
      overrides.organizationCertifications ?? [
        {
          id: 'cert-1',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          legalName: '测试企业',
          uscc: '91310000TEST00001',
          licenseFileId: 'license-1',
          address: '成都市高新区天府大道 1 号',
          establishedAt: '2020-04-09',
          submittedAt: new Date('2026-04-10T08:00:00.000Z'),
          reviewedAt: new Date('2026-04-10T09:00:00.000Z'),
          rejectReason: null,
          updatedAt: new Date('2026-04-10T09:00:00.000Z'),
          createdAt: new Date('2026-04-10T08:00:00.000Z'),
        },
      ],
    ),
  };

  const verificationService = {
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
  };

  const eligibilityService = {
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
  };
  const locationService = new EnterpriseHubLocationService(
    verificationService,
    eligibilityService,
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
  const mediaTruthService = {
    async validateListingBasicMedia() {},
    async syncListingBasicRefs() {},
    async validateFactoryShowcaseMedia() {},
    async syncFactoryShowcaseRefs() {},
    async validateCaseMedia() {},
    async syncCaseRefs() {},
    async clearCaseRefs() {},
    async clearEnterpriseRefs() {},
  };

  const writeService = new EnterpriseHubWriteService(
    repositories.listingRepository,
    repositories.companyRepository,
    repositories.factoryRepository,
    repositories.supplierRepository,
    repositories.caseRepository,
    repositories.contactRepository,
    repositories.applicationRepository,
    repositories.certificationSnapshotRepository,
    repositories.serviceAreaRepository,
    repositories.reviewSummaryRepository,
    {
      async syncForListing() {
        return null;
      },
    },
    new EnterpriseHubContactWriteService(repositories.contactRepository),
    new EnterpriseHubListingWriteSupportService(
      repositories.listingRepository,
      repositories.serviceAreaRepository,
      verificationService,
      eligibilityService,
    ),
    locationService,
    {
      async ensureFactoryRecommendationSlot() {
        return null;
      },
    },
    mediaTruthService,
  );

  const queryService = new EnterpriseHubWorkbenchQueryService(
    repositories.listingRepository,
    repositories.applicationRepository,
    repositories.companyRepository,
    repositories.factoryRepository,
    repositories.supplierRepository,
    repositories.caseRepository,
    repositories.contactRepository,
    repositories.organizationCertificationRepository,
    verificationService,
    eligibilityService,
    new EnterpriseHubWorkbenchPresenter(locationService),
  );

  return {
    repositories,
    writeService,
    queryService,
  };
}

test('enterprise workbench basic save persists contactName and contactMobile into the current contact truth only', async () => {
  const harness = createHarness({
    applications: [
      {
        id: 'application-1',
        enterpriseId: 'enterprise-1',
        applyBoardType: 'company',
        applicationStatus: 'draft',
        createdAt: new Date('2026-04-10T08:00:00.000Z'),
        updatedAt: new Date('2026-04-10T08:00:00.000Z'),
      },
    ],
    company: {
      enterpriseId: 'enterprise-1',
      exhibitionTypes: ['expo'],
      serviceItems: ['design'],
      serviceCities: ['成都'],
    },
  });

  await harness.writeService.updateBasic(
    'enterprise-1',
    {
      name: '坤特展览',
      shortIntro: '展台搭建与执行',
      provinceCode: '510000',
      provinceName: '四川省',
      cityCode: '510100',
      cityName: '成都市',
      contactName: '王五',
      contactMobile: '13900000000',
      wechat: 'wechat-ignored',
      phone: '028-88888888',
      email: 'ignored@example.com',
      position: 'ignored-title',
    },
    createContext('workbench-basic-contact-save'),
  );

  assert.equal(harness.repositories.contactRepository.items.length, 1);
  assert.equal(harness.repositories.contactRepository.items[0].contactName, '王五');
  assert.equal(harness.repositories.contactRepository.items[0].mobile, '13900000000');
  assert.equal(harness.repositories.contactRepository.items[0].isPrimary, true);
  assert.equal(harness.repositories.contactRepository.items[0].wechat ?? null, null);
  assert.equal(harness.repositories.contactRepository.items[0].phone ?? null, null);
  assert.equal(harness.repositories.contactRepository.items[0].email ?? null, null);
  assert.equal(harness.repositories.contactRepository.items[0].position ?? null, null);

  const response = await harness.queryService.getWorkbench(
    createContext('workbench-basic-contact-readback'),
    'company',
  );

  assert.equal(response.primaryContact.contactName, '王五');
  assert.equal(response.primaryContact.mobile, '13900000000');
  assert.equal(response.primaryContact.wechat ?? null, null);
  assert.equal(response.primaryContact.phone ?? null, null);
  assert.equal(response.primaryContact.email ?? null, null);
  assert.equal(response.primaryContact.position ?? null, null);
  assert.equal(response.readiness.hasContact, true);
});

test('enterprise workbench basic save reads back the same server truth and does not depend on raw header organization scope', async () => {
  const harness = createHarness({
    applications: [
      {
        id: 'application-1',
        enterpriseId: 'enterprise-1',
        applyBoardType: 'company',
        applicationStatus: 'draft',
        createdAt: new Date('2026-04-10T08:00:00.000Z'),
        updatedAt: new Date('2026-04-10T08:00:00.000Z'),
      },
    ],
    contacts: [
      {
        id: 'contact-1',
        enterpriseId: 'enterprise-1',
        contactName: '李四',
        mobile: '13800000000',
        isPrimary: true,
        visibleToPublic: true,
      },
    ],
    company: {
      enterpriseId: 'enterprise-1',
      exhibitionTypes: ['expo'],
      serviceItems: ['design'],
      serviceCities: ['成都'],
    },
  });

  await harness.writeService.updateBasic(
    'enterprise-1',
    {
      name: '坤特展览',
      shortIntro: '展台搭建与执行',
      provinceCode: '510000',
      provinceName: '四川省',
      cityCode: '510100',
      cityName: '成都市',
      address: '成都市高新区天府大道 1 号',
      foundedAt: '2020-04-09',
    },
    createContext('workbench-basic-save', { organizationId: 'wrong-header-org' }),
  );

  const response = await harness.queryService.getWorkbench(
    createContext('workbench-basic-readback', { organizationId: 'wrong-header-org' }),
    'company',
  );

  assert.equal(response.organizationId, 'org-1');
  assert.equal(response.basic.name, '测试企业');
  assert.equal(response.basic.shortIntro, '展台搭建与执行');
  assert.equal(response.basic.provinceCode, '510000');
  assert.equal(response.basic.provinceName, '四川省');
  assert.equal(response.basic.cityCode, '510100');
  assert.equal(response.basic.cityName, '成都市');
  assert.equal(response.basic.address, '成都市高新区天府大道 1 号');
  assert.equal(response.basic.foundedAt, '2020-04-09');
  assert.equal(response.primaryContact.contactName, '李四');
  assert.equal(response.primaryContact.mobile, '13800000000');
  assert.equal(response.readiness.hasContact, true);
  assert.equal(response.readiness.basicCompleted, true);
});

test('enterprise workbench profileCompleted follows the current board minimum truth for company, factory, and supplier', async () => {
  const cases = [
    {
      boardType: 'company',
      profile: {
        enterpriseId: 'enterprise-1',
        exhibitionTypes: ['expo'],
        serviceItems: ['design'],
        serviceCities: ['成都'],
      },
    },
    {
      boardType: 'factory',
      profile: {
        enterpriseId: 'enterprise-1',
        factoryName: '工厂一号',
        processTypes: ['wood'],
        coreProducts: ['桁架'],
        showcaseImageFileAssetIds: [],
      },
    },
    {
      boardType: 'supplier',
      profile: {
        enterpriseId: 'enterprise-1',
        supplyCategories: ['lighting'],
        supplyMode: ['spot'],
        coreProductsOrServices: ['射灯'],
      },
    },
  ];

  for (const item of cases) {
    const harness = createHarness({
      listing: {
        id: 'enterprise-1',
        organizationId: 'org-1',
        primaryBoardType: item.boardType,
        secondaryCapabilities: [],
        name: '测试企业',
        shortIntro: '一句话简介',
        fullIntro: null,
        logoFileAssetId: null,
        coverFileAssetId: null,
        provinceCode: '510000',
        provinceName: '四川省',
        cityCode: '510100',
        cityName: '成都市',
        address: null,
        foundedAt: null,
        teamSizeRange: null,
        cooperationModes: [],
        legalNameSnapshot: null,
        unifiedSocialCreditCodeSnapshot: null,
        verificationStatusSnapshot: 'verified',
        enterpriseStatus: 'unpublished',
        displayStatus: 'hidden',
        contactVisible: false,
      },
      applications: [
        {
          id: 'application-1',
          enterpriseId: 'enterprise-1',
          applicationStatus: 'draft',
          createdAt: new Date('2026-04-10T08:00:00.000Z'),
          updatedAt: new Date('2026-04-10T08:00:00.000Z'),
        },
      ],
      contacts: [
        {
          id: 'contact-1',
          enterpriseId: 'enterprise-1',
          contactName: '李四',
          mobile: '13800000000',
          isPrimary: true,
          visibleToPublic: true,
        },
      ],
      company: item.boardType === 'company' ? item.profile : null,
      factory: item.boardType === 'factory' ? item.profile : null,
      supplier: item.boardType === 'supplier' ? item.profile : null,
    });

    const response = await harness.queryService.getWorkbench(
      createContext(`workbench-profile-${item.boardType}`),
      item.boardType,
    );
    assert.equal(response.readiness.profileCompleted, true);
  }
});

test('enterprise workbench case create keeps cover/media rule stable and readback sets hasCase from server truth', async () => {
  const harness = createHarness({
    applications: [
      {
        id: 'application-1',
        enterpriseId: 'enterprise-1',
        applyBoardType: 'company',
        applicationStatus: 'draft',
        createdAt: new Date('2026-04-10T08:00:00.000Z'),
        updatedAt: new Date('2026-04-10T08:00:00.000Z'),
      },
    ],
    contacts: [
      {
        id: 'contact-1',
        enterpriseId: 'enterprise-1',
        contactName: '李四',
        mobile: '13800000000',
        isPrimary: true,
        visibleToPublic: true,
      },
    ],
    company: {
      enterpriseId: 'enterprise-1',
      exhibitionTypes: ['expo'],
      serviceItems: ['design'],
      serviceCities: ['成都'],
    },
    listing: {
      id: 'enterprise-1',
      organizationId: 'org-1',
      primaryBoardType: 'company',
      secondaryCapabilities: [],
      name: '测试企业',
      shortIntro: '一句话简介',
      fullIntro: null,
      logoFileAssetId: null,
      coverFileAssetId: null,
      provinceCode: '510000',
      provinceName: '四川省',
      cityCode: '510100',
      cityName: '成都市',
      address: null,
      foundedAt: null,
      teamSizeRange: null,
      cooperationModes: [],
      legalNameSnapshot: null,
      unifiedSocialCreditCodeSnapshot: null,
      verificationStatusSnapshot: 'verified',
      enterpriseStatus: 'unpublished',
      displayStatus: 'hidden',
      contactVisible: false,
    },
  });

  const created = await harness.writeService.createCase(
    'enterprise-1',
    {
      boardType: 'company',
      title: '春季展案例',
      summary: '从方案到落地',
      caseMediaFileAssetIds: ['media-1', 'media-2'],
      exhibitionType: 'expo',
      city: '成都',
    },
    createContext('workbench-case-create'),
  );

  assert.equal(created.caseStatus, 'draft');
  assert.equal(harness.repositories.caseRepository.items.length, 1);
  assert.equal(harness.repositories.caseRepository.items[0].caseCoverFileAssetId, 'media-1');
  assert.deepEqual(harness.repositories.caseRepository.items[0].caseMediaFileAssetIds, ['media-1', 'media-2']);

  const response = await harness.queryService.getWorkbench(
    createContext('workbench-case-readback'),
    'company',
  );

  assert.equal(response.readiness.hasCase, true);
  assert.equal(response.cases.length, 1);
  assert.equal(response.cases[0].caseCoverFileAssetId, 'media-1');
  assert.deepEqual(response.cases[0].caseMediaFileAssetIds, ['media-1', 'media-2']);
});

test('enterprise workbench only returns cases from the current primary board type', async () => {
  const harness = createHarness({
    listing: {
      id: 'enterprise-1',
      organizationId: 'org-1',
      primaryBoardType: 'factory',
      secondaryCapabilities: [],
      name: '重庆坤特展览展示有限公司',
      shortIntro: '工厂工作台',
      fullIntro: null,
      logoFileAssetId: null,
      coverFileAssetId: null,
      provinceCode: '500000',
      provinceName: '重庆市',
      cityCode: '500100',
      cityName: '重庆市',
      address: null,
      foundedAt: null,
      teamSizeRange: null,
      cooperationModes: [],
      legalNameSnapshot: '重庆坤特展览展示有限公司',
      unifiedSocialCreditCodeSnapshot: null,
      verificationStatusSnapshot: 'verified',
      enterpriseStatus: 'unpublished',
      displayStatus: 'hidden',
      contactVisible: false,
      publishedAt: null,
      createdAt: new Date('2026-04-10T08:00:00.000Z'),
      updatedAt: new Date('2026-04-10T08:00:00.000Z'),
    },
    applications: [
      {
        id: 'application-1',
        enterpriseId: 'enterprise-1',
        applyBoardType: 'factory',
        applicationStatus: 'draft',
        createdAt: new Date('2026-04-10T08:00:00.000Z'),
        updatedAt: new Date('2026-04-10T08:00:00.000Z'),
      },
    ],
    factory: {
      enterpriseId: 'enterprise-1',
      factoryName: '重庆海川展览工厂',
      processTypes: ['木作'],
      coreProducts: ['展台搭建'],
      equipmentList: [],
      showcaseImageFileAssetIds: [],
    },
    cases: [
      {
        id: 'case-factory-1',
        enterpriseId: 'enterprise-1',
        boardType: 'factory',
        title: '工厂案例',
        exhibitionType: 'expo',
        city: '重庆',
        eventTime: '2026-04-01',
        summary: '应进入当前工作台',
        caseCoverFileAssetId: 'factory-media-1',
        caseMediaFileAssetIds: ['factory-media-1'],
        isFeatured: false,
        caseStatus: 'draft',
        createdAt: new Date('2026-04-10T08:00:00.000Z'),
        updatedAt: new Date('2026-04-10T08:00:00.000Z'),
      },
      {
        id: 'case-company-1',
        enterpriseId: 'enterprise-1',
        boardType: 'company',
        title: '公司案例',
        exhibitionType: 'expo',
        city: '重庆',
        eventTime: '2026-03-01',
        summary: '不应进入工厂工作台',
        caseCoverFileAssetId: 'company-media-1',
        caseMediaFileAssetIds: ['company-media-1'],
        isFeatured: false,
        caseStatus: 'draft',
        createdAt: new Date('2026-04-10T08:00:00.000Z'),
        updatedAt: new Date('2026-04-10T08:00:00.000Z'),
      },
    ],
  });

  const response = await harness.queryService.getWorkbench(
    createContext('workbench-board-isolation'),
    'factory',
  );

  assert.equal(response.boardType, 'factory');
  assert.equal(response.cases.length, 1);
  assert.equal(response.cases[0].caseId, 'case-factory-1');
  assert.equal(response.cases[0].boardType, 'factory');
});

test('enterprise workbench readiness and blockers come only from server truth gaps', async () => {
  const harness = createHarness({
    listing: {
      id: 'enterprise-1',
      organizationId: 'org-1',
      primaryBoardType: 'company',
      secondaryCapabilities: [],
      name: '测试企业',
      shortIntro: '',
      fullIntro: null,
      logoFileAssetId: null,
      coverFileAssetId: null,
      provinceCode: '510000',
      provinceName: '四川省',
      cityCode: '510100',
      cityName: '成都市',
      address: null,
      foundedAt: null,
      teamSizeRange: null,
      cooperationModes: [],
      legalNameSnapshot: null,
      unifiedSocialCreditCodeSnapshot: null,
      verificationStatusSnapshot: null,
      enterpriseStatus: 'unpublished',
      displayStatus: 'hidden',
      contactVisible: false,
    },
    organizationCertifications: [
      {
        id: 'cert-1',
        organizationId: 'org-1',
        certificationStatus: 'pending_review',
        legalName: '测试企业',
        uscc: '91310000TEST00001',
        licenseFileId: 'license-1',
        address: null,
        establishedAt: null,
        submittedAt: new Date('2026-04-10T08:00:00.000Z'),
        reviewedAt: null,
        rejectReason: null,
        updatedAt: new Date('2026-04-10T09:00:00.000Z'),
        createdAt: new Date('2026-04-10T08:00:00.000Z'),
      },
    ],
  });

  const response = await harness.queryService.getWorkbench(
    createContext('workbench-readiness-truth'),
    'company',
  );

  assert.equal(response.readiness.hasApplication, false);
  assert.equal(response.readiness.profileCompleted, false);
  assert.equal(response.readiness.hasCase, false);
  assert.equal(response.readiness.hasContact, false);
  assert.equal(response.readiness.certificationApproved, false);
  assert.equal(response.readiness.submitReady, false);
  assert.deepEqual(response.readiness.blockers, [
    '当前还没有申请草稿；保存资料和上传图片不受影响，真正提交前仍需补齐联系人并进入申请流。',
    '基础资料未完成，请补齐企业名称、一句话简介和组织所在城市。',
    '板块画像未完成，请补齐当前主板块的必填资料。',
    '当前至少需要 1 个已保存案例，请先保存案例到当前展示档。',
    '当前缺少主联系人，请先填写联系人。',
    '当前企业认证未通过，请先回到我的公司完成企业认证。',
  ]);
});

test('enterprise workbench distinguishes existing shell without application from no-shell state', async () => {
  const shellOnlyHarness = createHarness({
    applications: [],
    listing: {
      id: 'enterprise-1',
      organizationId: 'org-1',
      primaryBoardType: 'company',
      secondaryCapabilities: [],
      name: '测试企业',
      shortIntro: '一句话简介',
      fullIntro: null,
      logoFileAssetId: null,
      coverFileAssetId: null,
      provinceCode: '510000',
      provinceName: '四川省',
      cityCode: '510100',
      cityName: '成都市',
      address: null,
      foundedAt: null,
      teamSizeRange: null,
      cooperationModes: [],
      legalNameSnapshot: null,
      unifiedSocialCreditCodeSnapshot: null,
      verificationStatusSnapshot: 'verified',
      enterpriseStatus: 'unpublished',
      displayStatus: 'hidden',
      contactVisible: false,
    },
    company: {
      enterpriseId: 'enterprise-1',
      exhibitionTypes: ['expo'],
      serviceItems: ['design'],
      serviceCities: ['成都'],
    },
  });

  const shellOnlyResponse = await shellOnlyHarness.queryService.getWorkbench(
    createContext('workbench-shell-no-application'),
    'company',
  );

  assert.equal(shellOnlyResponse.enterpriseId, 'enterprise-1');
  assert.equal(shellOnlyResponse.latestApplication, null);
  assert.equal(shellOnlyResponse.readiness.hasApplication, false);
  assert.equal(shellOnlyResponse.readiness.blockers[0], '当前还没有申请草稿；保存资料和上传图片不受影响，真正提交前仍需补齐联系人并进入申请流。');

  const noShellHarness = createHarness();
  noShellHarness.repositories.listingRepository.items.length = 0;
  const noShellResponse = await noShellHarness.queryService.getWorkbench(
    createContext('workbench-no-shell'),
    'company',
  );

  assert.equal(noShellResponse.enterpriseId, null);
  assert.equal(noShellResponse.latestApplication, null);
  assert.equal(noShellResponse.readiness.hasApplication, false);
  assert.equal(
    noShellResponse.readiness.blockers[0],
    '当前还没有展示档，请先保存资料或上传图片创建展示档。',
  );
});

test('enterprise workbench keeps submitReady false and submit fail-closed when no case truth exists', async () => {
  const harness = createHarness({
    listing: {
      id: 'enterprise-1',
      organizationId: 'org-1',
      primaryBoardType: 'company',
      secondaryCapabilities: [],
      name: '测试企业',
      shortIntro: '一句话简介',
      fullIntro: null,
      logoFileAssetId: null,
      coverFileAssetId: null,
      provinceCode: '510000',
      provinceName: '四川省',
      cityCode: '510100',
      cityName: '成都市',
      address: null,
      foundedAt: null,
      teamSizeRange: null,
      cooperationModes: [],
      legalNameSnapshot: null,
      unifiedSocialCreditCodeSnapshot: null,
      verificationStatusSnapshot: 'verified',
      enterpriseStatus: 'unpublished',
      displayStatus: 'hidden',
      contactVisible: false,
    },
    applications: [
      {
        id: 'application-1',
        enterpriseId: 'enterprise-1',
        applicationStatus: 'draft',
        createdAt: new Date('2026-04-10T08:00:00.000Z'),
        updatedAt: new Date('2026-04-10T08:00:00.000Z'),
      },
    ],
    contacts: [
      {
        id: 'contact-1',
        enterpriseId: 'enterprise-1',
        contactName: '李四',
        mobile: '13800000000',
        isPrimary: true,
        visibleToPublic: true,
      },
    ],
    company: {
      enterpriseId: 'enterprise-1',
      exhibitionTypes: ['expo'],
      serviceItems: ['design'],
      serviceCities: ['成都'],
    },
    certificationSnapshots: [
      {
        id: 'cert-snapshot-1',
        enterpriseId: 'enterprise-1',
        certificationType: 'business_license',
        certificationName: '营业执照',
        certificationFileAssetId: 'license-1',
        certStatus: 'approved',
        reviewerId: null,
        reviewNote: null,
        verifiedAt: new Date('2026-04-10T09:00:00.000Z'),
      },
    ],
    cases: [],
  });

  const response = await harness.queryService.getWorkbench(
    createContext('workbench-no-case-ready'),
    'company',
  );

  assert.equal(response.readiness.hasCase, false);
  assert.equal(response.readiness.submitReady, false);
  assert.ok(
    response.readiness.blockers.includes(
      '当前至少需要 1 个已保存案例，请先保存案例到当前展示档。',
    ),
  );

  await assert.rejects(
    () =>
      harness.writeService.submitApplication(
        'application-1',
        { confirm: true },
        createContext('workbench-no-case-submit'),
      ),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_CASE_REQUIRED',
  );
});

test('enterprise submit is not blocked by case gate once at least one case truth exists', async () => {
  const harness = createHarness({
    listing: {
      id: 'enterprise-1',
      organizationId: 'org-1',
      primaryBoardType: 'company',
      secondaryCapabilities: [],
      name: '测试企业',
      shortIntro: '一句话简介',
      fullIntro: null,
      logoFileAssetId: null,
      coverFileAssetId: null,
      provinceCode: '510000',
      provinceName: '四川省',
      cityCode: '510100',
      cityName: '成都市',
      address: null,
      foundedAt: null,
      teamSizeRange: null,
      cooperationModes: [],
      legalNameSnapshot: null,
      unifiedSocialCreditCodeSnapshot: null,
      verificationStatusSnapshot: 'verified',
      enterpriseStatus: 'unpublished',
      displayStatus: 'hidden',
      contactVisible: false,
    },
    applications: [
      {
        id: 'application-1',
        enterpriseId: 'enterprise-1',
        applyBoardType: 'company',
        applicationStatus: 'draft',
        createdAt: new Date('2026-04-10T08:00:00.000Z'),
        updatedAt: new Date('2026-04-10T08:00:00.000Z'),
      },
    ],
    contacts: [
      {
        id: 'contact-1',
        enterpriseId: 'enterprise-1',
        contactName: '李四',
        mobile: '13800000000',
        isPrimary: true,
        visibleToPublic: true,
      },
    ],
    company: {
      enterpriseId: 'enterprise-1',
      exhibitionTypes: ['expo'],
      serviceItems: ['design'],
      serviceCities: ['成都'],
    },
    certificationSnapshots: [
      {
        id: 'cert-snapshot-1',
        enterpriseId: 'enterprise-1',
        certificationType: 'business_license',
        certificationName: '营业执照',
        certificationFileAssetId: 'license-1',
        certStatus: 'approved',
        reviewerId: null,
        reviewNote: null,
        verifiedAt: new Date('2026-04-10T09:00:00.000Z'),
      },
    ],
    cases: [
      {
        id: 'case-1',
        enterpriseId: 'enterprise-1',
        boardType: 'company',
        title: '春季展案例',
        exhibitionType: 'expo',
        city: '成都',
        eventTime: null,
        summary: '从方案到落地',
        caseCoverFileAssetId: 'media-1',
        caseMediaFileAssetIds: ['media-1'],
        isFeatured: false,
        caseStatus: 'draft',
        createdAt: new Date('2026-04-10T08:00:00.000Z'),
        updatedAt: new Date('2026-04-10T08:00:00.000Z'),
      },
    ],
  });

  const response = await harness.queryService.getWorkbench(
    createContext('workbench-has-case-ready'),
    'company',
  );
  assert.equal(response.readiness.hasCase, true);
  assert.equal(response.readiness.submitReady, true);

  const submitResult = await harness.writeService.submitApplication(
    'application-1',
    { confirm: true },
    createContext('workbench-has-case-submit'),
  );
  assert.equal(submitResult.ok, true);
  assert.equal(harness.repositories.applicationRepository.items[0].applicationStatus, 'approved');
  assert.equal(harness.repositories.applicationRepository.items[0].reviewerId, 'system:auto-review');
  assert.equal(harness.repositories.applicationRepository.items[0].reviewNote, 'auto-review rule v1');
});
