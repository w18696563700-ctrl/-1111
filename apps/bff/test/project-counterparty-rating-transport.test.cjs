const path = require('path');
require('ts-node').register({
  transpileOnly: true,
  project: path.resolve(__dirname, '../tsconfig.json'),
});
require('reflect-metadata');

const test = require('node:test');
const assert = require('node:assert/strict');
const { Module, RequestMethod } = require('@nestjs/common');
const { PATH_METADATA, METHOD_METADATA } = require('@nestjs/common/constants');
const { NestFactory } = require('@nestjs/core');

const {
  ErrorNormalizerService,
} = require('../src/core/errors/error-normalizer.service.ts');
const {
  AppProjectCounterpartyRatingController,
} = require('../src/routes/project_counterparty_rating/app-project-counterparty-rating.controller.ts');
const {
  ProjectCounterpartyRatingService,
} = require('../src/routes/project_counterparty_rating/project-counterparty-rating.service.ts');

const entryPayload = {
  orderId: 'order-1',
  projectId: 'project-1',
  raterOrganizationId: 'org-rater',
  rateeOrganizationId: 'org-ratee',
  canRate: true,
  reason: null,
  ratingState: 'eligible',
};

const submitPayload = {
  ratingId: 'rating-1',
  orderId: 'order-1',
  projectId: 'project-1',
  raterOrganizationId: 'org-rater',
  rateeOrganizationId: 'org-ratee',
  state: 'submitted',
  ratingState: 'submitted',
  scoreValue: 5,
  scoreLabel: 'satisfied',
  submittedAt: '2026-05-08T10:00:00.000Z',
};

function createService({ onGet, onPost } = {}) {
  return new ProjectCounterpartyRatingService(
    {
      async get(pathName, options) {
        return onGet(pathName, options);
      },
      async post(pathName, payload, options) {
        return onPost(pathName, payload, options);
      },
    },
    {
      buildForwardHeaders(headers) {
        return {
          authorization: headers.authorization ?? 'Bearer smoke',
          'x-user-id': headers['x-user-id'] ?? 'user-1',
          'x-actor-id': headers['x-actor-id'] ?? headers['x-user-id'] ?? 'user-1',
        };
      },
    },
    new ErrorNormalizerService(),
  );
}

function createAxiosError(status, code, message) {
  return {
    isAxiosError: true,
    code: 'ERR_BAD_REQUEST',
    message: `Request failed with status code ${status}`,
    response: {
      status,
      data: {
        code,
        message,
        source: 'server',
      },
    },
  };
}

test('project-counterparty-rating app-facing routes are materialized', async () => {
  const calls = [];
  const service = {
    getEntry(query) {
      calls.push(`entry:${query.orderId}:${query.projectId}:${query.rateeOrganizationId}`);
      return entryPayload;
    },
    submit(payload) {
      calls.push(`submit:${payload.orderId}:${payload.projectId}:${payload.scoreLabel}`);
      return submitPayload;
    },
  };

  class TestModule {}
  Module({
    controllers: [AppProjectCounterpartyRatingController],
    providers: [{ provide: ProjectCounterpartyRatingService, useValue: service }],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, '127.0.0.1');

  try {
    const url = await app.getUrl();
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, AppProjectCounterpartyRatingController),
      'api/app/project-counterparty-rating',
    );
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, AppProjectCounterpartyRatingController.prototype.getEntry),
      RequestMethod.GET,
    );
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, AppProjectCounterpartyRatingController.prototype.submit),
      RequestMethod.POST,
    );

    const entryResponse = await fetch(
      `${url}/api/app/project-counterparty-rating/entry?orderId=order-1&projectId=project-1&rateeOrganizationId=org-ratee`,
    );
    assert.equal(entryResponse.status, 200);
    assert.equal((await entryResponse.json()).canRate, true);

    const submitResponse = await fetch(`${url}/api/app/project-counterparty-rating/submit`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        orderId: 'order-1',
        projectId: 'project-1',
        rateeOrganizationId: 'org-ratee',
        scoreLabel: 'satisfied',
      }),
    });
    assert.equal(submitResponse.status, 202);
    assert.equal((await submitResponse.json()).ratingState, 'submitted');
  } finally {
    await app.close();
  }

  assert.deepEqual(calls, [
    'entry:order-1:project-1:org-ratee',
    'submit:order-1:project-1:satisfied',
  ]);
});

test('project-counterparty-rating entry forwards canonical query to server truth path', async () => {
  let capturedParams = null;
  let capturedHeaders = null;
  const service = createService({
    async onGet(pathName, options) {
      assert.equal(pathName, '/server/project-counterparty-rating/entry');
      capturedParams = options.params;
      capturedHeaders = options.headers;
      return entryPayload;
    },
  });

  const result = await service.getEntry(
    {
      orderId: ' order-1 ',
      projectId: ' project-1 ',
      rateeOrganizationId: ' org-ratee ',
    },
    { 'x-user-id': 'user-9' },
  );

  assert.deepEqual(capturedParams, {
    orderId: 'order-1',
    projectId: 'project-1',
    rateeOrganizationId: 'org-ratee',
  });
  assert.equal(capturedHeaders['x-actor-id'], 'user-9');
  assert.deepEqual(result, entryPayload);
});

test('project-counterparty-rating submit forwards only frozen payload fields', async () => {
  let capturedPayload = null;
  const service = createService({
    async onPost(pathName, payload) {
      assert.equal(pathName, '/server/project-counterparty-rating/submit');
      capturedPayload = payload;
      return submitPayload;
    },
  });

  const result = await service.submit(
    {
      orderId: 'order-1',
      projectId: 'project-1',
      rateeOrganizationId: 'org-ratee',
      scoreLabel: 'satisfied',
      scoreValue: 999,
      commentText: '  合作顺利  ',
      extraFlag: true,
    },
    { 'x-user-id': 'user-1' },
  );

  assert.deepEqual(capturedPayload, {
    orderId: 'order-1',
    projectId: 'project-1',
    rateeOrganizationId: 'org-ratee',
    scoreLabel: 'satisfied',
    commentText: '合作顺利',
  });
  assert.deepEqual(result, submitPayload);
});

test('project-counterparty-rating submit rejects missing truth anchor locally', async () => {
  const service = createService({
    async onPost() {
      throw new Error('should not call upstream');
    },
  });

  await assert.rejects(
    () => service.submit({ orderId: 'order-1', scoreLabel: 'satisfied' }, {}),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'PROJECT_COUNTERPARTY_RATING_INVALID');
      assert.equal(error.getResponse().source, 'bff');
      return true;
    },
  );
});

test('project-counterparty-rating duplicate upstream state maps to stable duplicate code', async () => {
  const service = createService({
    async onPost() {
      throw createAxiosError(
        409,
        undefined,
        'One rating from the same rater to the same ratee already exists.',
      );
    },
  });

  await assert.rejects(
    () =>
      service.submit(
        {
          orderId: 'order-1',
          projectId: 'project-1',
          rateeOrganizationId: 'org-ratee',
          scoreLabel: 'satisfied',
        },
        { 'x-user-id': 'user-1' },
      ),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'PROJECT_COUNTERPARTY_RATING_DUPLICATE');
      assert.equal(error.getResponse().source, 'server');
      return true;
    },
  );
});
