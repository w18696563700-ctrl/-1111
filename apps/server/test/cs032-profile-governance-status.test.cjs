const test = require('node:test');
const assert = require('node:assert/strict');

const context = {
  authorization: 'Bearer test',
  actorId: 'current-actor-1',
  userId: 'current-user-1',
  organizationId: 'platform-org',
  actorRole: 'buyer_admin',
  requestId: 'request-cs032',
  traceId: 'trace-cs032'
};

function makeService(options = {}) {
  const penalties = [...(options.penalties ?? [])];
  const appeals = [...(options.appeals ?? [])];
  const currentSessionVerificationService = {
    verifyCurrentSessionContext: async (receivedContext) => ({
      outcome: 'verified',
      currentSession: {
        sessionId: 'session-1',
        actorId: 'current-actor-1',
        userId: 'current-user-1',
        organizationId: 'platform-org',
        requestId: receivedContext.requestId,
        traceId: receivedContext.traceId
      }
    })
  };
  const eligibilityService = {
    requireAuthenticatedActor: async () => ({ id: 'current-user-1', status: 'active' }),
    getCurrentOrganizationScope: async () => {
      if (options.scope === null) {
        return null;
      }
      return {
        organization: { id: 'platform-org' },
        membership: {
          id: 'member-1',
          memberStatus: 'active',
          roleKey: 'buyer_admin',
          joinedAt: new Date('2026-04-01T00:00:00.000Z'),
          disabledAt: null
        },
        certification: {
          certificationStatus: 'approved',
          legalName: null,
          uscc: null,
          licenseFileId: null,
          submittedAt: null,
          reviewedAt: null,
          reviewedBy: null,
          rejectReason: null,
          expiresAt: null
        },
        roleKeys: ['buyer_admin']
      };
    }
  };
  const penaltyRepository = {
    find: async () => penalties
  };
  const appealRepository = {
    find: async () => appeals
  };
  const { ProfileGovernanceStatusQueryService } = require('../dist/modules/profile/profile-governance-status.query.service.js');
  return {
    service: new ProfileGovernanceStatusQueryService(
      penaltyRepository,
      appealRepository,
      currentSessionVerificationService,
      eligibilityService
    )
  };
}

test('CS-032 profile governance status derives bounded score snapshot from effective penalties and invalidating appeals', async () => {
  const penalties = [
    {
      id: 'pen-warning',
      subjectType: 'organization',
      subjectId: 'platform-org',
      penaltyType: 'warning',
      status: 'active',
      reasonCode: 'warn',
      reasonSummary: 'Warning penalty.',
      evidenceFileAssetIds: [],
      effectiveFrom: new Date('2026-04-01T00:00:00.000Z'),
      effectiveUntil: null,
      createdBy: 'reviewer-user',
      operatorActorId: 'reviewer-user',
      operatorUserId: 'reviewer-user',
      operatorRole: 'platform_reviewer',
      metadata: {},
      createdAt: new Date('2026-04-01T00:00:00.000Z'),
      updatedAt: new Date('2026-04-01T00:00:00.000Z')
    },
    {
      id: 'pen-lifted-watchlist',
      subjectType: 'organization_member',
      subjectId: 'member-1',
      penaltyType: 'watchlist',
      status: 'lifted',
      reasonCode: 'watch',
      reasonSummary: 'Lifted watchlist penalty.',
      evidenceFileAssetIds: [],
      effectiveFrom: new Date('2026-04-02T00:00:00.000Z'),
      effectiveUntil: new Date('2026-04-03T00:00:00.000Z'),
      createdBy: 'reviewer-user',
      operatorActorId: 'reviewer-user',
      operatorUserId: 'reviewer-user',
      operatorRole: 'platform_reviewer',
      metadata: {},
      createdAt: new Date('2026-04-02T00:00:00.000Z'),
      updatedAt: new Date('2026-04-03T00:00:00.000Z')
    },
    {
      id: 'pen-revoked-restrict',
      subjectType: 'organization',
      subjectId: 'platform-org',
      penaltyType: 'restrict_publish',
      status: 'active',
      reasonCode: 'restrict',
      reasonSummary: 'Revoked restrict penalty.',
      evidenceFileAssetIds: [],
      effectiveFrom: new Date('2026-04-03T00:00:00.000Z'),
      effectiveUntil: null,
      createdBy: 'reviewer-user',
      operatorActorId: 'reviewer-user',
      operatorUserId: 'reviewer-user',
      operatorRole: 'platform_reviewer',
      metadata: {},
      createdAt: new Date('2026-04-03T00:00:00.000Z'),
      updatedAt: new Date('2026-04-03T00:00:00.000Z')
    },
    {
      id: 'pen-current-blacklist',
      subjectType: 'organization_member',
      subjectId: 'member-1',
      penaltyType: 'blacklist',
      status: 'active',
      reasonCode: 'black',
      reasonSummary: 'Current blacklist penalty.',
      evidenceFileAssetIds: [],
      effectiveFrom: new Date('2026-04-04T00:00:00.000Z'),
      effectiveUntil: null,
      createdBy: 'reviewer-user',
      operatorActorId: 'reviewer-user',
      operatorUserId: 'reviewer-user',
      operatorRole: 'platform_reviewer',
      metadata: {},
      createdAt: new Date('2026-04-04T00:00:00.000Z'),
      updatedAt: new Date('2026-04-04T00:00:00.000Z')
    }
  ];
  const appeals = [
    {
      id: 'appeal-revoke',
      penaltyId: 'pen-revoked-restrict',
      status: 'revoked',
      reason: 'Please revoke this penalty.',
      decision: 'revoke',
      decisionNote: 'Revoked after review.',
      evidenceFileAssetIds: [],
      submittedBy: 'current-user-1',
      submittedAt: new Date('2026-04-05T00:00:00.000Z'),
      decidedBy: 'reviewer-user',
      decidedAt: new Date('2026-04-10T00:00:00.000Z'),
      metadata: {},
      createdAt: new Date('2026-04-05T00:00:00.000Z'),
      updatedAt: new Date('2026-04-10T00:00:00.000Z')
    },
    {
      id: 'appeal-pending',
      penaltyId: 'pen-current-blacklist',
      status: 'submitted',
      reason: 'Appeal pending on blacklist.',
      decision: null,
      decisionNote: null,
      evidenceFileAssetIds: [],
      submittedBy: 'current-user-1',
      submittedAt: new Date('2026-04-06T00:00:00.000Z'),
      decidedBy: null,
      decidedAt: null,
      metadata: {},
      createdAt: new Date('2026-04-06T00:00:00.000Z'),
      updatedAt: new Date('2026-04-06T00:00:00.000Z')
    }
  ];
  const { service } = makeService({ penalties, appeals });

  const result = await service.getStatus(context);

  assert.deepEqual(result, {
    organizationId: 'platform-org',
    governanceStatus: 'blacklisted',
    whitelistStatus: 'none',
    appealEntryState: 'pending',
    currentPenalty: {
      penaltyId: 'pen-current-blacklist',
      penaltyType: 'blacklist',
      status: 'active',
      effectiveFrom: '2026-04-04T00:00:00.000Z',
      effectiveUntil: null,
      reasonSummary: 'Current blacklist penalty.',
      appealAllowed: false
    },
    violationScoreSnapshot: 8,
    violationScoreUpdatedAt: '2026-04-10T00:00:00.000Z'
  });
});

