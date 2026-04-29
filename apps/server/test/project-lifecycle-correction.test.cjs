const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId, authorization = 'Bearer lifecycle', organizationId = '') {
  return {
    authorization,
    actorId: '',
    userId: '',
    organizationId,
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1'
  };
}

function createProject(id, overrides = {}) {
  return {
    id,
    projectNo: `PROJ-${id}`,
    organizationId: 'buyer-org',
    creatorUserId: 'user-1',
    creatorActorId: 'user-1',
    title: `${id}-title`,
    exhibitionName: '中国建博会',
    brandName: '品牌A',
    buildingType: 'exhibition',
    budgetAmount: '120000.00',
    areaSqm: null,
    buildingTypeRemark: null,
    provinceCode: '310000',
    provinceName: '上海市',
    cityCode: '310100',
    cityName: '上海市',
    districtCode: null,
    districtName: null,
    detailAddress: '浦东新区龙阳路 1 号',
    scopeSummary: '主场展位搭建与灯光优化',
    plannedStartAt: null,
    plannedEndAt: null,
    scheduleDetail: null,
    description: null,
    state: 'submitted',
    summary: {
      heading: '项目已提交发布链路，可继续执行发布。',
      stateLabel: '当前项目已提交，尚未进入公域展示。'
    },
    publishedAt: null,
    createdAt: new Date('2026-04-13T08:00:00.000Z'),
    updatedAt: new Date('2026-04-13T08:00:00.000Z'),
    ...overrides
  };
}

