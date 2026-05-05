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

test('business license OCR preview ignores QRCode-like businessType noise but keeps valid enterprise-type hints', async () => {
  const { ContentSafetyOcrService } = require('../dist/modules/content_safety/content-safety-ocr.service.js');

  const service = new ContentSafetyOcrService({
    aliyunOcrEnabled: false,
    aliyunOcrAccessKeyId: '',
    aliyunOcrAccessKeySecret: '',
    aliyunOcrEndpoint: '',
  });

  const noisy = service.parseBusinessLicenseData(
    JSON.stringify({
      type: 'QRCode',
      companyName: '测试企业',
      creditCode: '91310000TEST000001',
    }),
  );
  assert.equal(noisy.businessType, null);

  const valid = service.parseBusinessLicenseData(
    JSON.stringify({
      companyType: '有限责任公司(自然人投资或控股)',
      companyName: '测试企业',
      creditCode: '91310000TEST000001',
    }),
  );
  assert.equal(valid.businessType, '有限责任公司(自然人投资或控股)');
});

test('certification submit persists the expanded formal truth fields from business-license OCR', async () => {
  const { ProfileCertificationWriteService } = require('../dist/modules/profile/profile-certification-write.service.js');
  const { ProfilePresenter } = require('../dist/modules/profile/profile.presenter.js');

  const savedOrganizations = [];
  const savedCertifications = [];
  const savedAudits = [];
  const initializedPostures = [];
  const organization = {
    id: 'org-1',
    status: 'draft',
    uscc: null,
    businessLicenseFileId: null,
    contactName: null,
    contactMobile: null,
  };

  const service = new ProfileCertificationWriteService(
    { findOneBy: async () => organization },
    {},
    { findOneBy: async () => ({ id: 'license-1', organizationId: 'org-1' }) },
    {
      async transaction(callback) {
        const repositories = new Map([
          [
            'OrganizationEntity',
            {
              async findOneBy() {
                return organization;
              },
              async save(value) {
                savedOrganizations.push({ ...value });
                Object.assign(organization, value);
                return value;
              },
            },
          ],
          [
            'OrganizationCertificationEntity',
            {
              async findOne() {
                return null;
              },
              create(value) {
                return { ...value };
              },
              async save(value) {
                savedCertifications.push({ ...value });
                return value;
              },
            },
          ],
          [
            'IdentityAuditLogEntity',
            {
              create(value) {
                return { ...value };
              },
              async save(value) {
                savedAudits.push({ ...value });
                return value;
              },
            },
          ],
        ]);
        return callback({
          getRepository(entity) {
            return repositories.get(entity.name);
          },
        });
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'actor-1',
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
    {
      async recognizeLicenseForOrganization() {
        return {
          status: 'recognized',
          message: 'recognized',
          legalName: '测试企业',
          uscc: '91310000TEST000001',
          legalPerson: '张三',
          businessType: '有限责任公司',
          address: '成都市高新区天府大道 1 号',
          registeredCapital: '100 万元',
          establishedAt: '2020年4月9日',
          businessTerm: '长期',
          businessScope: '展览服务',
          providerRequestId: 'ocr-1',
        };
      },
    },
    new ProfilePresenter(),
    {
      async syncOrganizationListings() {},
    },
    {
      async ensureDefaultPosturesForApprovedOrganization(organizationId) {
        initializedPostures.push(organizationId);
        return {
          eligible: true,
          organizationId,
          createdFamilies: ['credit', 'deposit', 'transaction_guarantee'],
          existingFamilies: [],
        };
      },
    },
  );

  const result = await service.submit(
    {
      organizationId: 'org-1',
      legalName: '测试企业',
      uscc: '91310000TEST000001',
      licenseFileId: 'license-1',
      contactName: '张三',
      contactMobile: '13800000000',
    },
    createContext('cert-submit'),
  );

  assert.equal(result.certificationStatus, 'approved');
  assert.equal(savedCertifications.length, 1);
  assert.equal(savedCertifications[0].legalName, '测试企业');
  assert.equal(savedCertifications[0].uscc, '91310000TEST000001');
  assert.equal(savedCertifications[0].licenseFileId, 'license-1');
  assert.equal(savedCertifications[0].address, '成都市高新区天府大道 1 号');
  assert.equal(savedCertifications[0].establishedAt, '2020-04-09');
  assert.equal(savedCertifications[0].legalPerson, '张三');
  assert.equal(savedCertifications[0].businessType, '有限责任公司');
  assert.equal(savedCertifications[0].registeredCapital, '100 万元');
  assert.equal(savedCertifications[0].businessTerm, '长期');
  assert.equal(savedCertifications[0].businessScope, '展览服务');
  assert.equal(savedAudits.length, 1);
  assert.deepEqual(initializedPostures, ['org-1']);
});

test('certification current returns the expanded formal truth fields', async () => {
  const { ProfilePresenter } = require('../dist/modules/profile/profile.presenter.js');

  const presenter = new ProfilePresenter();
  const result = presenter.toCurrentCertification({
    organizationId: 'org-1',
    certificationStatus: 'approved',
    legalName: '测试企业',
    uscc: '91310000TEST000001',
    licenseFileId: 'license-1',
    address: '成都市高新区天府大道 1 号',
    establishedAt: '2020-04-09',
    legalPerson: '张三',
    businessType: '有限责任公司',
    registeredCapital: '100 万元',
    businessTerm: '长期',
    businessScope: '展览服务',
    rejectReason: null,
    expiresAt: null,
    submittedAt: new Date('2026-04-10T10:00:00.000Z'),
  });

  assert.deepEqual(Object.keys(result).sort(), [
    'address',
    'businessScope',
    'businessTerm',
    'businessType',
    'certificationStatus',
    'establishedAt',
    'expiresAt',
    'legalName',
    'legalPerson',
    'licenseFileId',
    'organizationId',
    'personalCertification',
    'registeredCapital',
    'rejectReason',
    'submittedAt',
    'uscc',
  ]);
  assert.equal(result.businessType, '有限责任公司');
  assert.equal(result.legalPerson, '张三');
  assert.equal(result.registeredCapital, '100 万元');
  assert.equal(result.businessTerm, '长期');
  assert.equal(result.businessScope, '展览服务');
});
