const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId) {
  return {
    authorization: 'Bearer transport-carrier',
    actorId: '',
    userId: '',
    organizationId: '',
    actorRole: '',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

function createProjectPayload() {
  return {
    title: '春季品牌展项目',
    buildingType: 'exhibition',
    budgetAmount: 120000,
    provinceCode: '310000',
    provinceName: '上海市',
    cityCode: '310100',
    cityName: '上海市',
    detailAddress: '浦东新区龙阳路 1 号',
    scopeSummary: '主场展位搭建与灯光优化',
  };
}

function createEligibilityService(overrides = {}) {
  const {
    CurrentActorEligibilityService,
  } = require('../dist/modules/organization/current-actor-eligibility.service.js');

  const userRepository = {
    async findOneBy() {
      return { id: 'user-1', status: 'active' };
    },
  };
  const organizationRepository = {
    async findOneBy() {
      return { id: 'buyer-org', organizationType: 'buyer', lifecycleStatus: 'active' };
    },
  };
  const organizationMemberRepository = {
    async findOneBy() {
      return {
        organizationId: 'buyer-org',
        userId: 'user-1',
        memberStatus: 'active',
        roleKey: 'buyer_admin',
      };
    },
    async find() {
      return [];
    },
  };
  const organizationCertificationRepository = {
    async findOne() {
      return {
        organizationId: 'buyer-org',
        certificationStatus: 'approved',
        legalName: '测试企业',
        uscc: '91310000TEST00001',
        licenseFileId: 'file-license',
        submittedAt: new Date('2026-04-10T08:00:00.000Z'),
        reviewedAt: new Date('2026-04-10T09:00:00.000Z'),
        reviewedBy: 'reviewer-1',
        rejectReason: null,
        expiresAt: null,
        updatedAt: new Date('2026-04-10T09:00:00.000Z'),
      };
    },
  };
  const personalCertificationRepository = {
    async findOne() {
      return null;
    },
  };

  if (overrides.userRepository) {
    Object.assign(userRepository, overrides.userRepository);
  }
  if (overrides.organizationRepository) {
    Object.assign(organizationRepository, overrides.organizationRepository);
  }
  if (overrides.organizationMemberRepository) {
    Object.assign(organizationMemberRepository, overrides.organizationMemberRepository);
  }
  if (overrides.organizationCertificationRepository) {
    Object.assign(
      organizationCertificationRepository,
      overrides.organizationCertificationRepository,
    );
  }
  if (overrides.personalCertificationRepository) {
    Object.assign(personalCertificationRepository, overrides.personalCertificationRepository);
  }

  return new CurrentActorEligibilityService(
    userRepository,
    organizationRepository,
    organizationMemberRepository,
    organizationCertificationRepository,
    personalCertificationRepository,
  );
}

test('Server P0-1 eligibility truth allows approved both subject without buyer-role hard block', async () => {
  const approvedBuyerService = createEligibilityService();
  const approvedScope = await approvedBuyerService.requireProjectPublishEligibility({
    sessionId: 'session-1',
    actorId: 'user-1',
    userId: 'user-1',
    organizationId: 'buyer-org',
    requestId: 'eligibility-approved',
    traceId: 'trace-eligibility-approved',
  });
  assert.equal(approvedScope.organization.id, 'buyer-org');
  assert.equal(approvedScope.membership.roleKey, 'buyer_admin');
  assert.equal(approvedScope.certification.certificationStatus, 'approved');

  const pendingCertificationService = createEligibilityService({
    organizationCertificationRepository: {
      async findOne() {
        return {
          organizationId: 'buyer-org',
          certificationStatus: 'pending_review',
          legalName: '测试企业',
          uscc: '91310000TEST00001',
          licenseFileId: 'file-license',
          submittedAt: new Date('2026-04-10T08:00:00.000Z'),
          reviewedAt: null,
          reviewedBy: null,
          rejectReason: null,
          expiresAt: null,
          updatedAt: new Date('2026-04-10T08:00:00.000Z'),
        };
      },
    },
  });
  await assert.rejects(
    () =>
      pendingCertificationService.requireProjectPublishEligibility({
        sessionId: 'session-2',
        actorId: 'user-1',
        userId: 'user-1',
        organizationId: 'buyer-org',
        requestId: 'eligibility-pending',
        traceId: 'trace-eligibility-pending',
      }),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(
        error?.response?.details?.reason,
        'certification_not_approved',
      );
      assert.equal(
        error?.response?.details?.certificationStatus,
        'pending_review',
      );
      return true;
    },
  );

  const supplierRoleService = createEligibilityService({
    organizationMemberRepository: {
      async findOneBy() {
        return {
          organizationId: 'buyer-org',
          userId: 'user-1',
          memberStatus: 'active',
          roleKey: 'supplier_admin',
        };
      },
    },
  });
  await assert.rejects(
    () =>
      supplierRoleService.requireProjectPublishEligibility({
        sessionId: 'session-3',
        actorId: 'user-1',
        userId: 'user-1',
        organizationId: 'buyer-org',
        requestId: 'eligibility-supplier',
        traceId: 'trace-eligibility-supplier',
      }),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(error?.response?.details?.reason, 'buyer_role_not_allowed');
      return true;
    },
  );

  const bothSupplierRoleService = createEligibilityService({
    organizationRepository: {
      async findOneBy() {
        return { id: 'buyer-org', organizationType: 'both', lifecycleStatus: 'active' };
      },
    },
    organizationMemberRepository: {
      async findOneBy() {
        return {
          organizationId: 'buyer-org',
          userId: 'user-1',
          memberStatus: 'active',
          roleKey: 'supplier_admin',
        };
      },
    },
  });
  const bothScope = await bothSupplierRoleService.requireProjectPublishEligibility({
    sessionId: 'session-3b',
    actorId: 'user-1',
    userId: 'user-1',
    organizationId: 'buyer-org',
    requestId: 'eligibility-both-supplier-role',
    traceId: 'trace-eligibility-both-supplier-role',
  });
  assert.equal(bothScope.organization.organizationType, 'both');
  assert.equal(bothScope.membership.roleKey, 'supplier_admin');

  const supplierOnlyService = createEligibilityService({
    organizationRepository: {
      async findOneBy() {
        return { id: 'buyer-org', organizationType: 'supplier', lifecycleStatus: 'active' };
      },
    },
    organizationMemberRepository: {
      async findOneBy() {
        return {
          organizationId: 'buyer-org',
          userId: 'user-1',
          memberStatus: 'active',
          roleKey: 'supplier_admin',
        };
      },
    },
  });
  await assert.rejects(
    () =>
      supplierOnlyService.requireProjectPublishEligibility({
        sessionId: 'session-3c',
        actorId: 'user-1',
        userId: 'user-1',
        organizationId: 'buyer-org',
        requestId: 'eligibility-supplier-only',
        traceId: 'trace-eligibility-supplier-only',
      }),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(
        error?.response?.details?.reason,
        'organization_type_not_allowed',
      );
      return true;
    },
  );
});

