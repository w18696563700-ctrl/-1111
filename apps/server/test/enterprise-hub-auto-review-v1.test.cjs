const test = require('node:test');
const assert = require('node:assert/strict');

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
  EnterpriseHubLocationService,
} = require('../dist/modules/enterprise_hub/enterprise-hub-location.service.js');
const {
  EnterpriseHubApplicationReviewAdminWriteService,
} = require('../dist/modules/enterprise_hub/enterprise-hub-application-review-admin.write.service.js');

function createRepository(initialItems = [], key = 'id') {
  const items = initialItems.map((item) => ({ ...item }));
  return {
    items,
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
    async findOne(options) {
      const where = options?.where ?? {};
      const matched = items.filter((item) =>
        Object.entries(where).every(([field, expected]) => item[field] === expected),
      );
      if (matched.length === 0) {
        return null;
      }
      return matched[0];
    },
    async findOneBy(where) {
      return (
        items.find((item) =>
          Object.entries(where).every(([field, expected]) => item[field] === expected),
        ) ?? null
      );
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
    async findBy(where) {
      return items.filter((item) =>
        Object.entries(where).every(([field, expected]) => item[field] === expected),
      );
    },
  };
}

function createContext(requestId) {
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
  };
}

function createVerificationService() {
  return {
    async verifyCurrentSessionContext(context) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'reviewer-user',
          userId: 'reviewer-user',
          organizationId: 'org-1',
          requestId: context.requestId,
          traceId: context.traceId,
        },
      };
    },
  };
}

function createEligibilityService() {
  return {
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
    async requireReviewer(currentSession) {
      return {
        actorRole: 'platform_reviewer',
        currentSession,
      };
    },
  };
}

function createWriteHarness(overrides = {}) {
  const listingRepository = createRepository([
    {
      id: 'enterprise-1',
      organizationId: 'org-1',
      primaryBoardType: 'company',
      secondaryCapabilities: [],
      name: '测试企业',
      shortIntro: '一句话简介',
      provinceCode: '510000',
      provinceName: '四川省',
      cityCode: '510100',
      cityName: '成都市',
      enterpriseStatus: 'unpublished',
      verificationStatusSnapshot: 'verified',
      ...overrides.listing,
    },
  ]);
  const applicationRepository = createRepository([
    {
      id: 'application-1',
      enterpriseId: 'enterprise-1',
      applyBoardType: 'company',
      applicantName: '李四',
      applicantMobile: '13800000000',
      applicationStatus: 'draft',
      rejectionReason: null,
      reviewedAt: null,
      reviewerId: null,
      reviewNote: null,
      ...overrides.application,
    },
  ]);
  const caseRepository = createRepository(
    overrides.cases ?? [
      {
        id: 'case-1',
        enterpriseId: 'enterprise-1',
        boardType: 'company',
        title: '春季展案例',
        summary: '从方案到落地',
        caseCoverFileAssetId: 'media-1',
        caseMediaFileAssetIds: ['media-1'],
        caseStatus: 'draft',
      },
    ],
  );
  const contactRepository = createRepository([
    {
      id: 'contact-1',
      enterpriseId: 'enterprise-1',
      contactName: '李四',
      mobile: '13800000000',
      isPrimary: true,
      visibleToPublic: true,
    },
  ]);
  const companyRepository = createRepository([
    {
      enterpriseId: 'enterprise-1',
      exhibitionTypes: ['expo'],
      serviceItems: ['design'],
      serviceCities: ['成都'],
    },
  ], 'enterpriseId');
  const verificationService = createVerificationService();
  const eligibilityService = createEligibilityService();
  const serviceAreaRepository = createRepository([]);
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
  const writeService = new EnterpriseHubWriteService(
    listingRepository,
    companyRepository,
    createRepository([], 'enterpriseId'),
    createRepository([], 'enterpriseId'),
    caseRepository,
    contactRepository,
    applicationRepository,
    createRepository([
      {
        id: 'cert-snapshot-1',
        enterpriseId: 'enterprise-1',
        certStatus: 'approved',
      },
    ]),
    serviceAreaRepository,
    createRepository([], 'enterpriseId'),
    {
      async syncForListing() {
        return null;
      },
    },
    new EnterpriseHubContactWriteService(contactRepository),
    new EnterpriseHubListingWriteSupportService(
      listingRepository,
      serviceAreaRepository,
      verificationService,
      eligibilityService,
    ),
    locationService,
  );

  return {
    writeService,
    repositories: {
      applicationRepository,
      listingRepository,
      caseRepository,
    },
    verificationService,
    eligibilityService,
  };
}

