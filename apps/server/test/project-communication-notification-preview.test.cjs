require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(overrides = {}) {
  return {
    authorization: 'Bearer notification-preview-test',
    actorId: 'user-1',
    userId: 'user-1',
    organizationId: 'owner-org',
    actorRole: 'buyer_admin',
    requestId: 'notification-preview-test',
    traceId: 'trace-notification-preview-test',
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
    ...overrides,
  };
}

function createVerifier(organizationId = 'recipient-org') {
  return {
    async verifyCurrentSessionContext(context) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'user-1',
          userId: 'user-1',
          organizationId,
          requestId: context.requestId,
          traceId: context.traceId,
        },
      };
    },
  };
}

function createNotification(overrides = {}) {
  return {
    id: 'notification-1',
    userId: '',
    organizationId: 'recipient-org',
    type: 'project_communication_message',
    source: 'project_communication',
    title: '有新的项目沟通消息',
    body: 'hello',
    projectId: 'project-1',
    threadId: 'thread-1',
    routeTarget: { canonicalPath: '/api/app/message/project-communication/messages' },
    readAt: null,
    notificationState: 'active',
    createdAt: new Date('2026-05-01T08:00:00.000Z'),
    updatedAt: new Date('2026-05-01T08:00:00.000Z'),
    ...overrides,
  };
}

test('project communication message creates notification truth and noop push attempt', async () => {
  const { NotificationService } = require('../dist/modules/notifications/notification.service.js');
  const { NotificationPresenter } = require('../dist/modules/notifications/notification.presenter.js');
  const savedNotifications = [];
  const savedAttempts = [];
  const notificationRepository = {
    create(value) {
      return {
        ...value,
        createdAt: new Date('2026-05-01T08:00:00.000Z'),
        updatedAt: new Date('2026-05-01T08:00:00.000Z'),
      };
    },
    async save(value) {
      savedNotifications.push(value);
      return value;
    },
  };
  const tokenRepository = {
    async findBy() {
      return [];
    },
  };
  const attemptRepository = {
    create(value) {
      return value;
    },
    async save(value) {
      savedAttempts.push(...(Array.isArray(value) ? value : [value]));
      return value;
    },
  };
  const manager = {
    getRepository(entity) {
      if (String(entity?.name).includes('AppNotificationEntity')) return notificationRepository;
      if (String(entity?.name).includes('DevicePushTokenEntity')) return tokenRepository;
      if (String(entity?.name).includes('PushDeliveryAttemptEntity')) return attemptRepository;
      throw new Error('Unexpected repository ' + entity?.name);
    },
  };
  const service = new NotificationService({}, {}, {}, createVerifier(), new NotificationPresenter());
  const thread = {
    id: 'thread-1',
    projectId: 'project-1',
    ownerOrganizationId: 'owner-org',
    counterpartOrganizationId: 'recipient-org',
  };
  const message = {
    id: 'message-1',
    body: '项目资料已更新',
    messageKind: 'text',
  };

  const notification = await service.createProjectCommunicationMessageNotification(
    message,
    thread,
    'owner-org',
    manager,
  );

  assert.equal(savedNotifications.length, 1);
  assert.equal(notification.organizationId, 'recipient-org');
  assert.equal(notification.userId, '');
  assert.equal(notification.projectId, 'project-1');
  assert.equal(notification.threadId, 'thread-1');
  assert.equal(notification.body, '项目资料已更新');
  assert.equal(notification.routeTarget.routeParams.projectId, 'project-1');
  assert.equal(savedAttempts.length, 1);
  assert.equal(savedAttempts[0].provider, 'noop');
  assert.equal(savedAttempts[0].attemptStatus, 'skipped');
  assert.equal(savedAttempts[0].errorCode, 'no_device_token');
});