test('Server P0-1 eligibility truth returns structured organization scope missing reason', async () => {
  const missingScopeService = createEligibilityService();

  await assert.rejects(
    () =>
      missingScopeService.requireProjectPublishEligibility({
        sessionId: 'session-4',
        actorId: 'user-1',
        userId: 'user-1',
        organizationId: null,
        requestId: 'eligibility-no-scope',
        traceId: 'trace-eligibility-no-scope',
      }),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(
        error?.response?.details?.reason,
        'organization_scope_missing',
      );
      return true;
    },
  );
});

test('Server P0-1 ProjectWriteService consumes a single publish-eligibility conclusion from the policy layer', async () => {
  const { ProjectWriteService } = require('../dist/modules/project/project-write.service.js');

  const savedProjects = [];
  const auditCalls = [];
  const verifiedSession = {
    sessionId: 'session-1',
    actorId: 'user-1',
    userId: 'user-1',
    organizationId: 'buyer-org-approved',
    requestId: 'project-create',
    traceId: 'trace-project-create',
  };
  const eligibilityCalls = [];
  const eligibilityScope = {
    organization: { id: 'buyer-org-approved' },
    membership: { roleKey: 'buyer_admin' },
    certification: { certificationStatus: 'approved' },
    roleKeys: ['buyer_admin'],
  };

  const service = new ProjectWriteService(
    {
      create(input) {
        return input;
      },
    },
    {
      async transaction(callback) {
        return callback({
          getRepository() {
            return {
              async save(value) {
                savedProjects.push(value);
                return value;
              },
            };
          },
        });
      },
    },
    {
      toAcceptedResponse(projectId, state) {
        return { projectId, state };
      },
    },
    {
      async record(payload, auditContext) {
        auditCalls.push([payload, auditContext]);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            ...verifiedSession,
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireProjectPublishEligibilityFromContext(context, resolver) {
        const verified = await resolver.verifyCurrentSessionContext(context);
        eligibilityCalls.push(verified.currentSession);
        return {
          currentSession: verified.currentSession,
          scope: eligibilityScope,
        };
      },
    },
    {
      async requireProjectPublishGate() {
        throw new Error('publish gate should not be checked while creating project');
      },
    },
  );

  const result = await service.createProject(
    createProjectPayload(),
    createContext('project-create'),
  );

  assert.equal(eligibilityCalls.length, 1);
  assert.deepEqual(eligibilityCalls[0], verifiedSession);
  assert.equal(savedProjects.length, 1);
  assert.equal(savedProjects[0].organizationId, 'buyer-org-approved');
  assert.equal(savedProjects[0].creatorUserId, 'user-1');
  assert.equal(savedProjects[0].creatorActorId, 'user-1');
  assert.equal(savedProjects[0].exhibitionName, null);
  assert.equal(savedProjects[0].brandName, null);
  assert.equal(savedProjects[0].state, 'draft');
  assert.equal(savedProjects[0].publishedAt, null);
  assert.equal(auditCalls.length, 1);
  assert.equal(auditCalls[0][1].organizationId, 'buyer-org-approved');
  assert.deepEqual(result, { projectId: savedProjects[0].id, state: 'draft' });
});

test('Server P0-1 ProjectWriteService persists dual-field naming truth while keeping compatibility title', async () => {
  const { ProjectWriteService } = require('../dist/modules/project/project-write.service.js');

  const savedProjects = [];
  const auditCalls = [];

  const service = new ProjectWriteService(
    {
      create(input) {
        return input;
      },
    },
    {
      async transaction(callback) {
        return callback({
          getRepository() {
            return {
              async save(value) {
                savedProjects.push(value);
                return value;
              },
            };
          },
        });
      },
    },
    {
      toAcceptedResponse(projectId, state) {
        return { projectId, state };
      },
    },
    {
      async record(payload) {
        auditCalls.push(payload);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org-approved',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireProjectPublishEligibilityFromContext(context, resolver) {
        const verified = await resolver.verifyCurrentSessionContext(context);
        return {
          currentSession: verified.currentSession,
          scope: {
            organization: { id: 'buyer-org-approved' },
            membership: { roleKey: 'buyer_admin' },
            certification: { certificationStatus: 'approved' },
            roleKeys: ['buyer_admin'],
          },
        };
      },
    },
    {
      async requireProjectPublishGate() {
        throw new Error('publish gate should not be checked while creating project');
      },
    },
  );

  const result = await service.createProject(
    {
      exhibitionName: '中国建博会',
      brandName: '木作品牌A',
      buildingType: 'exhibition',
      budgetAmount: 120000,
      provinceCode: '310000',
      provinceName: '上海市',
      cityCode: '310100',
      cityName: '上海市',
      detailAddress: '浦东新区龙阳路 1 号',
      scopeSummary: '主场展位搭建与灯光优化',
    },
    createContext('project-create-dual'),
  );

  assert.equal(savedProjects.length, 1);
  assert.equal(savedProjects[0].exhibitionName, '中国建博会');
  assert.equal(savedProjects[0].brandName, '木作品牌A');
  assert.equal(savedProjects[0].title, '中国建博会 / 木作品牌A');
  assert.equal(savedProjects[0].state, 'draft');
  assert.equal(savedProjects[0].publishedAt, null);
  assert.equal(auditCalls[0].payload.exhibitionName, '中国建博会');
  assert.equal(auditCalls[0].payload.brandName, '木作品牌A');
  assert.deepEqual(result, { projectId: savedProjects[0].id, state: 'draft' });
});

test('Server P0-1b shell projectCreateEligibility stays aligned with the same publish eligibility truth', async () => {
  const { ShellQueryService } = require('../dist/modules/shell/shell-query.service.js');
  const eligibilityService = createEligibilityService();
  const scopePending = {
    organization: { id: 'buyer-org', organizationType: 'buyer' },
    membership: { roleKey: 'buyer_admin', memberStatus: 'active' },
    certification: { certificationStatus: 'pending_review' },
    roleKeys: ['buyer_admin'],
  };
  const scopeApproved = {
    ...scopePending,
    certification: { certificationStatus: 'approved' },
  };
  const scopeSupplier = {
    organization: { id: 'buyer-org', organizationType: 'buyer' },
    membership: { roleKey: 'supplier_admin', memberStatus: 'active' },
    certification: { certificationStatus: 'approved' },
    roleKeys: ['supplier_admin'],
  };
  const scopeBothSupplier = {
    organization: { id: 'both-org', organizationType: 'both' },
    membership: { roleKey: 'supplier_admin', memberStatus: 'active' },
    certification: { certificationStatus: 'approved' },
    roleKeys: ['supplier_admin'],
  };
  const scopeSupplierOnly = {
    organization: { id: 'supplier-org', organizationType: 'supplier' },
    membership: { roleKey: 'supplier_admin', memberStatus: 'active' },
    certification: { certificationStatus: 'approved' },
    roleKeys: ['supplier_admin'],
  };

  const buildService = (scope) =>
    new ShellQueryService(
      {
        async verifyCurrentSessionContext(context) {
          return {
            outcome: 'verified',
            currentSession: {
              sessionId: 'session-shell',
              actorId: 'user-1',
              userId: 'user-1',
              organizationId: 'buyer-org',
              requestId: context.requestId,
              traceId: context.traceId,
            },
          };
        },
      },
      {
        async requireAuthenticatedActor() {
          return {
            id: 'user-1',
            mobile: '13800138000',
            nickname: null,
            avatarUrl: null,
            status: 'active',
            profileIntro: null,
          };
        },
        async getCurrentOrganizationScope() {
          return scope;
        },
        canPublishProjectInScope(value) {
          return eligibilityService.canPublishProjectInScope(value);
        },
      },
      {
        async getShellSummaryProjection() {
          return {
            paidMembershipTier: null,
            paidMembershipEntitlementsSummary: [],
            paidMembershipQuotaSummary: [],
            paidMembershipNextRefreshAt: null,
          };
        },
      },
      {
        getShellContextProjection() {
          return {
            profileCorridorKey: 'my_building_compact_current_user_hub',
            profileEntryOrderBucket: 'my_building_compact_hub_first_level',
            visibleFamilyKeys: ['exhibition', 'messages', 'profile'],
            orderingReferenceVersion: '1',
            updatedAt: new Date('2026-04-01T00:00:00.000Z'),
            regrouping: {
              regroupingKey: 'my_building_compact_current_user_hub',
              regroupingVisibilityStatus: 'visible',
              regroupingExplanationKey: 'my_building_bounded_private_regrouping',
              updatedAt: new Date('2026-04-01T00:00:00.000Z'),
            },
            entryOrder: {
              entryOrderKey: 'my_building_compact_hub_first_level',
              entryVisibilityStatus: 'visible',
              entryPriorityBucket: 'primary',
              orderingExplanationKey: 'my_building_bounded_private_regrouping',
              updatedAt: new Date('2026-04-01T00:00:00.000Z'),
            },
            corridor: {
              corridorKey: 'profile',
              corridorVisibilityStatus: 'visible',
              corridorExplanationKey: 'my_building_bounded_private_regrouping',
              corridorTargetFamily: 'profile',
              updatedAt: new Date('2026-04-01T00:00:00.000Z'),
            },
            familyPresence: [],
            navigationExplanation: {
              navigationExplanationKey: 'nav',
              regroupingExplanationKey: 'regroup',
              orderingExplanationKey: 'order',
              corridorExplanationKey: 'corridor',
              dependencyExplanationKey: 'dependency',
            },
            dependencyReference: {
              dependencyRequired: false,
              dependencyFamilyKey: 'profile',
              dependencyExplanationKey: 'dependency',
              dependencyHandoffKey: 'profile',
            },
          };
        },
      },
      {
        async buildAccessUrlFromObjectUrl() {
          return null;
        },
      },
      {
        toContext(input) {
          return input;
        },
      },
    );

  const pendingContext = await buildService(scopePending).getContext(
    createContext('shell-pending'),
  );
  assert.equal(pendingContext.projectCreateEligibility.canCreateProject, false);

  const approvedContext = await buildService(scopeApproved).getContext(
    createContext('shell-approved'),
  );
  assert.equal(approvedContext.projectCreateEligibility.canCreateProject, true);

  const supplierContext = await buildService(scopeSupplier).getContext(
    createContext('shell-supplier'),
  );
  assert.equal(supplierContext.projectCreateEligibility.canCreateProject, false);

  const bothSupplierContext = await buildService(scopeBothSupplier).getContext(
    createContext('shell-both-supplier'),
  );
  assert.equal(bothSupplierContext.projectCreateEligibility.canCreateProject, true);

  const supplierOnlyContext = await buildService(scopeSupplierOnly).getContext(
    createContext('shell-supplier-only'),
  );
  assert.equal(supplierOnlyContext.projectCreateEligibility.canCreateProject, false);
});

test('Server P0-3 milestone submit shell accepts only the current milestone anchor', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const service = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.milestones milestone')) {
          return [
            {
              milestoneId: 'milestone-1',
              orderId: 'order-1',
              state: 'pending_submission',
              orderState: 'active',
            },
          ];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  const result = await service.submitMilestone(
    {
      milestoneId: 'milestone-1',
      submissionNote: 'phase 2 shell handoff',
    },
    createContext('shell-milestone-submit'),
  );

  assert.deepEqual(result, { milestoneId: 'milestone-1' });
});

