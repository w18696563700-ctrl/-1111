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

function createProjectNameAccessProjectionService() {
  const toProjection = (project) => ({
    displayTitle: project.exhibitionName ?? project.title,
    title: project.title,
    exhibitionName: project.exhibitionName ?? null,
    brandName: project.brandName ?? null,
    nameAccess: {
      status: 'visible',
      canRequest: false,
      requestId: null,
    },
  });
  return {
    async buildSingleProjectProjection({ project }) {
      return toProjection(project);
    },
    async buildPublicProjectionMap({ projects }) {
      return new Map(projects.map((project) => [project.id, toProjection(project)]));
    },
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

function createBid(overrides = {}) {
  return {
    id: 'bid-1',
    bidNo: 'BID-2026-1',
    projectId: 'project-1',
    bidderOrganizationId: 'supplier-org',
    organizationId: 'supplier-org',
    actorId: 'supplier-user',
    userId: 'supplier-user',
    quoteAmount: '10000.00',
    proposalSummary: '竞标方案摘要',
    projectUnderstandingFileAssetId: 'bid-understanding-asset',
    quoteSheetFileAssetId: 'bid-quote-asset',
    schedulePlanFileAssetId: 'bid-schedule-asset',
    state: 'submitted',
    submittedBy: 'supplier-user',
    submittedAt: new Date('2026-05-08T10:00:00.000Z'),
    createdAt: new Date('2026-05-08T10:00:00.000Z'),
    updatedAt: new Date('2026-05-08T10:00:00.000Z'),
    ...overrides,
  };
}

function createForumPost(overrides = {}) {
  return {
    id: 'forum-post-1',
    postNo: 'FORUM-POST-1',
    organizationId: 'buyer-org',
    authorUserId: 'buyer-user',
    authorActorId: 'buyer-user',
    authorOrganizationId: 'buyer-org',
    sourceDraftId: 'forum-draft-1',
    topicId: 'expo-entry',
    title: '论坛图片帖',
    body: '论坛图片帖正文',
    excerpt: '论坛图片帖正文',
    attachmentFileAssetIds: ['forum-asset-1'],
    state: 'published',
    commentCount: 0,
    lastModerationCaseId: null,
    publishedAt: new Date('2026-05-05T10:00:00.000Z'),
    hiddenAt: null,
    archivedAt: null,
    createdAt: new Date('2026-05-05T10:00:00.000Z'),
    updatedAt: new Date('2026-05-05T10:00:00.000Z'),
    ...overrides,
  };
}

function createPublicResource(overrides = {}) {
  return {
    resourceId: 'public-resource-1',
    resourceCategory: 'contract_template',
    title: '标准合同模板',
    summary: '用于项目续接的标准合同模板。',
    fileAssetId: 'asset-public-1',
    fileName: '标准合同模板.docx',
    mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    visibility: 'app_shared',
    sortOrder: 10,
    publishedAt: new Date('2026-04-22T08:00:00.000Z'),
    publishedBy: 'platform-admin',
    createdAt: new Date('2026-04-22T08:00:00.000Z'),
    ...overrides,
  };
}

function createAttachmentHarness(overrides = {}) {
  const state = {
    project: createProject(overrides.project),
    projectMissing: overrides.projectMissing ?? false,
    fileAssets: structuredClone(overrides.fileAssets ?? [createFileAsset()]),
    attachments: structuredClone(overrides.attachments ?? []),
    bids: structuredClone(overrides.bids ?? []),
    forumPosts: structuredClone(overrides.forumPosts ?? []),
    publicResources: structuredClone(overrides.publicResources ?? []),
    auditLogs: structuredClone(overrides.auditLogs ?? []),
  };

  function getRepository(entity, draft) {
    if (entity?.name === 'ProjectEntity') {
      return {
        async findOneBy(where) {
          if (!draft.project || draft.projectMissing) {
            return null;
          }
          if (where?.id && draft.project.id !== where.id) {
            return null;
          }
          return draft.project;
        },
        async query() {
          return [];
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

    if (entity?.name === 'BidEntity') {
      return {
        createQueryBuilder() {
          const query = { fileAssetId: null };
          return {
            where(_expression, parameters = {}) {
              query.fileAssetId = parameters.fileAssetId ?? null;
              return this;
            },
            orWhere(_expression, parameters = {}) {
              query.fileAssetId = query.fileAssetId ?? parameters.fileAssetId ?? null;
              return this;
            },
            async getOne() {
              return (
                draft.bids.find((item) => {
                  if (!query.fileAssetId) {
                    return false;
                  }
                  return (
                    item.projectUnderstandingFileAssetId === query.fileAssetId ||
                    item.quoteSheetFileAssetId === query.fileAssetId ||
                    item.schedulePlanFileAssetId === query.fileAssetId
                  );
                }) ?? null
              );
            },
          };
        },
      };
    }

    if (entity?.name === 'ProjectPublicResourceEntity') {
      return {
        async findOneBy(where) {
          return (
            draft.publicResources.find((item) => {
              if (where?.fileAssetId && item.fileAssetId !== where.fileAssetId) {
                return false;
              }
              if (where?.resourceId && item.resourceId !== where.resourceId) {
                return false;
              }
              return true;
            }) ?? null
          );
        },
      };
    }

    if (entity?.name === 'ForumPostEntity') {
      return {
        createQueryBuilder() {
          const query = { state: null, fileAssetIds: [] };
          return {
            where(_expression, parameters = {}) {
              query.state = parameters.state ?? null;
              return this;
            },
            andWhere(_expression, parameters = {}) {
              query.fileAssetIds = JSON.parse(parameters.fileAssetIds ?? '[]');
              return this;
            },
            orderBy() {
              return this;
            },
            async getOne() {
              return (
                draft.forumPosts.find((item) => {
                  if (query.state && item.state !== query.state) {
                    return false;
                  }
                  return query.fileAssetIds.every((fileAssetId) =>
                    item.attachmentFileAssetIds.includes(fileAssetId),
                  );
                }) ?? null
              );
            },
          };
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
      bidRepository: getRepository({ name: 'BidEntity' }, state),
      publicResourceRepository: getRepository({ name: 'ProjectPublicResourceEntity' }, state),
      forumPostRepository: getRepository({ name: 'ForumPostEntity' }, state),
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
    async requireAuthenticatedActor() {
      return { id: overrides.userId ?? 'buyer-user', status: 'active' };
    },
    async requireCurrentOrganizationScope(currentSession, organizationId) {
      if ((currentSession.organizationId ?? '') !== organizationId) {
        const error = new Error('organization scope mismatch');
        error.response = { code: 'AUTH_PERMISSION_INSUFFICIENT' };
        throw error;
      }
      return {
        organization: { id: organizationId },
        membership: { roleKey: overrides.roleKey ?? 'buyer_admin' },
        certification: { certificationStatus: 'approved' },
        roleKeys: [overrides.roleKey ?? 'buyer_admin'],
      };
    },
    async requireBidSubmitEligibilityFromContext(_context, _resolver, project) {
      const currentSession = {
        sessionId: 'session-1',
        actorId: overrides.actorId ?? 'supplier-user',
        userId: overrides.userId ?? 'supplier-user',
        organizationId: overrides.organizationId ?? 'supplier-org',
        requestId: 'bid-material-request',
        traceId: 'trace-bid-material-request',
      };
      const scope = await this.requireBidSubmitEligibility(currentSession, project);
      return { currentSession, scope, project };
    },
    async requireBidSubmitEligibility(currentSession, project) {
      if (!project || project.state !== 'published' || project.publishedAt === null) {
        const error = new Error('project not published');
        error.response = { code: 'AUTH_PERMISSION_INSUFFICIENT' };
        throw error;
      }
      const organizationId = currentSession.organizationId ?? overrides.organizationId ?? 'supplier-org';
      if (organizationId === project.organizationId) {
        const error = new Error('owner cannot bid');
        error.response = { code: 'AUTH_PERMISSION_INSUFFICIENT' };
        throw error;
      }
      return {
        organization: { id: organizationId, organizationType: 'supplier' },
        membership: { roleKey: overrides.roleKey ?? 'supplier_admin' },
        certification: { certificationStatus: 'approved' },
        personalCertification: {
          certificationStatus: 'approved',
          qualifiedForCurrentActor: true,
          lockedToOtherActor: false,
        },
        roleKeys: [overrides.roleKey ?? 'supplier_admin'],
      };
    },
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

function createFileAccessService(harness, overrides = {}) {
  const {
    ProjectAttachmentFileAccessService,
  } = require('../dist/modules/project/project-attachment-file-access.service.js');
  return new ProjectAttachmentFileAccessService(
    harness.repositories.fileAssetRepository,
    harness.repositories.attachmentRepository,
    harness.repositories.projectRepository,
    harness.repositories.bidRepository,
    harness.repositories.publicResourceRepository,
    harness.repositories.forumPostRepository,
    {
      async verifyCurrentSessionContext() {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: overrides.actorId ?? 'buyer-user',
            userId: overrides.userId ?? 'buyer-user',
            organizationId: overrides.sessionOrganizationId ?? 'buyer-org',
            requestId: 'file-access-request',
            traceId: 'trace-file-access-request',
          },
        };
      },
    },
    createEligibilityService({
      organizationId: overrides.sessionOrganizationId ?? 'buyer-org',
      roleKey: overrides.roleKey ?? 'buyer_admin',
    }),
    overrides.publicUrlService ?? {
      async buildObjectAccessUrl(objectKey) {
        return `https://signed.example.test/${encodeURIComponent(objectKey)}`;
      },
    },
    {
      uploadSignedUrlExpiresSeconds: overrides.expiresSeconds ?? 900,
    },
    overrides.bidParticipationAccessService ?? {
      async requireApprovedForOrganization() {},
    },
  );
}

test('project attachment migration keeps five V1 kinds plus legacy other_material constraint', () => {
  const {
    projectAttachmentCorridorP1Migrations,
  } = require('../dist/core/migrations/migrations.js');

  const migration = projectAttachmentCorridorP1Migrations.find(
    (item) => item.key === '20260427_quote_basis_material_package_v1_attachment_kind_constraint',
  );
  assert.ok(migration);
  const statements = migration.statements.join('\n');
  assert.match(statements, /DROP CONSTRAINT IF EXISTS chk_project_attachments_attachment_kind/);
  for (const kind of [
    'effect_image',
    'construction_doc',
    'material_sample',
    'equipment_material_list',
    'service_list',
    'other_material',
  ]) {
    assert.match(statements, new RegExp(`'${kind}'`));
  }
});

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

test('effect_image accepts non-image full-format truth', async () => {
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

  const result = await service.bind(
    'project-1',
    {
      fileAssetId: 'asset-1',
      fileName: '效果图说明.pdf',
      attachmentKind: 'effect_image',
    },
    createContext('attachment-bind-effect-image-full-format'),
  );

  assert.equal(result.attachmentKind, 'effect_image');
  assert.equal(result.mimeType, 'application/pdf');
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

test('construction_doc accepts image full-format truth', async () => {
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

  const result = await service.bind(
    'project-1',
    {
      fileAssetId: 'asset-1',
      fileName: '现场尺寸照片.jpg',
      attachmentKind: 'construction_doc',
    },
    createContext('attachment-bind-construction-doc-full-format'),
  );

  assert.equal(result.attachmentKind, 'construction_doc');
  assert.equal(result.mimeType, 'image/jpeg');
});

test('bind rejects legacy other_material for V1 writes', async () => {
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
          fileName: '其他材料.pdf',
          attachmentKind: 'other_material',
        },
        createContext('attachment-bind-other-material-legacy'),
      ),
    (error) =>
      error?.response?.code === 'PROJECT_ATTACHMENT_INVALID' &&
      error?.response?.message === 'Current attachmentKind is not supported.',
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

test('file/access returns owner-private signed access without exposing objectKey', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    attachments: [createAttachment()],
  });
  const service = createFileAccessService(harness, {
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/project-attachment';
      },
    },
  });

  const result = await service.getAccess(
    { fileAssetId: 'asset-1', mode: 'preview' },
    createContext('file-access-owner-preview'),
  );

  assert.equal(result.fileAssetId, 'asset-1');
  assert.equal(result.mode, 'preview');
  assert.equal(result.accessUrl, 'https://signed.example.test/project-attachment');
  assert.equal(result.fileName, '效果图.png');
  assert.equal(result.mimeType, 'image/png');
  assert.equal(result.contentLengthBytes, 2048);
  assert.deepEqual(publicUrlCalls, ['object-1']);
  assert.ok(Date.parse(result.expiresAt) > Date.now());
  assert.ok(!Object.prototype.hasOwnProperty.call(result, 'objectKey'));
});

test('file/access returns signed access for published forum post attachment', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    fileAssets: [
      createFileAsset({
        id: 'forum-asset-1',
        uploadSessionId: 'forum-upload-1',
        businessType: 'forum_draft_attachment',
        businessId: 'forum-draft-1',
        fileKind: 'media',
        objectKey: 'forum_draft_attachment/media/2026/05/forum-image.jpg',
        mimeType: 'image/jpeg',
      }),
    ],
    forumPosts: [createForumPost()],
  });
  const service = createFileAccessService(harness, {
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/forum-image';
      },
    },
  });

  const result = await service.getAccess(
    { fileAssetId: 'forum-asset-1', mode: 'preview' },
    createContext('file-access-forum-post-image'),
  );

  assert.equal(result.fileAssetId, 'forum-asset-1');
  assert.equal(result.mode, 'preview');
  assert.equal(result.accessUrl, 'https://signed.example.test/forum-image');
  assert.equal(result.fileName, 'forum-image.jpg');
  assert.equal(result.mimeType, 'image/jpeg');
  assert.equal(result.contentLengthBytes, 2048);
  assert.deepEqual(publicUrlCalls, ['forum_draft_attachment/media/2026/05/forum-image.jpg']);
  assert.ok(!Object.prototype.hasOwnProperty.call(result, 'objectKey'));
});

