const path = require('path');
require('ts-node').register({
  transpileOnly: true,
  project: path.resolve(__dirname, '../../../tsconfig.json'),
});
require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');
const { AxiosError } = require('axios');
const { Module, RequestMethod } = require('@nestjs/common');
const { PATH_METADATA, METHOD_METADATA } = require('@nestjs/common/constants');
const { NestFactory } = require('@nestjs/core');

const { AppBidController } = require('./app-bid.controller.ts');
const { BidService } = require('./bid.service.ts');
const { ErrorNormalizerService } = require('../../core/errors/error-normalizer.service.ts');

function createAxiosResponseError(status, data, message = `Request failed with status code ${status}`) {
  return new AxiosError(message, 'ERR_BAD_REQUEST', {}, null, {
    status,
    statusText: 'error',
    headers: {},
    config: {},
    data,
  });
}

test('app-facing seat and completeness routes are materialized in authoritative source', async () => {
  const calls = [];
  const bidService = {
    lockSeat(payload, headers, idempotencyKey) {
      calls.push(['lock', payload, idempotencyKey, headers['x-request-id'] ?? null]);
      return {
        seatId: 'seat-1',
        projectId: 'project-1',
        bidId: 'bid-1',
        state: 'locked',
        expiresAt: '2026-04-13T00:00:00.000Z',
        releasedAt: null,
      };
    },
    releaseSeat(payload, headers, idempotencyKey) {
      calls.push(['release', payload, idempotencyKey, headers['x-request-id'] ?? null]);
      return {
        seatId: 'seat-1',
        projectId: 'project-1',
        bidId: 'bid-1',
        state: 'released',
        expiresAt: null,
        releasedAt: '2026-04-13T01:00:00.000Z',
      };
    },
    getSeatStatus(projectId, bidId) {
      calls.push(['status', projectId, bidId]);
      return {
        seatId: 'seat-1',
        projectId,
        bidId,
        state: 'timed_out',
        expiresAt: '2026-04-13T00:00:00.000Z',
        releasedAt: null,
      };
    },
    getPackageCompleteness(projectId, bidId) {
      calls.push(['completeness', projectId, bidId]);
      return {
        bidId,
        projectId,
        state: 'incomplete',
        missingItems: ['proposalSummary'],
        quoteAmountReady: true,
        proposalSummaryReady: false,
      };
    },
    submitBid() {
      throw new Error('not used');
    },
    awardBid() {
      throw new Error('not used');
    },
    getBidResult() {
      throw new Error('not used');
    },
  };

  class TestModule {}
  Module({
    controllers: [AppBidController],
    providers: [{ provide: BidService, useValue: bidService }],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, '127.0.0.1');

  try {
    const url = await app.getUrl();
    assert.equal(Reflect.getMetadata(PATH_METADATA, AppBidController), 'api/app/bid');
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, AppBidController.prototype.lockSeat),
      'seat/lock',
    );
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, AppBidController.prototype.lockSeat),
      RequestMethod.POST,
    );
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, AppBidController.prototype.releaseSeat),
      'seat/release',
    );
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, AppBidController.prototype.getSeatStatus),
      'seat/status',
    );
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, AppBidController.prototype.getPackageCompleteness),
      'package-completeness',
    );

    const lockResponse = await fetch(`${url}/api/app/bid/seat/lock`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-idempotency-key': 'idem-lock',
      },
      body: JSON.stringify({ projectId: 'project-1', bidId: 'bid-1' }),
    });
    assert.equal(lockResponse.status, 202);
    assert.equal((await lockResponse.json()).state, 'locked');

    const releaseResponse = await fetch(`${url}/api/app/bid/seat/release`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-idempotency-key': 'idem-release',
      },
      body: JSON.stringify({ projectId: 'project-1', bidId: 'bid-1' }),
    });
    assert.equal(releaseResponse.status, 202);
    assert.equal((await releaseResponse.json()).state, 'released');

    const seatStatusResponse = await fetch(
      `${url}/api/app/bid/seat/status?projectId=project-1&bidId=bid-1`,
    );
    assert.equal(seatStatusResponse.status, 200);
    assert.equal((await seatStatusResponse.json()).state, 'timed_out');

    const completenessResponse = await fetch(
      `${url}/api/app/bid/package-completeness?projectId=project-1&bidId=bid-1`,
    );
    assert.equal(completenessResponse.status, 200);
    assert.equal((await completenessResponse.json()).state, 'incomplete');
  } finally {
    await app.close();
  }

  assert.deepEqual(calls, [
    ['lock', { projectId: 'project-1', bidId: 'bid-1' }, 'idem-lock', null],
    ['release', { projectId: 'project-1', bidId: 'bid-1' }, 'idem-release', null],
    ['status', 'project-1', 'bid-1'],
    ['completeness', 'project-1', 'bid-1'],
  ]);
});

