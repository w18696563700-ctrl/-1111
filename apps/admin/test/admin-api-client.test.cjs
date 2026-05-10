/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

const client = require('../test-dist/core/server/admin-api-client.js');

test.afterEach(() => {
  client.setAdminApiRuntimeForTest(null);
});

test('review transport list/detail/action calls Server Admin API with the same session carrier', async () => {
  const calls = installRuntime({ items: [], count: 0, traceId: 'trace-review' });

  await client.fetchContentSafetyReviewTasks();
  await client.fetchContentSafetyReviewTask('profile_safety_submission:submission-1');
  await client.approveProfileSafetySubmission('submission-1', { reviewNote: 'looks good' });
  await client.rejectProfileSafetySubmission('submission-1', { reason: 'manual reject' });
  await client.decideForumReport('ticket-1', {
    decision: 'resolved',
    reason: 'confirmed report',
  });

  assert.equal(calls.length, 5);
  assert.equal(
    calls[0].url,
    'http://server.test/server/admin/content-safety/review-tasks',
  );
  assert.equal(
    calls[1].url,
    'http://server.test/server/admin/content-safety/review-tasks/profile_safety_submission%3Asubmission-1',
  );
  assert.equal(
    calls[2].url,
    'http://server.test/server/admin/content-safety/profile-submissions/submission-1/approve',
  );
  assert.equal(
    calls[3].url,
    'http://server.test/server/admin/content-safety/profile-submissions/submission-1/reject',
  );
  assert.equal(
    calls[4].url,
    'http://server.test/server/admin/content-safety/forum-reports/ticket-1/decide',
  );
  assert.equal(calls[2].options.body, JSON.stringify({ reviewNote: 'looks good' }));
  assert.equal(calls[3].options.body, JSON.stringify({ reason: 'manual reject' }));
  assert.equal(
    calls[4].options.body,
    JSON.stringify({
      decision: 'resolved',
      reason: 'confirmed report',
    }),
  );
  assertForwardedCarrierHeaders(calls[0].options.headers);
  assert.equal(calls[0].options.method, 'GET');
  assert.equal(calls[2].options.method, 'POST');
  assert.equal(calls[2].options.headers['content-type'], 'application/json');
});

test('organization review transport list/detail/approve/reject stays on Server Admin API without content-safety task semantics', async () => {
  const calls = installRuntime({
    items: [],
    pagination: { page: 1, pageSize: 20, total: 0, hasMore: false },
    traceId: 'trace-organization-review',
  });

  await client.fetchAdminOrganizationReviews({
    page: 1,
    pageSize: 20,
    status: 'pending_review',
    organizationId: 'organization-1',
    keyword: 'exhibition',
  });
  await client.fetchAdminOrganizationReview('organization-1');
  await client.approveAdminOrganizationReview('organization-1', { note: 'documents verified' });
  await client.rejectAdminOrganizationReview('organization-1', {
    reason: 'license not readable',
    note: 'need clearer upload',
  });

  assert.equal(calls.length, 4);
  assert.equal(
    calls[0].url,
    'http://server.test/server/admin/reviews/organizations?page=1&pageSize=20&status=pending_review&organizationId=organization-1&keyword=exhibition',
  );
  assert.equal(
    calls[1].url,
    'http://server.test/server/admin/reviews/organizations/organization-1',
  );
  assert.equal(
    calls[2].url,
    'http://server.test/server/admin/reviews/organizations/organization-1/approve',
  );
  assert.equal(
    calls[3].url,
    'http://server.test/server/admin/reviews/organizations/organization-1/reject',
  );
  assertForwardedCarrierHeaders(calls[0].options.headers);
  assert.equal(calls[2].options.method, 'POST');
  assert.equal(calls[3].options.method, 'POST');
  assert.equal(calls[2].options.body, JSON.stringify({ note: 'documents verified' }));
  assert.equal(
    calls[3].options.body,
    JSON.stringify({
      reason: 'license not readable',
      note: 'need clearer upload',
    }),
  );
});

