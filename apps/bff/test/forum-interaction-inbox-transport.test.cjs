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

const { AppForumController } = require('../src/routes/forum/app-forum.controller.ts');
const { ForumAuthorProfileService } = require('../src/routes/forum/forum-author-profile.service.ts');
const { ForumDraftOpenService } = require('../src/routes/forum/forum-draft-open.service.ts');
const { ForumInteractionInboxService } = require('../src/routes/forum/forum-interaction-inbox.service.ts');
const { ForumInteractionService } = require('../src/routes/forum/forum-interaction.service.ts');
const { ForumOwnPostContinuityService } = require('../src/routes/forum/forum-own-post-continuity.service.ts');
const { ForumReportMineService } = require('../src/routes/forum/forum-report-mine.service.ts');
const { ForumService } = require('../src/routes/forum/forum.service.ts');
const { ErrorNormalizerService } = require('../src/core/errors/error-normalizer.service.ts');

function createAxiosResponseError(
  status,
  data,
  message = `Request failed with status code ${status}`
) {
  return new AxiosError(message, 'ERR_BAD_REQUEST', {}, null, {
    status,
    statusText: 'error',
    headers: {},
    config: {},
    data,
  });
}

test('forum interaction inbox app route is materialized and calls BFF inbox service', async () => {
  const calls = [];
  const inboxService = {
    getInbox(headers, tab, cursor, pageSize) {
      calls.push({
        authorization: headers.authorization,
        tab,
        cursor,
        pageSize,
      });
      return {
        items: [],
        page: { nextCursor: null, hasMore: false },
      };
    },
  };

  class TestModule {}
  Module({
    controllers: [AppForumController],
    providers: [
      { provide: ForumService, useValue: {} },
      { provide: ForumAuthorProfileService, useValue: {} },
      { provide: ForumInteractionService, useValue: {} },
      { provide: ForumInteractionInboxService, useValue: inboxService },
      { provide: ForumDraftOpenService, useValue: {} },
      { provide: ForumOwnPostContinuityService, useValue: {} },
      { provide: ForumReportMineService, useValue: {} },
    ],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, '127.0.0.1');

  try {
    const url = await app.getUrl();
    assert.equal(Reflect.getMetadata(PATH_METADATA, AppForumController), 'api/app/forum');
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, AppForumController.prototype.getInteractionInbox),
      'interaction/inbox'
    );
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, AppForumController.prototype.getInteractionInbox),
      RequestMethod.GET
    );

    const response = await fetch(
      `${url}/api/app/forum/interaction/inbox?tab=replies&cursor=2026-04-24T00%3A00%3A00.000Z&pageSize=3`,
      { headers: { authorization: 'Bearer app' } }
    );
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), {
      items: [],
      page: { nextCursor: null, hasMore: false },
    });
    assert.deepEqual(calls, [
      {
        authorization: 'Bearer app',
        tab: 'replies',
        cursor: '2026-04-24T00:00:00.000Z',
        pageSize: '3',
      },
    ]);
  } finally {
    await app.close();
  }
});

test('forum interaction inbox BFF service forwards three tabs and empty response', async () => {
  const calls = [];
  const serverClient = {
    get: async (serverPath, options) => {
      calls.push({ serverPath, options });
      return { items: [], page: { nextCursor: null, hasMore: false } };
    },
  };
  const commandContext = {
    buildCommandHeaders: async () => ({
      authorization: 'Bearer forwarded',
      'x-current-user-id': 'user-1',
    }),
  };
  const service = new ForumInteractionInboxService(
    serverClient,
    new ErrorNormalizerService(),
    commandContext
  );

  for (const tab of ['replies', 'likes', 'follows']) {
    const result = await service.getInbox({ authorization: 'Bearer app' }, tab, undefined, '20');
    assert.deepEqual(result, { items: [], page: { nextCursor: null, hasMore: false } });
  }

  assert.deepEqual(
    calls.map((call) => ({
      serverPath: call.serverPath,
      tab: call.options.params.tab,
      pageSize: call.options.params.pageSize,
      authorization: call.options.headers.authorization,
    })),
    [
      {
        serverPath: '/server/forum/interaction/inbox',
        tab: 'replies',
        pageSize: '20',
        authorization: 'Bearer forwarded',
      },
      {
        serverPath: '/server/forum/interaction/inbox',
        tab: 'likes',
        pageSize: '20',
        authorization: 'Bearer forwarded',
      },
      {
        serverPath: '/server/forum/interaction/inbox',
        tab: 'follows',
        pageSize: '20',
        authorization: 'Bearer forwarded',
      },
    ]
  );
});

test('forum interaction inbox BFF service preserves auth failure and illegal tab errors', async () => {
  const commandContext = {
    buildCommandHeaders: async () => ({ authorization: 'Bearer forwarded' }),
  };
  const makeService = (error) =>
    new ForumInteractionInboxService(
      {
        get: async () => {
          throw error;
        },
      },
      new ErrorNormalizerService(),
      commandContext
    );

  await assert.rejects(
    () =>
      makeService(
        createAxiosResponseError(401, {
          code: 'AUTH_SESSION_INVALID',
          message: 'Current session is invalid.',
        })
      ).getInbox({}, 'replies'),
    (error) => error.getStatus() === 401 && error.getResponse().code === 'AUTH_SESSION_INVALID'
  );
  await assert.rejects(
    () =>
      makeService(
        createAxiosResponseError(400, {
          code: 'FORUM_INTERACTION_INBOX_INVALID',
          message: 'tab must be one of replies, likes, follows.',
        })
      ).getInbox({}, 'bad'),
    (error) =>
      error.getStatus() === 400 && error.getResponse().code === 'FORUM_INTERACTION_INBOX_INVALID'
  );
});
