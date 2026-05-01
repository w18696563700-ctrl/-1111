const test = require('node:test');
const assert = require('node:assert/strict');
const { METHOD_METADATA, PATH_METADATA } = require('@nestjs/common/constants');
const { RequestMethod } = require('@nestjs/common');

const { ErrorNormalizerService } = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const { AppNotificationController } = require('../dist/apps/bff/src/routes/notification/app-notification.controller.js');
const { NotificationRouteService } = require('../dist/apps/bff/src/routes/notification/notification.service.js');

function createService(onRequest) {
  return new NotificationRouteService(
    {
      async get(path, options) { return onRequest('GET', path, undefined, options); },
      async post(path, body, options) { return onRequest('POST', path, body, options); },
    },
    {
      buildForwardHeaders(headers) {
        return {
          authorization: headers.authorization,
          'x-actor-id': headers['x-actor-id'] ?? 'actor-1',
        };
      },
    },
    new ErrorNormalizerService(),
  );
}

test('notification app routes are materialized under bounded notifications family', () => {
  assert.equal(Reflect.getMetadata(PATH_METADATA, AppNotificationController), 'api/app/notifications');
  assert.equal(Reflect.getMetadata(PATH_METADATA, AppNotificationController.prototype.registerDeviceToken), 'device-token/register');
  assert.equal(Reflect.getMetadata(METHOD_METADATA, AppNotificationController.prototype.registerDeviceToken), RequestMethod.POST);
  assert.equal(Reflect.getMetadata(PATH_METADATA, AppNotificationController.prototype.listNotifications), 'list');
  assert.equal(Reflect.getMetadata(METHOD_METADATA, AppNotificationController.prototype.listNotifications), RequestMethod.GET);
  assert.equal(Reflect.getMetadata(PATH_METADATA, AppNotificationController.prototype.markRead), 'read');
  assert.equal(Reflect.getMetadata(METHOD_METADATA, AppNotificationController.prototype.markRead), RequestMethod.POST);
});

test('notification routes forward to Server without owning unread truth', async () => {
  const calls = [];
  const service = createService(async (method, path, body, options) => {
    calls.push({ method, path, body, options });
    if (path === '/server/notifications/device-token/register') {
      return { registered: true, tokenId: 'token-1', platform: 'ios', provider: 'apns' };
    }
    if (path === '/server/notifications/list') {
      return {
        items: [
          {
            notificationId: 'n-1',
            type: 'project_communication_message',
            source: 'project_communication',
            title: '有新的项目沟通消息',
            body: 'hello',
            projectId: 'project-1',
            threadId: 'thread-1',
            routeTarget: { canonicalPath: '/api/app/message/project-communication/messages' },
            createdAt: '2026-05-01T08:00:00.000Z',
            readAt: null,
            unread: true,
          },
        ],
        page: { nextCursor: null, hasMore: false },
        unread: { total: 1, projectCommunication: 1, forumInteraction: 0, system: 0 },
      };
    }
    if (path === '/server/notifications/read') {
      return { readNotificationIds: ['n-1'], unread: { total: 0, projectCommunication: 0, forumInteraction: 0, system: 0 } };
    }
    throw new Error(`unexpected ${method} ${path}`);
  });

  const headers = { authorization: 'Bearer app', 'x-organization-id': 'org-1' };
  const registered = await service.registerDeviceToken({ platform: 'ios', provider: 'apns', deviceToken: 'raw-token', appInstallationId: 'install-1' }, headers);
  const list = await service.listNotifications('20', undefined, headers);
  const read = await service.markRead({ notificationIds: ['n-1'] }, headers);

  assert.deepEqual(registered, { registered: true, tokenId: 'token-1', platform: 'ios', provider: 'apns' });
  assert.equal(list.items.length, 1);
  assert.equal(list.unread.projectCommunication, 1);
  assert.deepEqual(read.readNotificationIds, ['n-1']);
  assert.deepEqual(calls.map((call) => call.path), [
    '/server/notifications/device-token/register',
    '/server/notifications/list',
    '/server/notifications/read',
  ]);
  assert.equal(calls[1].options.params.pageSize, '20');
  assert.equal(calls[1].options.headers['x-organization-id'], 'org-1');
});
