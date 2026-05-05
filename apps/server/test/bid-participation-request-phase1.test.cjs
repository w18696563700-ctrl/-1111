const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId, actorRole = 'supplier') {
  return {
    authorization: 'Bearer test-token',
    actorId: '',
    userId: '',
    organizationId: '',
    actorRole,
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

function createProject(overrides = {}) {
  return {
    id: 'project-1',
    projectNo: 'EXH-2026-PARTICIPATION',
    organizationId: 'publisher-org',
    title: '保密展台项目',
    exhibitionName: '保密展台项目',
    state: 'published',
    publishedAt: new Date('2026-04-28T08:00:00.000Z'),
    ...overrides,
  };
}

function createRequest(overrides = {}) {
  return {
    id: overrides.id ?? 'request-1',
    projectId: overrides.projectId ?? 'project-1',
    requesterOrganizationId: overrides.requesterOrganizationId ?? 'supplier-org',
    requestedByUserId: overrides.requestedByUserId ?? 'supplier-user',
    requestedByActorId: overrides.requestedByActorId ?? 'supplier-user',
    state: overrides.state ?? 'pending',
    reviewedByUserId: overrides.reviewedByUserId ?? null,
    reviewedByActorId: overrides.reviewedByActorId ?? null,
    reviewedAt: overrides.reviewedAt ?? null,
    createdAt: overrides.createdAt ?? new Date('2026-04-28T09:00:00.000Z'),
    updatedAt: overrides.updatedAt ?? new Date('2026-04-28T09:00:00.000Z'),
  };
}

function createRequestRepository(seed = []) {
  const rows = [...seed];
  return {
    rows,
    create(input) {
      return {
        ...input,
        createdAt: input.createdAt ?? new Date('2026-04-28T09:30:00.000Z'),
        updatedAt: input.updatedAt ?? new Date('2026-04-28T09:30:00.000Z'),
      };
    },
    async save(value) {
      const existingIndex = rows.findIndex((item) => item.id === value.id);
      if (existingIndex >= 0) {
        rows[existingIndex] = value;
      } else {
        rows.push(value);
      }
      return value;
    },
    async find(options = {}) {
      const where = options.where ?? {};
      return rows
        .filter((item) => {
          for (const [key, value] of Object.entries(where)) {
            if (item[key] !== value) {
              return false;
            }
          }
          return true;
        })
        .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
        .slice(0, options.take ?? rows.length);
    },
    async findOneBy(where) {
      return rows.find((item) => {
        for (const [key, value] of Object.entries(where)) {
          if (item[key] !== value) {
            return false;
          }
        }
        return true;
      }) ?? null;
    },
    async countBy(where) {
      return (await this.find({ where })).length;
    },
  };
}

function createAuditRepository() {
  const rows = [];
  return {
    rows,
    create(input) {
      return input;
    },
    async save(value) {
      rows.push(value);
      return value;
    },
  };
}

function createNotificationRepository() {
  const rows = [];
  return {
    rows,
    create(input) {
      return {
        ...input,
        createdAt: input.createdAt ?? new Date('2026-04-28T09:30:00.000Z'),
        updatedAt: input.updatedAt ?? new Date('2026-04-28T09:30:00.000Z'),
      };
    },
    async save(value) {
      rows.push(value);
      return value;
    },
  };
}

function createServiceHarness({ requests = [], project = createProject() } = {}) {
  const { BidParticipationRequestEntity } = require('../dist/modules/bid_participation_request/entities/bid-participation-request.entity.js');
  const { IdentityAuditLogEntity } = require('../dist/modules/audit/identity-audit-log.entity.js');
  const { AppNotificationEntity } = require('../dist/modules/notifications/entities/app-notification.entity.js');
  const { BidParticipationRequestPresenter } = require('../dist/modules/bid_participation_request/bid-participation-request.presenter.js');
  const { BidParticipationRequestWriteService } = require('../dist/modules/bid_participation_request/bid-participation-request.write.service.js');
  const { NotificationPresenter } = require('../dist/modules/notifications/notification.presenter.js');
  const { NotificationService } = require('../dist/modules/notifications/notification.service.js');
  const requestRepository = createRequestRepository(requests);
  const auditRepository = createAuditRepository();
  const notificationRepository = createNotificationRepository();
  const projectRepository = {
    async findOneBy(where) {
      return where.id === project.id ? project : null;
    },
  };
  const dataSource = {
    async transaction(callback) {
      return callback({
        getRepository(entity) {
          if (entity === BidParticipationRequestEntity) {
            return requestRepository;
          }
          if (entity === IdentityAuditLogEntity) {
            return auditRepository;
          }
          if (entity === AppNotificationEntity) {
            return notificationRepository;
          }
          throw new Error('unexpected repository');
        },
      });
    },
  };
  const sessionVerifier = {
    async verifyCurrentSessionContext(context) {
      const isOwner = context.actorRole === 'publisher';
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: isOwner ? 'publisher-user' : 'supplier-user',
          userId: isOwner ? 'publisher-user' : 'supplier-user',
          organizationId: isOwner ? 'publisher-org' : 'supplier-org',
          requestId: context.requestId,
          traceId: context.traceId,
        },
      };
    },
  };
  const eligibilityService = {
    async requireBidSubmitEligibilityFromContext(context, resolver) {
      const verified = await resolver.verifyCurrentSessionContext(context);
      return {
        currentSession: verified.currentSession,
        scope: {
          organization: { id: 'supplier-org' },
          membership: { roleKey: 'supplier_admin' },
          certification: { certificationStatus: 'approved' },
          roleKeys: ['supplier_admin'],
        },
        project,
      };
    },
    async requireProjectPublishEligibility(currentSession) {
      return {
        organization: { id: currentSession.organizationId },
        membership: { roleKey: 'publisher_admin' },
        certification: { certificationStatus: 'approved' },
        roleKeys: ['publisher_admin'],
      };
    },
  };
  return {
    requestRepository,
    auditRepository,
    service: new BidParticipationRequestWriteService(
      requestRepository,
      projectRepository,
      dataSource,
      sessionVerifier,
      eligibilityService,
      new BidParticipationRequestPresenter(),
      new NotificationService(
        notificationRepository,
        {},
        {},
        sessionVerifier,
        new NotificationPresenter(),
      ),
    ),
    notificationRepository,
  };
}

