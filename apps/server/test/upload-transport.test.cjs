const test = require('node:test');
const assert = require('node:assert/strict');

function withEnv(patch, run) {
  const previous = new Map();
  for (const [key, value] of Object.entries(patch)) {
    previous.set(key, process.env[key]);
    process.env[key] = value;
  }
  return Promise.resolve()
    .then(run)
    .finally(() => {
      for (const [key, value] of previous.entries()) {
        if (value === undefined) {
          delete process.env[key];
          continue;
        }
        process.env[key] = value;
      }
    });
}

function readSignedHeaders(url) {
  const parsed = new URL(url);
  const signedHeaders = parsed.searchParams.get('X-Amz-SignedHeaders');
  assert.ok(signedHeaders, 'expected X-Amz-SignedHeaders in presigned URL');
  return signedHeaders.split(';').map((header) => header.trim()).filter(Boolean).sort();
}

test('upload storage service keeps returned headers aligned with presigned PUT contract', async () => {
  await withEnv(
    {
      UPLOAD_BUCKET: 'exhibition-uploads',
      UPLOAD_S3_ENDPOINT: 'http://127.0.0.1:9000',
      UPLOAD_S3_PUBLIC_ENDPOINT: 'http://47.108.180.198:9000',
      UPLOAD_S3_REGION: 'us-east-1',
      UPLOAD_S3_ACCESS_KEY_ID: 'minioadmin',
      UPLOAD_S3_SECRET_ACCESS_KEY: 'minioadmin',
      UPLOAD_S3_FORCE_PATH_STYLE: 'true',
      UPLOAD_SIGNED_URL_EXPIRES_SECONDS: '900',
    },
    async () => {
      const { RuntimeConfigService } = require('../dist/core/runtime-config.service.js');
      const { UploadStorageService } = require('../dist/modules/upload/upload-storage.service.js');

      const config = new RuntimeConfigService();
      const service = new UploadStorageService(config);
      const directive = await service.buildDirective({
        sessionId: 'session-1',
        businessType: 'project',
        fileKind: 'evidence',
        mimeType: 'application/pdf',
        checksum: 'abc123',
      });

      const parsed = new URL(directive.directUploadUrl);
      const signedHeaders = readSignedHeaders(directive.directUploadUrl);
      const returnedHeaderNames = Object.keys(directive.directUploadHeaders)
        .map((header) => header.toLowerCase())
        .sort();

      assert.equal(parsed.host, '47.108.180.198:9000');
      assert.equal(directive.directUploadMethod, 'PUT');
      assert.match(directive.directUploadUrl, /X-Amz-Signature=/);
      assert.deepEqual(signedHeaders, [
        'content-type',
        'host',
        'x-amz-meta-business-type',
        'x-amz-meta-checksum-sha256',
        'x-amz-meta-file-kind',
        'x-amz-meta-upload-session-id',
      ]);
      assert.deepEqual(returnedHeaderNames, [
        'content-type',
        'x-amz-meta-business-type',
        'x-amz-meta-checksum-sha256',
        'x-amz-meta-file-kind',
        'x-amz-meta-upload-session-id',
      ]);
      assert.equal(parsed.searchParams.has('x-amz-meta-business-type'), false);
      assert.equal(parsed.searchParams.has('x-amz-meta-checksum-sha256'), false);
      assert.equal(parsed.searchParams.has('x-amz-meta-file-kind'), false);
      assert.equal(parsed.searchParams.has('x-amz-meta-upload-session-id'), false);
      assert.equal(directive.directUploadHeaders['Content-Type'], 'application/pdf');
      assert.equal(directive.directUploadHeaders['x-amz-meta-upload-session-id'], 'session-1');
      assert.equal(directive.directUploadHeaders['x-amz-meta-checksum-sha256'], 'abc123');
    }
  );
});

