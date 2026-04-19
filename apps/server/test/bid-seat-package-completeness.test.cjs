const test = require('node:test');
const assert = require('node:assert/strict');

const { BidSeatService } = require('../dist/modules/bid/bid-seat.service.js');
const { BidPackageCompletenessQueryService } = require('../dist/modules/bid/bid-package-completeness.query.service.js');
const { BidPresenter } = require('../dist/modules/bid/bid.presenter.js');
const { BidSeatEntity } = require('../dist/modules/bid/entities/bid-seat.entity.js');

function createContext(requestId) {
  return {
    authorization: 'Bearer bid-seat-token',
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

function createCurrentSession(overrides = {}) {
  return {
    sessionId: 'session-1',
    actorId: 'buyer-user',
    userId: 'buyer-user',
    organizationId: 'buyer-org',
    requestId: 'req-1',
    traceId: 'trace-1',
    ...overrides,
  };
}

function createScope(overrides = {}) {
  return {
    organization: { id: 'buyer-org' },
    membership: { roleKey: 'buyer_admin' },
    certification: { certificationStatus: 'approved' },
    roleKeys: ['buyer_admin'],
    ...overrides,
  };
}

function createProject(overrides = {}) {
  return {
    id: 'project-1',
    projectNo: 'PROJ-2026-1',
    organizationId: 'buyer-org',
    creatorUserId: 'buyer-user',
    creatorActorId: 'buyer-user',
    title: '展台项目',
    buildingType: 'exhibition',
    budgetAmount: '1000.00',
    state: 'published',
    publishedAt: new Date('2026-04-10T08:00:00.000Z'),
    ...overrides,
  };
}

function createBid(overrides = {}) {
  return {
    id: 'bid-1',
    projectId: 'project-1',
    organizationId: 'supplier-org',
    actorId: 'supplier-user',
    userId: 'supplier-user',
    quoteAmount: '8888.00',
    proposalSummary: '基础施工与物料方案',
    state: 'submitted',
    createdAt: new Date('2026-04-11T08:00:00.000Z'),
    updatedAt: new Date('2026-04-11T08:00:00.000Z'),
    ...overrides,
  };
}

function createSupplierCurrentSession(overrides = {}) {
  return createCurrentSession({
    actorId: 'supplier-user',
    userId: 'supplier-user',
    organizationId: 'supplier-org',
    ...overrides,
  });
}

function createSupplierScope(overrides = {}) {
  return createScope({
    organization: { id: 'supplier-org' },
    membership: { roleKey: 'supplier_admin' },
    certification: { certificationStatus: 'approved' },
    roleKeys: ['supplier_admin'],
    ...overrides,
  });
}

function createSeat(overrides = {}) {
  return {
    seatId: 'seat-1',
    projectId: 'project-1',
    bidId: 'bid-1',
    state: 'locked',
    lockedAt: new Date('2026-04-11T08:00:00.000Z'),
    expiresAt: new Date('2026-04-11T08:30:00.000Z'),
    releasedAt: null,
    updatedAt: new Date('2026-04-11T08:00:00.000Z'),
    ...overrides,
  };
}

function createSeatRepository(initialSeat) {
  let seat = initialSeat ? { ...initialSeat } : null;
  return {
    create(input) {
      return { ...input };
    },
    async findOneBy(criteria) {
      if (!seat) {
        return null;
      }
      if (criteria.projectId && criteria.projectId !== seat.projectId) {
        return null;
      }
      if (criteria.bidId && criteria.bidId !== seat.bidId) {
        return null;
      }
      return seat;
    },
    async save(value) {
      seat = value;
      return value;
    },
    get current() {
      return seat;
    },
  };
}

function createSeatHarness(options = {}) {
  const currentSession = createCurrentSession(options.currentSession);
  const scope = createScope(options.scope);
  const project = createProject(options.project);
  const bid = createBid(options.bid);
  const seatRepository = createSeatRepository(options.seat);
  const auditEvents = [];

  const service = new BidSeatService(
    {
      async transaction(callback) {
        return callback({
          getRepository(entity) {
            if (entity === BidSeatEntity) {
              return seatRepository;
            }
            throw new Error('unexpected repository');
          },
        });
      },
    },
    {
      async findOneBy(criteria) {
        if (
          criteria.id === project.id &&
          (!criteria.organizationId || criteria.organizationId === project.organizationId)
        ) {
          return project;
        }
        return null;
      },
    },
    {
      async findOneBy(criteria) {
        if (
          criteria.id === bid.id &&
          criteria.projectId === bid.projectId &&
          criteria.state === bid.state &&
          (!criteria.organizationId || criteria.organizationId === bid.organizationId)
        ) {
          return bid;
        }
        return null;
      },
    },
    {
      async verifyCurrentSessionContext() {
        return { outcome: 'verified', currentSession };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: currentSession.userId, status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return scope;
      },
    },
    {
      async record(entry, auditContext, manager) {
        auditEvents.push({ entry, auditContext, manager });
      },
    },
    new BidPresenter(),
  );

  return { service, seatRepository, auditEvents, currentSession, scope, project, bid };
}

function createCompletenessHarness(options = {}) {
  const currentSession = createCurrentSession(options.currentSession);
  const scope = createScope(options.scope);
  const project = createProject(options.project);
  const bid = createBid(options.bid);
  const auditEvents = [];

  const service = new BidPackageCompletenessQueryService(
    {
      async transaction(callback) {
        return callback({});
      },
    },
    {
      async findOneBy(criteria) {
        if (criteria.id === project.id && criteria.organizationId === project.organizationId) {
          return project;
        }
        return null;
      },
    },
    {
      async findOneBy(criteria) {
        if (
          criteria.id === bid.id &&
          criteria.projectId === bid.projectId &&
          criteria.state === bid.state &&
          (!criteria.organizationId || criteria.organizationId === bid.organizationId)
        ) {
          return bid;
        }
        return null;
      },
    },
    {
      async verifyCurrentSessionContext() {
        return { outcome: 'verified', currentSession };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: currentSession.userId, status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return scope;
      },
    },
    {
      async record(entry, auditContext, manager) {
        auditEvents.push({ entry, auditContext, manager });
      },
    },
    new BidPresenter(),
  );

  return { service, auditEvents, currentSession, scope, project, bid };
}

test('bid seat lock succeeds and duplicate lock fail-closes', async () => {
  const harness = createSeatHarness({ seat: null });
  const result = await harness.service.lock(
    { projectId: 'project-1', bidId: 'bid-1' },
    createContext('seat-lock'),
  );

  assert.equal(result.projectId, 'project-1');
  assert.equal(result.bidId, 'bid-1');
  assert.equal(result.state, 'locked');
  assert.match(result.seatId, /^[0-9a-f-]{36}$/i);
  assert.equal(typeof result.expiresAt, 'string');
  assert.equal(harness.auditEvents.length, 1);
  assert.equal(harness.auditEvents[0].entry.eventType, 'seat_locked');
  assert.equal(harness.auditEvents[0].entry.payload.beforeState, 'available');
  assert.equal(harness.auditEvents[0].entry.payload.afterState, 'locked');

  await assert.rejects(
    () =>
      harness.service.lock({ projectId: 'project-1', bidId: 'bid-1' }, createContext('seat-lock-dup')),
    (error) => error?.response?.code === 'BID_SEAT_CONFLICT',
  );
  assert.equal(harness.auditEvents.length, 1);
});

test('supplier can read, lock, and release its own bid seat from submitted bid context', async () => {
  const harness = createSeatHarness({
    seat: null,
    currentSession: createSupplierCurrentSession(),
    scope: createSupplierScope(),
  });

  const available = await harness.service.status(
    { projectId: 'project-1', bidId: 'bid-1' },
    createContext('supplier-seat-status'),
  );

  assert.deepEqual(available, {
    seatId: null,
    projectId: 'project-1',
    bidId: 'bid-1',
    state: 'available',
    expiresAt: null,
    releasedAt: null,
  });

  const locked = await harness.service.lock(
    { projectId: 'project-1', bidId: 'bid-1' },
    createContext('supplier-seat-lock'),
  );
  assert.equal(locked.state, 'locked');
  assert.match(locked.seatId, /^[0-9a-f-]{36}$/i);

  const released = await harness.service.release(
    { projectId: 'project-1', bidId: 'bid-1' },
    createContext('supplier-seat-release'),
  );
  assert.equal(released.state, 'released');
  assert.equal(typeof released.releasedAt, 'string');
});

test('bid seat release succeeds for active lock', async () => {
  const harness = createSeatHarness({
    seat: createSeat({
      state: 'locked',
      lockedAt: new Date('2026-04-11T08:00:00.000Z'),
      expiresAt: new Date(Date.now() + 10 * 60 * 1000),
    }),
  });

  const result = await harness.service.release(
    { projectId: 'project-1', bidId: 'bid-1' },
    createContext('seat-release'),
  );

  assert.equal(result.state, 'released');
  assert.equal(result.projectId, 'project-1');
  assert.equal(result.bidId, 'bid-1');
  assert.equal(typeof result.releasedAt, 'string');
  assert.equal(harness.seatRepository.current.state, 'released');
  assert.equal(harness.auditEvents.length, 1);
  assert.equal(harness.auditEvents[0].entry.eventType, 'seat_released');
  assert.equal(harness.auditEvents[0].entry.payload.afterState, 'released');
});

test('bid seat status returns available when seat is missing', async () => {
  const harness = createSeatHarness({ seat: null });

  const result = await harness.service.status(
    { projectId: 'project-1', bidId: 'bid-1' },
    createContext('seat-status-empty'),
  );

  assert.deepEqual(result, {
    seatId: null,
    projectId: 'project-1',
    bidId: 'bid-1',
    state: 'available',
    expiresAt: null,
    releasedAt: null,
  });
});

test('bid seat status timeout-releases expired lock and release path fail-closes', async () => {
  const expiredSeat = createSeat({
    state: 'locked',
    lockedAt: new Date('2026-04-11T07:00:00.000Z'),
    expiresAt: new Date('2026-04-11T07:30:00.000Z'),
    releasedAt: null,
  });
  const harness = createSeatHarness({ seat: expiredSeat });

  const status = await harness.service.status(
    { projectId: 'project-1', bidId: 'bid-1' },
    createContext('seat-status-timeout'),
  );

  assert.equal(status.state, 'timed_out');
  assert.equal(harness.seatRepository.current.state, 'timed_out');
  assert.equal(typeof status.releasedAt, 'string');
  assert.equal(harness.auditEvents.length, 1);
  assert.equal(harness.auditEvents[0].entry.eventType, 'seat_timeout_released');

  const expiredForRelease = createSeat({
    state: 'locked',
    lockedAt: new Date('2026-04-11T07:00:00.000Z'),
    expiresAt: new Date('2026-04-11T07:30:00.000Z'),
    releasedAt: null,
  });
  const releaseHarness = createSeatHarness({ seat: expiredForRelease });

  await assert.rejects(
    () =>
      releaseHarness.service.release(
        { projectId: 'project-1', bidId: 'bid-1' },
        createContext('seat-release-timeout'),
      ),
    (error) => error?.response?.code === 'BID_SEAT_TIMEOUT',
  );
  assert.equal(releaseHarness.seatRepository.current.state, 'timed_out');
  assert.equal(releaseHarness.auditEvents[0].entry.eventType, 'seat_timeout_released');
});

test('bid package completeness evaluates derived read and missing items', async () => {
  const completeHarness = createCompletenessHarness({
    bid: createBid({
      quoteAmount: '9000.00',
      proposalSummary: '完整方案',
    }),
  });

  const complete = await completeHarness.service.getPackageCompleteness(
    { projectId: 'project-1', bidId: 'bid-1' },
    createContext('completeness-complete'),
  );

  assert.deepEqual(complete, {
    bidId: 'bid-1',
    projectId: 'project-1',
    state: 'complete',
    missingItems: [],
    quoteAmountReady: true,
    proposalSummaryReady: true,
  });
  assert.equal(completeHarness.auditEvents.length, 1);
  assert.equal(completeHarness.auditEvents[0].entry.eventType, 'bid_completeness_evaluated');

  const incompleteHarness = createCompletenessHarness({
    bid: createBid({
      quoteAmount: '9000.00',
      proposalSummary: '   ',
    }),
  });

  const incomplete = await incompleteHarness.service.getPackageCompleteness(
    { projectId: 'project-1', bidId: 'bid-1' },
    createContext('completeness-incomplete'),
  );

  assert.equal(incomplete.state, 'incomplete');
  assert.deepEqual(incomplete.missingItems, ['proposal_summary']);
  assert.equal(incomplete.quoteAmountReady, true);
  assert.equal(incomplete.proposalSummaryReady, false);
});
