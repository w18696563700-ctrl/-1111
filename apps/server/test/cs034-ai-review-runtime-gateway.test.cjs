const test = require('node:test');
const assert = require('node:assert/strict');

const context = {
  authorization: 'Bearer test',
  actorId: 'gateway-actor',
  userId: 'gateway-user',
  organizationId: 'platform-org',
  actorRole: 'system_internal',
  requestId: 'request-cs034',
  traceId: 'trace-cs034'
};

function loadDistModule(candidates) {
  for (const candidate of candidates) {
    try {
      return require(candidate);
    } catch (error) {
      if (error?.code !== 'MODULE_NOT_FOUND') {
        throw error;
      }
    }
  }
  throw new Error(`Unable to load any dist module from: ${candidates.join(', ')}`);
}

function makeService(options = {}) {
  const requests = [...(options.requests ?? [])];
  const results = [...(options.results ?? [])];
  const providerAdapter =
    options.providerAdapter ??
    {
      providerKey: 'mock_ai_review_provider',
      buildRequest: (input) => ({ ...input, providerMarker: 'mock-built' }),
      invoke: async () => ({
        decision: 'allow',
        riskScore: 0,
        riskLabels: []
      }),
      normalizeResponse: (rawResponse) => {
        if (!rawResponse || typeof rawResponse !== 'object' || Array.isArray(rawResponse)) {
          throw invalidProviderResponse();
        }
        const source = rawResponse;
        return {
          decision: source.decision,
          riskScore: Number(source.riskScore),
          riskLabels: Array.isArray(source.riskLabels) ? source.riskLabels : []
        };
      }
    };

  const requestRepository = {
    create: (value) => ({ ...value }),
    save: async (request) => {
      const index = requests.findIndex((item) => item.id === request.id);
      if (index >= 0) {
        requests[index] = request;
      } else {
        requests.push(request);
      }
      return request;
    }
  };
  const resultRepository = {
    create: (value) => ({ ...value }),
    save: async (result) => {
      const index = results.findIndex((item) => item.id === result.id);
      if (index >= 0) {
        results[index] = result;
      } else {
        results.push(result);
      }
      return result;
    }
  };
  const { AiReviewGatewayService } = loadDistModule([
    '../dist/modules/ai_review_gateway/ai-review-gateway.service.js',
    '../dist/src/modules/ai_review_gateway/ai-review-gateway.service.js',
    '../dist/apps/server/src/modules/ai_review_gateway/ai-review-gateway.service.js'
  ]);
  const { AiReviewGatewayRequestNormalizer } = loadDistModule([
    '../dist/modules/ai_review_gateway/ai-review-gateway.request-normalizer.js',
    '../dist/src/modules/ai_review_gateway/ai-review-gateway.request-normalizer.js',
    '../dist/apps/server/src/modules/ai_review_gateway/ai-review-gateway.request-normalizer.js'
  ]);
  const { AiReviewGatewayPresenter } = loadDistModule([
    '../dist/modules/ai_review_gateway/ai-review-gateway.presenter.js',
    '../dist/src/modules/ai_review_gateway/ai-review-gateway.presenter.js',
    '../dist/apps/server/src/modules/ai_review_gateway/ai-review-gateway.presenter.js'
  ]);
  return {
    requests,
    results,
    service: new AiReviewGatewayService(
      requestRepository,
      resultRepository,
      providerAdapter,
      new AiReviewGatewayRequestNormalizer(),
      new AiReviewGatewayPresenter()
    )
  };
}

function invalidProviderResponse() {
  const error = new Error('invalid provider response');
  error.getResponse = () => ({ code: 'AI_REVIEW_GATEWAY_PROVIDER_RESPONSE_INVALID' });
  return error;
}

