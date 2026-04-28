const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId) {
  return {
    authorization: 'Bearer project-detail-owner',
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
    projectNo: 'EXH-2026-DD93A8',
    organizationId: 'buyer-org',
    creatorUserId: 'buyer-user',
    creatorActorId: 'buyer-user',
    title: '西洽会 - 泸州',
    exhibitionName: '西洽会',
    brandName: '泸州',
    buildingType: 'exhibition',
    budgetAmount: '120000.00',
    areaSqm: 200,
    buildingTypeRemark: null,
    provinceCode: '500000',
    provinceName: '重庆市',
    cityCode: '500100',
    cityName: '重庆市',
    districtCode: null,
    districtName: null,
    detailAddress: null,
    scopeSummary: null,
    plannedStartAt: '2026-05-16',
    plannedEndAt: '2026-05-23',
    scheduleDetail: null,
    description: null,
    state: 'published',
    summary: {
      heading: '项目已进入最小发布走廊。',
    },
    publishedAt: new Date('2026-04-20T08:00:00.000Z'),
    createdAt: new Date('2026-04-20T08:00:00.000Z'),
    updatedAt: new Date('2026-04-20T08:00:00.000Z'),
    ...overrides,
  };
}

function createService({ project = createProject(), actorOrganizationId = 'buyer-org' } = {}) {
  const { ProjectQueryService } = require('../dist/modules/project/project-query.service.js');
  const { ProjectPresenter } = require('../dist/modules/project/project.presenter.js');

  const queryCalls = [];
  const repository = {
    async findOneBy(query) {
      return query.id === project.id ? project : null;
    },
    async query(sql, params) {
      queryCalls.push({ sql, params });
      if (sql.includes('bid.bidder_organization_id = $2')) {
        assert.deepEqual(params, [project.id, actorOrganizationId]);
        if (actorOrganizationId === 'seller-org') {
          return [
            {
              bidId: 'bid-current',
              state: 'submitted',
            },
          ];
        }
        return [];
      }
      assert.match(sql, /from public\.bids bid/);
      assert.deepEqual(params, [project.id]);
      return [
        {
          bidId: 'bid-1',
          bidNo: 'BID-1',
          bidderOrganizationId: 'seller-org',
          bidderOrganizationName: '重庆展宏展览展示有限公司',
          quoteAmount: '118000.00',
          proposalSummary: '综合报价与交付能力匹配。',
          state: 'submitted',
          submittedAt: new Date('2026-05-20T10:00:00.000Z'),
        },
      ];
    },
  };

  return {
    queryCalls,
    service: new ProjectQueryService(
      repository,
      {
        async verifyCurrentSessionContext(context) {
          return {
            outcome: 'verified',
            currentSession: {
              sessionId: 'session-1',
              actorId: 'buyer-user',
              userId: 'buyer-user',
              organizationId: actorOrganizationId,
              requestId: context.requestId,
              traceId: context.traceId,
            },
          };
        },
      },
      {
        async getCurrentOrganizationScope() {
          return {
            organization: { id: actorOrganizationId },
            membership: { roleKey: 'buyer_admin' },
          };
        },
      },
      {
        async buildSingleProjectProjection() {
          return undefined;
        },
      },
      new ProjectPresenter(),
    ),
  };
}

test('owner project detail exposes bidCandidates and bidSelection from truth anchors', async () => {
  const project = createProject({
    state: 'converted_to_order',
    summary: {
      bidAward: {
        bidAwardId: 'award-1',
        projectId: 'project-1',
        winningBidId: 'bid-1',
        winningOrganizationId: 'seller-org',
        reasonCode: 'publisher_selected_partner',
        reasonText: '发布方选择该竞标方作为当前项目合作方。',
        state: 'converted_to_order',
        orderId: 'order-1',
        contractId: 'contract-1',
        decidedAt: '2026-06-04T10:00:00.000Z',
      },
    },
  });
  const { service } = createService({ project });

  const detail = await service.getProjectById('project-1', createContext('owner-detail'));

  assert.equal(detail.viewerProjectRelation, 'owner');
  assert.deepEqual(detail.bidCandidates, [
    {
      bidId: 'bid-1',
      bidNo: 'BID-1',
      bidderOrganizationId: 'seller-org',
      bidderOrganizationName: '重庆展宏展览展示有限公司',
      quoteAmount: 118000,
      proposalSummary: '综合报价与交付能力匹配。',
      state: 'submitted',
      submittedAt: '2026-05-20T10:00:00.000Z',
    },
  ]);
  assert.deepEqual(detail.bidSelection, {
    winningBidId: 'bid-1',
    orderId: 'order-1',
    contractId: 'contract-1',
  });
});

test('non-owner project detail does not expose owner-only bidCandidates', async () => {
  const { service, queryCalls } = createService({ actorOrganizationId: 'other-org' });

  const detail = await service.getProjectById('project-1', createContext('non-owner-detail'));

  assert.equal(detail.viewerProjectRelation, 'non_owner');
  assert.equal(detail.currentViewerBid, null);
  assert.equal('bidCandidates' in detail, false);
  assert.equal(
    queryCalls.some((call) => call.sql.includes('order by bid.submitted_at asc')),
    false,
  );
});

test('non-owner bidder project detail exposes current viewer bid only', async () => {
  const { service, queryCalls } = createService({ actorOrganizationId: 'seller-org' });

  const detail = await service.getProjectById('project-1', createContext('bidder-detail'));

  assert.equal(detail.viewerProjectRelation, 'non_owner');
  assert.deepEqual(detail.currentViewerBid, {
    bidId: 'bid-current',
    state: 'submitted',
  });
  assert.equal('bidCandidates' in detail, false);
  assert.equal(
    queryCalls.some((call) => call.sql.includes('bid.bidder_organization_id = $2')),
    true,
  );
  assert.equal(
    queryCalls.some((call) => call.sql.includes('order by bid.submitted_at asc')),
    false,
  );
});
