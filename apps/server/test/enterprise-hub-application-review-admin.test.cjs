const test = require('node:test');
const assert = require('node:assert/strict');
const { ForbiddenException } = require('@nestjs/common');

const {
  EnterpriseHubAdminController,
} = require('../dist/modules/enterprise_hub/enterprise-hub-admin.controller.js');
const {
  EnterpriseHubApplicationReviewAdminQueryService,
} = require('../dist/modules/enterprise_hub/enterprise-hub-application-review-admin.query.service.js');
const {
  EnterpriseHubApplicationReviewAdminWriteService,
} = require('../dist/modules/enterprise_hub/enterprise-hub-application-review-admin.write.service.js');

test('applications controller routes list/detail/review through bounded services and forwards resolved request context', async () => {
  const calls = [];
  const controller = new EnterpriseHubAdminController(
    {
      async listApplications(query, context) {
        calls.push({ kind: 'list', query, context });
        return { ok: true };
      },
      async getApplicationDetail(applicationId, context) {
        calls.push({ kind: 'detail', applicationId, context });
        return { ok: true };
      },
    },
    {
      async reviewApplication(applicationId, body, context) {
        calls.push({ kind: 'review', applicationId, body, context });
        return { ok: true };
      },
    },
    {},
    {},
  );
  const headers = createHeaderBag();

  await controller.listApplications({ page: '2' }, headers);
  await controller.getApplicationDetail('application-1', headers);
  await controller.reviewApplication('application-1', { action: 'approved' }, headers);

  assert.equal(calls.length, 3);
  assert.deepEqual(calls[0].query, { page: '2' });
  assert.equal(calls[1].applicationId, 'application-1');
  assert.deepEqual(calls[2].body, { action: 'approved' });
  for (const call of calls) {
    assert.equal(call.context.authorization, 'Bearer reviewer');
    assert.equal(call.context.actorId, 'spoofed-header-actor');
    assert.equal(call.context.actorRole, 'platform_reviewer');
    assert.equal(call.context.requestId, 'request-1');
    assert.equal(call.context.traceId, 'trace-1');
  }
});

test('recommendation slots list controller forwards resolved request context', async () => {
  const calls = [];
  const controller = new EnterpriseHubAdminController(
    {},
    {},
    {
      async listRecommendationSlots(query, context) {
        calls.push({ query, context });
        return { items: [] };
      },
    },
    {},
  );

  const result = await controller.listRecommendationSlots({ boardType: 'company' }, createHeaderBag());

  assert.deepEqual(result, { items: [] });
  assert.equal(calls.length, 1);
  assert.deepEqual(calls[0].query, { boardType: 'company' });
  assert.equal(calls[0].context.authorization, 'Bearer reviewer');
  assert.equal(calls[0].context.actorId, 'spoofed-header-actor');
  assert.equal(calls[0].context.actorRole, 'platform_reviewer');
  assert.equal(calls[0].context.requestId, 'request-1');
  assert.equal(calls[0].context.traceId, 'trace-1');
});

test('applications list fails closed without a carrier before any repository read', async () => {
  const service = createQueryService({
    verificationService: createVerificationService(),
    eligibilityService: createEligibilityService(),
  });

  await assert.rejects(
    () =>
      service.listApplications({}, createRequestContext({
        authorization: '',
        actorRole: '',
      })),
    (error) => {
      assert.equal(error.getStatus(), 401);
      assert.equal(error.getResponse().code, 'AUTH_SESSION_INVALID');
      return true;
    },
  );
});

test('applications detail fails closed for a verified non-reviewer before any repository read', async () => {
  const service = createQueryService({
    verificationService: createVerificationService({
      sessionsByAuthorization: {
        'Bearer owner': createVerifiedCurrentSession('owner-user'),
      },
    }),
    eligibilityService: createEligibilityService({
      reviewerActorIds: ['reviewer-user'],
    }),
  });

  await assert.rejects(
    () =>
      service.getApplicationDetail(
        'application-1',
        createRequestContext({ authorization: 'Bearer owner' }),
      ),
    (error) => {
      assert.equal(error.getStatus(), 403);
      assert.equal(error.getResponse().code, 'AUTH_PERMISSION_INSUFFICIENT');
      return true;
    },
  );
});

