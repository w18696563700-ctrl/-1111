const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  ProjectService,
} = require('../dist/apps/bff/src/routes/project/project.service.js');

function createService(overrides = {}) {
  return new ProjectService(
    {
      async post() {
        throw new Error('post mock missing');
      },
      async get() {
        throw new Error('get mock missing');
      },
      ...overrides.serverClient,
    },
    {
      buildForwardHeaders() {
        return { authorization: 'Bearer smoke' };
      },
      buildPublicHeadersWithOptionalActorHints() {
        return { authorization: 'Bearer public' };
      },
    },
    new ErrorNormalizerService(),
  );
}

function createAxiosError(status, code, message, details) {
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
        ...(details ? { details } : {}),
      },
    },
  };
}

function createProjectDetail(overrides = {}) {
  return {
    projectId: 'project-1',
    projectNo: 'PJ-001',
    title: '中国建博会 / 品牌A',
    exhibitionName: '中国建博会',
    brandName: '品牌A',
    buildingType: 'exhibition',
    budgetAmount: 120000,
    areaSqm: 36,
    provinceCode: '310000',
    provinceName: '上海市',
    cityCode: '310100',
    cityName: '上海市',
    districtCode: null,
    districtName: null,
    detailAddress: '浦东新区龙阳路 1 号',
    scopeSummary: '主场展位搭建与灯光优化',
    plannedStartAt: '2026-05-01',
    plannedEndAt: '2026-05-03',
    buildingTypeRemark: null,
    scheduleDetail: null,
    viewerProjectRelation: 'owner',
    description: null,
    state: 'draft',
    summary: {
      heading: '项目草稿已创建，可继续编辑后提交。',
      stateLabel: '当前项目为草稿，尚未进入公域展示。',
    },
    ...overrides,
  };
}

test('project lifecycle forwards edit/save/submit/publish to server and keeps accepted state carrier', async () => {
  const calls = [];
  const savePayload = {
    projectId: 'project-1',
    exhibitionName: '中国建博会',
    brandName: '品牌A',
    title: '中国建博会 / 品牌A',
    buildingType: 'exhibition',
    budgetAmount: 120000,
    provinceCode: '310000',
    provinceName: '上海市',
    cityCode: '310100',
    cityName: '上海市',
    detailAddress: '浦东新区龙阳路 1 号',
    scopeSummary: '主场展位搭建与灯光优化',
  };
  const service = createService({
    serverClient: {
      async get(path) {
        calls.push(['get', path]);
        return createProjectDetail();
      },
      async post(path, payload) {
        calls.push(['post', path, payload]);
        if (path === '/server/projects/save') {
          return { projectId: 'project-1', state: 'draft' };
        }
        if (path === '/server/projects/submit') {
          return { projectId: 'project-1', state: 'submitted' };
        }
        return { projectId: 'project-1', state: 'published' };
      },
    },
  });

  const editDetail = await service.getProjectEditDetail('project-1', {});
  const saved = await service.saveProject(savePayload, {});
  const submitted = await service.submitProject({ projectId: 'project-1' }, {});
  const published = await service.publishProject({ projectId: 'project-1' }, {});

  assert.equal(calls[0][1], '/server/projects/project-1/edit');
  assert.equal(calls[1][1], '/server/projects/save');
  assert.equal(calls[2][1], '/server/projects/submit');
  assert.equal(calls[3][1], '/server/projects/publish');
  assert.deepEqual(calls[1][2], savePayload);
  assert.equal(editDetail.state, 'draft');
  assert.deepEqual(saved, { projectId: 'project-1', state: 'draft' });
  assert.deepEqual(submitted, { projectId: 'project-1', state: 'submitted' });
  assert.deepEqual(published, { projectId: 'project-1', state: 'published' });
});

test('project lifecycle keeps invalid-state fallout stable at bff layer', async () => {
  const service = createService({
    serverClient: {
      async post() {
        throw createAxiosError(409, 'PROJECT_INVALID_STATE', 'Only submitted projects may be published.');
      },
    },
  });

  await assert.rejects(
    () => service.publishProject({ projectId: 'project-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'PROJECT_INVALID_STATE');
      assert.equal(error.getResponse().message, '当前项目尚未提交，暂不支持发布。');
      return true;
    },
  );
});

test('project publish preserves green-channel gate rejection semantics', async () => {
  const service = createService({
    serverClient: {
      async post() {
        throw createAxiosError(
          409,
          'PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_POLICY_UNAVAILABLE',
          'Project publish requires quote-basis materials and green-channel feedback.',
        );
      },
    },
  });

  await assert.rejects(
    () => service.publishProject({ projectId: 'project-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_POLICY_UNAVAILABLE');
      assert.equal(
        error.getResponse().message,
        '发布项目需先补齐必传报价依据资料，并完成项目真实性诚意金绿色通道表态；选择支持或暂不支持均可继续发布。',
      );
      assert.equal(error.getResponse().source, 'server');
      return true;
    },
  );
});

test('project lifecycle save uses route-specific invalid code for partial dual-field payloads', async () => {
  const service = createService();

  await assert.rejects(
    () =>
      service.saveProject(
        {
          projectId: 'project-1',
          exhibitionName: '只有展会名称',
          buildingType: 'exhibition',
          budgetAmount: 90000,
          provinceCode: '310000',
          provinceName: '上海市',
          cityCode: '310100',
          cityName: '上海市',
          detailAddress: '浦东新区龙阳路 1 号',
          scopeSummary: '搭建范围',
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'PROJECT_SAVE_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前项目保存参数无效，请检查后再试。',
      );
      return true;
    },
  );
});

test('project lifecycle submit maps publish eligibility rejection to stable Chinese message', async () => {
  const service = createService({
    serverClient: {
      async post() {
        throw createAxiosError(
          403,
          'AUTH_PERMISSION_INSUFFICIENT',
          'Current organization certification is not approved for project create.',
          { reason: 'certification_not_approved' },
        );
      },
    },
  });

  await assert.rejects(
    () => service.submitProject({ projectId: 'project-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(error.getResponse().code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(error.getResponse().message, '当前组织认证尚未通过，暂不可提交项目。');
      return true;
    },
  );
});

test('project edit/detail maps missing organization scope to stable Chinese message', async () => {
  const service = createService({
    serverClient: {
      async get() {
        throw createAxiosError(
          403,
          'AUTH_PERMISSION_INSUFFICIENT',
          'Current actor lacks the required organization scope for project create.',
          { reason: 'organization_scope_missing' },
        );
      },
    },
  });

  await assert.rejects(
    () => service.getProjectEditDetail('project-1', {}),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(error.getResponse().code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(
        error.getResponse().message,
        '当前组织身份不可用，请先进入可发布项目的组织后再操作。',
      );
      return true;
    },
  );
});
