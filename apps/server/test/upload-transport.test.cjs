const test = require('node:test');
const assert = require('node:assert/strict');

function createRequestContext() {
  return {
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'org-1',
    actorRole: 'buyer_admin',
    requestId: 'request-1',
    traceId: 'trace-1',
  };
}

function createUploadWriteHarness(overrides = {}) {
  const state = {
    projectId: overrides.projectId ?? 'project-1',
    session: overrides.session ?? null,
    fileAsset: overrides.fileAsset ?? null,
    savedSessions: [],
    savedFileAssets: [],
    auditEvents: [],
    verificationCalls: [],
  };

  const uploadSessionRepository = {
    create: (value) => ({ ...value }),
    async findOneBy(where) {
      if (!state.session) {
        return null;
      }
      if (where?.id && state.session.id !== where.id) {
        return null;
      }
      return state.session;
    },
    async save(value) {
      state.session = { ...value };
      state.savedSessions.push({ ...value });
      return value;
    },
  };

  const fileAssetRepository = {
    create: (value) => ({ ...value }),
    async findOneBy(where) {
      if (!state.fileAsset) {
        return null;
      }
      if (where?.id && state.fileAsset.id !== where.id) {
        return null;
      }
      return state.fileAsset;
    },
    async save(value) {
      state.fileAsset = { ...value };
      state.savedFileAssets.push({ ...value });
      return value;
    },
  };

  const projectRepository = {
    async findOneBy(where) {
      if (where?.id !== state.projectId) {
        return null;
      }
      return { id: state.projectId };
    },
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
    toInitResponse: (session) => ({
      uploadSessionId: session.id,
      businessType: session.businessType,
      businessId: session.businessId,
      fileKind: session.fileKind,
    }),
    toConfirmResponse: (fileAsset) => ({
      fileAssetId: fileAsset.id,
      businessType: fileAsset.businessType,
      businessId: fileAsset.businessId,
      fileKind: fileAsset.fileKind,
    }),
  };

  const storageService = {
    buildDirective: async ({ fileKind }) => ({
      objectKey: `project/${fileKind}/2026/04/file.bin`,
      directUploadUrl: 'https://upload.example.com/object',
      directUploadMethod: 'PUT',
      directUploadHeaders: { 'Content-Type': 'application/octet-stream' },
    }),
    verifyTransportObject: async () => {},
    ...overrides.storageService,
  };

  const enterpriseDisplayBinding = {
    loadOwnedListingForInit: async () => null,
    loadOwnedListingForConfirm: async () => null,
    ensureFileAsset: () => {},
  };

  const auditService = {
    record: async (event) => {
      state.auditEvents.push(event);
    },
  };

  const currentSession =
    overrides.currentSession ?? {
      sessionId: 'verified-session-1',
      actorId: 'actor-1',
      userId: 'user-1',
      organizationId: 'org-1',
      requestId: 'request-1',
      traceId: 'trace-1',
    };
  const currentSessionVerificationService =
    overrides.currentSessionVerificationService ?? {
      verifyCurrentSessionContext: async (context) => {
        state.verificationCalls.push({ ...context });
        return {
          outcome: 'verified',
          currentSession,
        };
      },
    };

  const { UploadWriteService } = require('../dist/modules/upload/upload-write.service.js');

  return {
    state,
    service: new UploadWriteService(
      uploadSessionRepository,
      fileAssetRepository,
      projectRepository,
      dataSource,
      presenter,
      storageService,
      enterpriseDisplayBinding,
      auditService,
      currentSessionVerificationService,
    ),
  };
}

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
      UPLOAD_S3_PUBLIC_ENDPOINT: 'http://formal-cloud.test:9000',
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

      assert.equal(parsed.host, 'formal-cloud.test:9000');
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

