const test = require('node:test');
const assert = require('node:assert/strict');

function createRepository(initialItems = [], key = 'id') {
  const items = initialItems.map((item) => ({ ...item }));
  return {
    items,
    async findOneBy(where) {
      return (
        items.find((item) =>
          Object.entries(where).every(([field, expected]) => item[field] === expected),
        ) ?? null
      );
    },
    async findOne(options = {}) {
      const where = options.where ?? {};
      const matched = items.filter((item) =>
        Object.entries(where).every(([field, expected]) => item[field] === expected),
      );
      const order = options.order ?? {};
      const sorted = [...matched].sort((left, right) => {
        for (const [field, direction] of Object.entries(order)) {
          const leftValue =
            left[field] instanceof Date ? left[field].getTime() : left[field] ?? '';
          const rightValue =
            right[field] instanceof Date ? right[field].getTime() : right[field] ?? '';
          if (leftValue === rightValue) {
            continue;
          }
          return direction === 'DESC'
            ? rightValue > leftValue
              ? 1
              : -1
            : leftValue > rightValue
              ? 1
              : -1;
        }
        return 0;
      });
      return sorted[0] ? { ...sorted[0] } : null;
    },
  };
}

function createContext(requestId) {
  return {
    authorization: 'Bearer carrier',
    actorId: '',
    userId: '',
    organizationId: 'header-only-org',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

function createEligibilityService(overrides = {}) {
  return {
    async requireAuthenticatedActor() {
      return { id: 'actor-1', status: 'active' };
    },
    async getCurrentOrganizationScope() {
      return {
        organization: { id: 'viewer-org' },
        certification: { certificationStatus: 'approved' },
        personalCertification: {
          certificationStatus: 'approved',
          qualifiedForCurrentActor: true,
          lockedToOtherActor: false,
        },
      };
    },
    ...overrides,
  };
}

test('formal-info read returns target enterprise certification current truth instead of viewer certification', async () => {
  const {
    EnterpriseHubFormalInfoQueryService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-formal-info.query.service.js');

  const service = new EnterpriseHubFormalInfoQueryService(
    createRepository([
      {
        id: 'enterprise-1',
        organizationId: 'target-org',
        enterpriseStatus: 'published',
        displayStatus: 'visible',
      },
    ]),
    createRepository(
      [
        {
          id: 'cert-target',
          organizationId: 'target-org',
          certificationStatus: 'approved',
          legalName: '重庆坤特展览展示有限公司',
          uscc: '91500105TARGET0001',
          legalPerson: '张三',
          businessType: '有限责任公司',
          address: '重庆市江北区港城工业园 8 号',
          registeredCapital: '500 万人民币',
          establishedAt: '2020-04-09',
          businessTerm: '长期',
          businessScope: '展览展示制作',
          updatedAt: new Date('2026-04-18T09:00:00.000Z'),
          createdAt: new Date('2026-04-18T08:00:00.000Z'),
        },
        {
          id: 'cert-viewer',
          organizationId: 'viewer-org',
          certificationStatus: 'approved',
          legalName: '当前查看者企业',
          uscc: '91500105VIEWER0001',
          legalPerson: '李四',
          businessType: '有限责任公司',
          address: '成都市高新区软件园 1 号',
          registeredCapital: '100 万人民币',
          establishedAt: '2021-01-01',
          businessTerm: '长期',
          businessScope: '设计服务',
          updatedAt: new Date('2026-04-18T10:00:00.000Z'),
          createdAt: new Date('2026-04-18T09:30:00.000Z'),
        },
      ],
      'id',
    ),
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'actor-1',
            userId: 'user-1',
            organizationId: 'viewer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    createEligibilityService(),
  );

  const result = await service.getEnterpriseFormalInfo(
    'enterprise-1',
    createContext('formal-info-target-truth'),
  );

  assert.equal(result.legalName, '重庆坤特展览展示有限公司');
  assert.equal(result.uscc, '91500105TARGET0001');
  assert.equal(result.address, '重庆市江北区港城工业园 8 号');
  assert.equal(result.certificationStatus, 'approved');
});

test('formal-info read fails closed when target enterprise has no approved current certification truth', async () => {
  const {
    EnterpriseHubFormalInfoQueryService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-formal-info.query.service.js');

  const service = new EnterpriseHubFormalInfoQueryService(
    createRepository([
      {
        id: 'enterprise-1',
        organizationId: 'target-org',
        enterpriseStatus: 'published',
        displayStatus: 'visible',
      },
    ]),
    createRepository(
      [
        {
          id: 'cert-target-pending',
          organizationId: 'target-org',
          certificationStatus: 'pending',
          legalName: '待审企业',
          updatedAt: new Date('2026-04-18T11:00:00.000Z'),
          createdAt: new Date('2026-04-18T10:00:00.000Z'),
        },
      ],
      'id',
    ),
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'actor-1',
            userId: 'user-1',
            organizationId: 'viewer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    createEligibilityService(),
  );

  await assert.rejects(
    () =>
      service.getEnterpriseFormalInfo(
        'enterprise-1',
        createContext('formal-info-unavailable'),
      ),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
  );
});

test('formal-info read keeps the dual-cert hard gate on the current viewer context', async () => {
  const {
    EnterpriseHubFormalInfoQueryService,
  } = require('../dist/modules/enterprise_hub/enterprise-hub-formal-info.query.service.js');

  const service = new EnterpriseHubFormalInfoQueryService(
    createRepository([
      {
        id: 'enterprise-1',
        organizationId: 'target-org',
        enterpriseStatus: 'published',
        displayStatus: 'visible',
      },
    ]),
    createRepository(
      [
        {
          id: 'cert-target',
          organizationId: 'target-org',
          certificationStatus: 'approved',
          legalName: '重庆坤特展览展示有限公司',
          updatedAt: new Date('2026-04-18T09:00:00.000Z'),
          createdAt: new Date('2026-04-18T08:00:00.000Z'),
        },
      ],
      'id',
    ),
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'actor-1',
            userId: 'user-1',
            organizationId: 'viewer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    createEligibilityService({
      async getCurrentOrganizationScope() {
        return {
          organization: { id: 'viewer-org' },
          certification: { certificationStatus: 'approved' },
          personalCertification: {
            certificationStatus: 'pending',
            qualifiedForCurrentActor: false,
            lockedToOtherActor: false,
          },
        };
      },
    }),
  );

  await assert.rejects(
    () =>
      service.getEnterpriseFormalInfo(
        'enterprise-1',
        createContext('formal-info-dual-cert-gate'),
      ),
    (error) => error?.response?.code === 'ENTERPRISE_HUB_PERMISSION_DENIED',
  );
});
