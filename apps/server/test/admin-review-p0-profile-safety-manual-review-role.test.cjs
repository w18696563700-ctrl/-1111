const test = require('node:test');
const assert = require('node:assert/strict');

const context = {
  authorization: 'Bearer test',
  actorId: 'reviewer-user',
  userId: 'reviewer-user',
  organizationId: 'buyer-org',
  actorRole: 'buyer_admin',
  requestId: 'request-admin-review-p0',
  traceId: 'trace-admin-review-p0',
};

function makeService() {
  const submission = {
    id: 'submission-1',
    userId: 'target-user',
    fieldKey: 'nickname',
    status: 'pending_review',
    proposedValue: '新昵称',
    proposedFileAssetId: null,
    proposedAvatarUrl: null,
    metadata: {},
    reviewedBy: null,
    reviewedAt: null,
    rejectReasonCode: null,
    rejectReason: null,
  };
  const user = {
    id: 'target-user',
    status: 'active',
    nickname: '旧昵称',
    profileIntro: '旧简介',
    avatarFileAssetId: null,
    avatarUrl: null,
  };
  const auditRecords = [];
  let manualReviewerChecks = 0;

  const submissionRepository = {
    findOneBy: async ({ id }) => (id === submission.id ? submission : null),
    save: async (value) => value,
  };
  const userRepository = {
    findOneBy: async ({ id }) => (id === user.id ? user : null),
    save: async (value) => value,
  };
  const fileAssetRepository = {
    findOneBy: async () => null,
  };
  const manager = {
    getRepository(entity) {
      switch (entity.name) {
        case 'ProfileSafetySubmissionEntity':
          return submissionRepository;
        case 'UserEntity':
          return userRepository;
        case 'FileAssetEntity':
          return fileAssetRepository;
        default:
          throw new Error(`Unexpected repository request: ${entity.name}`);
      }
    },
  };
  const dataSource = {
    transaction: async (callback) => callback(manager),
  };
  const verifier = {
    verifyCurrentSessionContext: async () => ({
      outcome: 'verified',
      currentSession: {
        sessionId: 'session-1',
        actorId: 'reviewer-user',
        userId: 'reviewer-user',
        organizationId: 'buyer-org',
        requestId: context.requestId,
        traceId: context.traceId,
      },
    }),
  };
  const eligibility = {
    requireManualReviewer: async () => {
      manualReviewerChecks += 1;
      return {
        actorRole: 'platform_reviewer',
        organizationId: 'platform-org',
        user: { id: 'reviewer-user', status: 'active' },
      };
    },
  };
  const approvalService = {
    applyApprovedSubmission: async (nextUser, nextSubmission) => {
      if (nextSubmission.fieldKey === 'nickname') {
        nextUser.nickname = nextSubmission.proposedValue;
      }
      return nextUser;
    },
  };
  const auditService = {
    record: async (input) => {
      auditRecords.push(input);
      return input;
    },
  };
  const presenter = {
    toReviewResponse: (nextSubmission, nextUser, requestContext) => ({
      submissionId: nextSubmission.id,
      status: nextSubmission.status,
      reviewedBy: nextSubmission.reviewedBy,
      actorRoleUsed: auditRecords[0]?.actorRole ?? null,
      updatedNickname: nextUser.nickname,
      traceId: requestContext.traceId,
    }),
  };

  const {
    ProfileSafetyReviewService,
  } = require('../dist/modules/profile/profile-safety-review.service.js');

  return {
    submission,
    user,
    auditRecords,
    getManualReviewerChecks: () => manualReviewerChecks,
    service: new ProfileSafetyReviewService(
      dataSource,
      verifier,
      eligibility,
      approvalService,
      auditService,
      presenter,
    ),
  };
}

test('Admin Review P0 profile safety approve derives reviewer role from eligibility instead of request context actorRole', async () => {
  const { service, submission, user, auditRecords, getManualReviewerChecks } =
    makeService();

  const result = await service.approveSubmission(
    submission.id,
    { reviewNote: 'smoke approve' },
    context,
  );

  assert.equal(getManualReviewerChecks(), 1);
  assert.equal(user.nickname, '新昵称');
  assert.equal(submission.status, 'approved');
  assert.equal(submission.reviewedBy, 'reviewer-user');
  assert.equal(auditRecords.length, 2);
  assert.equal(auditRecords[0].actorRole, 'platform_reviewer');
  assert.equal(auditRecords[1].actorRole, 'platform_reviewer');
  assert.deepEqual(result, {
    submissionId: 'submission-1',
    status: 'approved',
    reviewedBy: 'reviewer-user',
    actorRoleUsed: 'platform_reviewer',
    updatedNickname: '新昵称',
    traceId: context.traceId,
  });
});