test('file/access returns bid submission attachment signed access for publisher organization', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    fileAssets: [
      createFileAsset({
        id: 'bid-understanding-asset',
        businessType: 'project',
        businessId: 'project-1',
        organizationId: 'supplier-org',
        fileKind: 'bid_project_understanding',
        objectKey: 'project/bid/bid-understanding.pdf',
        mimeType: 'application/pdf',
      }),
    ],
    bids: [createBid()],
  });
  const service = createFileAccessService(harness, {
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/bid-understanding';
      },
    },
  });

  const result = await service.getAccess(
    { fileAssetId: 'bid-understanding-asset', mode: 'preview', projectId: 'project-1' },
    createContext('file-access-bid-submission-publisher'),
  );

  assert.equal(result.fileAssetId, 'bid-understanding-asset');
  assert.equal(result.mode, 'preview');
  assert.equal(result.accessUrl, 'https://signed.example.test/bid-understanding');
  assert.equal(result.fileName, 'bid-understanding.pdf');
  assert.equal(result.mimeType, 'application/pdf');
  assert.deepEqual(publicUrlCalls, ['project/bid/bid-understanding.pdf']);
  assert.ok(!Object.prototype.hasOwnProperty.call(result, 'objectKey'));
});

test('file/access returns bid submission attachment signed access for owning bidder organization', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    fileAssets: [
      createFileAsset({
        id: 'bid-quote-asset',
        businessType: 'project',
        businessId: 'project-1',
        organizationId: 'supplier-org',
        fileKind: 'bid_quote_sheet',
        objectKey: 'project/bid/bid-quote.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      }),
    ],
    bids: [createBid()],
  });
  const service = createFileAccessService(harness, {
    sessionOrganizationId: 'supplier-org',
    roleKey: 'supplier_admin',
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/bid-quote';
      },
    },
  });

  const result = await service.getAccess(
    { fileAssetId: 'bid-quote-asset', mode: 'download', projectId: 'project-1' },
    createContext('file-access-bid-submission-bidder'),
  );

  assert.equal(result.fileAssetId, 'bid-quote-asset');
  assert.equal(result.mode, 'download');
  assert.equal(result.accessUrl, 'https://signed.example.test/bid-quote');
  assert.equal(result.fileName, 'bid-quote.xlsx');
  assert.deepEqual(publicUrlCalls, ['project/bid/bid-quote.xlsx']);
});

