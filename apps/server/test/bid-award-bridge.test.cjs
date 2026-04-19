const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId) {
  return {
    authorization: 'Bearer bid-award-token',
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
    title: '展台项目',
    state: 'published',
    summary: {},
    publishedAt: '2026-04-10T08:00:00.000Z',
    ...overrides,
  };
}

function createBid(overrides = {}) {
  return {
    id: 'bid-1',
    projectId: 'project-1',
    organizationId: 'supplier-org',
    quoteAmount: '88888.00',
    proposalSummary: '最小投标方案',
    state: 'submitted',
    ...overrides,
  };
}

function createAwardHarness(overrides = {}) {
  const state = {
    lockAvailable: overrides.lockAvailable ?? true,
    failOnOrderInsert: overrides.failOnOrderInsert ?? null,
    failOnContractInsert: overrides.failOnContractInsert ?? null,
    hasOrderCreatedByColumn: overrides.hasOrderCreatedByColumn ?? false,
    hasContractNoColumn: overrides.hasContractNoColumn ?? false,
    project: createProject(overrides.project),
    bids: structuredClone(
      overrides.bids ?? [
        createBid({ id: 'bid-winning', organizationId: 'supplier-win' }),
        createBid({ id: 'bid-losing', organizationId: 'supplier-lose', quoteAmount: '99999.00' }),
      ],
    ),
    orders: structuredClone(overrides.orders ?? []),
    contracts: structuredClone(overrides.contracts ?? []),
    auditLogs: structuredClone(overrides.auditLogs ?? []),
  };

  return {
    state,
    dataSource: {
      async transaction(callback) {
        const draft = structuredClone(state);
        const manager = {
          async query(sql, params) {
            if (sql.includes('pg_try_advisory_xact_lock')) {
              return [{ locked: draft.lockAvailable }];
            }

            if (sql.includes('from project project') && sql.includes('for update')) {
              return draft.project && draft.project.id === params[0] ? [draft.project] : [];
            }

            if (
              sql.includes('from public.orders "order"') &&
              sql.includes('"order".project_id = $1') &&
              sql.includes('for update')
            ) {
              return draft.orders
                .filter((order) => order.projectId === params[0])
                .map((order) => ({ orderId: order.orderId }));
            }

            if (
              sql.includes('from public.contracts contract') &&
              sql.includes('"order".project_id = $1') &&
              sql.includes('for update')
            ) {
              return draft.contracts
                .map((contract) => {
                  const order = draft.orders.find((candidate) => candidate.orderId === contract.orderId);
                  if (!order || order.projectId !== params[0]) {
                    return null;
                  }
                  return {
                    contractId: contract.contractId,
                    orderId: contract.orderId,
                  };
                })
                .filter(Boolean);
            }

            if (sql.includes('from bids bid') && sql.includes('for update')) {
              return draft.bids
                .filter((bid) => bid.projectId === params[0])
                .map((bid) => ({ ...bid }));
            }

            if (
              sql.includes('from information_schema.columns') &&
              sql.includes("table_name = 'orders'")
            ) {
              return draft.hasOrderCreatedByColumn ? [{ columnName: 'created_by' }] : [];
            }

            if (
              sql.includes('from information_schema.columns') &&
              sql.includes("table_name = 'contracts'")
            ) {
              return draft.hasContractNoColumn ? [{ columnName: 'contract_no' }] : [];
            }

            if (sql.includes('insert into public.orders')) {
              if (draft.failOnOrderInsert) {
                throw draft.failOnOrderInsert;
              }
              const hasCreatedBy = sql.includes('created_by');
              draft.orders.push({
                orderId: params[0],
                orderNo: params[1],
                projectId: params[2],
                bidId: params[3],
                buyerOrganizationId: params[4],
                supplierOrganizationId: params[5],
                title: params[6],
                totalAmount: params[7],
                state: params[8],
                activatedAt: params[9],
                createdBy: hasCreatedBy ? params[10] : null,
              });
              return [];
            }

            if (sql.includes('insert into public.contracts')) {
              if (draft.failOnContractInsert) {
                throw draft.failOnContractInsert;
              }
              const hasContractNo = sql.includes('contract_no');
              draft.contracts.push({
                contractId: params[0],
                orderId: params[1],
                state: params[2],
                summaryText: params[3],
                amendCount: params[4],
                contractNo: hasContractNo ? params[5] : null,
              });
              return [];
            }

            if (sql.includes('update public.bids')) {
              for (const bid of draft.bids) {
                if (bid.projectId !== params[0]) {
                  continue;
                }
                bid.state = bid.id === params[1] ? params[2] : params[3];
              }
              return [];
            }

            if (sql.includes('update project')) {
              draft.project.state = params[1];
              draft.project.summary = JSON.parse(params[2]);
              return [];
            }

            throw new Error(`unexpected sql: ${sql}`);
          },
          getRepository(entity) {
            if (entity.name === 'IdentityAuditLogEntity') {
              return {
                async save(value) {
                  draft.auditLogs.push(value);
                  return value;
                },
              };
            }
            throw new Error(`unexpected repository ${entity?.name ?? 'unknown'}`);
          },
        };

        try {
          const result = await callback(manager);
          Object.assign(state, draft);
          return result;
        } catch (error) {
          throw error;
        }
      },
    },
  };
}