test('Server P0-3 inspection submit shell echoes current inspection anchor without state advancement', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const service = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.inspections inspection')) {
          return [
            {
              inspectionId: 'inspection-1',
              milestoneId: 'milestone-1',
              orderId: 'order-1',
              state: 'draft',
              orderState: 'active',
            },
          ];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  const result = await service.submitInspection(
    { inspectionId: 'inspection-1' },
    createContext('shell-inspection-submit'),
  );

  assert.equal(result.inspectionId, 'inspection-1');
  assert.equal(result.milestoneId, 'milestone-1');
  assert.equal(result.state, 'draft');
  assert.equal(
    result.summary.heading,
    '当前验收提交入口已受理，后续仍以验收详情真值为准。',
  );
});

test('Server E3 inspection recheck shell advances submitted to rechecked only', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const executedUpdates = [];
  const service = new TradingShellHandoffService(
    {
      async query(sql, params) {
        if (sql.includes('from public.inspections inspection')) {
          return [
            {
              inspectionId: 'inspection-1',
              milestoneId: 'milestone-1',
              orderId: 'order-1',
              state: 'submitted',
              orderState: 'active',
            },
          ];
        }
        if (sql.includes('update public.inspections')) {
          executedUpdates.push({ sql, params });
          return [];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  const result = await service.recheckInspection(
    { inspectionId: 'inspection-1' },
    createContext('shell-inspection-recheck'),
  );

  assert.deepEqual(result, {
    inspectionId: 'inspection-1',
    milestoneId: 'milestone-1',
    state: 'rechecked',
    summary: {
      heading: '当前验收复检已受理，后续仍以验收详情真值为准。',
    },
  });
  assert.equal(executedUpdates.length, 1);
  assert.deepEqual(executedUpdates[0].params, ['inspection-1', 'rechecked']);
});

test('Server E3 inspection recheck shell rejects invalid payload with stable code', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const service = new TradingShellHandoffService(
    {
      async query() {
        throw new Error('Inspection query should not run for invalid payload.');
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () => service.recheckInspection({}, createContext('shell-inspection-recheck-invalid')),
    (error) => {
      assert.equal(error?.response?.code, 'INSPECTION_RECHECK_INVALID');
      return true;
    },
  );
});

test('Server E3 inspection recheck shell fail-closes unavailable carriers and illegal states', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const unavailableService = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.inspections inspection')) {
          return [];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () =>
      unavailableService.recheckInspection(
        { inspectionId: 'inspection-missing' },
        createContext('shell-inspection-recheck-unavailable'),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'INSPECTION_ENTRY_UNAVAILABLE');
      return true;
    },
  );

  const invalidStateService = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.inspections inspection')) {
          return [
            {
              inspectionId: 'inspection-2',
              milestoneId: 'milestone-2',
              orderId: 'order-2',
              state: 'draft',
              orderState: 'active',
            },
          ];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () =>
      invalidStateService.recheckInspection(
        { inspectionId: 'inspection-2' },
        createContext('shell-inspection-recheck-illegal-state'),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'INSPECTION_INVALID_STATE');
      return true;
    },
  );
});