test('submitApplication auto-approves objective-complete enterprise truth without auto-publish', async () => {
  const harness = createWriteHarness();

  const result = await harness.writeService.submitApplication(
    'application-1',
    { confirm: true },
    createContext('auto-review-approved'),
  );

  assert.deepEqual(result, { ok: true, traceId: 'trace-auto-review-approved' });
  assert.equal(harness.repositories.applicationRepository.items[0].applicationStatus, 'approved');
  assert.equal(harness.repositories.applicationRepository.items[0].reviewerId, 'system:auto-review');
  assert.equal(harness.repositories.applicationRepository.items[0].reviewNote, 'auto-review rule v1');
  assert.equal(harness.repositories.listingRepository.items[0].enterpriseStatus, 'unpublished');
});

test('submitApplication returns revision_required when no valid case media truth exists', async () => {
  const harness = createWriteHarness({
    cases: [
      {
        id: 'case-1',
        enterpriseId: 'enterprise-1',
        boardType: 'company',
        title: '空壳案例',
        summary: '只有标题摘要',
        caseCoverFileAssetId: '',
        caseMediaFileAssetIds: [],
        caseStatus: 'draft',
      },
    ],
  });

  await harness.writeService.submitApplication(
    'application-1',
    { confirm: true },
    createContext('auto-review-revision'),
  );

  assert.equal(
    harness.repositories.applicationRepository.items[0].applicationStatus,
    'revision_required',
  );
  assert.equal(harness.repositories.applicationRepository.items[0].rejectionReason, 'case_incomplete');
  assert.equal(harness.repositories.applicationRepository.items[0].reviewerId, 'system:auto-review');
});

test('submitApplication falls back to submitted when auto-review requires manual review', async () => {
  const harness = createWriteHarness({
    application: {
      applyBoardType: 'factory',
    },
  });

  await harness.writeService.submitApplication(
    'application-1',
    { confirm: true },
    createContext('auto-review-manual'),
  );

  assert.equal(harness.repositories.applicationRepository.items[0].applicationStatus, 'submitted');
  assert.equal(harness.repositories.applicationRepository.items[0].reviewedAt, null);
  assert.equal(harness.repositories.applicationRepository.items[0].reviewerId, null);
  assert.equal(harness.repositories.applicationRepository.items[0].reviewNote, null);
});

test('admin review can override system auto-approved application truth', async () => {
  const applicationRepository = createRepository([
    {
      id: 'application-1',
      enterpriseId: 'enterprise-1',
      applicationStatus: 'approved',
      reviewedAt: new Date('2026-04-17T13:00:00.000Z'),
      reviewerId: 'system:auto-review',
      reviewNote: 'auto-review rule v1',
      rejectionReason: null,
    },
  ]);
  const service = new EnterpriseHubApplicationReviewAdminWriteService(
    applicationRepository,
    createVerificationService(),
    createEligibilityService(),
  );

  await service.reviewApplication(
    'application-1',
    {
      action: 'rejected',
      reason: 'other',
      reviewNote: 'manual override after sample inspection',
    },
    createContext('manual-override'),
  );

  assert.equal(applicationRepository.items[0].applicationStatus, 'rejected');
  assert.equal(applicationRepository.items[0].reviewerId, 'reviewer-user');
  assert.equal(applicationRepository.items[0].reviewNote, 'manual override after sample inspection');
  assert.equal(applicationRepository.items[0].rejectionReason, 'other');
});