function createEligibilityService(requestId) {
  return {
    async requireProjectPublishEligibilityFromContext() {
      return {
        currentSession: {
          sessionId: 'session-1',
          actorId: 'buyer-user',
          userId: 'buyer-user',
          organizationId: 'buyer-org',
          requestId,
          traceId: `trace-${requestId}`,
        },
        scope: {
          organization: { id: 'buyer-org' },
          membership: { roleKey: 'buyer_admin' },
        },
      };
    },
  };
}

test('BidAward P0 mainline closes bid award, order conversion, contract seed, and project conversion in one transaction', async () => {
  const { BidAwardWriteService } = require('../dist/modules/bid_award/bid-award.write.service.js');
  const { BidAwardPresenter } = require('../dist/modules/bid_award/bid-award.presenter.js');

  const harness = createAwardHarness();
  const service = new BidAwardWriteService(
    harness.dataSource,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService('bid-award-mainline'),
    new BidAwardPresenter(),
  );

  const result = await service.award(
    {
      projectId: 'project-1',
      winningBidId: 'bid-winning',
      reasonCode: 'commercial_fit',
      reasonText: '综合报价与交付能力最优',
    },
    createContext('bid-award-mainline'),
  );

  assert.equal(harness.state.project.state, 'converted_to_order');
  assert.equal(harness.state.project.summary.bidAward.projectId, 'project-1');
  assert.equal(harness.state.project.summary.bidAward.winningBidId, 'bid-winning');
  assert.equal(harness.state.project.summary.bidAward.reasonCode, 'commercial_fit');
  assert.equal(harness.state.project.summary.bidAward.state, 'converted_to_order');
  assert.equal(harness.state.orders.length, 1);
  assert.equal(harness.state.orders[0].projectId, 'project-1');
  assert.equal(harness.state.orders[0].bidId, 'bid-winning');
  assert.equal(harness.state.orders[0].state, 'active');
  assert.equal(harness.state.orders[0].buyerOrganizationId, 'buyer-org');
  assert.equal(harness.state.orders[0].supplierOrganizationId, 'supplier-win');
  assert.equal(harness.state.contracts.length, 1);
  assert.equal(harness.state.contracts[0].orderId, harness.state.orders[0].orderId);
  assert.equal(harness.state.contracts[0].state, 'pending_confirm');
  assert.equal(harness.state.bids[0].state, 'awarded');
  assert.equal(harness.state.bids[1].state, 'lost');
  assert.equal(harness.state.auditLogs.length, 1);
  assert.equal(harness.state.auditLogs[0].action, 'BidAwarded');
  assert.equal(harness.state.auditLogs[0].afterState, 'converted_to_order');
  assert.equal(result.projectId, 'project-1');
  assert.equal(result.winningBidId, 'bid-winning');
  assert.equal(result.state, 'converted_to_order');
  assert.equal(result.orderId, harness.state.orders[0].orderId);
  assert.equal(result.contractId, harness.state.contracts[0].contractId);
});

test('BidAward P0 order conversion stays compatible when orders schema requires created_by and non-null title', async () => {
  const { BidAwardWriteService } = require('../dist/modules/bid_award/bid-award.write.service.js');
  const { BidAwardPresenter } = require('../dist/modules/bid_award/bid-award.presenter.js');

  const harness = createAwardHarness({
    hasOrderCreatedByColumn: true,
    project: createProject({
      projectNo: 'RC-PROJ-2026-1',
      title: null,
    }),
  });
  const service = new BidAwardWriteService(
    harness.dataSource,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService('bid-award-order-schema'),
    new BidAwardPresenter(),
  );

  const result = await service.award(
    {
      projectId: 'project-1',
      winningBidId: 'bid-winning',
      reasonCode: 'commercial_fit',
      reasonText: '综合报价与交付能力最优',
    },
    createContext('bid-award-order-schema'),
  );

  assert.equal(result.state, 'converted_to_order');
  assert.equal(harness.state.orders.length, 1);
  assert.equal(harness.state.orders[0].title, 'RC-PROJ-2026-1');
  assert.equal(harness.state.orders[0].createdBy, 'buyer-user');
});

