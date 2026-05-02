const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId, authorization = '') {
  return {
    authorization,
    actorId: '',
    userId: '',
    organizationId: '',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

function createProject(id, overrides = {}) {
  return {
    id,
    projectNo: `PROJ-${id}`,
    organizationId: 'buyer-org',
    creatorUserId: 'user-1',
    creatorActorId: 'actor-1',
    title: `${id}-title`,
    exhibitionName: `${id}-exhibition`,
    brandName: `${id}-brand`,
    buildingType: 'exhibition',
    budgetAmount: '80000.00',
    areaSqm: '36.00',
    buildingTypeRemark: null,
    provinceCode: '650000',
    provinceName: '新疆维吾尔自治区',
    cityCode: '650100',
    cityName: '乌鲁木齐市',
    districtCode: null,
    districtName: null,
    detailAddress: '测试地址',
    scopeSummary: '测试项目',
    plannedStartAt: '2099-04-01',
    plannedEndAt: '2099-04-30',
    scheduleDetail: null,
    description: null,
    state: 'published',
    summary: {
      heading: `${id}-heading`,
      stateLabel: '已发布',
    },
    publishedAt: new Date('2026-04-10T08:00:00.000Z'),
    createdAt: new Date('2026-04-10T07:00:00.000Z'),
    updatedAt: new Date('2026-04-10T09:00:00.000Z'),
    ...overrides,
  };
}

function applyFindWhere(projects, where) {
  return projects.filter((project) => {
    if (where?.provinceCode && project.provinceCode !== where.provinceCode) {
      return false;
    }
    if (where?.cityCode && project.cityCode !== where.cityCode) {
      return false;
    }
    if (where?.publishedAt && project.publishedAt == null) {
      return false;
    }
    return true;
  });
}

function createProjectNameAccessProjectionService() {
  const toProjection = (project) => ({
    displayTitle: project.exhibitionName ?? project.title,
    title: project.title,
    exhibitionName: project.exhibitionName ?? null,
    brandName: project.brandName ?? null,
    nameAccess: {
      status: 'visible',
      canRequest: false,
      requestId: null,
    },
  });
  return {
    async buildPublicProjectionMap({ projects }) {
      return new Map(projects.map((project) => [project.id, toProjection(project)]));
    },
    async buildSingleProjectProjection({ project }) {
      return toProjection(project);
    },
  };
}

function createService(projects, options = {}) {
  const { ProjectQueryService } = require('../dist/modules/project/project-query.service.js');
  const { ProjectPresenter } = require('../dist/modules/project/project.presenter.js');
  const repository = {
    async find(options) {
      return applyFindWhere(projects, options?.where);
    },
    async findOne(options) {
      return projects.find((project) => {
        const where = options?.where ?? {};
        if (where.id && project.id !== where.id) {
          return false;
        }
        if (where.publishedAt && project.publishedAt == null) {
          return false;
        }
        return true;
      }) ?? null;
    },
    async findOneBy(where) {
      return (
        projects.find((project) => {
          if (where?.id && project.id !== where.id) {
            return false;
          }
          if (where?.organizationId && project.organizationId !== where.organizationId) {
            return false;
          }
          return true;
        }) ?? null
      );
    },
    async query() {
      return [];
    },
  };

  const verificationService =
    options.verificationService ??
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'failed',
          reason: 'missing_current_session_carrier',
          requestId: context.requestId,
          traceId: context.traceId,
        };
      },
    };
  const eligibilityService =
    options.eligibilityService ??
    {
      async getCurrentOrganizationScope() {
        return null;
      },
    };

  return new ProjectQueryService(
    repository,
    verificationService,
    eligibilityService,
    createProjectNameAccessProjectionService(),
    new ProjectPresenter(),
  );
}

