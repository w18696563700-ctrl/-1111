const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId, overrides = {}) {
  return {
    authorization: 'Bearer corridor-carrier',
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

function sortByOrder(items, order) {
  const entries = Object.entries(order ?? {});
  if (!entries.length) {
    return [...items];
  }
  return [...items].sort((left, right) => {
    for (const [field, direction] of entries) {
      const leftValue = left[field];
      const rightValue = right[field];
      const leftComparable = leftValue instanceof Date ? leftValue.getTime() : leftValue ?? '';
      const rightComparable = rightValue instanceof Date ? rightValue.getTime() : rightValue ?? '';
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
  });
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
          Object.entries(where).every(([field, expected]) => item[field] === expected),
        ) ?? null
      );
    },
    async findOne(options) {
      const where = options?.where ?? {};
      const matched = items.filter((item) =>
        Object.entries(where).every(([field, expected]) => item[field] === expected),
      );
      const ordered = sortByOrder(matched, options?.order);
      return ordered[0] ?? null;
    },
    async find(options) {
      const where = options?.where ?? {};
      const matched = items.filter((item) =>
        Object.entries(where).every(([field, expected]) => item[field] === expected),
      );
      const ordered = sortByOrder(matched, options?.order);
      const skip = options?.skip ?? 0;
      const take = options?.take ?? ordered.length;
      return ordered.slice(skip, skip + take).map((item) => ({ ...item }));
    },
    async findBy(where) {
      return items
        .filter((item) =>
          Object.entries(where).every(([field, expected]) =>
            Array.isArray(expected) ? expected.includes(item[field]) : item[field] === expected,
          ),
        )
        .map((item) => ({ ...item }));
    },
    async count() {
      return items.length;
    },
    async delete(where) {
      for (let index = items.length - 1; index >= 0; index -= 1) {
        const item = items[index];
        if (Object.entries(where).every(([field, expected]) => item[field] === expected)) {
          items.splice(index, 1);
        }
      }
    },
  };
}