test('organization review client surfaces ORG_REVIEW error codes as AdminApiError', async () => {
  const cases = [
    {
      label: 'approve invalid state',
      invoke: () =>
        client.approveAdminOrganizationReview('organization-1', {
          note: 'documents verified',
        }),
      status: 409,
      code: 'ORG_REVIEW_INVALID_STATE',
      message: 'Current certification state does not allow approve.',
    },
    {
      label: 'approve invalid payload',
      invoke: () =>
        client.approveAdminOrganizationReview('organization-1', {
          note: 'documents verified',
        }),
      status: 400,
      code: 'ORG_REVIEW_APPROVE_INVALID',
      message: 'Organization review approve requires an existing certification file truth.',
    },
    {
      label: 'reject invalid body',
      invoke: () => client.rejectAdminOrganizationReview('organization-1', {}),
      status: 400,
      code: 'ORG_REVIEW_REJECT_INVALID',
      message: 'Field `reason` is required.',
    },
    {
      label: 'detail resource unavailable',
      invoke: () => client.fetchAdminOrganizationReview('organization-404'),
      status: 404,
      code: 'ORG_REVIEW_RESOURCE_UNAVAILABLE',
      message: 'Current organization review resource is unavailable.',
    },
  ];

  for (const item of cases) {
    client.setAdminApiRuntimeForTest(async () => ({
      fetchImpl: async () =>
        new Response(
          JSON.stringify({
            code: item.code,
            message: item.message,
          }),
          {
            status: item.status,
            headers: { 'content-type': 'application/json' },
          },
        ),
      serverAdminApiBaseUrl: 'http://server.test/server/admin',
      incomingHeaders: new Headers(),
      sessionCarrier: 'opaque-access-carrier',
    }));

    await assert.rejects(
      item.invoke,
      (error) =>
        error instanceof client.AdminApiError &&
        error.code === item.code &&
        error.message === item.message,
      item.label,
    );
  }
});

test('governance penalties transport list/detail/apply stays on Server Admin API', async () => {
  const calls = installRuntime({
    items: [],
    pagination: { page: 1, pageSize: 20, total: 0, hasMore: false },
  });

  await client.fetchGovernancePenalties({ page: 1, pageSize: 20, status: 'active' });
  await client.fetchGovernancePenalty('penalty-1');
  await client.applyGovernancePenalty({
    subjectType: 'organization',
    subjectId: '11111111-1111-4111-8111-111111111111',
    penaltyType: 'warning',
    reasonCode: 'manual_review_violation',
    reasonSummary: 'Penalty from admin workbench.',
    evidenceFileAssetIds: ['asset-1'],
  });

  assert.equal(calls.length, 3);
  assert.equal(
    calls[0].url,
    'http://server.test/server/admin/governance/penalties?page=1&pageSize=20&status=active',
  );
  assert.equal(
    calls[1].url,
    'http://server.test/server/admin/governance/penalties/penalty-1',
  );
  assert.equal(
    calls[2].url,
    'http://server.test/server/admin/governance/penalties',
  );
  assertForwardedCarrierHeaders(calls[2].options.headers);
  assert.equal(calls[2].options.method, 'POST');
  assert.equal(
    calls[2].options.body,
    JSON.stringify({
      subjectType: 'organization',
      subjectId: '11111111-1111-4111-8111-111111111111',
      penaltyType: 'warning',
      reasonCode: 'manual_review_violation',
      reasonSummary: 'Penalty from admin workbench.',
      evidenceFileAssetIds: ['asset-1'],
    }),
  );
});

test('governance appeals transport list/detail/decide stays on Server Admin API', async () => {
  const calls = installRuntime({
    items: [],
    pagination: { page: 1, pageSize: 20, total: 0, hasMore: false },
  });

  await client.fetchGovernanceAppeals({ keyword: 'appeal-1', status: 'submitted' });
  await client.fetchGovernanceAppeal('appeal-1');
  await client.decideGovernanceAppeal('appeal-1', {
    decision: 'revoke',
    decisionNote: 'Decision from admin workbench.',
  });

  assert.equal(calls.length, 3);
  const appealListUrl = new URL(calls[0].url);
  assert.equal(
    `${appealListUrl.origin}${appealListUrl.pathname}`,
    'http://server.test/server/admin/governance/appeals',
  );
  assert.equal(appealListUrl.searchParams.get('status'), 'submitted');
  assert.equal(appealListUrl.searchParams.get('keyword'), 'appeal-1');
  assert.equal(
    calls[1].url,
    'http://server.test/server/admin/governance/appeals/appeal-1',
  );
  assert.equal(
    calls[2].url,
    'http://server.test/server/admin/governance/appeals/appeal-1/decide',
  );
  assertForwardedCarrierHeaders(calls[1].options.headers);
  assert.equal(calls[2].options.method, 'POST');
  assert.equal(
    calls[2].options.body,
    JSON.stringify({
      decision: 'revoke',
      decisionNote: 'Decision from admin workbench.',
    }),
  );
});