test('Server P0-3 inspection submit shell rejects invalid payload with stable code', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const service = new TradingShellHandoffService(
    {
      async query() {
        throw new Error('Inspection query should not run for invalid payload.');
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () => service.submitInspection({}, createContext('shell-inspection-submit-invalid')),
    (error) => {
      assert.equal(error?.response?.code, 'INSPECTION_SUBMIT_INVALID');
      return true;
    },
  );
});

test('Server E1 contract confirm shell advances pending_confirm to active only', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const executedUpdates = [];
  const service = new TradingShellHandoffService(
    {
      async query(sql, params) {
        if (sql.includes('from public.contracts contract')) {
          return [
            {
              contractId: 'contract-1',
              orderId: 'order-1',
              state: 'pending_confirm',
              orderState: 'active',
            },
          ];
        }
        if (sql.includes('update public.contracts')) {
          executedUpdates.push({ sql, params });
          return [];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  const result = await service.confirmContract(
    { orderId: 'order-1' },
    createContext('shell-contract-confirm'),
  );

  assert.deepEqual(result, {
    contractId: 'contract-1',
    orderId: 'order-1',
    state: 'active',
    summary: {
      heading: '当前合同确认已受理，后续仍以合同详情真值为准。',
    },
  });
  assert.equal(executedUpdates.length, 1);
  assert.deepEqual(executedUpdates[0].params, ['contract-1', 'active']);
});

test('Server E1 contract confirm shell rejects invalid payload with stable code', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const service = new TradingShellHandoffService(
    {
      async query() {
        throw new Error('Contract query should not run for invalid payload.');
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () => service.confirmContract({}, createContext('shell-contract-confirm-invalid')),
    (error) => {
      assert.equal(error?.response?.code, 'CONTRACT_CONFIRM_INVALID');
      return true;
    },
  );
});

test('Server E1 contract confirm shell fail-closes unavailable carriers and illegal states', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const unavailableService = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.contracts contract')) {
          return [];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () =>
      unavailableService.confirmContract(
        { orderId: 'order-missing' },
        createContext('shell-contract-confirm-unavailable'),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'CONTRACT_ENTRY_UNAVAILABLE');
      return true;
    },
  );

  const invalidStateService = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.contracts contract')) {
          return [
            {
              contractId: 'contract-2',
              orderId: 'order-2',
              state: 'active',
              orderState: 'active',
            },
          ];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () =>
      invalidStateService.confirmContract(
        { orderId: 'order-2' },
        createContext('shell-contract-confirm-illegal-state'),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'CONTRACT_INVALID_STATE');
      return true;
    },
  );
});

