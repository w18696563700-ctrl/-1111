const test = require('node:test');
const assert = require('node:assert/strict');

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
  const bid = {
    id: 'bid-1',
    projectId: 'project-1',
    bidderOrganizationId: 'org-bidder',
    organizationId: 'org-bidder',
    projectUnderstandingFileAssetId: 'file-understanding',
    quoteSheetFileAssetId: 'file-quote',
    schedulePlanFileAssetId: 'file-schedule',
    updatedAt: new Date('2026-05-02T01:05:00.000Z'),
  };
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

  const threadRepo = {
    async findOneBy(where) {
      return where.id === thread.id && where.projectId === thread.projectId ? thread : null;
    },
  };
  const bidRepo = {
    async findOneBy(where) {
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
  );
  return { service, reviews };
}

test('workbench exposes 10 fixed entries and pending publisher material for bidder', async () => {
  const { service } = createHarness();
  const result = await service.getWorkbench(
    { projectId: 'project-1', threadId: 'thread-1', bidId: 'bid-1' },
    createContext('org-bidder'),
  );

  assert.equal(result.entries.length, 10);
  assert.equal(result.entries[0].entryKey, 'publisher_effect_image_review');
  assert.equal(result.entries[0].label, '效果图确认');
  assert.equal(result.entries[0].reviewState, 'pending_review');
  assert.equal(result.entries[0].actionState, 'enabled');
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
