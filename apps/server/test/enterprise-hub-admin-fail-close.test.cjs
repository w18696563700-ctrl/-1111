const test = require('node:test');
const assert = require('node:assert/strict');
const { ForbiddenException } = require('@nestjs/common');

const {
  EnterpriseHubAdminService,
} = require('../dist/modules/enterprise_hub/enterprise-hub-admin.service.js');

const ADMIN_COMMANDS = [
  {
    name: 'publishListing',
    run: (service, context) =>
      service.publishListing('enterprise-1', { operatorId: 'operator-1' }, context),
  },
  {
    name: 'offlineListing',
    run: (service, context) =>
      service.offlineListing('enterprise-1', { reason: 'risk_control' }, context),
  },
  {
    name: 'freezeListing',
    run: (service, context) =>
      service.freezeListing('enterprise-1', { reason: 'risk_control' }, context),
  },
  {
    name: 'listRecommendationSlots',
    run: (service, context) => service.listRecommendationSlots({}, context),
  },
  {
    name: 'createRecommendationSlot',
    run: (service, context) =>
      service.createRecommendationSlot(
        {
          boardType: 'company',
          slotPosition: 1,
          enterpriseId: 'enterprise-1',
          startAt: '2026-05-01T00:00:00.000Z',
          endAt: '2026-05-02T00:00:00.000Z',
          sourceType: 'manual',
        },
        context,
      ),
  },
];

test('enterprise hub admin commands fail closed without a verified current session before repository access', async () => {
  for (const command of ADMIN_COMMANDS) {
    const service = createService({
      verificationService: createVerificationService({ mode: 'missing' }),
      eligibilityService: createEligibilityService(),
    });

    await assert.rejects(
      () => command.run(service, createContext({ authorization: '' })),
      (error) => {
        assert.equal(error.getStatus(), 401, command.name);
        assert.equal(error.getResponse().code, 'AUTH_SESSION_INVALID', command.name);
        return true;
      },
    );
  }
});

test('enterprise hub admin commands fail closed for verified non-reviewers before repository access', async () => {
  for (const command of ADMIN_COMMANDS) {
    const service = createService({
      verificationService: createVerificationService({ mode: 'verified' }),
      eligibilityService: createEligibilityService({ allowReviewer: false }),
    });

    await assert.rejects(
      () => command.run(service, createContext()),
      (error) => {
        assert.equal(error.getStatus(), 403, command.name);
        assert.equal(error.getResponse().code, 'AUTH_PERMISSION_INSUFFICIENT', command.name);
        return true;
      },
    );
  }
});

function createService({
  verificationService = createVerificationService({ mode: 'verified' }),
  eligibilityService = createEligibilityService(),
} = {}) {
  return new EnterpriseHubAdminService(
    createFailIfTouchedRepository('applicationRepository'),
    createFailIfTouchedRepository('listingRepository'),
    createFailIfTouchedRepository('recommendationSlotRepository'),
    createPresenter(),
    verificationService,
    eligibilityService,
  );
}

function createFailIfTouchedRepository(name) {
  const fail = (method) => {
    throw new Error(`${name}.${method} must not be touched before reviewer verification.`);
  };
  return {
    findOne: () => fail('findOne'),
    findOneBy: () => fail('findOneBy'),
    find: () => fail('find'),
    findBy: () => fail('findBy'),
    save: () => fail('save'),
    create: () => fail('create'),
  };
}

function createPresenter() {
  return {
    toAdminRecommendationSlotItem(value) {
      return value;
    },
  };
}

function createVerificationService({ mode }) {
  return {
    async verifyCurrentSessionContext(context) {
      if (mode !== 'verified') {
        return {
          outcome: 'failed',
          reason: 'missing_current_session_carrier',
          requestId: context.requestId,
          traceId: context.traceId,
        };
      }
      return {
        outcome: 'verified',
        currentSession: {
          sessionId: 'session-1',
          actorId: 'actor-1',
          userId: 'user-1',
          organizationId: null,
          requestId: context.requestId,
          traceId: context.traceId,
        },
      };
    },
  };
}

function createEligibilityService({ allowReviewer = true } = {}) {
  return {
    async requireReviewer(currentSession) {
      if (!allowReviewer) {
        throw new ForbiddenException({
          code: 'AUTH_PERMISSION_INSUFFICIENT',
          message: 'Current actor lacks reviewer permission for enterprise hub admin.',
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

function createContext(overrides = {}) {
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