test('seat lock, release, status, and package completeness forward to frozen server paths and shape responses', async () => {
  const calls = [];
  const rememberCalls = [];
  const service = new BidService(
    {
      async post(pathName, body, options) {
        calls.push({ method: 'post', pathName, body, options });
        if (pathName === '/server/bid/seat/lock') {
          return {
            seatId: 'seat-1',
            projectId: 'project-1',
            bidId: 'bid-1',
            state: 'locked',
            expiresAt: '2026-04-13T00:00:00.000Z',
            releasedAt: null,
            lockAuditId: 'trim-me',
          };
        }
        return {
          seatId: 'seat-1',
          projectId: 'project-1',
          bidId: 'bid-1',
          state: 'released',
          expiresAt: null,
          releasedAt: '2026-04-13T01:00:00.000Z',
          auditTrail: ['trim-me'],
        };
      },
      async get(pathName, options) {
        calls.push({ method: 'get', pathName, options });
        if (pathName === '/server/bid/seat/status') {
          return {
            seatId: 'seat-1',
            projectId: 'project-1',
            bidId: 'bid-1',
            state: 'stale_locked',
            expiresAt: '2026-04-13T00:00:00.000Z',
            releasedAt: null,
            internalLockOwner: 'trim-me',
          };
        }
        return {
          bidId: 'bid-1',
          projectId: 'project-1',
          state: 'incomplete',
          missingItems: ['proposalSummary'],
          quoteAmountReady: true,
          proposalSummaryReady: false,
          recomputeReason: 'trim-me',
        };
      },
    },
    {
      buildForwardHeaders() {
        return {
          authorization: 'Bearer token',
          'x-actor-id': 'actor-1',
          'x-organization-id': 'org-1',
          'x-actor-role': 'supplier',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
        };
      },
    },
    {
      async getCached() {
        return null;
      },
      async remember(scope, key, value) {
        rememberCalls.push({ scope, key, value });
      },
    },
    new ErrorNormalizerService(),
  );

  const lockResult = await service.lockSeat({ projectId: ' project-1 ', bidId: ' bid-1 ' }, {}, ' lock-key ');
  const releaseResult = await service.releaseSeat({ projectId: 'project-1', bidId: 'bid-1' }, {}, 'release-key');
  const statusResult = await service.getSeatStatus(' project-1 ', ' bid-1 ', {});
  const completenessResult = await service.getPackageCompleteness(' project-1 ', ' bid-1 ', {});

  assert.deepEqual(lockResult, {
    seatId: 'seat-1',
    projectId: 'project-1',
    bidId: 'bid-1',
    state: 'locked',
    expiresAt: '2026-04-13T00:00:00.000Z',
    releasedAt: null,
  });
  assert.deepEqual(releaseResult, {
    seatId: 'seat-1',
    projectId: 'project-1',
    bidId: 'bid-1',
    state: 'released',
    expiresAt: null,
    releasedAt: '2026-04-13T01:00:00.000Z',
  });
  assert.deepEqual(statusResult, {
    seatId: 'seat-1',
    projectId: 'project-1',
    bidId: 'bid-1',
    state: 'timed_out',
    expiresAt: '2026-04-13T00:00:00.000Z',
    releasedAt: null,
  });
  assert.deepEqual(completenessResult, {
    bidId: 'bid-1',
    projectId: 'project-1',
    state: 'incomplete',
    missingItems: ['proposalSummary'],
    quoteAmountReady: true,
    proposalSummaryReady: false,
  });

  assert.deepEqual(calls, [
    {
      method: 'post',
      pathName: '/server/bid/seat/lock',
      body: { projectId: 'project-1', bidId: 'bid-1' },
      options: {
        headers: {
          authorization: 'Bearer token',
          'x-actor-id': 'actor-1',
          'x-organization-id': 'org-1',
          'x-actor-role': 'supplier',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
          'x-idempotency-key': 'lock-key',
        },
      },
    },
    {
      method: 'post',
      pathName: '/server/bid/seat/release',
      body: { projectId: 'project-1', bidId: 'bid-1' },
      options: {
        headers: {
          authorization: 'Bearer token',
          'x-actor-id': 'actor-1',
          'x-organization-id': 'org-1',
          'x-actor-role': 'supplier',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
          'x-idempotency-key': 'release-key',
        },
      },
    },
    {
      method: 'get',
      pathName: '/server/bid/seat/status',
      options: {
        headers: {
          authorization: 'Bearer token',
          'x-actor-id': 'actor-1',
          'x-organization-id': 'org-1',
          'x-actor-role': 'supplier',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
        },
        params: {
          projectId: 'project-1',
          bidId: 'bid-1',
        },
      },
    },
    {
      method: 'get',
      pathName: '/server/bid/package-completeness',
      options: {
        headers: {
          authorization: 'Bearer token',
          'x-actor-id': 'actor-1',
          'x-organization-id': 'org-1',
          'x-actor-role': 'supplier',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
        },
        params: {
          projectId: 'project-1',
          bidId: 'bid-1',
        },
      },
    },
  ]);

  assert.deepEqual(rememberCalls, [
    {
      scope: 'bid-seat-lock',
      key: 'lock-key',
      value: lockResult,
    },
    {
      scope: 'bid-seat-release',
      key: 'release-key',
      value: releaseResult,
    },
  ]);
});

