const test = require('node:test');
const assert = require('node:assert/strict');

const {
  AppEnterpriseHubCompanyController,
  AppEnterpriseHubSupplierController,
  EnterpriseHubFactoryController,
} = require('../dist/apps/bff/src/routes/enterprise_hub/enterprise-hub-board-scoped.controller.js');

test('board-scoped alias controllers forward fixed board identity and preserve shared services', async () => {
  const calls = [];
  const enterpriseHubService = {
    async listEnterprisesForBoard(headers, boardType, query) {
      calls.push(['listEnterprisesForBoard', boardType, headers, query]);
      return { items: [] };
    },
    async getEnterpriseDetailForBoard(enterpriseId, boardType, headers) {
      calls.push(['getEnterpriseDetailForBoard', enterpriseId, boardType, headers]);
      return { enterpriseId, boardType };
    },
    async getRecommendationsForBoard(headers, boardType) {
      calls.push(['getRecommendationsForBoard', boardType, headers]);
      return { boardType, items: [] };
    },
    async ensureShellForBoard(boardType, payload, headers) {
      calls.push(['ensureShellForBoard', boardType, payload, headers]);
      return { boardType, shellStatus: 'created' };
    },
    async createApplicationForBoard(boardType, payload, headers) {
      calls.push(['createApplicationForBoard', boardType, payload, headers]);
      return { boardType, applicationStatus: 'draft' };
    },
    async resolveLocation(payload, headers) {
      calls.push(['resolveLocation', payload, headers]);
      return { ok: true };
    },
    async updateBasic(enterpriseId, payload, headers) {
      calls.push(['updateBasic', enterpriseId, payload, headers]);
      return { ok: true };
    },
    async updateCompanyProfile(enterpriseId, payload, headers) {
      calls.push(['updateCompanyProfile', enterpriseId, payload, headers]);
      return { ok: true };
    },
    async updateFactoryProfile(enterpriseId, payload, headers) {
      calls.push(['updateFactoryProfile', enterpriseId, payload, headers]);
      return { ok: true };
    },
    async updateSupplierProfile(enterpriseId, payload, headers) {
      calls.push(['updateSupplierProfile', enterpriseId, payload, headers]);
      return { ok: true };
    },
    async createCaseForBoard(enterpriseId, boardType, payload, headers) {
      calls.push(['createCaseForBoard', enterpriseId, boardType, payload, headers]);
      return { caseId: 'case-1', caseStatus: 'draft' };
    },
    async getCaseDetail(caseId, headers) {
      calls.push(['getCaseDetail', caseId, headers]);
      return { caseId };
    },
    async getPublicCaseDetail(caseId, headers) {
      calls.push(['getPublicCaseDetail', caseId, headers]);
      return { caseId };
    },
    async updateCase(caseId, payload, headers) {
      calls.push(['updateCase', caseId, payload, headers]);
      return { caseId, caseStatus: 'draft' };
    },
    async deleteCase(caseId, headers) {
      calls.push(['deleteCase', caseId, headers]);
      return { ok: true };
    },
    async deleteEnterprise(enterpriseId, headers) {
      calls.push(['deleteEnterprise', enterpriseId, headers]);
      return { ok: true };
    },
    async submitApplication(applicationId, payload, headers) {
      calls.push(['submitApplication', applicationId, payload, headers]);
      return { ok: true };
    },
    async getApplicationStatus(applicationId, headers) {
      calls.push(['getApplicationStatus', applicationId, headers]);
      return { applicationId };
    },
  };
  const enterpriseHubFormalInfoService = {
    async getTargetEnterpriseFormalInfo(enterpriseId, headers) {
      calls.push(['getTargetEnterpriseFormalInfo', enterpriseId, headers]);
      return { enterpriseId };
    },
  };
  const enterpriseHubPublishedChangeService = {
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
      return { caseId: 'case-1' };
    },
    async updateCurrentCase(enterpriseId, caseId, payload, headers) {
      calls.push(['updateCurrentCase', enterpriseId, caseId, payload, headers]);
      return { caseId };
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
  const enterpriseHubWorkbenchService = {
    async getWorkbench(headers, boardType) {
      calls.push(['getWorkbench', boardType, headers]);
      return { boardType };
    },
  };

  const appCompanyController = new AppEnterpriseHubCompanyController(
    enterpriseHubService,
    enterpriseHubFormalInfoService,
    enterpriseHubPublishedChangeService,
    enterpriseHubWorkbenchService,
  );
  const internalFactoryController = new EnterpriseHubFactoryController(
    enterpriseHubService,
    enterpriseHubFormalInfoService,
    enterpriseHubPublishedChangeService,
    enterpriseHubWorkbenchService,
  );
  const appSupplierController = new AppEnterpriseHubSupplierController(
    enterpriseHubService,
    enterpriseHubFormalInfoService,
    enterpriseHubPublishedChangeService,
    enterpriseHubWorkbenchService,
  );

  await appCompanyController.getWorkbench({ req: '1' });
  await appCompanyController.listEnterprises({ req: '2' }, '木作', '510000', '510100', undefined, '1', '10');
  await appCompanyController.getEnterpriseDetail('enterprise-1', { req: '3' });
  await appCompanyController.getRecommendations({ req: '4' });
  await appCompanyController.ensureShell({}, { req: '5' });
  await appCompanyController.createApplication(
    { applicantName: '张三', applicantMobile: '13800000000' },
    { req: '6' },
  );
  await appCompanyController.updateBoardProfile(
    'enterprise-1',
    { exhibitionTypes: ['特装'], serviceItems: ['搭建'], serviceCities: ['成都'] },
    { req: '7' },
  );
  await appCompanyController.createCase(
    'enterprise-1',
    { title: '案例', summary: '摘要' },
    { req: '8' },
  );
  await appCompanyController.getCurrentChange('enterprise-1', { req: '9' });
  await appCompanyController.updateCurrentChangeBoardProfile(
    'enterprise-1',
    { exhibitionTypes: ['特装'], serviceItems: ['搭建'], serviceCities: ['成都'] },
    { req: '10' },
  );

  await internalFactoryController.ensureShell({}, { req: '11' });
  await internalFactoryController.createApplication(
    { applicantName: '李四', applicantMobile: '13900000000' },
    { req: '12' },
  );
  await internalFactoryController.updateBoardProfile(
    'enterprise-2',
    { processTypes: ['喷涂'], coreProducts: ['木作'] },
    { req: '13' },
  );
  await internalFactoryController.updateCurrentChangeBoardProfile(
    'enterprise-2',
    { processTypes: ['喷涂'], coreProducts: ['木作'] },
    { req: '14' },
  );

  await appSupplierController.createCase(
    'enterprise-3',
    { title: '供应商案例', summary: '摘要' },
    { req: '15' },
  );

  assert.deepEqual(calls[0], ['getWorkbench', 'company', { req: '1' }]);
  assert.deepEqual(calls[1], [
    'listEnterprisesForBoard',
    'company',
    { req: '2' },
    {
      keyword: '木作',
      provinceCode: '510000',
      cityCode: '510100',
      plantAreaRange: undefined,
      page: '1',
      pageSize: '10',
    },
  ]);
  assert.deepEqual(calls[4], ['ensureShellForBoard', 'company', {}, { req: '5' }]);
  assert.deepEqual(calls[5], [
    'createApplicationForBoard',
    'company',
    { applicantName: '张三', applicantMobile: '13800000000' },
    { req: '6' },
  ]);
  assert.deepEqual(calls[6][0], 'updateCompanyProfile');
  assert.deepEqual(calls[7], [
    'createCaseForBoard',
    'enterprise-1',
    'company',
    { title: '案例', summary: '摘要' },
    { req: '8' },
  ]);
  assert.deepEqual(calls[9][0], 'updateCurrentCompanyProfile');
  assert.deepEqual(calls[10], ['ensureShellForBoard', 'factory', {}, { req: '11' }]);
  assert.deepEqual(calls[11][0], 'createApplicationForBoard');
  assert.deepEqual(calls[12][0], 'updateFactoryProfile');
  assert.deepEqual(calls[13][0], 'updateCurrentFactoryProfile');
  assert.deepEqual(calls[14], [
    'createCaseForBoard',
    'enterprise-3',
    'supplier',
    { title: '供应商案例', summary: '摘要' },
    { req: '15' },
  ]);
});