test('bid participation create writes pending truth, notification, and append-only audit', async () => {
  const { service, requestRepository, auditRepository, notificationRepository } = createServiceHarness();
  const result = await service.createRequest(
    { projectId: 'project-1' },
    createContext('bid-participation-create'),
  );

  assert.equal(requestRepository.rows.length, 1);
  assert.equal(requestRepository.rows[0].projectId, 'project-1');
  assert.equal(requestRepository.rows[0].requesterOrganizationId, 'supplier-org');
  assert.equal(requestRepository.rows[0].state, 'pending');
  assert.equal(auditRepository.rows.length, 1);
  assert.equal(auditRepository.rows[0].objectType, 'bid_participation_request');
  assert.equal(auditRepository.rows[0].action, 'BidParticipationRequested');
  assert.equal(notificationRepository.rows.length, 1);
  assert.equal(notificationRepository.rows[0].type, 'bid_participation_request');
  assert.equal(notificationRepository.rows[0].source, 'bid_participation_request');
  assert.equal(notificationRepository.rows[0].organizationId, 'publisher-org');
  assert.equal(notificationRepository.rows[0].projectId, 'project-1');
  assert.equal(notificationRepository.rows[0].threadId, requestRepository.rows[0].id);
  assert.equal(
    notificationRepository.rows[0].routeTarget.canonicalPath,
    '/api/app/project/bid-participation/thread/detail',
  );
  assert.equal(
    notificationRepository.rows[0].routeTarget.routeParams.requestId,
    requestRepository.rows[0].id,
  );
  assert.deepEqual(result, {
    requestId: requestRepository.rows[0].id,
    projectId: 'project-1',
    status: 'pending',
    threadId: requestRepository.rows[0].id,
  });
});

test('bid participation create rejects duplicate pending or approved request', async () => {
  const pendingHarness = createServiceHarness({ requests: [createRequest({ state: 'pending' })] });
  await assert.rejects(
    () => pendingHarness.service.createRequest({ projectId: 'project-1' }, createContext('pending-duplicate')),
    (error) => error?.response?.code === 'BID_PARTICIPATION_CONFLICT',
  );

  const approvedHarness = createServiceHarness({ requests: [createRequest({ state: 'approved' })] });
  await assert.rejects(
    () => approvedHarness.service.createRequest({ projectId: 'project-1' }, createContext('approved-duplicate')),
    (error) => error?.response?.code === 'BID_PARTICIPATION_CONFLICT',
  );
});

test('publisher can approve or reject once and non-owner cannot review', async () => {
  const request = createRequest({ id: 'request-approve' });
  const { service, auditRepository } = createServiceHarness({ requests: [request] });
  const result = await service.approveRequest(
    'project-1',
    'request-approve',
    createContext('approve', 'publisher'),
  );
  assert.deepEqual(result, {
    requestId: 'request-approve',
    projectId: 'project-1',
    status: 'approved',
  });
  assert.equal(request.state, 'approved');
  assert.equal(request.reviewedByUserId, 'publisher-user');
  assert.ok(request.reviewedAt instanceof Date);
  assert.equal(auditRepository.rows[0].action, 'BidParticipationApproved');

  await assert.rejects(
    () => service.rejectRequest('project-1', 'request-approve', createContext('repeat', 'publisher')),
    (error) => error?.response?.code === 'BID_PARTICIPATION_INVALID_STATE',
  );

  const nonOwnerHarness = createServiceHarness({ requests: [createRequest({ id: 'request-reject' })] });
  await assert.rejects(
    () => nonOwnerHarness.service.rejectRequest('project-1', 'request-reject', createContext('reject', 'supplier')),
    (error) => error?.response?.code === 'BID_PARTICIPATION_FORBIDDEN',
  );
});

test('bid participation access gate fails closed until approved', async () => {
  const { BidParticipationRequestAccessService } = require('../dist/modules/bid_participation_request/bid-participation-request-access.service.js');
  const approvedRepository = createRequestRepository([createRequest({ state: 'approved' })]);
  const rejectedRepository = createRequestRepository([createRequest({ state: 'rejected' })]);
  const project = createProject();

  const approvedAccess = new BidParticipationRequestAccessService(approvedRepository);
  await approvedAccess.requireApprovedForOrganization(project, 'supplier-org');

  const rejectedAccess = new BidParticipationRequestAccessService(rejectedRepository);
  await assert.rejects(
    () => rejectedAccess.requireApprovedForOrganization(project, 'supplier-org'),
    (error) => error?.response?.code === 'BID_PARTICIPATION_REQUIRED',
  );
});

test('bid participation migration is registered in server migrations', () => {
  const {
    bidParticipationRequestMigrations,
    serverMigrations,
  } = require('../dist/core/migrations/migrations.js');
  const migration = bidParticipationRequestMigrations.find(
    (item) => item.key === '20260429_bid_participation_request_phase1_truth',
  );

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  assert.match(migration.statements.join('\n'), /CREATE TABLE IF NOT EXISTS bid_participation_requests/);
  assert.match(migration.statements.join('\n'), /idx_bid_participation_requests_one_active_pending/);
});
