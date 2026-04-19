const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId, authorization = 'Bearer public-resource') {
  return {
    authorization,
    actorId: '',
    userId: '',
    organizationId: '',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1'
  };
}

function createResource(overrides = {}) {
  return {
    resourceId: 'resource-1',
    resourceCategory: 'contract_template',
    title: '标准合同模板',
    summary: '用于项目续接的标准合同模板。',
    fileAssetId: 'asset-1',
    fileName: 'contract-template.pdf',
    mimeType: 'application/pdf',
    visibility: 'app_shared',
    sortOrder: 0,
    publishedAt: new Date('2026-04-14T08:00:00.000Z'),
    publishedBy: 'admin-1',
    createdAt: new Date('2026-04-14T08:00:00.000Z'),
    ...overrides
  };
}

function createFileAsset(overrides = {}) {
  return {
    id: 'asset-1',
    uploadSessionId: 'upload-1',
    businessType: 'template_governance',
    businessId: 'template-1',
    fileKind: 'public_resource',
    objectKey: 'resources/contract-template.pdf',
    mimeType: 'application/pdf',
    size: 2048,
    checksum: 'checksum-1',
    actorId: 'admin-1',
    userId: 'admin-1',
    organizationId: 'platform-org',
    createdAt: new Date('2026-04-14T08:00:00.000Z'),
    ...overrides
  };
}

function createHarness(overrides = {}) {
  const { ProjectPublicResourceService } = require('../dist/modules/project/project-public-resource.service.js');
  const { ProjectPublicResourcePresenter } = require('../dist/modules/project/project-public-resource.presenter.js');

  const state = {
    resources: structuredClone(overrides.resources ?? [createResource()]),
    fileAssets: structuredClone(overrides.fileAssets ?? [createFileAsset()])
  };

  const resourceRepository = {
    async find() {
      return [...state.resources].sort((left, right) => {
        if (left.sortOrder !== right.sortOrder) {
          return left.sortOrder - right.sortOrder;
        }
        return new Date(right.publishedAt).getTime() - new Date(left.publishedAt).getTime();
      });
    }
  };

  const fileAssetRepository = {
    async findBy() {
      return [...state.fileAssets];
    }
  };

  return {
    service: new ProjectPublicResourceService(
      resourceRepository,
      fileAssetRepository,
      overrides.currentSessionVerificationService ?? {
        async verifyCurrentSessionContext(context) {
          return {
            outcome: 'verified',
            currentSession: {
              sessionId: 'session-1',
              actorId: 'user-1',
              userId: 'user-1',
              organizationId: 'buyer-org',
              requestId: context.requestId,
              traceId: context.traceId
            }
          };
        }
      },
      overrides.eligibilityService ?? {
        async requireAuthenticatedActor() {
          return { id: 'user-1', status: 'active' };
        }
      },
      new ProjectPublicResourcePresenter()
    )
  };
}

test('project public resources list returns app_shared catalog only with stable download anchor fields', async () => {
  const harness = createHarness({
    resources: [
      createResource({
        resourceId: 'resource-2',
        title: '流程图说明',
        resourceCategory: 'process_guide',
        fileAssetId: 'asset-2',
        fileName: 'guide.png',
        mimeType: 'image/png',
        sortOrder: 1
      }),
      createResource(),
      createResource({
        resourceId: 'resource-hidden',
        visibility: 'owner_private',
        fileAssetId: 'asset-3'
      }),
      createResource({
        resourceId: 'resource-unpublished',
        publishedAt: null,
        fileAssetId: 'asset-4'
      }),
      createResource({
        resourceId: 'resource-invalid-mime',
        fileAssetId: 'asset-5',
        mimeType: 'application/zip'
      }),
      createResource({
        resourceId: 'resource-missing-asset',
        fileAssetId: 'asset-missing'
      })
    ],
    fileAssets: [
      createFileAsset(),
      createFileAsset({ id: 'asset-2', mimeType: 'image/png', objectKey: 'resources/guide.png' }),
      createFileAsset({ id: 'asset-3' }),
      createFileAsset({ id: 'asset-4' }),
      createFileAsset({ id: 'asset-5', mimeType: 'application/zip' })
    ]
  });

  const result = await harness.service.list(createContext('public-resource-list'));

  assert.deepEqual(result, {
    resources: [
      {
        resourceId: 'resource-1',
        resourceCategory: 'contract_template',
        title: '标准合同模板',
        summary: '用于项目续接的标准合同模板。',
        fileAssetId: 'asset-1',
        fileName: 'contract-template.pdf',
        mimeType: 'application/pdf',
        visibility: 'app_shared',
        sortOrder: 0,
        publishedAt: '2026-04-14T08:00:00.000Z'
      },
      {
        resourceId: 'resource-2',
        resourceCategory: 'process_guide',
        title: '流程图说明',
        summary: '用于项目续接的标准合同模板。',
        fileAssetId: 'asset-2',
        fileName: 'guide.png',
        mimeType: 'image/png',
        visibility: 'app_shared',
        sortOrder: 1,
        publishedAt: '2026-04-14T08:00:00.000Z'
      }
    ]
  });
  assert.equal('objectKey' in result.resources[0], false);
});

test('project public resources require a verified current session and active actor', async () => {
  const harness = createHarness({
    currentSessionVerificationService: {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'failed',
          reason: 'missing_current_session_carrier',
          requestId: context.requestId,
          traceId: context.traceId
        };
      }
    }
  });

  await assert.rejects(
    () => harness.service.list(createContext('public-resource-auth', '')),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_SESSION_INVALID');
      return true;
    }
  );
});