test('BidAward P0 contract seed stays compatible when contracts schema requires contract_no NOT NULL', async () => {
  const { BidAwardWriteService } = require('../dist/modules/bid_award/bid-award.write.service.js');
  const { BidAwardPresenter } = require('../dist/modules/bid_award/bid-award.presenter.js');

  const harness = createAwardHarness({
    hasContractNoColumn: true,
    project: createProject({
      projectNo: 'RC-CONTRACT-2026-1',
    }),
  });
  const service = new BidAwardWriteService(
    harness.dataSource,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService('bid-award-contract-schema'),
    new BidAwardPresenter(),
  );

  const result = await service.award(
    {
      projectId: 'project-1',
      winningBidId: 'bid-winning',
      reasonCode: 'commercial_fit',
      reasonText: '综合报价与交付能力最优',
    },
    createContext('bid-award-contract-schema'),
  );

  assert.equal(result.state, 'converted_to_order');
  assert.equal(harness.state.contracts.length, 1);
  assert.equal(harness.state.contracts[0].contractNo, 'CTR-RC-CONTRACT-2026-1');
});

test('BidAward P0 result outlet remains readable for winner and loser after project converted_to_order', async () => {
  const { BidAwardQueryService } = require('../dist/modules/bid_award/bid-award.query.service.js');
  const { BidAwardPresenter } = require('../dist/modules/bid_award/bid-award.presenter.js');

  const project = createProject({
    state: 'converted_to_order',
    summary: {
      bidAward: {
        bidAwardId: 'award-1',
        projectId: 'project-1',
        winningBidId: 'bid-winning',
        winningOrganizationId: 'supplier-win',
        reasonCode: 'commercial_fit',
        reasonText: '综合报价与交付能力最优',
        state: 'converted_to_order',
        orderId: 'order-1',
        contractId: 'contract-1',
        decidedAt: '2026-04-12T10:00:00.000Z',
      },
    },
  });

  const winningService = new BidAwardQueryService(
    { async findOneBy() { return project; } },
    { async find() { return [createBid({ id: 'bid-winning', organizationId: 'supplier-win', state: 'awarded' })]; } },
    { async verifyCurrentSessionContext() { return { outcome: 'verified', currentSession: { sessionId: 'session-1', actorId: 'supplier-user', userId: 'supplier-user', organizationId: 'supplier-win', requestId: 'bid-result-win', traceId: 'trace-bid-result-win' } }; } },
    {
      async requireBidQualifiedScope() {
        return { organization: { id: 'supplier-win' }, roleKeys: ['buyer_admin'] };
      },
    },
    new BidAwardPresenter(),
  );

  const losingService = new BidAwardQueryService(
    { async findOneBy() { return project; } },
    { async find() { return [createBid({ id: 'bid-losing', organizationId: 'supplier-lose', state: 'lost' })]; } },
    { async verifyCurrentSessionContext() { return { outcome: 'verified', currentSession: { sessionId: 'session-2', actorId: 'supplier-user', userId: 'supplier-user', organizationId: 'supplier-lose', requestId: 'bid-result-lose', traceId: 'trace-bid-result-lose' } }; } },
    {
      async requireBidQualifiedScope() {
        return { organization: { id: 'supplier-lose' }, roleKeys: ['buyer_admin'] };
      },
    },
    new BidAwardPresenter(),
  );

  assert.deepEqual(await winningService.getResult('project-1', createContext('bid-result-win')), {
    bidId: 'bid-winning',
    projectId: 'project-1',
    state: 'awarded',
    result: 'won',
    reasonCode: 'commercial_fit',
    reasonText: '综合报价与交付能力最优',
    decidedAt: '2026-04-12T10:00:00.000Z',
  });

  assert.deepEqual(await losingService.getResult('project-1', createContext('bid-result-lose')), {
    bidId: 'bid-losing',
    projectId: 'project-1',
    state: 'lost',
    result: 'lost',
    reasonCode: 'commercial_fit',
    reasonText: '综合报价与交付能力最优',
    decidedAt: '2026-04-12T10:00:00.000Z',
  });
});

test('BidAward P0 duplicate guard still fail-closes when an effective downstream continuation already exists', async () => {
  const { BidAwardWriteService } = require('../dist/modules/bid_award/bid-award.write.service.js');
  const { BidAwardPresenter } = require('../dist/modules/bid_award/bid-award.presenter.js');

  const harness = createAwardHarness({
    project: createProject({ state: 'converted_to_order' }),
    orders: [{ orderId: 'order-1', projectId: 'project-1' }],
    contracts: [{ contractId: 'contract-1', orderId: 'order-1' }],
  });
  const service = new BidAwardWriteService(
    harness.dataSource,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService('bid-award-duplicate'),
    new BidAwardPresenter(),
  );

  await assert.rejects(
    () =>
      service.award(
        {
          projectId: 'project-1',
          winningBidId: 'bid-winning',
          reasonCode: 'commercial_fit',
          reasonText: '综合报价与交付能力最优',
        },
        createContext('bid-award-duplicate'),
      ),
    (error) => error?.response?.code === 'BID_AWARD_DUPLICATE',
  );
});

