const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  MyProjectService,
} = require('../dist/apps/bff/src/routes/my_project/my-project.service.js');

function createService() {
  return new MyProjectService(
    {
      async get() {
        throw new Error('not used');
      },
      async delete() {
        throw new Error('not used');
      },
    },
    {
      buildForwardHeaders() {
        return {};
      },
    },
    new ErrorNormalizerService(),
  );
}

function createAxiosError(status, code, message) {
  return {
    isAxiosError: true,
    code: 'ERR_BAD_REQUEST',
    message: `Request failed with status code ${status}`,
    response: {
      status,
      data: {
        code,
        message,
        source: 'server',
      },
    },
  };
}

function createPublicProject(overrides = {}) {
  return {
    projectId: 'project-1',
    projectNo: 'PJT-001',
    title: '春季品牌展项目',
    exhibitionName: '中国建博会',
    brandName: '品牌A',
    buildingType: 'exhibition',
    budgetAmount: 120000,
    areaSqm: 300,
    provinceCode: '310000',
    provinceName: '上海市',
    cityCode: '310100',
    cityName: '上海市',
    plannedStartAt: '2026-05-01',
    plannedEndAt: '2026-05-03',
    state: 'published',
    summary: {
      heading: '项目摘要',
      stateLabel: '已发布',
    },
    buildingTypeRemark: null,
    districtCode: null,
    districtName: null,
    detailAddress: '浦东新区龙阳路 1 号',
    scopeSummary: '主场展位搭建与灯光优化',
    scheduleDetail: null,
    description: null,
    viewerProjectRelation: 'owner',
    ...overrides,
  };
}

function createPrivateProgress() {
  return {
    hasAcceptedOrder: false,
    orderStatus: null,
    contractStatus: null,
    milestoneCount: 0,
    inspectionStatus: null,
    formalCompletionStatus: 'not_formally_completed',
    evaluationStatus: 'not_eligible',
  };
}

test('my-project detail requires upstream viewerProjectRelation instead of defaulting to owner', () => {
  const service = createService();

  assert.throws(
    () =>
      service.toMyProjectDetailReadModel({
        publicProject: createPublicProject({ viewerProjectRelation: undefined }),
        privateProgress: createPrivateProgress(),
      }),
    /missing viewerProjectRelation/,
  );
});

test('my-project detail still accepts explicit owner/non_owner relation from upstream', () => {
  const service = createService();

  const ownerDetail = service.toMyProjectDetailReadModel({
    publicProject: createPublicProject({ viewerProjectRelation: 'owner' }),
    privateProgress: createPrivateProgress(),
  });
  assert.equal(ownerDetail.publicProject.viewerProjectRelation, 'owner');

  const nonOwnerDetail = service.toMyProjectDetailReadModel({
    publicProject: createPublicProject({ viewerProjectRelation: 'non_owner' }),
    privateProgress: createPrivateProgress(),
  });
  assert.equal(nonOwnerDetail.publicProject.viewerProjectRelation, 'non_owner');
});

test('my-project publicProject keeps dual-field values and legacy title-only fallback aligned', () => {
  const service = createService();

  const dualField = service.toMyProjectDetailReadModel({
    publicProject: createPublicProject(),
    privateProgress: createPrivateProgress(),
  });
  const legacyTitleOnly = service.toMyProjectDetailReadModel({
    publicProject: createPublicProject({
      title: '历史标题项目',
      exhibitionName: null,
      brandName: null,
      plannedStartAt: null,
      plannedEndAt: null,
    }),
    privateProgress: createPrivateProgress(),
  });

  assert.equal(dualField.publicProject.exhibitionName, '中国建博会');
  assert.equal(dualField.publicProject.brandName, '品牌A');
  assert.equal(dualField.publicProject.plannedStartAt, '2026-05-01');
  assert.equal(dualField.publicProject.plannedEndAt, '2026-05-03');
  assert.equal(legacyTitleOnly.publicProject.title, '历史标题项目');
  assert.equal(legacyTitleOnly.publicProject.exhibitionName, null);
  assert.equal(legacyTitleOnly.publicProject.brandName, null);
});

test('my-project detail keeps lifecycle fallout state and summary from upstream publicProject', () => {
  const service = createService();

  const submittedDetail = service.toMyProjectDetailReadModel({
    publicProject: createPublicProject({
      state: 'submitted',
      summary: {
        heading: '项目已提交发布链路，可继续执行发布。',
        stateLabel: '当前项目已提交，尚未进入公域展示。',
      },
    }),
    privateProgress: createPrivateProgress(),
  });

  const publishedDetail = service.toMyProjectDetailReadModel({
    publicProject: createPublicProject({
      state: 'published',
      summary: {
        heading: '项目已进入最小发布走廊。',
        stateLabel: '当前项目已发布，可继续进入最小竞标继续面。',
      },
    }),
    privateProgress: createPrivateProgress(),
  });

  assert.equal(submittedDetail.publicProject.state, 'submitted');
  assert.equal(
    submittedDetail.publicProject.summary.stateLabel,
    '当前项目已提交，尚未进入公域展示。',
  );
  assert.equal(publishedDetail.publicProject.state, 'published');
  assert.equal(
    publishedDetail.publicProject.summary.stateLabel,
    '当前项目已发布，可继续进入最小竞标继续面。',
  );
});

test('my-project delete forwards current project id and preserves deleted carrier', async () => {
  const service = new MyProjectService(
    {
      async get() {
        throw new Error('not used');
      },
      async delete(path) {
        assert.equal(path, '/server/projects/project-1');
        return { projectId: 'project-1', state: 'deleted' };
      },
    },
    {
      buildForwardHeaders() {
        return {};
      },
    },
    new ErrorNormalizerService(),
  );

  const deleted = await service.deleteMyProject('project-1', {});
  assert.deepEqual(deleted, { projectId: 'project-1', state: 'deleted' });
});

test('my-project delete maps invalid state into stable chinese message', async () => {
  const service = new MyProjectService(
    {
      async get() {
        throw new Error('not used');
      },
      async delete() {
        throw createAxiosError(
          409,
          'PROJECT_INVALID_STATE',
          'Only draft projects may be deleted.',
        );
      },
    },
    {
      buildForwardHeaders() {
        return {};
      },
    },
    new ErrorNormalizerService(),
  );

  await assert.rejects(
    () => service.deleteMyProject('project-1', {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'PROJECT_INVALID_STATE');
      assert.equal(error.getResponse().message, '当前只有草稿项目允许删除。');
      return true;
    },
  );
});