test('upload storage service rejects loopback public endpoint', async () => {
  await withEnv(
    {
      UPLOAD_BUCKET: 'exhibition-uploads',
      UPLOAD_S3_ENDPOINT: 'http://127.0.0.1:9000',
      UPLOAD_S3_PUBLIC_ENDPOINT: 'http://127.0.0.1:9000',
      UPLOAD_S3_REGION: 'us-east-1',
      UPLOAD_S3_ACCESS_KEY_ID: 'minioadmin',
      UPLOAD_S3_SECRET_ACCESS_KEY: 'minioadmin',
      UPLOAD_S3_FORCE_PATH_STYLE: 'true',
    },
    async () => {
      const { RuntimeConfigService } = require('../dist/core/runtime-config.service.js');
      const { UploadStorageService } = require('../dist/modules/upload/upload-storage.service.js');

      const config = new RuntimeConfigService();
      const service = new UploadStorageService(config);

      await assert.rejects(
        () =>
          service.buildDirective({
            sessionId: 'session-2',
            businessType: 'project',
            fileKind: 'evidence',
            mimeType: 'application/pdf',
            checksum: 'abc123',
          }),
        (error) => error?.message === 'Upload public endpoint must not use loopback host.'
      );
    }
  );
});

test('confirm upload fails without transport truth and does not create FileAsset', async () => {
  const { UploadWriteService } = require('../dist/modules/upload/upload-write.service.js');
  const { uploadSessionMissingFileAssetTruth } = require('../dist/modules/upload/upload.errors.js');

  let fileAssetSaved = false;
  let sessionSaved = false;
  let auditRecorded = false;

  const session = {
    id: 'session-3',
    businessType: 'project',
    businessId: 'project-1',
    fileKind: 'evidence',
    objectKey: 'project/evidence/2026/04/file.pdf',
    mimeType: 'application/pdf',
    size: 25,
    checksum: 'abc123',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'org-1',
    fileAssetId: null,
  };

  const uploadSessionRepository = {
    create: (value) => value,
    findOneBy: async () => session,
    save: async () => {
      sessionSaved = true;
    },
  };
  const fileAssetRepository = {
    create: (value) => value,
    findOneBy: async () => null,
    save: async () => {
      fileAssetSaved = true;
    },
  };
  const projectRepository = {
    findOneBy: async () => ({ id: 'project-1' }),
  };
  const manager = {
    getRepository(entity) {
      if (entity.name === 'UploadSessionEntity') return uploadSessionRepository;
      if (entity.name === 'FileAssetEntity') return fileAssetRepository;
      if (entity.name === 'ProjectEntity') return projectRepository;
      throw new Error(`Unexpected repository request: ${entity.name}`);
    },
  };
  const dataSource = {
    transaction: async (run) => run(manager),
  };
  const presenter = {
    toConfirmResponse: (fileAsset) => ({ fileAssetId: fileAsset.id }),
  };
  const storageService = {
    buildDirective: async () => {
      throw new Error('not used');
    },
    verifyTransportObject: async () => {
      throw uploadSessionMissingFileAssetTruth('Upload transport object does not exist for upload confirm.');
    },
  };
  const auditService = {
    record: async () => {
      auditRecorded = true;
    },
  };

  const service = new UploadWriteService(
    uploadSessionRepository,
    fileAssetRepository,
    projectRepository,
    dataSource,
    presenter,
    storageService,
    auditService
  );

  await assert.rejects(
    () =>
      service.confirmUpload(
        { uploadSessionId: 'session-3' },
        {
          actorId: 'actor-1',
          userId: 'user-1',
          organizationId: 'org-1',
          actorRole: 'member',
          requestId: 'request-1',
          traceId: 'trace-1',
        }
      ),
    (error) => typeof error?.getStatus === 'function' && error.getStatus() === 409
  );

  assert.equal(fileAssetSaved, false);
  assert.equal(sessionSaved, false);
  assert.equal(auditRecorded, false);
});
