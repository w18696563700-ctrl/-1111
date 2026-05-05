const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId) {
  return {
    authorization: 'Bearer test',
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
    creatorActorId: 'user-1',
    title: `${id}-title`,
    buildingType: 'exhibition',
    budgetAmount: '1000.00',
    areaSqm: null,
    buildingTypeRemark: null,
    provinceCode: '310000',
    provinceName: '上海市',
    cityCode: '310100',
    cityName: '上海市',
    districtCode: null,
    districtName: null,
    detailAddress: '测试地址',
    scopeSummary: '测试项目',
    plannedStartAt: null,
    plannedEndAt: null,
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

function createProjectPresenter() {
  return {
    toShowcaseListItem(project) {
      return {
        projectId: project.id,
        title: project.title,
      };
    },
    toReadModel(project) {
      return {
        projectId: project.id,
        title: project.title,
      };
    },
  };
}

test('non-archived historicalProjects bucket still follows formalCompletionStatus', async () => {
  const { MyProjectPresenter } = require('../dist/modules/my_project/my-project.presenter.js');
  const presenter = new MyProjectPresenter(createProjectPresenter());
  const ongoingProject = createProject('project-ongoing');
  const completedProject = createProject('project-history');

  const result = presenter.toListResponse(
    [ongoingProject, completedProject],
    new Map([
      [
        ongoingProject.id,
        {
          hasAcceptedOrder: true,
          orderStatus: 'active',
          contractStatus: 'active',
          fulfillmentStatus: 'submitted',
          acceptanceStatus: null,
          afterSalesOrDisputeStatus: null,
          formalCompletionStatus: 'not_formally_completed',
          evaluationStatus: 'not_eligible',
        },
      ],
      [
        completedProject.id,
        {
          hasAcceptedOrder: true,
          orderStatus: 'completed',
          contractStatus: 'active',
          fulfillmentStatus: 'submitted',
          acceptanceStatus: null,
          afterSalesOrDisputeStatus: null,
          formalCompletionStatus: 'formally_completed',
          evaluationStatus: 'eligible',
        },
      ],
    ]),
  );

  assert.equal(result.ongoingProjects.length, 1);
  assert.equal(result.ongoingProjects[0].publicProject.projectId, 'project-ongoing');
  assert.equal(result.ongoingProjects[0].projectCreatedAt, '2026-04-10T07:00:00.000Z');
  assert.equal(result.historicalProjects.length, 1);
  assert.equal(result.historicalProjects[0].publicProject.projectId, 'project-history');
  assert.equal(result.historicalProjects[0].projectCreatedAt, '2026-04-10T07:00:00.000Z');
});

test('default private progress fallback stays in ongoingProjects', async () => {
  const { MyProjectPresenter } = require('../dist/modules/my_project/my-project.presenter.js');
  const { MyProjectQueryService } = require('../dist/modules/my_project/my-project.query.service.js');
  const service = new MyProjectQueryService(
    {
      async find() {
        return [createProject('project-no-trade-truth')];
      },
      async query() {
        return [];
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
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
          organization: { id: 'buyer-org' },
          membership: { roleKey: 'buyer_admin' },
          certification: { certificationStatus: 'approved' },
          roleKeys: ['buyer_admin'],
        };
      },
    },
    new MyProjectPresenter(createProjectPresenter()),
  );

  const result = await service.listProjects(createContext('my-project-list'));

  assert.equal(result.historicalProjects.length, 0);
  assert.equal(result.ongoingProjects.length, 1);
  assert.equal(
    result.ongoingProjects[0].privateSummary.formalCompletionStatus,
    'not_formally_completed',
  );
});

test('formalCompletionStatus stays order-derived while evaluationStatus reflects rating submit truth', async () => {
  const {
    deriveMyProjectPrivateProgress,
  } = require('../dist/modules/my_project/my-project.private-progress.js');

  const ongoingProgress = deriveMyProjectPrivateProgress({
    hasAcceptedOrder: true,
    orderStatus: 'active',
    contractStatus: 'active',
    fulfillmentStatus: 'submitted',
    acceptanceStatus: null,
    afterSalesOrDisputeStatus: 'opened',
    ratingStatus: 'submitted',
  });
  const eligibleProgress = deriveMyProjectPrivateProgress({
    hasAcceptedOrder: true,
    orderStatus: 'completed',
    contractStatus: 'active',
    fulfillmentStatus: 'submitted',
    acceptanceStatus: null,
    afterSalesOrDisputeStatus: 'opened',
    ratingStatus: 'draft',
  });
  const submittedProgress = deriveMyProjectPrivateProgress({
    hasAcceptedOrder: true,
    orderStatus: 'completed',
    contractStatus: 'active',
    fulfillmentStatus: 'submitted',
    acceptanceStatus: null,
    afterSalesOrDisputeStatus: 'opened',
    ratingStatus: 'submitted',
  });

  assert.equal(ongoingProgress.formalCompletionStatus, 'not_formally_completed');
  assert.equal(ongoingProgress.evaluationStatus, 'not_eligible');
  assert.equal(eligibleProgress.formalCompletionStatus, 'formally_completed');
  assert.equal(eligibleProgress.evaluationStatus, 'eligible');
  assert.equal(submittedProgress.formalCompletionStatus, 'formally_completed');
  assert.equal(submittedProgress.evaluationStatus, 'submitted');
});

test('my-project query refreshes dispute and submitted evaluation status from latest truth rows', async () => {
  const { MyProjectPresenter } = require('../dist/modules/my_project/my-project.presenter.js');
  const { MyProjectQueryService } = require('../dist/modules/my_project/my-project.query.service.js');
  const executedSql = [];
  const repository = {
    async find() {
      return [createProject('project-trade')];
    },
    async query(sql) {
      executedSql.push(sql);
      if (sql.includes('from public.orders')) {
        return [
          {
            id: 'order-1',
            projectId: 'project-trade',
            state: 'completed',
            createdAt: '2026-04-11T00:00:00.000Z',
            updatedAt: '2026-04-11T00:00:00.000Z',
          },
        ];
      }
      if (sql.includes('from public.contracts')) {
        return [];
      }
      if (sql.includes('from public.milestones')) {
        return [];
      }
      if (sql.includes('from public.disputes')) {
        return [
          {
            id: 'dispute-1',
            orderId: 'order-1',
            state: 'withdrawn',
            createdAt: '2026-04-11T00:00:00.000Z',
            updatedAt: '2026-04-11T00:00:00.000Z',
          },
        ];
      }
      if (sql.includes('from public.ratings')) {
        return [
          {
            id: 'rating-1',
            orderId: 'order-1',
            state: 'submitted',
            createdAt: '2026-04-11T00:00:00.000Z',
            updatedAt: '2026-04-11T00:00:00.000Z',
          },
        ];
      }
      return [];
    },
  };
  const service = new MyProjectQueryService(
    repository,
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
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
          organization: { id: 'buyer-org' },
          membership: { roleKey: 'buyer_admin' },
          certification: { certificationStatus: 'approved' },
          roleKeys: ['buyer_admin'],
        };
      },
    },
    new MyProjectPresenter(createProjectPresenter()),
  );

  const result = await service.listProjects(createContext('my-project-no-dead-truth'));

  assert.equal(result.historicalProjects.length, 1);
  assert.equal(result.historicalProjects[0].privateSummary.afterSalesOrDisputeStatus, 'withdrawn');
  assert.equal(result.historicalProjects[0].privateSummary.evaluationStatus, 'submitted');
  assert.equal(executedSql.some((sql) => sql.includes('from public.disputes')), true);
  assert.equal(executedSql.some((sql) => sql.includes('from public.ratings')), true);
});

