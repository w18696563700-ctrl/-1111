const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  FileService,
} = require('../dist/apps/bff/src/routes/file/file.service.js');

function createService({ onPost } = {}) {
  const calls = {
    authForward: 0,
    forumCommand: 0,
  };
  const service = new FileService(
    {
      async post(path, payload, options) {
        return onPost(path, payload, options);
      },
    },
    {
      buildForwardHeaders() {
        calls.authForward += 1;
        return {
          authorization: 'Bearer forwarded',
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
    {
      async buildCommandHeaders() {
        calls.forumCommand += 1;
        return {
          authorization: 'Bearer smoke',
          'x-actor-id': 'actor-1',
          'x-organization-id': 'org-1',
        };
      },
    },
  );
  return { service, calls };
}

test('enterprise_display upload init uses command headers so organization scope is forwarded', async () => {
  let captured = null;
  const { service, calls } = createService({
    async onPost(path, payload, options) {
      captured = { path, payload, options };
      return {
        uploadSessionId: 'session-1',
        directUpload: {
          url: 'https://oss.example.com/upload',
          method: 'PUT',
          headers: {},
        },
      };
    },
  });

  const result = await service.initUpload(
    {
      businessType: 'enterprise_display',
      businessId: 'enterprise-1',
      fileKind: 'enterprise_case_media',
      mimeType: 'image/png',
      size: 1024,
      checksum: 'abc123',
    },
    {},
  );

  assert.equal(calls.forumCommand, 1);
  assert.equal(calls.authForward, 0);
  assert.equal(captured.path, '/server/uploads/init');
  assert.equal(captured.options.headers['x-organization-id'], 'org-1');
  assert.equal(result.uploadSessionId, 'session-1');
});