function createHarness() {
  const { ProjectLifecycleService } = require('../dist/modules/project/project-lifecycle.service.js');
  const { ProjectExitGovernanceService } = require('../dist/modules/project/project-exit-governance.service.js');
  const { ProjectQueryService } = require('../dist/modules/project/project-query.service.js');
  const { ProjectPresenter } = require('../dist/modules/project/project.presenter.js');
  const { MyProjectPresenter } = require('../dist/modules/my_project/my-project.presenter.js');
  const { MyProjectQueryService } = require('../dist/modules/my_project/my-project.query.service.js');
  const { ProjectEntity } = require('../dist/modules/project/entities/project.entity.js');
  const { ProjectExitCaseEntity } = require('../dist/modules/project/entities/project-exit-case.entity.js');
  const { BidEntity } = require('../dist/modules/bid/entities/bid.entity.js');
  const { ProjectOrderEntity } = require('../dist/modules/order/entities/project-order.entity.js');
  const {
    PlatformServiceFeeAuthorizationEntity
  } = require('../dist/modules/p0_pay/entities/platform-service-fee-authorization.entity.js');

  const projects = [];
  const bids = [];
  const orders = [];
  const authorizations = [];
  const exitCases = [];
  const auditLogs = [];
  function createRepository(items) {
    return {
    items,
    create(value) {
      return { ...value };
    },
    async save(value) {
      const index = items.findIndex((item) => item.id === value.id);
      if (index >= 0) {
        items[index] = { ...items[index], ...value };
        return items[index];
      }
      items.push({ ...value });
      return value;
    },
    async count(options = {}) {
      return (await this.find(options)).length;
    },
    async find(options = {}) {
      const where = options.where ?? {};
      return items
        .filter((item) => {
          for (const [key, value] of Object.entries(where)) {
            if (value !== undefined && value !== null && item[key] !== value) {
              return false;
            }
          }
          return true;
        })
        .sort((left, right) => {
          const leftPublished = left.publishedAt instanceof Date ? left.publishedAt.getTime() : 0;
          const rightPublished = right.publishedAt instanceof Date ? right.publishedAt.getTime() : 0;
          if (leftPublished !== rightPublished) {
            return rightPublished - leftPublished;
          }
          const leftCreated = left.createdAt instanceof Date ? left.createdAt.getTime() : 0;
          const rightCreated = right.createdAt instanceof Date ? right.createdAt.getTime() : 0;
          return rightCreated - leftCreated;
        });
    },
    async findOneBy(where) {
      return (
        items.find((item) => {
          for (const [key, value] of Object.entries(where)) {
            if (value !== undefined && value !== null && item[key] !== value) {
              return false;
            }
          }
          return true;
        }) ?? null
      );
    },
    async findOne(options) {
      return this.findOneBy(options?.where ?? {});
    },
    async query(sql) {
      if (sql.includes('from public.projects')) {
        return [];
      }
      return [];
    }
  };
  }
  const repository = createRepository(projects);
  const bidRepository = createRepository(bids);
  const orderRepository = createRepository(orders);
  const authorizationRepository = createRepository(authorizations);
  const exitCaseRepository = createRepository(exitCases);
  const repositoryByEntityName = new Map([
    [ProjectEntity.name, repository],
    [BidEntity.name, bidRepository],
    [ProjectOrderEntity.name, orderRepository],
    [PlatformServiceFeeAuthorizationEntity.name, authorizationRepository],
    [ProjectExitCaseEntity.name, exitCaseRepository]
  ]);
  const dataSource = {
    async transaction(callback) {
      return callback({
        getRepository(entity) {
          return repositoryByEntityName.get(entity?.name) ?? repository;
        }
      });
    }
  };

  const legacyRepository = {
    items: projects,
    async save(value) {
      return repository.save(value);
    },
    async find(options = {}) {
      const where = options.where ?? {};
      return projects
        .filter((project) => {
          if (where.organizationId && project.organizationId !== where.organizationId) {
            return false;
          }
          return true;
        })
        .sort((left, right) => {
          const leftPublished = left.publishedAt instanceof Date ? left.publishedAt.getTime() : 0;
          const rightPublished = right.publishedAt instanceof Date ? right.publishedAt.getTime() : 0;
          if (leftPublished !== rightPublished) {
            return rightPublished - leftPublished;
          }
          return right.createdAt.getTime() - left.createdAt.getTime();
        });
    },
    async findOneBy(where) {
      return (
        projects.find((project) => {
          if (where.id && project.id !== where.id) {
            return false;
          }
          if (where.organizationId && project.organizationId !== where.organizationId) {
            return false;
          }
          return true;
        }) ?? null
      );
    },
    async findOne(options) {
      const where = options?.where ?? {};
      return (
        projects.find((project) => {
          if (where.id && project.id !== where.id) {
            return false;
          }
          return true;
        }) ?? null
      );
    },
    async query(sql) {
      if (sql.includes('from public.projects')) {
        return [];
      }
      return [];
    }
  };

  const verificationService = {
    async verifyCurrentSessionContext(context) {
      const organizationId = context.organizationId || 'buyer-org';
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: organizationId === 'supplier-org' ? 'supplier-user' : 'user-1',
          userId: organizationId === 'supplier-org' ? 'supplier-user' : 'user-1',
          organizationId,
          requestId: context.requestId,
          traceId: context.traceId
        }
      };
    }
  };

  const eligibilityService = {
    async requireProjectPublishEligibilityFromContext(context, resolver) {
      const verified = await resolver.verifyCurrentSessionContext(context);
      return {
        currentSession: verified.currentSession,
        scope: this.scopeForOrganization(verified.currentSession.organizationId ?? 'buyer-org')
      };
    },
    async requireAuthenticatedActor() {
      return { id: 'user-1', status: 'active' };
    },
    async getCurrentOrganizationScope(currentSession) {
      return this.scopeForOrganization(currentSession.organizationId ?? 'buyer-org');
    },
    scopeForOrganization(organizationId) {
      return {
        organization: {
          id: organizationId,
          organizationType: organizationId === 'supplier-org' ? 'supplier' : 'buyer'
        },
        membership: { roleKey: organizationId === 'supplier-org' ? 'supplier_admin' : 'buyer_admin' },
        certification: { certificationStatus: 'approved' },
        personalCertification: { certificationStatus: 'approved' },
        roleKeys: [organizationId === 'supplier-org' ? 'supplier_admin' : 'buyer_admin']
      };
    }
  };

  const presenter = new ProjectPresenter();

  return {
    projects,
    bids,
    orders,
    authorizations,
    exitCases,
    auditLogs,
    lifecycleService: new ProjectLifecycleService(
      legacyRepository,
      dataSource,
      presenter,
      {
        async record(entry) {
          auditLogs.push(entry);
        }
      },
      verificationService,
      eligibilityService
    ),
    exitGovernanceService: new ProjectExitGovernanceService(
      repository,
      bidRepository,
      orderRepository,
      authorizationRepository,
      exitCaseRepository,
      dataSource,
      {
        async record(entry) {
          auditLogs.push(entry);
        }
      },
      verificationService,
      eligibilityService
    ),
    publicQueryService: new ProjectQueryService(
      legacyRepository,
      verificationService,
      eligibilityService,
      presenter
    ),
    myProjectQueryService: new MyProjectQueryService(
      legacyRepository,
      verificationService,
      eligibilityService,
      new MyProjectPresenter(presenter)
    )
  };
}