test('my-project publicProject reuses shared project naming truth with legacy fallback', () => {
  const { MyProjectPresenter } = require('../dist/modules/my_project/my-project.presenter.js');
  const { ProjectPresenter } = require('../dist/modules/project/project.presenter.js');

  const presenter = new MyProjectPresenter(new ProjectPresenter());
  const result = presenter.toDetailResponse(
    createProject('legacy-project', {
      title: '历史标题项目',
      exhibitionName: null,
      brandName: null,
      plannedStartAt: '2026-05-01',
      plannedEndAt: '2026-05-03',
    }),
    {
      hasAcceptedOrder: false,
      orderStatus: null,
      contractStatus: null,
      fulfillmentStatus: null,
      acceptanceStatus: null,
      afterSalesOrDisputeStatus: null,
      formalCompletionStatus: 'not_formally_completed',
      evaluationStatus: 'not_eligible',
    },
    'owner',
  );

  assert.equal(result.publicProject.title, '历史标题项目');
  assert.equal(result.publicProject.exhibitionName, null);
  assert.equal(result.publicProject.brandName, null);
  assert.equal(result.publicProject.plannedStartAt, '2026-05-01');
  assert.equal(result.publicProject.plannedEndAt, '2026-05-03');
});

test('my-project privateProgress refreshes contractStatus from latest contract truth', async () => {
  const { MyProjectPresenter } = require('../dist/modules/my_project/my-project.presenter.js');
  const { MyProjectQueryService } = require('../dist/modules/my_project/my-project.query.service.js');

  const repository = {
    async find() {
      return [createProject('project-contract-active')];
    },
    async query(sql) {
      if (sql.includes('from public.orders')) {
        return [
          {
            id: 'order-1',
            projectId: 'project-contract-active',
            state: 'active',
            createdAt: '2026-04-11T00:00:00.000Z',
            updatedAt: '2026-04-11T00:00:00.000Z',
          },
        ];
      }
      if (sql.includes('from public.contracts')) {
        return [
          {
            id: 'contract-1',
            orderId: 'order-1',
            state: 'active',
            createdAt: '2026-04-11T00:00:00.000Z',
            updatedAt: '2026-04-11T00:05:00.000Z',
          },
        ];
      }
      if (sql.includes('from public.milestones')) {
        return [];
      }
      return [];
    },
  };

  const service = new MyProjectQueryService(
    repository,
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
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
          organization: { id: 'buyer-org' },
          membership: { roleKey: 'buyer_admin' },
          certification: { certificationStatus: 'approved' },
          roleKeys: ['buyer_admin'],
        };
      },
    },
    new MyProjectPresenter(createProjectPresenter()),
  );

  const result = await service.listProjects(createContext('my-project-contract-refresh'));

  assert.equal(result.ongoingProjects.length, 1);
  assert.equal(result.ongoingProjects[0].privateSummary.contractStatus, 'active');
});