test('Server E2 contract amend shell advances active to amended only', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const executedUpdates = [];
  const service = new TradingShellHandoffService(
    {
      async query(sql, params) {
        if (sql.includes('from public.contracts contract')) {
          return [
            {
              contractId: 'contract-1',
              orderId: 'order-1',
              state: 'active',
              orderState: 'active',
            },
          ];
        }
        if (sql.includes('update public.contracts')) {
          executedUpdates.push({ sql, params });
          return [];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  const result = await service.amendContract(
    { orderId: 'order-1' },
    createContext('shell-contract-amend'),
  );

  assert.deepEqual(result, {
    contractId: 'contract-1',
    orderId: 'order-1',
    state: 'amended',
    summary: {
      heading: '当前合同改单已受理，后续仍以合同详情真值为准。',
    },
  });
  assert.equal(executedUpdates.length, 1);
  assert.deepEqual(executedUpdates[0].params, ['contract-1', 'amended']);
});

test('Server E2 contract amend shell rejects invalid payload with stable code', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const service = new TradingShellHandoffService(
    {
      async query() {
        throw new Error('Contract query should not run for invalid payload.');
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () => service.amendContract({}, createContext('shell-contract-amend-invalid')),
    (error) => {
      assert.equal(error?.response?.code, 'CONTRACT_AMEND_INVALID');
      return true;
    },
  );
});

test('Server E2 contract amend shell fail-closes unavailable carriers and illegal states', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const unavailableService = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.contracts contract')) {
          return [];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () =>
      unavailableService.amendContract(
        { orderId: 'order-missing' },
        createContext('shell-contract-amend-unavailable'),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'CONTRACT_ENTRY_UNAVAILABLE');
      return true;
    },
  );

  const invalidStateService = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.contracts contract')) {
          return [
            {
              contractId: 'contract-2',
              orderId: 'order-2',
              state: 'pending_confirm',
              orderState: 'active',
            },
          ];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () =>
      invalidStateService.amendContract(
        { orderId: 'order-2' },
        createContext('shell-contract-amend-illegal-state'),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'CONTRACT_INVALID_STATE');
      return true;
    },
  );
});