function createHarness(overrides = {}) {
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
    EnterpriseHubPublishedChangeSnapshotService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change-snapshot.service.js');
  const {
    EnterpriseHubPublishedChangeSupportService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change-support.service.js');
  const {
    EnterpriseHubPublishedChangePresenter,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change.presenter.js');
  const {
    EnterpriseHubPublishedChangeLiveWriteService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change-live-write.service.js');
  const {
    EnterpriseHubPublishedChangeAppService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change-app.service.js');
  const {
    EnterpriseHubPublishedChangeAdminService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-published-change-admin.service.js');

  const listing = {
    id: 'enterprise-1',
    organizationId: 'org-1',
    primaryBoardType: 'company',
    secondaryCapabilities: [],
    name: '线上企业',
    shortIntro: '原始简介',
    fullIntro: '原始完整简介',
    logoFileAssetId: 'logo-live',
    coverFileAssetId: 'cover-live',
    provinceCode: '510000',
    provinceName: '四川省',
    cityCode: '510100',
    cityName: '成都市',
    address: '天府大道 1 号',
    foundedAt: '2021-01-01',
    teamSizeRange: '20-99',
    cooperationModes: ['design'],
    legalNameSnapshot: null,
    unifiedSocialCreditCodeSnapshot: null,
    verificationStatusSnapshot: 'verified',
    enterpriseStatus: overrides.enterpriseStatus ?? 'published',
    displayStatus: overrides.displayStatus ?? 'visible',
    contactVisible: true,
    publishedAt: new Date('2026-04-10T08:00:00.000Z'),
    createdAt: new Date('2026-04-10T08:00:00.000Z'),
    updatedAt: new Date('2026-04-10T08:00:00.000Z'),
  };

  const repositories = {
    listingRepository: createRepository([overrides.listing ?? listing]),
    companyRepository: createRepository(
      overrides.company
        ? [overrides.company]
        : [
            {
              enterpriseId: 'enterprise-1',
              exhibitionTypes: ['expo'],
              serviceItems: ['design'],
              serviceCities: ['成都'],
              teamSize: 32,
              maxProjectScale: '100w',
              averageDeliveryCycleDays: 12,
              knownClients: ['A'],
              qualificationDesc: 'ISO',
              projectManagementCapability: 'pm',
              onsiteExecutionCapability: 'onsite',
            },
          ],
      'enterpriseId',
    ),
    factoryRepository: createRepository([], 'enterpriseId'),
    supplierRepository: createRepository([], 'enterpriseId'),
    caseRepository: createRepository(
      overrides.cases ?? [
        {
          id: 'live-case-1',
          enterpriseId: 'enterprise-1',
          boardType: 'company',
          title: '线上案例 1',
          exhibitionType: 'expo',
          city: '上海',
          eventTime: '2026-03-01',
          summary: '线上案例摘要',
          caseCoverFileAssetId: 'case-cover-live',
          caseMediaFileAssetIds: ['case-cover-live'],
          isFeatured: false,
          sortOrder: null,
          caseStatus: 'approved',
          reviewNote: null,
          createdAt: new Date('2026-04-10T08:00:00.000Z'),
          updatedAt: new Date('2026-04-10T08:00:00.000Z'),
        },
      ],
    ),
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
    changeRequestRepository: createRepository(overrides.changeRequests ?? []),
    serviceAreaRepository: createRepository(overrides.serviceAreas ?? []),
  };

  const verificationService = {
    async verifyCurrentSessionContext(context) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: context.actorId || 'actor-1',
          userId: context.userId || 'user-1',
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
    async requireReviewer(currentSession) {
      return {
        actorRole: overrides.reviewerRole ?? 'platform_reviewer',
        currentSession,
      };
    },
  };

  const listingWriteSupportService = new EnterpriseHubListingWriteSupportService(
    repositories.listingRepository,
    repositories.serviceAreaRepository,
    verificationService,
    eligibilityService,
  );
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
  const contactWriteService = new EnterpriseHubContactWriteService(
    repositories.contactRepository,
  );
  const mediaTruthService = {
    async validateListingBasicMedia() {},
    async syncListingBasicRefs() {},
    async validateFactoryShowcaseMedia() {},
    async syncFactoryShowcaseRefs() {},
    async validateCaseMedia() {},
    async syncCaseRefs() {},
    async clearCaseRefs() {},
  };
  const snapshotService = new EnterpriseHubPublishedChangeSnapshotService(
    repositories.companyRepository,
    repositories.factoryRepository,
    repositories.supplierRepository,
    repositories.caseRepository,
    repositories.contactRepository,
    locationService,
    {
      async buildDisplayUrlMap() {
        return new Map();
      },
      readDisplayUrl() {
        return null;
      },
    },
  );
  const supportService = new EnterpriseHubPublishedChangeSupportService(
    repositories.listingRepository,
    repositories.changeRequestRepository,
    listingWriteSupportService,
    snapshotService,
    mediaTruthService,
  );
  const presenter = new EnterpriseHubPublishedChangePresenter();
  const liveWriteService = new EnterpriseHubPublishedChangeLiveWriteService(
    repositories.companyRepository,
    repositories.factoryRepository,
    repositories.supplierRepository,
    repositories.caseRepository,
    contactWriteService,
    listingWriteSupportService,
    locationService,
    mediaTruthService,
  );

  return {
    repositories,
    appService: new EnterpriseHubPublishedChangeAppService(
      supportService,
      presenter,
      locationService,
    ),
    adminService: new EnterpriseHubPublishedChangeAdminService(
      repositories.changeRequestRepository,
      repositories.listingRepository,
      verificationService,
      eligibilityService,
      presenter,
      supportService,
      liveWriteService,
    ),
  };
}

test('same listing reuses one active change request and save draft does not mutate live listing or live cases', async () => {
  const harness = createHarness();

  await harness.appService.updateCurrentBasic(
    'enterprise-1',
    {
      name: '草稿企业名',
      shortIntro: '草稿简介',
      contactName: '李四',
      contactMobile: '13800000000',
    },
    createContext('corridor-save-basic'),
  );
  const draftId = harness.repositories.changeRequestRepository.items[0].id;

  const caseResult = await harness.appService.createCurrentCase(
    'enterprise-1',
    {
      title: '草稿新增案例',
      summary: '草稿新增案例摘要',
      caseMediaFileAssetIds: ['draft-case-cover'],
      isFeatured: true,
    },
    createContext('corridor-create-case'),
  );

  assert.equal(harness.repositories.changeRequestRepository.items.length, 1);
  assert.equal(harness.repositories.changeRequestRepository.items[0].id, draftId);
  assert.equal(harness.repositories.listingRepository.items[0].name, '线上企业');
  assert.equal(harness.repositories.caseRepository.items.length, 1);
  assert.equal(harness.repositories.caseRepository.items[0].title, '线上案例 1');

  const current = await harness.appService.getCurrentChange(
    'enterprise-1',
    createContext('corridor-current'),
  );

  assert.equal(current.currentChangeRequest.changeRequestId, draftId);
  assert.equal(current.basic.name, '草稿企业名');
  assert.equal(current.primaryContact.contactName, '李四');
  assert.equal(current.liveSnapshot.enterpriseStatus, 'published');
  assert.equal(current.cases.some((item) => item.caseId === caseResult.caseId), true);
});

test('status read does not create persisted draft carrier when no active change request exists', async () => {
  const harness = createHarness();

  const status = await harness.appService.getCurrentChangeStatus(
    'enterprise-1',
    createContext('corridor-status-no-draft'),
  );

  assert.equal(status.changeStatus, 'draft');
  assert.equal(status.changeRequestId, 'enterprise-1:draft');
  assert.equal(harness.repositories.changeRequestRepository.items.length, 0);
});

test('same listing cannot create parallel active change requests', async () => {
  const harness = createHarness();

  await harness.appService.updateCurrentBasic(
    'enterprise-1',
    {
      name: '第一次草稿企业名',
      shortIntro: '第一次草稿简介',
      contactName: '李四',
      contactMobile: '13800000000',
    },
    createContext('corridor-single-active-save'),
  );
  const changeRequestId = harness.repositories.changeRequestRepository.items[0].id;

  await harness.appService.submitCurrentChange(
    'enterprise-1',
    { confirm: true },
    createContext('corridor-single-active-submit'),
  );

  await assert.rejects(
    () =>
      harness.appService.updateCurrentBasic(
        'enterprise-1',
        {
          name: '第二次草稿企业名',
          shortIntro: '第二次草稿简介',
        },
        createContext('corridor-single-active-illegal-second-draft'),
      ),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
  );
  assert.equal(harness.repositories.changeRequestRepository.items.length, 1);
  assert.equal(harness.repositories.changeRequestRepository.items[0].id, changeRequestId);
  assert.equal(harness.repositories.changeRequestRepository.items[0].changeStatus, 'submitted');
});

test('submit under_review approved applied keeps live listing unchanged until apply and then updates live truth', async () => {
  const harness = createHarness();

  await harness.appService.updateCurrentBasic(
    'enterprise-1',
    {
      name: '申请变更后的企业名',
      shortIntro: '申请变更后的简介',
      contactName: '李四',
      contactMobile: '13800000000',
    },
    createContext('corridor-save-before-submit'),
  );
  await harness.appService.updateCurrentCase(
    'enterprise-1',
    'live-case-1',
    {
      title: '变更后的案例标题',
      summary: '变更后的案例摘要',
    },
    createContext('corridor-case-before-submit'),
  );
  const changeRequestId = harness.repositories.changeRequestRepository.items[0].id;

  await harness.appService.submitCurrentChange(
    'enterprise-1',
    { confirm: true },
    createContext('corridor-submit'),
  );

  let status = await harness.appService.getCurrentChangeStatus(
    'enterprise-1',
    createContext('corridor-status-submitted'),
  );
  assert.equal(status.changeRequestId, changeRequestId);
  assert.equal(status.changeStatus, 'submitted');

  const queue = await harness.adminService.listChangeRequests(
    { page: 1, pageSize: 20 },
    createContext('corridor-admin-queue', {
      actorId: 'reviewer-1',
      userId: 'reviewer-1',
    }),
  );
  assert.equal(queue.items.length, 1);
  assert.equal(queue.items[0].changeRequestId, changeRequestId);
  assert.equal(queue.items[0].changeStatus, 'submitted');

  const detail = await harness.adminService.getChangeRequestDetail(
    changeRequestId,
    createContext('corridor-admin-detail', {
      actorId: 'reviewer-1',
      userId: 'reviewer-1',
    }),
  );
  assert.equal(detail.basic.name, '申请变更后的企业名');
  assert.equal(detail.changeRequest.changeStatus, 'under_review');
  assert.equal(detail.cases[0].title, '变更后的案例标题');

  status = await harness.appService.getCurrentChangeStatus(
    'enterprise-1',
    createContext('corridor-status-under-review'),
  );
  assert.equal(status.changeStatus, 'under_review');

  await harness.adminService.reviewChangeRequest(
    changeRequestId,
    { action: 'approved', reviewNote: '内容通过' },
    createContext('corridor-admin-approved', {
      actorId: 'reviewer-1',
      userId: 'reviewer-1',
    }),
  );
  assert.equal(harness.repositories.listingRepository.items[0].name, '线上企业');
  assert.equal(harness.repositories.caseRepository.items[0].title, '线上案例 1');

  status = await harness.appService.getCurrentChangeStatus(
    'enterprise-1',
    createContext('corridor-status-approved'),
  );
  assert.equal(status.changeStatus, 'approved');

  const applyResponse = await harness.adminService.applyChangeRequest(
    changeRequestId,
    createContext('corridor-admin-apply', {
      actorId: 'reviewer-2',
      userId: 'reviewer-2',
    }),
  );

  assert.equal(applyResponse.changeStatus, 'applied');
  assert.equal(harness.repositories.listingRepository.items[0].name, '申请变更后的企业名');
  assert.equal(harness.repositories.caseRepository.items[0].title, '变更后的案例标题');
  assert.equal(harness.repositories.caseRepository.items[0].caseStatus, 'approved');
});

test('revision_required returns to the same changeRequestId and can continue editing', async () => {
  const harness = createHarness();

  await harness.appService.updateCurrentBasic(
    'enterprise-1',
    {
      name: '第一次草稿名',
      shortIntro: '第一次草稿简介',
      contactName: '李四',
      contactMobile: '13800000000',
    },
    createContext('corridor-revision-save-1'),
  );
  const changeRequestId = harness.repositories.changeRequestRepository.items[0].id;

  await harness.appService.submitCurrentChange(
    'enterprise-1',
    { confirm: true },
    createContext('corridor-revision-submit-1'),
  );
  await harness.adminService.reviewChangeRequest(
    changeRequestId,
    { action: 'revision_required', reviewNote: '请补充案例说明' },
    createContext('corridor-revision-review', {
      actorId: 'reviewer-1',
      userId: 'reviewer-1',
    }),
  );

  const current = await harness.appService.getCurrentChange(
    'enterprise-1',
    createContext('corridor-revision-current'),
  );
  assert.equal(current.currentChangeRequest.changeRequestId, changeRequestId);
  assert.equal(current.currentChangeRequest.changeStatus, 'revision_required');
  assert.equal(current.changeReadiness.draftEditable, true);

  await harness.appService.updateCurrentBasic(
    'enterprise-1',
    {
      name: '二次修改后的企业名',
      shortIntro: '二次修改后的简介',
    },
    createContext('corridor-revision-save-2'),
  );

  assert.equal(harness.repositories.changeRequestRepository.items.length, 1);
  assert.equal(harness.repositories.changeRequestRepository.items[0].id, changeRequestId);
  assert.equal(
    harness.repositories.changeRequestRepository.items[0].draftBasic.name,
    '二次修改后的企业名',
  );
});

test('invalid transitions return ENTERPRISE_HUB_INVALID_STATE_TRANSITION', async () => {
  const harness = createHarness();

  await harness.appService.updateCurrentBasic(
    'enterprise-1',
    {
      name: '待审核企业名',
      shortIntro: '待审核简介',
      contactName: '李四',
      contactMobile: '13800000000',
    },
    createContext('corridor-invalid-save'),
  );
  const changeRequestId = harness.repositories.changeRequestRepository.items[0].id;
  await harness.appService.submitCurrentChange(
    'enterprise-1',
    { confirm: true },
    createContext('corridor-invalid-submit'),
  );
  await harness.adminService.reviewChangeRequest(
    changeRequestId,
    { action: 'approved', reviewNote: '通过' },
    createContext('corridor-invalid-approved', {
      actorId: 'reviewer-1',
      userId: 'reviewer-1',
    }),
  );

  await assert.rejects(
    () =>
      harness.adminService.reviewChangeRequest(
        changeRequestId,
        { action: 'rejected', reviewNote: '重复审核' },
        createContext('corridor-invalid-review-2', {
          actorId: 'reviewer-2',
          userId: 'reviewer-2',
        }),
      ),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
  );
});

test('published change corridor is unavailable when live listing is not published and visible', async () => {
  const harness = createHarness({
    enterpriseStatus: 'unpublished',
    displayStatus: 'hidden',
  });

  await assert.rejects(
    () =>
      harness.appService.getCurrentChange(
        'enterprise-1',
        createContext('corridor-unavailable'),
      ),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE',
  );
});
