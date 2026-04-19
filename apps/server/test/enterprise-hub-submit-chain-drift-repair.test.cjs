const test = require('node:test');
const assert = require('node:assert/strict');

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
      const order = options?.order ?? {};
      return [...matched].sort((left, right) => {
        for (const [field, direction] of Object.entries(order)) {
          const leftValue = left[field];
          const rightValue = right[field];
          const leftComparable =
            leftValue instanceof Date ? leftValue.getTime() : leftValue ?? '';
          const rightComparable =
            rightValue instanceof Date ? rightValue.getTime() : rightValue ?? '';
          if (leftComparable === rightComparable) {
            continue;
          }
          return direction === 'DESC'
            ? rightComparable > leftComparable
              ? 1
              : -1
            : leftComparable > rightComparable
              ? 1
              : -1;
        }
        return 0;
      })[0];
    },
    async findOneBy(where) {
      return (
        items.find((item) =>
          Object.entries(where).every(([field, expected]) => item[field] === expected),
        ) ?? null
      );
    },
    async saveAll(values) {
      for (const value of values) {
        await this.save(value);
      }
    },
    async delete(where) {
      for (let index = items.length - 1; index >= 0; index -= 1) {
        const item = items[index];
        if (
          Object.entries(where).every(([field, expected]) => item[field] === expected)
        ) {
          items.splice(index, 1);
        }
      }
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

test('createApplication reuses the current editable draft instead of creating another one for the same listing', async () => {
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

  const listingRepository = createRepository([
    {
      id: 'enterprise-1',
      organizationId: 'org-1',
      primaryBoardType: 'factory',
    },
  ]);
  const applicationRepository = createRepository([
    {
      id: 'draft-1',
      enterpriseId: 'enterprise-1',
      applyBoardType: 'factory',
      applicantName: '旧联系人',
      applicantMobile: '13000000000',
      applicationStatus: 'draft',
      createdAt: new Date('2026-04-10T08:00:00.000Z'),
      updatedAt: new Date('2026-04-10T09:00:00.000Z'),
    },
  ]);
  const serviceAreaRepository = createRepository([]);

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

  const service = new EnterpriseHubWriteService(
    listingRepository,
    createRepository([], 'enterpriseId'),
    createRepository([], 'enterpriseId'),
    createRepository([], 'enterpriseId'),
    createRepository([]),
    createRepository([]),
    applicationRepository,
    createRepository([]),
    serviceAreaRepository,
    createRepository([]),
    {
      async syncForListing() {
        return null;
      },
    },
    new EnterpriseHubContactWriteService(createRepository([])),
    new EnterpriseHubListingWriteSupportService(
      listingRepository,
      serviceAreaRepository,
      verificationService,
      eligibilityService,
    ),
    locationService,
  );

  const result = await service.createApplication(
    {
      applyBoardType: 'factory',
      applicantName: '新联系人',
      applicantMobile: '13800000000',
    },
    createContext('reuse-draft'),
  );

  assert.equal(result.applicationId, 'draft-1');
  assert.equal(applicationRepository.items.length, 1);
  assert.equal(applicationRepository.items[0].applicantName, '新联系人');
  assert.equal(applicationRepository.items[0].applicantMobile, '13800000000');
});

test('ensureShell creates only listing and review-summary shells without creating application or contact truth', async () => {
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

  const listingRepository = createRepository([]);
  const applicationRepository = createRepository([]);
  const contactRepository = createRepository([]);
  const reviewSummaryRepository = createRepository([], 'enterpriseId');
  const serviceAreaRepository = createRepository([]);
  const syncCalls = [];

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

  const service = new EnterpriseHubWriteService(
    listingRepository,
    createRepository([], 'enterpriseId'),
    createRepository([], 'enterpriseId'),
    createRepository([], 'enterpriseId'),
    createRepository([]),
    contactRepository,
    applicationRepository,
    createRepository([]),
    serviceAreaRepository,
    reviewSummaryRepository,
    {
      async syncForListing(listing) {
        syncCalls.push(listing.id);
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

  const result = await service.ensureShell(
    { boardType: 'factory' },
    createContext('ensure-shell-created'),
  );

  assert.equal(result.boardType, 'factory');
  assert.equal(result.shellStatus, 'created');
  assert.equal(listingRepository.items.length, 1);
  assert.equal(listingRepository.items[0].primaryBoardType, 'factory');
  assert.equal(reviewSummaryRepository.items.length, 1);
  assert.equal(reviewSummaryRepository.items[0].enterpriseId, result.enterpriseId);
  assert.equal(applicationRepository.items.length, 0);
  assert.equal(contactRepository.items.length, 0);
  assert.deepEqual(syncCalls, [result.enterpriseId]);
});

test('syncForListing clears stale certification snapshot when organization certification truth is absent', async () => {
  const { EnterpriseHubCertificationSyncService } = require('../dist/modules/enterprise_hub/enterprise-hub-certification-sync.service.js');

  const listingRepository = createRepository([
    {
      id: 'enterprise-1',
      organizationId: 'org-1',
      legalNameSnapshot: '旧快照',
      unifiedSocialCreditCodeSnapshot: 'OLD-USCC',
      verificationStatusSnapshot: 'verified',
    },
  ]);
  const certificationRepository = createRepository([]);
  const enterpriseCertificationRepository = createRepository([
    {
      id: 'snapshot-1',
      enterpriseId: 'enterprise-1',
      certificationType: 'business_license',
      certStatus: 'approved',
    },
  ]);

  const service = new EnterpriseHubCertificationSyncService(
    certificationRepository,
    enterpriseCertificationRepository,
    listingRepository,
  );

  const result = await service.syncForListing(listingRepository.items[0]);

  assert.equal(result, null);
  assert.equal(listingRepository.items[0].verificationStatusSnapshot, null);
  assert.equal(listingRepository.items[0].legalNameSnapshot, null);
  assert.equal(listingRepository.items[0].unifiedSocialCreditCodeSnapshot, null);
  assert.equal(enterpriseCertificationRepository.items.length, 0);
});

test('syncForListing still materializes approved snapshot when organization certification truth exists', async () => {
  const { EnterpriseHubCertificationSyncService } = require('../dist/modules/enterprise_hub/enterprise-hub-certification-sync.service.js');

  const listingRepository = createRepository([
    {
      id: 'enterprise-1',
      organizationId: 'org-1',
      legalNameSnapshot: null,
      unifiedSocialCreditCodeSnapshot: null,
      verificationStatusSnapshot: null,
    },
  ]);
  const certificationRepository = createRepository([
    {
      id: 'cert-1',
      organizationId: 'org-1',
      certificationStatus: 'approved',
      legalName: '测试企业',
      uscc: '91310000TEST00001',
      licenseFileId: 'license-1',
      reviewedBy: 'reviewer-1',
      rejectReason: null,
      reviewedAt: new Date('2026-04-10T09:00:00.000Z'),
      updatedAt: new Date('2026-04-10T09:00:00.000Z'),
      createdAt: new Date('2026-04-10T08:00:00.000Z'),
    },
  ]);
  const enterpriseCertificationRepository = createRepository([]);

  const service = new EnterpriseHubCertificationSyncService(
    certificationRepository,
    enterpriseCertificationRepository,
    listingRepository,
  );

  const snapshot = await service.syncForListing(listingRepository.items[0]);

  assert.equal(listingRepository.items[0].verificationStatusSnapshot, 'verified');
  assert.equal(listingRepository.items[0].legalNameSnapshot, '测试企业');
  assert.equal(listingRepository.items[0].unifiedSocialCreditCodeSnapshot, '91310000TEST00001');
  assert.equal(snapshot.certStatus, 'approved');
  assert.equal(enterpriseCertificationRepository.items.length, 1);
});
