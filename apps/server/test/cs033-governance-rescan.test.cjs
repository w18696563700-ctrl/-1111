const test = require('node:test');
const assert = require('node:assert/strict');

const context = {
  authorization: 'Bearer test',
  actorId: 'reviewer-user',
  userId: 'reviewer-user',
  organizationId: 'platform-org',
  actorRole: 'platform_reviewer',
  requestId: 'request-cs033',
  traceId: 'trace-cs033'
};

function makeService(options = {}) {
  const jobs = [...(options.jobs ?? [])];
  const snapshots = [...(options.snapshots ?? [])];
  const tickets = [...(options.tickets ?? [])];
  const auditRecords = [];

  const jobRepository = {
    create: (value) => ({ ...value }),
    save: async (job) => {
      const index = jobs.findIndex((item) => item.id === job.id);
      if (index >= 0) {
        jobs[index] = job;
      } else {
        jobs.push(job);
      }
      return job;
    },
    findOneBy: async ({ id }) => jobs.find((item) => item.id === id) ?? null,
    createQueryBuilder: () => makeQueryBuilder(jobs)
  };
  const snapshotRepository = {
    find: async () => snapshots
  };
  const ticketRepository = {
    find: async () => tickets
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
  const auditService = {
    record: async (input) => {
      auditRecords.push(input);
      return { id: 'audit-1', ...input };
    }
  };
  const dataSource = {
    transaction: async (callback) => callback({ getRepository: () => jobRepository })
  };

  const { GovernanceRescanJobService } = loadDistModule([
    '../dist/apps/server/src/modules/governance/governance-rescan-job.service.js',
    '../dist/src/modules/governance/governance-rescan-job.service.js',
    '../dist/modules/governance/governance-rescan-job.service.js'
  ]);
  const { GovernanceRescanJobPresenter } = loadDistModule([
    '../dist/apps/server/src/modules/governance/governance-rescan-job.presenter.js',
    '../dist/src/modules/governance/governance-rescan-job.presenter.js',
    '../dist/modules/governance/governance-rescan-job.presenter.js'
  ]);

  return {
    jobs,
    auditRecords,
    service: new GovernanceRescanJobService(
      jobRepository,
      ticketRepository,
      snapshotRepository,
      verifier,
      eligibility,
      auditService,
      dataSource,
      new GovernanceRescanJobPresenter()
    )
  };
}

function makeQueryBuilder(items) {
  const state = { offset: 0, limit: 20 };
  const qb = {
    orderBy: () => qb,
    offset: (value) => {
      state.offset = value;
      return qb;
    },
    limit: (value) => {
      state.limit = value;
      return qb;
    },
    getCount: async () => items.length,
    getMany: async () =>
      [...items]
        .sort((left, right) => right.createdAt.getTime() - left.createdAt.getTime())
        .slice(state.offset, state.offset + state.limit)
  };
  return qb;
}

function hasErrorCode(expectedCode) {
  return (error) => error?.getResponse?.().code === expectedCode;
}

function loadDistModule(candidates) {
  for (const candidate of candidates) {
    try {
      return require(candidate);
    } catch (error) {
      if (error?.code !== 'MODULE_NOT_FOUND') {
        throw error;
      }
    }
  }
  throw new Error(`Unable to load any dist module from: ${candidates.join(', ')}`);
}

test('CS-033 create stores queued rescan truth and derives forum candidate counts from snapshots', async () => {
  const snapshotWithinWindow = {
    id: 'snapshot-1',
    subjectType: 'forum_report_ticket',
    subjectId: 'report-1',
    userId: 'reporter-user',
    contentType: 'forum_post',
    fieldKey: 'post',
    currentValue: JSON.stringify({
      targetType: 'post',
      postId: 'post-1',
      topicId: 'topic-1',
      publishedAt: '2026-04-07T03:30:00.000Z'
    }),
    proposedValue: null,
    fileAssetId: null,
    metadata: {},
    createdAt: new Date('2026-04-07T03:31:00.000Z')
  };
  const snapshotOutsideWindow = {
    ...snapshotWithinWindow,
    id: 'snapshot-2',
    subjectId: 'report-2',
    currentValue: JSON.stringify({
      targetType: 'comment',
      commentId: 'comment-1',
      postId: 'post-1',
      publishedAt: '2026-04-01T00:00:00.000Z'
    })
  };
  const { service, jobs, auditRecords } = makeService({
    snapshots: [snapshotWithinWindow, snapshotOutsideWindow],
    tickets: [
      {
        id: 'report-1',
        reasonCode: 'spam_or_flood',
        reasonDetail: 'Spam content.',
        targetType: 'post',
        targetId: 'post-1',
        targetAuthorUserId: 'author-1',
        targetOrganizationId: 'org-1',
        reporterUserId: 'reporter-user',
        reporterActorId: 'reporter-actor',
        reporterOrganizationId: 'platform-org',
        status: 'submitted',
        targetSnapshot: {},
        createdAt: new Date('2026-04-07T03:31:00.000Z'),
        updatedAt: new Date('2026-04-07T03:31:00.000Z')
      },
      {
        id: 'report-2',
        reasonCode: 'other',
        reasonDetail: 'Other reason.',
        targetType: 'comment',
        targetId: 'comment-1',
        targetAuthorUserId: 'author-2',
        targetOrganizationId: 'org-1',
        reporterUserId: 'reporter-user',
        reporterActorId: 'reporter-actor',
        reporterOrganizationId: 'platform-org',
        status: 'submitted',
        targetSnapshot: {},
        createdAt: new Date('2026-04-01T00:01:00.000Z'),
        updatedAt: new Date('2026-04-01T00:01:00.000Z')
      }
    ]
  });

  const result = await service.create(
    {
      scopeType: 'forum_content',
      windowStart: '2026-04-07T00:00:00.000Z',
      windowEnd: '2026-04-08T00:00:00.000Z',
      reason: 'Rescan historical forum content after policy update.',
      ruleSetVersion: 'forum_content_rule_v1',
      engineMode: 'bounded_rules'
    },
    context
  );

  assert.equal(result.status, 'queued');
  assert.equal(result.traceId, context.traceId);
  assert.equal(jobs.length, 1);
  assert.equal(jobs[0].scopeType, 'forum_content');
  assert.equal(jobs[0].candidateCount, 1);
  assert.equal(jobs[0].flaggedCount, 1);
  assert.equal(jobs[0].createdBy, 'reviewer-user');
  assert.equal(auditRecords.length, 1);
  assert.equal(auditRecords[0].subjectType, 'governance_rescan_job');
  assert.equal(auditRecords[0].decision, 'queued');
  assert.equal(auditRecords[0].metadata.candidateCount, 1);
});

test('CS-033 list and detail expose bounded rescan job minimum projection', async () => {
  const createdAt = new Date('2026-04-08T03:00:00.000Z');
  const { service } = makeService({
    jobs: [
      {
        id: 'rescan-job-1',
        scopeType: 'forum_content',
        status: 'queued',
        windowStart: new Date('2026-04-07T00:00:00.000Z'),
        windowEnd: new Date('2026-04-08T00:00:00.000Z'),
        candidateCount: 2,
        flaggedCount: 1,
        reason: 'Historical forum rescan.',
        ruleSetVersion: 'forum_content_rule_v1',
        engineMode: 'bounded_rules',
        createdBy: 'reviewer-user',
        createdAt,
        completedAt: null,
        updatedAt: createdAt
      }
    ]
  });

  const list = await service.list({ page: '1', pageSize: '10' }, context);
  const detail = await service.detail('rescan-job-1', context);

  assert.equal(list.pagination.total, 1);
  assert.deepEqual(list.items[0], {
    rescanJobId: 'rescan-job-1',
    scopeType: 'forum_content',
    status: 'queued',
    candidateCount: 2,
    createdAt: createdAt.toISOString()
  });
  assert.deepEqual(detail, {
    rescanJobId: 'rescan-job-1',
    scopeType: 'forum_content',
    status: 'queued',
    windowStart: '2026-04-07T00:00:00.000Z',
    windowEnd: '2026-04-08T00:00:00.000Z',
    candidateCount: 2,
    flaggedCount: 1,
    createdAt: createdAt.toISOString(),
    completedAt: null
  });
});

test('CS-033 create rejects out-of-bound scope and invalid window payloads', async () => {
  const { service } = makeService();

  await assert.rejects(
    () =>
      service.create(
        {
          scopeType: 'organization',
          windowStart: '2026-04-07T00:00:00.000Z',
          windowEnd: '2026-04-08T00:00:00.000Z',
          reason: 'Unsupported scope.'
        },
        context
      ),
    hasErrorCode('GOVERNANCE_RESCAN_JOB_CREATE_INVALID')
  );
  await assert.rejects(
    () =>
      service.create(
        {
          scopeType: 'forum_content',
          windowStart: '2026-04-08T00:00:00.000Z',
          windowEnd: '2026-04-07T00:00:00.000Z',
          reason: 'Backwards window.'
        },
        context
      ),
    hasErrorCode('GOVERNANCE_RESCAN_JOB_CREATE_INVALID')
  );
});

test('CS-033 migration registry includes governance_rescan_jobs truth only', () => {
  const { governanceRescanP2AMigrations, serverMigrations } = loadDistModule([
    '../dist/apps/server/src/core/migrations/migrations.js',
    '../dist/src/core/migrations/migrations.js',
    '../dist/core/migrations/migrations.js'
  ]);
  const migration = governanceRescanP2AMigrations.find(
    (item) => item.key === '20260408_governance_rescan_p2a_truth'
  );

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  const joined = migration.statements.join('\n');
  assert.match(joined, /CREATE TABLE IF NOT EXISTS governance_rescan_jobs/);
  assert.match(joined, /scope_type varchar\(32\) NOT NULL DEFAULT 'forum_content'/);
  assert.match(joined, /status IN \('queued', 'running', 'completed', 'failed', 'cancelled'\)/);
  assert.doesNotMatch(joined, /appeal_cases/);
  assert.doesNotMatch(joined, /permanent_bans/);
});
