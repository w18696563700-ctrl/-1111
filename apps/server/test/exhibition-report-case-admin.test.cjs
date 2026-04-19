const test = require('node:test');
const assert = require('node:assert/strict');

const context = {
  authorization: 'Bearer test',
  actorId: 'reviewer-user',
  userId: 'reviewer-user',
  organizationId: 'platform-org',
  actorRole: 'platform_reviewer',
  requestId: 'request-report-case',
  traceId: 'trace-report-case',
  userAgent: '',
  remoteIp: ''
};

function makeService(options = {}) {
  const cases = [...(options.cases ?? [])];
  const auditRecords = [];
  const caseById = new Map(cases.map((item) => [item.id, item]));

  const caseRepository = {
    findOneBy: async ({ id }) => caseById.get(id) ?? null,
    createQueryBuilder: () => makeQueryBuilder(cases)
  };
  const txCaseRepository = {
    findOneBy: async ({ id }) => caseById.get(id) ?? null,
    save: async (reportCase) => {
      caseById.set(reportCase.id, reportCase);
      return reportCase;
    }
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
      return { id: `audit-${auditRecords.length}`, ...input };
    }
  };
  const dataSource = {
    transaction: async (callback) =>
      callback({
        getRepository: () => txCaseRepository
      })
  };

  const {
    ExhibitionReportCaseService
  } = require('../dist/modules/exhibition_report_cases/exhibition-report-case.service.js');
  const {
    ExhibitionReportCasePresenter
  } = require('../dist/modules/exhibition_report_cases/exhibition-report-case.presenter.js');

  return {
    service: new ExhibitionReportCaseService(
      caseRepository,
      verifier,
      eligibility,
      auditService,
      dataSource,
      new ExhibitionReportCasePresenter()
    ),
    cases,
    auditRecords
  };
}