function createArrayRepository(items) {
  return {
    async find(options = {}) {
      let result = [...items];
      if (options.where) {
        result = result.filter((item) =>
          Object.entries(options.where).every(([key, value]) => item[key] === value),
        );
      }
      if (options.order) {
        const [[field, direction]] = Object.entries(options.order);
        result.sort((left, right) => {
          const leftValue = left[field];
          const rightValue = right[field];
          if (leftValue === rightValue) {
            return 0;
          }
          const factor = String(direction).toUpperCase() === 'DESC' ? -1 : 1;
          return leftValue > rightValue ? factor : -factor;
        });
      }
      if (typeof options.take === 'number') {
        result = result.slice(0, options.take);
      }
      return result;
    },
    async findOneBy(where) {
      return (
        items.find((item) =>
          Object.entries(where).every(([key, value]) => item[key] === value),
        ) ?? null
      );
    },
  };
}

function createReviewTaskContext(authorization, requestId) {
  return {
    authorization,
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

test('S1-C03 review-tasks list/detail return the current minimal profile/forum upstream set', async () => {
  const {
    ContentSafetyReviewTaskQueryService,
  } = require('../dist/modules/content_safety/content-safety-review-task.query.service.js');
  const {
    ContentSafetyReviewTaskPresenter,
  } = require('../dist/modules/content_safety/content-safety-review-task.presenter.js');

  let manualReviewerChecks = 0;
  const profileSubmissionRepository = createArrayRepository([
    {
      id: 'submission-1',
      userId: 'user-1',
      fieldKey: 'nickname',
      status: 'pending_review',
      currentValue: '旧昵称',
      proposedValue: '新昵称',
      proposedFileAssetId: null,
      proposedAvatarUrl: null,
      engineType: 'rule',
      ruleDecision: 'review',
      matchedRuleIds: ['rule-1'],
      rejectReasonCode: null,
      rejectReason: null,
      submittedBy: 'user-1',
      reviewedBy: null,
      reviewedAt: null,
      resubmittedFromId: null,
      metadata: {},
      createdAt: new Date('2026-04-09T10:00:00.000Z'),
      updatedAt: new Date('2026-04-09T10:30:00.000Z'),
    },
  ]);
  const forumReportRepository = createArrayRepository([
    {
      id: 'ticket-1',
      targetType: 'post',
      targetId: 'post-1',
      targetAuthorUserId: 'author-1',
      targetOrganizationId: 'org-author-1',
      reporterUserId: 'reporter-1',
      reporterActorId: 'reporter-actor-1',
      reporterOrganizationId: 'org-reporter-1',
      reasonCode: 'spam',
      reasonDetail: 'contains spam links',
      status: 'submitted',
      targetSnapshot: { excerpt: 'reported excerpt' },
      createdAt: new Date('2026-04-09T11:00:00.000Z'),
      updatedAt: new Date('2026-04-09T11:20:00.000Z'),
    },
  ]);
  const verifier = {
    async verifyCurrentSessionContext(queryContext) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-reviewer',
          actorId: 'reviewer-1',
          userId: 'reviewer-1',
          organizationId: 'platform-org',
          requestId: queryContext.requestId,
          traceId: queryContext.traceId,
        },
      };
    },
  };
  const eligibility = {
    async requireManualReviewer() {
      manualReviewerChecks += 1;
      return {
        actorRole: 'platform_reviewer',
        organizationId: 'platform-org',
        user: { id: 'reviewer-1' },
      };
    },
  };

  const service = new ContentSafetyReviewTaskQueryService(
    profileSubmissionRepository,
    forumReportRepository,
    verifier,
    eligibility,
    new ContentSafetyReviewTaskPresenter(),
  );

  const list = await service.list(
    createReviewTaskContext('Bearer reviewer', 'review-task-list'),
  );
  assert.equal(manualReviewerChecks, 1);
  assert.equal(list.count, 2);
  assert.equal(list.traceId, 'trace-review-task-list');
  assert.equal(list.items[0].taskId, 'forum_report_ticket:ticket-1');
  assert.equal(list.items[0].taskType, 'forum_report_ticket');
  assert.deepEqual(list.items[0].allowedActions, ['decide']);
  assert.equal(list.items[1].taskId, 'profile_safety_submission:submission-1');
  assert.equal(list.items[1].taskType, 'profile_safety_submission');
  assert.deepEqual(list.items[1].allowedActions, ['approve', 'reject']);

  const profileDetail = await service.detail(
    'profile_safety_submission:submission-1',
    createReviewTaskContext('Bearer reviewer', 'review-task-detail-profile'),
  );
  assert.equal(manualReviewerChecks, 2);
  assert.equal(profileDetail.subjectId, 'submission-1');
  assert.equal(profileDetail.subjectUserId, 'user-1');
  assert.equal(profileDetail.currentValue, '旧昵称');
  assert.equal(profileDetail.proposedValue, '新昵称');

  const forumDetail = await service.detail(
    'forum_report_ticket:ticket-1',
    createReviewTaskContext('Bearer reviewer', 'review-task-detail-forum'),
  );
  assert.equal(manualReviewerChecks, 3);
  assert.equal(forumDetail.subjectId, 'ticket-1');
  assert.equal(forumDetail.targetType, 'post');
  assert.equal(forumDetail.reasonCode, 'spam');
  assert.deepEqual(forumDetail.allowedActions, ['decide']);
});