test('file/access rejects unrelated organization for bid submission attachment before signing URL', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    fileAssets: [
      createFileAsset({
        id: 'bid-schedule-asset',
        businessType: 'project',
        businessId: 'project-1',
        organizationId: 'supplier-org',
        fileKind: 'bid_schedule_plan',
        objectKey: 'project/bid/bid-schedule.pdf',
        mimeType: 'application/pdf',
      }),
    ],
    bids: [createBid()],
  });
  const service = createFileAccessService(harness, {
    sessionOrganizationId: 'other-org',
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/bid-schedule';
      },
    },
  });

  await assert.rejects(
    () =>
      service.getAccess(
        { fileAssetId: 'bid-schedule-asset', mode: 'preview', projectId: 'project-1' },
        createContext('file-access-bid-submission-unrelated-denied'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_PERMISSION_DENIED',
  );
  assert.deepEqual(publicUrlCalls, []);
});

test('file/access rejects non-owner before signing URL', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    attachments: [createAttachment()],
  });
  const service = createFileAccessService(harness, {
    sessionOrganizationId: 'supplier-org',
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/project-attachment';
      },
    },
  });

  await assert.rejects(
    () =>
      service.getAccess(
        { fileAssetId: 'asset-1', mode: 'download' },
        createContext('file-access-non-owner'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_PERMISSION_DENIED',
  );
  assert.deepEqual(publicUrlCalls, []);
});

