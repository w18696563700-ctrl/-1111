const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  TradingShellHandoffErrorService,
} = require('../dist/apps/bff/src/routes/trading_shell_handoff/trading-shell-handoff.error.service.js');
const {
  TradingShellHandoffService,
} = require('../dist/apps/bff/src/routes/trading_shell_handoff/trading-shell-handoff.service.js');
const {
  readContractDetailViewModel,
} = require('../dist/apps/bff/src/routes/trading_read_corridor/trading-read-corridor.read-model.js');
const {
  MyProjectService,
} = require('../dist/apps/bff/src/routes/my_project/my-project.service.js');

function createService({ onPost } = {}) {
  return new TradingShellHandoffService(
    {
      async post(path, payload, options) {
        return onPost(path, payload, options);
      },
    },
    {
      buildForwardHeaders() {
        return { authorization: 'Bearer smoke' };
      },
    },
    new TradingShellHandoffErrorService(new ErrorNormalizerService()),
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
    {
      async get() {
        throw new Error('not used');
      },
    },
    {
      buildForwardHeaders() {
        return {};
      },
    },
    {
      toHttpException(error) {
        return error;
      },
    },
  );
}

test('milestone/submit strips upstream details while keeping stable invalid code and message', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        400,
        'MILESTONE_SUBMIT_INVALID',
        'Field `milestoneId` is required for milestone submit.',
      );
    },
  });

  await assert.rejects(
    () => service.submitMilestone({}, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'MILESTONE_SUBMIT_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前里程碑提交参数无效，请检查后再试。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('inspection/submit strips upstream details while keeping stable unavailable code and message', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        404,
        'AUTH_RESOURCE_UNAVAILABLE',
        'Cannot POST /server/inspection/submit',
      );
    },
  });

  await assert.rejects(
    () => service.submitInspection({ inspectionId: 'inspection-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.equal(error.getResponse().code, 'INSPECTION_ENTRY_UNAVAILABLE');
      assert.equal(
        error.getResponse().message,
        '当前验收提交入口暂不可用，请稍后再试。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('inspection/submit passes through accepted carrier from server truth', async () => {
  const service = createService({
    async onPost() {
      return {
        inspectionId: 'inspection-1',
        milestoneId: 'milestone-1',
        state: 'draft',
        summary: {
          heading: '当前验收提交入口已受理，后续仍以验收详情真值为准。',
        },
      };
    },
  });

  const result = await service.submitInspection({ inspectionId: 'inspection-1' }, {});

  assert.deepEqual(result, {
    inspectionId: 'inspection-1',
    milestoneId: 'milestone-1',
    state: 'draft',
    summary: {
      heading: '当前验收提交入口已受理，后续仍以验收详情真值为准。',
    },
  });
});

test('inspection/recheck passes through accepted carrier from server truth', async () => {
  const service = createService({
    async onPost(path) {
      assert.equal(path, '/server/inspection/recheck');
      return {
        inspectionId: 'inspection-1',
        milestoneId: 'milestone-1',
        state: 'rechecked',
        summary: {
          heading: '当前验收复检已受理，后续仍以验收详情真值为准。',
        },
      };
    },
  });

  const result = await service.recheckInspection({ inspectionId: 'inspection-1' }, {});

  assert.deepEqual(result, {
    inspectionId: 'inspection-1',
    milestoneId: 'milestone-1',
    state: 'rechecked',
    summary: {
      heading: '当前验收复检已受理，后续仍以验收详情真值为准。',
    },
  });
});

test('inspection/recheck only forwards canonical inspectionId payload and rejects missing inspectionId locally', async () => {
  const service = createService({
    async onPost(_path, payload) {
      return {
        inspectionId: payload.inspectionId,
        milestoneId: 'milestone-1',
        state: 'rechecked',
        summary: { heading: 'accepted' },
      };
    },
  });

  const accepted = await service.recheckInspection(
    { inspectionId: 'inspection-1', state: 'submitted', extraFlag: true },
    {},
  );
  assert.deepEqual(accepted, {
    inspectionId: 'inspection-1',
    milestoneId: 'milestone-1',
    state: 'rechecked',
    summary: { heading: 'accepted' },
  });

  await assert.rejects(
    () => service.recheckInspection({ state: 'submitted' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'INSPECTION_RECHECK_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前验收复检参数无效，请检查后再试。',
      );
      return true;
    },
  );
});

test('inspection/recheck strips upstream details while keeping stable invalid code and message', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        400,
        'INSPECTION_RECHECK_INVALID',
        'Field `inspectionId` is required for inspection recheck.',
      );
    },
  });

  await assert.rejects(
    () => service.recheckInspection({}, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'INSPECTION_RECHECK_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前验收复检参数无效，请检查后再试。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('inspection/recheck preserves stable invalid-state semantics', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        409,
        'INSPECTION_INVALID_STATE',
        'Only submitted inspections may continue through recheck handoff.',
      );
    },
  });

  await assert.rejects(
    () => service.recheckInspection({ inspectionId: 'inspection-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'INSPECTION_INVALID_STATE');
      assert.equal(
        error.getResponse().message,
        '当前验收状态暂不支持复检。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('contract/confirm passes through accepted carrier from server truth', async () => {
  let capturedPayload = null;
  const service = createService({
    async onPost(path, payload) {
      assert.equal(path, '/server/contract/confirm');
      capturedPayload = payload;
      return {
        contractId: 'contract-1',
        orderId: 'order-1',
        state: 'active',
        summary: {
          heading: '当前合同确认已受理，后续仍以合同详情真值为准。',
        },
      };
    },
  });

  const result = await service.confirmContract({ orderId: 'order-1' }, {});

  assert.deepEqual(capturedPayload, { orderId: 'order-1' });

  assert.deepEqual(result, {
    contractId: 'contract-1',
    orderId: 'order-1',
    state: 'active',
    summary: {
      heading: '当前合同确认已受理，后续仍以合同详情真值为准。',
    },
  });
});

test('contract/confirm only forwards canonical orderId payload and rejects missing orderId locally', async () => {
  const service = createService({
    async onPost(_path, payload) {
      return {
        contractId: 'contract-1',
        orderId: payload.orderId,
        state: 'active',
        summary: { heading: 'accepted' },
      };
    },
  });

  const accepted = await service.confirmContract(
    { orderId: 'order-1', state: 'pending_confirm', extraFlag: true },
    {},
  );
  assert.deepEqual(accepted, {
    contractId: 'contract-1',
    orderId: 'order-1',
    state: 'active',
    summary: { heading: 'accepted' },
  });

  await assert.rejects(
    () => service.confirmContract({ state: 'pending_confirm' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'CONTRACT_CONFIRM_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前合同确认参数无效，请检查后再试。',
      );
      return true;
    },
  );
});

test('contract/confirm strips upstream details while keeping stable invalid code and message', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        400,
        'CONTRACT_CONFIRM_INVALID',
        'Field `orderId` is required for contract confirm.',
      );
    },
  });

  await assert.rejects(
    () => service.confirmContract({}, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'CONTRACT_CONFIRM_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前合同确认参数无效，请检查后再试。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('contract/confirm preserves stable invalid-state semantics', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        409,
        'CONTRACT_INVALID_STATE',
        'Only pending_confirm contracts may continue through confirm handoff.',
      );
    },
  });

  await assert.rejects(
    () => service.confirmContract({ orderId: 'order-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'CONTRACT_INVALID_STATE');
      assert.equal(
        error.getResponse().message,
        '当前合同状态暂不支持确认。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('contract/amend passes through accepted carrier from server truth', async () => {
  let capturedPayload = null;
  const service = createService({
    async onPost(path, payload) {
      assert.equal(path, '/server/contract/amend');
      capturedPayload = payload;
      return {
        contractId: 'contract-1',
        orderId: 'order-1',
        state: 'amended',
        summary: {
          heading: '当前合同改单已受理，后续仍以合同详情真值为准。',
        },
      };
    },
  });

  const result = await service.amendContract({ orderId: 'order-1' }, {});

  assert.deepEqual(capturedPayload, { orderId: 'order-1' });
  assert.deepEqual(result, {
    contractId: 'contract-1',
    orderId: 'order-1',
    state: 'amended',
    summary: {
      heading: '当前合同改单已受理，后续仍以合同详情真值为准。',
    },
  });
});

test('contract/amend only forwards canonical orderId payload and rejects missing orderId locally', async () => {
  const service = createService({
    async onPost(_path, payload) {
      return {
        contractId: 'contract-1',
        orderId: payload.orderId,
        state: 'amended',
        summary: { heading: 'accepted' },
      };
    },
  });

  const accepted = await service.amendContract(
    { orderId: 'order-1', state: 'active', extraFlag: true },
    {},
  );
  assert.deepEqual(accepted, {
    contractId: 'contract-1',
    orderId: 'order-1',
    state: 'amended',
    summary: { heading: 'accepted' },
  });

  await assert.rejects(
    () => service.amendContract({ state: 'active' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'CONTRACT_AMEND_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前合同改单参数无效，请检查后再试。',
      );
      return true;
    },
  );
});

test('contract/amend strips upstream details while keeping stable invalid code and message', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        400,
        'CONTRACT_AMEND_INVALID',
        'Field `orderId` is required for contract amend.',
      );
    },
  });

  await assert.rejects(
    () => service.amendContract({}, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'CONTRACT_AMEND_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前合同改单参数无效，请检查后再试。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('contract/amend preserves stable invalid-state semantics', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        409,
        'CONTRACT_INVALID_STATE',
        'Only active contracts may continue through amend handoff.',
      );
    },
  });

  await assert.rejects(
    () => service.amendContract({ orderId: 'order-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'CONTRACT_INVALID_STATE');
      assert.equal(
        error.getResponse().message,
        '当前合同状态暂不支持改单。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('contract confirm fallout keeps contract detail and my-project read-side carriers aligned', () => {
  const detail = readContractDetailViewModel({
    contractId: 'contract-1',
    orderId: 'order-1',
    state: 'active',
    summary: {
      heading: '合同已确认生效',
      stateLabel: '当前合同已生效，可继续进入履约。',
    },
  });
  assert.equal(detail.state, 'active');

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
      orderStatus: 'active',
      contractStatus: 'active',
      fulfillmentStatus: null,
      acceptanceStatus: null,
      afterSalesOrDisputeStatus: null,
      formalCompletionStatus: 'not_formally_completed',
      evaluationStatus: 'not_eligible',
    },
  });
  assert.equal(myProjectDetail.privateProgress.contractStatus, 'active');
});

