/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

const client = require('../test-dist/core/server/admin-api-client.js');

test.afterEach(() => {
  client.setAdminApiRuntimeForTest(null);
});

test('governance penalty admin client keeps penalty writes on Server Admin API', async () => {
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

  await client.applyGovernancePenalty({
    subjectType: 'organization',
    subjectId: 'organization-1',
    penaltyType: 'warning',
    reasonCode: 'manual_review_violation',
    reasonSummary: 'bounded governance penalty',
  });

  assert.equal(calls.length, 1);
  assert.equal(calls[0].url, 'http://server.test/server/admin/governance/penalties');
  assert.equal(calls[0].options.method, 'POST');
  assert.equal(calls[0].options.headers.authorization, 'Bearer opaque-access-carrier');
  assert.deepEqual(JSON.parse(calls[0].options.body), {
    subjectType: 'organization',
    subjectId: 'organization-1',
    penaltyType: 'warning',
    reasonCode: 'manual_review_violation',
    reasonSummary: 'bounded governance penalty',
  });
});