test('applications review ignores spoofed reviewer header hints and still fails closed without a carrier', async () => {
  const service = createWriteService({
    verificationService: createVerificationService(),
    eligibilityService: createEligibilityService(),
  });

  await assert.rejects(
    () =>
      service.reviewApplication(
        'application-1',
        { action: 'approved', reviewNote: 'ship it' },
        createRequestContext({
          authorization: '',
          actorId: 'spoofed-header-actor',
          actorRole: 'platform_super_admin',
        }),
      ),
    (error) => {
      assert.equal(error.getStatus(), 401);
      assert.equal(error.getResponse().code, 'AUTH_SESSION_INVALID');
      return true;
    },
  );
});

test('applications review stores reviewerId from verified current-session truth instead of raw header hints', async () => {
  const application = {
    id: 'application-1',
    enterpriseId: 'enterprise-1',
    applicationStatus: 'submitted',
    reviewedAt: null,
    reviewerId: null,
    reviewNote: null,
    rejectionReason: null,
  };
  const service = createWriteService({
    verificationService: createVerificationService({
      sessionsByAuthorization: {
        'Bearer reviewer': createVerifiedCurrentSession('reviewer-user'),
      },
    }),
    eligibilityService: createEligibilityService({
      reviewerActorIds: ['reviewer-user'],
    }),
    applicationRepository: createApplicationWriteRepository(application),
  });

  const result = await service.reviewApplication(
    'application-1',
    { action: 'approved', reviewNote: 'ship it' },
    createRequestContext({
      authorization: 'Bearer reviewer',
      actorId: 'spoofed-header-actor',
      actorRole: 'platform_super_admin',
    }),
  );

  assert.deepEqual(result, { ok: true, traceId: 'trace-1' });
  assert.equal(application.applicationStatus, 'approved');
  assert.equal(application.reviewerId, 'reviewer-user');
  assert.equal(application.reviewNote, 'ship it');
  assert.equal(application.rejectionReason, null);
});

test('applications review requires a frozen reject reason for revision_required', async () => {
  const application = createReviewableApplication();
  const service = createWriteService({
    verificationService: createVerificationService(),
    eligibilityService: createEligibilityService(),
    applicationRepository: createApplicationWriteRepository(application),
  });

  await assert.rejects(
    () =>
      service.reviewApplication(
        'application-1',
        { action: 'revision_required', reviewNote: 'need more detail' },
        createRequestContext(),
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS');
      return true;
    },
  );
});

test('applications review requires a frozen reject reason for rejected', async () => {
  const application = createReviewableApplication();
  const service = createWriteService({
    verificationService: createVerificationService(),
    eligibilityService: createEligibilityService(),
    applicationRepository: createApplicationWriteRepository(application),
  });

  await assert.rejects(
    () =>
      service.reviewApplication(
        'application-1',
        { action: 'rejected', reviewNote: 'cannot approve as-is' },
        createRequestContext(),
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS');
      return true;
    },
  );
});

