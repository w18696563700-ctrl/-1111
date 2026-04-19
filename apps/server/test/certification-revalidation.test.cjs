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

function hasErrorCode(expectedCode) {
  return (error) => error?.getResponse?.().code === expectedCode;
}

function makeService(options = {}) {
  const { ProfileCertificationRevalidationService } = require('../dist/modules/profile/profile-certification-revalidation.service.js');
  const { ProfilePresenter } = require('../dist/modules/profile/profile.presenter.js');

  const organization =
    options.organization ?? {
      id: 'org-approved-1',
      status: 'active',
      uscc: '91310000123456789A',
      businessLicenseFileId: 'license-old-1',
    };
  const certification =
    options.certification ?? {
      id: 'cert-approved-1',
      organizationId: 'org-approved-1',
      certificationStatus: 'approved',
      legalName: '上海展建服务有限公司',
      uscc: '91310000123456789A',
      licenseFileId: 'license-old-1',
      address: '上海市徐汇区漕溪北路 398 号',
      establishedAt: '2016-03-30',
      legalPerson: '张三',
      businessType: '有限责任公司',
      registeredCapital: '壹佰万元整',
      businessTerm: '长期',
      businessScope: '展览展示服务',
      rejectReason: null,
      expiresAt: null,
      submittedAt: new Date('2026-04-01T09:00:00.000Z'),
      reviewedAt: new Date('2026-04-01T09:00:00.000Z'),
      reviewedBy: null,
      updatedAt: new Date('2026-04-01T09:00:00.000Z'),
      createdAt: new Date('2026-04-01T09:00:00.000Z'),
    };
  const fileAsset =
    options.fileAsset ?? {
      id: 'license-new-1',
      organizationId: 'org-approved-1',
      mimeType: 'image/png',
    };
  const revalidationAttempts = [];
  const audits = [];

  const service = new ProfileCertificationRevalidationService(
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
                Object.assign(organization, value);
                return value;
              },
            },
          ],
          [
            'OrganizationCertificationEntity',
            {
              async findOne() {
                return certification;
              },
              async save(value) {
                Object.assign(certification, value);
                return value;
              },
            },
          ],
          [
            'FileAssetEntity',
            {
              async findOneBy(where) {
                if (where.id !== fileAsset.id) {
                  return null;
                }
                return fileAsset;
              },
            },
          ],
          [
            'OrganizationCertificationRevalidationAttemptEntity',
            {
              async save(value) {
                revalidationAttempts.push({ ...value });
                return value;
              },
            },
          ],
          [
            'IdentityAuditLogEntity',
            {
              async save(value) {
                audits.push({ ...value });
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
            organizationId: 'org-approved-1',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireOrganizationAdmin(currentSession, organizationId) {
        assert.equal(currentSession.organizationId, 'org-approved-1');
        assert.equal(organizationId, 'org-approved-1');
        return {
          organization: { id: 'org-approved-1' },
          membership: { roleKey: 'buyer_admin' },
        };
      },
    },
    {
      async recognizeLicenseForOrganization() {
        return options.ocrView ?? {
          status: 'recognized',
          message: 'recognized',
          legalName: '上海展建服务集团有限公司',
          uscc: '91310000999999999X',
          legalPerson: '李四',
          businessType: '有限责任公司',
          address: '上海市浦东新区世纪大道 100 号',
          registeredCapital: '贰佰万元整',
          establishedAt: '2020年4月9日',
          businessTerm: '长期',
          businessScope: '展览工程',
          providerRequestId: 'ocr-revalidate-1',
        };
      },
    },
    new ProfilePresenter(),
  );

  return {
    service,
    organization,
    certification,
    revalidationAttempts,
    audits,
  };
}

test('certification revalidate updates approved formal truth and writes audit carriers', async () => {
  const { service, organization, certification, revalidationAttempts, audits } =
    makeService();

  const result = await service.revalidate(
    {
      organizationId: 'org-approved-1',
      legalName: '上海展建服务集团有限公司',
      uscc: '91310000999999999X',
      licenseFileId: 'license-new-1',
      correctionNote: '营业执照字段已更新',
    },
    createContext('cert-revalidate-success'),
  );

  assert.equal(result.certificationStatus, 'approved');
  assert.equal(organization.uscc, '91310000999999999X');
  assert.equal(organization.businessLicenseFileId, 'license-new-1');
  assert.equal(certification.legalName, '上海展建服务集团有限公司');
  assert.equal(certification.uscc, '91310000999999999X');
  assert.equal(certification.licenseFileId, 'license-new-1');
  assert.equal(certification.legalPerson, '李四');
  assert.equal(certification.businessScope, '展览工程');
  assert.equal(revalidationAttempts.length, 1);
  assert.equal(revalidationAttempts[0].commandOutcome, 'updated');
  assert.equal(revalidationAttempts[0].beforeStatus, 'approved');
  assert.equal(revalidationAttempts[0].afterStatus, 'approved');
  assert.equal(revalidationAttempts[0].oldSnapshot.legalName, '上海展建服务有限公司');
  assert.equal(
    revalidationAttempts[0].requestedSnapshot.correctionNote,
    '营业执照字段已更新',
  );
  assert.equal(revalidationAttempts[0].ocrSnapshot.providerRequestId, 'ocr-revalidate-1');
  assert.equal(audits.length, 1);
  assert.equal(audits[0].action, 'OrganizationCertificationRevalidated');
});

test('certification revalidate keeps current truth unchanged when OCR verification fails but still records attempt', async () => {
  const { service, organization, certification, revalidationAttempts, audits } =
    makeService({
      ocrView: {
        status: 'recognized',
        message: 'recognized',
        legalName: '上海展建服务集团有限公司',
        uscc: '91310000123456789A',
        legalPerson: '李四',
        businessType: '有限责任公司',
        address: '上海市浦东新区世纪大道 100 号',
        registeredCapital: '贰佰万元整',
        establishedAt: '2020年4月9日',
        businessTerm: '长期',
        businessScope: '展览工程',
        providerRequestId: 'ocr-revalidate-2',
      },
    });

  await assert.rejects(
    () =>
      service.revalidate(
        {
          organizationId: 'org-approved-1',
          legalName: '北京另一家公司',
          uscc: '91310000999999999X',
          licenseFileId: 'license-new-1',
          correctionNote: '尝试更正',
        },
        createContext('cert-revalidate-failure'),
      ),
    hasErrorCode('CERTIFICATION_REVALIDATE_INVALID'),
  );

  assert.equal(organization.uscc, '91310000123456789A');
  assert.equal(organization.businessLicenseFileId, 'license-old-1');
  assert.equal(certification.legalName, '上海展建服务有限公司');
  assert.equal(certification.uscc, '91310000123456789A');
  assert.equal(revalidationAttempts.length, 1);
  assert.equal(revalidationAttempts[0].commandOutcome, 'rejected');
  assert.equal(revalidationAttempts[0].beforeStatus, 'approved');
  assert.equal(revalidationAttempts[0].afterStatus, 'approved');
  assert.match(
    revalidationAttempts[0].outcomeReason,
    /营业执照 OCR 自动核验未通过/,
  );
  assert.equal(audits.length, 1);
  assert.equal(audits[0].action, 'OrganizationCertificationRevalidationRejected');
});
