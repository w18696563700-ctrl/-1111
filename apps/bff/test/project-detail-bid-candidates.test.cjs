const test = require('node:test');
const assert = require('node:assert/strict');

const {
  ErrorNormalizerService,
} = require('../dist/apps/bff/src/core/errors/error-normalizer.service.js');
const {
  ProjectService,
} = require('../dist/apps/bff/src/routes/project/project.service.js');

function createService() {
  return new ProjectService(
    {},
    {},
    new ErrorNormalizerService(),
  );
}

function createProjectDetail(overrides = {}) {
  return {
    projectId: 'project-1',
    projectNo: 'EXH-2026-DD93A8',
    title: '西洽会 - 泸州',
    displayTitle: '西洽会',
    exhibitionName: '西洽会',
    brandName: '泸州',
    buildingType: 'exhibition',
    budgetAmount: 120000,
    areaSqm: 200,
    provinceCode: '500000',
    provinceName: '重庆市',
    cityCode: '500100',
    cityName: '重庆市',
    plannedStartAt: '2026-05-16',
    plannedEndAt: '2026-05-23',
    publishedAt: '2026-04-30T08:15:00.000Z',
    state: 'published',
    nameAccess: {
      status: 'visible',
      canRequest: false,
      requestId: null,
    },
    summary: {
      heading: '项目已进入最小发布走廊。',
    },
    buildingTypeRemark: null,
    districtCode: null,
    districtName: null,
    detailAddress: null,
    scopeSummary: null,
    scheduleDetail: null,
    viewerProjectRelation: 'owner',
    description: null,
    ...overrides,
  };
}

test('project detail BFF read model preserves owner bidCandidates and bidSelection', () => {
  const service = createService();

  const detail = service.toProjectDetailReadModel(
    createProjectDetail({
      bidCandidates: [
        {
          bidId: 'bid-1',
          bidNo: 'BID-1',
          bidderOrganizationId: 'seller-org',
          bidderOrganizationName: '重庆展宏展览展示有限公司',
          quoteAmount: '118000.00',
          proposalSummary: '综合报价与交付能力匹配。',
          state: 'submitted',
          submittedAt: '2026-05-20T10:00:00.000Z',
          ignored: 'must-strip',
        },
      ],
      bidSelection: {
        winningBidId: 'bid-1',
        orderId: 'order-1',
        contractId: 'contract-1',
        ignored: 'must-strip',
      },
    }),
  );

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

test('project detail BFF read model defaults missing bidCandidates to empty owner-only carrier', () => {
  const service = createService();

  const detail = service.toProjectDetailReadModel(createProjectDetail());

  assert.deepEqual(detail.bidCandidates, []);
  assert.equal(detail.bidSelection, null);
  assert.equal(detail.currentViewerBid, null);
});

test('project detail BFF read model projects currentViewerBid from server only', () => {
  const service = createService();

  const detail = service.toProjectDetailReadModel(
    createProjectDetail({
      viewerProjectRelation: 'non_owner',
      currentViewerBid: {
        bidId: 'bid-current',
        state: 'submitted',
        ignored: 'must-strip',
      },
    }),
  );

  assert.deepEqual(detail.currentViewerBid, {
    bidId: 'bid-current',
    state: 'submitted',
  });
  assert.deepEqual(detail.bidCandidates, []);
});
