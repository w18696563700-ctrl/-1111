const test = require('node:test');
const assert = require('node:assert/strict');

function loadDistModule(candidates) {
  for (const candidate of candidates) {
    try {
      return require(candidate);
    } catch (error) {
      if (error?.code !== 'MODULE_NOT_FOUND') {
        throw error;
      }
    }
  }
  throw new Error(`Unable to load any dist module from: ${candidates.join(', ')}`);
}

function createSessionRepository(seedSession) {
  const sessions = [seedSession];
  return {
    sessions,
    create: (value) => ({ ...value }),
    async findOneBy(criteria) {
      return sessions.find((item) => item.id === criteria.id) ?? null;
    },
    async save(session) {
      const index = sessions.findIndex((item) => item.id === session.id);
      if (index >= 0) {
        sessions[index] = session;
      } else {
        sessions.push(session);
      }
      return session;
    },
    async update(criteria, patch) {
      const session = sessions.find((item) => item.id === criteria.id);
      if (!session) {
        return { affected: 0 };
      }
      Object.assign(session, patch);
      return { affected: 1 };
    }
  };
}

function createVerificationHarness(options = {}) {
  const sessionRepository = createSessionRepository({
    id: 'session-1',
    userId: 'user-1',
    refreshTokenHash: 'refresh-hash',
    organizationId: options.initialSessionOrganizationId ?? null,
    deviceId: null,
    deviceName: null,
    ip: null,
    userAgent: null,
    status: 'valid',
    expiresAt: new Date('2026-04-30T00:00:00.000Z'),
    revokedAt: null,
    createdAt: new Date('2026-04-01T00:00:00.000Z')
  });
  const userRepository = {
    async findOneBy(criteria) {
      if (criteria.id !== 'user-1') {
        return null;
      }
      return {
        id: 'user-1',
        mobile: '13800138000',
        nickname: 'Current User',
        avatarUrl: null,
        status: 'active',
        profileIntro: null
      };
    }
  };
  const accessCarrierService = {
    verify: () => ({
      outcome: 'verified',
      payload: {
        sessionId: 'session-1',
        organizationId: options.carrierOrganizationId ?? null,
        expiresAt: '2026-04-30T00:00:00.000Z',
        nonce: 'nonce-1'
      }
    }),
    mapFailureReason: () => 'authorization_carrier_malformed'
  };
  const { CurrentSessionVerificationService } = loadDistModule([
    '../dist/modules/auth/current-session-verification.service.js',
    '../dist/src/modules/auth/current-session-verification.service.js',
    '../dist/apps/server/src/modules/auth/current-session-verification.service.js'
  ]);

  return {
    sessionRepository,
    verifier: new CurrentSessionVerificationService(
      sessionRepository,
      userRepository,
      accessCarrierService
    )
  };
}

