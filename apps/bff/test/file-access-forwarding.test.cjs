const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  FileService,
} = require('../dist/apps/bff/src/routes/file/file.service.js');
const {
  MyProjectAttachmentService,
} = require('../dist/apps/bff/src/routes/my_project/my-project-attachment.service.js');

function createService({ onGet }) {
  const calls = {
    commandHeaders: 0,
  };
  const service = new FileService(
    {
      async get(path, options) {
        return onGet(path, options);
      },
      async post() {
        throw new Error('file/access smoke must not call upload endpoints');
      },
    },
    {
      buildForwardHeaders() {
        throw new Error('file/access smoke must not use generic upload forwarding');
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
        calls.commandHeaders += 1;
        return {
          authorization: 'Bearer owner',
          'x-actor-id': 'actor-owner-1',
          'x-organization-id': 'org-owner-1',
        };
      },
    },
  );
  return { service, calls };
}

test('file/access forwards to Server and only shapes the returned access payload', async () => {
  let captured = null;
  const { service, calls } = createService({
    async onGet(path, options) {
      captured = { path, options };
      return {
        fileAssetId: 'file-asset-1',
        mode: 'preview',
        accessUrl: 'https://signed.example.test/project/project_attachment/a.png',
        fileName: '效果图.png',
        mimeType: 'image/png',
        expiresAt: '2026-04-27T10:00:00.000Z',
        contentLengthBytes: 2048,
        objectKey: 'project/project_attachment/a.png',
      };
    },
  });

  const result = await service.getAccess(
    { authorization: 'Bearer app' },
    'file-asset-1',
    'preview',
  );

  assert.equal(calls.commandHeaders, 1);
  assert.equal(captured.path, '/server/file/access');
  assert.deepEqual(captured.options.params, {
    fileAssetId: 'file-asset-1',
    mode: 'preview',
  });
  assert.equal(captured.options.headers['x-organization-id'], 'org-owner-1');
  assert.deepEqual(result, {
    fileAssetId: 'file-asset-1',
    mode: 'preview',
    accessUrl: 'https://signed.example.test/project/project_attachment/a.png',
    fileName: '效果图.png',
    mimeType: 'image/png',
    expiresAt: '2026-04-27T10:00:00.000Z',
    contentLengthBytes: 2048,
  });
  assert.ok(!Object.prototype.hasOwnProperty.call(result, 'objectKey'));
});

test('file/access download mode still delegates signing to Server', async () => {
  let captured = null;
  const { service, calls } = createService({
    async onGet(path, options) {
      captured = { path, options };
      return {
        fileAssetId: 'file-asset-pdf-1',
        mode: 'download',
        accessUrl: 'https://signed.example.test/project/project_attachment/spec.pdf',
        fileName: '施工说明.pdf',
        mimeType: 'application/pdf',
        expiresAt: '2026-04-27T10:15:00.000Z',
      };
    },
  });

  const result = await service.getAccess(
    { authorization: 'Bearer app' },
    'file-asset-pdf-1',
    'download',
  );

  assert.equal(calls.commandHeaders, 1);
  assert.equal(captured.path, '/server/file/access');
  assert.deepEqual(captured.options.params, {
    fileAssetId: 'file-asset-pdf-1',
    mode: 'download',
  });
  assert.deepEqual(result, {
    fileAssetId: 'file-asset-pdf-1',
    mode: 'download',
    accessUrl: 'https://signed.example.test/project/project_attachment/spec.pdf',
    fileName: '施工说明.pdf',
    mimeType: 'application/pdf',
    expiresAt: '2026-04-27T10:15:00.000Z',
  });
  assert.ok(!Object.prototype.hasOwnProperty.call(result, 'objectKey'));
});

test('my project attachment list keeps projectId + attachments[] contract shape', async () => {
  let captured = null;
  const service = new MyProjectAttachmentService(
    {
      async get(path, options) {
        captured = { path, options };
        return {
          projectId: 'project-owner-1',
          attachments: [
            {
              attachmentId: 'attachment-effect-1',
              projectId: 'project-owner-1',
              fileAssetId: 'file-asset-effect-1',
              fileName: '效果图.png',
              attachmentKind: 'effect_image',
              mimeType: 'image/png',
              visibility: 'owner_private',
              sortOrder: 0,
              createdAt: '2026-04-27T10:20:00.000Z',
              createdBy: 'actor-owner-1',
              objectKey: 'project/project_attachment/effect.png',
              accessUrl: 'https://signed.example.test/should-not-be-listed',
            },
          ],
        };
      },
    },
    {
      buildForwardHeaders(headers) {
        return {
          authorization: headers.authorization,
          'x-actor-id': 'actor-owner-1',
        };
      },
    },
    new ErrorNormalizerService(),
  );

  const result = await service.getAttachments('project-owner-1', {
    authorization: 'Bearer owner',
  });

  assert.equal(captured.path, '/server/projects/project-owner-1/attachments');
  assert.equal(captured.options.headers.authorization, 'Bearer owner');
  assert.deepEqual(result, {
    projectId: 'project-owner-1',
    attachments: [
      {
        attachmentId: 'attachment-effect-1',
        projectId: 'project-owner-1',
        fileAssetId: 'file-asset-effect-1',
        fileName: '效果图.png',
        attachmentKind: 'effect_image',
        mimeType: 'image/png',
        visibility: 'owner_private',
        sortOrder: 0,
        createdAt: '2026-04-27T10:20:00.000Z',
        createdBy: 'actor-owner-1',
      },
    ],
  });
  assert.ok(!Object.prototype.hasOwnProperty.call(result.attachments[0], 'objectKey'));
  assert.ok(!Object.prototype.hasOwnProperty.call(result.attachments[0], 'accessUrl'));
});
