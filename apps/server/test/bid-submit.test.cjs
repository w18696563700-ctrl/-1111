const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId) {
  return {
    authorization: 'Bearer bid-token',
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

function createProject(overrides = {}) {
  return {
    id: 'project-1',
    projectNo: 'PROJ-2026-1',
    organizationId: 'buyer-org',
    creatorUserId: 'buyer-user',
    creatorActorId: 'buyer-user',
    title: '展台项目',
    buildingType: 'exhibition',
    budgetAmount: '1000.00',
    state: 'published',
    publishedAt: new Date('2026-04-10T08:00:00.000Z'),
    ...overrides,
  };
}

function createCurrentSession(overrides = {}) {
  return {
    sessionId: 'session-1',
    actorId: 'supplier-user',
    userId: 'supplier-user',
    organizationId: 'supplier-org',
    requestId: 'bid-eligibility',
    traceId: 'trace-bid-eligibility',
    ...overrides,
  };
}

function createEligibilityService({
  organizationId = 'supplier-org',
  organizationType = 'supplier',
  roleKey = 'supplier_admin',
  certificationStatus = 'approved',
  personalCertificationStatus = 'approved',
  certifiedUserId = 'supplier-user',
} = {}) {
  const { CurrentActorEligibilityService } = require('../dist/modules/organization/current-actor-eligibility.service.js');
  return new CurrentActorEligibilityService(
    {
      async findOneBy() {
        return { id: 'supplier-user', status: 'active' };
      },
    },
    {
      async findOneBy() {
        return { id: organizationId, organizationType, lifecycleStatus: 'active' };
      },
    },
    {
      async findOneBy() {
        return {
          organizationId,
          userId: 'supplier-user',
          memberStatus: 'active',
          roleKey,
        };
      },
      async find() {
        return [];
      },
    },
    {
      async findOne() {
        return {
          organizationId,
          certificationStatus,
          legalName: '供应商',
          uscc: '91310000TEST00002',
          licenseFileId: 'file-1',
          submittedAt: new Date('2026-04-01T00:00:00.000Z'),
          reviewedAt: new Date('2026-04-02T00:00:00.000Z'),
          reviewedBy: 'reviewer-1',
          rejectReason: null,
          expiresAt: null,
          updatedAt: new Date('2026-04-02T00:00:00.000Z'),
        };
      },
    },
    {
      async findOne() {
        return {
          organizationId,
          certificationStatus: personalCertificationStatus,
          userId: certifiedUserId,
          realName: '张三',
          idNumberMasked: '500***********1234',
          idCardFrontFileId: 'file-id-front',
          providerRequestId: 'provider-1',
          submittedAt: new Date('2026-04-01T00:00:00.000Z'),
          reviewedAt: new Date('2026-04-02T00:00:00.000Z'),
          rejectReason: null,
          lockedAt: certifiedUserId === 'supplier-user' ? null : new Date('2026-04-02T00:00:00.000Z'),
          createdAt: new Date('2026-04-01T00:00:00.000Z'),
          updatedAt: new Date('2026-04-02T00:00:00.000Z'),
        };
      },
    },
  );
}

test('bid submit eligibility uses organization type plus dual certification as the main gate', async () => {
  const bothService = createEligibilityService({
    organizationId: 'both-org',
    organizationType: 'both',
    roleKey: 'buyer_admin',
  });
  const supplierService = createEligibilityService({
    organizationId: 'supplier-org',
    organizationType: 'supplier',
    roleKey: 'supplier_admin',
  });

  const allowedBoth = await bothService.requireBidSubmitEligibility(
    createCurrentSession({ organizationId: 'both-org' }),
    createProject(),
  );
  assert.equal(allowedBoth.organization.id, 'both-org');
  assert.equal(allowedBoth.membership.roleKey, 'buyer_admin');

  const allowedSupplier = await supplierService.requireBidSubmitEligibility(
    createCurrentSession({ organizationId: 'supplier-org' }),
    createProject(),
  );
  assert.equal(allowedSupplier.organization.id, 'supplier-org');
  assert.equal(allowedSupplier.membership.roleKey, 'supplier_admin');
});

test('bid submit eligibility still rejects demand-only scope, locked certification, unpublished project, and owner relation', async () => {
  const demandOnlyService = createEligibilityService({
    organizationId: 'demand-org',
    organizationType: 'demand',
    roleKey: 'buyer_admin',
  });
  const lockedService = createEligibilityService({
    organizationId: 'both-org',
    organizationType: 'both',
    roleKey: 'buyer_admin',
    certifiedUserId: 'other-user',
  });
  const allowedService = createEligibilityService({
    organizationId: 'both-org',
    organizationType: 'both',
    roleKey: 'buyer_admin',
  });

  await assert.rejects(
    () =>
      demandOnlyService.requireBidSubmitEligibility(
        createCurrentSession({ organizationId: 'demand-org' }),
        createProject(),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(error?.response?.details?.reason, 'organization_type_not_allowed');
      return true;
    },
  );
  await assert.rejects(
    () =>
      lockedService.requireBidSubmitEligibility(
        createCurrentSession({ organizationId: 'both-org' }),
        createProject(),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(error?.response?.details?.reason, 'personal_certification_locked');
      return true;
    },
  );
  await assert.rejects(
    () =>
      allowedService.requireBidSubmitEligibility(
        createCurrentSession({ organizationId: 'both-org' }),
        createProject({ organizationId: 'both-org' }),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(error?.response?.details?.reason, 'owner_relation_not_allowed');
      return true;
    },
  );
  await assert.rejects(
    () =>
      allowedService.requireBidSubmitEligibility(
        createCurrentSession({ organizationId: 'both-org' }),
        createProject({ state: 'bidding_closed' }),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'AUTH_PERMISSION_INSUFFICIENT');
      assert.equal(error?.response?.details?.reason, 'project_not_published');
      return true;
    },
  );
});

test('bid submit writes bid truth and append-only audit, then returns accepted bidId', async () => {
  const { BidEntity } = require('../dist/modules/bid/entities/bid.entity.js');
  const { IdentityAuditLogEntity } = require('../dist/modules/audit/identity-audit-log.entity.js');
  const { BidWriteService } = require('../dist/modules/bid/bid-write.service.js');
  const savedBids = [];
  const savedAudit = [];
  const service = new BidWriteService(
    {
      create(input) {
        return input;
      },
    },
    {
      async findOneBy() {
        return createProject();
      },
    },
    {
      async transaction(callback) {
        return callback({
          getRepository(entity) {
            if (entity === BidEntity) {
              return {
                async findOneBy() {
                  return null;
                },
                async save(value) {
                  savedBids.push(value);
                  return value;
                },
              };
            }
            if (entity === IdentityAuditLogEntity) {
              return {
                async save(value) {
                  savedAudit.push(value);
                  return value;
                },
              };
            }
            throw new Error('unexpected repository');
          },
        });
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'supplier-user',
            userId: 'supplier-user',
            organizationId: 'supplier-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireBidSubmitEligibilityFromContext(context, resolver, project) {
        const verified = await resolver.verifyCurrentSessionContext(context);
        return {
          currentSession: verified.currentSession,
          scope: {
            organization: { id: 'supplier-org' },
            membership: { roleKey: 'supplier_admin' },
            certification: { certificationStatus: 'approved' },
            roleKeys: ['supplier_admin'],
          },
          project,
        };
      },
    },
    {
      toAcceptedResponse(bidId) {
        return { bidId };
      },
    },
  );

  const result = await service.submitBid(
    {
      projectId: 'project-1',
      quoteAmount: 88888,
      proposalSummary: '供应商最小报价与执行方案',
    },
    createContext('bid-submit'),
  );

  assert.equal(savedBids.length, 1);
  assert.equal(savedBids[0].projectId, 'project-1');
  assert.match(savedBids[0].bidNo, /^BID-PROJ-2026-1-[0-9A-F]{12}$/);
  assert.equal(savedBids[0].bidderOrganizationId, 'supplier-org');
  assert.equal(savedBids[0].organizationId, 'supplier-org');
  assert.equal(savedBids[0].quoteAmount, '88888.00');
  assert.equal(savedBids[0].state, 'submitted');
  assert.equal(savedBids[0].submittedBy, 'supplier-user');
  assert.ok(savedBids[0].submittedAt instanceof Date);
  assert.equal(savedAudit.length, 1);
  assert.equal(savedAudit[0].objectType, 'bid');
  assert.equal(savedAudit[0].action, 'BidSubmitted');
  assert.equal(savedAudit[0].afterState, 'submitted');
  assert.deepEqual(result, { bidId: savedBids[0].id });
});

test('bid submit rejects same organization duplicate submission with controlled conflict', async () => {
  const { BidEntity } = require('../dist/modules/bid/entities/bid.entity.js');
  const { IdentityAuditLogEntity } = require('../dist/modules/audit/identity-audit-log.entity.js');
  const { BidWriteService } = require('../dist/modules/bid/bid-write.service.js');
  const service = new BidWriteService(
    {
      create(input) {
        return input;
      },
    },
    {
      async findOneBy() {
        return createProject();
      },
    },
    {
      async transaction(callback) {
        return callback({
          getRepository(entity) {
            if (entity === BidEntity) {
              return {
                async findOneBy() {
                  return {
                    id: 'existing-bid',
                    projectId: 'project-1',
                    bidderOrganizationId: 'supplier-org',
                  };
                },
                async save() {
                  throw new Error('should not save duplicate bid');
                },
              };
            }
            if (entity === IdentityAuditLogEntity) {
              return {
                async save() {
                  throw new Error('should not append audit for duplicate bid');
                },
              };
            }
            throw new Error('unexpected repository');
          },
        });
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'supplier-user',
            userId: 'supplier-user',
            organizationId: 'supplier-org',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireBidSubmitEligibilityFromContext(context, resolver, project) {
        const verified = await resolver.verifyCurrentSessionContext(context);
        return {
          currentSession: verified.currentSession,
          scope: {
            organization: { id: 'supplier-org' },
            membership: { roleKey: 'supplier_admin' },
            certification: { certificationStatus: 'approved' },
            roleKeys: ['supplier_admin'],
          },
          project,
        };
      },
    },
    {
      toAcceptedResponse(bidId) {
        return { bidId };
      },
    },
  );

  await assert.rejects(
    () =>
      service.submitBid(
        {
          projectId: 'project-1',
          quoteAmount: 88888,
          proposalSummary: '供应商最小报价与执行方案',
        },
        createContext('bid-duplicate'),
      ),
    (error) => {
      assert.equal(error?.response?.code, 'BID_DUPLICATE_SUBMISSION');
      assert.equal(
        error?.response?.message,
        'Current actor has already submitted a bid for this project.',
      );
      return true;
    },
  );
});

test('bid submit rejects malformed body and unavailable project with controlled errors', async () => {
  const { BidWriteService } = require('../dist/modules/bid/bid-write.service.js');
  const service = new BidWriteService(
    { create(input) { return input; } },
    {
      async findOneBy() {
        return null;
      },
    },
    {
      async transaction() {
        throw new Error('should not start transaction');
      },
    },
    { async verifyCurrentSessionContext() { throw new Error('should not verify'); } },
    { async requireBidSubmitEligibilityFromContext() { throw new Error('should not check eligibility'); } },
    { toAcceptedResponse(bidId) { return { bidId }; } },
  );

  await assert.rejects(
    () => service.submitBid({ quoteAmount: 1, proposalSummary: 'x' }, createContext('invalid')),
    (error) => error?.response?.code === 'BID_SUBMIT_INVALID',
  );
  await assert.rejects(
    () =>
      service.submitBid(
        { projectId: 'missing-project', quoteAmount: 1, proposalSummary: 'x' },
        createContext('unavailable'),
      ),
    (error) => error?.response?.code === 'AUTH_RESOURCE_UNAVAILABLE',
  );
});

test('bid duplicate submission migration registers explicit project plus bidder uniqueness', () => {
  const {
    bidDuplicateSubmitRepairMigrations,
    serverMigrations,
  } = require('../dist/core/migrations/migrations.js');
  const migration = bidDuplicateSubmitRepairMigrations.find(
    (item) => item.key === '20260415_bid_duplicate_submission_controlled_repair',
  );

  assert.ok(migration);
  assert.ok(serverMigrations.includes(migration));
  assert.match(
    migration.statements.join('\n'),
    /CREATE UNIQUE INDEX IF NOT EXISTS idx_bids_project_bidder_unique/,
  );
});