test('file/access returns bid-material signed access for qualified supplier scope', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    attachments: [
      createAttachment({
        id: 'attachment-equipment-list',
        fileAssetId: 'asset-1',
        fileName: '设备物料清单.xlsx',
        attachmentKind: 'equipment_material_list',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      }),
    ],
    fileAssets: [
      createFileAsset({
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      }),
    ],
  });
  const service = createFileAccessService(harness, {
    sessionOrganizationId: 'supplier-org',
    roleKey: 'supplier_admin',
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/bid-material';
      },
    },
  });

  const result = await service.getAccess(
    {
      fileAssetId: 'asset-1',
      mode: 'download',
      projectId: 'project-1',
      accessScope: 'bid_material',
    },
    createContext('file-access-bid-material-supplier'),
  );

  assert.equal(result.fileAssetId, 'asset-1');
  assert.equal(result.mode, 'download');
  assert.equal(result.fileName, '设备物料清单.xlsx');
  assert.equal(result.accessUrl, 'https://signed.example.test/bid-material');
  assert.deepEqual(publicUrlCalls, ['object-1']);
});

test('file/access rejects owner organization for bid-material scope before signing URL', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    attachments: [createAttachment()],
  });
  const service = createFileAccessService(harness, {
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/bid-material';
      },
    },
  });

  await assert.rejects(
    () =>
      service.getAccess(
        {
          fileAssetId: 'asset-1',
          mode: 'download',
          projectId: 'project-1',
          accessScope: 'bid_material',
        },
        createContext('file-access-bid-material-owner-denied'),
      ),
    (error) => error?.response?.code === 'AUTH_PERMISSION_INSUFFICIENT',
  );
  assert.deepEqual(publicUrlCalls, []);
});