test('project lifecycle correction materializes submitted withdraw back to draft with audit', async () => {
  const harness = createHarness();
  harness.projects.push(createProject('project-withdraw'));

  const accepted = await harness.lifecycleService.withdrawProject(
    { projectId: 'project-withdraw' },
    createContext('project-withdraw')
  );

  assert.deepEqual(accepted, { projectId: 'project-withdraw', state: 'draft' });
  assert.equal(harness.projects[0].state, 'draft');
  assert.equal(harness.projects[0].publishedAt, null);
  assert.equal(harness.auditLogs.at(-1)?.eventType, 'project_withdrawn_to_draft');
});

test('project exit governance withdraws published project back to submitted without dropping bids', async () => {
  const harness = createHarness();
  harness.projects.push(
    createProject('project-withdraw-published', {
      state: 'published',
      publishedAt: new Date('2026-04-13T09:00:00.000Z')
    })
  );
  harness.bids.push({
    id: 'bid-1',
    projectId: 'project-withdraw-published',
    state: 'submitted',
    createdAt: new Date('2026-04-13T10:00:00.000Z')
  });

  const accepted = await harness.exitGovernanceService.withdrawPublishedProject(
    { projectId: 'project-withdraw-published', reasonCode: 'content_needs_revision' },
    createContext('project-withdraw-published')
  );

  assert.equal(accepted.state, 'submitted');
  assert.equal(accepted.action, 'withdraw_published_to_submitted');
  assert.equal(accepted.affectedBidCount, 1);
  assert.equal(harness.projects[0].state, 'submitted');
  assert.equal(harness.projects[0].publishedAt, null);
  assert.equal(harness.bids[0].state, 'submitted');
  assert.equal(harness.exitCases[0].exitType, 'published_withdrawal');
  assert.equal(harness.auditLogs.at(-1)?.eventType, 'project_published_withdrawn_to_submitted');
});

test('project exit governance cancels uninitialized pending authorization on published withdrawal', async () => {
  const harness = createHarness();
  harness.projects.push(
    createProject('project-withdraw-pending-auth', {
      state: 'published',
      publishedAt: new Date('2026-04-13T09:00:00.000Z')
    })
  );
  harness.authorizations.push({
    id: 'auth-pending-1',
    taskId: 'project-withdraw-pending-auth',
    bidId: 'bid-1',
    status: 'pending_authorization',
    paymentOrderId: null,
    authorizationOrderId: null,
    authorizedAt: null,
    releasedAt: null,
    chargedAt: null
  });

  const accepted = await harness.exitGovernanceService.withdrawPublishedProject(
    { projectId: 'project-withdraw-pending-auth', reasonCode: 'content_needs_revision' },
    createContext('project-withdraw-pending-auth')
  );

  assert.equal(accepted.state, 'submitted');
  assert.equal(accepted.cancelledPendingAuthorizationCount, 1);
  assert.equal(harness.projects[0].state, 'submitted');
  assert.equal(harness.authorizations[0].status, 'cancelled');
  assert.deepEqual(harness.auditLogs.at(-1)?.payload.cancelledPendingAuthorizationIds, ['auth-pending-1']);
});

test('project exit governance fail-closes active and authorized projects on published withdrawal', async () => {
  const activeHarness = createHarness();
  activeHarness.projects.push(
    createProject('project-active', {
      state: 'converted_to_order',
      publishedAt: new Date('2026-04-13T09:00:00.000Z')
    })
  );

  await assert.rejects(
    () => activeHarness.exitGovernanceService.withdrawPublishedProject(
      { projectId: 'project-active' },
      createContext('project-active')
    ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_EXIT_INVALID_STATE');
      return true;
    }
  );

  const authHarness = createHarness();
  authHarness.projects.push(
    createProject('project-auth', {
      state: 'published',
      publishedAt: new Date('2026-04-13T09:00:00.000Z')
    })
  );
  authHarness.authorizations.push({
    id: 'auth-1',
    taskId: 'project-auth',
    bidId: 'bid-1',
    status: 'authorized'
  });

  await assert.rejects(
    () => authHarness.exitGovernanceService.withdrawPublishedProject(
      { projectId: 'project-auth' },
      createContext('project-auth')
    ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_EXIT_INVALID_STATE');
      assert.equal(authHarness.projects[0].state, 'published');
      return true;
    }
  );
});

