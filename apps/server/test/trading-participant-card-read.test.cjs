const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId, organizationId = 'org-owner-1') {
  return {
    authorization: 'Bearer token',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId,
    actorRole: 'buyer_admin',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

test('participant-card returns bounded enterprise summary for admitted thread participant', async () => {
  const {
    TradingImParticipantCardQueryService,
  } = require('../dist/modules/trading_im/trading-im-participant-card.query.service.js');

  const service = new TradingImParticipantCardQueryService(
    {
      async findOneBy(where) {
        if (where.projectId === 'project-1' && where.bidId === 'bid-1') {
          return {
            id: 'thread-1',
            projectId: 'project-1',
            bidId: 'bid-1',
            projectOwnerOrganizationId: 'org-owner-1',
            bidderOrganizationId: 'org-bidder-1',
          };
        }
        return null;
      },
    },
    {
      async findOneBy(where) {
        if (where.organizationId === 'org-bidder-1') {
          return {
            id: 'enterprise-1',
            organizationId: 'org-bidder-1',
            name: '杭州搭建公司',
            logoFileAssetId: 'logo-1',
            primaryBoardType: 'supplier',
            provinceName: '浙江省',
            cityName: '杭州市',
            verificationStatusSnapshot: 'approved',
            enterpriseStatus: 'published',
            displayStatus: 'visible',
          };
        }
        return null;
      },
    },
    {
      async findOneBy(where) {
        if (where.enterpriseId === 'enterprise-1') {
          return {
            avgScore: '4.80',
            reviewCount: 12,
            keywordTags: ['响应快', '沟通顺'],
          };
        }
        return null;
      },
    },
    {
      async findOne(options) {
        if (options.where.organizationId === 'org-bidder-1') {
          return {
            legalName: '杭州搭建展示有限公司',
            businessType: '有限责任公司',
            registeredCapital: '500 万人民币',
            establishedAt: '2020-04-09',
            businessScope: '展览搭建；展示设计',
            certificationStatus: 'approved',
          };
        }
        return null;
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: context.actorId,
            userId: context.userId,
            organizationId: context.organizationId,
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {},
      async getCurrentOrganizationScope() {
        return {
          organization: { id: 'org-owner-1', name: '项目方组织' },
        };
      },
    },
    {
      async buildDisplayUrlMap(fileAssetIds) {
        assert.deepEqual(fileAssetIds, ['logo-1']);
        return new Map([['logo-1', 'https://cdn.example.com/logo-1.png']]);
      },
      readDisplayUrl(fileAssetId, displayUrlMap) {
        return displayUrlMap.get(fileAssetId) ?? null;
      },
    },
    {
      toParticipantCard(payload) {
        return payload;
      },
    },
  );

  const result = await service.getParticipantCard(
    {
      projectId: 'project-1',
      bidId: 'bid-1',
      participantOrganizationId: 'org-bidder-1',
    },
    createContext('participant-card-read'),
  );

  assert.equal(result.participantRole, 'bidder');
  assert.equal(result.enterpriseSummary.displayName, '杭州搭建公司');
  assert.equal(result.enterpriseSummary.logoUrl, 'https://cdn.example.com/logo-1.png');
  assert.equal(result.reviewSummary.avgScore, 4.8);
  assert.deepEqual(result.reviewSummary.keywordTags, ['响应快', '沟通顺']);
  assert.equal(result.formalInfoSummary.legalName, '杭州搭建展示有限公司');
});

test('participant-card fails closed for non-admitted viewer organization', async () => {
  const {
    TradingImParticipantCardQueryService,
  } = require('../dist/modules/trading_im/trading-im-participant-card.query.service.js');

  const service = new TradingImParticipantCardQueryService(
    {
      async findOneBy() {
        return {
          id: 'thread-1',
          projectId: 'project-1',
          bidId: 'bid-1',
          projectOwnerOrganizationId: 'org-owner-1',
          bidderOrganizationId: 'org-bidder-1',
        };
      },
    },
    { async findOneBy() { return null; } },
    { async findOneBy() { return null; } },
    { async findOne() { return null; } },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: context.actorId,
            userId: context.userId,
            organizationId: context.organizationId,
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {},
      async getCurrentOrganizationScope() {
        return {
          organization: { id: 'org-outsider', name: '旁观者组织' },
        };
      },
    },
    {
      async buildDisplayUrlMap() {
        return new Map();
      },
      readDisplayUrl() {
        return null;
      },
    },
    {
      toParticipantCard(payload) {
        return payload;
      },
    },
  );

  await assert.rejects(
    () =>
      service.getParticipantCard(
        {
          projectId: 'project-1',
          bidId: 'bid-1',
          participantOrganizationId: 'org-bidder-1',
        },
        createContext('participant-card-forbidden', 'org-outsider'),
      ),
    (error) => error?.response?.code === 'THREAD_PARTICIPANT_CARD_FORBIDDEN',
  );
});

test('participant-card fails closed when bounded projection is missing', async () => {
  const {
    TradingImParticipantCardQueryService,
  } = require('../dist/modules/trading_im/trading-im-participant-card.query.service.js');

  const service = new TradingImParticipantCardQueryService(
    {
      async findOneBy(where) {
        if (where.projectId === 'project-1' && where.bidId === 'bid-1') {
          return {
            id: 'thread-1',
            projectId: 'project-1',
            bidId: 'bid-1',
            projectOwnerOrganizationId: 'org-owner-1',
            bidderOrganizationId: 'org-bidder-1',
          };
        }
        return null;
      },
    },
    {
      async findOneBy(where) {
        if (where.organizationId === 'org-bidder-1') {
          return {
            id: 'enterprise-1',
            organizationId: 'org-bidder-1',
            name: '杭州搭建公司',
            logoFileAssetId: 'logo-1',
            primaryBoardType: 'supplier',
            provinceName: '浙江省',
            cityName: '杭州市',
            verificationStatusSnapshot: 'approved',
            enterpriseStatus: 'published',
            displayStatus: 'visible',
          };
        }
        return null;
      },
    },
    {
      async findOneBy() {
        return null;
      },
    },
    {
      async findOne(options) {
        if (options.where.organizationId === 'org-bidder-1') {
          return {
            legalName: '杭州搭建展示有限公司',
            businessType: '有限责任公司',
            registeredCapital: '500 万人民币',
            establishedAt: '2020-04-09',
            businessScope: '展览搭建；展示设计',
            certificationStatus: 'approved',
          };
        }
        return null;
      },
    },
    {
      async verifyCurrentSessionContext(context) {
        return {
          outcome: 'verified',
          currentSession: {
            sessionId: 'session-1',
            actorId: context.actorId,
            userId: context.userId,
            organizationId: context.organizationId,
            requestId: context.requestId,
            traceId: context.traceId,
          },
        };
      },
    },
    {
      async requireAuthenticatedActor() {},
      async getCurrentOrganizationScope() {
        return {
          organization: { id: 'org-owner-1', name: '项目方组织' },
        };
      },
    },
    {
      async buildDisplayUrlMap(fileAssetIds) {
        assert.deepEqual(fileAssetIds, ['logo-1']);
        return new Map([['logo-1', 'https://cdn.example.com/logo-1.png']]);
      },
      readDisplayUrl(fileAssetId, displayUrlMap) {
        return displayUrlMap.get(fileAssetId) ?? null;
      },
    },
    {
      toParticipantCard(payload) {
        return payload;
      },
    },
  );

  await assert.rejects(
    () =>
      service.getParticipantCard(
        {
          projectId: 'project-1',
          bidId: 'bid-1',
          participantOrganizationId: 'org-bidder-1',
        },
        createContext('participant-card-missing-projection'),
      ),
    (error) => error?.response?.code === 'THREAD_PARTICIPANT_CARD_UNAVAILABLE',
  );
});