test('Server P0-3 inspection submit shell fail-closes unavailable inspection carriers', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const service = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.inspections inspection')) {
          return [];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () =>
      service.submitInspection(
        { inspectionId: 'inspection-missing' },
        createContext('shell-inspection-submit-unavailable'),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'INSPECTION_ENTRY_UNAVAILABLE');
      return true;
    },
  );
});

test('Server P0-3 dispute open shell accepts current order anchor without inventing dispute truth', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const service = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.orders "order"')) {
          return [
            {
              orderId: 'order-1',
              state: 'active',
            },
          ];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  const result = await service.openDispute(
    {
      orderId: 'order-1',
      reason: 'quality shell handoff',
    },
    createContext('shell-dispute-open'),
  );

  assert.deepEqual(result, {
    orderId: 'order-1',
    state: 'accepted',
    summary: {
      heading: '当前争议开启入口已受理，后续仍保持边界续接。',
    },
  });
  assert.equal(Object.prototype.hasOwnProperty.call(result, 'disputeId'), false);
});

test('Server E4 dispute withdraw shell advances opened to withdrawn only', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const executedUpdates = [];
  const service = new TradingShellHandoffService(
    {
      async query(sql, params) {
        if (sql.includes('from public.disputes dispute')) {
          return [
            {
              disputeId: 'dispute-1',
              orderId: 'order-1',
              state: 'opened',
              orderState: 'active',
            },
          ];
        }
        if (sql.includes('update public.disputes')) {
          executedUpdates.push({ sql, params });
          return [];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  const result = await service.withdrawDispute(
    { orderId: 'order-1' },
    createContext('shell-dispute-withdraw'),
  );

  assert.deepEqual(result, {
    disputeId: 'dispute-1',
    orderId: 'order-1',
    state: 'withdrawn',
    summary: {
      heading: '当前争议撤回已受理，后续仍以项目私域与工作台真值为准。',
    },
  });
  assert.equal(executedUpdates.length, 1);
  assert.deepEqual(executedUpdates[0].params, ['dispute-1', 'withdrawn']);
});

test('Server E4 dispute withdraw shell rejects invalid payload with stable code', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const service = new TradingShellHandoffService(
    {
      async query() {
        throw new Error('Dispute query should not run for invalid payload.');
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () => service.withdrawDispute({}, createContext('shell-dispute-withdraw-invalid')),
    (error) => {
      assert.equal(error?.response?.code, 'DISPUTE_WITHDRAW_INVALID');
      return true;
    },
  );
});

test('Server E4 dispute withdraw shell fail-closes unavailable carriers and illegal states', async () => {
  const {
    TradingShellHandoffService,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.service.js');
  const {
    TradingShellHandoffPresenter,
  } = require('../dist/modules/trading_shell_handoff/trading-shell-handoff.presenter.js');

  const unavailableService = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.disputes dispute')) {
          return [];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () =>
      unavailableService.withdrawDispute(
        { orderId: 'order-missing' },
        createContext('shell-dispute-withdraw-unavailable'),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'DISPUTE_INVALID_STATE');
      return true;
    },
  );

  const invalidStateService = new TradingShellHandoffService(
    {
      async query(sql) {
        if (sql.includes('from public.disputes dispute')) {
          return [
            {
              disputeId: 'dispute-2',
              orderId: 'order-2',
              state: 'withdrawn',
              orderState: 'active',
            },
          ];
        }
        throw new Error(`Unexpected SQL branch: ${sql}`);
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-shell',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'buyer-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return { organization: { id: 'buyer-org' } };
      },
    },
    new TradingShellHandoffPresenter(),
  );

  await assert.rejects(
    () =>
      invalidStateService.withdrawDispute(
        { orderId: 'order-2' },
        createContext('shell-dispute-withdraw-illegal-state'),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'DISPUTE_INVALID_STATE');
      return true;
    },
  );
});
