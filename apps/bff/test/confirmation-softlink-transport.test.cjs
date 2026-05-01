const test = require('node:test');
const assert = require('node:assert/strict');
const { METHOD_METADATA, PATH_METADATA } = require('@nestjs/common/constants');
const { RequestMethod } = require('@nestjs/common');

const { ErrorNormalizerService } = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const { ConfirmationSoftLinkController } = require('../dist/apps/bff/src/routes/message_interaction/confirmation-softlink.controller.js');
const { ConfirmationSoftLinkService } = require('../dist/apps/bff/src/routes/message_interaction/confirmation-softlink.service.js');

function createService(onGet) {
  return new ConfirmationSoftLinkService(
    { async get(path, options) { return onGet(path, options); } },
    {
      buildForwardHeaders(headers) {
        return { authorization: headers.authorization, 'x-actor-id': headers['x-actor-id'] ?? 'actor-1' };
      },
    },
    new ErrorNormalizerService(),
  );
}

test('confirmation softLink app route is materialized outside generic chat', () => {
  assert.equal(Reflect.getMetadata(PATH_METADATA, ConfirmationSoftLinkController), 'api/app/confirmation');
  assert.equal(Reflect.getMetadata(PATH_METADATA, ConfirmationSoftLinkController.prototype.getSoftLink), 'softlink/detail');
  assert.equal(Reflect.getMetadata(METHOD_METADATA, ConfirmationSoftLinkController.prototype.getSoftLink), RequestMethod.GET);
});

test('confirmation softLink forwards anchors and only shapes read projection', async () => {
  let captured = null;
  const service = createService(async (path, options) => {
    captured = { path, options };
    return {
      projectId: 'project-1',
      threadId: 'thread-1',
      messageId: 'message-1',
      confirmationType: 'schedule',
      status: 'pending',
      title: '排期确认',
      summary: '确认进场与交付节点。',
      routeTarget: {
        canonicalPath: '/api/app/message/project-communication/messages',
        localEntryKey: 'project_communication.confirmation.schedule',
        routeParams: { projectId: 'project-1', threadId: 'thread-1', messageId: 'message-1' },
      },
    };
  });

  const result = await service.getSoftLink(
    'project-1',
    'thread-1',
    'message-1',
    { authorization: 'Bearer app', 'x-organization-id': 'org-1' },
  );

  assert.equal(captured.path, '/server/confirmation/softlink/detail');
  assert.deepEqual(captured.options.params, { projectId: 'project-1', threadId: 'thread-1', messageId: 'message-1' });
  assert.equal(captured.options.headers['x-organization-id'], 'org-1');
  assert.equal(result.confirmationType, 'schedule');
  assert.equal(result.status, 'pending');
  assert.equal(result.routeTarget.localEntryKey, 'project_communication.confirmation.schedule');
});
