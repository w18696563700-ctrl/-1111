const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  AppEnterpriseHubController,
} = require('../dist/apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.js');
const {
  EnterpriseHubController,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.js');
const {
  EnterpriseHubPublishedChangeService,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub-published-change.service.js');

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

function createService(overrides = {}) {
  return new EnterpriseHubPublishedChangeService(
    {
      async get(path, options) {
        return overrides.onGet(path, options);
      },
      async put(path, payload, options) {
        return overrides.onPut(path, payload, options);
      },
      async post(path, payload, options) {
        return overrides.onPost(path, payload, options);
      },
      async delete(path, options) {
        return overrides.onDelete(path, options);
      },
    },
    new ErrorNormalizerService(),
    {
      async buildCommandHeaders() {
        return {
          authorization: 'Bearer smoke',
          'x-organization-id': 'org-smoke',
        };
      },
    },
  );
}

test('app-facing and internal controllers both expose the full changes/current family', async () => {
  const calls = [];
  const publishedChangeService = {
    async getCurrentChange(enterpriseId, headers) {
      calls.push(['getCurrentChange', enterpriseId, headers]);
      return { enterpriseId };
    },
    async updateCurrentBasic(enterpriseId, payload, headers) {
      calls.push(['updateCurrentBasic', enterpriseId, payload, headers]);
      return { ok: true };
    },
    async updateCurrentCompanyProfile(enterpriseId, payload, headers) {
      calls.push(['updateCurrentCompanyProfile', enterpriseId, payload, headers]);
      return { ok: true };
    },
    async updateCurrentFactoryProfile(enterpriseId, payload, headers) {
      calls.push(['updateCurrentFactoryProfile', enterpriseId, payload, headers]);
      return { ok: true };
    },
    async updateCurrentSupplierProfile(enterpriseId, payload, headers) {
      calls.push(['updateCurrentSupplierProfile', enterpriseId, payload, headers]);
      return { ok: true };
    },
    async createCurrentCase(enterpriseId, payload, headers) {
      calls.push(['createCurrentCase', enterpriseId, payload, headers]);
      return { caseId: 'case-1', caseStatus: 'draft' };
    },
    async updateCurrentCase(enterpriseId, caseId, payload, headers) {
      calls.push(['updateCurrentCase', enterpriseId, caseId, payload, headers]);
      return { caseId, caseStatus: 'draft' };
    },
    async deleteCurrentCase(enterpriseId, caseId, headers) {
      calls.push(['deleteCurrentCase', enterpriseId, caseId, headers]);
      return { ok: true };
    },
    async submitCurrentChange(enterpriseId, payload, headers) {
      calls.push(['submitCurrentChange', enterpriseId, payload, headers]);
      return { ok: true };
    },
    async getCurrentChangeStatus(enterpriseId, headers) {
      calls.push(['getCurrentChangeStatus', enterpriseId, headers]);
      return { enterpriseId, changeStatus: 'draft' };
    },
  };
  const appController = new AppEnterpriseHubController(
    {},
    {},
    publishedChangeService,
    {},
  );
  const bffController = new EnterpriseHubController(
    {},
    {},
    publishedChangeService,
    {},
  );

  await appController.getCurrentChange('ent-1', { a: '1' });
  await appController.updateCurrentChangeBasic('ent-1', { name: 'A' }, { h: '1' });
  await appController.updateCurrentChangeCompanyProfile('ent-1', { exhibitionTypes: ['x'] }, { h: '2' });
  await appController.updateCurrentChangeFactoryProfile('ent-1', { processTypes: ['p'], coreProducts: ['c'] }, { h: '3' });
  await appController.updateCurrentChangeSupplierProfile('ent-1', { supplyCategories: ['s'], supplyMode: ['m'], coreProductsOrServices: ['x'] }, { h: '4' });
  await appController.createCurrentChangeCase('ent-1', { title: 't', summary: 's' }, { h: '5' });
  await appController.updateCurrentChangeCase('ent-1', 'case-1', { title: 't', summary: 's' }, { h: '6' });
  await appController.deleteCurrentChangeCase('ent-1', 'case-1', { h: '7' });
  await appController.submitCurrentChange('ent-1', { confirm: true }, { h: '8' });
  await appController.getCurrentChangeStatus('ent-1', { h: '9' });

  await bffController.getCurrentChange('ent-2', { a: '2' });
  await bffController.getCurrentChangeStatus('ent-2', { a: '3' });

  assert.equal(calls.length, 12);
  assert.deepEqual(calls[0], ['getCurrentChange', 'ent-1', { a: '1' }]);
  assert.deepEqual(calls[9], ['getCurrentChangeStatus', 'ent-1', { h: '9' }]);
  assert.deepEqual(calls[10], ['getCurrentChange', 'ent-2', { a: '2' }]);
  assert.deepEqual(calls[11], ['getCurrentChangeStatus', 'ent-2', { a: '3' }]);
});

test('getCurrentChange only performs canonical read transport and preserves approved without fabricating current carrier', async () => {
  const calls = [];
  const service = createService({
    async onGet(path, options) {
      calls.push(['get', path, options]);
      return {
        enterpriseId: 'enterprise-1',
        boardType: 'factory',
        liveSnapshot: {
          enterpriseStatus: 'published',
          displayStatus: 'visible',
          publishedAt: '2026-04-12T10:00:00.000Z',
        },
        currentChangeRequest: {
          changeRequestId: 'change-1',
          changeStatus: 'approved',
          submittedAt: '2026-04-12T10:01:00.000Z',
          reviewedAt: '2026-04-12T10:02:00.000Z',
          rejectionReason: null,
        },
        basic: {},
        boardProfile: {},
        primaryContact: null,
        cases: [],
        changeReadiness: {
          draftEditable: false,
          submitReady: false,
          blockers: ['已审核通过，等待 apply。'],
        },
      };
    },
    async onPut() {
      throw new Error('GET current should not call put');
    },
    async onPost() {
      throw new Error('GET current should not call post');
    },
    async onDelete() {
      throw new Error('GET current should not call delete');
    },
  });

  const result = await service.getCurrentChange('enterprise-1', {});

  assert.deepEqual(calls, [
    [
      'get',
      '/server/exhibition/enterprise-hub/enterprises/enterprise-1/changes/current',
      {
        headers: {
          authorization: 'Bearer smoke',
          'x-organization-id': 'org-smoke',
        },
      },
    ],
  ]);
  assert.equal(result.enterpriseId, 'enterprise-1');
  assert.equal(result.currentChangeRequest.changeStatus, 'approved');
  assert.equal(result.changeReadiness.draftEditable, false);
});

test('status surface preserves approved and applied as distinct states', async () => {
  const service = createService({
    async onGet(path) {
      if (path.endsWith('/status')) {
        return {
          enterpriseId: 'enterprise-1',
          changeRequestId: 'change-2',
          changeStatus: 'applied',
          submittedAt: '2026-04-12T10:00:00.000Z',
          reviewedAt: '2026-04-12T11:00:00.000Z',
          rejectionReason: null,
        };
      }
      throw new Error('unexpected path');
    },
    async onPut() {
      throw new Error('not used');
    },
    async onPost() {
      throw new Error('not used');
    },
    async onDelete() {
      throw new Error('not used');
    },
  });

  const status = await service.getCurrentChangeStatus('enterprise-1', {});
  assert.equal(status.changeStatus, 'applied');
  assert.notEqual(status.changeStatus, 'approved');
});

test('published change surface maps not available and invalid state without redefining governance truth', async () => {
  const service = createService({
    async onGet() {
      throw createAxiosError(
        400,
        'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE',
        'Enterprise hub published change request is unavailable for the governed corridor.',
      );
    },
    async onPut() {
      throw new Error('not used');
    },
    async onPost(path) {
      if (path.endsWith('/submit')) {
        throw createAxiosError(
          409,
          'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
          'Enterprise hub published change request is not reviewable in its current state.',
        );
      }
      throw new Error('unexpected path');
    },
    async onDelete() {
      throw new Error('not used');
    },
  });

  await assert.rejects(
    () => service.getCurrentChange('enterprise-1', {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(
        error.getResponse().code,
        'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE',
      );
      assert.equal(
        error.getResponse().message,
        '当前企业展示暂不支持进入正式修改通道。',
      );
      return true;
    },
  );

  await assert.rejects(
    () => service.submitCurrentChange('enterprise-1', { confirm: true }, {}),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(
        error.getResponse().code,
        'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
      );
      assert.equal(
        error.getResponse().message,
        '当前企业展示修改状态暂不支持提交，请刷新后再试。',
      );
      return true;
    },
  );
});

test('published change case create rejects boardType in corridor payload', async () => {
  const service = createService({
    async onGet() {
      throw new Error('not used');
    },
    async onPut() {
      throw new Error('not used');
    },
    async onPost() {
      throw new Error('boardType rejection should fail before upstream post');
    },
    async onDelete() {
      throw new Error('not used');
    },
  });

  await assert.rejects(
    () =>
      service.createCurrentCase(
        'enterprise-1',
        {
          boardType: 'factory',
          title: '案例标题',
          summary: '案例摘要',
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(
        error.getResponse().code,
        'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
      );
      assert.equal(
        error.getResponse().message,
        '当前正式修改通道新增案例不接受 boardType，请直接填写案例内容。',
      );
      return true;
    },
  );
});