test('exhibition report-cases transport list/detail/request-explanation/decide/escalate stays on Server Admin API', async () => {
  const calls = installRuntime({
    items: [],
    pagination: { page: 1, pageSize: 20, total: 0, hasMore: false },
  });

  await client.fetchExhibitionReportCases({
    page: 1,
    pageSize: 20,
    status: 'submitted',
    targetType: 'project',
    keyword: 'report-case-1',
  });
  await client.fetchExhibitionReportCase('report-case-1');
  await client.requestExhibitionReportExplanation('report-case-1', {
    question: 'Please explain the source.',
    dueAt: '2026-04-12T12:00:00.000Z',
  });
  await client.decideExhibitionReportCase('report-case-1', {
    adjudicationResult: 'partially_established',
    decisionNote: 'Need controlled follow-up.',
  });
  await client.escalateExhibitionReportCase('report-case-1', {
    reason: 'Fraud risk needs governance follow-up.',
  });

  assert.equal(calls.length, 5);
  assert.equal(
    calls[0].url,
    'http://server.test/server/admin/exhibition/report-cases?page=1&pageSize=20&status=submitted&targetType=project&keyword=report-case-1',
  );
  assert.equal(
    calls[1].url,
    'http://server.test/server/admin/exhibition/report-cases/report-case-1',
  );
  assert.equal(
    calls[2].url,
    'http://server.test/server/admin/exhibition/report-cases/report-case-1/request-explanation',
  );
  assert.equal(
    calls[3].url,
    'http://server.test/server/admin/exhibition/report-cases/report-case-1/decide',
  );
  assert.equal(
    calls[4].url,
    'http://server.test/server/admin/exhibition/report-cases/report-case-1/escalate',
  );
  assertForwardedCarrierHeaders(calls[4].options.headers);
  assert.equal(calls[2].options.method, 'POST');
  assert.equal(
    calls[2].options.body,
    JSON.stringify({
      question: 'Please explain the source.',
      dueAt: '2026-04-12T12:00:00.000Z',
    }),
  );
  assert.equal(
    calls[3].options.body,
    JSON.stringify({
      adjudicationResult: 'partially_established',
      decisionNote: 'Need controlled follow-up.',
    }),
  );
  assert.equal(
    calls[4].options.body,
    JSON.stringify({
      reason: 'Fraud risk needs governance follow-up.',
    }),
  );
});

test('audit logs transport list/detail stays on Server Admin API and preserves read-only filters', async () => {
  const calls = installRuntime({
    items: [],
    pagination: { page: 1, pageSize: 20, total: 0 },
  });

  await client.fetchAdminAuditLogs({
    sourceFamily: 'identity',
    objectType: 'organization_certification',
    requestId: 'request-1',
    traceId: 'trace-1',
    page: 1,
    pageSize: 20,
  });
  await client.fetchAdminAuditLog('identity:11111111-1111-4111-8111-111111111111');

  assert.equal(calls.length, 2);
  assert.equal(
    calls[0].url,
    'http://server.test/server/admin/audit/logs?sourceFamily=identity&objectType=organization_certification&requestId=request-1&traceId=trace-1&page=1&pageSize=20',
  );
  assert.equal(
    calls[1].url,
    'http://server.test/server/admin/audit/logs/identity%3A11111111-1111-4111-8111-111111111111',
  );
  assertForwardedCarrierHeaders(calls[0].options.headers);
  assert.equal(calls[0].options.method, 'GET');
  assert.equal(calls[1].options.method, 'GET');
});

