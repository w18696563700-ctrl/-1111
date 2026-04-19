const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId, overrides = {}) {
  return {
    authorization: 'Bearer media-truth',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'header-org',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
    ...overrides,
  };
}

function matchesExpected(actual, expected) {
  if (expected && typeof expected === 'object' && expected._type === 'in') {
    return expected._value.includes(actual);
  }
  return actual === expected;
}

function createRepository(initialItems = [], key = 'id') {
  const items = initialItems.map((item) => ({ ...item }));
  return {
    items,
    create(input) {
      return { ...input };
    },
    async save(value) {
      if (Array.isArray(value)) {
        const saved = [];
        for (const item of value) {
          saved.push(await this.save(item));
        }
        return saved;
      }
      const next = { ...value };
      const index = items.findIndex((item) => item[key] === next[key]);
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
          Object.entries(where).every(([field, expected]) =>
            matchesExpected(item[field], expected),
          ),
        ) ?? null
      );
    },
    async findBy(where) {
      return items
        .filter((item) =>
          Object.entries(where).every(([field, expected]) =>
            matchesExpected(item[field], expected),
          ),
        )
        .map((item) => ({ ...item }));
    },
    async findOne(options) {
      const where = options?.where ?? {};
      return this.findOneBy(where);
    },
    async find(options = {}) {
      const where = options?.where ?? {};
      return items
        .filter((item) =>
          Object.entries(where).every(([field, expected]) =>
            matchesExpected(item[field], expected),
          ),
        )
        .map((item) => ({ ...item }));
    },
    async delete(where) {
      for (let index = items.length - 1; index >= 0; index -= 1) {
        const item = items[index];
        if (
          Object.entries(where).every(([field, expected]) =>
            matchesExpected(item[field], expected),
          )
        ) {
          items.splice(index, 1);
        }
      }
    },
    async count() {
      return items.length;
    },
  };
}

