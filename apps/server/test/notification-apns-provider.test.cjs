require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');

const APNS_ENV_KEYS = [
  'APNS_KEY_ID',
  'APNS_TEAM_ID',
  'APNS_BUNDLE_ID',
  'APNS_ENV',
  'APNS_AUTH_KEY_PATH',
];

function withClearedApnsEnv(fn) {
  const previous = Object.fromEntries(APNS_ENV_KEYS.map((key) => [key, process.env[key]]));
  for (const key of APNS_ENV_KEYS) {
    delete process.env[key];
  }
  return Promise.resolve()
    .then(fn)
    .finally(() => {
      for (const key of APNS_ENV_KEYS) {
        if (previous[key] === undefined) {
          delete process.env[key];
        } else {
          process.env[key] = previous[key];
        }
      }
    });
}

function createVerifier() {
  return {
    async verifyCurrentSessionContext(context) {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'user-1',
          userId: 'user-1',
          organizationId: 'recipient-org',
          requestId: context.requestId,
          traceId: context.traceId,
        },
      };
    },
  };
}

test('APNs adapter degrades without provider credentials', async () => {
  await withClearedApnsEnv(async () => {
    const {
      ApnsPushProviderAdapter,
    } = require('../dist/modules/notifications/apns-push-provider.adapter.js');
    const adapter = new ApnsPushProviderAdapter();

    const result = await adapter.deliver(
      {
        id: 'token-1',
        provider: 'apns',
        deviceToken: 'device-token-hidden',
      },
      {
        id: 'notification-1',
        title: '测试通知',
        body: '测试内容',
        source: 'system',
        routeTarget: {},
      },
    );

    assert.equal(result.provider, 'apns');
    assert.equal(result.attemptStatus, 'provider_credentials_unavailable');
    assert.equal(result.errorCode, 'provider_credentials_unavailable');
  });
});

test('notification service records APNs delivery result and deactivates invalid tokens', async () => {
  const { NotificationService } = require('../dist/modules/notifications/notification.service.js');
  const { NotificationPresenter } = require('../dist/modules/notifications/notification.presenter.js');
  const tokens = [
    {
      id: 'token-1',
      organizationId: 'recipient-org',
      provider: 'apns',
      deviceToken: 'device-token-hidden',
      tokenState: 'active',
    },
  ];
  const savedAttempts = [];
  const savedTokens = [];
  const notificationRepository = {
    create(value) {
      return {
        ...value,
        createdAt: new Date('2026-05-06T08:00:00.000Z'),
        updatedAt: new Date('2026-05-06T08:00:00.000Z'),
      };
    },
    async save(value) {
      return value;
    },
  };
  const tokenRepository = {
    async findBy() {
      return tokens;
    },
    async save(value) {
      savedTokens.push(value);
      return value;
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
  const pushProvider = {
    async deliver() {
      return {
        provider: 'apns',
        attemptStatus: 'token_invalid',
        errorCode: 'BadDeviceToken',
        errorMessage: 'APNs rejected this device token.',
      };
    },
  };
  const service = new NotificationService(
    {},
    {},
    {},
    createVerifier(),
    new NotificationPresenter(),
    undefined,
    pushProvider,
  );

  await service.createProjectCommunicationMessageNotification(
    {
      id: 'message-1',
      body: '测试消息',
      messageKind: 'text',
    },
    {
      id: 'thread-1',
      projectId: 'project-1',
      ownerOrganizationId: 'sender-org',
      counterpartOrganizationId: 'recipient-org',
    },
    'sender-org',
    manager,
  );

  assert.equal(savedAttempts.length, 1);
  assert.equal(savedAttempts[0].provider, 'apns');
  assert.equal(savedAttempts[0].attemptStatus, 'token_invalid');
  assert.equal(savedAttempts[0].errorCode, 'BadDeviceToken');
  assert.equal(tokens[0].tokenState, 'inactive');
  assert.equal(savedTokens.length, 1);
});

test('notification service creates forum interaction notifications in the forum bucket', async () => {
  const { NotificationService } = require('../dist/modules/notifications/notification.service.js');
  const { NotificationPresenter } = require('../dist/modules/notifications/notification.presenter.js');
  const savedNotifications = [];
  const savedAttempts = [];
  const notificationRepository = {
    create(value) {
      return {
        ...value,
        createdAt: new Date('2026-05-06T08:00:00.000Z'),
        updatedAt: new Date('2026-05-06T08:00:00.000Z'),
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
  const service = new NotificationService(
    {},
    {},
    {},
    createVerifier(),
    new NotificationPresenter(),
    undefined,
    {
      async deliver() {
        throw new Error('no token should be delivered');
      },
    },
  );

  await service.createForumInteractionNotification(
    {
      tab: 'replies',
      title: '有新的论坛回复',
      body: '有人评论了你的帖子。',
      recipientUserId: 'owner-user',
      recipientOrganizationId: 'owner-org',
      actorUserId: 'other-user',
      targetId: 'post-1',
    },
    manager,
  );

  assert.equal(savedNotifications.length, 1);
  assert.equal(savedNotifications[0].type, 'forum_interaction');
  assert.equal(savedNotifications[0].source, 'forum_interaction');
  assert.equal(savedNotifications[0].userId, 'owner-user');
  assert.equal(savedNotifications[0].organizationId, 'owner-org');
  assert.deepEqual(savedNotifications[0].routeTarget, {
    canonicalPath: '/api/app/forum/interaction/inbox',
    localEntryKey: 'forum_interaction.open',
    requiredParams: ['tab'],
    routeParams: {
      tab: 'replies',
      targetId: 'post-1',
    },
    state: 'enabled',
  });
  assert.equal(savedAttempts.length, 1);
  assert.equal(savedAttempts[0].attemptStatus, 'skipped');
  assert.equal(savedAttempts[0].errorCode, 'no_device_token');
});

test('notification service skips self forum interaction notifications', async () => {
  const { NotificationService } = require('../dist/modules/notifications/notification.service.js');
  const { NotificationPresenter } = require('../dist/modules/notifications/notification.presenter.js');
  const savedNotifications = [];
  const manager = {
    getRepository(entity) {
      if (String(entity?.name).includes('AppNotificationEntity')) {
        return {
          create(value) {
            return value;
          },
          async save(value) {
            savedNotifications.push(value);
            return value;
          },
        };
      }
      throw new Error('Unexpected repository ' + entity?.name);
    },
  };
  const service = new NotificationService(
    {},
    {},
    {},
    createVerifier(),
    new NotificationPresenter(),
  );

  const result = await service.createForumInteractionNotification(
    {
      tab: 'likes',
      title: '有新的论坛点赞',
      body: '有人点赞了你的帖子。',
      recipientUserId: 'same-user',
      recipientOrganizationId: 'same-org',
      actorUserId: 'same-user',
      targetId: 'post-1',
    },
    manager,
  );

  assert.equal(result, null);
  assert.equal(savedNotifications.length, 0);
});