function buildReadSurfaceHarness(verifier, options = {}) {
  const targetOrganization = {
    id: 'org-target',
    name: 'Target Organization',
    organizationType: 'demand'
  };
  const otherOrganization = {
    id: 'org-other',
    name: 'Other Organization',
    organizationType: 'supplier'
  };
  const targetMembership = {
    id: 'member-target',
    organizationId: targetOrganization.id,
    userId: 'user-1',
    roleKey: 'buyer_admin',
    memberStatus: 'active',
    invitedBy: null,
    invitedAt: null,
    joinedAt: new Date('2026-04-02T00:00:00.000Z'),
    disabledAt: null
  };
  const targetCertification = {
    certificationStatus: 'approved',
    legalName: 'Target Co',
    uscc: 'USCC-1',
    licenseFileId: 'license-1',
    submittedAt: new Date('2026-04-02T00:00:00.000Z'),
    reviewedAt: new Date('2026-04-03T00:00:00.000Z'),
    reviewedBy: 'reviewer-1',
    rejectReason: null,
    expiresAt: null
  };
  const scopeMap = {
    [targetOrganization.id]: {
      organization: targetOrganization,
      membership: targetMembership,
      certification: targetCertification,
      roleKeys: ['buyer_admin']
    }
  };
  const { ShellQueryService } = loadDistModule([
    '../dist/modules/shell/shell-query.service.js',
    '../dist/src/modules/shell/shell-query.service.js',
    '../dist/apps/server/src/modules/shell/shell-query.service.js'
  ]);
  const { ProfileQueryService } = loadDistModule([
    '../dist/modules/profile/profile-query.service.js',
    '../dist/src/modules/profile/profile-query.service.js',
    '../dist/apps/server/src/modules/profile/profile-query.service.js'
  ]);
  const { ProfileOrganizationMembersQueryService } = loadDistModule([
    '../dist/modules/profile/profile-organization-members.query.service.js',
    '../dist/src/modules/profile/profile-organization-members.query.service.js',
    '../dist/apps/server/src/modules/profile/profile-organization-members.query.service.js'
  ]);
  const { ShellPresenter } = loadDistModule([
    '../dist/modules/shell/shell.presenter.js',
    '../dist/src/modules/shell/shell.presenter.js',
    '../dist/apps/server/src/modules/shell/shell.presenter.js'
  ]);
  const { ProfilePresenter } = loadDistModule([
    '../dist/modules/profile/profile.presenter.js',
    '../dist/src/modules/profile/profile.presenter.js',
    '../dist/apps/server/src/modules/profile/profile.presenter.js'
  ]);

  const eligibilityService = {
    async requireAuthenticatedActor(currentSession) {
      assert.equal(currentSession.organizationId, targetOrganization.id);
      return {
        id: 'user-1',
        mobile: '13800138000',
        nickname: 'Current User',
        avatarUrl: null,
        status: 'active',
        profileIntro: 'Hello'
      };
    },
    async getCurrentOrganizationScope(currentSession) {
      return currentSession.organizationId ? scopeMap[currentSession.organizationId] ?? null : null;
    },
    async requireOrganizationAdmin(currentSession, organizationId) {
      assert.equal(currentSession.organizationId, organizationId);
      return scopeMap[organizationId];
    },
    canPublishProjectInScope(scope) {
      return (
        Array.isArray(scope?.roleKeys) &&
        scope.roleKeys.includes('buyer_admin') &&
        scope?.certification?.certificationStatus === 'approved'
      );
    },
    async listAccessibleOrganizations() {
      return [
        {
          organization: otherOrganization,
          roleKeys: ['supplier_member(scoped)'],
          membershipStatus: 'active',
          certificationStatus: 'approved'
        },
        {
          organization: targetOrganization,
          roleKeys: ['buyer_admin'],
          membershipStatus: 'active',
          certificationStatus: 'approved'
        }
      ];
    }
  };
  const membershipQueryService = {
    async getShellSummaryProjection(organizationId) {
      assert.equal(organizationId, targetOrganization.id);
      return {
        paidMembershipTier: 'gold',
        paidMembershipEntitlementsSummary: ['entitlement-a'],
        paidMembershipQuotaSummary: ['quota-a'],
        paidMembershipNextRefreshAt: null
      };
    }
  };
  const shellContextProjection = {
    profileCorridorKey: 'my_building_compact_current_user_hub',
    profileEntryOrderBucket: 'my_building_compact_hub_first_level',
    visibleFamilyKeys: ['exhibition', 'profile', 'messages'],
    orderingReferenceVersion: '1',
    updatedAt: new Date('2026-04-01T00:00:00.000Z'),
    regrouping: {
      regroupingKey: 'my_building_compact_current_user_hub',
      regroupingVisibilityStatus: 'visible',
      regroupingExplanationKey: 'my_building_bounded_private_regrouping',
      updatedAt: new Date('2026-04-01T00:00:00.000Z')
    },
    entryOrder: {
      entryOrderKey: 'my_building_compact_hub_first_level',
      entryVisibilityStatus: 'visible',
      entryPriorityBucket: 'primary',
      orderingExplanationKey: 'my_building_bounded_private_regrouping',
      updatedAt: new Date('2026-04-01T00:00:00.000Z')
    },
    corridor: {
      corridorKey: 'profile',
      corridorVisibilityStatus: 'visible',
      corridorExplanationKey: 'my_building_bounded_private_regrouping',
      corridorTargetFamily: 'profile',
      updatedAt: new Date('2026-04-01T00:00:00.000Z')
    },
    familyPresence: [
      {
        familyKey: 'exhibition',
        familyPresenceStatus: 'visible',
        familyOrderReference: 1,
        familyVisibilityReasonKey: 'my_building_bounded_private_regrouping',
        updatedAt: new Date('2026-04-01T00:00:00.000Z')
      },
      {
        familyKey: 'profile',
        familyPresenceStatus: 'visible',
        familyOrderReference: 2,
        familyVisibilityReasonKey: 'my_building_bounded_private_regrouping',
        updatedAt: new Date('2026-04-01T00:00:00.000Z')
      }
    ],
    navigationExplanation: {
      regroupingExplanationKey: 'my_building_bounded_private_regrouping',
      orderingExplanationKey: 'my_building_bounded_private_regrouping',
      corridorExplanationKey: 'my_building_bounded_private_regrouping',
      dependencyExplanationKey: 'my_building_bounded_private_regrouping',
      navigationExplanationKey: 'my_building_bounded_private_regrouping'
    },
    dependencyReference: {
      dependencyRequired: false,
      dependencyFamilyKey: 'exhibition',
      dependencyExplanationKey: 'my_building_bounded_private_regrouping',
      dependencyHandoffKey: 'my_building_bounded_private_regrouping'
    }
  };
  const profileIndexProjection = {
    regroupingKey: 'my_building_compact_current_user_hub',
    entryOrderKey: 'my_building_compact_hub_first_level',
    corridorVisibilityStatus: 'visible',
    groupingExplanationKey: 'my_building_bounded_private_regrouping',
    updatedAt: new Date('2026-04-01T00:00:00.000Z')
  };
  const privateOperatingSystemService = {
    getShellContextProjection() {
      return shellContextProjection;
    },
    getProfileIndexProjection() {
      return profileIndexProjection;
    }
  };
  const avatarUrlService = {
    async buildAccessUrlFromObjectUrl(value) {
      return value ? `https://cdn.example/${value}` : null;
    }
  };
  const organizationMemberRepository = {
    async find() {
      return [targetMembership];
    }
  };
  const userRepository = {
    async findBy() {
      return [
        {
          id: 'user-1',
          mobile: '13800138000',
          nickname: 'Current User'
        }
      ];
    }
  };

  return {
    targetOrganization,
    otherOrganization,
    targetMembership,
    targetCertification,
    services: {
      shell: new ShellQueryService(
        verifier,
        eligibilityService,
        membershipQueryService,
        privateOperatingSystemService,
        avatarUrlService,
        new ShellPresenter()
      ),
      profile: new ProfileQueryService(
        verifier,
        eligibilityService,
        privateOperatingSystemService,
        avatarUrlService,
        new ProfilePresenter()
      ),
      members: new ProfileOrganizationMembersQueryService(
        organizationMemberRepository,
        userRepository,
        verifier,
        eligibilityService,
        new ProfilePresenter()
      )
    },
    eligibilityService
  };
}

