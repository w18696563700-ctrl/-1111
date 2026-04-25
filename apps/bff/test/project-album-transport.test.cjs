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

const { AppProjectAlbumController } = require('../src/routes/project/app-project-album.controller.ts');
const { ProjectAlbumService } = require('../src/routes/project/project-album.service.ts');
const { ErrorNormalizerService } = require('../src/core/errors/error-normalizer.service.ts');

const photoPayload = {
  photoId: 'photo-1',
  projectId: 'project-1',
  fileAssetId: 'file-1',
  category: 'progress',
  caption: '现场进度',
  mimeType: 'image/jpeg',
  sortOrder: 0,
  photoState: 'active',
  uploadedByUserId: 'user-1',
  uploadedByActorId: null,
  uploadedByOrganizationId: 'org-1',
  createdAt: '2026-05-09T10:00:00.000Z',
  removedAt: null,
};

test('project album app-facing routes are materialized', async () => {
  const calls = [];
  const service = {
    listPhotos(projectId) {
      calls.push(`list:${projectId}`);
      return {
        projectId,
        limit: 50,
        photoCount: 1,
        items: [{ ...photoPayload, projectId }],
      };
    },
    bindPhoto(projectId, payload) {
      calls.push(`bind:${projectId}:${payload.fileAssetId}:${payload.category}`);
      return { ...photoPayload, projectId, fileAssetId: payload.fileAssetId, category: payload.category };
    },
    removePhoto(projectId, photoId) {
      calls.push(`remove:${projectId}:${photoId}`);
      return { ...photoPayload, projectId, photoId, photoState: 'removed' };
    },
  };

  class TestModule {}
  Module({
    controllers: [AppProjectAlbumController],
    providers: [{ provide: ProjectAlbumService, useValue: service }],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, '127.0.0.1');

  try {
    const url = await app.getUrl();
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, AppProjectAlbumController),
      'api/app/project/:projectId/album/photos',
    );
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, AppProjectAlbumController.prototype.listPhotos),
      RequestMethod.GET,
    );
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, AppProjectAlbumController.prototype.bindPhoto),
      RequestMethod.POST,
    );
    assert.equal(
      Reflect.getMetadata(METHOD_METADATA, AppProjectAlbumController.prototype.removePhoto),
      RequestMethod.DELETE,
    );

    const listResponse = await fetch(`${url}/api/app/project/project-1/album/photos`);
    assert.equal(listResponse.status, 200);
    assert.equal((await listResponse.json()).photoCount, 1);

    const bindResponse = await fetch(`${url}/api/app/project/project-1/album/photos`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ fileAssetId: 'file-2', category: 'contract' }),
    });
    assert.equal(bindResponse.status, 202);
    assert.equal((await bindResponse.json()).fileAssetId, 'file-2');

    const deleteResponse = await fetch(`${url}/api/app/project/project-1/album/photos/photo-1`, {
      method: 'DELETE',
    });
    assert.equal(deleteResponse.status, 202);
    assert.equal((await deleteResponse.json()).photoState, 'removed');
  } finally {
    await app.close();
  }

  assert.deepEqual(calls, [
    'list:project-1',
    'bind:project-1:file-2:contract',
    'remove:project-1:photo-1',
  ]);
});

test('project album service forwards to server truth paths', async () => {
  const calls = [];
  const service = new ProjectAlbumService(
    {
      async get(pathName) {
        calls.push(`GET ${pathName}`);
        return {
          projectId: 'project-1',
          limit: 50,
          photoCount: 1,
          items: [photoPayload],
        };
      },
      async post(pathName, payload) {
        calls.push(`POST ${pathName} ${payload.fileAssetId}:${payload.category}`);
        return { ...photoPayload, fileAssetId: payload.fileAssetId, category: payload.category };
      },
      async delete(pathName) {
        calls.push(`DELETE ${pathName}`);
        return { ...photoPayload, photoState: 'removed' };
      },
    },
    {
      buildForwardHeaders(headers) {
        return headers;
      },
    },
    new ErrorNormalizerService(),
  );

  assert.equal((await service.listPhotos('project-1', {})).photoCount, 1);
  assert.equal(
    (await service.bindPhoto('project-1', { fileAssetId: 'file-2', category: 'defect' }, {})).category,
    'defect',
  );
  assert.equal((await service.removePhoto('project-1', 'photo-1', {})).photoState, 'removed');

  assert.deepEqual(calls, [
    'GET /server/projects/project-1/album/photos',
    'POST /server/projects/project-1/album/photos file-2:defect',
    'DELETE /server/projects/project-1/album/photos/photo-1',
  ]);
});
