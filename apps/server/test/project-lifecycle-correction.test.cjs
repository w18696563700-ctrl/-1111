const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId, authorization = 'Bearer lifecycle') {
  return {
    authorization,
    actorId: '',
    userId: '',
    organizationId: '',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1'
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
    exhibitionName: '中国建博会',
    brandName: '品牌A',
    buildingType: 'exhibition',
    budgetAmount: '120000.00',
    areaSqm: null,
    buildingTypeRemark: null,
    provinceCode: '310000',
    provinceName: '上海市',
    cityCode: '310100',
    cityName: '上海市',
    districtCode: null,
    districtName: null,
    detailAddress: '浦东新区龙阳路 1 号',
    scopeSummary: '主场展位搭建与灯光优化',
    plannedStartAt: null,
    plannedEndAt: null,
    scheduleDetail: null,
    description: null,
    state: 'submitted',
    summary: {
      heading: '项目已提交发布链路，可继续执行发布。',
      stateLabel: '当前项目已提交，尚未进入公域展示。'
    },
    publishedAt: null,
    createdAt: new Date('2026-04-13T08:00:00.000Z'),
    updatedAt: new Date('2026-04-13T08:00:00.000Z'),
    ...overrides
  };
}

function createHarness() {
  const { ProjectLifecycleService } = require('../dist/modules/project/project-lifecycle.service.js');
  const { ProjectQueryService } = require('../dist/modules/project/project-query.service.js');
  const { ProjectPresenter } = require('../dist/modules/project/project.presenter.js');
  const { MyProjectPresenter } = require('../dist/modules/my_project/my-project.presenter.js');
  const { MyProjectQueryService } = require('../dist/modules/my_project/my-project.query.service.js');

  const projects = [];
  const auditLogs = [];
  const repository = {
    items: projects,
    async save(value) {
      const index = projects.findIndex((item) => item.id === value.id);
      if (index >= 0) {
        projects[index] = { ...projects[index], ...value };
        return projects[index];
      }
      projects.push({ ...value });
      return value;
    },
    async find(options = {}) {
      const where = options.where ?? {};
      return projects
        .filter((project) => {
          if (where.organizationId && project.organizationId !== where.organizationId) {
            return false;
          }
          return true;
        })
        .sort((left, right) => {
          const leftPublished = left.publishedAt instanceof Date ? left.publishedAt.getTime() : 0;
          const rightPublished = right.publishedAt instanceof Date ? right.publishedAt.getTime() : 0;
          if (leftPublished !== rightPublished) {
            return rightPublished - leftPublished;
          }
          return right.createdAt.getTime() - left.createdAt.getTime();
        });
    },
    async findOneBy(where) {
      return (
        projects.find((project) => {
          if (where.id && project.id !== where.id) {
            return false;
          }
          if (where.organizationId && project.organizationId !== where.organizationId) {
            return false;
          }
          return true;
        }) ?? null
      );
    },
    async findOne(options) {
      const where = options?.where ?? {};
      return (
        projects.find((project) => {
          if (where.id && project.id !== where.id) {
            return false;
          }
          return true;
        }) ?? null
      );
    },
    async query(sql) {
      if (sql.includes('from public.projects')) {
        return [];
      }
      return [];
    }
  };

  const verificationService = {
    async verifyCurrentSessionContext(context) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'user-1',
          userId: 'user-1',
          organizationId: 'buyer-org',
          requestId: context.requestId,
          traceId: context.traceId
        }
      };
    }
  };

  const eligibilityService = {
    async requireProjectPublishEligibilityFromContext(context, resolver) {
      const verified = await resolver.verifyCurrentSessionContext(context);
      return {
        currentSession: verified.currentSession,
        scope: {
          organization: { id: 'buyer-org' },
          membership: { roleKey: 'buyer_admin' },
          certification: { certificationStatus: 'approved' },
          roleKeys: ['buyer_admin']
        }
      };
    },
    async requireAuthenticatedActor() {
      return { id: 'user-1', status: 'active' };
    },
    async getCurrentOrganizationScope() {
      return {
        organization: { id: 'buyer-org' },
        membership: { roleKey: 'buyer_admin' },
        certification: { certificationStatus: 'approved' },
        roleKeys: ['buyer_admin']
      };
    }
  };

  const presenter = new ProjectPresenter();

  return {
    projects,
    auditLogs,
    lifecycleService: new ProjectLifecycleService(
      repository,
      {
        async transaction(callback) {
          return callback({
            getRepository() {
              return repository;
            }
          });
        }
      },
      presenter,
      {
        async record(entry) {
          auditLogs.push(entry);
        }
      },
      verificationService,
      eligibilityService
    ),
    publicQueryService: new ProjectQueryService(
      repository,
      verificationService,
      eligibilityService,
      presenter
    ),
    myProjectQueryService: new MyProjectQueryService(
      repository,
      verificationService,
      eligibilityService,
      new MyProjectPresenter(presenter)
    )
  };
}