test('project exit governance discards submitted project into archived with exit case', async () => {
  const harness = createHarness();
  harness.projects.push(createProject('project-discard'));

  const accepted = await harness.exitGovernanceService.discardSubmittedProject(
    { projectId: 'project-discard', reasonCode: 'no_longer_needed' },
    createContext('project-discard')
  );

  assert.equal(accepted.state, 'archived');
  assert.equal(accepted.action, 'discard_submitted');
  assert.equal(harness.projects[0].state, 'archived');
  assert.equal(harness.exitCases[0].exitType, 'submitted_discard');
  assert.equal(harness.auditLogs.at(-1)?.eventType, 'project_submitted_discarded');
});

test('project exit governance accepts cancellation by closing order and returning project to submitted', async () => {
  const harness = createHarness();
  harness.projects.push(createProject('project-cancel', { state: 'converted_to_order' }));
  harness.orders.push({
    id: 'order-1',
    projectId: 'project-cancel',
    buyerOrganizationId: 'buyer-org',
    sellerOrganizationId: 'supplier-org',
    state: 'active'
  });

  const requested = await harness.exitGovernanceService.requestCancellation(
    {
      projectId: 'project-cancel',
      orderId: 'order-1',
      reasonCode: 'mutual_change',
      noAutomaticPenaltyConfirmed: true
    },
    createContext('project-cancel-request')
  );

  assert.equal(requested.caseStatus, 'requested');
  assert.equal(requested.projectState, 'converted_to_order');
  assert.equal(harness.projects[0].state, 'converted_to_order');

  const responded = await harness.exitGovernanceService.respondCancellation(
    {
      projectId: 'project-cancel',
      exitCaseId: requested.exitCaseId,
      decision: 'accept',
      noAutomaticPenaltyConfirmed: true
    },
    createContext('project-cancel-respond', 'Bearer lifecycle', 'supplier-org')
  );

  assert.equal(responded.caseStatus, 'accepted');
  assert.equal(responded.projectState, 'submitted');
  assert.equal(responded.orderState, 'cancelled');
  assert.equal(harness.projects[0].state, 'submitted');
  assert.equal(harness.projects[0].publishedAt, null);
  assert.equal(harness.orders[0].state, 'cancelled');
  assert.equal(harness.exitCases[0].status, 'accepted');
  assert.equal(harness.auditLogs.at(-1)?.payload.previousProjectState, 'converted_to_order');
  assert.equal(harness.auditLogs.at(-1)?.payload.nextProjectState, 'submitted');
  assert.equal(harness.auditLogs.at(-1)?.payload.previousOrderState, 'active');
  assert.equal(harness.auditLogs.at(-1)?.payload.nextOrderState, 'cancelled');
});

test('project exit governance rejects cancellation without closing project or order', async () => {
  const harness = createHarness();
  harness.projects.push(createProject('project-cancel-reject', { state: 'converted_to_order' }));
  harness.orders.push({
    id: 'order-1',
    projectId: 'project-cancel-reject',
    buyerOrganizationId: 'buyer-org',
    sellerOrganizationId: 'supplier-org',
    state: 'active'
  });

  const requested = await harness.exitGovernanceService.requestCancellation(
    {
      projectId: 'project-cancel-reject',
      orderId: 'order-1',
      reasonCode: 'mutual_change',
      noAutomaticPenaltyConfirmed: true
    },
    createContext('project-cancel-reject-request')
  );

  const responded = await harness.exitGovernanceService.respondCancellation(
    {
      projectId: 'project-cancel-reject',
      exitCaseId: requested.exitCaseId,
      decision: 'reject',
      noAutomaticPenaltyConfirmed: true
    },
    createContext('project-cancel-reject-respond', 'Bearer lifecycle', 'supplier-org')
  );

  assert.equal(responded.caseStatus, 'rejected');
  assert.equal(responded.projectState, 'converted_to_order');
  assert.equal(harness.projects[0].state, 'converted_to_order');
  assert.equal(harness.orders[0].state, 'active');
  assert.equal(harness.exitCases[0].status, 'rejected');
});

