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
            routeTargetAvailability: {
              state: 'missing_context',
              reasonCode: 'PROJECT_COMMUNICATION_CONTEXT_MISSING',
              reasonText: '入口已失效，可从主体项目列表重新进入。',
              fallbackAction: 'none',
              fallbackRouteTarget: null,
            },
            createdAt: '2026-05-01T08:00:00.000Z',
            readAt: null,
            unread: true,
          },
          {
            notificationId: 'n-2',
            type: 'bid_participation_request',
            source: 'bid_participation_request',
            title: '有新的参与竞标申请',
            body: '有供应商提交了参与竞标申请，请进入审核线程处理。',
            projectId: 'project-1',
            threadId: 'request-1',
            routeTarget: {
              canonicalPath: '/api/app/project/bid-participation/thread/detail',
              localEntryKey: 'bid_participation_request.open',
              requiredParams: ['threadId', 'projectId', 'requestId'],
              routeParams: {
                threadId: 'request-1',
                projectId: 'project-1',
                requestId: 'request-1',
              },
              state: 'enabled',
            },
            routeTargetAvailability: {
              state: 'available',
              reasonCode: 'ROUTE_TARGET_AVAILABLE',
              reasonText: '当前通知入口可用。',
              fallbackAction: 'none',
              fallbackRouteTarget: null,
            },
            createdAt: '2026-05-04T07:30:00.000Z',
            readAt: null,
            unread: true,
          },
        ],
        page: { nextCursor: null, hasMore: false },
        unread: {
          total: 7,
          projectCommunication: 1,
          businessTodo: 1,
          bidParticipationRequest: 1,
          forumInteraction: 0,
          system: 5,
        },
      };
    }
    if (path === '/server/notifications/read') {
      return {
        readNotificationIds: ['n-1'],
        unread: {
          total: 6,
          projectCommunication: 0,
          businessTodo: 1,
          bidParticipationRequest: 1,
          forumInteraction: 0,
          system: 5,
        },
      };
    }
    throw new Error(`unexpected ${method} ${path}`);
  });

  const headers = { authorization: 'Bearer app', 'x-organization-id': 'org-1' };
  const registered = await service.registerDeviceToken({ platform: 'ios', provider: 'apns', deviceToken: 'raw-token', appInstallationId: 'install-1' }, headers);
  const list = await service.listNotifications({ pageSize: '20', source: 'business_todo' }, headers);
  const read = await service.markRead({ notificationIds: ['n-1'] }, headers);

  assert.deepEqual(registered, { registered: true, tokenId: 'token-1', platform: 'ios', provider: 'apns' });
  assert.equal(list.items.length, 2);
  assert.equal(list.unread.projectCommunication, 1);
  assert.equal(list.unread.businessTodo, 1);
  assert.equal(list.unread.bidParticipationRequest, 1);
  assert.equal(list.unread.total, 7);
  assert.equal(list.items[1].type, 'bid_participation_request');
  assert.equal(list.items[1].source, 'bid_participation_request');
  assert.equal(list.items[0].routeTargetAvailability.state, 'missing_context');
  assert.equal(list.items[0].routeTargetAvailability.reasonCode, 'PROJECT_COMMUNICATION_CONTEXT_MISSING');
  assert.equal(list.items[1].routeTargetAvailability.state, 'available');
  assert.deepEqual(list.items[1].routeTarget.routeParams, {
    threadId: 'request-1',
    projectId: 'project-1',
    requestId: 'request-1',
  });
  assert.deepEqual(read.readNotificationIds, ['n-1']);
  assert.deepEqual(read.unread, {
    total: 6,
    projectCommunication: 0,
    businessTodo: 1,
    bidParticipationRequest: 1,
    forumInteraction: 0,
    system: 5,
  });
  assert.deepEqual(calls.map((call) => call.path), [
    '/server/notifications/device-token/register',
    '/server/notifications/list',
    '/server/notifications/read',
  ]);
  assert.equal(calls[1].options.params.pageSize, '20');
  assert.equal(calls[1].options.params.source, 'business_todo');
  assert.equal(calls[1].options.headers['x-organization-id'], 'org-1');
});

test('notification read-model fails controlled on unsupported notification type', async () => {
  const service = createService(async (method, path) => {
    assert.equal(method, 'GET');
    assert.equal(path, '/server/notifications/list');
    return {
      items: [
        {
          notificationId: 'n-unknown',
          type: 'generic_chat',
          source: 'system',
          title: 'unsupported',
          createdAt: '2026-05-04T07:30:00.000Z',
          unread: true,
        },
      ],
      page: { nextCursor: null, hasMore: false },
      unread: { total: 1, projectCommunication: 0, businessTodo: 0, bidParticipationRequest: 0, forumInteraction: 0, system: 1 },
    };
  });

  await assert.rejects(
    () => service.listNotifications({}, { authorization: 'Bearer app' }),
    (error) => {
      assert.equal(error.getStatus(), 502);
      assert.equal(error.getResponse().code, 'NOTIFICATION_UNAVAILABLE');
      return true;
    },
  );
});
