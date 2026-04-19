const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId) {
  return {
    authorization: 'Bearer project-attachment-token',
    actorId: 'buyer-user',
    userId: 'buyer-user',
    organizationId: 'buyer-org',
    actorRole: 'buyer_admin',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

function createProject(overrides = {}) {
  return {
    id: 'project-1',
    projectNo: 'PROJ-ATT-2026-1',
    organizationId: 'buyer-org',
    creatorUserId: 'buyer-user',
    creatorActorId: 'buyer-user',
    title: '已发布项目',
    buildingType: 'exhibition',
    budgetAmount: '88888.00',
    description: null,
    state: 'published',
    summary: {},
    publishedAt: new Date('2026-04-13T08:00:00.000Z'),
    createdAt: new Date('2026-04-13T08:00:00.000Z'),
    updatedAt: new Date('2026-04-13T08:00:00.000Z'),
    ...overrides,
  };
}

function createFileAsset(overrides = {}) {
  return {
    id: 'asset-1',
    uploadSessionId: 'upload-1',
    businessType: 'project',
    businessId: 'project-1',
    fileKind: 'project_attachment',
    objectKey: 'object-1',
    mimeType: 'image/png',
    size: 2048,
    checksum: 'checksum-1',
    actorId: 'buyer-user',
    userId: 'buyer-user',
    organizationId: 'buyer-org',
    createdAt: new Date('2026-04-13T08:00:00.000Z'),
    ...overrides,
  };
}

function createAttachment(overrides = {}) {
  return {
    id: 'attachment-1',
    projectId: 'project-1',
    fileAssetId: 'asset-1',
    fileName: '效果图.png',
    attachmentKind: 'effect_image',
    mimeType: 'image/png',
    visibility: 'owner_private',
    sortOrder: 0,
    createdBy: 'buyer-user',
    createdAt: new Date('2026-04-13T08:00:00.000Z'),
    ...overrides,
  };
}

function createAttachmentHarness(overrides = {}) {
  const state = {
    project: createProject(overrides.project),
    fileAssets: structuredClone(overrides.fileAssets ?? [createFileAsset()]),
    attachments: structuredClone(overrides.attachments ?? []),
    auditLogs: structuredClone(overrides.auditLogs ?? []),
  };

  function getRepository(entity, draft) {
    if (entity?.name === 'ProjectEntity') {
      return {
        async findOneBy(where) {
          if (!draft.project) {
            return null;
          }
          if (where?.id && draft.project.id !== where.id) {
            return null;
          }
          return draft.project;
        },
      };
    }

    if (entity?.name === 'FileAssetEntity') {
      return {
        async findOneBy(where) {
          return (
            draft.fileAssets.find((item) => {
              if (where?.id && item.id !== where.id) {
                return false;
              }
              return true;
            }) ?? null
          );
        },
      };
    }

    if (entity?.name === 'ProjectAttachmentEntity') {
      return {
        create(input) {
          return {
            ...input,
            createdAt: input.createdAt ?? new Date('2026-04-13T09:00:00.000Z'),
          };
        },
        async find(options = {}) {
          const projectId = options?.where?.projectId ?? null;
          const attachmentKindFilter = options?.where?.attachmentKind ?? null;
          return draft.attachments
            .filter((item) => {
              if (projectId && item.projectId !== projectId) {
                return false;
              }
              if (!attachmentKindFilter) {
                return true;
              }
              if (attachmentKindFilter?._type === 'in') {
                return attachmentKindFilter._value.includes(item.attachmentKind);
              }
              if (Array.isArray(attachmentKindFilter)) {
                return attachmentKindFilter.includes(item.attachmentKind);
              }
              return item.attachmentKind === attachmentKindFilter;
            })
            .sort((left, right) => {
              if (left.sortOrder !== right.sortOrder) {
                return left.sortOrder - right.sortOrder;
              }
              return new Date(left.createdAt).getTime() - new Date(right.createdAt).getTime();
            });
        },
        async findOne(options = {}) {
          const items = await this.find(options);
          if (options?.order?.sortOrder === 'DESC') {
            return items.at(-1) ?? null;
          }
          return items[0] ?? null;
        },
        async findOneBy(where) {
          return (
            draft.attachments.find((item) => {
              if (where?.id && item.id !== where.id) {
                return false;
              }
              if (where?.projectId && item.projectId !== where.projectId) {
                return false;
              }
              if (where?.fileAssetId && item.fileAssetId !== where.fileAssetId) {
                return false;
              }
              return true;
            }) ?? null
          );
        },
        async save(value) {
          const existingIndex = draft.attachments.findIndex((item) => item.id === value.id);
          if (existingIndex >= 0) {
            draft.attachments[existingIndex] = value;
          } else {
            draft.attachments.push(value);
          }
          return value;
        },
        async delete(criteria) {
          draft.attachments = draft.attachments.filter((item) => item.id !== criteria.id);
          return { affected: 1 };
        },
      };
    }

    throw new Error(`unexpected repository ${entity?.name ?? 'unknown'}`);
  }

  return {
    state,
    dataSource: {
      async transaction(callback) {
        const draft = structuredClone(state);
        const manager = {
          __draft: draft,
          getRepository(entity) {
            return getRepository(entity, draft);
          },
        };
        const result = await callback(manager);
        Object.assign(state, draft);
        return result;
      },
    },
    repositories: {
      projectRepository: getRepository({ name: 'ProjectEntity' }, state),
      attachmentRepository: getRepository({ name: 'ProjectAttachmentEntity' }, state),
      fileAssetRepository: getRepository({ name: 'FileAssetEntity' }, state),
    },
    auditService: {
      async record(input, _context, manager) {
        const draft = manager?.__draft ?? state;
        draft.auditLogs.push(input);
      },
    },
  };
}

function createEligibilityService(overrides = {}) {
  return {
    async requireProjectPublishEligibilityFromContext() {
      return {
        currentSession: {
          sessionId: 'session-1',
          actorId: overrides.actorId ?? 'buyer-user',
          userId: overrides.userId ?? 'buyer-user',
          organizationId: overrides.organizationId ?? 'buyer-org',
          requestId: 'attachment-request',
          traceId: 'trace-attachment-request',
        },
        scope: {
          organization: { id: overrides.organizationId ?? 'buyer-org' },
          membership: { roleKey: overrides.roleKey ?? 'buyer_admin' },
          certification: { certificationStatus: 'approved' },
          roleKeys: [overrides.roleKey ?? 'buyer_admin'],
        },
      };
    },
    async getCurrentOrganizationScope(currentSession) {
      return {
        organization: { id: currentSession.organizationId },
        membership: { roleKey: 'buyer_admin' },
        certification: { certificationStatus: 'approved' },
        roleKeys: ['buyer_admin'],
      };
    },
  };
}

test('owner + published project bind success', async () => {
  const { ProjectAttachmentService } = require('../dist/modules/project/project-attachment.service.js');
  const { ProjectAttachmentPresenter } = require('../dist/modules/project/project-attachment.presenter.js');

  const harness = createAttachmentHarness({
    attachments: [createAttachment({ id: 'attachment-0', fileAssetId: 'asset-0', sortOrder: 0 })],
    fileAssets: [
      createFileAsset({ id: 'asset-0' }),
      createFileAsset({ id: 'asset-1', mimeType: 'image/webp' }),
    ],
  });
  const service = new ProjectAttachmentService(
    harness.repositories.projectRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.fileAssetRepository,
    harness.dataSource,
    harness.auditService,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService(),
    new ProjectAttachmentPresenter(),
  );

  const result = await service.bind(
    'project-1',
    {
      fileAssetId: 'asset-1',
      fileName: '补充效果图.webp',
      attachmentKind: 'effect_image',
    },
    createContext('attachment-bind-success'),
  );

  assert.equal(result.projectId, 'project-1');
  assert.equal(result.fileAssetId, 'asset-1');
  assert.equal(result.mimeType, 'image/webp');
  assert.equal(result.visibility, 'owner_private');
  assert.equal(result.sortOrder, 1);
  assert.equal(harness.state.attachments.length, 2);
  assert.equal(harness.state.attachments[1].createdBy, 'buyer-user');
});

test('non-owner bind forbidden', async () => {
  const { ProjectAttachmentService } = require('../dist/modules/project/project-attachment.service.js');
  const { ProjectAttachmentPresenter } = require('../dist/modules/project/project-attachment.presenter.js');

  const harness = createAttachmentHarness();
  const service = new ProjectAttachmentService(
    harness.repositories.projectRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.fileAssetRepository,
    harness.dataSource,
    harness.auditService,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService({ organizationId: 'supplier-org', roleKey: 'supplier_admin' }),
    new ProjectAttachmentPresenter(),
  );

  await assert.rejects(
    () =>
      service.bind(
        'project-1',
        {
          fileAssetId: 'asset-1',
          fileName: '补充效果图.png',
          attachmentKind: 'effect_image',
        },
        createContext('attachment-bind-non-owner'),
      ),
    (error) => error?.response?.code === 'AUTH_PERMISSION_INSUFFICIENT',
  );
});

test('unpublished project bind forbidden', async () => {
  const { ProjectAttachmentService } = require('../dist/modules/project/project-attachment.service.js');
  const { ProjectAttachmentPresenter } = require('../dist/modules/project/project-attachment.presenter.js');

  const harness = createAttachmentHarness({
    project: createProject({ publishedAt: null, state: 'draft' }),
  });
  const service = new ProjectAttachmentService(
    harness.repositories.projectRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.fileAssetRepository,
    harness.dataSource,
    harness.auditService,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService(),
    new ProjectAttachmentPresenter(),
  );

  await assert.rejects(
    () =>
      service.bind(
        'project-1',
        {
          fileAssetId: 'asset-1',
          fileName: '补充材料.png',
          attachmentKind: 'effect_image',
        },
        createContext('attachment-bind-unpublished'),
      ),
    (error) => error?.response?.code === 'PROJECT_INVALID_STATE',
  );
});

test('submitted project bind success before publish', async () => {
  const { ProjectAttachmentService } = require('../dist/modules/project/project-attachment.service.js');
  const { ProjectAttachmentPresenter } = require('../dist/modules/project/project-attachment.presenter.js');

  const harness = createAttachmentHarness({
    project: createProject({
      state: 'submitted',
      publishedAt: null,
      title: '预发布项目',
    }),
    fileAssets: [createFileAsset({ id: 'asset-submitted-1', mimeType: 'application/pdf' })],
  });
  const service = new ProjectAttachmentService(
    harness.repositories.projectRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.fileAssetRepository,
    harness.dataSource,
    harness.auditService,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService(),
    new ProjectAttachmentPresenter(),
  );

  const result = await service.bind(
    'project-1',
    {
      fileAssetId: 'asset-submitted-1',
      fileName: '预发布施工图.pdf',
      attachmentKind: 'construction_doc',
    },
    createContext('attachment-bind-submitted-success'),
  );

  assert.equal(result.projectId, 'project-1');
  assert.equal(result.fileAssetId, 'asset-submitted-1');
  assert.equal(result.attachmentKind, 'construction_doc');
  assert.equal(harness.state.attachments.length, 1);
});

test('effect_image mime validation rejects non-image truth', async () => {
  const { ProjectAttachmentService } = require('../dist/modules/project/project-attachment.service.js');
  const { ProjectAttachmentPresenter } = require('../dist/modules/project/project-attachment.presenter.js');

  const harness = createAttachmentHarness({
    fileAssets: [createFileAsset({ mimeType: 'application/pdf' })],
  });
  const service = new ProjectAttachmentService(
    harness.repositories.projectRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.fileAssetRepository,
    harness.dataSource,
    harness.auditService,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService(),
    new ProjectAttachmentPresenter(),
  );

  await assert.rejects(
    () =>
      service.bind(
        'project-1',
        {
          fileAssetId: 'asset-1',
          fileName: '效果图.pdf',
          attachmentKind: 'effect_image',
        },
        createContext('attachment-bind-effect-image-mime'),
      ),
    (error) => error?.response?.code === 'PROJECT_ATTACHMENT_INVALID',
  );
});

test('project attachment bind rejects legacy project evidence truth', async () => {
  const { ProjectAttachmentService } = require('../dist/modules/project/project-attachment.service.js');
  const { ProjectAttachmentPresenter } = require('../dist/modules/project/project-attachment.presenter.js');

  const harness = createAttachmentHarness({
    fileAssets: [createFileAsset({ fileKind: 'evidence', mimeType: 'image/png' })],
  });
  const service = new ProjectAttachmentService(
    harness.repositories.projectRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.fileAssetRepository,
    harness.dataSource,
    harness.auditService,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService(),
    new ProjectAttachmentPresenter(),
  );

  await assert.rejects(
    () =>
      service.bind(
        'project-1',
        {
          fileAssetId: 'asset-1',
          fileName: '旧发布走廊图片.png',
          attachmentKind: 'effect_image',
        },
        createContext('attachment-bind-legacy-evidence'),
      ),
    (error) => error?.response?.code === 'PROJECT_ATTACHMENT_INVALID',
  );
});

test('construction_doc mime validation rejects image truth', async () => {
  const { ProjectAttachmentService } = require('../dist/modules/project/project-attachment.service.js');
  const { ProjectAttachmentPresenter } = require('../dist/modules/project/project-attachment.presenter.js');

  const harness = createAttachmentHarness({
    fileAssets: [createFileAsset({ mimeType: 'image/jpeg' })],
  });
  const service = new ProjectAttachmentService(
    harness.repositories.projectRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.fileAssetRepository,
    harness.dataSource,
    harness.auditService,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService(),
    new ProjectAttachmentPresenter(),
  );

  await assert.rejects(
    () =>
      service.bind(
        'project-1',
        {
          fileAssetId: 'asset-1',
          fileName: '施工文档.jpg',
          attachmentKind: 'construction_doc',
        },
        createContext('attachment-bind-construction-doc-mime'),
      ),
    (error) => error?.response?.code === 'PROJECT_ATTACHMENT_INVALID',
  );
});

test('other_material mime validation rejects unsupported truth', async () => {
  const { ProjectAttachmentService } = require('../dist/modules/project/project-attachment.service.js');
  const { ProjectAttachmentPresenter } = require('../dist/modules/project/project-attachment.presenter.js');

  const harness = createAttachmentHarness({
    fileAssets: [createFileAsset({ mimeType: 'application/zip' })],
  });
  const service = new ProjectAttachmentService(
    harness.repositories.projectRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.fileAssetRepository,
    harness.dataSource,
    harness.auditService,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService(),
    new ProjectAttachmentPresenter(),
  );

  await assert.rejects(
    () =>
      service.bind(
        'project-1',
        {
          fileAssetId: 'asset-1',
          fileName: '其他材料.zip',
          attachmentKind: 'other_material',
        },
        createContext('attachment-bind-other-material-mime'),
      ),
    (error) => error?.response?.code === 'PROJECT_ATTACHMENT_INVALID',
  );
});

test('list readback success', async () => {
  const { ProjectAttachmentService } = require('../dist/modules/project/project-attachment.service.js');
  const { ProjectAttachmentPresenter } = require('../dist/modules/project/project-attachment.presenter.js');

  const harness = createAttachmentHarness({
    attachments: [
      createAttachment({
        id: 'attachment-2',
        fileAssetId: 'asset-2',
        sortOrder: 2,
        createdAt: new Date('2026-04-13T09:02:00.000Z'),
      }),
      createAttachment({
        id: 'attachment-1',
        fileAssetId: 'asset-1',
        sortOrder: 1,
        attachmentKind: 'construction_doc',
        mimeType: 'application/pdf',
        createdAt: new Date('2026-04-13T09:01:00.000Z'),
      }),
    ],
  });
  const service = new ProjectAttachmentService(
    harness.repositories.projectRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.fileAssetRepository,
    harness.dataSource,
    harness.auditService,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService(),
    new ProjectAttachmentPresenter(),
  );

  const result = await service.list('project-1', createContext('attachment-list-success'));

  assert.deepEqual(
    result.items.map((item) => item.attachmentId),
    ['attachment-1', 'attachment-2'],
  );
  assert.equal(result.items[0].mimeType, 'application/pdf');
});

test('delete binding success keeps FileAsset truth untouched', async () => {
  const { ProjectAttachmentService } = require('../dist/modules/project/project-attachment.service.js');
  const { ProjectAttachmentPresenter } = require('../dist/modules/project/project-attachment.presenter.js');

  const harness = createAttachmentHarness({
    attachments: [createAttachment()],
  });
  const service = new ProjectAttachmentService(
    harness.repositories.projectRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.fileAssetRepository,
    harness.dataSource,
    harness.auditService,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService(),
    new ProjectAttachmentPresenter(),
  );

  const result = await service.remove('project-1', 'attachment-1', createContext('attachment-delete-success'));

  assert.deepEqual(result, { projectId: 'project-1', attachmentId: 'attachment-1' });
  assert.equal(harness.state.attachments.length, 0);
  assert.equal(harness.state.fileAssets.length, 1);
  assert.equal(harness.state.auditLogs.at(-1)?.eventType, 'project_attachment_deleted');
});

test('duplicate bind rejected', async () => {
  const { ProjectAttachmentService } = require('../dist/modules/project/project-attachment.service.js');
  const { ProjectAttachmentPresenter } = require('../dist/modules/project/project-attachment.presenter.js');

  const harness = createAttachmentHarness({
    attachments: [createAttachment()],
  });
  const service = new ProjectAttachmentService(
    harness.repositories.projectRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.fileAssetRepository,
    harness.dataSource,
    harness.auditService,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService(),
    new ProjectAttachmentPresenter(),
  );

  await assert.rejects(
    () =>
      service.bind(
        'project-1',
        {
          fileAssetId: 'asset-1',
          fileName: '重复材料.png',
          attachmentKind: 'effect_image',
        },
        createContext('attachment-bind-duplicate'),
      ),
    (error) => error?.response?.code === 'PROJECT_ATTACHMENT_DUPLICATE',
  );
});

test('public project detail is not expanded by attachment corridor', async () => {
  const { ProjectQueryService } = require('../dist/modules/project/project-query.service.js');
  const { ProjectPresenter } = require('../dist/modules/project/project.presenter.js');

  const project = createProject();
  const service = new ProjectQueryService(
    {
      async findOneBy(where) {
        return where?.id === 'project-1' ? project : null;
      },
    },
    {
      async verifyCurrentSessionContext() {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'buyer-user',
            userId: 'buyer-user',
            organizationId: 'buyer-org',
            requestId: 'detail-request',
            traceId: 'trace-detail-request',
          },
        };
      },
    },
    createEligibilityService(),
    new ProjectPresenter(),
  );

  const detail = await service.getProjectById('project-1', createContext('attachment-public-detail'));

  assert.equal(detail.projectId, 'project-1');
  assert.ok(!Object.prototype.hasOwnProperty.call(detail, 'attachments'));
});

