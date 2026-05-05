const test = require('node:test');
const assert = require('node:assert/strict');
const { createHash } = require('node:crypto');

function hashSource(parts) {
  return createHash('sha256').update(parts.join('|'), 'utf8').digest('hex');
}

function createContext(organizationId) {
  return {
    authorization: 'Bearer workbench-token',
    actorId: `actor-${organizationId}`,
    userId: `user-${organizationId}`,
    organizationId,
    actorRole: 'org_admin',
    requestId: `req-${organizationId}`,
    traceId: `trace-${organizationId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

function createHarness(options = {}) {
  const {
    ProjectCommunicationWorkbenchService,
  } = require('../dist/modules/project_communication/project-communication-workbench.service.js');
  const {
    ProjectCommunicationWorkbenchPresenter,
  } = require('../dist/modules/project_communication/project-communication-workbench.presenter.js');
  const {
    ProjectCommunicationThreadEntity,
  } = require('../dist/modules/project_communication/entities/project-communication-thread.entity.js');
  const {
    ProjectCommunicationMaterialReviewEntity,
  } = require('../dist/modules/project_communication/entities/project-communication-material-review.entity.js');
  const { BidEntity } = require('../dist/modules/bid/entities/bid.entity.js');
  const {
    ProjectAttachmentEntity,
  } = require('../dist/modules/project/entities/project-attachment.entity.js');

  const thread = {
    id: 'thread-1',
    projectId: 'project-1',
    ownerOrganizationId: 'org-publisher',
    counterpartOrganizationId: 'org-bidder',
    threadState: 'open',
    createdAt: new Date('2026-05-02T01:00:00.000Z'),
    updatedAt: new Date('2026-05-02T01:00:00.000Z'),
  };
  const defaultBid = {
    id: 'bid-1',
    projectId: 'project-1',
    bidderOrganizationId: 'org-bidder',
    organizationId: 'org-bidder',
    projectUnderstandingFileAssetId: 'file-understanding',
    quoteSheetFileAssetId: 'file-quote',
    schedulePlanFileAssetId: 'file-schedule',
    updatedAt: new Date('2026-05-02T01:05:00.000Z'),
  };
  const bid = Object.prototype.hasOwnProperty.call(options, 'bid') ? options.bid : defaultBid;
  const attachments = options.attachments ?? [
    {
      id: 'att-effect',
      projectId: 'project-1',
      fileAssetId: 'file-effect',
      fileName: '效果图.png',
      attachmentKind: 'effect_image',
      visibility: 'owner_private',
      sortOrder: 0,
      createdAt: new Date('2026-05-02T01:10:00.000Z'),
    },
  ];
  const reviews = options.reviews ?? [];
  const businessState = options.businessState ?? {
    businessTodoSummary: {
      bidParticipationReviewPendingCount: 0,
      publisherMaterialReviewPendingCount: 1,
      bidMaterialReviewPendingCount: 0,
      dealConfirmationPendingCount: 0,
      totalPendingCount: 1,
    },
    chatAvailability: {
      canSendMessage: false,
      lockReasonCode: 'publisher_material_confirmation_pending',
      lockReasonText: '请先确认发布方提供的报价依据资料。',
      requiredNextAction: 'confirm_publisher_materials',
    },
  };

  const threadRepo = {
    async findOneBy(where) {
      return where.id === thread.id && where.projectId === thread.projectId ? thread : null;
    },
  };
  const bidRepo = {
    async findOneBy(where) {
      if (!bid) return null;
      if (where.id && where.id !== bid.id) return null;
      if (where.projectId !== bid.projectId) return null;
      if (where.bidderOrganizationId && where.bidderOrganizationId !== bid.bidderOrganizationId) return null;
      return bid;
    },
  };
  const attachmentRepo = {
    async find() {
      return attachments;
    },
  };
  const reviewRepo = {
    async findBy(where) {
      return reviews.filter((review) => review.projectId === where.projectId && review.bidId === where.bidId);
    },
    async findOneBy(where) {
      return reviews.find(
        (review) =>
          review.projectId === where.projectId &&
          review.bidId === where.bidId &&
          review.reviewerOrganizationId === where.reviewerOrganizationId &&
          review.entryKey === where.entryKey,
      ) ?? null;
    },
    create(seed) {
      return { ...seed };
    },
    async save(review) {
      const existing = await this.findOneBy({
        projectId: review.projectId,
        bidId: review.bidId,
        reviewerOrganizationId: review.reviewerOrganizationId,
        entryKey: review.entryKey,
      });
      if (!existing) {
        reviews.push(review);
      }
      return review;
    },
  };
  const manager = {
    getRepository(entity) {
      if (entity === ProjectCommunicationThreadEntity) return threadRepo;
      if (entity === BidEntity) return bidRepo;
      if (entity === ProjectAttachmentEntity) return attachmentRepo;
      if (entity === ProjectCommunicationMaterialReviewEntity) return reviewRepo;
      throw new Error(`Unexpected repository: ${entity.name}`);
    },
  };
  const dataSource = {
    async transaction(callback) {
      return callback(manager);
    },
  };
  const accessService = {
    async requireExistingThreadParticipant(currentThread, context) {
      const organizationId = context.organizationId;
      if (
        organizationId !== currentThread.ownerOrganizationId &&
        organizationId !== currentThread.counterpartOrganizationId
      ) {
        const error = new Error('forbidden');
        error.status = 403;
        throw error;
      }
      return {
        currentSession: {
          sessionId: 'session-1',
          actorId: context.actorId,
          userId: context.userId,
          organizationId,
          requestId: context.requestId,
          traceId: context.traceId,
        },
        project: { id: currentThread.projectId, organizationId: currentThread.ownerOrganizationId },
        organizationId,
        isOwner: organizationId === currentThread.ownerOrganizationId,
      };
    },
  };
  const service = new ProjectCommunicationWorkbenchService(
    threadRepo,
    bidRepo,
    attachmentRepo,
    reviewRepo,
    dataSource,
    accessService,
    new ProjectCommunicationWorkbenchPresenter(),
    {
      async buildForThread(input) {
        assert.equal(input.thread.id, 'thread-1');
        return businessState;
      },
    },
  );
  return { service, reviews };
}

function createBusinessStateHarness(options = {}) {
  const {
    ProjectCommunicationBusinessStateService,
  } = require('../dist/modules/project_communication/project-communication-business-state.service.js');
  const bid = options.bid ?? null;
  const attachments = options.attachments ?? [];
  const reviews = options.reviews ?? [];
  const confirmations = options.confirmations ?? [];
  const pendingParticipationCount = options.pendingParticipationCount ?? 0;
  const service = new ProjectCommunicationBusinessStateService(
    {
      async countBy() {
        return pendingParticipationCount;
      },
    },
    {
      async findOneBy() {
        return bid;
      },
    },
    {
      async find() {
        return attachments;
      },
    },
    {
      async findBy(where) {
        return reviews.filter(
          (review) =>
            review.projectId === where.projectId &&
            review.bidId === where.bidId &&
            review.reviewerOrganizationId === where.reviewerOrganizationId,
        );
      },
    },
    {
      async find() {
        return confirmations;
      },
    },
  );
  return service;
}

test('business state keeps ordinary unread separate from owner bid participation todo', async () => {
  const service = createBusinessStateHarness({ pendingParticipationCount: 1 });
  const result = await service.buildForPair({
    projectId: 'project-1',
    ownerOrganizationId: 'org-publisher',
    counterpartOrganizationId: 'org-bidder',
    viewerOrganizationId: 'org-publisher',
  });

  assert.equal(result.businessTodoSummary.bidParticipationReviewPendingCount, 1);
  assert.equal(result.businessTodoSummary.totalPendingCount, 1);
  assert.equal(result.chatAvailability.canSendMessage, false);
  assert.equal(result.chatAvailability.lockReasonCode, 'bid_participation_review_pending');
  assert.equal(result.chatAvailability.requiredNextAction, 'review_bid_participation');
});

test('business state locks bidder chat on pending publisher material confirmation before bid submit', async () => {
  const service = createBusinessStateHarness({
    attachments: [
      {
        id: 'att-effect',
        projectId: 'project-1',
        fileAssetId: 'file-effect',
        attachmentKind: 'effect_image',
        visibility: 'owner_private',
        sortOrder: 0,
        createdAt: new Date('2026-05-02T01:10:00.000Z'),
      },
    ],
  });
  const result = await service.buildForPair({
    projectId: 'project-1',
    ownerOrganizationId: 'org-publisher',
    counterpartOrganizationId: 'org-bidder',
    viewerOrganizationId: 'org-bidder',
  });

  assert.equal(result.businessTodoSummary.publisherMaterialReviewPendingCount, 1);
  assert.equal(result.chatAvailability.canSendMessage, false);
  assert.equal(result.chatAvailability.lockReasonCode, 'publisher_material_confirmation_pending');
  assert.equal(result.chatAvailability.requiredNextAction, 'confirm_publisher_materials');
});

test('business state reads no-bid publisher material review before bid submit', async () => {
  const attachmentCreatedAt = new Date('2026-05-02T01:10:00.000Z');
  const service = createBusinessStateHarness({
    attachments: [
      {
        id: 'att-effect',
        projectId: 'project-1',
        fileAssetId: 'file-effect',
        attachmentKind: 'effect_image',
        visibility: 'owner_private',
        sortOrder: 0,
        createdAt: attachmentCreatedAt,
      },
    ],
    reviews: [
      {
        projectId: 'project-1',
        bidId: '',
        reviewerOrganizationId: 'org-bidder',
        entryKey: 'publisher_effect_image_review',
        sourceVersionToken: hashSource([`att-effect:file-effect:${attachmentCreatedAt.toISOString()}`]),
        reviewState: 'confirmed',
      },
    ],
  });
  const result = await service.buildForPair({
    projectId: 'project-1',
    ownerOrganizationId: 'org-publisher',
    counterpartOrganizationId: 'org-bidder',
    viewerOrganizationId: 'org-bidder',
  });

  assert.equal(result.businessTodoSummary.publisherMaterialReviewPendingCount, 0);
  assert.equal(result.businessTodoSummary.totalPendingCount, 0);
  assert.equal(result.chatAvailability.canSendMessage, false);
  assert.equal(result.chatAvailability.lockReasonCode, 'bid_submission_pending');
  assert.equal(result.chatAvailability.requiredNextAction, 'submit_bid_materials');
});

test('business state leaves final amount pending as a communication prompt, not a chat lock', async () => {
  const service = createBusinessStateHarness({
    bid: {
      id: 'bid-1',
      projectId: 'project-1',
      bidderOrganizationId: 'org-bidder',
      organizationId: 'org-bidder',
      projectUnderstandingFileAssetId: 'file-understanding',
      quoteSheetFileAssetId: 'file-quote',
      schedulePlanFileAssetId: 'file-schedule',
      updatedAt: new Date('2026-05-02T01:05:00.000Z'),
    },
    confirmations: [
      {
        taskId: 'project-1',
        publisherOrganizationId: 'org-publisher',
        factoryOrganizationId: 'org-bidder',
        publisherConfirmedAt: new Date('2026-05-02T02:00:00.000Z'),
        factoryConfirmedAt: null,
        contractStatus: 'pending_counterparty_confirm',
      },
    ],
  });
  const result = await service.buildForPair({
    projectId: 'project-1',
    ownerOrganizationId: 'org-publisher',
    counterpartOrganizationId: 'org-bidder',
    viewerOrganizationId: 'org-bidder',
  });

  assert.equal(result.businessTodoSummary.dealConfirmationPendingCount, 1);
  assert.equal(result.chatAvailability.canSendMessage, true);
  assert.equal(result.chatAvailability.requiredNextAction, 'open_deal_confirmation');
});

test('workbench exposes 10 fixed entries and pending publisher material for bidder', async () => {
  const { service } = createHarness();
  const result = await service.getWorkbench(
    { projectId: 'project-1', threadId: 'thread-1', bidId: 'bid-1' },
    createContext('org-bidder'),
  );

  assert.equal(result.entries.length, 10);
  assert.equal(result.businessTodoSummary.publisherMaterialReviewPendingCount, 1);
  assert.equal(result.chatAvailability.canSendMessage, false);
  assert.equal(result.entries[0].entryKey, 'publisher_effect_image_review');
  assert.equal(result.entries[0].label, '效果图确认');
  assert.equal(result.entries[0].reviewState, 'pending_review');
  assert.equal(result.entries[0].actionState, 'enabled');
  assert.equal(result.entries[0].badgeCount, 1);
  assert.equal(result.entries[1].disabledReason, '当前资料尚未提交。');
  assert.equal(result.entries[6].entryKey, 'bid_quote_sheet_review');
  assert.equal(result.entries[8].entryKey, 'contract_confirmation');
});

test('bidder confirms publisher material and persisted state returns green truth', async () => {
  const { service, reviews } = createHarness();
  const before = await service.getWorkbench(
    { projectId: 'project-1', threadId: 'thread-1', bidId: 'bid-1' },
    createContext('org-bidder'),
  );
  const sourceVersionToken = before.entries[0].truthAnchor.sourceVersionToken;
  const result = await service.reviewMaterial(
    {
      projectId: 'project-1',
      threadId: 'thread-1',
      bidId: 'bid-1',
      entryKey: 'publisher_effect_image_review',
      reviewAction: 'confirm',
      sourceVersionToken,
      idempotencyKey: 'confirm-effect-1',
    },
    createContext('org-bidder'),
  );

  assert.equal(reviews.length, 1);
  assert.equal(reviews[0].reviewState, 'confirmed');
  assert.equal(result.entry.reviewState, 'confirmed');
  assert.equal(result.entry.reviewedAt, reviews[0].confirmedAt.toISOString());
});

test('bidder confirms publisher material without bidId before bid submit', async () => {
  const { service, reviews } = createHarness({ bid: null });
  const before = await service.getWorkbench(
    { projectId: 'project-1', threadId: 'thread-1' },
    createContext('org-bidder'),
  );
  const sourceVersionToken = before.entries[0].truthAnchor.sourceVersionToken;
  const result = await service.reviewMaterial(
    {
      projectId: 'project-1',
      threadId: 'thread-1',
      entryKey: 'publisher_effect_image_review',
      reviewAction: 'confirm',
      sourceVersionToken,
      idempotencyKey: 'confirm-effect-no-bid',
    },
    createContext('org-bidder'),
  );

  assert.equal(reviews.length, 1);
  assert.equal(reviews[0].bidId, '');
  assert.equal(reviews[0].reviewState, 'confirmed');
  assert.equal(result.entry.bidId, null);
  assert.equal(result.entry.reviewState, 'confirmed');
  assert.equal(result.entry.reviewedAt, reviews[0].confirmedAt.toISOString());
});

test('workbench keeps no-bid publisher material review visible after bid exists', async () => {
  const attachmentCreatedAt = new Date('2026-05-02T01:10:00.000Z');
  const { service } = createHarness({
    attachments: [
      {
        id: 'att-effect',
        projectId: 'project-1',
        fileAssetId: 'file-effect',
        fileName: '效果图.png',
        attachmentKind: 'effect_image',
        visibility: 'owner_private',
        sortOrder: 0,
        createdAt: attachmentCreatedAt,
      },
    ],
    reviews: [
      {
        projectId: 'project-1',
        bidId: '',
        reviewerOrganizationId: 'org-bidder',
        entryKey: 'publisher_effect_image_review',
        sourceVersionToken: hashSource([`att-effect:file-effect:${attachmentCreatedAt.toISOString()}`]),
        reviewState: 'confirmed',
        confirmedAt: new Date('2026-05-02T01:20:00.000Z'),
      },
    ],
  });
  const result = await service.getWorkbench(
    { projectId: 'project-1', threadId: 'thread-1', bidId: 'bid-1' },
    createContext('org-bidder'),
  );

  assert.equal(result.entries[0].bidId, 'bid-1');
  assert.equal(result.entries[0].reviewState, 'confirmed');
  assert.equal(result.entries[0].badgeCount, 0);
});

test('bid material review still requires bidId', async () => {
  const { service, reviews } = createHarness({ bid: null });
  await assert.rejects(
    () =>
      service.reviewMaterial(
        {
          projectId: 'project-1',
          threadId: 'thread-1',
          entryKey: 'bid_quote_sheet_review',
          reviewAction: 'confirm',
          idempotencyKey: 'bid-material-no-bid',
        },
        createContext('org-publisher'),
      ),
    (error) =>
      error.getResponse?.().code === 'PROJECT_COMMUNICATION_INVALID' &&
      error.getResponse?.().message === 'Field `bidId` is required for bid material review.',
  );
  assert.equal(reviews.length, 0);
});

test('publisher cannot confirm its own publisher material', async () => {
  const { service } = createHarness();
  await assert.rejects(
    () =>
      service.reviewMaterial(
        {
          projectId: 'project-1',
          threadId: 'thread-1',
          bidId: 'bid-1',
          entryKey: 'publisher_effect_image_review',
          reviewAction: 'confirm',
          idempotencyKey: 'publisher-own-material',
        },
        createContext('org-publisher'),
      ),
    (error) => error.getResponse?.().code === 'PROJECT_COMMUNICATION_MATERIAL_REVIEWER_MISMATCH',
  );
});

test('publisher can request supplement for bidder quote sheet', async () => {
  const { service, reviews } = createHarness();
  const result = await service.reviewMaterial(
    {
      projectId: 'project-1',
      threadId: 'thread-1',
      bidId: 'bid-1',
      entryKey: 'bid_quote_sheet_review',
      reviewAction: 'request_supplement',
      feedbackReasonCodes: ['missing_total'],
      feedbackText: '请补充最终报价合计。',
      idempotencyKey: 'quote-sheet-feedback-1',
    },
    createContext('org-publisher'),
  );

  assert.equal(reviews.length, 1);
  assert.equal(reviews[0].reviewState, 'needs_supplement');
  assert.equal(result.entry.reviewState, 'needs_supplement');
  assert.equal(result.entry.latestFeedbackText, '请补充最终报价合计。');
});

test('stale source token is rejected before writing review truth', async () => {
  const { service, reviews } = createHarness();
  await assert.rejects(
    () =>
      service.reviewMaterial(
        {
          projectId: 'project-1',
          threadId: 'thread-1',
          bidId: 'bid-1',
          entryKey: 'publisher_effect_image_review',
          reviewAction: 'confirm',
          sourceVersionToken: 'stale-token',
          idempotencyKey: 'stale-source',
        },
        createContext('org-bidder'),
      ),
    (error) => error.getResponse?.().code === 'PROJECT_COMMUNICATION_MATERIAL_SOURCE_CONFLICT',
  );
  assert.equal(reviews.length, 0);
});
