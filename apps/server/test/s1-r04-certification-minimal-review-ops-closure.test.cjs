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

function readFindOperatorValue(value) {
  if (!value || typeof value !== 'object') {
    return null;
  }
  if (value._type === 'in') {
    return value._value;
  }
  return null;
}

function matchesWhere(item, where) {
  return Object.entries(where).every(([key, expected]) => {
    const expectedSet = readFindOperatorValue(expected);
    if (expectedSet) {
      return expectedSet.includes(item[key]);
    }
    return item[key] === expected;
  });
}

function sortItems(items, order) {
  if (!order) {
    return [...items];
  }
  const orderEntries = Object.entries(order);
  return [...items].sort((left, right) => {
    for (const [field, direction] of orderEntries) {
      const leftValue = left[field];
      const rightValue = right[field];
      if (leftValue === rightValue) {
        continue;
      }
      const factor = String(direction).toUpperCase() === 'DESC' ? -1 : 1;
      return leftValue > rightValue ? factor : -factor;
    }
    return 0;
  });
}

function createArrayRepository(items) {
  return {
    items,
    create(value) {
      return { ...value };
    },
    async findOneBy(where) {
      return items.find((item) => matchesWhere(item, where)) ?? null;
    },
    async findBy(where) {
      return items.filter((item) => matchesWhere(item, where));
    },
    async find(options = {}) {
      const filtered = options.where ? items.filter((item) => matchesWhere(item, options.where)) : items;
      return sortItems(filtered, options.order);
    },
    async findOne(options = {}) {
      const filtered = options.where ? items.filter((item) => matchesWhere(item, options.where)) : items;
      return sortItems(filtered, options.order)[0] ?? null;
    },
    async save(entity) {
      const index = items.findIndex((item) => item.id === entity.id);
      if (index >= 0) {
        items[index] = entity;
      } else {
        items.push(entity);
      }
      return entity;
    }
  };
}

function createVerifier(sessionByCarrier) {
  return {
    async verifyCurrentSessionContext(context) {
      const session = sessionByCarrier[context.authorization];
      if (!session) {
        return {
          outcome: 'failed',
          reason: 'missing_current_session_carrier',
          requestId: context.requestId,
          traceId: context.traceId
        };
      }
      return {
        outcome: 'verified',
        currentSession: session
      };
    }
  };
}

function createReviewListQueryBuilder(certifications, organizations) {
  const state = {
    status: null,
    organizationId: null,
    keyword: null,
    offset: 0,
    limit: 20
  };

  function filteredRows() {
    let rows = certifications.map((certification) => {
      const organization = organizations.find((item) => item.id === certification.organizationId);
      return organization
        ? {
            organization,
            certification
          }
        : null;
    }).filter(Boolean);

    if (state.status) {
      rows = rows.filter((row) => row.certification.certificationStatus === state.status);
    }
    if (state.organizationId) {
      rows = rows.filter((row) => row.organization.id === state.organizationId);
    }
    if (state.keyword) {
      const keyword = state.keyword.toLowerCase();
      rows = rows.filter((row) =>
        [row.organization.name, row.certification.legalName, row.certification.uscc]
          .filter(Boolean)
          .some((value) => String(value).toLowerCase().includes(keyword))
      );
    }

    rows.sort((left, right) => {
      const leftSubmittedAt = left.certification.submittedAt?.getTime() ?? 0;
      const rightSubmittedAt = right.certification.submittedAt?.getTime() ?? 0;
      if (leftSubmittedAt !== rightSubmittedAt) {
        return rightSubmittedAt - leftSubmittedAt;
      }
      const leftCreatedAt = left.organization.createdAt?.getTime?.() ?? 0;
      const rightCreatedAt = right.organization.createdAt?.getTime?.() ?? 0;
      return rightCreatedAt - leftCreatedAt;
    });
    return rows;
  }

  return {
    innerJoin() {
      return this;
    },
    andWhere(sql, params) {
      if (sql.includes('certification.certification_status')) {
        state.status = params.status;
      }
      if (sql.includes('organization.id = :organizationId')) {
        state.organizationId = params.organizationId;
      }
      if (sql.includes('organization.name ILIKE')) {
        state.keyword = String(params.keyword).replaceAll('%', '');
      }
      return this;
    },
    async getCount() {
      return filteredRows().length;
    },
    select() {
      return this;
    },
    orderBy() {
      return this;
    },
    addOrderBy() {
      return this;
    },
    offset(value) {
      state.offset = value;
      return this;
    },
    limit(value) {
      state.limit = value;
      return this;
    },
    async getRawMany() {
      return filteredRows()
        .slice(state.offset, state.offset + state.limit)
        .map((row) => ({
          organization_id: row.organization.id,
          organization_name: row.organization.name,
          organization_type: row.organization.organizationType,
          certification_status: row.certification.certificationStatus,
          submitted_at: row.certification.submittedAt?.toISOString() ?? null
        }));
    }
  };
}