test('contract amend fallout keeps contract detail and my-project read-side carriers aligned', () => {
  const detail = readContractDetailViewModel({
    contractId: 'contract-1',
    orderId: 'order-1',
    state: 'amended',
    summary: {
      heading: '合同已进入改单态',
      stateLabel: '当前合同已改单，可继续保持只读承接。',
    },
  });
  assert.equal(detail.state, 'amended');

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
      orderStatus: 'active',
      contractStatus: 'amended',
      fulfillmentStatus: null,
      acceptanceStatus: null,
      afterSalesOrDisputeStatus: null,
      formalCompletionStatus: 'not_formally_completed',
      evaluationStatus: 'not_eligible',
    },
  });
  assert.equal(myProjectDetail.privateProgress.contractStatus, 'amended');
});

test('dispute/withdraw passes through accepted carrier from server truth', async () => {
  const service = createService({
    async onPost(path) {
      assert.equal(path, '/server/dispute/withdraw');
      return {
        disputeId: 'dispute-1',
        orderId: 'order-1',
        state: 'withdrawn',
        summary: {
          heading: '当前争议撤回已受理，后续仍以项目私域与工作台真值为准。',
        },
      };
    },
  });

  const result = await service.withdrawDispute({ orderId: 'order-1' }, {});

  assert.deepEqual(result, {
    disputeId: 'dispute-1',
    orderId: 'order-1',
    state: 'withdrawn',
    summary: {
      heading: '当前争议撤回已受理，后续仍以项目私域与工作台真值为准。',
    },
  });
});