test('bid participation request creates owner notification without project communication message', async () => {
  const { NotificationService } = require('../dist/modules/notifications/notification.service.js');
  const { NotificationPresenter } = require('../dist/modules/notifications/notification.presenter.js');
  const savedNotifications = [];
  const notificationRepository = {
    create(value) {
      return {
        ...value,
        createdAt: new Date('2026-05-04T07:30:00.000Z'),
        updatedAt: new Date('2026-05-04T07:30:00.000Z'),
      };
    },
    async save(value) {
      savedNotifications.push(value);
      return value;
    },
  };
  const manager = {
    getRepository(entity) {
      if (String(entity?.name).includes('AppNotificationEntity')) return notificationRepository;
      throw new Error('Unexpected repository ' + entity?.name);
    },
  };
  const service = new NotificationService({}, {}, {}, createVerifier(), new NotificationPresenter());

  const notification = await service.createBidParticipationRequestCreatedNotification(
    {
      id: 'request-1',
      requesterOrganizationId: 'supplier-org',
    },
    {
      id: 'project-1',
      organizationId: 'publisher-org',
    },
    manager,
  );

  assert.equal(savedNotifications.length, 1);
  assert.equal(notification.type, 'bid_participation_request');
  assert.equal(notification.source, 'bid_participation_request');
  assert.equal(notification.organizationId, 'publisher-org');
  assert.equal(notification.userId, '');
  assert.equal(notification.projectId, 'project-1');
  assert.equal(notification.threadId, 'request-1');
  assert.equal(notification.routeTarget.localEntryKey, 'bid_participation_request.open');
  assert.equal(
    notification.routeTarget.canonicalPath,
    '/api/app/project/bid-participation/thread/detail',
  );
  assert.deepEqual(notification.routeTarget.routeParams, {
    threadId: 'request-1',
    projectId: 'project-1',
    requestId: 'request-1',
  });
});

test('notification mark read updates only actor-owned notifications and returns unread projection', async () => {
  const { NotificationService } = require('../dist/modules/notifications/notification.service.js');
  const { NotificationPresenter } = require('../dist/modules/notifications/notification.presenter.js');
  const notifications = [
    createNotification({ id: 'n-1', source: 'project_communication', readAt: null }),
    createNotification({ id: 'n-2', source: 'forum_interaction', readAt: null }),
    createNotification({ id: 'n-4', source: 'bid_participation_request', readAt: null }),
    createNotification({ id: 'n-3', organizationId: 'other-org', source: 'system', readAt: null }),
  ];
  const queryBuilder = {
    where() { return this; },
    andWhere() { return this; },
    async getMany() { return [notifications[0]]; },
  };
  const repository = {
    createQueryBuilder() { return queryBuilder; },
    async save(items) { return items; },
    async find() {
      return notifications.filter((item) => item.organizationId === 'recipient-org' && !item.readAt);
    },
  };
  const service = new NotificationService(repository, {}, {}, createVerifier('recipient-org'), new NotificationPresenter());

  const result = await service.markRead({ notificationIds: ['n-1'] }, createContext({ organizationId: 'recipient-org' }));

  assert.deepEqual(result.readNotificationIds, ['n-1']);
  assert.ok(notifications[0].readAt instanceof Date);
  assert.deepEqual(result.unread, {
    total: 2,
    projectCommunication: 0,
    bidParticipationRequest: 1,
    forumInteraction: 1,
    system: 0,
  });
});