test('my-project list/detail fall back to legacy public.projects ownership truth', async () => {
  const { MyProjectPresenter } = require('../dist/modules/my_project/my-project.presenter.js');
  const { MyProjectQueryService } = require('../dist/modules/my_project/my-project.query.service.js');

  const repository = {
    async find() {
      return [];
    },
    async findOneBy() {
      return null;
    },
    async query(sql, params) {
      if (
        sql.includes('from public.projects') &&
        sql.includes('owner_organization_id = $1') &&
        !sql.includes('projects.id = $1')
      ) {
        return [
          {
            id: 'legacy-project-1',
            projectNo: 'LEG-1',
            ownerOrganizationId: 'buyer-org',
            createdBy: 'user-1',
            buildingType: 'exhibition',
            title: '遗留项目',
            description: 'legacy',
            budgetAmount: '88000',
            state: 'published',
            publishedAt: '2026-04-12T00:00:00.000Z',
            createdAt: '2026-04-11T00:00:00.000Z',
            updatedAt: '2026-04-12T00:00:00.000Z',
          },
        ];
      }
      if (sql.includes('from public.projects') && sql.includes('projects.id = $1')) {
        return [
          {
            id: params[0],
            projectNo: 'LEG-1',
            ownerOrganizationId: 'buyer-org',
            createdBy: 'user-1',
            buildingType: 'exhibition',
            title: '遗留项目',
            description: 'legacy',
            budgetAmount: '88000',
            state: 'published',
            publishedAt: '2026-04-12T00:00:00.000Z',
            createdAt: '2026-04-11T00:00:00.000Z',
            updatedAt: '2026-04-12T00:00:00.000Z',
          },
        ];
      }
      if (sql.includes('from public.orders')) {
        return [
          {
            id: 'order-legacy-1',
            projectId: 'legacy-project-1',
            state: 'active',
            createdAt: '2026-04-11T00:00:00.000Z',
            updatedAt: '2026-04-11T00:00:00.000Z',
          },
        ];
      }
      if (sql.includes('from public.contracts')) {
        return [
          {
            id: 'contract-legacy-1',
            orderId: 'order-legacy-1',
            state: 'pending_confirm',
            createdAt: '2026-04-11T00:00:00.000Z',
            updatedAt: '2026-04-11T00:05:00.000Z',
          },
        ];
      }
      if (sql.includes('from public.milestones')) {
        return [];
      }
      return [];
    },
  };

  const service = new MyProjectQueryService(
    repository,
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
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
          organization: { id: 'buyer-org' },
          membership: { roleKey: 'buyer_admin' },
          certification: { certificationStatus: 'approved' },
          roleKeys: ['buyer_admin'],
        };
      },
    },
    new MyProjectPresenter(createProjectPresenter()),
  );

  const list = await service.listProjects(createContext('my-project-legacy-list'));
  const detail = await service.getProjectById('legacy-project-1', createContext('my-project-legacy-detail'));

  assert.equal(list.ongoingProjects.length, 1);
  assert.equal(list.ongoingProjects[0].publicProject.projectId, 'legacy-project-1');
  assert.equal(list.ongoingProjects[0].privateSummary.contractStatus, 'pending_confirm');
  assert.equal(detail.publicProject.projectId, 'legacy-project-1');
  assert.equal(detail.privateProgress.contractStatus, 'pending_confirm');
});