test('enterprise hub published-change transport list/detail/review/apply stays on Server Admin API', async () => {
  const calls = installRuntime({
    items: [],
    pagination: { page: 1, pageSize: 20, total: 0, hasMore: false },
  });

  await client.fetchEnterpriseHubChangeRequests({ page: 1, pageSize: 20 });
  await client.fetchEnterpriseHubChangeRequest('change-request-1');
  await client.reviewEnterpriseHubChangeRequest('change-request-1', {
    action: 'approved',
    reviewNote: 'review pass',
  });
  await client.applyEnterpriseHubChangeRequest('change-request-1');

  assert.equal(calls.length, 4);
  assert.equal(
    calls[0].url,
    'http://server.test/server/admin/exhibition/enterprise-hub/change-requests?page=1&pageSize=20',
  );
  assert.equal(
    calls[1].url,
    'http://server.test/server/admin/exhibition/enterprise-hub/change-requests/change-request-1',
  );
  assert.equal(
    calls[2].url,
    'http://server.test/server/admin/exhibition/enterprise-hub/change-requests/change-request-1/review',
  );
  assert.equal(
    calls[3].url,
    'http://server.test/server/admin/exhibition/enterprise-hub/change-requests/change-request-1/apply',
  );
  assertForwardedCarrierHeaders(calls[3].options.headers);
  assert.equal(calls[2].options.method, 'POST');
  assert.equal(calls[3].options.method, 'POST');
  assert.equal(
    calls[2].options.body,
    JSON.stringify({
      action: 'approved',
      reviewNote: 'review pass',
    }),
  );
});

test('enterprise hub application review transport list/detail/review stays on Server Admin API with dedicated applications semantics', async () => {
  const calls = installRuntime({
    items: [],
    pagination: { page: 1, pageSize: 20, total: 0, hasMore: false },
  });

  await client.fetchEnterpriseHubApplicationReviews({
    page: 1,
    pageSize: 20,
    applicationStatus: 'submitted',
    boardType: 'company',
  });
  await client.fetchEnterpriseHubApplicationReview('application-1');
  await client.reviewEnterpriseHubApplication('application-1', {
    action: 'revision_required',
    reason: 'profile_incomplete',
    reviewNote: 'need factory and staffing detail',
  });

  assert.equal(calls.length, 3);
  assert.equal(
    calls[0].url,
    'http://server.test/server/admin/exhibition/enterprise-hub/applications?page=1&pageSize=20&applicationStatus=submitted&boardType=company',
  );
  assert.equal(
    calls[1].url,
    'http://server.test/server/admin/exhibition/enterprise-hub/applications/application-1',
  );
  assert.equal(
    calls[2].url,
    'http://server.test/server/admin/exhibition/enterprise-hub/applications/application-1/review',
  );
  assertForwardedCarrierHeaders(calls[2].options.headers);
  assert.equal(calls[2].options.method, 'POST');
  assert.equal(
    calls[2].options.body,
    JSON.stringify({
      action: 'revision_required',
      reason: 'profile_incomplete',
      reviewNote: 'need factory and staffing detail',
    }),
  );
});

test('enterprise hub application review client surfaces ENTERPRISE_HUB domain errors as AdminApiError', async () => {
  client.setAdminApiRuntimeForTest(async () => ({
    fetchImpl: async () =>
      new Response(
        JSON.stringify({
          code: 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
          message: 'Review reason is required.',
        }),
        {
          status: 400,
          headers: { 'content-type': 'application/json' },
        },
      ),
    serverAdminApiBaseUrl: 'http://server.test/server/admin',
    incomingHeaders: new Headers(),
    sessionCarrier: 'opaque-access-carrier',
  }));

  await assert.rejects(
    () =>
      client.reviewEnterpriseHubApplication('application-1', {
        action: 'rejected',
      }),
    (error) =>
      error instanceof client.AdminApiError &&
      error.code === 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS' &&
      error.message === 'Review reason is required.',
  );
});

test('session carrier verification probes Server Admin API before cookie write', async () => {
  const calls = installRuntime({ items: [], count: 0, traceId: 'trace-verify' }, {
    sessionCarrier: null,
    incomingHeaders: new Headers([
      ['x-actor-id', 'actor-should-not-forward'],
      ['authorization', 'Bearer stale-carrier'],
    ]),
  });

  await client.verifyAdminSessionCarrier('fresh-session-carrier');

  assert.equal(calls.length, 1);
  assert.equal(
    calls[0].url,
    'http://server.test/server/admin/content-safety/review-tasks',
  );
  assert.equal(
    calls[0].options.headers.authorization,
    'Bearer fresh-session-carrier',
  );
  assert.equal(calls[0].options.headers['x-actor-id'], undefined);
});