test('project showcase list applies real city and bucket filters and trims expired items', async () => {
  const service = createService([
    createProject('match'),
    createProject('other-city', { cityCode: '650200', cityName: '克拉玛依市' }),
    createProject('other-area', { areaSqm: '54.00' }),
    createProject('other-budget', { budgetAmount: '120000.00' }),
    createProject('expired-match', { plannedEndAt: '2000-01-01' }),
  ]);

  const result = await service.listProjects(createContext('project-list-filter'), {
    provinceCode: '650000',
    cityCode: '650100',
    areaBucket: '36_sqm',
    budgetBucket: '8_10w',
  });

  assert.deepEqual(
    result.items.map((item) => item.projectId),
    ['match'],
  );
  assert.equal(result.items[0].publishedAt, '2026-04-10T08:00:00.000Z');
  assert.deepEqual(result.pagination, {
    page: 1,
    pageSize: 20,
    total: 1,
    hasMore: false,
  });
});

test('project showcase list excludes non-published states even when publishedAt remains', async () => {
  const service = createService([
    createProject('visible-published', {
      publishedAt: new Date('2026-04-10T08:00:00.000Z'),
    }),
    createProject('converted-hidden', {
      state: 'converted_to_order',
      publishedAt: new Date('2026-04-10T11:00:00.000Z'),
    }),
    createProject('awarded-hidden', {
      state: 'awarded',
      publishedAt: new Date('2026-04-10T10:00:00.000Z'),
    }),
    createProject('submitted-hidden', {
      state: 'submitted',
      publishedAt: new Date('2026-04-10T09:00:00.000Z'),
    }),
  ]);

  const result = await service.listProjects(createContext('project-list-state-trim'));

  assert.deepEqual(
    result.items.map((item) => item.projectId),
    ['visible-published'],
  );
  assert.equal(result.pagination.total, 1);
});

test('project showcase list supports custom_sqm and 20w_plus boundary buckets', async () => {
  const service = createService([
    createProject('custom-area-match', {
      areaSqm: '35.50',
      budgetAmount: '200000.00',
    }),
    createProject('standard-area', {
      areaSqm: '36.00',
      budgetAmount: '200000.00',
    }),
    createProject('budget-too-low', {
      areaSqm: '35.50',
      budgetAmount: '199999.99',
    }),
    createProject('over-108', {
      areaSqm: '120.00',
      budgetAmount: '260000.00',
    }),
  ]);

  const result = await service.listProjects(createContext('project-list-custom-buckets'), {
    areaBucket: 'custom_sqm',
    budgetBucket: '20w_plus',
  });

  assert.deepEqual(
    result.items.map((item) => item.projectId),
    ['custom-area-match'],
  );
});

test('expired public project detail returns controlled unavailable', async () => {
  const service = createService([
    createProject('expired-detail', { plannedEndAt: '2000-01-01' }),
  ]);

  await assert.rejects(
    () => service.getProjectById('expired-detail', createContext('project-detail-expired')),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_RESOURCE_UNAVAILABLE');
      return true;
    },
  );
});

test('owner detail remains readable after converted_to_order project leaves public showcase visibility', async () => {
  const service = createService(
    [
      createProject('owner-converted', {
        state: 'converted_to_order',
        plannedEndAt: '2000-01-01',
      }),
    ],
    {
      verificationService: {
        async verifyCurrentSessionContext(context) {
          return {
            outcome: 'verified',
            currentSession: {
              sessionId: 'session-owner',
              actorId: 'user-1',
              userId: 'user-1',
              organizationId: 'buyer-org',
              requestId: context.requestId,
              traceId: context.traceId,
            },
          };
        },
      },
      eligibilityService: {
        async getCurrentOrganizationScope() {
          return {
            organization: { id: 'buyer-org' },
            membership: { roleKey: 'buyer_admin' },
            certification: { certificationStatus: 'approved' },
            roleKeys: ['buyer_admin'],
          };
        },
      },
    },
  );

  const detail = await service.getProjectById(
    'owner-converted',
    createContext('project-detail-owner-continuation', 'Bearer owner'),
  );

  assert.equal(detail.projectId, 'owner-converted');
  assert.equal(detail.state, 'converted_to_order');
  assert.equal(detail.viewerProjectRelation, 'owner');
});