test('S1-C03 review-tasks fail closed for non-reviewer actor', async () => {
  const {
    ContentSafetyReviewTaskQueryService,
  } = require('../dist/modules/content_safety/content-safety-review-task.query.service.js');
  const {
    ContentSafetyReviewTaskPresenter,
  } = require('../dist/modules/content_safety/content-safety-review-task.presenter.js');
  const {
    authPermissionInsufficient,
  } = require('../dist/modules/organization/organization-auth.errors.js');

  const service = new ContentSafetyReviewTaskQueryService(
    createArrayRepository([]),
    createArrayRepository([]),
    {
      async verifyCurrentSessionContext(queryContext) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-owner',
            actorId: 'owner-1',
            userId: 'owner-1',
            organizationId: 'buyer-org',
            requestId: queryContext.requestId,
            traceId: queryContext.traceId,
          },
        };
      },
    },
    {
      async requireManualReviewer() {
        throw authPermissionInsufficient(
          'Current actor lacks reviewer permission for content safety review.',
        );
      },
    },
    new ContentSafetyReviewTaskPresenter(),
  );

  await assert.rejects(
    () =>
      service.list(createReviewTaskContext('Bearer owner', 'review-task-list-owner')),
    (error) => error?.response?.code === 'AUTH_PERMISSION_INSUFFICIENT',
  );
  await assert.rejects(
    () =>
      service.detail(
        'profile_safety_submission:submission-1',
        createReviewTaskContext('Bearer owner', 'review-task-detail-owner'),
      ),
    (error) => error?.response?.code === 'AUTH_PERMISSION_INSUFFICIENT',
  );
});

test('S1-C03 admin-facing approve/reject paths hand off directly to ProfileSafetyReviewService', async () => {
  const {
    ContentSafetyReviewTaskWriteService,
  } = require('../dist/modules/content_safety/content-safety-review-task.write.service.js');

  const calls = [];
  const service = new ContentSafetyReviewTaskWriteService({
    approveSubmission: async (submissionId, body, queryContext) => {
      calls.push(['approve', submissionId, body, queryContext.traceId]);
      return { ok: true, traceId: queryContext.traceId, status: 'approved' };
    },
    rejectSubmission: async (submissionId, body, queryContext) => {
      calls.push(['reject', submissionId, body, queryContext.traceId]);
      return { ok: true, traceId: queryContext.traceId, status: 'rejected' };
    },
  });

  const approveResult = await service.approveProfileSubmission(
    'submission-1',
    { reviewNote: 'looks good' },
    createReviewTaskContext('Bearer reviewer', 'approve-path'),
  );
  const rejectResult = await service.rejectProfileSubmission(
    'submission-1',
    { reason: 'manual reject' },
    createReviewTaskContext('Bearer reviewer', 'reject-path'),
  );

  assert.deepEqual(calls, [
    ['approve', 'submission-1', { reviewNote: 'looks good' }, 'trace-approve-path'],
    ['reject', 'submission-1', { reason: 'manual reject' }, 'trace-reject-path'],
  ]);
  assert.equal(approveResult.status, 'approved');
  assert.equal(rejectResult.status, 'rejected');
});