function createHarness() {
  const reviewerUser = {
    id: 'user-reviewer',
    mobile: '13800138001',
    nickname: 'Reviewer',
    avatarUrl: null,
    status: 'active',
    profileIntro: null
  };
  const ownerUser = {
    id: 'user-owner',
    mobile: '13800138002',
    nickname: 'Owner',
    avatarUrl: null,
    status: 'active',
    profileIntro: 'Org owner'
  };
  const users = [reviewerUser, ownerUser];
  const organizations = [
    {
      id: 'org-platform',
      name: 'Platform Org',
      organizationType: 'platform',
      status: 'active',
      contactName: 'Platform',
      contactMobile: '13800138009',
      uscc: null,
      businessLicenseFileId: null,
      createdAt: new Date('2026-04-01T00:00:00.000Z')
    },
    {
      id: 'org-target',
      name: 'Target Org',
      organizationType: 'demand',
      status: 'draft',
      contactName: 'Target Contact',
      contactMobile: '13800138003',
      uscc: 'USCC-TARGET',
      businessLicenseFileId: 'file-license-1',
      createdAt: new Date('2026-04-02T00:00:00.000Z')
    }
  ];
  const memberships = [
    {
      id: 'member-reviewer',
      organizationId: 'org-platform',
      userId: reviewerUser.id,
      roleKey: 'platform_reviewer',
      memberStatus: 'active',
      joinedAt: new Date('2026-04-03T00:00:00.000Z'),
      disabledAt: null
    },
    {
      id: 'member-owner',
      organizationId: 'org-target',
      userId: ownerUser.id,
      roleKey: 'buyer_admin',
      memberStatus: 'active',
      joinedAt: new Date('2026-04-04T00:00:00.000Z'),
      disabledAt: null
    }
  ];
  const certifications = [
    {
      id: 'cert-target',
      organizationId: 'org-target',
      certificationStatus: 'pending_review',
      legalName: 'Target Legal Name',
      uscc: 'USCC-TARGET',
      licenseFileId: 'file-license-1',
      submittedAt: new Date('2026-04-05T00:00:00.000Z'),
      reviewedAt: null,
      reviewedBy: null,
      rejectReason: null,
      expiresAt: null,
      createdAt: new Date('2026-04-05T00:00:00.000Z'),
      updatedAt: new Date('2026-04-05T00:00:00.000Z')
    }
  ];
  const fileAssets = [
    {
      id: 'file-license-1',
      organizationId: 'org-target'
    }
  ];
  const auditRecords = [];

  const organizationRepository = createArrayRepository(organizations);
  const certificationRepository = createArrayRepository(certifications);
  certificationRepository.createQueryBuilder = () =>
    createReviewListQueryBuilder(certifications, organizations);
  const organizationMemberRepository = createArrayRepository(memberships);
  const userRepository = createArrayRepository(users);
  const fileAssetRepository = createArrayRepository(fileAssets);

  const { CurrentActorEligibilityService } = loadDistModule([
    '../dist/modules/organization/current-actor-eligibility.service.js',
    '../dist/src/modules/organization/current-actor-eligibility.service.js',
    '../dist/apps/server/src/modules/organization/current-actor-eligibility.service.js'
  ]);
  const { OrganizationReviewQueryService } = loadDistModule([
    '../dist/modules/review/organization-review-query.service.js',
    '../dist/src/modules/review/organization-review-query.service.js',
    '../dist/apps/server/src/modules/review/organization-review-query.service.js'
  ]);
  const { OrganizationReviewWriteService } = loadDistModule([
    '../dist/modules/review/organization-review-write.service.js',
    '../dist/src/modules/review/organization-review-write.service.js',
    '../dist/apps/server/src/modules/review/organization-review-write.service.js'
  ]);
  const { OrganizationReviewPresenter } = loadDistModule([
    '../dist/modules/review/organization-review.presenter.js',
    '../dist/src/modules/review/organization-review.presenter.js',
    '../dist/apps/server/src/modules/review/organization-review.presenter.js'
  ]);
  const { ProfileQueryService } = loadDistModule([
    '../dist/modules/profile/profile-query.service.js',
    '../dist/src/modules/profile/profile-query.service.js',
    '../dist/apps/server/src/modules/profile/profile-query.service.js'
  ]);
  const { ProfilePresenter } = loadDistModule([
    '../dist/modules/profile/profile.presenter.js',
    '../dist/src/modules/profile/profile.presenter.js',
    '../dist/apps/server/src/modules/profile/profile.presenter.js'
  ]);
  const { ShellQueryService } = loadDistModule([
    '../dist/modules/shell/shell-query.service.js',
    '../dist/src/modules/shell/shell-query.service.js',
    '../dist/apps/server/src/modules/shell/shell-query.service.js'
  ]);
  const { ShellPresenter } = loadDistModule([
    '../dist/modules/shell/shell.presenter.js',
    '../dist/src/modules/shell/shell.presenter.js',
    '../dist/apps/server/src/modules/shell/shell.presenter.js'
  ]);

  const verifier = createVerifier({
    'Bearer reviewer': {
      sessionId: 'session-reviewer',
      actorId: reviewerUser.id,
      userId: reviewerUser.id,
      organizationId: 'org-platform',
      requestId: 'request-reviewer',
      traceId: 'trace-reviewer'
    },
    'Bearer owner': {
      sessionId: 'session-owner',
      actorId: ownerUser.id,
      userId: ownerUser.id,
      organizationId: 'org-target',
      requestId: 'request-owner',
      traceId: 'trace-owner'
    }
  });

  const eligibilityService = new CurrentActorEligibilityService(
    userRepository,
    organizationRepository,
    organizationMemberRepository,
    certificationRepository
  );

  const presenter = new OrganizationReviewPresenter();
  const queryService = new OrganizationReviewQueryService(
    certificationRepository,
    organizationRepository,
    verifier,
    eligibilityService,
    presenter
  );
  const dataSource = {
    async transaction(callback) {
      return callback({
        getRepository(entity) {
          switch (entity.name) {
            case 'OrganizationEntity':
              return organizationRepository;
            case 'OrganizationCertificationEntity':
              return certificationRepository;
            case 'IdentityAuditLogEntity':
              return {
                async save(record) {
                  auditRecords.push(record);
                  return record;
                }
              };
            default:
              throw new Error(`Unexpected repository request: ${entity.name}`);
          }
        }
      });
    }
  };
  const writeService = new OrganizationReviewWriteService(
    certificationRepository,
    organizationRepository,
    fileAssetRepository,
    dataSource,
    verifier,
    eligibilityService,
    presenter
  );

  const privateOperatingSystemService = {
    getProfileIndexProjection() {
      return {
        regroupingKey: 'my_building_compact_current_user_hub',
        entryOrderKey: 'my_building_compact_hub_first_level',
        corridorVisibilityStatus: 'visible',
        groupingExplanationKey: 'my_building_bounded_private_regrouping',
        updatedAt: new Date('2026-04-01T00:00:00.000Z')
      };
    },
    getShellContextProjection() {
      return {
        profileCorridorKey: 'my_building_compact_current_user_hub',
        profileEntryOrderBucket: 'my_building_compact_hub_first_level',
        visibleFamilyKeys: ['exhibition', 'messages', 'profile'],
        orderingReferenceVersion: 'phase0.package1a',
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
            familyKey: 'profile',
            familyPresenceStatus: 'visible',
            familyOrderReference: 1,
            familyVisibilityReasonKey: 'my_building_bounded_private_regrouping',
            updatedAt: new Date('2026-04-01T00:00:00.000Z')
          }
        ],
        navigationExplanation: {
          navigationExplanationKey: 'my_building_bounded_private_regrouping',
          regroupingExplanationKey: 'my_building_bounded_private_regrouping',
          orderingExplanationKey: 'my_building_bounded_private_regrouping',
          corridorExplanationKey: 'my_building_bounded_private_regrouping',
          dependencyExplanationKey: 'my_building_bounded_private_regrouping'
        },
        dependencyReference: {
          dependencyRequired: false,
          dependencyFamilyKey: 'profile',
          dependencyExplanationKey: 'my_building_bounded_private_regrouping',
          dependencyHandoffKey: 'my_building_bounded_private_regrouping'
        }
      };
    }
  };
  const avatarUrlService = {
    async buildAccessUrlFromObjectUrl(value) {
      return value;
    }
  };
  const membershipQueryService = {
    async getShellSummaryProjection() {
      return {
        paidMembershipTier: null,
        paidMembershipEntitlementsSummary: [],
        paidMembershipQuotaSummary: [],
        paidMembershipNextRefreshAt: null
      };
    }
  };

  const profileQueryService = new ProfileQueryService(
    verifier,
    eligibilityService,
    privateOperatingSystemService,
    avatarUrlService,
    new ProfilePresenter()
  );
  const shellQueryService = new ShellQueryService(
    verifier,
    eligibilityService,
    membershipQueryService,
    privateOperatingSystemService,
    avatarUrlService,
    new ShellPresenter()
  );

  return {
    reviewerUser,
    ownerUser,
    organizations,
    certifications,
    auditRecords,
    services: {
      eligibilityService,
      queryService,
      writeService,
      profileQueryService,
      shellQueryService
    }
  };
}

