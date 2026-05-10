/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

const client = require('../test-dist/core/server/admin-api-client.js');

test.afterEach(() => {
  client.setAdminApiRuntimeForTest(null);
});

test('governance appeal admin client keeps appeal decision on Server Admin API', async () => {
  const calls = [];
  client.setAdminApiRuntimeForTest(async () => ({
    fetchImpl: async (url, options) => {
      calls.push({ url, options });
      return new Response(JSON.stringify({ ok: true }), {
        status: 200,
        headers: { 'content-type': 'application/json' },
      });
    },
    serverAdminApiBaseUrl: 'http://server.test/server/admin',
    incomingHeaders: new Headers(),
    sessionCarrier: 'opaque-access-carrier',
  }));

  await client.decideGovernanceAppeal('appeal-1', {
    decision: 'uphold',
    decisionNote: 'appeal rejected by reviewer',
  });

  assert.equal(calls.length, 1);
  assert.equal(
    calls[0].url,
    'http://server.test/server/admin/governance/appeals/appeal-1/decide',
  );
  assert.equal(calls[0].options.method, 'POST');
  assert.equal(calls[0].options.headers.authorization, 'Bearer opaque-access-carrier');
  assert.deepEqual(JSON.parse(calls[0].options.body), {
    decision: 'uphold',
    decisionNote: 'appeal rejected by reviewer',
  });
});