test('upload storage service keeps spreadsheet object keys on canonical xls/xlsx extensions', async () => {
  await withEnv(
    {
      UPLOAD_BUCKET: 'exhibition-uploads',
      UPLOAD_S3_ENDPOINT: 'http://127.0.0.1:9000',
      UPLOAD_S3_PUBLIC_ENDPOINT: 'http://formal-cloud.test:9000',
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
      const cases = [
        {
          mimeType: 'application/vnd.ms-excel',
          expectedSuffix: '.xls',
        },
        {
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          expectedSuffix: '.xlsx',
        },
      ];

      for (const item of cases) {
        const directive = await service.buildDirective({
          sessionId: `session-${item.expectedSuffix}`,
          businessType: 'project',
          fileKind: 'bid_quote_sheet',
          mimeType: item.mimeType,
          checksum: 'abc123',
        });

        assert.match(directive.objectKey, new RegExp(`${item.expectedSuffix.replace('.', '\\.')}$`));
      }
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
  const enterpriseDisplayBinding = {
    loadOwnedListingForInit: async () => null,
    loadOwnedListingForConfirm: async () => null,
    ensureFileAsset: () => {},
  };
  const currentSessionVerificationService = {
    verifyCurrentSessionContext: async () => ({
      outcome: 'verified',
      currentSession: {
        sessionId: 'verified-session-1',
        actorId: 'actor-1',
        userId: 'user-1',
        organizationId: 'org-1',
        requestId: 'request-1',
        traceId: 'trace-1',
      },
    }),
  };

  const service = new UploadWriteService(
    uploadSessionRepository,
    fileAssetRepository,
    projectRepository,
    dataSource,
    presenter,
    storageService,
    enterpriseDisplayBinding,
    auditService,
    currentSessionVerificationService
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

test('upload init accepts project_attachment and keeps project binding truth', async () => {
  const { service, state } = createUploadWriteHarness();

  const response = await service.initUpload(
    {
      businessType: 'project',
      businessId: 'project-1',
      fileKind: 'project_attachment',
      mimeType: 'application/pdf',
      size: 128,
      checksum: 'checksum-project-attachment',
    },
    createRequestContext(),
  );

  assert.equal(response.businessType, 'project');
  assert.equal(response.businessId, 'project-1');
  assert.equal(response.fileKind, 'project_attachment');
  assert.equal(state.savedSessions.length, 1);
  assert.equal(state.savedSessions[0].fileKind, 'project_attachment');
});

test('upload init accepts project_album_photo images and rejects non-image truth', async () => {
  const { service, state } = createUploadWriteHarness();

  const response = await service.initUpload(
    {
      businessType: 'project',
      businessId: 'project-1',
      fileKind: 'project_album_photo',
      mimeType: 'image/jpeg',
      size: 128,
      checksum: 'checksum-project-album-photo',
    },
    createRequestContext(),
  );

  assert.equal(response.fileKind, 'project_album_photo');
  assert.equal(state.savedSessions.length, 1);
  assert.equal(state.savedSessions[0].mimeType, 'image/jpeg');
  await assert.rejects(
    () =>
      service.initUpload(
        {
          businessType: 'project',
          businessId: 'project-1',
          fileKind: 'project_album_photo',
          mimeType: 'application/pdf',
          size: 128,
          checksum: 'checksum-project-album-pdf',
        },
        createRequestContext(),
      ),
    (error) => error?.response?.code === 'FILE_UPLOAD_INIT_INVALID',
  );
});

test('upload init accepts forum draft media and keeps forum file truth', async () => {
  const { service, state } = createUploadWriteHarness();

  const response = await service.initUpload(
    {
      businessType: 'forum_draft_attachment',
      businessId: 'draft-1',
      fileKind: 'media',
      mimeType: 'image/jpeg',
      size: 128,
      checksum: 'checksum-forum-image',
    },
    createRequestContext(),
  );

  assert.equal(response.businessType, 'forum_draft_attachment');
  assert.equal(response.businessId, 'draft-1');
  assert.equal(response.fileKind, 'media');
  assert.equal(state.savedSessions.length, 1);
  assert.equal(state.savedSessions[0].businessType, 'forum_draft_attachment');
  assert.equal(state.savedSessions[0].fileKind, 'media');
});

test('upload init accepts forum draft document attachments and rejects unsafe media shape', async () => {
  const { service, state } = createUploadWriteHarness();

  const response = await service.initUpload(
    {
      businessType: 'forum_draft_attachment',
      businessId: 'draft-1',
      fileKind: '现场交付清单.pdf',
      mimeType: 'application/pdf',
      size: 1024,
      checksum: 'checksum-forum-pdf',
    },
    createRequestContext(),
  );

  assert.equal(response.businessType, 'forum_draft_attachment');
  assert.equal(response.fileKind, '现场交付清单.pdf');
  assert.equal(state.savedSessions.length, 1);

  await assert.rejects(
    () =>
      service.initUpload(
        {
          businessType: 'forum_draft_attachment',
          businessId: 'draft-1',
          fileKind: 'media',
          mimeType: 'application/pdf',
          size: 1024,
          checksum: 'checksum-forum-media-pdf',
        },
        createRequestContext(),
      ),
    (error) => error?.response?.code === 'FILE_UPLOAD_INIT_INVALID',
  );

  await assert.rejects(
    () =>
      service.initUpload(
        {
          businessType: 'forum_draft_attachment',
          businessId: 'draft-1',
          fileKind: 'huge.pdf',
          mimeType: 'application/pdf',
          size: 21 * 1024 * 1024,
          checksum: 'checksum-forum-huge-pdf',
        },
        createRequestContext(),
      ),
    (error) => error?.response?.code === 'FILE_UPLOAD_INIT_INVALID',
  );
});

test('upload init stores verified current session truth for project uploads', async () => {
  const { service, state } = createUploadWriteHarness({
    currentSession: {
      sessionId: 'verified-session-project-init',
      actorId: 'actor-project-init',
      userId: 'user-project-init',
      organizationId: 'org-project-init',
      requestId: 'request-1',
      traceId: 'trace-1',
    },
  });

  await service.initUpload(
    {
      businessType: 'project',
      businessId: 'project-1',
      fileKind: 'bid_quote_sheet',
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      size: 256,
      checksum: 'checksum-project-session-stamp',
    },
    {
      ...createRequestContext(),
      actorId: '',
      userId: '',
      organizationId: '',
    },
  );

  assert.equal(state.verificationCalls.length, 1);
  assert.equal(state.savedSessions[0].actorId, 'actor-project-init');
  assert.equal(state.savedSessions[0].userId, 'user-project-init');
  assert.equal(state.savedSessions[0].organizationId, 'org-project-init');
});

test('upload init accepts bid submit required attachment file kinds', async () => {
  const cases = [
    {
      fileKind: 'bid_project_understanding',
      mimeType: 'application/pdf',
    },
    {
      fileKind: 'bid_project_understanding',
      mimeType: 'image/png',
    },
    {
      fileKind: 'bid_quote_sheet',
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    },
    {
      fileKind: 'bid_schedule_plan',
      mimeType: 'application/vnd.ms-excel',
    },
  ];

  for (const item of cases) {
    const { service, state } = createUploadWriteHarness();

    const response = await service.initUpload(
      {
        businessType: 'project',
        businessId: 'project-1',
        fileKind: item.fileKind,
        mimeType: item.mimeType,
        size: 128,
        checksum: `checksum-${item.fileKind}`,
      },
      createRequestContext(),
    );

    assert.equal(response.businessType, 'project');
    assert.equal(response.businessId, 'project-1');
    assert.equal(response.fileKind, item.fileKind);
    assert.equal(state.savedSessions.length, 1);
    assert.equal(state.savedSessions[0].fileKind, item.fileKind);
  }
});

test('upload init rejects spreadsheet as project understanding attachment', async () => {
  const { service } = createUploadWriteHarness();

  await assert.rejects(
    () =>
      service.initUpload(
        {
          businessType: 'project',
          businessId: 'project-1',
          fileKind: 'bid_project_understanding',
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          size: 128,
          checksum: 'checksum-project-understanding-xlsx',
        },
        createRequestContext(),
      ),
    (error) =>
      typeof error?.getStatus === 'function' &&
      error.getStatus() === 400 &&
      error.getResponse()?.code === 'FILE_UPLOAD_INIT_INVALID'
  );
});

test('upload init keeps legacy project evidence binding compatible', async () => {
  const { service, state } = createUploadWriteHarness();

  const response = await service.initUpload(
    {
      businessType: 'project',
      businessId: 'project-1',
      fileKind: 'evidence',
      mimeType: 'application/pdf',
      size: 64,
      checksum: 'checksum-project-evidence',
    },
    createRequestContext(),
  );

  assert.equal(response.fileKind, 'evidence');
  assert.equal(state.savedSessions.length, 1);
  assert.equal(state.savedSessions[0].fileKind, 'evidence');
});

test('confirm upload keeps project_attachment in FileAsset truth for post-publish corridor', async () => {
  const { service, state } = createUploadWriteHarness({
    session: {
      id: 'session-project-attachment',
      businessType: 'project',
      businessId: 'project-1',
      fileKind: 'project_attachment',
      objectKey: 'project/project_attachment/2026/04/file.pdf',
      mimeType: 'application/pdf',
      size: 256,
      checksum: 'checksum-confirm-project-attachment',
      actorId: 'actor-1',
      userId: 'user-1',
      organizationId: 'org-1',
      fileAssetId: null,
      directUploadUrl: 'https://upload.example.com/object',
      directUploadMethod: 'PUT',
      directUploadHeaders: {},
      sessionStatus: 'initiated',
      confirmedAt: null,
    },
  });

  const response = await service.confirmUpload(
    { uploadSessionId: 'session-project-attachment' },
    createRequestContext(),
  );

  assert.equal(response.fileKind, 'project_attachment');
  assert.equal(state.savedFileAssets.length, 1);
  assert.equal(state.savedFileAssets[0].fileKind, 'project_attachment');
  assert.equal(state.savedFileAssets[0].businessType, 'project');
  assert.equal(state.savedFileAssets[0].businessId, 'project-1');
});

test('confirm upload backfills project file truth from verified current session', async () => {
  const { service, state } = createUploadWriteHarness({
    currentSession: {
      sessionId: 'verified-session-project-confirm',
      actorId: 'actor-project-confirm',
      userId: 'user-project-confirm',
      organizationId: 'org-project-confirm',
      requestId: 'request-1',
      traceId: 'trace-1',
    },
    session: {
      id: 'session-project-confirm',
      businessType: 'project',
      businessId: 'project-1',
      fileKind: 'bid_schedule_plan',
      objectKey: 'project/bid_schedule_plan/2026/04/file.pdf',
      mimeType: 'application/pdf',
      size: 64,
      checksum: 'checksum-project-confirm',
      actorId: null,
      userId: null,
      organizationId: '',
      fileAssetId: null,
      directUploadUrl: 'https://upload.example.com/object',
      directUploadMethod: 'PUT',
      directUploadHeaders: {},
      sessionStatus: 'initiated',
      confirmedAt: null,
    },
  });

  await service.confirmUpload(
    { uploadSessionId: 'session-project-confirm' },
    {
      ...createRequestContext(),
      actorId: '',
      userId: '',
      organizationId: '',
    },
  );

  assert.equal(state.verificationCalls.length, 1);
  const savedSession = state.savedSessions[state.savedSessions.length - 1];
  assert.equal(savedSession.actorId, 'actor-project-confirm');
  assert.equal(savedSession.userId, 'user-project-confirm');
  assert.equal(savedSession.organizationId, 'org-project-confirm');
  assert.equal(state.savedFileAssets[0].actorId, 'actor-project-confirm');
  assert.equal(state.savedFileAssets[0].userId, 'user-project-confirm');
  assert.equal(state.savedFileAssets[0].organizationId, 'org-project-confirm');
});

test('confirm upload rejects project session ownership drift across users', async () => {
  const { service } = createUploadWriteHarness({
    currentSession: {
      sessionId: 'verified-session-project-owner',
      actorId: 'actor-project-owner',
      userId: 'user-project-owner',
      organizationId: 'org-project-owner',
      requestId: 'request-1',
      traceId: 'trace-1',
    },
    session: {
      id: 'session-project-owner-mismatch',
      businessType: 'project',
      businessId: 'project-1',
      fileKind: 'project_attachment',
      objectKey: 'project/project_attachment/2026/04/file.pdf',
      mimeType: 'application/pdf',
      size: 128,
      checksum: 'checksum-project-owner-mismatch',
      actorId: 'another-actor',
      userId: 'another-user',
      organizationId: 'org-project-owner',
      fileAssetId: null,
      directUploadUrl: 'https://upload.example.com/object',
      directUploadMethod: 'PUT',
      directUploadHeaders: {},
      sessionStatus: 'initiated',
      confirmedAt: null,
    },
  });

  await assert.rejects(
    () => service.confirmUpload({ uploadSessionId: 'session-project-owner-mismatch' }, createRequestContext()),
    (error) =>
      typeof error?.getStatus === 'function' &&
      error.getStatus() === 409 &&
      error.getResponse()?.code === 'FILE_UPLOAD_CONFIRM_REQUIRED'
  );
});