test('seat status accepts available with null seatId while lock and release still require seatId', async () => {
  const {
    readBidSeatReadModel,
    readBidSeatStatusReadModel,
  } = require('./bid-seat-completeness.read-model.ts');

  const statusResult = readBidSeatStatusReadModel({
    seatId: null,
    projectId: 'project-1',
    bidId: 'bid-1',
    state: 'available',
    expiresAt: null,
    releasedAt: null,
  });
  assert.deepEqual(statusResult, {
    seatId: null,
    projectId: 'project-1',
    bidId: 'bid-1',
    state: 'available',
    expiresAt: null,
    releasedAt: null,
  });

  assert.throws(
    () =>
      readBidSeatReadModel({
        seatId: null,
        projectId: 'project-1',
        bidId: 'bid-1',
        state: 'locked',
        expiresAt: null,
        releasedAt: null,
      }),
    /Bid response is missing `seatId`\./,
  );
});

test('seat and completeness errors are mapped to minimal app-facing semantics', async () => {
  const service = new BidService(
    {
      async post(pathName) {
        if (pathName === '/server/bid/seat/lock') {
          throw createAxiosResponseError(409, {
            code: 'BID_SEAT_CONFLICT',
            message: 'Seat already locked by another bid.',
            source: 'server',
            details: { internal: true },
          });
        }
        throw createAxiosResponseError(401, {
          code: 'AUTH_SESSION_INVALID',
          message: 'Session expired.',
          source: 'server',
        });
      },
      async get(pathName) {
        if (pathName === '/server/bid/package-completeness') {
          throw createAxiosResponseError(404, {
            code: 'AUTH_RESOURCE_UNAVAILABLE',
            message: 'Cannot GET /server/bid/package-completeness',
            source: 'server',
          });
        }
        throw createAxiosResponseError(403, {
          code: 'AUTH_PERMISSION_INSUFFICIENT',
          message: 'Forbidden.',
          source: 'server',
        });
      },
    },
    {
      buildForwardHeaders() {
        return {
          authorization: 'Bearer token',
          'x-actor-id': 'actor-1',
          'x-request-id': 'request-1',
          'x-trace-id': 'trace-1',
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

  await assert.rejects(
    () => service.lockSeat({ projectId: 'project-1', bidId: 'bid-1' }, {}, 'lock-key'),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.deepEqual(error.getResponse(), {
        statusCode: 409,
        code: 'BID_SEAT_CONFLICT',
        message: '当前席位已被占用，请刷新后重试。',
        details: undefined,
        source: 'server',
      });
      return true;
    },
  );

  await assert.rejects(
    () => service.releaseSeat({ projectId: 'project-1', bidId: 'bid-1' }, {}, 'release-key'),
    (error) => {
      assert.equal(error.getStatus(), 401);
      assert.deepEqual(error.getResponse(), {
        statusCode: 401,
        code: 'AUTH_SESSION_INVALID',
        message: '当前登录态不可用，请重新登录后再试。',
        details: undefined,
        source: 'server',
      });
      return true;
    },
  );

  await assert.rejects(
    () => service.getSeatStatus('project-1', 'bid-1', {}),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.deepEqual(error.getResponse(), {
        statusCode: 403,
        code: 'AUTH_PERMISSION_INSUFFICIENT',
        message: '当前组织不具备查看席位状态的权限，请确认组织身份后再试。',
        details: undefined,
        source: 'server',
      });
      return true;
    },
  );

  await assert.rejects(
    () => service.getPackageCompleteness('project-1', 'bid-1', {}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.deepEqual(error.getResponse(), {
        statusCode: 404,
        code: 'BID_PACKAGE_COMPLETENESS_UNAVAILABLE',
        message: '当前投标资料完整性暂不可用，请稍后再试。',
        details: undefined,
        source: 'server',
      });
      return true;
    },
  );
});