test('S1-R02 current session verification backfills session organization truth and ignores hint', async () => {
  const { sessionRepository, verifier } = createVerificationHarness({
    initialSessionOrganizationId: null,
    carrierOrganizationId: 'org-carrier'
  });

  const verified = await verifier.verifyCurrentSessionContext({
    authorization: 'Bearer test',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'org-hint',
    actorRole: 'buyer_admin',
    requestId: 'request-1',
    traceId: 'trace-1',
    userAgent: 'test-agent',
    remoteIp: '127.0.0.1'
  });

  assert.equal(verified.outcome, 'verified');
  assert.equal(verified.currentSession.organizationId, 'org-carrier');
  assert.equal(sessionRepository.sessions[0].organizationId, 'org-carrier');
});

test('S1-R02 organization switch writes session truth and shell/profile read the same scope', async () => {
  const { sessionRepository, verifier } = createVerificationHarness({
    initialSessionOrganizationId: 'org-old',
    carrierOrganizationId: 'org-old'
  });
  const auditRecords = [];
  const { OrganizationWriteService } = loadDistModule([
    '../dist/modules/organization/organization-write.service.js',
    '../dist/src/modules/organization/organization-write.service.js',
    '../dist/apps/server/src/modules/organization/organization-write.service.js'
  ]);
  const { OrganizationWritePresenter } = loadDistModule([
    '../dist/modules/organization/organization-write.presenter.js',
    '../dist/src/modules/organization/organization-write.presenter.js',
    '../dist/apps/server/src/modules/organization/organization-write.presenter.js'
  ]);
  const organizationRepository = {
    async findOneBy(criteria) {
      if (criteria.id === 'org-target') {
        return {
          id: 'org-target',
          name: 'Target Organization',
          organizationType: 'demand'
        };
      }
      if (criteria.id === 'org-old') {
        return {
          id: 'org-old',
          name: 'Old Organization',
          organizationType: 'supplier'
        };
      }
      return null;
    }
  };
  const organizationMemberRepository = {
    async findOneBy(criteria) {
      if (criteria.organizationId === 'org-target' && criteria.userId === 'user-1' && criteria.memberStatus === 'active') {
        return {
          id: 'member-target',
          organizationId: 'org-target',
          userId: 'user-1',
          roleKey: 'buyer_admin',
          memberStatus: 'active',
          invitedBy: null,
          invitedAt: null,
          joinedAt: new Date('2026-04-02T00:00:00.000Z'),
          disabledAt: null
        };
      }
      return null;
    }
  };
  const organizationCertificationRepository = {
    async findOne() {
      return {
        certificationStatus: 'approved'
      };
    }
  };
  const organizationInvitationRepository = { async findOneBy() { return null; } };
  const fileAssetRepository = { async findOneBy() { return null; } };
  const dataSource = {
    async transaction(callback) {
      return callback({
        getRepository(entity) {
          if (entity.name === 'SessionEntity') {
            return sessionRepository;
          }
          if (entity.name === 'IdentityAuditLogEntity') {
            return {
              create: (value) => ({ ...value }),
              async save(record) {
                auditRecords.push(record);
                return record;
              }
            };
          }
          throw new Error(`Unexpected repository request for ${entity.name}`);
        }
      });
    }
  };
  const organizationWriteService = new OrganizationWriteService(
    organizationRepository,
    organizationMemberRepository,
    organizationCertificationRepository,
    organizationInvitationRepository,
    fileAssetRepository,
    dataSource,
    verifier,
    {
      async requireAuthenticatedActor() {
        return {
          id: 'user-1',
          mobile: '13800138000',
          nickname: 'Current User',
          avatarUrl: null,
          status: 'active',
          profileIntro: null
        };
      }
    },
    new OrganizationWritePresenter()
  );

  const switched = await organizationWriteService.switch(
    {
      organizationId: 'org-target'
    },
    {
      authorization: 'Bearer test',
      actorId: 'user-1',
      userId: 'user-1',
      organizationId: 'org-hint-stale',
      actorRole: 'buyer_admin',
      requestId: 'request-2',
      traceId: 'trace-2',
      userAgent: 'test-agent',
      remoteIp: '127.0.0.1'
    }
  );

  assert.equal(switched.organizationId, 'org-target');
  assert.equal(sessionRepository.sessions[0].organizationId, 'org-target');
  assert.equal(auditRecords.length, 1);
  assert.equal(auditRecords[0].action, 'OrganizationSwitched');

  const verifiedAfterSwitch = await verifier.verifyCurrentSessionContext({
    authorization: 'Bearer test',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'org-hint-stale',
    actorRole: 'buyer_admin',
    requestId: 'request-3',
    traceId: 'trace-3',
    userAgent: 'test-agent',
    remoteIp: '127.0.0.1'
  });

  assert.equal(verifiedAfterSwitch.currentSession.organizationId, 'org-target');

  const { services, targetOrganization, otherOrganization } = buildReadSurfaceHarness(verifier);
  const shellContext = await services.shell.getContext({
    authorization: 'Bearer test',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'org-hint-stale',
    actorRole: 'buyer_admin',
    requestId: 'request-4',
    traceId: 'trace-4',
    userAgent: 'test-agent',
    remoteIp: '127.0.0.1'
  });
  const profileIndex = await services.profile.getProfileIndex({
    authorization: 'Bearer test',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'org-hint-stale',
    actorRole: 'buyer_admin',
    requestId: 'request-5',
    traceId: 'trace-5',
    userAgent: 'test-agent',
    remoteIp: '127.0.0.1'
  });
  const organizations = await services.profile.getOrganizations({
    authorization: 'Bearer test',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'org-hint-stale',
    actorRole: 'buyer_admin',
    requestId: 'request-6',
    traceId: 'trace-6',
    userAgent: 'test-agent',
    remoteIp: '127.0.0.1'
  });
  const members = await services.members.getMembers({
    authorization: 'Bearer test',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'org-hint-stale',
    actorRole: 'buyer_admin',
    requestId: 'request-7',
    traceId: 'trace-7',
    userAgent: 'test-agent',
    remoteIp: '127.0.0.1'
  });

  assert.equal(shellContext.organizationId, targetOrganization.id);
  assert.equal(profileIndex.organization.organizationId, targetOrganization.id);
  assert.equal(organizations.items.find((item) => item.organizationId === targetOrganization.id).current, true);
  assert.equal(organizations.items.find((item) => item.organizationId === otherOrganization.id).current, false);
  assert.equal(members.items[0].roleKey, 'buyer_admin');
  assert.equal(members.items[0].memberStatus, 'active');
});

test('S1-R02 migration registry includes session organization scope truth', () => {
  const { currentSessionScopeMigrations, serverMigrations } = loadDistModule([
    '../dist/src/core/migrations/migrations.js',
    '../dist/apps/server/src/core/migrations/migrations.js',
    '../dist/core/migrations/migrations.js'
  ]);
  const migration = currentSessionScopeMigrations.find(
    (item) => item.key === '20260409_sessions_current_organization_scope_truth'
  );

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  const joined = migration.statements.join('\n');
  assert.match(joined, /ALTER TABLE sessions/);
  assert.match(joined, /ADD COLUMN IF NOT EXISTS organization_id varchar\(64\)/);
});
