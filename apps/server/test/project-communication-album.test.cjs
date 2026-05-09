const test = require('node:test');
const assert = require('node:assert/strict');

function createContext() {
  return {
    authorization: 'Bearer project-communication-test',
    actorId: 'user-1',
    userId: 'user-1',
    organizationId: 'owner-org',
    actorRole: 'buyer_admin',
    requestId: 'project-communication-test',
    traceId: 'trace-project-communication-test',
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

function createPresenter() {
  return {
    toMessage(message) {
      return {
        messageId: message.id,
        threadId: message.threadId,
        projectId: message.projectId,
        senderUserId: message.senderUserId,
        senderActorId: message.senderActorId,
        senderOrganizationId: message.senderOrganizationId,
        messageKind: message.messageKind,
        body: message.body,
        payload:
          message.payload && Object.keys(message.payload).length > 0
            ? message.payload
            : null,
        clientMessageId: message.clientMessageId,
        messageState: message.messageState,
        createdAt: message.createdAt.toISOString(),
      };
    },
    toAlbumPhoto(photo) {
      return photo;
    },
    toAlbumList(projectId, items) {
      return { projectId, items };
    },
  };
}

test('project communication send requires explicit projectId truth anchor', async () => {
  const {
    ProjectCommunicationMessageService,
  } = require('../dist/modules/project_communication/project-communication-message.service.js');
  const service = new ProjectCommunicationMessageService(
    { async find() { return []; } },
    { manager: {}, async transaction() { throw new Error('transaction should not run'); } },
    {},
    {},
    {},
    {},
  );

  await assert.rejects(
    () =>
      service.sendMessage(
        {
          threadId: 'thread-1',
          body: 'hello',
        },
        createContext(),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_COMMUNICATION_INVALID');
      return true;
    },
  );
});

test('project communication send publishes bounded realtime message event', async () => {
  const {
    ProjectCommunicationMessageService,
  } = require('../dist/modules/project_communication/project-communication-message.service.js');
  const {
    ProjectCommunicationRealtimeEventService,
  } = require('../dist/modules/project_communication/project-communication-realtime-event.service.js');
  const savedMessages = [];
  const savedThreads = [];
  const auditRecords = [];
  const realtimeEvents = new ProjectCommunicationRealtimeEventService();
  const thread = {
    id: 'thread-1',
    projectId: 'project-1',
    ownerOrganizationId: 'owner-org',
    counterpartOrganizationId: 'counterpart-org',
    lastMessageId: null,
    lastMessageAt: null,
  };
  const messageRepository = {
    create(value) {
      return {
        ...value,
        createdAt: new Date('2026-05-19T10:00:00.000Z'),
      };
    },
    async save(message) {
      savedMessages.push(message);
      return message;
    },
    async findOneBy() {
      return null;
    },
  };
  const threadRepository = {
    async save(value) {
      savedThreads.push({ ...value });
      return value;
    },
  };
  const manager = {
    getRepository(entity) {
      return String(entity?.name).includes('ProjectCommunicationMessageEntity')
        ? messageRepository
        : threadRepository;
    },
  };
  const service = new ProjectCommunicationMessageService(
    {},
    {
      async transaction(callback) {
        return callback(manager);
      },
    },
    {
      async requireExistingThreadParticipant() {
        return {
          currentSession: {
            userId: 'user-1',
            actorId: 'actor-1',
          },
          organizationId: 'owner-org',
        };
      },
    },
    {
      async record(record) {
        auditRecords.push(record);
      },
    },
    createPresenter(),
    realtimeEvents,
  );
  service.requireThreadParticipant = async () => ({
    actor: {
      currentSession: {
        userId: 'user-1',
        actorId: 'actor-1',
      },
      organizationId: 'owner-org',
    },
    thread,
  });

  const result = await service.sendMessage(
    {
      threadId: 'thread-1',
      projectId: 'project-1',
      body: 'realtime message',
      clientMessageId: 'client-1',
    },
    createContext(),
  );
  const events = realtimeEvents.listThreadEvents('thread-1', 'project-1', null);

  assert.equal(result.threadId, 'thread-1');
  assert.equal(savedMessages.length, 1);
  assert.equal(savedThreads[0].lastMessageId, savedMessages[0].id);
  assert.equal(auditRecords[0].eventType, 'ProjectCommunicationMessageSent');
  assert.equal(events.length, 1);
  assert.equal(events[0].eventType, 'project_communication.message.created');
  assert.equal(events[0].messageId, savedMessages[0].id);
  assert.equal(events[0].threadId, 'thread-1');
  assert.equal(events[0].projectId, 'project-1');
  assert.equal(events[0].senderOrganizationId, 'owner-org');
  assert.equal(events[0].messageKind, 'text');
  assert.equal(events[0].body, 'realtime message');
  assert.equal(events[0].payload, null);
  assert.equal(events[0].clientMessageId, 'client-1');
  assert.equal(events[0].createdAt, '2026-05-19T10:00:00.000Z');
  assert.match(events[0].eventId, /^[0-9a-f-]{36}$/);
});

test('project communication send is blocked by server chat availability truth', async () => {
  const {
    ProjectCommunicationMessageService,
  } = require('../dist/modules/project_communication/project-communication-message.service.js');
  const thread = {
    id: 'thread-1',
    projectId: 'project-1',
    ownerOrganizationId: 'owner-org',
    counterpartOrganizationId: 'counterpart-org',
    lastMessageId: null,
    lastMessageAt: null,
  };
  const manager = {
    getRepository() {
      return {
        async findOneBy() {
          return null;
        },
      };
    },
  };
  const service = new ProjectCommunicationMessageService(
    {},
    {
      async transaction(callback) {
        return callback(manager);
      },
    },
    {},
    {},
    createPresenter(),
    { publishMessageCreated() {} },
    {
      async buildForThread() {
        return {
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
      },
    },
  );
  service.requireThreadParticipant = async () => ({
    actor: {
      currentSession: {
        userId: 'user-1',
        actorId: 'actor-1',
      },
      organizationId: 'counterpart-org',
    },
    thread,
  });

  await assert.rejects(
    () =>
      service.sendMessage(
        {
          threadId: 'thread-1',
          projectId: 'project-1',
          body: 'should be locked',
        },
        createContext(),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_COMMUNICATION_INVALID');
      assert.equal(error?.response?.message, '请先确认发布方提供的报价依据资料。');
      return true;
    },
  );
});

test('project communication image message stores dedicated FileAsset payload', async () => {
  const {
    ProjectCommunicationMessageService,
  } = require('../dist/modules/project_communication/project-communication-message.service.js');
  const {
    ProjectCommunicationRealtimeEventService,
  } = require('../dist/modules/project_communication/project-communication-realtime-event.service.js');
  const { FileAssetEntity } = require('../dist/modules/upload/entities/file-asset.entity.js');
  const savedMessages = [];
  const realtimeEvents = new ProjectCommunicationRealtimeEventService();
  const thread = {
    id: 'thread-1',
    projectId: 'project-1',
    ownerOrganizationId: 'owner-org',
    counterpartOrganizationId: 'counterpart-org',
    lastMessageId: null,
    lastMessageAt: null,
  };
  const messageRepository = {
    create(value) {
      return {
        ...value,
        createdAt: new Date('2026-05-19T10:00:00.000Z'),
      };
    },
    async save(message) {
      savedMessages.push(message);
      return message;
    },
    async findOneBy() {
      return null;
    },
  };
  const fileAssetRepository = {
    async findOneBy() {
      return {
        id: 'file-1',
        businessType: 'project',
        businessId: 'project-1',
        fileKind: 'project_communication_attachment',
        organizationId: 'owner-org',
        mimeType: 'image/png',
        size: 128,
      };
    },
  };
  const manager = {
    getRepository(entity) {
      if (entity === FileAssetEntity) {
        return fileAssetRepository;
      }
      if (String(entity?.name).includes('ProjectCommunicationMessageEntity')) {
        return messageRepository;
      }
      return {
        async save(value) {
          return value;
        },
      };
    },
  };
  const service = new ProjectCommunicationMessageService(
    {},
    {
      async transaction(callback) {
        return callback(manager);
      },
    },
    {},
    { async record() {} },
    createPresenter(),
    realtimeEvents,
  );
  service.requireThreadParticipant = async () => ({
    actor: {
      currentSession: {
        userId: 'user-1',
        actorId: 'actor-1',
      },
      organizationId: 'owner-org',
    },
    thread,
  });

  const result = await service.sendMessage(
    {
      threadId: 'thread-1',
      projectId: 'project-1',
      messageKind: 'image',
      body: '现场照片',
      payload: {
        attachment: {
          fileAssetId: 'file-1',
          fileName: 'booth.png',
          mimeType: 'image/png',
          size: 128,
          category: 'image',
        },
      },
      clientMessageId: 'client-image-1',
    },
    createContext(),
  );
  const events = realtimeEvents.listThreadEvents('thread-1', 'project-1', null);

  assert.equal(result.messageKind, 'image');
  assert.equal(result.payload.attachment.fileAssetId, 'file-1');
  assert.equal(savedMessages[0].payload.attachment.category, 'image');
  assert.equal(events[0].payload.attachment.fileName, 'booth.png');
});

test('project communication attachment rejects cross-project FileAsset', async () => {
  const {
    ProjectCommunicationMessageService,
  } = require('../dist/modules/project_communication/project-communication-message.service.js');
  const { FileAssetEntity } = require('../dist/modules/upload/entities/file-asset.entity.js');
  const thread = {
    id: 'thread-1',
    projectId: 'project-1',
    ownerOrganizationId: 'owner-org',
    counterpartOrganizationId: 'counterpart-org',
  };
  const manager = {
    getRepository(entity) {
      if (entity === FileAssetEntity) {
        return {
          async findOneBy() {
            return {
              id: 'file-1',
              businessType: 'project',
              businessId: 'other-project',
              fileKind: 'project_communication_attachment',
              organizationId: 'owner-org',
              mimeType: 'application/pdf',
              size: 256,
            };
          },
        };
      }
      return {
        async findOneBy() {
          return null;
        },
      };
    },
  };
  const service = new ProjectCommunicationMessageService(
    {},
    {
      async transaction(callback) {
        return callback(manager);
      },
    },
    {},
    { async record() {} },
    createPresenter(),
    { publishMessageCreated() {} },
  );
  service.requireThreadParticipant = async () => ({
    actor: {
      currentSession: {
        userId: 'user-1',
        actorId: 'actor-1',
      },
      organizationId: 'owner-org',
    },
    thread,
  });

  await assert.rejects(
    () =>
      service.sendMessage(
        {
          threadId: 'thread-1',
          projectId: 'project-1',
          messageKind: 'file',
          payload: {
            attachment: {
              fileAssetId: 'file-1',
              fileName: 'quote.pdf',
              mimeType: 'application/pdf',
              size: 256,
              category: 'file',
            },
          },
        },
        createContext(),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_COMMUNICATION_INVALID');
      return true;
    },
  );
});

test('project communication confirmation card stores whitelisted payload', async () => {
  const {
    ProjectCommunicationMessageService,
  } = require('../dist/modules/project_communication/project-communication-message.service.js');
  const realtimeEvents = {
    publishMessageCreated() {},
  };
  const savedMessages = [];
  const thread = {
    id: 'thread-1',
    projectId: 'project-1',
    ownerOrganizationId: 'owner-org',
    counterpartOrganizationId: 'counterpart-org',
    lastMessageId: null,
    lastMessageAt: null,
  };
  const messageRepository = {
    create(value) {
      return {
        ...value,
        createdAt: new Date('2026-05-19T10:00:00.000Z'),
      };
    },
    async save(message) {
      savedMessages.push(message);
      return message;
    },
    async findOneBy() {
      return null;
    },
  };
  const service = new ProjectCommunicationMessageService(
    {},
    {
      async transaction(callback) {
        return callback({
          getRepository(entity) {
            if (String(entity?.name).includes('ProjectCommunicationMessageEntity')) {
              return messageRepository;
            }
            return {
              async save(value) {
                return value;
              },
            };
          },
        });
      },
    },
    {},
    { async record() {} },
    createPresenter(),
    realtimeEvents,
  );
  service.requireThreadParticipant = async () => ({
    actor: {
      currentSession: {
        userId: 'user-1',
        actorId: 'actor-1',
      },
      organizationId: 'owner-org',
    },
    thread,
  });

  const result = await service.sendMessage(
    {
      threadId: 'thread-1',
      projectId: 'project-1',
      messageKind: 'confirmation_card',
      payload: {
        confirmation: {
          confirmationType: 'quote',
          title: '报价确认',
          summary: '确认当前报价为 12000 元。',
        },
      },
    },
    createContext(),
  );

  assert.equal(result.messageKind, 'confirmation_card');
  assert.equal(result.body, '报价确认');
  assert.equal(result.payload.confirmation.status, 'proposed');
  assert.equal(savedMessages[0].payload.confirmation.confirmationType, 'quote');
});

test('project communication clientMessageId dedupe returns truth without duplicate realtime event', async () => {
  const {
    ProjectCommunicationMessageService,
  } = require('../dist/modules/project_communication/project-communication-message.service.js');
  const {
    ProjectCommunicationRealtimeEventService,
  } = require('../dist/modules/project_communication/project-communication-realtime-event.service.js');
  const savedMessages = [];
  const realtimeEvents = new ProjectCommunicationRealtimeEventService();
  const thread = {
    id: 'thread-1',
    projectId: 'project-1',
    ownerOrganizationId: 'owner-org',
    counterpartOrganizationId: 'counterpart-org',
    lastMessageId: null,
    lastMessageAt: null,
  };
  const messageRepository = {
    create(value) {
      return {
        ...value,
        createdAt: new Date('2026-05-19T10:00:00.000Z'),
      };
    },
    async save(message) {
      savedMessages.push(message);
      return message;
    },
    async findOneBy(where) {
      return (
        savedMessages.find(
          (message) =>
            message.threadId === where.threadId &&
            message.senderOrganizationId === where.senderOrganizationId &&
            message.clientMessageId === where.clientMessageId,
        ) ?? null
      );
    },
  };
  const service = new ProjectCommunicationMessageService(
    {},
    {
      async transaction(callback) {
        return callback({
          getRepository(entity) {
            if (String(entity?.name).includes('ProjectCommunicationMessageEntity')) {
              return messageRepository;
            }
            return {
              async save(value) {
                return value;
              },
            };
          },
        });
      },
    },
    {
      async requireExistingThreadParticipant() {
        return {
          currentSession: {
            userId: 'user-1',
            actorId: 'actor-1',
          },
          organizationId: 'owner-org',
        };
      },
    },
    {
      async record() {},
    },
    createPresenter(),
    realtimeEvents,
  );
  service.requireThreadParticipant = async () => ({
    actor: {
      currentSession: {
        userId: 'user-1',
        actorId: 'actor-1',
      },
      organizationId: 'owner-org',
    },
    thread,
  });
  service.findClientMessage = (clientMessageId, threadId, senderOrganizationId) =>
    messageRepository.findOneBy({ clientMessageId, threadId, senderOrganizationId });

  const payload = {
    threadId: 'thread-1',
    projectId: 'project-1',
    body: 'dedupe message',
    clientMessageId: 'client-dedupe-1',
  };
  const first = await service.sendMessage(payload, createContext());
  const second = await service.sendMessage(payload, createContext());
  const events = realtimeEvents.listThreadEvents('thread-1', 'project-1', null);

  assert.equal(first.messageId, second.messageId);
  assert.equal(savedMessages.length, 1);
  assert.equal(events.length, 1);
  assert.equal(events[0].projectId, 'project-1');
  assert.equal(events[0].threadId, 'thread-1');
  assert.equal(events[0].messageId, first.messageId);
});

test('project communication thread open rejects owner-side generic DM without project relationship', async () => {
  const {
    ProjectCommunicationAccessService,
  } = require('../dist/modules/project_communication/project-communication-access.service.js');
  const service = new ProjectCommunicationAccessService(
    {
      async findOneBy() {
        return { id: 'project-1', organizationId: 'owner-org' };
      },
    },
    { async countBy() { return 0; } },
    { async countBy() { return 0; } },
    { async countBy() { return 0; } },
    { async countBy() { return 0; } },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: context.actorId,
            userId: context.userId,
            organizationId: context.organizationId,
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {},
      async getCurrentOrganizationScope() {
        return { organization: { id: 'owner-org' } };
      },
    },
  );

  await assert.rejects(
    () => service.requireProjectConversationPair('project-1', 'counterpart-org', createContext()),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_COMMUNICATION_FORBIDDEN');
      return true;
    },
  );
});

test('project album bind enforces 50 active photo limit before FileAsset bind', async () => {
  const {
    ProjectAlbumPhotoService,
  } = require('../dist/modules/project_communication/project-album-photo.service.js');
  const service = new ProjectAlbumPhotoService(
    {},
    {
      async transaction(callback) {
        return callback({
          async query() {},
          getRepository() {
            return {
              async countBy() {
                return 50;
              },
            };
          },
        });
      },
    },
    {
      async requireProjectAlbumAccess() {
        return {
          currentSession: { actorId: 'user-1', userId: 'user-1' },
          project: { id: 'project-1', organizationId: 'owner-org' },
          organizationId: 'owner-org',
          isOwner: true,
        };
      },
    },
    {},
    createPresenter(),
  );

  await assert.rejects(
    () =>
      service.bind(
        'project-1',
        {
          fileAssetId: 'file-1',
          category: 'progress',
        },
        createContext(),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_ALBUM_LIMIT_EXCEEDED');
      return true;
    },
  );
});

test('project album bind only accepts image FileAsset with project_album_photo kind', async () => {
  const { FileAssetEntity } = require('../dist/modules/upload/entities/file-asset.entity.js');
  const {
    ProjectAlbumPhotoService,
  } = require('../dist/modules/project_communication/project-album-photo.service.js');
  const service = new ProjectAlbumPhotoService(
    {},
    {
      async transaction(callback) {
        return callback({
          async query() {},
          getRepository(entity) {
            if (entity === FileAssetEntity) {
              return {
                async findOneBy() {
                  return {
                    id: 'file-1',
                    businessType: 'project',
                    businessId: 'project-1',
                    fileKind: 'project_attachment',
                    organizationId: 'owner-org',
                    mimeType: 'application/pdf',
                  };
                },
              };
            }
            return {
              async countBy() {
                return 0;
              },
              async findOneBy() {
                return null;
              },
            };
          },
        });
      },
    },
    {
      async requireProjectAlbumAccess() {
        return {
          currentSession: { actorId: 'user-1', userId: 'user-1' },
          project: { id: 'project-1', organizationId: 'owner-org' },
          organizationId: 'owner-org',
          isOwner: true,
        };
      },
    },
    {},
    createPresenter(),
  );

  await assert.rejects(
    () =>
      service.bind(
        'project-1',
        {
          fileAssetId: 'file-1',
          category: 'contract',
        },
        createContext(),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_ALBUM_INVALID');
      return true;
    },
  );
});