test('admin runtime prefers admin_session over incoming Authorization', async () => {
  const calls = installRuntime({ items: [], count: 0, traceId: 'trace-cookie-first' }, {
    sessionCarrier: 'opaque-access-carrier',
    incomingHeaders: new Headers([
      ['authorization', 'Bearer stale-incoming-carrier'],
      ['x-request-id', 'request-cookie-first'],
    ]),
  });

  await client.fetchContentSafetyReviewTasks();

  assert.equal(calls.length, 1);
  assert.equal(calls[0].options.headers.authorization, 'Bearer opaque-access-carrier');
  assert.equal(calls[0].options.headers['x-request-id'], 'request-cookie-first');
});

test('admin runtime does not promote incoming Authorization without admin_session', async () => {
  const calls = installRuntime({ items: [], count: 0, traceId: 'trace-no-cookie' }, {
    sessionCarrier: null,
    incomingHeaders: new Headers([
      ['authorization', 'Bearer stale-incoming-carrier'],
      ['x-request-id', 'request-no-cookie'],
    ]),
  });

  await client.fetchContentSafetyReviewTasks();

  assert.equal(calls.length, 1);
  assert.equal(calls[0].options.headers.authorization, undefined);
  assert.equal(calls[0].options.headers['x-request-id'], 'request-no-cookie');
});

test('membership admin transport stays read-only on Server Admin API', async () => {
  const calls = installRuntime({
    items: [],
    pagination: { page: 1, pageSize: 20, total: 0, hasMore: false },
    readOnly: true,
    writeActionsEnabled: false,
  });

  await client.fetchAdminMembershipOrders({
    organizationId: 'org-1',
    orderStatus: 'active',
    paymentStatus: 'succeeded',
    entitlementStatus: 'active',
    page: 1,
    pageSize: 20,
  });
  await client.fetchAdminMembershipOrder('membership-order-1');
  await client.fetchAdminMembershipStatus('org-1');

  assert.equal(calls.length, 3);
  assert.equal(
    calls[0].url,
    'http://server.test/server/admin/membership/orders?organizationId=org-1&orderStatus=active&paymentStatus=succeeded&entitlementStatus=active&page=1&pageSize=20',
  );
  assert.equal(
    calls[1].url,
    'http://server.test/server/admin/membership/orders/membership-order-1',
  );
  assert.equal(
    calls[2].url,
    'http://server.test/server/admin/membership/organizations/org-1/status',
  );
  assertForwardedCarrierHeaders(calls[0].options.headers);
  assert.equal(calls[0].options.method, 'GET');
  assert.equal(calls[1].options.method, 'GET');
  assert.equal(calls[2].options.method, 'GET');
  assert.equal(calls[0].options.body, undefined);
});

function installRuntime(responseBody, overrides = {}) {
  const calls = [];
  client.setAdminApiRuntimeForTest(async () => ({
    fetchImpl: async (url, options) => {
      calls.push({ url, options });
      return new Response(JSON.stringify(responseBody), {
        status: 200,
        headers: { 'content-type': 'application/json' },
      });
    },
    serverAdminApiBaseUrl: 'http://server.test/server/admin',
    incomingHeaders: new Headers([
      ['x-actor-id', 'actor-1'],
      ['x-user-id', 'user-1'],
      ['x-organization-id', 'org-1'],
      ['x-actor-role', 'platform_reviewer'],
      ['x-role', 'platform_reviewer'],
      ['x-request-id', 'request-1'],
      ['x-trace-id', 'trace-1'],
    ]),
    sessionCarrier: 'opaque-access-carrier',
    ...overrides,
  }));
  return calls;
}

function assertForwardedCarrierHeaders(headers) {
  assert.equal(headers.authorization, 'Bearer opaque-access-carrier');
  assert.equal(headers['x-admin-client'], 'admin-governance-console');
  assert.equal(headers['x-actor-id'], 'actor-1');
  assert.equal(headers['x-user-id'], 'user-1');
  assert.equal(headers['x-organization-id'], 'org-1');
  assert.equal(headers['x-actor-role'], 'platform_reviewer');
  assert.equal(headers['x-role'], 'platform_reviewer');
  assert.equal(headers['x-request-id'], 'request-1');
  assert.equal(headers['x-trace-id'], 'trace-1');
}
