const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId) {
  return {
    authorization: 'Bearer carrier',
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

test('organization write truth rejects 000000 placeholder administrative codes', async () => {
  const { OrganizationWriteService } = require('../dist/modules/organization/organization-write.service.js');

  const service = new OrganizationWriteService(
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
  );

  assert.throws(
    () =>
      service.toCreateCommand({
        name: '测试企业',
        organizationType: 'supplier',
        provinceCode: '000000',
        cityCode: '510100',
        contactName: '张三',
        contactMobile: '13800000000',
        uscc: null,
        businessLicenseFileId: null,
        intro: null,
      }),
    (error) => error?.response?.code === 'ORG_CREATE_INVALID',
  );

  assert.throws(
    () =>
      service.toUpdateCurrentCommand({
        name: '测试企业',
        provinceCode: '510000',
        cityCode: '000000',
        contactName: '张三',
        contactMobile: '13800000000',
        intro: null,
      }),
    (error) => error?.response?.code === 'ORG_UPDATE_INVALID',
  );
});

test('certification OCR recognize persists address and establishedAt into the latest certification truth', async () => {
  const { ProfileCertificationOcrService } = require('../dist/modules/profile/profile-certification-ocr.service.js');
  const { ProfilePresenter } = require('../dist/modules/profile/profile.presenter.js');
  const saved = [];
  const currentCertification = {
    id: 'cert-1',
    organizationId: 'org-1',
    licenseFileId: 'license-1',
    address: null,
    establishedAt: null,
  };

  const service = new ProfileCertificationOcrService(
    {
      async findOneBy() {
        return null;
      },
    },
    {
      async findOne() {
        return currentCertification;
      },
      async save(value) {
        saved.push({ ...value });
        Object.assign(currentCertification, value);
        return value;
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
            organizationId: 'org-1',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireOrganizationAdmin(currentSession, organizationId) {
        assert.equal(currentSession.organizationId, 'org-1');
        assert.equal(organizationId, 'org-1');
        return {
          organization: { id: 'org-1' },
          membership: { roleKey: 'supplier_admin' },
        };
      },
    },
    {},
    {},
    new ProfilePresenter(),
  );

  service.recognizeLicenseForOrganization = async () => ({
    status: 'recognized',
    message: 'recognized',
    legalName: '测试企业',
    uscc: '91310000TEST00001',
    legalPerson: null,
    businessType: null,
    address: '成都市高新区天府大道 1 号',
    registeredCapital: null,
    establishedAt: '2020年4月9日',
    businessTerm: null,
    businessScope: null,
    providerRequestId: 'ocr-1',
  });

  const result = await service.recognizeLicense(
    {
      organizationId: 'org-1',
      licenseFileId: 'license-1',
    },
    createContext('cert-ocr-repair'),
  );

  assert.equal(saved.length, 1);
  assert.equal(saved[0].address, '成都市高新区天府大道 1 号');
  assert.equal(saved[0].establishedAt, '2020-04-09');
  assert.equal(result.address, '成都市高新区天府大道 1 号');
  assert.equal(result.establishedAt, '2020年4月9日');
});

test('enterprise workbench basic falls back to certification truth for foundedAt and address', async () => {
  const { EnterpriseHubWorkbenchPresenter } = require('../dist/modules/enterprise_hub/enterprise-hub-workbench.presenter.js');
  const { EnterpriseHubLocationService } = require('../dist/modules/enterprise_hub/enterprise-hub-location.service.js');

  const presenter = new EnterpriseHubWorkbenchPresenter(
    new EnterpriseHubLocationService(
      { async verifyCurrentSessionContext() { return null; } },
      { async requireAuthenticatedActor() { return null; }, async getCurrentOrganizationScope() { return null; } },
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
    ),
  );
  const response = presenter.toResponse({
    organizationId: 'org-1',
    boardType: 'company',
    listing: {
      id: 'enterprise-1',
      primaryBoardType: 'company',
      name: '测试企业',
      logoFileAssetId: null,
      coverFileAssetId: null,
      shortIntro: '一句话简介',
      fullIntro: null,
      provinceCode: '510000',
      provinceName: '四川省',
      cityCode: '510100',
      cityName: '成都市',
      address: null,
      foundedAt: null,
      teamSizeRange: null,
      cooperationModes: [],
      contactVisible: true,
    },
    latestApplication: null,
    company: null,
    factory: null,
    supplier: null,
    cases: [],
    primaryContact: null,
    certification: {
      certificationStatus: 'approved',
      legalName: '测试企业',
      uscc: '91310000TEST00001',
      licenseFileId: 'license-1',
      address: '成都市高新区天府大道 1 号',
      establishedAt: '2020-04-09',
      submittedAt: new Date('2026-04-10T08:00:00.000Z'),
      reviewedAt: new Date('2026-04-10T09:00:00.000Z'),
      rejectReason: null,
    },
    readiness: {
      hasApplication: true,
      draftEditable: true,
      basicCompleted: true,
      profileCompleted: true,
      hasCase: false,
      hasContact: true,
      certificationApproved: true,
      submitReady: true,
      blockers: [],
    },
  });

  assert.equal(response.basic.address, '成都市高新区天府大道 1 号');
  assert.equal(response.basic.foundedAt, '2020-04-09');
  assert.equal(response.certification.address, '成都市高新区天府大道 1 号');
  assert.equal(response.certification.establishedAt, '2020-04-09');
});
