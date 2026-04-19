/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

const {
  AdminApiError,
} = require('../test-dist/core/server/admin-api-client.js');
const {
  buildApproveChangeReviewPayload,
  buildRejectedChangeReviewPayload,
  buildRevisionRequiredChangeReviewPayload,
  readChangeRequestId,
  toPublishedChangeActionError,
} = require('../test-dist/modules/published_change_review/published-change-review-form.js');
const {
  describePublishedChangeStatus,
  loadPublishedChangeReviewState,
} = require('../test-dist/modules/published_change_review/published-change-review-state.js');

test('published change review queue/detail consumption selects the first change request and reads both change snapshot and live snapshot', async () => {
  const calls = [];
  const state = await loadPublishedChangeReviewState(
    {},
    {
      fetchList: async (query) => {
        calls.push({ kind: 'list', query });
        return {
          items: [
            {
              changeRequestId: 'change-request-1',
              enterpriseId: 'enterprise-1',
              boardType: 'company',
              enterpriseName: '已发布企业',
              changeStatus: 'approved',
              submittedAt: '2026-04-12T01:00:00.000Z',
              reviewedAt: '2026-04-12T02:00:00.000Z',
              appliedAt: null,
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
      fetchDetail: async (changeRequestId) => {
        calls.push({ kind: 'detail', changeRequestId });
        return {
          changeRequest: {
            changeRequestId,
            enterpriseId: 'enterprise-1',
            boardType: 'company',
            changeStatus: 'approved',
            submittedAt: '2026-04-12T01:00:00.000Z',
            reviewedAt: '2026-04-12T02:00:00.000Z',
            appliedAt: null,
            reviewNote: 'looks good',
          },
          enterprise: {
            enterpriseId: 'enterprise-1',
            organizationId: 'org-1',
            name: '已发布企业',
            primaryBoardType: 'company',
            secondaryCapabilities: [],
            enterpriseStatus: 'published',
            displayStatus: 'visible',
          },
          liveSnapshot: {
            enterpriseStatus: 'published',
            displayStatus: 'visible',
            publishedAt: '2026-04-10T08:00:00.000Z',
          },
          basic: {
            name: '变更后的企业名',
            shortIntro: '变更后的简介',
            contactVisible: true,
          },
          boardProfile: {
            exhibitionTypes: ['expo'],
          },
          primaryContact: {
            contactName: '李四',
            mobile: '13800000000',
            wechat: null,
            phone: null,
            email: null,
            position: null,
            isPrimary: true,
            visibleToPublic: true,
          },
          cases: [
            {
              caseId: 'case-1',
              boardType: 'company',
              title: '变更案例',
              exhibitionType: 'expo',
              city: '上海',
              eventTime: '2026-04-01',
              summary: '案例摘要',
              caseCoverFileAssetId: 'cover-1',
              caseMediaFileAssetIds: ['cover-1'],
              isFeatured: true,
              caseStatus: 'approved',
            },
          ],
        };
      },
    },
  );

  assert.deepEqual(calls, [
    {
      kind: 'list',
      query: {
        page: 1,
        pageSize: 20,
      },
    },
    {
      kind: 'detail',
      changeRequestId: 'change-request-1',
    },
  ]);
  assert.equal(state.total, 1);
  assert.equal(state.items[0].changeRequestId, 'change-request-1');
  assert.equal(state.detail.changeRequest.changeRequestId, 'change-request-1');
  assert.equal(state.detail.liveSnapshot.displayStatus, 'visible');
  assert.equal(state.detail.basic.name, '变更后的企业名');
  assert.equal(state.statusSummary.label, '已审核通过，待 apply');
  assert.equal(state.statusSummary.canApply, true);
  assert.equal(state.error, null);
});

test('published change review queue/detail consumption surfaces controlled Server Admin API errors', async () => {
  const state = await loadPublishedChangeReviewState(
    { selectedChangeRequestId: 'missing' },
    {
      fetchList: async () => {
        throw new AdminApiError(
          409,
          'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
          'invalid state',
          null,
        );
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
    error: 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION: invalid state',
    statusSummary: null,
  });
});

test('published change review form builders submit three review decisions and require reasons for revision_required or rejected', () => {
  const approveForm = new FormData();
  approveForm.set('changeRequestId', 'change-request-1');
  approveForm.set('reviewNote', 'passed');

  const revisionForm = new FormData();
  revisionForm.set('changeRequestId', 'change-request-1');
  revisionForm.set('reviewNote', '请补充案例说明');

  const rejectForm = new FormData();
  rejectForm.set('changeRequestId', 'change-request-1');
  rejectForm.set('reviewNote', '当前变更不应进入上线');

  assert.equal(readChangeRequestId(approveForm), 'change-request-1');
  assert.deepEqual(buildApproveChangeReviewPayload(approveForm), {
    action: 'approved',
    reviewNote: 'passed',
  });
  assert.deepEqual(buildRevisionRequiredChangeReviewPayload(revisionForm), {
    action: 'revision_required',
    reviewNote: '请补充案例说明',
  });
  assert.deepEqual(buildRejectedChangeReviewPayload(rejectForm), {
    action: 'rejected',
    reviewNote: '当前变更不应进入上线',
  });

  const invalidRevisionForm = new FormData();
  invalidRevisionForm.set('changeRequestId', 'change-request-1');
  assert.throws(
    () => buildRevisionRequiredChangeReviewPayload(invalidRevisionForm),
    /reviewNote 为必填项/,
  );
  assert.throws(
    () => buildRejectedChangeReviewPayload(new FormData()),
    /reviewNote 为必填项/,
  );
});

test('published change status summary keeps approved and applied distinct and only approved exposes apply', () => {
  const submitted = describePublishedChangeStatus('submitted');
  const approved = describePublishedChangeStatus('approved');
  const applied = describePublishedChangeStatus('applied');

  assert.equal(submitted.canReview, true);
  assert.equal(submitted.canApply, false);
  assert.equal(approved.canReview, false);
  assert.equal(approved.canApply, true);
  assert.match(approved.description, /尚未 apply 到 live listing/);
  assert.equal(applied.canApply, false);
  assert.match(applied.description, /已.*live listing/);
});

test('invalid transition is surfaced as page error text instead of success notice text', () => {
  const error = new AdminApiError(
    409,
    'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
    'apply is not allowed',
    null,
  );

  assert.equal(
    toPublishedChangeActionError(error),
    'ENTERPRISE_HUB_INVALID_STATE_TRANSITION: apply is not allowed',
  );
});
