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

const { MyBidController } = require('../src/routes/my_bid/my-bid.controller.ts');
const { AppBidController } = require('../src/routes/bid/app-bid.controller.ts');
const { MyBidService } = require('../src/routes/my_bid/my-bid.service.ts');
const { ErrorNormalizerService } = require('../src/core/errors/error-normalizer.service.ts');
const { BidService } = require('../src/routes/bid/bid.service.ts');

function createAxiosResponseError(status, data, message = `Request failed with status code ${status}`) {
  return new AxiosError(message, 'ERR_BAD_REQUEST', {}, null, {
    status,
    statusText: 'error',
    headers: {},
    config: {},
    data,
  });
}

test('my bids and snapshot routes are materialized and no longer router 404 locally', async () => {
  const calls = [];
  const myBidService = {
    getMyBids(state) {
      calls.push(['list', state ?? null]);
      return { items: [] };
    },
  };
  const bidService = {
    getBidSubmissionSnapshot(projectId, bidId) {
      calls.push(['snapshot', projectId, bidId]);
      return {
        projectId,
        bidId,
        bidder: {
          organizationId: 'org-1',
          displayName: '测试供应商',
          avatarUrl: null,
        },
        submittedAt: '2026-04-24T00:00:00.000Z',
        quoteAmount: 1000,
        proposalSummary: '最小摘要',
        attachmentSummary: { count: 0 },
        availability: { canOpenBidThread: true },
      };
    },
  };

  class TestModule {}
  Module({
    controllers: [MyBidController, AppBidController],
    providers: [
      { provide: MyBidService, useValue: myBidService },
      { provide: BidService, useValue: bidService },
    ],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, '127.0.0.1');

  try {
    const url = await app.getUrl();
    assert.equal(Reflect.getMetadata(PATH_METADATA, MyBidController), 'api/app/my/bids');
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, MyBidController.prototype.getMyBids),
      RequestMethod.GET,
    );
    assert.equal(Reflect.getMetadata(PATH_METADATA, AppBidController), 'api/app/bid');
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, AppBidController.prototype.getBidSubmissionSnapshot),
      'submission/snapshot',
    );
    assert.equal(
      Reflect.getMetadata(
        METHOD_METADATA,
        AppBidController.prototype.getBidSubmissionSnapshot,
      ),
      RequestMethod.GET,
    );

    const listResponse = await fetch(`${url}/api/app/my/bids`);
    assert.equal(listResponse.status, 200);
    assert.deepEqual(await listResponse.json(), { items: [] });

    const snapshotResponse = await fetch(
      `${url}/api/app/bid/submission/snapshot?projectId=project-1&bidId=bid-1`,
    );
    assert.equal(snapshotResponse.status, 200);
    assert.equal((await snapshotResponse.json()).bidId, 'bid-1');
  } finally {
    await app.close();
  }

  assert.deepEqual(calls, [
    ['list', null],
    ['snapshot', 'project-1', 'bid-1'],
  ]);
});

test('my bids and snapshot services forward frozen server paths and accepted response carries thread seed', async () => {
  const myBidService = new MyBidService(
    {
      async get(pathName, options) {
        assert.equal(pathName, '/server/my/bids');
        assert.deepEqual(options.params, undefined);
        return {
          items: [
            {
              bidId: 'bid-1',
              projectId: 'project-1',
              projectNo: 'PROJ-1',
              projectTitle: '展台项目',
              quoteAmount: 1000,
              proposalSummaryPreview: '最小摘要',
              submittedAt: '2026-04-24T00:00:00.000Z',
              outcomeState: 'published',
              canOpenBidThread: true,
              canOpenBidResult: false,
              snapshotReadable: true,
              trimmed: 'ignore-me',
            },
          ],
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

  const list = await myBidService.getMyBids(undefined, {});
  assert.equal(list.items.length, 1);
  assert.equal(list.items[0].bidId, 'bid-1');

  const bidService = new BidService(
    {
      async get(pathName, options) {
        assert.equal(pathName, '/server/bid/submission/snapshot');
        assert.deepEqual(options.params, { projectId: 'project-1', bidId: 'bid-1' });
        return {
          projectId: 'project-1',
          bidId: 'bid-1',
          bidder: {
            organizationId: 'org-1',
            displayName: '测试供应商',
            avatarUrl: null,
          },
          submittedAt: '2026-04-24T00:00:00.000Z',
          quoteAmount: 1000,
          proposalSummary: '最小摘要',
          attachmentSummary: { count: 0 },
          availability: { canOpenBidThread: true },
          trimmed: 'ignore-me',
        };
      },
      async post() {
        return {
          bidId: 'bid-1',
          projectId: 'project-1',
          threadId: 'thread-1',
          systemSeed: {
            systemSeedType: 'bid_submitted',
            systemSeedAction: {
              objectType: 'bid_submission_snapshot',
              actionKey: 'bid_submission_snapshot.open',
              canonicalPath: '/api/app/bid/submission/snapshot',
              params: { projectId: 'project-1', bidId: 'bid-1' },
            },
          },
          interactionSeed: {
            seedType: 'bid_submitted',
            routeTarget: {
              objectType: 'bid_thread',
              actionKey: 'bid_thread.open',
              canonicalPath: '/bid/thread/detail',
              params: { projectId: 'project-1', bidId: 'bid-1', threadId: 'thread-1' },
            },
          },
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
    {
      async getCached() {
        return null;
      },
      async remember() {},
    },
    new ErrorNormalizerService(),
  );

  const snapshot = await bidService.getBidSubmissionSnapshot('project-1', 'bid-1', {});
  assert.equal(snapshot.bidId, 'bid-1');

  const brokenService = new BidService(
    {
      async get() {
        throw createAxiosResponseError(404, {
          statusCode: 404,
          message: 'Cannot GET /server/bid/submission/snapshot',
          source: 'server',
        });
      },
      async post() {
        throw new Error('not used');
      },
    },
    {
      buildForwardHeaders() {
        return {};
      },
    },
    {
      async getCached() {
        return null;
      },
      async remember() {},
    },
    new ErrorNormalizerService(),
  );

  await assert.rejects(
    () => brokenService.getBidSubmissionSnapshot('project-1', 'bid-1', {}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      const response = error.getResponse();
      assert.equal(response.statusCode, 404);
      assert.equal(response.code, 'BID_SUBMISSION_SNAPSHOT_UNAVAILABLE');
      assert.equal(response.message, '当前竞标摘要暂不可用，请稍后再试。');
      assert.equal(response.source, 'server');
      return true;
    },
  );

  const accepted = await bidService.submitBid(
    {
      projectId: 'project-1',
      quoteAmount: 1000,
      proposalSummary: '最小摘要',
    },
    {},
  );
  assert.deepEqual(accepted, {
    bidId: 'bid-1',
    threadSeed: {
      threadId: 'thread-1',
      projectId: 'project-1',
      bidId: 'bid-1',
      messageKind: 'system_seed',
      systemSeedType: 'bid_submitted',
      systemSeedAction: {
        objectType: 'bid_submission_snapshot',
        actionKey: 'bid_submission_snapshot.open',
        canonicalPath: '/api/app/bid/submission/snapshot',
        params: { projectId: 'project-1', bidId: 'bid-1' },
      },
    },
  });
});