test('dispute/withdraw only forwards canonical orderId payload and rejects missing orderId locally', async () => {
  const service = createService({
    async onPost(_path, payload) {
      return {
        disputeId: 'dispute-1',
        orderId: payload.orderId,
        state: 'withdrawn',
        summary: { heading: 'accepted' },
      };
    },
  });

  const accepted = await service.withdrawDispute(
    { orderId: 'order-1', state: 'opened', extraFlag: true },
    {},
  );
  assert.deepEqual(accepted, {
    disputeId: 'dispute-1',
    orderId: 'order-1',
    state: 'withdrawn',
    summary: { heading: 'accepted' },
  });

  await assert.rejects(
    () => service.withdrawDispute({ state: 'opened' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'DISPUTE_WITHDRAW_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前争议撤回参数无效，请检查后再试。',
      );
      return true;
    },
  );
});

test('dispute/withdraw preserves stable invalid-state semantics', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        409,
        'DISPUTE_INVALID_STATE',
        'Only opened disputes may continue through withdraw handoff.',
      );
    },
  });

  await assert.rejects(
    () => service.withdrawDispute({ orderId: 'order-1' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'DISPUTE_INVALID_STATE');
      assert.equal(
        error.getResponse().message,
        '当前争议状态暂不支持撤回。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});

test('dispute withdraw fallout keeps my-project read-side carrier aligned', () => {
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
      orderStatus: 'active',
      contractStatus: 'active',
      fulfillmentStatus: 'submitted',
      acceptanceStatus: null,
      afterSalesOrDisputeStatus: 'withdrawn',
      formalCompletionStatus: 'not_formally_completed',
      evaluationStatus: 'not_eligible',
    },
  });
  assert.equal(myProjectDetail.privateProgress.afterSalesOrDisputeStatus, 'withdrawn');
});

test('inspection/submit strips upstream details while keeping stable invalid code and message', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        400,
        'INSPECTION_SUBMIT_INVALID',
        'Field `inspectionId` is required for inspection submit.',
      );
    },
  });

  await assert.rejects(
    () => service.submitInspection({}, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'INSPECTION_SUBMIT_INVALID');
      assert.equal(
        error.getResponse().message,
        '当前验收提交参数无效，请检查后再试。',
      );
      assert.equal(error.getResponse().details, undefined);
      return true;
    },
  );
});
