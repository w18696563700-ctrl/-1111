const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId, overrides = {}) {
  return {
    authorization: 'Bearer session-token',
    actorId: '',
    userId: '',
    organizationId: 'header-only-org',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
    ...overrides,
  };
}

function createRepositories() {
  return {
    listingRepository: {
      async findOneBy() {
        return null;
      },
    },
    applicationRepository: {
      async findOne() {
        return null;
      },
    },
    companyRepository: {
      async findOneBy() {
        return null;
      },
    },
    factoryRepository: {
      async findOneBy() {
        return null;
      },
    },
    supplierRepository: {
      async findOneBy() {
        return null;
      },
    },
    caseRepository: {
      async find() {
        return [];
      },
    },
    contactRepository: {
      async findOneBy() {
        return null;
      },
    },
    organizationCertificationRepository: {
      async findOne() {
        return {
          certificationStatus: 'approved',
          legalName: '测试企业',
          uscc: '91310000TEST00003',
          licenseFileId: 'file-license',
          submittedAt: new Date('2026-04-10T08:00:00.000Z'),
          reviewedAt: new Date('2026-04-10T09:00:00.000Z'),
          rejectReason: null,
        };
      },
    },
  };
}

test('enterprise-hub workbench resolves organization scope from verified current session instead of raw header scope', async () => {
  const { EnterpriseHubWorkbenchQueryService } = require('../dist/modules/enterprise_hub/enterprise-hub-workbench.query.service.js');
  const { EnterpriseHubWorkbenchPresenter } = require('../dist/modules/enterprise_hub/enterprise-hub-workbench.presenter.js');
  const { EnterpriseHubLocationService } = require('../dist/modules/enterprise_hub/enterprise-hub-location.service.js');
  const repos = createRepositories();
  const verificationCalls = [];
  const scopeCalls = [];
  const verificationService = {
    async verifyCurrentSessionContext(context) {
      verificationCalls.push(context);
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'user-1',
          userId: 'user-1',
          organizationId: 'session-org',
          requestId: context.requestId,
          traceId: context.traceId,
        },
      };
    },
  };
  const eligibilityService = {
    async requireAuthenticatedActor(currentSession) {
      assert.equal(currentSession.organizationId, 'session-org');
      return { id: 'user-1', status: 'active' };
    },
    async getCurrentOrganizationScope(currentSession) {
      scopeCalls.push(currentSession);
      return {
        organization: { id: 'scope-org' },
        membership: { roleKey: 'supplier_admin' },
        certification: { certificationStatus: 'approved' },
        roleKeys: ['supplier_admin'],
      };
    },
  };
  const locationService = new EnterpriseHubLocationService(
    verificationService,
    eligibilityService,
    {
      buildMapPreviewUrl() {
        return null;
      },
      buildMapLinkUrl() {
        return null;
      },
      requireProviderConfig() {},
      async geocodeAddress() {
        return null;
      },
      async reverseGeocode() {
        return null;
      },
    },
  );

  const service = new EnterpriseHubWorkbenchQueryService(
    repos.listingRepository,
    repos.applicationRepository,
    repos.companyRepository,
    repos.factoryRepository,
    repos.supplierRepository,
    repos.caseRepository,
    repos.contactRepository,
    repos.organizationCertificationRepository,
    verificationService,
    eligibilityService,
    new EnterpriseHubWorkbenchPresenter(locationService),
  );

  const result = await service.getWorkbench(
    createContext('enterprise-workbench'),
    'company',
  );

  assert.equal(verificationCalls.length, 1);
  assert.equal(scopeCalls.length, 1);
  assert.equal(scopeCalls[0].organizationId, 'session-org');
  assert.equal(result.organizationId, 'scope-org');
  assert.equal(
    result.readiness.blockers[0],
    '当前还没有展示档，请先保存资料或上传图片创建展示档。',
  );
});

test('enterprise-hub workbench fail-closes when verified session does not resolve current organization scope', async () => {
  const { EnterpriseHubWorkbenchQueryService } = require('../dist/modules/enterprise_hub/enterprise-hub-workbench.query.service.js');
  const { EnterpriseHubWorkbenchPresenter } = require('../dist/modules/enterprise_hub/enterprise-hub-workbench.presenter.js');
  const { EnterpriseHubLocationService } = require('../dist/modules/enterprise_hub/enterprise-hub-location.service.js');
  const repos = createRepositories();
  const verificationService = {
    async verifyCurrentSessionContext(context) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'user-1',
          userId: 'user-1',
          organizationId: null,
          requestId: context.requestId,
          traceId: context.traceId,
        },
      };
    },
  };
  const eligibilityService = {
    async requireAuthenticatedActor() {
      return { id: 'user-1', status: 'active' };
    },
    async getCurrentOrganizationScope() {
      return null;
    },
  };
  const locationService = new EnterpriseHubLocationService(
    verificationService,
    eligibilityService,
    {
      buildMapPreviewUrl() {
        return null;
      },
      buildMapLinkUrl() {
        return null;
      },
      requireProviderConfig() {},
      async geocodeAddress() {
        return null;
      },
      async reverseGeocode() {
        return null;
      },
    },
  );

  const service = new EnterpriseHubWorkbenchQueryService(
    repos.listingRepository,
    repos.applicationRepository,
    repos.companyRepository,
    repos.factoryRepository,
    repos.supplierRepository,
    repos.caseRepository,
    repos.contactRepository,
    repos.organizationCertificationRepository,
    verificationService,
    eligibilityService,
    new EnterpriseHubWorkbenchPresenter(locationService),
  );

  await assert.rejects(
    () => service.getWorkbench(createContext('enterprise-workbench-missing'), 'company'),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_PERMISSION_DENIED',
  );
});
