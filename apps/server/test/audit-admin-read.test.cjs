const test = require('node:test');
const assert = require('node:assert/strict');

const context = {
  authorization: 'Bearer test',
  actorId: 'reviewer-user',
  userId: 'reviewer-user',
  organizationId: 'platform-org',
  actorRole: 'platform_reviewer',
  requestId: 'request-audit',
  traceId: 'trace-audit',
  userAgent: '',
  remoteIp: ''
};

function makeService(options = {}) {
  const identityLogs = [...(options.identityLogs ?? [])];
  const projectLogs = [...(options.projectLogs ?? [])];
  const identityById = new Map(identityLogs.map((item) => [item.id, item]));
  const projectById = new Map(projectLogs.map((item) => [item.id, item]));

  const identityRepository = {
    find: async () => identityLogs,
    findOneBy: async ({ id }) => identityById.get(id) ?? null
  };
  const projectRepository = {
    find: async () => projectLogs,
    findOneBy: async ({ id }) => projectById.get(id) ?? null
  };
  const verifier = {
    verifyCurrentSessionContext: async () => ({
      outcome: 'verified',
      currentSession: {
        sessionId: 'session-1',
        actorId: context.actorId,
        userId: context.userId,
        organizationId: context.organizationId,
        requestId: context.requestId,
        traceId: context.traceId
      }
    })
  };
  const eligibility = {
    requireReviewer: async () => ({ actorRole: 'platform_reviewer' })
  };

  const { AuditLogQueryService } = require('../dist/modules/audit/audit-log-query.service.js');
  const { AuditLogPresenter } = require('../dist/modules/audit/audit-log.presenter.js');

  return new AuditLogQueryService(
    identityRepository,
    projectRepository,
    verifier,
    eligibility,
    new AuditLogPresenter()
  );
}

test('audit queue/list merges identity and project_publish carriers into append-only admin projection', async () => {
  const occurredAt = new Date('2026-04-11T01:00:00.000Z');
  const createdAt = new Date('2026-04-11T02:00:00.000Z');
  const service = makeService({
    identityLogs: [
      {
        id: '11111111-1111-4111-8111-111111111111',
        objectType: 'organization_certification',
        objectId: 'cert-1',
        objectNo: 'CERT-001',
        action: 'OrganizationCertificationApproved',
        actorId: 'reviewer-user',
        actorRole: 'platform_reviewer',
        beforeState: 'submitted',
        afterState: 'approved',
        reason: 'Manual audit pass.',
        requestId: 'request-identity-1',
        traceId: 'trace-identity-1',
        occurredAt
      }
    ],
    projectLogs: [
      {
        id: 'project-audit-1',
        aggregateType: 'project',
        aggregateId: 'project-1',
        eventType: 'ProjectPublished',
        actorId: 'publisher-user',
        userId: 'publisher-user',
        organizationId: 'org-1',
        requestId: 'request-project-1',
        traceId: 'trace-project-1',
        payload: { publishedState: 'published' },
        createdAt
      }
    ]
  });

  const result = await service.list({ page: '1', pageSize: '10' }, context);

  assert.equal(result.pagination.total, 2);
  assert.deepEqual(result.items[0], {
    auditLogId: 'project_publish:project-audit-1',
    sourceFamily: 'project_publish',
    objectType: 'project',
    objectId: 'project-1',
    objectNo: null,
    action: 'ProjectPublished',
    actorId: 'publisher-user',
    actorRole: null,
    requestId: 'request-project-1',
    traceId: 'trace-project-1',
    occurredAt: createdAt.toISOString()
  });
  assert.deepEqual(result.items[1], {
    auditLogId: 'identity:11111111-1111-4111-8111-111111111111',
    sourceFamily: 'identity',
    objectType: 'organization_certification',
    objectId: 'cert-1',
    objectNo: 'CERT-001',
    action: 'OrganizationCertificationApproved',
    actorId: 'reviewer-user',
    actorRole: 'platform_reviewer',
    requestId: 'request-identity-1',
    traceId: 'trace-identity-1',
    occurredAt: occurredAt.toISOString()
  });
});