test('S1-C03 forum report decide writes only ticket decision and content-safety audit', async () => {
  const {
    ContentSafetyReviewTaskWriteService,
  } = require('../dist/modules/content_safety/content-safety-review-task.write.service.js');

  const ticket = {
    id: 'ticket-1',
    targetType: 'post',
    targetId: 'post-1',
    targetAuthorUserId: 'author-1',
    targetOrganizationId: 'org-author-1',
    reporterUserId: 'reporter-1',
    reporterActorId: 'reporter-actor-1',
    reporterOrganizationId: 'org-reporter-1',
    reasonCode: 'spam',
    reasonDetail: 'contains spam links',
    status: 'submitted',
    targetSnapshot: { excerpt: 'reported excerpt' },
    createdAt: new Date('2026-04-09T11:00:00.000Z'),
    updatedAt: new Date('2026-04-09T11:20:00.000Z'),
  };
  const saves = [];
  const auditRecords = [];
  const forumRepository = {
    findOneBy: async ({ id }) => (id === ticket.id ? ticket : null),
    save: async (value) => {
      saves.push({ ...value });
      return value;
    },
  };
  const manager = {
    getRepository(entity) {
      if (entity.name === 'ForumReportTicketEntity') {
        return forumRepository;
      }
      throw new Error(`Unexpected repository request: ${entity.name}`);
    },
  };
  const dataSource = {
    transaction: async (callback) => callback(manager),
  };
  const verifier = {
    async verifyCurrentSessionContext(queryContext) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-reviewer',
          actorId: 'reviewer-1',
          userId: 'reviewer-1',
          organizationId: 'platform-org',
          requestId: queryContext.requestId,
          traceId: queryContext.traceId,
        },
      };
    },
  };
  const eligibility = {
    async requireManualReviewer() {
      return {
        actorRole: 'platform_reviewer',
        organizationId: 'platform-org',
        user: { id: 'reviewer-1' },
      };
    },
  };
  const auditService = {
    async record(input, queryContext, entityManager) {
      auditRecords.push({ input, queryContext, entityManager });
      return input;
    },
  };
  const service = new ContentSafetyReviewTaskWriteService(
    {
      approveSubmission: async () => {
        throw new Error('not used');
      },
      rejectSubmission: async () => {
        throw new Error('not used');
      },
    },
    dataSource,
    verifier,
    eligibility,
    auditService,
  );

  const result = await service.decideForumReport(
    ticket.id,
    { decision: 'resolved', reason: 'confirmed report' },
    createReviewTaskContext('Bearer reviewer', 'forum-decide'),
  );

  assert.equal(result.ok, true);
  assert.equal(result.status, 'resolved');
  assert.equal(result.previousStatus, 'submitted');
  assert.equal(ticket.status, 'resolved');
  assert.equal(saves.length, 1);
  assert.equal(auditRecords.length, 1);
  assert.equal(auditRecords[0].input.subjectType, 'forum_report_ticket');
  assert.equal(auditRecords[0].input.action, 'forum_report_decide');
  assert.equal(auditRecords[0].input.actorRole, 'platform_reviewer');
  assert.equal(auditRecords[0].input.decision, 'resolved');
  assert.equal(auditRecords[0].input.reason, 'confirmed report');
  assert.equal(auditRecords[0].input.metadata.previousStatus, 'submitted');
  assert.equal(auditRecords[0].input.metadata.nextStatus, 'resolved');
});

test('S1-C03 forum report decide fails closed for non-decidable ticket state', async () => {
  const {
    ContentSafetyReviewTaskWriteService,
  } = require('../dist/modules/content_safety/content-safety-review-task.write.service.js');

  const ticket = {
    id: 'ticket-1',
    status: 'resolved',
  };
  const dataSource = {
    transaction: async (callback) =>
      callback({
        getRepository() {
          return {
            findOneBy: async () => ticket,
            save: async () => ticket,
          };
        },
      }),
  };
  const verifier = {
    async verifyCurrentSessionContext(queryContext) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-reviewer',
          actorId: 'reviewer-1',
          userId: 'reviewer-1',
          organizationId: 'platform-org',
          requestId: queryContext.requestId,
          traceId: queryContext.traceId,
        },
      };
    },
  };
  const service = new ContentSafetyReviewTaskWriteService(
    {},
    dataSource,
    verifier,
    { requireManualReviewer: async () => ({ actorRole: 'platform_reviewer' }) },
    { record: async () => null },
  );

  await assert.rejects(
    () =>
      service.decideForumReport(
        'ticket-1',
        { decision: 'closed', reason: 'already handled' },
        createReviewTaskContext('Bearer reviewer', 'forum-decide-state'),
      ),
    (error) => error?.response?.code === 'CONTENT_SAFETY_REVIEW_TASK_INVALID_STATE',
  );
});
