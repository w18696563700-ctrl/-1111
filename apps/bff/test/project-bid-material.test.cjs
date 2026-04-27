const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  ProjectBidMaterialService,
} = require('../dist/apps/bff/src/routes/project/project-bid-material.service.js');
const {
  MyProjectAttachmentService,
} = require('../dist/apps/bff/src/routes/my_project/my-project-attachment.service.js');

function createBidMaterialService(overrides = {}) {
  return new ProjectBidMaterialService(
    {
      async get() {
        throw new Error('get mock missing');
      },
      ...overrides.serverClient,
    },
    {
      buildPublicHeadersWithOptionalActorHints() {
        return { authorization: 'Bearer public' };
      },
    },
    new ErrorNormalizerService(),
  );
}

function createMyProjectAttachmentService(overrides = {}) {
  return new MyProjectAttachmentService(
    {
      async get() {
        throw new Error('get mock missing');
      },
      async post() {
        throw new Error('post mock missing');
      },
      async delete() {
        throw new Error('delete mock missing');
      },
      ...overrides.serverClient,
    },
    {
      buildForwardHeaders() {
        return { authorization: 'Bearer owner' };
      },
    },
    new ErrorNormalizerService(),
  );
}

function createAxiosError(status, code, message, details) {
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
        ...(details ? { details } : {}),
      },
    },
  };
}

test('project bid-material service forwards canonical read-only projection', async () => {
  const calls = [];
  const service = createBidMaterialService({
    serverClient: {
      async get(path, options) {
        calls.push([path, options]);
        return {
          projectId: 'project-1',
          attachments: [
            {
              attachmentId: 'attachment-1',
              projectId: 'project-1',
              fileAssetId: 'file-asset-1',
              fileName: '效果图.png',
              attachmentKind: 'effect_image',
              mimeType: 'image/png',
              sortOrder: 0,
              createdAt: '2026-04-16T09:30:00.000Z',
            },
            {
              attachmentId: 'attachment-2',
              projectId: 'project-1',
              fileAssetId: 'file-asset-2',
              fileName: '施工图.pdf',
              attachmentKind: 'construction_doc',
              mimeType: 'application/pdf',
              sortOrder: 1,
              createdAt: '2026-04-16T09:31:00.000Z',
            },
            {
              attachmentId: 'attachment-3',
              projectId: 'project-1',
              fileAssetId: 'file-asset-3',
              fileName: '材质图.pdf',
              attachmentKind: 'material_sample',
              mimeType: 'application/pdf',
              sortOrder: 2,
              createdAt: '2026-04-16T09:32:00.000Z',
            },
            {
              attachmentId: 'attachment-4',
              projectId: 'project-1',
              fileAssetId: 'file-asset-4',
              fileName: '设备物料清单.xlsx',
              attachmentKind: 'equipment_material_list',
              mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              sortOrder: 3,
              createdAt: '2026-04-16T09:33:00.000Z',
            },
            {
              attachmentId: 'attachment-5',
              projectId: 'project-1',
              fileAssetId: 'file-asset-5',
              fileName: '服务清单.csv',
              attachmentKind: 'service_list',
              mimeType: 'text/csv',
              sortOrder: 4,
              createdAt: '2026-04-16T09:34:00.000Z',
            },
          ],
        };
      },
    },
  });

  const result = await service.getBidMaterials('project-1', {});

  assert.equal(calls[0][0], '/server/projects/project-1/bid-materials');
  assert.equal(result.projectId, 'project-1');
  assert.deepEqual(
    result.attachments.map((item) => item.attachmentKind),
    [
      'effect_image',
      'construction_doc',
      'material_sample',
      'equipment_material_list',
      'service_list',
    ],
  );
});

test('project bid-material service rewrites 404 into stable Chinese message', async () => {
  const service = createBidMaterialService({
    serverClient: {
      async get() {
        throw createAxiosError(
          404,
          'AUTH_RESOURCE_UNAVAILABLE',
          'Current project is unavailable.',
        );
      },
    },
  });

  await assert.rejects(
    () => service.getBidMaterials('project-1', {}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.equal(error.getResponse().code, 'AUTH_RESOURCE_UNAVAILABLE');
      assert.equal(error.getResponse().message, '当前项目材料清单暂不可读，请稍后再试。');
      return true;
    },
  );
});

test('my-project attachment service keeps submitted-or-later invalid-state translation stable', async () => {
  const service = createMyProjectAttachmentService({
    serverClient: {
      async post() {
        throw createAxiosError(
          409,
          'PROJECT_INVALID_STATE',
          'Only submitted-or-later projects may enter the project attachment corridor.',
        );
      },
    },
  });

  await assert.rejects(
    () =>
      service.bindAttachment(
        'project-1',
        {
          fileAssetId: 'file-asset-1',
          fileName: '效果图.png',
          attachmentKind: 'effect_image',
        },
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 409);
      assert.equal(error.getResponse().code, 'PROJECT_INVALID_STATE');
      assert.equal(error.getResponse().message, '当前项目状态暂不支持补充资料。');
      return true;
    },
  );
});