test('bid-material projection filters to effect_image and construction_doc only', async () => {
  const { ProjectBidMaterialPresenter } = require('../dist/modules/project/project-bid-material.presenter.js');
  const { ProjectBidMaterialService } = require('../dist/modules/project/project-bid-material.service.js');
  const { ProjectQueryService } = require('../dist/modules/project/project-query.service.js');
  const { ProjectPresenter } = require('../dist/modules/project/project.presenter.js');

  const harness = createAttachmentHarness({
    attachments: [
      createAttachment({
        id: 'attachment-2',
        fileAssetId: 'asset-2',
        fileName: '施工图.pdf',
        attachmentKind: 'construction_doc',
        mimeType: 'application/pdf',
        sortOrder: 2,
        createdAt: new Date('2026-04-13T09:02:00.000Z'),
      }),
      createAttachment({
        id: 'attachment-0',
        fileAssetId: 'asset-0',
        fileName: '其他资料.pdf',
        attachmentKind: 'other_material',
        mimeType: 'application/pdf',
        sortOrder: 0,
        createdAt: new Date('2026-04-13T09:00:00.000Z'),
      }),
      createAttachment({
        id: 'attachment-1',
        fileAssetId: 'asset-1',
        fileName: '效果图.png',
        attachmentKind: 'effect_image',
        mimeType: 'image/png',
        sortOrder: 1,
        createdAt: new Date('2026-04-13T09:01:00.000Z'),
      }),
    ],
  });
  const queryService = new ProjectQueryService(
    harness.repositories.projectRepository,
    {
      async verifyCurrentSessionContext() {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'buyer-user',
            userId: 'buyer-user',
            organizationId: 'buyer-org',
            requestId: 'bid-material-request',
            traceId: 'trace-bid-material-request',
          },
        };
      },
    },
    createEligibilityService(),
    new ProjectPresenter(),
  );
  const service = new ProjectBidMaterialService(
    harness.repositories.attachmentRepository,
    queryService,
    new ProjectBidMaterialPresenter(),
  );

  const result = await service.list('project-1', createContext('bid-material-list-success'));

  assert.equal(result.projectId, 'project-1');
  assert.deepEqual(
    result.attachments.map((item) => item.attachmentId),
    ['attachment-1', 'attachment-2'],
  );
  assert.ok(result.attachments.every((item) => item.attachmentKind !== 'other_material'));
});