function makeQueryBuilder(items) {
  const state = { offset: 0, limit: 20 };
  const qb = {
    andWhere: () => qb,
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

function makeReportCase(overrides = {}) {
  const createdAt = overrides.createdAt ?? new Date('2026-04-10T01:00:00.000Z');
  return {
    id: 'report-case-1',
    targetType: 'project',
    targetId: 'project-1',
    reasonCode: 'fabricated_project',
    reasonDetail: 'Project material looks fabricated.',
    reporterUserId: 'reporter-user',
    reporterOrganizationId: 'org-1',
    status: 'submitted',
    temporaryRestrictionState: 'not_applied',
    reviewTaskId: 'review-task-1',
    governanceTicketRef: null,
    evidenceFileAssetIds: ['asset-1'],
    explanationRequestedAt: null,
    explanationDueAt: null,
    explanationReceivedAt: null,
    adjudicationResult: null,
    decisionNote: null,
    decidedAt: null,
    closedAt: null,
    metadata: { targetTitle: 'Demo Exhibition Project' },
    createdAt,
    updatedAt: createdAt,
    ...overrides
  };
}

test('report-case queue list and detail expose minimum admin adjudication desk projections', async () => {
  const createdAt = new Date('2026-04-10T03:00:00.000Z');
  const { service } = makeService({
    cases: [
      makeReportCase({
        id: 'report-case-queue-1',
        governanceTicketRef: 'gov-ticket-1',
        explanationRequestedAt: new Date('2026-04-10T04:00:00.000Z'),
        explanationReceivedAt: new Date('2026-04-10T05:00:00.000Z'),
        adjudicationResult: 'partially_established',
        decidedAt: new Date('2026-04-10T06:00:00.000Z'),
        decisionNote: 'Need controlled follow-up.',
        createdAt,
        updatedAt: createdAt
      })
    ]
  });

  const list = await service.list({ page: '1', pageSize: '10' }, context);
  const detail = await service.detail('report-case-queue-1', context);

  assert.equal(list.pagination.total, 1);
  assert.deepEqual(list.items[0], {
    reportCaseId: 'report-case-queue-1',
    targetType: 'project',
    targetId: 'project-1',
    reasonCode: 'fabricated_project',
    status: 'submitted',
    temporaryRestrictionState: 'not_applied',
    submittedAt: createdAt.toISOString()
  });
  assert.equal(detail.reportCaseId, 'report-case-queue-1');
  assert.equal(detail.reviewTaskId, 'review-task-1');
  assert.equal(detail.governanceTicketId, 'gov-ticket-1');
  assert.equal(detail.reasonDetail, 'Project material looks fabricated.');
  assert.equal(detail.reporter.actorId, 'reporter-user');
  assert.equal(detail.adjudicationResult, 'partially_established');
  assert.equal(detail.decisionNote, 'Need controlled follow-up.');
});

test('request-explanation records question, dueAt, state, and reviewer audit attribution', async () => {
  const reportCase = makeReportCase({ id: 'report-case-request-1' });
  const { service, auditRecords } = makeService({ cases: [reportCase] });

  const ack = await service.requestExplanation(
    'report-case-request-1',
    {
      question: 'Please explain the source of the submitted project materials.',
      dueAt: '2026-04-12T12:00:00.000Z'
    },
    context
  );

  assert.deepEqual(ack, { ok: true, traceId: context.traceId });
  assert.equal(reportCase.status, 'explanation_requested');
  assert.ok(reportCase.explanationRequestedAt instanceof Date);
  assert.equal(
    reportCase.explanationDueAt.toISOString(),
    '2026-04-12T12:00:00.000Z'
  );
  assert.equal(
    reportCase.metadata.explanationQuestion,
    'Please explain the source of the submitted project materials.'
  );
  assert.equal(auditRecords.length, 1);
  assert.equal(auditRecords[0].action, 'exhibition_report_case_request_explanation');
  assert.equal(auditRecords[0].actorId, context.actorId);
});

test('decide writes adjudication result, lifts active temporary restriction when not established, and audits', async () => {
  const reportCase = makeReportCase({
    id: 'report-case-decide-1',
    status: 'escalated',
    temporaryRestrictionState: 'active'
  });
  const { service, auditRecords } = makeService({ cases: [reportCase] });

  const ack = await service.decide(
    'report-case-decide-1',
    {
      adjudicationResult: 'not_established',
      decisionNote: 'Evidence does not establish the allegation.'
    },
    context
  );

  assert.deepEqual(ack, { ok: true, traceId: context.traceId });
  assert.equal(reportCase.status, 'decided');
  assert.equal(reportCase.adjudicationResult, 'not_established');
  assert.equal(reportCase.decisionNote, 'Evidence does not establish the allegation.');
  assert.equal(reportCase.temporaryRestrictionState, 'lifted');
  assert.ok(reportCase.decidedAt instanceof Date);
  assert.equal(auditRecords.length, 1);
  assert.equal(auditRecords[0].action, 'exhibition_report_case_decide');
  assert.equal(auditRecords[0].metadata.nextStatus, 'decided');
  assert.equal(auditRecords[0].metadata.nextTemporaryRestrictionState, 'lifted');
});

test('escalate opens a governance ticket ref, activates restriction overlay, and audits', async () => {
  const reportCase = makeReportCase({
    id: 'report-case-escalate-1',
    status: 'under_review',
    temporaryRestrictionState: 'not_applied'
  });
  const { service, auditRecords } = makeService({ cases: [reportCase] });

  const ack = await service.escalate(
    'report-case-escalate-1',
    { reason: 'Pattern indicates coordinated fraud risk.' },
    context
  );

  assert.deepEqual(ack, { ok: true, traceId: context.traceId });
  assert.equal(reportCase.status, 'escalated');
  assert.equal(reportCase.temporaryRestrictionState, 'active');
  assert.match(reportCase.governanceTicketRef, /^gov-[a-z0-9]{24}$/);
  assert.equal(reportCase.metadata.escalationReason, 'Pattern indicates coordinated fraud risk.');
  assert.equal(auditRecords.length, 1);
  assert.equal(auditRecords[0].action, 'exhibition_report_case_escalate');
  assert.equal(
    auditRecords[0].metadata.temporaryRestrictionState,
    'active'
  );
});

test('migration registry includes exhibition_report_cases truth and no second ticket table', () => {
  const {
    exhibitionReportCaseP0Migrations,
    serverMigrations
  } = require('../dist/core/migrations/migrations.js');
  const migration = exhibitionReportCaseP0Migrations.find(
    (item) => item.key === '20260411_exhibition_report_case_p0_truth'
  );

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  const joined = migration.statements.join('\n');
  assert.match(joined, /CREATE TABLE IF NOT EXISTS exhibition_report_cases/);
  assert.match(joined, /temporary_restriction_state varchar\(32\) NOT NULL DEFAULT 'not_applied'/);
  assert.match(joined, /CREATE UNIQUE INDEX IF NOT EXISTS idx_exhibition_report_cases_active_reporter_target_reason/);
  assert.doesNotMatch(joined, /CREATE TABLE IF NOT EXISTS report_evidences/);
  assert.doesNotMatch(joined, /CREATE TABLE IF NOT EXISTS governance_tickets/);
});
