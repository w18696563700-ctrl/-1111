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
    remoteIp: '127.0.0.1',
  };
}

function createHarness() {
  const { ProjectWriteService } = require('../dist/modules/project/project-write.service.js');
  const { ProjectQueryService } = require('../dist/modules/project/project-query.service.js');
  const { ProjectPresenter } = require('../dist/modules/project/project.presenter.js');

  const projects = [];
  const auditLogs = [];
  const repository = {
    items: projects,
    create(input) {
      return { ...input };
    },
    async save(value) {
      const index = projects.findIndex((item) => item.id === value.id);
      if (index >= 0) {
        projects[index] = { ...projects[index], ...value };
        return projects[index];
      }
      projects.push({ ...value });
      return value;
    },
    async delete(where) {
      const index = projects.findIndex((project) => {
        if (where.id && project.id !== where.id) {
          return false;
        }
        if (where.organizationId && project.organizationId !== where.organizationId) {
          return false;
        }
        return true;
      });
      if (index >= 0) {
        projects.splice(index, 1);
      }
      return { affected: index >= 0 ? 1 : 0 };
    },
    async findOne(options) {
      const where = options?.where ?? {};
      return (
        projects.find((project) => {
          if (where.id && project.id !== where.id) {
            return false;
          }
          if (where.publishedAt && project.publishedAt == null) {
            return false;
          }
          return true;
        }) ?? null
      );
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
    async find(options) {
      const where = options?.where ?? {};
      return projects.filter((project) => {
        if (where.publishedAt && project.publishedAt == null) {
          return false;
        }
        return true;
      });
    },
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
          roleKeys: ['buyer_admin'],
        },
      };
    },
    async getCurrentOrganizationScope() {
      return {
        organization: { id: 'buyer-org' },
        membership: { roleKey: 'buyer_admin' },
        certification: { certificationStatus: 'approved' },
        roleKeys: ['buyer_admin'],
      };
    },
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
          traceId: context.traceId,
        },
      };
    },
  };

  return {
    projects,
    auditLogs,
    writeService: new ProjectWriteService(
      repository,
      {
        async transaction(callback) {
          return callback({
            getRepository() {
              return repository;
            },
          });
        },
      },
      new ProjectPresenter(),
      {
        async record(entry) {
          auditLogs.push(entry);
        },
      },
      verificationService,
      eligibilityService,
    ),
    queryService: new ProjectQueryService(
      repository,
      verificationService,
      eligibilityService,
      new ProjectPresenter(),
    ),
  };
}

function createPayload(overrides = {}) {
  return {
    exhibitionName: '中国建博会',
    brandName: '品牌A',
    buildingType: 'exhibition',
    budgetAmount: 120000,
    provinceCode: '310000',
    provinceName: '上海市',
    cityCode: '310100',
    cityName: '上海市',
    detailAddress: '浦东新区龙阳路 1 号',
    scopeSummary: '主场展位搭建与灯光优化',
    ...overrides,
  };
}

test('project lifecycle closes create -> save -> submit -> publish with real server truth', async () => {
  const harness = createHarness();

  const created = await harness.writeService.createProject(
    createPayload(),
    createContext('project-create'),
  );
  assert.equal(created.state, 'draft');
  assert.equal(harness.projects[0].publishedAt, null);

  const saved = await harness.writeService.saveProject(
    {
      projectId: created.projectId,
      ...createPayload({ brandName: '品牌B' }),
    },
    createContext('project-save'),
  );
  assert.equal(saved.state, 'draft');
  assert.equal(harness.projects[0].brandName, '品牌B');
  assert.equal(harness.projects[0].title, '中国建博会 / 品牌B');

  const submitted = await harness.writeService.submitProject(
    { projectId: created.projectId },
    createContext('project-submit'),
  );
  assert.equal(submitted.state, 'submitted');
  assert.equal(harness.projects[0].state, 'submitted');
  assert.equal(harness.projects[0].publishedAt, null);

  const published = await harness.writeService.publishProject(
    { projectId: created.projectId },
    createContext('project-publish'),
  );
  assert.equal(published.state, 'published');
  assert.equal(harness.projects[0].state, 'published');
  assert.ok(harness.projects[0].publishedAt instanceof Date);
});

test('project lifecycle allows owner to delete draft project only and records audit', async () => {
  const harness = createHarness();
  const created = await harness.writeService.createProject(
    createPayload(),
    createContext('project-create-delete'),
  );

  const deleted = await harness.writeService.deleteProject(
    created.projectId,
    createContext('project-delete-draft'),
  );
  assert.deepEqual(deleted, { projectId: created.projectId, state: 'deleted' });
  assert.equal(harness.projects.length, 0);
  assert.equal(harness.auditLogs.at(-1)?.eventType, 'project_deleted');
});

test('project lifecycle rejects deleting non-draft project', async () => {
  const harness = createHarness();
  const created = await harness.writeService.createProject(
    createPayload(),
    createContext('project-create-delete-invalid'),
  );
  await harness.writeService.submitProject(
    { projectId: created.projectId },
    createContext('project-submit-delete-invalid'),
  );

  await assert.rejects(
    () => harness.writeService.deleteProject(
      created.projectId,
      createContext('project-delete-submitted'),
    ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_INVALID_STATE');
      return true;
    },
  );
  assert.equal(harness.projects.length, 1);
});

test('project editable detail can read draft while public detail stays closed until publish', async () => {
  const harness = createHarness();
  const created = await harness.writeService.createProject(
    createPayload(),
    createContext('project-create-draft'),
  );

  const editable = await harness.queryService.getEditableProjectById(
    created.projectId,
    createContext('project-edit-detail'),
  );
  assert.equal(editable.projectId, created.projectId);
  assert.equal(editable.state, 'draft');
  assert.equal(editable.viewerProjectRelation, 'owner');

  await assert.rejects(
    () => harness.queryService.getProjectById(created.projectId, createContext('project-public-detail')),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_RESOURCE_UNAVAILABLE');
      return true;
    },
  );

  await harness.writeService.submitProject(
    { projectId: created.projectId },
    createContext('project-submit-visible'),
  );
  await harness.writeService.publishProject(
    { projectId: created.projectId },
    createContext('project-publish-visible'),
  );

  const publicDetail = await harness.queryService.getProjectById(
    created.projectId,
    createContext('project-public-detail-visible'),
  );
  assert.equal(publicDetail.state, 'published');
});

test('project lifecycle rejects invalid state transitions', async () => {
  const harness = createHarness();
  const created = await harness.writeService.createProject(
    createPayload(),
    createContext('project-create-invalid-state'),
  );

  await assert.rejects(
    () => harness.writeService.publishProject(
      { projectId: created.projectId },
      createContext('project-publish-before-submit'),
    ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_INVALID_STATE');
      return true;
    },
  );

  await harness.writeService.submitProject(
    { projectId: created.projectId },
    createContext('project-submit-once'),
  );

  await assert.rejects(
    () => harness.writeService.saveProject(
      { projectId: created.projectId, ...createPayload() },
      createContext('project-save-after-submit'),
    ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_INVALID_STATE');
      return true;
    },
  );
});