test('file/access rejects legacy other_material for bid-material scope', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    attachments: [
      createAttachment({
        attachmentKind: 'other_material',
        mimeType: 'application/pdf',
      }),
    ],
    fileAssets: [
      createFileAsset({
        mimeType: 'application/pdf',
      }),
    ],
  });
  const service = createFileAccessService(harness, {
    sessionOrganizationId: 'supplier-org',
    roleKey: 'supplier_admin',
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/bid-material';
      },
    },
  });

  await assert.rejects(
    () =>
      service.getAccess(
        {
          fileAssetId: 'asset-1',
          mode: 'download',
          projectId: 'project-1',
          accessScope: 'bid_material',
        },
        createContext('file-access-bid-material-legacy-other-material'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_PERMISSION_DENIED',
  );
  assert.deepEqual(publicUrlCalls, []);
});

test('file/access rejects unbound FileAsset', async () => {
  const harness = createAttachmentHarness({
    attachments: [],
  });
  const service = createFileAccessService(harness);

  await assert.rejects(
    () =>
      service.getAccess(
        { fileAssetId: 'asset-1', mode: 'download' },
        createContext('file-access-unbound'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_NOT_FOUND',
  );
});

test('file/access returns public-resource signed download when attachment binding is absent', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    attachments: [],
    fileAssets: [
      createFileAsset({
        id: 'asset-public-1',
        businessType: 'template_governance',
        businessId: 'template-1',
        fileKind: 'public_resource',
        objectKey: 'resources/contract-template.docx',
        mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        size: 4096,
        organizationId: 'platform-org',
      }),
    ],
    publicResources: [createPublicResource()],
  });
  const service = createFileAccessService(harness, {
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/resources/contract-template.docx';
      },
    },
  });

  const result = await service.getAccess(
    { fileAssetId: 'asset-public-1', mode: 'download' },
    createContext('file-access-public-resource-fallback'),
  );

  assert.equal(result.fileAssetId, 'asset-public-1');
  assert.equal(result.mode, 'download');
  assert.equal(result.fileName, '标准合同模板.docx');
  assert.equal(
    result.mimeType,
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  );
  assert.equal(result.accessUrl, 'https://signed.example.test/resources/contract-template.docx');
  assert.equal(result.contentLengthBytes, 4096);
  assert.deepEqual(publicUrlCalls, ['resources/contract-template.docx']);
  assert.ok(!Object.prototype.hasOwnProperty.call(result, 'objectKey'));
});