test('non-owner converted_to_order detail remains trimmed when project is no longer public visible', async () => {
  const service = createService(
    [
      createProject('non-owner-converted', {
        state: 'converted_to_order',
        plannedEndAt: '2000-01-01',
      }),
    ],
    {
      verificationService: {
        async verifyCurrentSessionContext(context) {
          return {
            outcome: 'verified',
            currentSession: {
              sessionId: 'session-non-owner',
              actorId: 'user-2',
              userId: 'user-2',
              organizationId: 'supplier-org',
              requestId: context.requestId,
              traceId: context.traceId,
            },
          };
        },
      },
      eligibilityService: {
        async getCurrentOrganizationScope() {
          return {
            organization: { id: 'supplier-org' },
            membership: { roleKey: 'supplier_admin' },
            certification: { certificationStatus: 'approved' },
            roleKeys: ['supplier_admin'],
          };
        },
      },
    },
  );

  await assert.rejects(
    () =>
      service.getProjectById(
        'non-owner-converted',
        createContext('project-detail-non-owner-continuation', 'Bearer non-owner'),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_RESOURCE_UNAVAILABLE');
      return true;
    },
  );
});

test('project list/detail keep dual-field truth and legacy title-only fallback aligned', async () => {
  const service = createService([
    createProject('dual-field', {
      exhibitionName: '中国建博会',
      brandName: '品牌A',
      plannedStartAt: '2099-05-01',
      plannedEndAt: '2099-05-05',
    }),
    createProject('legacy-title', {
      exhibitionName: null,
      brandName: null,
      title: '历史标题项目',
      plannedStartAt: null,
      plannedEndAt: null,
    }),
  ]);

  const list = await service.listProjects(createContext('project-list-dual-legacy'));
  const dualItem = list.items.find((item) => item.projectId === 'dual-field');
  const legacyItem = list.items.find((item) => item.projectId === 'legacy-title');
  const detail = await service.getProjectById('legacy-title', createContext('project-detail-legacy'));

  assert.equal(dualItem.exhibitionName, '中国建博会');
  assert.equal(dualItem.brandName, '品牌A');
  assert.equal(dualItem.plannedStartAt, '2099-05-01');
  assert.equal(dualItem.plannedEndAt, '2099-05-05');
  assert.equal(legacyItem.title, '历史标题项目');
  assert.equal(legacyItem.exhibitionName, null);
  assert.equal(legacyItem.brandName, null);
  assert.equal(detail.title, '历史标题项目');
  assert.equal(detail.exhibitionName, null);
  assert.equal(detail.brandName, null);
});

test('project showcase list paginates after filter and expiry trimming', async () => {
  const service = createService([
    createProject('first-visible', { publishedAt: new Date('2026-04-10T09:00:00.000Z') }),
    createProject('second-visible', { publishedAt: new Date('2026-04-10T08:00:00.000Z') }),
    createProject('third-visible', { publishedAt: new Date('2026-04-10T07:00:00.000Z') }),
    createProject('expired-hidden', { plannedEndAt: '2000-01-01' }),
  ]);

  const pageOne = await service.listProjects(createContext('project-list-page-1'), {
    page: '1',
    pageSize: '2',
  });
  const pageTwo = await service.listProjects(createContext('project-list-page-2'), {
    page: '2',
    pageSize: '2',
  });

  assert.deepEqual(
    pageOne.items.map((item) => item.projectId),
    ['first-visible', 'second-visible'],
  );
  assert.deepEqual(pageOne.pagination, {
    page: 1,
    pageSize: 2,
    total: 3,
    hasMore: true,
  });
  assert.deepEqual(
    pageTwo.items.map((item) => item.projectId),
    ['third-visible'],
  );
  assert.deepEqual(pageTwo.pagination, {
    page: 2,
    pageSize: 2,
    total: 3,
    hasMore: false,
  });
});