function createLocationService() {
  const { EnterpriseHubLocationService } = require('../dist/modules/enterprise_hub/enterprise-hub-location.service.js');
  return new EnterpriseHubLocationService(
    {
      async verifyCurrentSessionContext() {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'actor-1',
            userId: 'user-1',
            organizationId: 'session-org',
            requestId: 'req',
            traceId: 'trace',
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

function createMediaTruthHarness(overrides = {}) {
  const {
    EnterpriseHubWriteService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-write.service.js');
  const {
    EnterpriseHubContactWriteService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-contact-write.service.js');
  const {
    EnterpriseHubListingWriteSupportService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-listing-write-support.service.js');
  const {
    EnterpriseHubMediaTruthService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-media-truth.service.js');

  const listing = {
    id: 'enterprise-1',
    organizationId: 'org-1',
    primaryBoardType: 'company',
    secondaryCapabilities: [],
    name: '测试企业',
    shortIntro: '简介',
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
    enterpriseStatus: overrides.enterpriseStatus ?? 'unpublished',
    displayStatus: overrides.displayStatus ?? 'hidden',
    contactVisible: false,
    publishedAt:
      overrides.enterpriseStatus === 'published'
        ? new Date('2026-04-10T08:00:00.000Z')
        : null,
    createdAt: new Date('2026-04-10T08:00:00.000Z'),
    updatedAt: new Date('2026-04-10T08:00:00.000Z'),
  };

  const repositories = {
    listingRepository: createRepository([listing]),
    companyRepository: createRepository([], 'enterpriseId'),
    factoryRepository: createRepository([], 'enterpriseId'),
    supplierRepository: createRepository([], 'enterpriseId'),
    caseRepository: createRepository(overrides.cases ?? []),
    contactRepository: createRepository(overrides.contacts ?? []),
    applicationRepository: createRepository(overrides.applications ?? []),
    certificationSnapshotRepository: createRepository([]),
    serviceAreaRepository: createRepository([]),
    reviewSummaryRepository: createRepository([]),
    fileAssetRepository: createRepository(overrides.fileAssets ?? []),
    mediaAssetRefRepository: createRepository([], 'id'),
  };

  const verificationService = {
    async verifyCurrentSessionContext(context) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'actor-1',
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

  const locationService = createLocationService();
  const listingWriteSupportService = new EnterpriseHubListingWriteSupportService(
    repositories.listingRepository,
    repositories.serviceAreaRepository,
    verificationService,
    eligibilityService,
  );
  const mediaTruthService = new EnterpriseHubMediaTruthService(
    repositories.fileAssetRepository,
    repositories.mediaAssetRefRepository,
  );

  return {
    repositories,
    mediaTruthService,
    writeService: new EnterpriseHubWriteService(
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
      listingWriteSupportService,
      locationService,
      {
        async ensureFactoryRecommendationSlot() {
          return null;
        },
      },
      mediaTruthService,
    ),
  };
}

function createPublishedChangeHarness(overrides = {}) {
  const {
    EnterpriseHubContactWriteService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-contact-write.service.js');
  const {
    EnterpriseHubListingWriteSupportService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-listing-write-support.service.js');
  const {
    EnterpriseHubPublishedChangeSupportService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change-support.service.js');
  const {
    EnterpriseHubPublishedChangeAppService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change-app.service.js');
  const {
    EnterpriseHubPublishedChangeLiveWriteService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change-live-write.service.js');
  const {
    EnterpriseHubMediaTruthService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-media-truth.service.js');

  const listing = {
    id: 'enterprise-1',
    organizationId: 'org-1',
    primaryBoardType: 'company',
    secondaryCapabilities: [],
    name: '线上企业',
    shortIntro: '原始简介',
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
    enterpriseStatus: 'published',
    displayStatus: 'visible',
    contactVisible: true,
    publishedAt: new Date('2026-04-10T08:00:00.000Z'),
    createdAt: new Date('2026-04-10T08:00:00.000Z'),
    updatedAt: new Date('2026-04-10T08:00:00.000Z'),
  };

  const repositories = {
    listingRepository: createRepository([listing]),
    companyRepository: createRepository([], 'enterpriseId'),
    factoryRepository: createRepository([], 'enterpriseId'),
    supplierRepository: createRepository([], 'enterpriseId'),
    caseRepository: createRepository(overrides.cases ?? []),
    contactRepository: createRepository(
      overrides.contacts ?? [
        {
          id: 'contact-1',
          enterpriseId: 'enterprise-1',
          contactName: '张三',
          mobile: '13900000000',
          wechat: null,
          phone: null,
          email: null,
          position: null,
          isPrimary: true,
          visibleToPublic: true,
        },
      ],
    ),
    changeRequestRepository: createRepository([]),
    serviceAreaRepository: createRepository([]),
    fileAssetRepository: createRepository(overrides.fileAssets ?? []),
    mediaAssetRefRepository: createRepository([], 'id'),
  };

  const verificationService = {
    async verifyCurrentSessionContext(context) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'actor-1',
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

  const locationService = createLocationService();
  const listingWriteSupportService = new EnterpriseHubListingWriteSupportService(
    repositories.listingRepository,
    repositories.serviceAreaRepository,
    verificationService,
    eligibilityService,
  );
  const mediaTruthService = new EnterpriseHubMediaTruthService(
    repositories.fileAssetRepository,
    repositories.mediaAssetRefRepository,
  );
  const supportService = new EnterpriseHubPublishedChangeSupportService(
    repositories.listingRepository,
    repositories.changeRequestRepository,
    listingWriteSupportService,
    {
      async buildLiveSnapshot() {
        return {
          basic: {
            name: '线上企业',
            logoFileAssetId: null,
            coverFileAssetId: null,
            logoUrl: null,
            albumImageFileAssetIds: [],
            albumImageUrlMap: {},
            shortIntro: '原始简介',
            fullIntro: null,
            provinceCode: '510000',
            provinceName: '四川省',
            cityCode: '510100',
            cityName: '成都市',
            address: null,
            location: null,
            foundedAt: null,
            teamSizeRange: null,
            cooperationModes: [],
            contactVisible: true,
          },
          boardProfile: null,
          primaryContact: null,
          cases: [],
        };
      },
      async hydrateSnapshotMedia(_listing, snapshot) {
        return snapshot;
      },
    },
    mediaTruthService,
  );

  return {
    repositories,
    appService: new EnterpriseHubPublishedChangeAppService(
      supportService,
      {},
      locationService,
    ),
    liveWriteService: new EnterpriseHubPublishedChangeLiveWriteService(
      repositories.companyRepository,
      repositories.factoryRepository,
      repositories.supplierRepository,
      repositories.caseRepository,
      new EnterpriseHubContactWriteService(repositories.contactRepository),
      listingWriteSupportService,
      locationService,
      mediaTruthService,
    ),
  };
}

function createFileAsset(overrides = {}) {
  return {
    id: overrides.id ?? 'file-1',
    uploadSessionId: overrides.uploadSessionId ?? `session-${overrides.id ?? 'file-1'}`,
    businessType: overrides.businessType ?? 'enterprise_display',
    businessId: overrides.businessId ?? 'enterprise-1',
    fileKind: overrides.fileKind ?? 'enterprise_case_media',
    objectKey: overrides.objectKey ?? `enterprise/${overrides.id ?? 'file-1'}.png`,
    mimeType: overrides.mimeType ?? 'image/png',
    size: 1024,
    checksum: 'checksum',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: overrides.organizationId ?? 'org-1',
    createdAt: new Date('2026-04-10T08:00:00.000Z'),
  };
}

test('workbench case create rejects file assets outside enterprise display truth', async () => {
  const harness = createMediaTruthHarness({
    fileAssets: [
      createFileAsset({
        id: 'license-1',
        businessType: 'profile',
        businessId: 'org-1',
        fileKind: 'business_license',
        objectKey: 'profile/business_license/license-1.png',
      }),
    ],
  });

  await assert.rejects(
    () =>
      harness.writeService.createCase(
        'enterprise-1',
        {
          boardType: 'company',
          title: '非法案例',
          summary: '不应保存',
          caseMediaFileAssetIds: ['license-1'],
        },
        createContext('direct-case-invalid-media'),
      ),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_INVALID_MEDIA_OWNERSHIP',
  );
});

test('workbench case create syncs enterprise_media_asset_ref for live case truth', async () => {
  const harness = createMediaTruthHarness({
    fileAssets: [createFileAsset({ id: 'case-media-1' })],
  });

  const created = await harness.writeService.createCase(
    'enterprise-1',
    {
      boardType: 'company',
      title: '合法案例',
      summary: '应保存并写 ref',
      caseMediaFileAssetIds: ['case-media-1'],
    },
    createContext('direct-case-valid-media'),
  );

  assert.equal(created.caseStatus, 'draft');
  assert.equal(harness.repositories.mediaAssetRefRepository.items.length, 2);
  assert.deepEqual(
    harness.repositories.mediaAssetRefRepository.items
      .map((item) => item.mediaRole)
      .sort(),
    ['case_cover', 'case_media'],
  );
});

test('published-change current case create rejects invalid media ownership', async () => {
  const harness = createPublishedChangeHarness({
    fileAssets: [
      createFileAsset({
        id: 'license-1',
        businessType: 'profile',
        businessId: 'org-1',
        fileKind: 'business_license',
        objectKey: 'profile/business_license/license-1.png',
      }),
    ],
  });

  await assert.rejects(
    () =>
      harness.appService.createCurrentCase(
        'enterprise-1',
        {
          title: '走廊非法案例',
          summary: '不应进入 current change',
          caseMediaFileAssetIds: ['license-1'],
        },
        createContext('corridor-case-invalid-media'),
      ),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_INVALID_MEDIA_OWNERSHIP',
  );
});

test('published-change live apply syncs enterprise_media_asset_ref for approved case truth', async () => {
  const harness = createPublishedChangeHarness({
    fileAssets: [createFileAsset({ id: 'case-media-1' })],
  });

  await harness.liveWriteService.applyToLiveListing(
    harness.repositories.listingRepository.items[0],
    {
      basic: {
        name: '线上企业',
        logoFileAssetId: null,
        coverFileAssetId: null,
        logoUrl: null,
        albumImageFileAssetIds: [],
        albumImageUrlMap: {},
        shortIntro: '原始简介',
        fullIntro: null,
        provinceCode: '510000',
        provinceName: '四川省',
        cityCode: '510100',
        cityName: '成都市',
        address: null,
        location: {
          addressText: null,
          publicDisplayAddress: null,
          provinceCode: '510000',
          provinceName: '四川省',
          cityCode: '510100',
          cityName: '成都市',
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
      boardProfile: null,
      primaryContact: null,
      cases: [
        {
          caseId: 'case-1',
          boardType: 'company',
          title: '通过案例',
          exhibitionType: null,
          city: null,
          eventTime: null,
          summary: 'apply 后应写 ref',
          caseCoverFileAssetId: 'case-media-1',
          caseMediaFileAssetIds: ['case-media-1'],
          caseImageUrlMap: {},
          isFeatured: false,
          caseStatus: 'draft',
        },
      ],
    },
  );

  assert.equal(harness.repositories.caseRepository.items.length, 1);
  assert.equal(harness.repositories.caseRepository.items[0].caseStatus, 'approved');
  assert.equal(harness.repositories.mediaAssetRefRepository.items.length, 2);
});

test('media projection fail-closes profile business license images for enterprise display reads', async () => {
  const {
    EnterpriseHubMediaProjectionService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-media-projection.service.js');
  const {
    EnterpriseHubMediaTruthService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-media-truth.service.js');

  const fileAssetRepository = createRepository([
    createFileAsset({
      id: 'license-1',
      businessType: 'profile',
      businessId: 'org-1',
      fileKind: 'business_license',
      objectKey: 'profile/business_license/license-1.png',
    }),
  ]);
  const mediaTruthService = new EnterpriseHubMediaTruthService(
    fileAssetRepository,
    createRepository([], 'id'),
  );
  const service = new EnterpriseHubMediaProjectionService(
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

  const displayUrlMap = await service.buildDisplayUrlMap(['license-1']);
  assert.equal(service.readDisplayUrl('license-1', displayUrlMap), null);
});