test('CS-034 submit materializes normalized request/result truth and trace linkage', async () => {
  const { service, requests, results } = makeService({
    providerAdapter: {
      providerKey: 'mock_ai_review_provider',
      buildRequest: (input) => ({
        providerKey: input.providerKey,
        engineType: input.engineType,
        reviewObjectType: input.reviewObjectType,
        objectId: input.objectId,
        policyProfile: input.policyProfile,
        reviewPayload: input.reviewPayload,
        traceId: input.traceId,
        providerNormalized: true
      }),
      invoke: async () => ({
        decision: 'block',
        riskScore: '0.91',
        riskLabels: ['spam', 'policy']
      }),
      normalizeResponse: (rawResponse) => ({
        decision: rawResponse.decision,
        riskScore: Number(rawResponse.riskScore),
        riskLabels: [...rawResponse.riskLabels]
      })
    }
  });

  const response = await service.submit(
    {
      engineType: 'mock_engine',
      providerKey: 'mock_ai_review_provider',
      reviewObjectType: 'forum_comment',
      objectId: 'comment-1',
      policyProfile: 'forum_publish_text_v1',
      reviewPayload: {
        title: 'Hello',
        body: 'World'
      },
      traceId: 'trace-cs034-submit'
    },
    context
  );

  assert.equal(requests.length, 1);
  assert.equal(results.length, 1);
  assert.equal(requests[0].traceId, 'trace-cs034-submit');
  assert.match(requests[0].requestPayloadRef, /^ai_review_gateway_request_payload:/);
  assert.equal(results[0].status, 'completed');
  assert.equal(results[0].decision, 'block');
  assert.equal(results[0].riskScore, 0.91);
  assert.deepEqual(results[0].riskLabels, ['spam', 'policy']);
  assert.match(results[0].providerResponseRef, /^ai_review_gateway_provider_response:/);
  assert.deepEqual(response, {
    requestId: requests[0].id,
    resultId: results[0].id,
    engineType: 'mock_engine',
    providerKey: 'mock_ai_review_provider',
    reviewObjectType: 'forum_comment',
    objectId: 'comment-1',
    policyProfile: 'forum_publish_text_v1',
    requestPayloadRef: requests[0].requestPayloadRef,
    providerResponseRef: results[0].providerResponseRef,
    traceId: 'trace-cs034-submit',
    decision: 'block',
    riskScore: 0.91,
    riskLabels: ['spam', 'policy'],
    status: 'completed'
  });
});

test('CS-034 submit marks failed result truth when provider invocation fails', async () => {
  const { service, requests, results } = makeService({
    providerAdapter: {
      providerKey: 'mock_ai_review_provider',
      buildRequest: () => ({ built: true }),
      invoke: async () => {
        throw new Error('vendor unavailable');
      },
      normalizeResponse: () => ({
        decision: 'allow',
        riskScore: 0,
        riskLabels: []
      })
    }
  });

  await assert.rejects(
    () =>
      service.submit(
        {
          engineType: 'mock_engine',
          providerKey: 'mock_ai_review_provider',
          reviewObjectType: 'forum_post',
          objectId: 'post-1',
          policyProfile: 'forum_publish_text_v1',
          reviewPayload: { body: 'test' },
          traceId: 'trace-cs034-failed'
        },
        context
      ),
    (error) => error?.getResponse?.().code === 'AI_REVIEW_GATEWAY_PROVIDER_UNAVAILABLE'
  );

  assert.equal(requests.length, 1);
  assert.equal(results.length, 1);
  assert.equal(results[0].status, 'failed');
  assert.equal(results[0].decision, 'block');
  assert.equal(results[0].riskScore, 1);
  assert.deepEqual(results[0].riskLabels, ['provider_error']);
});

test('CS-034 submit rejects malformed payloads and unsupported providers', async () => {
  const { service } = makeService();

  await assert.rejects(
    () =>
      service.submit(
        {
          engineType: 'mock_engine',
          providerKey: 'other_provider',
          reviewObjectType: 'forum_post',
          objectId: 'post-1',
          policyProfile: 'forum_publish_text_v1',
          reviewPayload: { body: 'test' },
          traceId: 'trace-cs034-invalid-provider'
        },
        context
      ),
    (error) => error?.getResponse?.().code === 'AI_REVIEW_GATEWAY_PROVIDER_UNAVAILABLE'
  );

  await assert.rejects(
    () =>
      service.submit(
        {
          engineType: 'mock_engine',
          providerKey: 'mock_ai_review_provider',
          reviewObjectType: 'forum_post',
          objectId: 'post-1',
          policyProfile: 'forum_publish_text_v1',
          reviewPayload: 'not-an-object'
        },
        context
      ),
    (error) => error?.getResponse?.().code === 'AI_REVIEW_GATEWAY_REQUEST_INVALID'
  );
});

test('CS-034 migration registry includes ai_review_gateway bounded truth', () => {
  const { aiReviewGatewayP1AMigrations, serverMigrations } = loadDistModule([
    '../dist/src/core/migrations/migrations.js',
    '../dist/apps/server/src/core/migrations/migrations.js',
    '../dist/core/migrations/migrations.js'
  ]);
  const migration = aiReviewGatewayP1AMigrations.find((item) => item.key === '20260408_ai_review_gateway_p1a_truth');

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  const joined = migration.statements.join('\n');
  assert.match(joined, /CREATE TABLE IF NOT EXISTS ai_review_gateway_requests/);
  assert.match(joined, /CREATE TABLE IF NOT EXISTS ai_review_gateway_results/);
  assert.match(joined, /CHECK \(status IN \('queued', 'processing', 'completed', 'failed'\)\)/);
  assert.doesNotMatch(joined, /\/api\/app\//);
  assert.doesNotMatch(joined, /\/server\/admin\//);
});
