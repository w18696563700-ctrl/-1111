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
  };
}

function createHarness(overrides = {}) {
  const {
    EnterpriseHubCaseContinuationSupportService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-case-continuation-support.service.js');
  const {
    EnterpriseHubCaseContinuationQueryService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-case-continuation.query.service.js');
  const {
    EnterpriseHubCaseContinuationWriteService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-case-continuation.write.service.js');
  const {
    EnterpriseHubListingWriteSupportService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-listing-write-support.service.js');

  const listing = {
    id: 'enterprise-1',
    organizationId: overrides.listingOrganizationId ?? 'org-1',
    primaryBoardType: 'company',
    secondaryCapabilities: [],
    name: '测试企业',
    shortIntro: '展台搭建与执行',
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
        ? new Date('2026-04-11T09:00:00.000Z')
        : null,
    createdAt: new Date('2026-04-10T08:00:00.000Z'),
    updatedAt: new Date('2026-04-10T08:00:00.000Z'),
  };

  const application = {
    id: 'application-1',
    enterpriseId: 'enterprise-1',
    applicationStatus: overrides.applicationStatus ?? 'draft',
    createdAt: new Date('2026-04-10T08:00:00.000Z'),
    updatedAt: new Date('2026-04-10T08:00:00.000Z'),
  };

  const caseEntity = {
    id: 'case-1',
    enterpriseId: 'enterprise-1',
    boardType: 'company',
    title: '旧案例标题',
    exhibitionType: 'trade-show',
    city: '上海',
    eventTime: '2026-03-20',
    summary: '旧摘要',
    caseCoverFileAssetId: 'cover-old',
    caseMediaFileAssetIds: ['cover-old', 'media-old-2'],
    isFeatured: false,
    caseStatus: 'draft',
    reviewNote: null,
    createdAt: new Date('2026-04-10T08:00:00.000Z'),
    updatedAt: new Date('2026-04-10T08:00:00.000Z'),
  };

  const repositories = {
    listingRepository: createRepository([overrides.listing ?? listing]),
    caseRepository: createRepository([overrides.caseEntity ?? caseEntity]),
    applicationRepository: createRepository(
      overrides.applications ?? [application],
    ),
    serviceAreaRepository: createRepository(overrides.serviceAreas ?? []),
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
        organization: { id: overrides.scopeOrganizationId ?? 'org-1' },
        membership: { roleKey: 'supplier_admin', memberStatus: 'active' },
        certification: { certificationStatus: 'approved' },
        roleKeys: ['supplier_admin'],
      };
    },
  };

  const listingWriteSupportService = new EnterpriseHubListingWriteSupportService(
    repositories.listingRepository,
    repositories.serviceAreaRepository,
    verificationService,
    eligibilityService,
  );
  const supportService = new EnterpriseHubCaseContinuationSupportService(
    repositories.caseRepository,
    repositories.applicationRepository,
    listingWriteSupportService,
  );
  const mediaTruthService = {
    async validateCaseMedia() {},
    async syncCaseRefs() {},
  };
  const mediaProjectionService = {
    async buildDisplayUrlMap() {
      return new Map();
    },
    readDisplayUrl() {
      return null;
    },
  };

  return {
    repositories,
    queryService: new EnterpriseHubCaseContinuationQueryService(
      supportService,
      mediaProjectionService,
    ),
    writeService: new EnterpriseHubCaseContinuationWriteService(
      repositories.caseRepository,
      supportService,
      mediaTruthService,
    ),
  };
}

test('enterprise hub case continuation GET returns the full edit carrier under current organization scope', async () => {
  const harness = createHarness();

  const result = await harness.queryService.getCaseDetail(
    'case-1',
    createContext('case-detail'),
  );

  assert.deepEqual(result, {
    caseId: 'case-1',
    enterpriseId: 'enterprise-1',
    boardType: 'company',
    title: '旧案例标题',
    exhibitionType: 'trade-show',
    city: '上海',
    eventTime: '2026-03-20',
    summary: '旧摘要',
    caseCoverFileAssetId: 'cover-old',
    caseMediaFileAssetIds: ['cover-old', 'media-old-2'],
    caseImageUrlMap: {},
    isFeatured: false,
    caseStatus: 'draft',
  });
});

test('enterprise hub case continuation PUT updates listing-owned case truth and reads back the same carrier', async () => {
  const harness = createHarness();

  const updateResult = await harness.writeService.updateCase(
    'case-1',
    {
      title: '更新后的案例标题',
      exhibitionType: 'conference',
      city: '广州',
      eventTime: '2026-04-01',
      summary: '更新后的摘要',
      caseCoverFileAssetId: null,
      caseMediaFileAssetIds: ['media-new-1', 'media-new-2'],
      isFeatured: true,
    },
    createContext('case-update'),
  );

  assert.deepEqual(updateResult, {
    caseId: 'case-1',
    caseStatus: 'draft',
  });
  assert.equal(harness.repositories.caseRepository.items[0].title, '更新后的案例标题');
  assert.equal(harness.repositories.caseRepository.items[0].exhibitionType, 'conference');
  assert.equal(harness.repositories.caseRepository.items[0].city, '广州');
  assert.equal(harness.repositories.caseRepository.items[0].eventTime, '2026-04-01');
  assert.equal(harness.repositories.caseRepository.items[0].summary, '更新后的摘要');
  assert.equal(harness.repositories.caseRepository.items[0].caseCoverFileAssetId, 'media-new-1');
  assert.deepEqual(harness.repositories.caseRepository.items[0].caseMediaFileAssetIds, [
    'media-new-1',
    'media-new-2',
  ]);
  assert.equal(harness.repositories.caseRepository.items[0].isFeatured, true);

  const detail = await harness.queryService.getCaseDetail(
    'case-1',
    createContext('case-update-readback'),
  );

  assert.equal(detail.title, '更新后的案例标题');
  assert.equal(detail.summary, '更新后的摘要');
  assert.equal(detail.caseCoverFileAssetId, 'media-new-1');
  assert.deepEqual(detail.caseMediaFileAssetIds, ['media-new-1', 'media-new-2']);
  assert.equal(detail.isFeatured, true);
});

test('enterprise hub case continuation PUT rejects boardType migration in direct update payload', async () => {
  const harness = createHarness();

  await assert.rejects(
    () =>
      harness.writeService.updateCase(
        'case-1',
        {
          boardType: 'factory',
          title: '更新后的案例标题',
          summary: '更新后的摘要',
        },
        createContext('case-update-boardtype'),
      ),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_INVALID_BOARD_TYPE',
  );
  assert.equal(harness.repositories.caseRepository.items[0].boardType, 'company');
});

test('enterprise hub case continuation rejects access outside current organization scope', async () => {
  const harness = createHarness({
    listingOrganizationId: 'org-2',
    scopeOrganizationId: 'org-1',
  });

  await assert.rejects(
    () =>
      harness.queryService.getCaseDetail(
        'case-1',
        createContext('case-detail-forbidden'),
      ),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_PERMISSION_DENIED',
  );
});

test('enterprise hub case continuation returns ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED for published-governed case direct updates', async () => {
  const harness = createHarness({
    enterpriseStatus: 'published',
    applicationStatus: 'approved',
  });

  await assert.rejects(
    () =>
      harness.writeService.updateCase(
        'case-1',
        {
          title: '发布后试图直改',
          summary: '这条更新必须进入 corridor',
        },
        createContext('case-update-published'),
      ),
    (error) =>
      error?.response?.code === 'ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED',
  );
});
