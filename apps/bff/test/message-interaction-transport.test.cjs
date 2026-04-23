const path = require('path');
require('ts-node').register({
  transpileOnly: true,
  project: path.resolve(__dirname, '../tsconfig.json'),
});
require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');
const { AxiosError } = require('axios');
const { Module, RequestMethod } = require('@nestjs/common');
const { PATH_METADATA, METHOD_METADATA } = require('@nestjs/common/constants');
const { NestFactory } = require('@nestjs/core');

const { MessageInteractionController } = require('../src/routes/message_interaction/message-interaction.controller.ts');
const { MessageInteractionService } = require('../src/routes/message_interaction/message-interaction.service.ts');
const { ErrorNormalizerService } = require('../src/core/errors/error-normalizer.service.ts');

function createAxiosResponseError(status, data, message = `Request failed with status code ${status}`) {
  return new AxiosError(message, 'ERR_BAD_REQUEST', {}, null, {
    status,
    statusText: 'error',
    headers: {},
    config: {},
    data,
  });
}

test('message interactions route is materialized and no longer router 404 locally', async () => {
  const calls = [];
  const service = {
    getInteractions(lane) {
      calls.push(lane ?? null);
      return {
        lane: lane ?? 'project_communication',
        items: [],
      };
    },
  };

  class TestModule {}
  Module({
    controllers: [MessageInteractionController],
    providers: [{ provide: MessageInteractionService, useValue: service }],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, '127.0.0.1');

  try {
    const url = await app.getUrl();
    assert.equal(Reflect.getMetadata(PATH_METADATA, MessageInteractionController), 'api/app/message');
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, MessageInteractionController.prototype.getInteractions),
      'interactions',
    );
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, MessageInteractionController.prototype.getInteractions),
      RequestMethod.GET,
    );

    const response = await fetch(
      `${url}/api/app/message/interactions?lane=project_communication`,
    );
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), {
      lane: 'project_communication',
      items: [],
    });
  } finally {
    await app.close();
  }

  assert.deepEqual(calls, ['project_communication']);
});

test('message interactions service forwards frozen server path and hides raw route drift', async () => {
  const service = new MessageInteractionService(
    {
      async get(pathName, options) {
        assert.equal(pathName, '/server/message/interactions');
        assert.deepEqual(options.params, { lane: 'project_communication' });
        return {
          lane: 'project_communication',
          items: [],
          trimmed: 'ignore-me',
        };
      },
    },
    {
      buildForwardHeaders() {
        return {
          authorization: 'Bearer token',
          'x-organization-id': 'org-1',
          'x-actor-role': 'supplier_admin',
        };
      },
    },
    new ErrorNormalizerService(),
  );

  const result = await service.getInteractions(undefined, {});
  assert.deepEqual(result, {
    lane: 'project_communication',
    items: [],
  });

  const brokenService = new MessageInteractionService(
    {
      async get() {
        throw createAxiosResponseError(404, {
          statusCode: 404,
          message: 'Cannot GET /server/message/interactions',
          source: 'server',
        });
      },
    },
    {
      buildForwardHeaders() {
        return {};
      },
    },
    new ErrorNormalizerService(),
  );

  await assert.rejects(
    () => brokenService.getInteractions(undefined, {}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.deepEqual(error.getResponse(), {
        statusCode: 404,
        code: 'MESSAGE_INTERACTION_UNAVAILABLE',
        message: '当前项目沟通入口暂不可用，请稍后再试。',
        source: 'server',
      });
      return true;
    },
  );
});
