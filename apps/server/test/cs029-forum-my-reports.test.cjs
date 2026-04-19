const test = require('node:test');
const assert = require('node:assert/strict');

const context = {
  authorization: 'Bearer test',
  actorId: 'reporter-user',
  userId: 'reporter-user',
  organizationId: 'org-1',
  actorRole: 'buyer_admin',
  requestId: 'request-cs029',
  traceId: 'trace-cs029',
};

function makeTicket(overrides = {}) {
  return {
    id: 'ticket-own-1',
    targetType: 'post',
    targetId: 'post-1',
    targetAuthorUserId: 'author-1',
    targetOrganizationId: 'org-author',
    reporterUserId: 'reporter-user',
    reporterActorId: 'reporter-user',
    reporterOrganizationId: 'org-1',
    reasonCode: 'spam',
    reasonDetail: 'visible only in detail',
    status: 'submitted',
    targetSnapshot: {
      targetType: 'post',
      postId: 'post-1',
      topicId: 'topic-1',
      title: 'Reported post',
      body: 'body must not be exposed as a raw full snapshot field',
      excerpt: 'short post excerpt',
      state: 'published',
      publishedAt: '2026-04-07T00:00:00.000Z',
    },
    createdAt: new Date('2026-04-07T00:00:00.000Z'),
    updatedAt: new Date('2026-04-07T01:00:00.000Z'),
    ...overrides,
  };
}

function makeService(options = {}) {
  const tickets = options.tickets ?? [makeTicket()];
  const calls = [];
  const reportRepository = {
    find: async (query) => {
      calls.push(['find', query]);
      return tickets.filter((ticket) => ticket.reporterUserId === query.where.reporterUserId);
    },
    findOneBy: async (query) => {
      calls.push(['findOneBy', query]);
      return tickets.find(
        (ticket) => ticket.id === query.id && ticket.reporterUserId === query.reporterUserId
      ) ?? null;
    },
  };
  const verifier = options.verifier ?? {
    verifyCurrentSessionContext: async () => ({
      outcome: 'verified',
      currentSession: {
        sessionId: 'session-1',
        actorId: context.actorId,
        userId: context.userId,
        organizationId: context.organizationId,
        requestId: context.requestId,
        traceId: context.traceId,
      },
    }),
  };
  const eligibility = options.eligibility ?? {
    requireAuthenticatedActor: async () => ({ id: context.userId, status: 'active' }),
  };

  const { ForumReportQueryService } = require('../dist/modules/forum/forum-report.query.service.js');
  const { ForumReportPresenter } = require('../dist/modules/forum/forum-report.presenter.js');
  return {
    calls,
    service: new ForumReportQueryService(
      reportRepository,
      new ForumReportPresenter(),
      verifier,
      eligibility
    ),
  };
}

function hasErrorCode(expectedCode) {
  return (error) => error?.getResponse?.().code === expectedCode;
}

test('CS-029 listMine returns only current reporter minimal fields', async () => {
  const otherTicket = makeTicket({ id: 'ticket-other-1', reporterUserId: 'other-user' });
  const { calls, service } = makeService({ tickets: [makeTicket(), otherTicket] });

  const result = await service.listMine({ limit: '10' }, context);

  assert.equal(calls[0][0], 'find');
  assert.equal(calls[0][1].where.reporterUserId, 'reporter-user');
  assert.equal(result.count, 1);
  assert.equal(result.items[0].ticketId, 'ticket-own-1');
  assert.equal(result.items[0].reasonCode, 'spam');
  assert.equal(result.items[0].targetSnapshot.excerpt, 'short post excerpt');
  assert.equal(Object.hasOwn(result.items[0], 'reasonDetail'), false);
  assert.equal(Object.hasOwn(result.items[0], 'reporterUserId'), false);
  assert.equal(Object.hasOwn(result.items[0].targetSnapshot, 'body'), false);
});

test('CS-029 detail scopes lookup by current reporter and hides internal fields', async () => {
  const { calls, service } = makeService();

  const result = await service.getMineReportTicket('ticket-own-1', context);

  assert.equal(calls[0][0], 'findOneBy');
  assert.deepEqual(calls[0][1], { id: 'ticket-own-1', reporterUserId: 'reporter-user' });
  assert.equal(result.ticketId, 'ticket-own-1');
  assert.equal(result.reasonDetail, 'visible only in detail');
  assert.equal(Object.hasOwn(result, 'reporterUserId'), false);
  assert.equal(Object.hasOwn(result, 'reporterActorId'), false);
  assert.equal(Object.hasOwn(result, 'reviewerNotes'), false);
});

test('CS-029 detail rejects invalid and non-owned tickets with controlled errors', async () => {
  const { service } = makeService();

  await assert.rejects(
    () => service.getMineReportTicket('', context),
    hasErrorCode('FORUM_REPORT_INVALID')
  );
  await assert.rejects(
    () => service.getMineReportTicket('ticket-other-1', context),
    hasErrorCode('FORUM_REPORT_UNAVAILABLE')
  );
});

test('CS-029 mine routes require verified current session', async () => {
  const { service } = makeService({
    verifier: {
      verifyCurrentSessionContext: async () => ({
        outcome: 'failed',
        reason: 'missing_current_session_carrier',
        requestId: context.requestId,
        traceId: context.traceId,
      }),
    },
  });

  await assert.rejects(
    () => service.listMine({}, context),
    hasErrorCode('AUTH_SESSION_INVALID')
  );
});
