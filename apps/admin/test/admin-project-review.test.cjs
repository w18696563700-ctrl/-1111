/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

const {
  AdminApiError,
} = require('../test-dist/core/server/admin-api-client.js');
const {
  buildDecideReportCasePayload,
  buildEscalateReportCasePayload,
  buildRequestExplanationPayload,
  readReportCaseId,
} = require('../test-dist/modules/project_review/project-review-form.js');
const {
  loadProjectReviewState,
} = require('../test-dist/modules/project_review/project-review-state.js');

test('project_review queue/detail consumption selects the first report case when none is specified', async () => {
  const calls = [];
  const state = await loadProjectReviewState(
    {},
    {
      fetchList: async () => {
        calls.push('list');
        return {
          items: [
            {
              reportCaseId: 'report-case-1',
              targetType: 'project',
              targetId: 'project-1',
              reasonCode: 'fabricated_project',
              status: 'submitted',
              temporaryRestrictionState: 'not_applied',
              submittedAt: '2026-04-10T01:00:00.000Z',
            },
          ],
          pagination: {
            page: 1,
            pageSize: 20,
            total: 1,
            hasMore: false,
          },
        };
      },
      fetchDetail: async (reportCaseId) => {
        calls.push(`detail:${reportCaseId}`);
        return {
          reportCaseId,
          targetType: 'project',
          targetId: 'project-1',
          reasonCode: 'fabricated_project',
          reasonDetail: 'Project material looks fabricated.',
          status: 'submitted',
          temporaryRestrictionState: 'not_applied',
          reviewTaskId: 'review-task-1',
          governanceTicketId: null,
          submittedAt: '2026-04-10T01:00:00.000Z',
          explanationRequestedAt: null,
          explanationReceivedAt: null,
          adjudicationResult: null,
          decidedAt: null,
          decisionNote: null,
        };
      },
    },
  );

  assert.deepEqual(calls, ['list', 'detail:report-case-1']);
  assert.equal(state.total, 1);
  assert.equal(state.items[0].reportCaseId, 'report-case-1');
  assert.equal(state.detail.reportCaseId, 'report-case-1');
  assert.equal(state.error, null);
});

test('project_review queue/detail consumption surfaces controlled Server Admin API errors', async () => {
  const state = await loadProjectReviewState(
    { selectedReportCaseId: 'report-case-404' },
    {
      fetchList: async () => {
        throw new AdminApiError(404, 'REVIEW_REPORT_RESOURCE_UNAVAILABLE', 'not found', null);
      },
      fetchDetail: async () => {
        throw new Error('should not run');
      },
    },
  );

  assert.deepEqual(state, {
    items: [],
    detail: null,
    total: 0,
    error: 'REVIEW_REPORT_RESOURCE_UNAVAILABLE: not found',
  });
});

test('project_review action consumption builds bounded request/decide/escalate payloads from forms', () => {
  const requestForm = new FormData();
  requestForm.set('reportCaseId', 'report-case-1');
  requestForm.set('question', 'Please explain the source.');
  requestForm.set('dueAt', '2026-04-12T12:00:00.000Z');

  const decideForm = new FormData();
  decideForm.set('reportCaseId', 'report-case-1');
  decideForm.set('adjudicationResult', 'materially_established');
  decideForm.set('decisionNote', 'Evidence materially establishes the report.');

  const escalateForm = new FormData();
  escalateForm.set('reportCaseId', 'report-case-1');
  escalateForm.set('reason', 'Fraud risk needs governance follow-up.');

  assert.equal(readReportCaseId(requestForm), 'report-case-1');
  assert.deepEqual(buildRequestExplanationPayload(requestForm), {
    question: 'Please explain the source.',
    dueAt: '2026-04-12T12:00:00.000Z',
  });
  assert.deepEqual(buildDecideReportCasePayload(decideForm), {
    adjudicationResult: 'materially_established',
    decisionNote: 'Evidence materially establishes the report.',
  });
  assert.deepEqual(buildEscalateReportCasePayload(escalateForm), {
    reason: 'Fraud risk needs governance follow-up.',
  });
});
