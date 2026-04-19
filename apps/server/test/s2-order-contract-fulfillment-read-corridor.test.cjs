const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(authorization, requestId) {
  return {
    authorization,
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

function createQueryRepository({
  scopedOrder,
  contract,
  milestones,
  inspection,
  orderError,
  contractError,
  milestoneError,
}) {
  return {
    async query(sql, params) {
      if (sql.includes('from public.orders "order"') && params[0] === 'order-1') {
        if (orderError) {
          throw orderError;
        }
        return scopedOrder ? [scopedOrder] : [];
      }
      if (sql.includes('from public.contracts contract') && params[0] === 'order-1') {
        if (contractError) {
          throw contractError;
        }
        return contract ? [contract] : [];
      }
      if (sql.includes('from public.milestones milestone') && params[0] === 'order-1') {
        if (milestoneError) {
          throw milestoneError;
        }
        return milestones ?? [];
      }
      if (sql.includes('from public.inspections inspection') && params[0] === 'milestone-1') {
        return inspection ? [inspection] : [];
      }
      return [];
    },
  };
}

function createVerifiedServices() {
  return {
    verifier: {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: 'user-1',
            userId: 'user-1',
            organizationId: 'org-buyer',
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    eligibility: {
      async requireAuthenticatedActor() {
        return { id: 'user-1', status: 'active' };
      },
      async getCurrentOrganizationScope() {
        return {
          organization: { id: 'org-buyer' },
          membership: { roleKey: 'buyer_admin' },
          certification: { certificationStatus: 'approved' },
          roleKeys: ['buyer_admin'],
        };
      },
    },
  };
}

test('S2 read corridor exposes scoped order, contract, milestone, and inspection carriers', async () => {
  const {
    TradingReadCorridorPresenter,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.presenter.js');
  const {
    TradingReadCorridorQueryService,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.query.service.js');

  const { verifier, eligibility } = createVerifiedServices();
  const service = new TradingReadCorridorQueryService(
    createQueryRepository({
      scopedOrder: {
        orderId: 'order-1',
        orderNo: 'ORD-1',
        projectId: 'project-1',
        bidId: 'bid-1',
        buyerOrganizationId: 'org-buyer',
        supplierOrganizationId: 'org-supplier',
        title: '主场展台施工订单',
        totalAmount: 1200,
        state: 'active',
        activatedAt: '2026-04-09T10:00:00.000Z',
        createdAt: '2026-04-09T09:00:00.000Z',
        updatedAt: '2026-04-09T11:00:00.000Z',
      },
      contract: {
        contractId: 'contract-1',
        orderId: 'order-1',
        state: 'pending_confirm',
        summaryText: '合同待双方确认',
        confirmedAt: null,
        createdAt: '2026-04-09T09:30:00.000Z',
        updatedAt: '2026-04-09T10:30:00.000Z',
        amendCount: 0,
      },
      milestones: [
        {
          milestoneId: 'milestone-1',
          orderId: 'order-1',
          sequenceNo: 1,
          title: '结构搭建与主材进场',
          amount: 62000,
          state: 'pending_submission',
          submittedAt: null,
          submittedBy: null,
          submissionNote: null,
          createdAt: '2026-04-09T10:00:00.000Z',
          updatedAt: '2026-04-09T10:20:00.000Z',
        },
        {
          milestoneId: 'milestone-2',
          orderId: 'order-1',
          sequenceNo: 2,
          title: '超出冻结边界的已完工节点',
          amount: 38000,
          state: 'completed',
          submittedAt: '2026-04-09T10:30:00.000Z',
          submittedBy: 'user-1',
          submissionNote: 'done',
          createdAt: '2026-04-09T10:00:00.000Z',
          updatedAt: '2026-04-09T10:40:00.000Z',
        },
      ],
      inspection: {
        inspectionId: 'inspection-1',
        milestoneId: 'milestone-1',
        orderId: 'order-1',
        state: 'submitted',
        summaryText: '验收单已提交',
        submittedAt: '2026-04-09T12:00:00.000Z',
        submittedBy: 'user-1',
        createdAt: '2026-04-09T11:30:00.000Z',
        updatedAt: '2026-04-09T12:00:00.000Z',
        rectificationCount: 0,
        recheckCount: 0,
      },
    }),
    verifier,
    eligibility,
    new TradingReadCorridorPresenter(),
  );

  const orderDetail = await service.getOrderDetail(
    'order-1',
    createContext('Bearer token', 'order-detail'),
  );
  assert.deepEqual(orderDetail, {
    orderId: 'order-1',
    orderNo: 'ORD-1',
    projectId: 'project-1',
    bidId: 'bid-1',
    state: 'active',
    summary: { heading: '主场展台施工订单' },
    milestones: [
      {
        milestoneId: 'milestone-1',
        orderId: 'order-1',
        title: '结构搭建与主材进场',
        amount: 62000,
        state: 'pending_submission',
        summary: { heading: '当前里程碑待提交。' },
      },
    ],
  });

  const contractDetail = await service.getContractDetail(
    'order-1',
    createContext('Bearer token', 'contract-detail'),
  );
  assert.deepEqual(contractDetail, {
    contractId: 'contract-1',
    orderId: 'order-1',
    state: 'pending_confirm',
    summary: { heading: '合同待双方确认' },
  });

  const milestoneList = await service.listMilestones(
    'order-1',
    createContext('Bearer token', 'milestone-list'),
  );
  assert.deepEqual(milestoneList, {
    items: [
      {
        milestoneId: 'milestone-1',
        orderId: 'order-1',
        title: '结构搭建与主材进场',
        amount: 62000,
        state: 'pending_submission',
        summary: { heading: '当前里程碑待提交。' },
      },
    ],
  });

  const inspectionDetail = await service.getInspectionDetail(
    'milestone-1',
    createContext('Bearer token', 'inspection-detail'),
  );
  assert.deepEqual(inspectionDetail, {
    inspectionId: 'inspection-1',
    milestoneId: 'milestone-1',
    state: 'submitted',
    summary: { heading: '验收单已提交' },
  });
});

test('S2 order and contract detail reject missing orderId with controlled invalid results', async () => {
  const {
    TradingReadCorridorPresenter,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.presenter.js');
  const {
    TradingReadCorridorQueryService,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.query.service.js');

  const { verifier, eligibility } = createVerifiedServices();
  const service = new TradingReadCorridorQueryService(
    createQueryRepository({}),
    verifier,
    eligibility,
    new TradingReadCorridorPresenter(),
  );

  await assert.rejects(
    () => service.getOrderDetail(undefined, createContext('Bearer token', 'order-missing-id')),
    (error) => error?.response?.code === 'ORDER_DETAIL_INVALID',
  );
  await assert.rejects(
    () =>
      service.getContractDetail(undefined, createContext('Bearer token', 'contract-missing-id')),
    (error) => error?.response?.code === 'CONTRACT_DETAIL_INVALID',
  );
});

test('S2 read corridor fail-closes when current actor is outside the scoped order chain', async () => {
  const {
    TradingReadCorridorPresenter,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.presenter.js');
  const {
    TradingReadCorridorQueryService,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.query.service.js');

  const { verifier, eligibility } = createVerifiedServices();
  const service = new TradingReadCorridorQueryService(
    createQueryRepository({
      scopedOrder: null,
      contract: null,
      milestones: [],
      inspection: null,
    }),
    verifier,
    eligibility,
    new TradingReadCorridorPresenter(),
  );

  await assert.rejects(
    () => service.getOrderDetail('order-1', createContext('Bearer token', 'order-miss')),
    (error) => error?.response?.code === 'AUTH_RESOURCE_UNAVAILABLE',
  );
  await assert.rejects(
    () =>
      service.getContractDetail('order-1', createContext('Bearer token', 'contract-miss')),
    (error) => error?.response?.code === 'CONTRACT_ENTRY_UNAVAILABLE',
  );
  await assert.rejects(
    () =>
      service.listMilestones('order-1', createContext('Bearer token', 'milestone-miss')),
    (error) => error?.response?.code === 'AUTH_RESOURCE_UNAVAILABLE',
  );
  await assert.rejects(
    () =>
      service.getInspectionDetail(
        'milestone-1',
        createContext('Bearer token', 'inspection-miss'),
      ),
    (error) => error?.response?.code === 'INSPECTION_ENTRY_UNAVAILABLE',
  );
});

test('S2 inspection and order read corridor keep out-of-bound states unavailable', async () => {
  const {
    TradingReadCorridorPresenter,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.presenter.js');
  const {
    TradingReadCorridorQueryService,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.query.service.js');

  const { verifier, eligibility } = createVerifiedServices();
  const service = new TradingReadCorridorQueryService(
    createQueryRepository({
      scopedOrder: {
        orderId: 'order-1',
        orderNo: 'ORD-1',
        projectId: 'project-1',
        bidId: 'bid-1',
        buyerOrganizationId: 'org-buyer',
        supplierOrganizationId: 'org-supplier',
        title: '已完结订单',
        totalAmount: 1200,
        state: 'completed',
        activatedAt: '2026-04-09T10:00:00.000Z',
        createdAt: '2026-04-09T09:00:00.000Z',
        updatedAt: '2026-04-09T11:00:00.000Z',
      },
      contract: {
        contractId: 'contract-1',
        orderId: 'order-1',
        state: 'active',
        summaryText: 'active contract',
        confirmedAt: '2026-04-09T10:30:00.000Z',
        createdAt: '2026-04-09T09:30:00.000Z',
        updatedAt: '2026-04-09T10:30:00.000Z',
        amendCount: 0,
      },
      milestones: [],
      inspection: {
        inspectionId: 'inspection-1',
        milestoneId: 'milestone-1',
        orderId: 'order-1',
        state: 'passed',
        summaryText: 'outside frozen set',
        submittedAt: '2026-04-09T12:00:00.000Z',
        submittedBy: 'user-1',
        createdAt: '2026-04-09T11:30:00.000Z',
        updatedAt: '2026-04-09T12:00:00.000Z',
        rectificationCount: 0,
        recheckCount: 0,
      },
    }),
    verifier,
    eligibility,
    new TradingReadCorridorPresenter(),
  );

  await assert.rejects(
    () =>
      service.getOrderDetail('order-1', createContext('Bearer token', 'order-completed')),
    (error) => error?.response?.code === 'AUTH_RESOURCE_UNAVAILABLE',
  );
  await assert.rejects(
    () =>
      service.getInspectionDetail(
        'milestone-1',
        createContext('Bearer token', 'inspection-passed'),
      ),
    (error) => error?.response?.code === 'INSPECTION_ENTRY_UNAVAILABLE',
  );
});

test('S2 contract detail fail-closes when order is visible but contract truth is absent or not readable', async () => {
  const {
    TradingReadCorridorPresenter,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.presenter.js');
  const {
    TradingReadCorridorQueryService,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.query.service.js');

  const { verifier, eligibility } = createVerifiedServices();
  const visibleOrder = {
    orderId: 'order-1',
    orderNo: 'ORD-1',
    projectId: 'project-1',
    bidId: 'bid-1',
    buyerOrganizationId: 'org-buyer',
    supplierOrganizationId: 'org-supplier',
    title: '可见订单',
    totalAmount: 1200,
    state: 'active',
    activatedAt: '2026-04-09T10:00:00.000Z',
    createdAt: '2026-04-09T09:00:00.000Z',
    updatedAt: '2026-04-09T11:00:00.000Z',
  };

  const serviceWithoutContract = new TradingReadCorridorQueryService(
    createQueryRepository({
      scopedOrder: visibleOrder,
      contract: null,
      milestones: [],
      inspection: null,
    }),
    verifier,
    eligibility,
    new TradingReadCorridorPresenter(),
  );
  await assert.rejects(
    () =>
      serviceWithoutContract.getContractDetail(
        'order-1',
        createContext('Bearer token', 'contract-absent'),
      ),
    (error) => error?.response?.code === 'CONTRACT_ENTRY_UNAVAILABLE',
  );

  const serviceWithUnreadableContract = new TradingReadCorridorQueryService(
    createQueryRepository({
      scopedOrder: visibleOrder,
      contract: {
        contractId: 'contract-1',
        orderId: 'order-1',
        state: 'cancelled',
        summaryText: 'hidden contract state',
        confirmedAt: null,
        createdAt: '2026-04-09T09:30:00.000Z',
        updatedAt: '2026-04-09T10:30:00.000Z',
        amendCount: 0,
      },
      milestones: [],
      inspection: null,
    }),
    verifier,
    eligibility,
    new TradingReadCorridorPresenter(),
  );
  await assert.rejects(
    () =>
      serviceWithUnreadableContract.getContractDetail(
        'order-1',
        createContext('Bearer token', 'contract-unreadable-state'),
      ),
    (error) => error?.response?.code === 'CONTRACT_ENTRY_UNAVAILABLE',
  );
});

test('S2 order and contract detail hide upstream query failures behind controlled unavailable results', async () => {
  const {
    TradingReadCorridorPresenter,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.presenter.js');
  const {
    TradingReadCorridorQueryService,
  } = require('../dist/modules/trading_read_corridor/trading-read-corridor.query.service.js');

  const { verifier, eligibility } = createVerifiedServices();

  const orderFailureService = new TradingReadCorridorQueryService(
    createQueryRepository({
      orderError: new Error('db connection reset'),
    }),
    verifier,
    eligibility,
    new TradingReadCorridorPresenter(),
  );
  await assert.rejects(
    () =>
      orderFailureService.getOrderDetail(
        'order-1',
        createContext('Bearer token', 'order-db-error'),
      ),
    (error) =>
      error?.response?.code === 'AUTH_RESOURCE_UNAVAILABLE' &&
      error?.response?.message === 'Current order detail is unavailable.',
  );

  const contractFailureService = new TradingReadCorridorQueryService(
    createQueryRepository({
      scopedOrder: {
        orderId: 'order-1',
        orderNo: 'ORD-1',
        projectId: 'project-1',
        bidId: 'bid-1',
        buyerOrganizationId: 'org-buyer',
        supplierOrganizationId: 'org-supplier',
        title: '可见订单',
        totalAmount: 1200,
        state: 'active',
        activatedAt: '2026-04-09T10:00:00.000Z',
        createdAt: '2026-04-09T09:00:00.000Z',
        updatedAt: '2026-04-09T11:00:00.000Z',
      },
      contractError: new Error('contracts relation missing'),
    }),
    verifier,
    eligibility,
    new TradingReadCorridorPresenter(),
  );
  await assert.rejects(
    () =>
      contractFailureService.getContractDetail(
        'order-1',
        createContext('Bearer token', 'contract-db-error'),
      ),
    (error) =>
      error?.response?.code === 'CONTRACT_ENTRY_UNAVAILABLE' &&
      error?.response?.message === 'Current contract entry is unavailable.',
  );
});