test('project exit governance records breach as credit candidate without money action', async () => {
  const harness = createHarness();
  harness.projects.push(createProject('project-breach', { state: 'converted_to_order' }));
  harness.orders.push({
    id: 'order-1',
    projectId: 'project-breach',
    buyerOrganizationId: 'buyer-org',
    sellerOrganizationId: 'supplier-org',
    state: 'active'
  });

  const accepted = await harness.exitGovernanceService.recordFactoryBreach(
    {
      projectId: 'project-breach',
      orderId: 'order-1',
      reasonCode: 'factory_refused_fulfillment',
      noAutomaticPenaltyConfirmed: true
    },
    createContext('project-breach')
  );

  assert.equal(accepted.caseStatus, 'recorded');
  assert.equal(accepted.creditImpactCandidate, true);
  assert.equal(harness.exitCases[0].creditImpactCandidate, true);
  assert.equal(harness.exitCases[0].noAutomaticPenaltyConfirmed, true);
  assert.equal(harness.projects[0].state, 'converted_to_order');
  assert.equal(harness.auditLogs.at(-1)?.eventType, 'project_factory_breach_recorded');
});

test('project lifecycle correction materializes submitted archive into owner historical bucket', async () => {
  const harness = createHarness();
  harness.projects.push(createProject('project-archive'));

  const accepted = await harness.lifecycleService.archiveProject(
    { projectId: 'project-archive' },
    createContext('project-archive')
  );
  const myProjects = await harness.myProjectQueryService.listProjects(
    createContext('my-project-list')
  );
  const archivedDetail = await harness.myProjectQueryService.getProjectById(
    'project-archive',
    createContext('my-project-detail')
  );

  assert.deepEqual(accepted, { projectId: 'project-archive', state: 'archived' });
  assert.equal(myProjects.ongoingProjects.length, 0);
  assert.equal(myProjects.historicalProjects.length, 1);
  assert.equal(myProjects.historicalProjects[0].publicProject.projectId, 'project-archive');
  assert.equal(archivedDetail.publicProject.state, 'archived');
  assert.equal(harness.auditLogs.at(-1)?.eventType, 'project_archived');
});

test('project lifecycle correction closes published project into archived and removes public visibility only', async () => {
  const harness = createHarness();
  harness.projects.push(
    createProject('project-close', {
      state: 'published',
      publishedAt: new Date('2026-04-13T09:00:00.000Z'),
      summary: {
        heading: '项目已进入最小发布走廊。',
        stateLabel: '当前项目已发布，可继续进入最小竞标继续面。'
      }
    })
  );

  const accepted = await harness.lifecycleService.closeProject(
    { projectId: 'project-close' },
    createContext('project-close')
  );

  await assert.rejects(
    () => harness.publicQueryService.getProjectById('project-close', createContext('public-detail', '')),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_RESOURCE_UNAVAILABLE');
      return true;
    }
  );

  const ownerDetail = await harness.myProjectQueryService.getProjectById(
    'project-close',
    createContext('owner-detail')
  );

  assert.deepEqual(accepted, { projectId: 'project-close', state: 'archived' });
  assert.equal(ownerDetail.publicProject.projectId, 'project-close');
  assert.equal(ownerDetail.publicProject.state, 'archived');
  assert.equal(harness.auditLogs.at(-1)?.eventType, 'project_closed');
});

test('project lifecycle correction keeps awarded and converted_to_order on business close boundary only', async () => {
  const harness = createHarness();
  harness.projects.push(
    createProject('project-awarded', {
      state: 'converted_to_order',
      publishedAt: new Date('2026-04-13T09:00:00.000Z')
    })
  );

  await assert.rejects(
    () => harness.lifecycleService.closeProject(
      { projectId: 'project-awarded' },
      createContext('project-close-converted')
    ),
    (error) => {
      assert.equal(error?.response?.code, 'PROJECT_INVALID_STATE');
      return true;
    }
  );
});
