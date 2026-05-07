const test = require('node:test');
const assert = require('node:assert/strict');

function createRepository(seed = []) {
  const rows = [...seed];
  return {
    rows,
    create(input) {
      return {
        ...input,
        createdAt: input.createdAt ?? new Date('2026-05-06T10:00:00.000Z'),
        updatedAt: input.updatedAt ?? new Date('2026-05-06T10:00:00.000Z'),
      };
    },
    async save(value) {
      const existingIndex = rows.findIndex((item) => item.id === value.id);
      if (existingIndex >= 0) {
        rows[existingIndex] = value;
      } else {
        rows.push(value);
      }
      return value;
    },
    async findOneBy(where) {
      return rows.find((item) => {
        for (const [key, value] of Object.entries(where)) {
          if (item[key] !== value) {
            return false;
          }
        }
        return true;
      }) ?? null;
    },
  };
}

function createHarness() {
  const {
    ProjectCommunicationBusinessEventService,
  } = require('../dist/modules/project_communication/project-communication-business-event.service.js');
  const {
    ProjectCommunicationThreadEntity,
  } = require('../dist/modules/project_communication/entities/project-communication-thread.entity.js');
  const {
    ProjectCommunicationMessageEntity,
  } = require('../dist/modules/project_communication/entities/project-communication-message.entity.js');
  const threadRepository = createRepository();
  const messageRepository = createRepository();
  const notifications = [];
  const notificationService = {
    async createProjectCommunicationMessageNotification(
      message,
      thread,
      senderOrganizationId,
    ) {
      notifications.push({ message, thread, senderOrganizationId });
      return { id: `notification-${notifications.length}` };
    },
  };
  const manager = {
    getRepository(entity) {
      if (entity === ProjectCommunicationThreadEntity) {
        return threadRepository;
      }
      if (entity === ProjectCommunicationMessageEntity) {
        return messageRepository;
      }
      throw new Error(`unexpected repository: ${entity.name}`);
    },
  };
  return {
    service: new ProjectCommunicationBusinessEventService(notificationService),
    manager,
    threadRepository,
    messageRepository,
    notifications,
  };
}

test('bid submit business event creates project communication message and notification once', async () => {
  const { service, manager, threadRepository, messageRepository, notifications } =
    createHarness();
  const input = {
    manager,
    project: { id: 'project-1', organizationId: 'publisher-org' },
    bid: {
      id: 'bid-1',
      bidderOrganizationId: 'bidder-org',
      organizationId: 'bidder-org',
      quoteAmount: '88888.00',
    },
    actorUserId: 'bidder-user',
    actorId: 'bidder-actor',
  };

  await service.emitBidSubmitted(input);
  await service.emitBidSubmitted(input);

  assert.equal(threadRepository.rows.length, 1);
  assert.equal(threadRepository.rows[0].projectId, 'project-1');
  assert.equal(threadRepository.rows[0].ownerOrganizationId, 'publisher-org');
  assert.equal(threadRepository.rows[0].counterpartOrganizationId, 'bidder-org');
  assert.equal(messageRepository.rows.length, 1);
  assert.equal(messageRepository.rows[0].messageKind, 'text');
  assert.equal(messageRepository.rows[0].senderOrganizationId, 'bidder-org');
  assert.equal(
    messageRepository.rows[0].payload.eventType,
    'bid_submitted_material_review_pending',
  );
  assert.equal(notifications.length, 1);
  assert.equal(notifications[0].senderOrganizationId, 'bidder-org');
});

test('material review business event keeps bidder and publisher in the same project communication thread', async () => {
  const { service, manager, threadRepository, messageRepository, notifications } =
    createHarness();
  await service.emitMaterialReviewResult({
    manager,
    entry: {
      definition: {
        entryKey: 'bid_quote_sheet_review',
        group: 'bid_materials',
      },
      label: '报价表',
      projectId: 'project-1',
      threadId: 'thread-1',
      bidId: 'bid-1',
      viewerRole: 'publisher',
      subjectOwnerOrganizationId: 'bidder-org',
      reviewerOrganizationId: 'publisher-org',
    },
    review: {
      id: 'review-1',
      reviewState: 'needs_supplement',
    },
    actorUserId: 'publisher-user',
    actorId: 'publisher-actor',
  });

  assert.equal(threadRepository.rows.length, 1);
  assert.equal(threadRepository.rows[0].ownerOrganizationId, 'publisher-org');
  assert.equal(threadRepository.rows[0].counterpartOrganizationId, 'bidder-org');
  assert.equal(messageRepository.rows.length, 1);
  assert.equal(
    messageRepository.rows[0].payload.eventType,
    'material_review_supplement_requested',
  );
  assert.equal(messageRepository.rows[0].senderOrganizationId, 'publisher-org');
  assert.equal(notifications.length, 1);
});

test('bid material confirmation completion event asks bidder to complete service fee authorization once', async () => {
  const { service, manager, threadRepository, messageRepository, notifications } =
    createHarness();
  const input = {
    manager,
    entry: {
      definition: {
        entryKey: 'bid_quote_sheet_review',
        group: 'bid_materials',
      },
      projectId: 'project-1',
      threadId: 'thread-1',
      bidId: 'bid-1',
      viewerRole: 'publisher',
      subjectOwnerOrganizationId: 'bidder-org',
      reviewerOrganizationId: 'publisher-org',
    },
    actorUserId: 'publisher-user',
    actorId: 'publisher-actor',
  };

  await service.emitBidMaterialConfirmationCompleted(input);
  await service.emitBidMaterialConfirmationCompleted(input);

  assert.equal(threadRepository.rows.length, 1);
  assert.equal(threadRepository.rows[0].ownerOrganizationId, 'publisher-org');
  assert.equal(threadRepository.rows[0].counterpartOrganizationId, 'bidder-org');
  assert.equal(messageRepository.rows.length, 1);
  assert.equal(
    messageRepository.rows[0].payload.eventType,
    'bid_materials_confirmed_service_fee_authorization_required',
  );
  assert.equal(
    messageRepository.rows[0].body,
    '发布方已确认完你的资料：项目理解、报价表、进度安排。请完成 4000 元竞标服务费预授权额度；完成后项目级自由发送将开启。',
  );
  assert.equal(
    messageRepository.rows[0].payload.requiredNextAction,
    'complete_service_fee_authorization',
  );
  assert.equal(messageRepository.rows[0].senderOrganizationId, 'publisher-org');
  assert.equal(notifications.length, 1);
});