test('file/access public_resource scope only signs published app-shared resources', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    attachments: [createAttachment()],
    fileAssets: [
      createFileAsset({
        id: 'asset-hidden-resource',
        businessType: 'template_governance',
        businessId: 'template-hidden',
        fileKind: 'public_resource',
        objectKey: 'resources/hidden.docx',
        mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      }),
    ],
    publicResources: [
      createPublicResource({
        fileAssetId: 'asset-hidden-resource',
        visibility: 'owner_private',
      }),
    ],
  });
  const service = createFileAccessService(harness, {
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return `https://signed.example.test/${objectKey}`;
      },
    },
  });

  await assert.rejects(
    () =>
      service.getAccess(
        {
          fileAssetId: 'asset-hidden-resource',
          mode: 'download',
          accessScope: 'public_resource',
        },
        createContext('file-access-public-resource-hidden'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_NOT_FOUND',
  );
  assert.deepEqual(publicUrlCalls, []);
});

test('file/access public_resource scope rejects preview mode before signing URL', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    attachments: [],
    fileAssets: [
      createFileAsset({
        id: 'asset-public-1',
        businessType: 'template_governance',
        businessId: 'template-1',
        fileKind: 'public_resource',
        objectKey: 'resources/contract-template.docx',
        mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      }),
    ],
    publicResources: [createPublicResource()],
  });
  const service = createFileAccessService(harness, {
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return `https://signed.example.test/${objectKey}`;
      },
    },
  });

  await assert.rejects(
    () =>
      service.getAccess(
        {
          fileAssetId: 'asset-public-1',
          mode: 'preview',
          accessScope: 'public_resource',
        },
        createContext('file-access-public-resource-preview'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_INVALID',
  );
  assert.deepEqual(publicUrlCalls, []);
});

