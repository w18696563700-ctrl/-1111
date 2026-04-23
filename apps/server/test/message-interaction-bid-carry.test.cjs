const test = require('node:test');
const assert = require('node:assert/strict');

function createContext(requestId) {
  return {
    authorization: 'Bearer carry-token',
    actorId: 'actor-1',
    userId: 'user-1',
    organizationId: 'org-1',
    actorRole: 'supplier_admin',
    requestId,
    traceId: `trace-${requestId}`,
    userAgent: 'node-test',
    remoteIp: '127.0.0.1',
  };
}

test('my bids list returns controlled empty list when current bidder scope has no bids', async () => {
  const { MyBidQueryService } = require('../dist/modules/my_bid/my-bid.query.service.js');
  const service = new MyBidQueryService(
    {
      async find() {
        return [];
      },
      async findOneBy() {
        return null;
      },
    },
    {
      async findBy() {
        return [];
      },
      async findOneBy() {
        return null;
      },
    },
    {
      async findBy() {
        return [];
      },
    },
    {
      async findOneBy() {
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
          organization: { id: 'org-1', name: '测试供应商' },
        };
      },
    },
    {
      toListResponse(items) {
        return { items };
      },
      toSnapshot() {
        throw new Error('not used');
      },
    },
  );

  const result = await service.listMyBids(undefined, createContext('my-bids-empty'));
  assert.deepEqual(result, { items: [] });
});

test('message interactions list returns project communication lane and empty items when no admitted interaction exists', async () => {
  const {
    MessageInteractionQueryService,
  } = require('../dist/modules/message_interaction/message-interaction.query.service.js');
  const service = new MessageInteractionQueryService(
    {
      async find() {
        return [];
      },
    },
    {
      async find() {
        return [];
      },
    },
    {
      async findBy() {
        return [];
      },
    },
    {
      async findBy() {
        return [];
      },
    },
    {
      async findBy() {
        return [];
      },
    },
    {
      async findBy() {
        return [];
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
          organization: { id: 'org-1', name: '测试供应商' },
        };
      },
    },
    {
      toListResponse(lane, items) {
        return { lane, items };
      },
      toLastMessageSummary() {
        throw new Error('not used');
      },
    },
  );

  const result = await service.listInteractions(undefined, createContext('message-interactions-empty'));
  assert.deepEqual(result, {
    lane: 'project_communication',
    items: [],
  });
});