test('audit queue/list filters by sourceFamily, objectType, requestId, and traceId', async () => {
  const occurredAt = new Date('2026-04-11T01:00:00.000Z');
  const service = makeService({
    identityLogs: [
      {
        id: '11111111-1111-4111-8111-111111111111',
        objectType: 'organization_certification',
        objectId: 'cert-1',
        objectNo: 'CERT-001',
        action: 'OrganizationCertificationApproved',
        actorId: 'reviewer-user',
        actorRole: 'platform_reviewer',
        beforeState: 'submitted',
        afterState: 'approved',
        reason: 'Manual audit pass.',
        requestId: 'request-identity-1',
        traceId: 'trace-identity-1',
        occurredAt
      }
    ],
    projectLogs: [
      {
        id: 'project-audit-1',
        aggregateType: 'project',
        aggregateId: 'project-1',
        eventType: 'ProjectPublished',
        actorId: 'publisher-user',
        userId: 'publisher-user',
        organizationId: 'org-1',
        requestId: 'request-project-1',
        traceId: 'trace-project-1',
        payload: { publishedState: 'published' },
        createdAt: new Date('2026-04-11T02:00:00.000Z')
      }
    ]
  });

  const bySourceFamily = await service.list(
    { sourceFamily: 'identity', page: '1', pageSize: '10' },
    context
  );
  const byObjectType = await service.list(
    { objectType: 'project', page: '1', pageSize: '10' },
    context
  );
  const byRequestId = await service.list(
    { requestId: 'request-identity-1', page: '1', pageSize: '10' },
    context
  );
  const byTraceId = await service.list(
    { traceId: 'trace-project-1', page: '1', pageSize: '10' },
    context
  );

  assert.equal(bySourceFamily.items.length, 1);
  assert.equal(bySourceFamily.items[0].sourceFamily, 'identity');
  assert.equal(byObjectType.items.length, 1);
  assert.equal(byObjectType.items[0].objectType, 'project');
  assert.equal(byRequestId.items.length, 1);
  assert.equal(byRequestId.items[0].requestId, 'request-identity-1');
  assert.equal(byTraceId.items.length, 1);
  assert.equal(byTraceId.items[0].traceId, 'trace-project-1');
});

test('audit detail inspect returns normalized identity and project_publish detail shapes', async () => {
  const occurredAt = new Date('2026-04-11T01:00:00.000Z');
  const createdAt = new Date('2026-04-11T02:00:00.000Z');
  const service = makeService({
    identityLogs: [
      {
        id: '11111111-1111-4111-8111-111111111111',
        objectType: 'organization_certification',
        objectId: 'cert-1',
        objectNo: 'CERT-001',
        action: 'OrganizationCertificationApproved',
        actorId: 'reviewer-user',
        actorRole: 'platform_reviewer',
        beforeState: 'submitted',
        afterState: 'approved',
        reason: 'Manual audit pass.',
        requestId: 'request-identity-1',
        traceId: 'trace-identity-1',
        occurredAt
      }
    ],
    projectLogs: [
      {
        id: 'project-audit-1',
        aggregateType: 'project',
        aggregateId: 'project-1',
        eventType: 'ProjectPublished',
        actorId: 'publisher-user',
        userId: 'publisher-user',
        organizationId: 'org-1',
        requestId: 'request-project-1',
        traceId: 'trace-project-1',
        payload: { publishedState: 'published' },
        createdAt
      }
    ]
  });

  const identityDetail = await service.detail(
    'identity:11111111-1111-4111-8111-111111111111',
    context
  );
  const projectDetail = await service.detail('project_publish:project-audit-1', context);

  assert.equal(identityDetail.beforeState, 'submitted');
  assert.equal(identityDetail.afterState, 'approved');
  assert.equal(identityDetail.reason, 'Manual audit pass.');
  assert.deepEqual(identityDetail.payload, {});

  assert.equal(projectDetail.beforeState, null);
  assert.equal(projectDetail.afterState, null);
  assert.equal(projectDetail.reason, null);
  assert.deepEqual(projectDetail.payload, { publishedState: 'published' });
});