function createRequestContext(authorization, requestId) {
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

async function assertAuthPermissionInsufficient(promiseFactory) {
  await assert.rejects(
    promiseFactory,
    (error) => error?.response?.code === 'AUTH_PERMISSION_INSUFFICIENT'
  );
}

test('S1-R04 reviewer can read organization review list/detail while non-reviewer is fail-closed', async () => {
  const { services } = createHarness();

  const list = await services.queryService.list(
    { status: 'pending_review', keyword: 'Target', organizationId: 'org-target' },
    createRequestContext('Bearer reviewer', 'review-list')
  );
  assert.equal(list.items.length, 1);
  assert.equal(list.items[0].organizationId, 'org-target');
  assert.equal(list.items[0].certificationStatus, 'pending_review');

  const detail = await services.queryService.detail(
    'org-target',
    createRequestContext('Bearer reviewer', 'review-detail')
  );
  assert.equal(detail.organizationId, 'org-target');
  assert.equal(detail.certificationStatus, 'pending_review');
  assert.equal(detail.legalName, 'Target Legal Name');
  assert.equal(detail.licenseFileId, 'file-license-1');

  await assertAuthPermissionInsufficient(() =>
    services.queryService.list({}, createRequestContext('Bearer owner', 'review-list-owner'))
  );
  await assertAuthPermissionInsufficient(() =>
    services.queryService.detail('org-target', createRequestContext('Bearer owner', 'review-detail-owner'))
  );
});

test('S1-R04 approve is reviewer-only and writes audit plus approved readback', async () => {
  const { organizations, certifications, auditRecords, services, reviewerUser } = createHarness();

  await assertAuthPermissionInsufficient(() =>
    services.writeService.approve(
      'org-target',
      { note: 'owner cannot approve' },
      createRequestContext('Bearer owner', 'approve-owner')
    )
  );

  const ack = await services.writeService.approve(
    'org-target',
    { note: 'looks good' },
    createRequestContext('Bearer reviewer', 'approve-reviewer')
  );

  assert.deepEqual(ack, {
    ok: true,
    traceId: 'trace-approve-reviewer'
  });
  assert.equal(certifications[0].certificationStatus, 'approved');
  assert.equal(certifications[0].reviewedBy, reviewerUser.id);
  assert.equal(certifications[0].rejectReason, null);
  assert.equal(organizations.find((item) => item.id === 'org-target').status, 'active');
  assert.equal(auditRecords.length, 1);
  assert.equal(auditRecords[0].action, 'OrganizationCertificationApproved');
  assert.equal(auditRecords[0].objectType, 'organization_certification');
  assert.equal(auditRecords[0].objectId, 'cert-target');
  assert.equal(auditRecords[0].objectNo, 'org-target');
  assert.equal(auditRecords[0].actorId, reviewerUser.id);
  assert.equal(auditRecords[0].beforeState, 'pending_review');
  assert.equal(auditRecords[0].afterState, 'approved');
  assert.equal(auditRecords[0].actorRole, 'platform_reviewer');
  assert.equal(auditRecords[0].requestId, 'approve-reviewer');
  assert.equal(auditRecords[0].traceId, 'trace-approve-reviewer');
  assert.match(auditRecords[0].reason, /licenseFileId=file-license-1/);
  assert.match(auditRecords[0].reason, /note=looks good/);

  const profileIndex = await services.profileQueryService.getProfileIndex(
    createRequestContext('Bearer owner', 'profile-approved')
  );
  const shellContext = await services.shellQueryService.getContext(
    createRequestContext('Bearer owner', 'shell-approved')
  );

  assert.equal(profileIndex.certification.status, 'approved');
  assert.equal(shellContext.certificationStatus, 'approved');
});

test('S1-R04 reject is reviewer-only and writes audit plus rejected readback', async () => {
  const { organizations, certifications, auditRecords, services, reviewerUser } = createHarness();

  await assertAuthPermissionInsufficient(() =>
    services.writeService.reject(
      'org-target',
      { reason: 'owner cannot reject' },
      createRequestContext('Bearer owner', 'reject-owner')
    )
  );

  const ack = await services.writeService.reject(
    'org-target',
    { reason: 'license_blur', note: 'image unreadable' },
    createRequestContext('Bearer reviewer', 'reject-reviewer')
  );

  assert.deepEqual(ack, {
    ok: true,
    traceId: 'trace-reject-reviewer'
  });
  assert.equal(certifications[0].certificationStatus, 'rejected');
  assert.equal(certifications[0].reviewedBy, reviewerUser.id);
  assert.equal(certifications[0].rejectReason, 'license_blur');
  assert.equal(organizations.find((item) => item.id === 'org-target').status, 'draft');
  assert.equal(auditRecords.length, 1);
  assert.equal(auditRecords[0].action, 'OrganizationCertificationRejected');
  assert.equal(auditRecords[0].objectType, 'organization_certification');
  assert.equal(auditRecords[0].objectId, 'cert-target');
  assert.equal(auditRecords[0].objectNo, 'org-target');
  assert.equal(auditRecords[0].actorId, reviewerUser.id);
  assert.equal(auditRecords[0].beforeState, 'pending_review');
  assert.equal(auditRecords[0].afterState, 'rejected');
  assert.equal(auditRecords[0].actorRole, 'platform_reviewer');
  assert.equal(auditRecords[0].requestId, 'reject-reviewer');
  assert.equal(auditRecords[0].traceId, 'trace-reject-reviewer');
  assert.match(auditRecords[0].reason, /licenseFileId=file-license-1/);
  assert.match(auditRecords[0].reason, /reason=license_blur/);
  assert.match(auditRecords[0].reason, /note=image unreadable/);

  const profileIndex = await services.profileQueryService.getProfileIndex(
    createRequestContext('Bearer owner', 'profile-rejected')
  );
  const shellContext = await services.shellQueryService.getContext(
    createRequestContext('Bearer owner', 'shell-rejected')
  );

  assert.equal(profileIndex.certification.status, 'rejected');
  assert.equal(shellContext.certificationStatus, 'rejected');
});