test('BidAward P0 concurrent guard returns BID_AWARD_CONCURRENT_CONFLICT and leaves state untouched', async () => {
  const { BidAwardWriteService } = require('../dist/modules/bid_award/bid-award.write.service.js');
  const { BidAwardPresenter } = require('../dist/modules/bid_award/bid-award.presenter.js');

  const harness = createAwardHarness({ lockAvailable: false });
  const snapshot = structuredClone(harness.state);
  const service = new BidAwardWriteService(
    harness.dataSource,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService('bid-award-concurrent'),
    new BidAwardPresenter(),
  );

  await assert.rejects(
    () =>
      service.award(
        {
          projectId: 'project-1',
          winningBidId: 'bid-winning',
          reasonCode: 'commercial_fit',
          reasonText: '综合报价与交付能力最优',
        },
        createContext('bid-award-concurrent'),
      ),
    (error) => error?.response?.code === 'BID_AWARD_CONCURRENT_CONFLICT',
  );

  assert.deepEqual(harness.state, snapshot);
});

test('BidAward P0 rollback keeps project, bids, order, and contract clean when synchronous contract seed fails', async () => {
  const { BidAwardWriteService } = require('../dist/modules/bid_award/bid-award.write.service.js');
  const { BidAwardPresenter } = require('../dist/modules/bid_award/bid-award.presenter.js');

  const harness = createAwardHarness({
    failOnContractInsert: Object.assign(new Error('contract seed failed'), { code: 'boom' }),
  });
  const snapshot = {
    project: structuredClone(harness.state.project),
    bids: structuredClone(harness.state.bids),
    orders: structuredClone(harness.state.orders),
    contracts: structuredClone(harness.state.contracts),
    auditLogs: structuredClone(harness.state.auditLogs),
  };
  const service = new BidAwardWriteService(
    harness.dataSource,
    { async verifyCurrentSessionContext() { throw new Error('should not verify directly'); } },
    createEligibilityService('bid-award-rollback'),
    new BidAwardPresenter(),
  );

  await assert.rejects(
    () =>
      service.award(
        {
          projectId: 'project-1',
          winningBidId: 'bid-winning',
          reasonCode: 'commercial_fit',
          reasonText: '综合报价与交付能力最优',
        },
        createContext('bid-award-rollback'),
      ),
    (error) => error?.response?.code === 'CONTRACT_SEED_FAILED',
  );

  assert.deepEqual(harness.state.project, snapshot.project);
  assert.deepEqual(harness.state.bids, snapshot.bids);
  assert.deepEqual(harness.state.orders, snapshot.orders);
  assert.deepEqual(harness.state.contracts, snapshot.contracts);
  assert.deepEqual(harness.state.auditLogs, snapshot.auditLogs);
});

test('BidAward P0 guard rejects invalid request shape and invalid supplier result query', async () => {
  const { BidAwardWriteService } = require('../dist/modules/bid_award/bid-award.write.service.js');
  const { BidAwardQueryService } = require('../dist/modules/bid_award/bid-award.query.service.js');
  const { BidAwardPresenter } = require('../dist/modules/bid_award/bid-award.presenter.js');

  const writeService = new BidAwardWriteService(
    { async transaction() { throw new Error('should not start transaction'); } },
    { async verifyCurrentSessionContext() { throw new Error('should not verify'); } },
    { async requireProjectPublishEligibilityFromContext() { throw new Error('should not check'); } },
    new BidAwardPresenter(),
  );

  await assert.rejects(
    () => writeService.award({ projectId: 'project-1' }, createContext('bid-award-invalid')),
    (error) => error?.response?.code === 'BID_AWARD_INVALID',
  );

  const queryService = new BidAwardQueryService(
    { async findOneBy() { throw new Error('should not query project'); } },
    { async find() { throw new Error('should not query bids'); } },
    { async verifyCurrentSessionContext() { throw new Error('should not verify'); } },
    {
      async requireBidQualifiedScope() { throw new Error('should not scope'); },
    },
    new BidAwardPresenter(),
  );

  await assert.rejects(
    () => queryService.getResult('', createContext('bid-result-invalid')),
    (error) => error?.response?.code === 'BID_RESULT_INVALID',
  );
});
