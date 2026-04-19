const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  RatingErrorService,
} = require('../dist/apps/bff/src/routes/rating/rating-error.service.js');
const {
  RatingService,
} = require('../dist/apps/bff/src/routes/rating/rating.service.js');
const {
  MyProjectService,
} = require('../dist/apps/bff/src/routes/my_project/my-project.service.js');

function createService({ onGet, onPost } = {}) {
  return new RatingService(
    {
      async get(path, options) {
        return onGet(path, options);
      },
      async post(path, payload, options) {
        return onPost(path, payload, options);
      },
    },
    {
      buildForwardHeaders() {
        return { authorization: 'Bearer smoke' };
      },
    },
    new RatingErrorService(new ErrorNormalizerService()),
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

function createMyProjectService() {
  return new MyProjectService(
    { async get() { throw new Error('not used'); } },
    { buildForwardHeaders() { return {}; } },
    { toHttpException(error) { return error; } },
  );
}

test('rating/entry forwards canonical orderId query and passes through entry carrier', async () => {
  let capturedParams = null;
  const service = createService({
    async onGet(path, options) {
      assert.equal(path, '/server/rating/entry');
      capturedParams = options.params;
      return {
        ratingId: 'rating-1',
        orderId: 'order-1',
        state: 'eligible',
        summary: {
          heading: '当前评价入口已就绪，可继续提交最小评价真值。',
        },
      };
    },
  });

  const result = await service.getRatingEntry('order-1', {});
  assert.deepEqual(capturedParams, { orderId: 'order-1' });
  assert.deepEqual(result, {
    ratingId: 'rating-1',
    orderId: 'order-1',
    state: 'eligible',
    summary: {
      heading: '当前评价入口已就绪，可继续提交最小评价真值。',
    },
  });
});

test('rating/entry fails closed on missing orderId and does not call upstream', async () => {
  let called = false;
  const service = createService({
    async onGet() {
      called = true;
      throw new Error('should not call upstream');
    },
  });

  await assert.rejects(
    () => service.getRatingEntry(undefined, {}),
    (error) => {
      assert.equal(called, false);
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'RATING_ENTRY_UNAVAILABLE');
      assert.equal(
        error.getResponse().message,
        '当前评价入口暂不可用，请稍后再试。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('rating/submit only forwards canonical orderId payload and passes through accepted carrier', async () => {
  let capturedPayload = null;
  const service = createService({
    async onPost(path, payload) {
      assert.equal(path, '/server/rating/submit');
      capturedPayload = payload;
      return {
        ratingId: 'rating-1',
        orderId: 'order-1',
        state: 'submitted',
        summary: {
          heading: '当前评价提交已受理，后续仍以项目私域真值为准。',
        },
      };
    },
  });

  const result = await service.submitRating(
    { orderId: 'order-1', score: 5, extraFlag: true },
    {},
  );
  assert.deepEqual(capturedPayload, { orderId: 'order-1' });
  assert.deepEqual(result, {
    ratingId: 'rating-1',
    orderId: 'order-1',
    state: 'submitted',
    summary: {
      heading: '当前评价提交已受理，后续仍以项目私域真值为准。',
    },
  });
});

test('rating/submit rejects missing orderId locally with stable invalid code', async () => {
  const service = createService({
    async onPost() {
      throw new Error('should not call upstream');
    },
  });

  await assert.rejects(
    () => service.submitRating({}, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'RATING_SUBMIT_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前评价提交参数无效，请检查后再试。',
      );
      return true;
    },
  );
});

test('rating/submit preserves stable invalid-state semantics and strips upstream details', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        409,
        'RATING_INVALID_STATE',
        'Current rating state does not allow submit.',
      );
    },
  });

  await assert.rejects(
    () => service.submitRating({ orderId: 'order-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'RATING_INVALID_STATE');
      assert.equal(
        error.getResponse().message,
        '当前评价状态暂不支持提交。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('rating fallout keeps my-project read-side carrier aligned', () => {
  const myProjectService = createMyProjectService();
  const myProjectDetail = myProjectService.toMyProjectDetailReadModel({
    publicProject: {
      projectId: 'project-1',
      projectNo: 'PJT-001',
      title: '春季品牌展项目',
      exhibitionName: '中国建博会',
      brandName: '品牌A',
      buildingType: 'exhibition',
      budgetAmount: 120000,
      areaSqm: 36,
      provinceCode: '310000',
      provinceName: '上海市',
      cityCode: '310100',
      cityName: '上海市',
      plannedStartAt: '2026-05-01',
      plannedEndAt: '2026-05-03',
      state: 'published',
      summary: { heading: '项目已发布', stateLabel: '已发布' },
      buildingTypeRemark: null,
      districtCode: null,
      districtName: null,
      detailAddress: null,
      scopeSummary: null,
      scheduleDetail: null,
      description: null,
      viewerProjectRelation: 'owner',
    },
    privateProgress: {
      hasAcceptedOrder: true,
      orderStatus: 'completed',
      contractStatus: 'active',
      fulfillmentStatus: 'completed',
      acceptanceStatus: 'completed',
      afterSalesOrDisputeStatus: null,
      formalCompletionStatus: 'formally_completed',
      evaluationStatus: 'submitted',
    },
  });
  assert.equal(myProjectDetail.privateProgress.evaluationStatus, 'submitted');
});
