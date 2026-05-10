/* eslint-disable @typescript-eslint/no-require-imports */
const test = require('node:test');
const assert = require('node:assert/strict');

const client = require('../test-dist/core/server/admin-api-client.js');

test.afterEach(() => {
  client.setAdminApiRuntimeForTest(null);
});

test('admin review forum report decision stays bounded to Server Admin API', async () => {
  const calls = [];
  client.setAdminApiRuntimeForTest(async () => ({
    fetchImpl: async (url, options) => {
      calls.push({ url, options });
      return new Response(JSON.stringify({ ok: true, status: 'resolved' }), {
        status: 200,
        headers: { 'content-type': 'application/json' },
      });
    },
    serverAdminApiBaseUrl: 'http://server.test/server/admin',
    incomingHeaders: new Headers([['x-request-id', 'request-review']]),
    sessionCarrier: 'opaque-access-carrier',
  }));

  await client.decideForumReport('ticket-1', {
    decision: 'resolved',
    reason: 'confirmed report',
  });

  assert.equal(calls.length, 1);
  assert.equal(
    calls[0].url,
    'http://server.test/server/admin/content-safety/forum-reports/ticket-1/decide',
  );
  assert.equal(calls[0].options.method, 'POST');
  assert.equal(calls[0].options.headers.authorization, 'Bearer opaque-access-carrier');
  assert.equal(calls[0].options.headers['x-request-id'], 'request-review');
  assert.deepEqual(JSON.parse(calls[0].options.body), {
    decision: 'resolved',
    reason: 'confirmed report',
  });
});