test('CS-032 profile governance status keeps warning-only current status normal while lifted penalties still count', async () => {
  const penalties = [
    {
      id: 'pen-warning',
      subjectType: 'organization',
      subjectId: 'platform-org',
      penaltyType: 'warning',
      status: 'active',
      reasonCode: 'warn',
      reasonSummary: 'Warning penalty.',
      evidenceFileAssetIds: [],
      effectiveFrom: new Date('2026-04-01T00:00:00.000Z'),
      effectiveUntil: null,
      createdBy: 'reviewer-user',
      operatorActorId: 'reviewer-user',
      operatorUserId: 'reviewer-user',
      operatorRole: 'platform_reviewer',
      metadata: {},
      createdAt: new Date('2026-04-01T00:00:00.000Z'),
      updatedAt: new Date('2026-04-01T00:00:00.000Z')
    },
    {
      id: 'pen-lifted-watchlist',
      subjectType: 'organization_member',
      subjectId: 'member-1',
      penaltyType: 'watchlist',
      status: 'lifted',
      reasonCode: 'watch',
      reasonSummary: 'Lifted watchlist penalty.',
      evidenceFileAssetIds: [],
      effectiveFrom: new Date('2026-04-03T00:00:00.000Z'),
      effectiveUntil: new Date('2026-04-04T00:00:00.000Z'),
      createdBy: 'reviewer-user',
      operatorActorId: 'reviewer-user',
      operatorUserId: 'reviewer-user',
      operatorRole: 'platform_reviewer',
      metadata: {},
      createdAt: new Date('2026-04-03T00:00:00.000Z'),
      updatedAt: new Date('2026-04-04T00:00:00.000Z')
    }
  ];
  const { service } = makeService({ penalties, appeals: [] });

  const result = await service.getStatus(context);

  assert.equal(result.organizationId, 'platform-org');
  assert.equal(result.governanceStatus, 'normal');
  assert.equal(result.whitelistStatus, 'none');
  assert.equal(result.appealEntryState, 'available');
  assert.deepEqual(result.currentPenalty, {
    penaltyId: 'pen-warning',
    penaltyType: 'warning',
    status: 'active',
    effectiveFrom: '2026-04-01T00:00:00.000Z',
    effectiveUntil: null,
    reasonSummary: 'Warning penalty.',
    appealAllowed: true
  });
  assert.equal(result.violationScoreSnapshot, 3);
  assert.equal(result.violationScoreUpdatedAt, '2026-04-03T00:00:00.000Z');
});