test('file preview returns signed access without exposing objectKey', async () => {
  const {
    ProjectCommunicationFilePreviewService,
  } = require('../dist/modules/project_communication/project-communication-file-preview.service.js');
  const thread = { id: 'thread-1', projectId: 'project-1' };
  const message = {
    id: 'message-1',
    threadId: 'thread-1',
    projectId: 'project-1',
    payload: { attachment: { fileAssetId: 'asset-1', fileName: '方案.png' } },
  };
  const fileAsset = {
    id: 'asset-1',
    businessType: 'project',
    businessId: 'project-1',
    fileKind: 'project_communication_attachment',
    objectKey: 'private/object-key.png',
    mimeType: 'image/png',
    size: 1234,
  };
  const service = new ProjectCommunicationFilePreviewService(
    { async findOneBy() { return thread; } },
    { async find() { return [message]; } },
    { async findOneBy() { return fileAsset; } },
    { async findOneBy() { return null; } },
    { async findOneBy() { return null; } },
    { async findOneBy() { return null; } },
    { async requireExistingThreadParticipant() { return { organizationId: 'owner-org' }; } },
    { async buildObjectAccessUrl(objectKey) { return 'https://signed.example/' + objectKey; } },
    { uploadSignedUrlExpiresSeconds: 60 },
  );

  const result = await service.getPreviewAccess(
    { projectId: 'project-1', threadId: 'thread-1', fileAssetId: 'asset-1' },
    createContext(),
  );

  assert.equal(result.previewType, 'image');
  assert.equal(result.canPreview, true);
  assert.equal(result.fileName, '方案.png');
  assert.equal(result.accessUrl, 'https://signed.example/private/object-key.png');
  assert.equal(result.objectKey, undefined);
});

test('file preview allows active project album photos without exposing objectKey', async () => {
  const {
    ProjectCommunicationFilePreviewService,
  } = require('../dist/modules/project_communication/project-communication-file-preview.service.js');
  const thread = { id: 'thread-1', projectId: 'project-1' };
  const fileAsset = {
    id: 'asset-1',
    businessType: 'project',
    businessId: 'project-1',
    fileKind: 'project_album_photo',
    objectKey: 'private/album-photo.png',
    mimeType: 'image/png',
    size: 5678,
  };
  const service = new ProjectCommunicationFilePreviewService(
    { async findOneBy() { return thread; } },
    { async find() { return []; } },
    { async findOneBy() { return fileAsset; } },
    { async findOneBy() { return null; } },
    { async findOneBy() { return null; } },
    { async findOneBy() { return { caption: '现场证据图' }; } },
    { async requireExistingThreadParticipant() { return { organizationId: 'owner-org' }; } },
    { async buildObjectAccessUrl(objectKey) { return 'https://signed.example/' + objectKey; } },
    { uploadSignedUrlExpiresSeconds: 60 },
  );

  const result = await service.getPreviewAccess(
    { projectId: 'project-1', threadId: 'thread-1', fileAssetId: 'asset-1' },
    createContext(),
  );

  assert.equal(result.previewType, 'image');
  assert.equal(result.canPreview, true);
  assert.equal(result.fileName, '现场证据图');
  assert.equal(result.accessUrl, 'https://signed.example/private/album-photo.png');
  assert.equal(result.objectKey, undefined);
});

test('confirmation softLink maps material_process to bounded material route target', async () => {
  const {
    ProjectCommunicationSoftLinkService,
  } = require('../dist/modules/project_communication/project-communication-softlink.service.js');
  const service = new ProjectCommunicationSoftLinkService(
    { async findOneBy() { return { id: 'thread-1', projectId: 'project-1' }; } },
    {
      async findOneBy() {
        return {
          id: 'message-1',
          threadId: 'thread-1',
          projectId: 'project-1',
          messageKind: 'confirmation_card',
          payload: {
            confirmation: {
              confirmationType: 'material_process',
              title: '工艺确认',
              summary: '确认主材与收口工艺。',
              status: 'recorded',
            },
          },
        };
      },
    },
    { async requireExistingThreadParticipant() { return { organizationId: 'owner-org' }; } },
  );

  const result = await service.getSoftLink(
    { projectId: 'project-1', threadId: 'thread-1', messageId: 'message-1' },
    createContext(),
  );

  assert.equal(result.confirmationType, 'material');
  assert.equal(result.status, 'recorded');
  assert.equal(result.routeTarget.localEntryKey, 'project_communication.confirmation.material');
  assert.deepEqual(result.routeTarget.routeParams, {
    projectId: 'project-1',
    threadId: 'thread-1',
    messageId: 'message-1',
  });
});