test('project lifecycle correction materializes submitted withdraw back to draft with audit', async () => {
  const harness = createHarness();
  harness.projects.push(createProject('project-withdraw'));

  const accepted = await harness.lifecycleService.withdrawProject(
    { projectId: 'project-withdraw' },
    createContext('project-withdraw')
  );

  assert.deepEqual(accepted, { projectId: 'project-withdraw', state: 'draft' });
  assert.equal(harness.projects[0].state, 'draft');
  assert.equal(harness.projects[0].publishedAt, null);
  assert.equal(harness.auditLogs.at(-1)?.eventType, 'project_withdrawn_to_draft');
});

test('project lifecycle correction materializes submitted archive into owner historical bucket', async () => {
  const harness = createHarness();
  harness.projects.push(createProject('project-archive'));

  const accepted = await harness.lifecycleService.archiveProject(
    { projectId: 'project-archive' },
    createContext('project-archive')
  );
  const myProjects = await harness.myProjectQueryService.listProjects(
    createContext('my-project-list')
  );
  const archivedDetail = await harness.myProjectQueryService.getProjectById(
    'project-archive',
    createContext('my-project-detail')
  );

  assert.deepEqual(accepted, { projectId: 'project-archive', state: 'archived' });
  assert.equal(myProjects.ongoingProjects.length, 0);
  assert.equal(myProjects.historicalProjects.length, 1);
  assert.equal(myProjects.historicalProjects[0].publicProject.projectId, 'project-archive');
  assert.equal(archivedDetail.publicProject.state, 'archived');
  assert.equal(harness.auditLogs.at(-1)?.eventType, 'project_archived');
});

test('project lifecycle correction closes published project into archived and removes public visibility only', async () => {
  const harness = createHarness();
  harness.projects.push(
    createProject('project-close', {
      state: 'published',
      publishedAt: new Date('2026-04-13T09:00:00.000Z'),
      summary: {
        heading: '项目已进入最小发布走廊。',
        stateLabel: '当前项目已发布，可继续进入最小竞标继续面。'
      }
    })
  );

  const accepted = await harness.lifecycleService.closeProject(
    { projectId: 'project-close' },
    createContext('project-close')
  );

  await assert.rejects(
    () => harness.publicQueryService.getProjectById('project-close', createContext('public-detail', '')),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_RESOURCE_UNAVAILABLE');
      return true;
    }
  );

  const ownerDetail = await harness.myProjectQueryService.getProjectById(
    'project-close',
    createContext('owner-detail')
  );

  assert.deepEqual(accepted, { projectId: 'project-close', state: 'archived' });
  assert.equal(ownerDetail.publicProject.projectId, 'project-close');
  assert.equal(ownerDetail.publicProject.state, 'archived');
  assert.equal(harness.auditLogs.at(-1)?.eventType, 'project_closed');
});

test('project lifecycle correction keeps awarded and converted_to_order on business close boundary only', async () => {
  const harness = createHarness();
  harness.projects.push(
    createProject('project-awarded', {
      state: 'converted_to_order',
      publishedAt: new Date('2026-04-13T09:00:00.000Z')
    })
  );

  await assert.rejects(
    () => harness.lifecycleService.closeProject(
      { projectId: 'project-awarded' },
      createContext('project-close-converted')
    ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_INVALID_STATE');
      return true;
    }
  );
});