test('file/access rejects unsupported mode', async () => {
  const harness = createAttachmentHarness({
    attachments: [createAttachment()],
  });
  const service = createFileAccessService(harness);

  await assert.rejects(
    () =>
      service.getAccess(
        { fileAssetId: 'asset-1', mode: 'inline' },
        createContext('file-access-invalid-mode'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_INVALID',
  );
});

test('file/access rejects missing fileAssetId', async () => {
  const harness = createAttachmentHarness({
    attachments: [createAttachment()],
  });
  const service = createFileAccessService(harness);

  await assert.rejects(
    () =>
      service.getAccess(
        { mode: 'download' },
        createContext('file-access-missing-file-asset-id'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_INVALID',
  );
});

test('file/access rejects non owner-private attachment visibility', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    attachments: [createAttachment({ visibility: 'public' })],
  });
  const service = createFileAccessService(harness, {
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/project-attachment';
      },
    },
  });

  await assert.rejects(
    () =>
      service.getAccess(
        { fileAssetId: 'asset-1', mode: 'download' },
        createContext('file-access-public-visibility'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_NOT_FOUND',
  );
  assert.deepEqual(publicUrlCalls, []);
});

test('file/access rejects attachment when project truth is missing', async () => {
  const harness = createAttachmentHarness({
    projectMissing: true,
    attachments: [createAttachment()],
  });
  const service = createFileAccessService(harness);

  await assert.rejects(
    () =>
      service.getAccess(
        { fileAssetId: 'asset-1', mode: 'download' },
        createContext('file-access-project-missing'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_NOT_FOUND',
  );
});

test('file/access rejects FileAsset project binding drift before signing URL', async () => {
  const publicUrlCalls = [];
  const harness = createAttachmentHarness({
    fileAssets: [createFileAsset({ businessId: 'other-project' })],
    attachments: [createAttachment()],
  });
  const service = createFileAccessService(harness, {
    publicUrlService: {
      async buildObjectAccessUrl(objectKey) {
        publicUrlCalls.push(objectKey);
        return 'https://signed.example.test/project-attachment';
      },
    },
  });

  await assert.rejects(
    () =>
      service.getAccess(
        { fileAssetId: 'asset-1', mode: 'download' },
        createContext('file-access-file-asset-drift'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_UNAVAILABLE',
  );
  assert.deepEqual(publicUrlCalls, []);
});

test('file/access fails closed when signed URL cannot be built', async () => {
  const harness = createAttachmentHarness({
    attachments: [createAttachment()],
  });
  const service = createFileAccessService(harness, {
    publicUrlService: {
      async buildObjectAccessUrl() {
        return null;
      },
    },
  });

  await assert.rejects(
    () =>
      service.getAccess(
        { fileAssetId: 'asset-1', mode: 'download' },
        createContext('file-access-url-unavailable'),
      ),
    (error) => error?.response?.code === 'FILE_ACCESS_UNAVAILABLE',
  );
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
      async query() {
        return [];
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
    createProjectNameAccessProjectionService(),
    new ProjectPresenter(),
  );

  const detail = await service.getProjectById('project-1', createContext('attachment-public-detail'));

  assert.equal(detail.projectId, 'project-1');
  assert.ok(!Object.prototype.hasOwnProperty.call(detail, 'attachments'));
});

test('bid-material projection filters to quote-basis V1 kinds only', async () => {
  const { ProjectBidMaterialPresenter } = require('../dist/modules/project/project-bid-material.presenter.js');
  const { ProjectBidMaterialService } = require('../dist/modules/project/project-bid-material.service.js');

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
        id: 'attachment-3',
        fileAssetId: 'asset-3',
        fileName: '材质图.pdf',
        attachmentKind: 'material_sample',
        mimeType: 'application/pdf',
        sortOrder: 3,
        createdAt: new Date('2026-04-13T09:03:00.000Z'),
      }),
      createAttachment({
        id: 'attachment-4',
        fileAssetId: 'asset-4',
        fileName: '设备物料清单.xlsx',
        attachmentKind: 'equipment_material_list',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        sortOrder: 4,
        createdAt: new Date('2026-04-13T09:04:00.000Z'),
      }),
      createAttachment({
        id: 'attachment-5',
        fileAssetId: 'asset-5',
        fileName: '服务清单.csv',
        attachmentKind: 'service_list',
        mimeType: 'text/csv',
        sortOrder: 5,
        createdAt: new Date('2026-04-13T09:05:00.000Z'),
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
  const verificationService = {
    async verifyCurrentSessionContext() {
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'supplier-user',
          userId: 'supplier-user',
          organizationId: 'supplier-org',
          requestId: 'bid-material-request',
          traceId: 'trace-bid-material-request',
        },
      };
    },
  };
  const eligibilityService = createEligibilityService({
    organizationId: 'supplier-org',
    roleKey: 'supplier_admin',
  });
  const service = new ProjectBidMaterialService(
    harness.repositories.attachmentRepository,
    harness.repositories.projectRepository,
    { async findOneBy() { return null; } },
    verificationService,
    eligibilityService,
    new ProjectBidMaterialPresenter(),
    { async requireApprovedForOrganization() {} },
    { async getWorkbench() { throw new Error('should not build workbench without thread'); } },
  );

  const result = await service.list('project-1', createContext('bid-material-list-success'));

  assert.equal(result.projectId, 'project-1');
  assert.deepEqual(
    result.attachments.map((item) => item.attachmentId),
    ['attachment-1', 'attachment-2', 'attachment-3', 'attachment-4', 'attachment-5'],
  );
  assert.ok(result.attachments.every((item) => item.attachmentKind !== 'other_material'));
});