test('applications review rejects reasons outside the frozen reject-reason family', async () => {
  const application = createReviewableApplication();
  const service = createWriteService({
    verificationService: createVerificationService(),
    eligibilityService: createEligibilityService(),
    applicationRepository: createApplicationWriteRepository(application),
  });

  await assert.rejects(
    () =>
      service.reviewApplication(
        'application-1',
        { action: 'rejected', reason: 'published_change_invalid', reviewNote: 'wrong family' },
        createRequestContext(),
      ),
    (error) => {
      assert.equal(error.getStatus(), 400);
      assert.equal(error.getResponse().code, 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS');
      return true;
    },
  );
});

test('applications review persists rejectionReason from reason and keeps reviewNote supplemental', async () => {
  const application = createReviewableApplication();
  const service = createWriteService({
    verificationService: createVerificationService(),
    eligibilityService: createEligibilityService(),
    applicationRepository: createApplicationWriteRepository(application),
  });

  const result = await service.reviewApplication(
    'application-1',
    {
      action: 'revision_required',
      reason: 'profile_incomplete',
      reviewNote: 'missing workshop and staffing details',
    },
    createRequestContext(),
  );

  assert.deepEqual(result, { ok: true, traceId: 'trace-1' });
  assert.equal(application.applicationStatus, 'revision_required');
  assert.equal(application.rejectionReason, 'profile_incomplete');
  assert.equal(application.reviewNote, 'missing workshop and staffing details');
  assert.equal(application.reviewerId, 'reviewer-user');
});

function createQueryService({
  verificationService,
  eligibilityService,
} = {}) {
  return new EnterpriseHubApplicationReviewAdminQueryService(
    createFailIfTouchedApplicationQueryRepository(),
    createFailIfTouchedRepository('listingRepository.findBy/findOneBy'),
    createFailIfTouchedRepository('companyRepository.findOneBy'),
    createFailIfTouchedRepository('factoryRepository.findOneBy'),
    createFailIfTouchedRepository('supplierRepository.findOneBy'),
    createFailIfTouchedRepository('caseRepository.findBy'),
    createFailIfTouchedRepository('certificationRepository.findBy'),
    createFailIfTouchedRepository('contactRepository.findBy'),
    verificationService,
    eligibilityService,
    createPresenter(),
  );
}

function createWriteService({
  verificationService,
  eligibilityService,
  applicationRepository = createFailIfTouchedRepository('applicationRepository.findOneBy/save'),
} = {}) {
  return new EnterpriseHubApplicationReviewAdminWriteService(
    applicationRepository,
    verificationService,
    eligibilityService,
  );
}

function createVerificationService({
  sessionsByAuthorization = {
    'Bearer reviewer': createVerifiedCurrentSession('reviewer-user'),
  },
} = {}) {
  return {
    async verifyCurrentSessionContext(context) {
      if (!context.authorization.trim()) {
        return {
          outcome: 'failed',
          reason: 'missing_current_session_carrier',
          requestId: context.requestId,
          traceId: context.traceId,
        };
      }
      const currentSession = sessionsByAuthorization[context.authorization];
      if (!currentSession) {
        return {
          outcome: 'failed',
          reason: 'current_session_not_found',
          requestId: context.requestId,
          traceId: context.traceId,
        };
      }
      return {
        outcome: 'verified',
        currentSession: {
          ...currentSession,
          requestId: context.requestId,
          traceId: context.traceId,
        },
      };
    },
  };
}

function createEligibilityService({
  reviewerActorIds = ['reviewer-user'],
} = {}) {
  return {
    async requireReviewer(currentSession) {
      if (!reviewerActorIds.includes(currentSession.actorId)) {
        throw new ForbiddenException({
          code: 'AUTH_PERMISSION_INSUFFICIENT',
          message: 'Current actor lacks reviewer permission for organization review.',
        });
      }
      return {
        actorRole: 'platform_reviewer',
        organizationId: 'platform-org',
        user: { id: currentSession.actorId },
      };
    },
  };
}

function createVerifiedCurrentSession(actorId) {
  return {
    sessionId: `session-${actorId}`,
    actorId,
    userId: actorId,
    organizationId: null,
    requestId: 'request-1',
    traceId: 'trace-1',
  };
}

function createRequestContext(overrides = {}) {
  return {
    authorization: 'Bearer reviewer',
    actorId: 'spoofed-header-actor',
    userId: 'spoofed-header-user',
    organizationId: '',
    actorRole: 'platform_reviewer',
    requestId: 'request-1',
    traceId: 'trace-1',
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
    ...overrides,
  };
}

function createHeaderBag() {
  return {
    authorization: 'Bearer reviewer',
    'x-actor-id': 'spoofed-header-actor',
    'x-user-id': 'spoofed-header-user',
    'x-organization-id': '',
    'x-actor-role': 'platform_reviewer',
    'x-request-id': 'request-1',
    'x-trace-id': 'trace-1',
  };
}

function createFailIfTouchedApplicationQueryRepository() {
  return {
    createQueryBuilder() {
      throw new Error('applicationRepository.createQueryBuilder should not run before reviewer guard passes.');
    },
    async findOneBy() {
      throw new Error('applicationRepository.findOneBy should not run before reviewer guard passes.');
    },
  };
}

function createFailIfTouchedRepository(label) {
  return new Proxy(
    {},
    {
      get(_target, propertyKey) {
        return async () => {
          throw new Error(`${label} was touched via ${String(propertyKey)} before reviewer guard passed.`);
        };
      },
    },
  );
}

function createApplicationWriteRepository(application) {
  return {
    async findOneBy(where) {
      return application.id === where.id ? application : null;
    },
    async save(entity) {
      return entity;
    },
  };
}

function createReviewableApplication() {
  return {
    id: 'application-1',
    enterpriseId: 'enterprise-1',
    applicationStatus: 'submitted',
    reviewedAt: null,
    reviewerId: null,
    reviewNote: null,
    rejectionReason: null,
  };
}

function createPresenter() {
  return {
    toAdminApplicationListItem() {
      return {};
    },
    toPagination(page, pageSize, total) {
      return { page, pageSize, total, hasMore: false };
    },
    toApplicationStatus(application) {
      return application;
    },
  };
}
