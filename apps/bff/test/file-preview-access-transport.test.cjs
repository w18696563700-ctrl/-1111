const test = require('node:test');
const assert = require('node:assert/strict');
const { METHOD_METADATA, PATH_METADATA } = require('@nestjs/common/constants');
const { RequestMethod } = require('@nestjs/common');

const { ErrorNormalizerService } = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const { AppFilePreviewController } = require('../dist/apps/bff/src/routes/file/app-file-preview.controller.js');
const { FilePreviewService } = require('../dist/apps/bff/src/routes/file/file-preview.service.js');

function createService(onGet) {
  return new FilePreviewService(
    { async get(path, options) { return onGet(path, options); } },
    {
      buildForwardHeaders(headers) {
        return { authorization: headers.authorization, 'x-actor-id': headers['x-actor-id'] ?? 'actor-1' };
      },
    },
    new ErrorNormalizerService(),
  );
}

test('file preview app route is materialized', () => {
  assert.equal(Reflect.getMetadata(PATH_METADATA, AppFilePreviewController), 'api/app/file');
  assert.equal(Reflect.getMetadata(PATH_METADATA, AppFilePreviewController.prototype.getPreviewAccess), 'preview/access');
  assert.equal(Reflect.getMetadata(METHOD_METADATA, AppFilePreviewController.prototype.getPreviewAccess), RequestMethod.GET);
});

test('file preview forwards project/thread/file anchors and strips objectKey', async () => {
  let captured = null;
  const service = createService(async (path, options) => {
    captured = { path, options };
    return {
      fileAssetId: 'asset-1',
      projectId: 'project-1',
      threadId: 'thread-1',
      previewType: 'pdf',
      canPreview: true,
      fileName: '方案.pdf',
      mimeType: 'application/pdf',
      accessUrl: 'https://signed.example/asset-1',
      expiresAt: '2026-05-01T08:10:00.000Z',
      contentLengthBytes: 2048,
      downloadAvailable: true,
      objectKey: 'must/not/leak.pdf',
    };
  });

  const result = await service.getPreviewAccess(
    { authorization: 'Bearer app', 'x-organization-id': 'org-1' },
    'project-1',
    'thread-1',
    'asset-1',
  );

  assert.equal(captured.path, '/server/file/preview/access');
  assert.deepEqual(captured.options.params, { projectId: 'project-1', threadId: 'thread-1', fileAssetId: 'asset-1' });
  assert.equal(captured.options.headers['x-organization-id'], 'org-1');
  assert.equal(result.previewType, 'pdf');
  assert.equal(result.accessUrl, 'https://signed.example/asset-1');
  assert.equal(Object.prototype.hasOwnProperty.call(result, 'objectKey'), false);
});
