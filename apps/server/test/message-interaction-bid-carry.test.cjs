const test = require('node:test');
const assert = require('node:assert/strict');

const avatarUrlService = {
  async buildAccessUrlFromObjectUrl(value) {
    return value ? `${value}?signed=1` : null;
  },
};

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
    avatarUrlService,
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
      async listConversations() {
        return [];
      },
    },
    {
      toListResponse(lane, items) {
        return { lane, items };
      },
      toCounterpartConversationDetail(detail) {
        return detail;
      },
    },
  );

  const result = await service.listInteractions(undefined, createContext('message-interactions-empty'));
  assert.deepEqual(result, {
    lane: 'project_communication',
    items: [],
  });
});

test('message interactions list returns counterpart conversation container cards', async () => {
  const {
    MessageInteractionQueryService,
  } = require('../dist/modules/message_interaction/message-interaction.query.service.js');
  const service = new MessageInteractionQueryService(
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
          organization: { id: 'org-owner', name: '重庆坤特展览展示有限公司' },
        };
      },
    },
    {
      async listConversations() {
        return [
          {
            interactionId: 'org-1',
            interactionType: 'counterpart_conversation',
            conversationId: 'org-1',
            projectId: 'project-1',
            counterpart: {
              organizationId: 'org-1',
              displayName: '重庆海川展览工厂',
              avatarUrl: null,
              role: 'counterpart',
            },
            summary: {
              focusProjectId: 'project-1',
              title: '新的竞标已提交',
              text: '重庆海川展览工厂 已对当前项目提交竞标。',
              projectCount: 1,
              latestCardType: 'bid_thread',
            },
            updatedAt: '2026-04-24T08:05:00.000Z',
            routeTarget: {
              objectType: 'counterpart_conversation',
              actionKey: 'counterpart_conversation.open',
              canonicalPath: '/api/app/message/counterpart-conversation/detail',
              params: {
                conversationId: 'org-1',
                projectId: 'project-1',
              },
            },
          },
        ];
      },
    },
    {
      toListResponse(lane, items) {
        return { lane, items };
      },
      toCounterpartConversationDetail(detail) {
        return detail;
      },
    },
  );

  const result = await service.listInteractions(
    undefined,
    createContext('message-interactions-with-seed'),
  );
  assert.equal(result.lane, 'project_communication');
  assert.equal(result.items.length, 1);
  assert.deepEqual(result.items[0].counterpart, {
    organizationId: 'org-1',
    displayName: '重庆海川展览工厂',
    avatarUrl: null,
    role: 'counterpart',
  });
  assert.deepEqual(result.items[0].summary, {
    focusProjectId: 'project-1',
    title: '新的竞标已提交',
    text: '重庆海川展览工厂 已对当前项目提交竞标。',
    projectCount: 1,
    latestCardType: 'bid_thread',
  });
});

test('counterpart conversation detail keeps every business card anchored to project truth', async () => {
  const {
    MessageInteractionQueryService,
  } = require('../dist/modules/message_interaction/message-interaction.query.service.js');
  const service = new MessageInteractionQueryService(
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
          organization: { id: 'org-owner', name: '重庆坤特展览展示有限公司' },
        };
      },
    },
    {
      async listConversations() {
        return [];
      },
      async getConversationDetail(input) {
        assert.deepEqual(input, {
          viewerOrganizationId: 'org-owner',
          conversationId: 'org-1',
          focusProjectId: 'project-1',
        });
        return {
          conversationId: 'org-1',
          counterpart: {
            organizationId: 'org-1',
            displayName: '重庆海川展览工厂',
            avatarUrl: null,
            role: 'counterpart',
          },
          summary: {
            focusProjectId: 'project-1',
            title: '项目名称查看申请',
            text: '重庆海川展览工厂 申请查看当前项目名称。',
            projectCount: 1,
            latestCardType: 'project_name_access_request',
          },
          focusProjectId: 'project-1',
          latestActivityAt: '2026-04-24T08:05:00.000Z',
          projectGroups: [
            {
              projectId: 'project-1',
              projectDisplayTitle: '项目名称需申请查看',
              titleVisibility: 'masked',
              projectState: 'published',
              latestActivityAt: '2026-04-24T08:05:00.000Z',
              cards: [
                {
                  cardId: 'project-name-access:request-1',
                  cardType: 'project_name_access_request',
                  title: '项目名称查看申请',
                  summary: '重庆海川展览工厂 申请查看当前项目名称。',
                  status: 'pending',
                  updatedAt: '2026-04-24T08:05:00.000Z',
                  truthAnchor: {
                    truthType: 'project_name_access_request',
                    projectId: 'project-1',
                    requestId: 'request-1',
                    threadId: 'request-1',
                  },
                  detailRouteTarget: {
                    objectType: 'project_name_access_thread',
                    actionKey: 'project_name_access_thread.open',
                    canonicalPath: '/api/app/project/name-access/thread/detail',
                    params: {
                      threadId: 'request-1',
                      projectId: 'project-1',
                      requestId: 'request-1',
                    },
                  },
                  decisionAvailability: {
                    canApprove: true,
                    canReject: true,
                  },
                },
              ],
            },
          ],
        };
      },
    },
    {
      toListResponse(lane, items) {
        return { lane, items };
      },
      toCounterpartConversationDetail(detail) {
        return detail;
      },
    },
  );

  const result = await service.getCounterpartConversationDetail(
    'org-1',
    'project-1',
    createContext('counterpart-conversation-detail'),
  );
  assert.equal(result.projectGroups.length, 1);
  assert.equal(
    result.projectGroups[0].cards[0].truthAnchor.projectId,
    'project-1',
  );
  assert.deepEqual(result.projectGroups[0].cards[0].decisionAvailability, {
    canApprove: true,
    canReject: true,
  });
});

test('bid submission snapshot returns canonical attachment list instead of hardcoded zero', async () => {
  const { MyBidQueryService } = require('../dist/modules/my_bid/my-bid.query.service.js');
  const submittedAt = new Date('2026-04-24T08:00:00.000Z');
  const service = new MyBidQueryService(
    {
      async find() {
        return [];
      },
      async findOneBy() {
        return {
          id: 'bid-1',
          projectId: 'project-1',
          bidderOrganizationId: 'org-1',
          organizationId: 'org-1',
          userId: 'user-bidder',
          quoteAmount: '8800.00',
          proposalSummary: '先做结构、灯光与现场安装。',
          submittedAt,
          state: 'submitted',
          projectUnderstandingFileAssetId: 'file-understanding-1',
          quoteSheetFileAssetId: 'file-quote-1',
          schedulePlanFileAssetId: 'file-schedule-1',
        };
      },
    },
    {
      async findBy() {
        return [];
      },
      async findOneBy() {
        return {
          id: 'project-1',
          organizationId: 'org-owner',
          state: 'published',
        };
      },
    },
    {
      async findBy() {
        return [];
      },
    },
    {
      async findOneBy() {
        return { id: 'org-1', name: '重庆海川展览工厂' };
      },
    },
    {
      async findOneBy(where) {
        if (where.id === 'user-bidder') {
          return {
            id: 'user-bidder',
            avatarUrl: 'https://oss.example.com/private/avatar-bidder.png',
          };
        }
        return null;
      },
    },
    {
      async findBy() {
        return [
          {
            id: 'file-understanding-1',
            fileKind: 'bid_project_understanding',
            mimeType: 'application/pdf',
          },
          {
            id: 'file-quote-1',
            fileKind: 'bid_quote_sheet',
            mimeType: 'application/vnd.ms-excel',
          },
          {
            id: 'file-schedule-1',
            fileKind: 'bid_schedule_plan',
            mimeType: 'application/pdf',
          },
        ];
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
          organization: { id: 'org-owner', name: '重庆坤特展览展示有限公司' },
        };
      },
    },
    avatarUrlService,
    {
      toListResponse(items) {
        return { items };
      },
      toSnapshot(snapshot) {
        return snapshot;
      },
    },
  );

  const result = await service.getSubmissionSnapshot(
    { projectId: 'project-1', bidId: 'bid-1' },
    createContext('snapshot-attachments'),
  );

  assert.equal(result.attachmentSummary.count, 3);
  assert.deepEqual(result.attachments, [
    {
      slotKey: 'project_understanding',
      slotLabel: '项目理解',
      fileAssetId: 'file-understanding-1',
      fileKind: 'bid_project_understanding',
      mimeType: 'application/pdf',
    },
    {
      slotKey: 'quote_sheet',
      slotLabel: '报价表',
      fileAssetId: 'file-quote-1',
      fileKind: 'bid_quote_sheet',
      mimeType: 'application/vnd.ms-excel',
    },
    {
      slotKey: 'schedule_plan',
      slotLabel: '进度安排',
      fileAssetId: 'file-schedule-1',
      fileKind: 'bid_schedule_plan',
      mimeType: 'application/pdf',
    },
  ]);
  assert.equal(result.availability.participantCardReadable, true);
  assert.equal(
    result.bidder.avatarUrl,
    'https://oss.example.com/private/avatar-bidder.png?signed=1',
  );
});

test('bid submission snapshot resolves legacy attachment slots when canonical ids are absent', async () => {
  const { MyBidQueryService } = require('../dist/modules/my_bid/my-bid.query.service.js');
  const submittedAt = new Date('2026-04-24T08:00:00.000Z');
  const service = new MyBidQueryService(
    {
      async find() {
        return [];
      },
      async findOneBy() {
        return {
          id: 'bid-legacy-1',
          projectId: 'project-1',
          bidderOrganizationId: 'org-1',
          organizationId: 'org-1',
          quoteAmount: '8800.00',
          proposalSummary: '先做结构、灯光与现场安装。',
          submittedAt,
          state: 'submitted',
          projectUnderstandingFileAssetId: null,
          quoteSheetFileAssetId: null,
          schedulePlanFileAssetId: null,
        };
      },
    },
    {
      async findBy() {
        return [];
      },
      async findOneBy() {
        return {
          id: 'project-1',
          organizationId: 'org-owner',
          state: 'published',
        };
      },
    },
    {
      async findBy() {
        return [];
      },
    },
    {
      async findOneBy() {
        return { id: 'org-1', name: '重庆海川展览工厂' };
      },
    },
    {
      async findOneBy(where) {
        if (where.id === 'user-bidder') {
          return {
            id: 'user-bidder',
            avatarUrl: 'https://oss.example.com/private/avatar-bidder.png',
          };
        }
        return null;
      },
    },
    {
      async findBy() {
        throw new Error('canonical attachment ids should not be used for legacy snapshot compatibility');
      },
      async find(options) {
        assert.equal(options.where.organizationId, 'org-1');
        assert.equal(options.where.businessType, 'project');
        assert.equal(options.where.businessId, 'project-1');
        return [
          {
            id: 'file-understanding-legacy-1',
            organizationId: 'org-1',
            businessType: 'project',
            businessId: 'project-1',
            fileKind: 'bid_project_understanding',
            mimeType: 'application/pdf',
            createdAt: new Date('2026-04-24T07:45:00.000Z'),
          },
          {
            id: 'file-quote-legacy-1',
            organizationId: 'org-1',
            businessType: 'project',
            businessId: 'project-1',
            fileKind: 'bid_quote_sheet',
            mimeType: 'application/vnd.ms-excel',
            createdAt: new Date('2026-04-24T07:46:00.000Z'),
          },
          {
            id: 'file-schedule-legacy-1',
            organizationId: 'org-1',
            businessType: 'project',
            businessId: 'project-1',
            fileKind: 'bid_schedule_plan',
            mimeType: 'application/pdf',
            createdAt: new Date('2026-04-24T07:47:00.000Z'),
          },
        ];
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
          organization: { id: 'org-owner', name: '重庆坤特展览展示有限公司' },
        };
      },
    },
    avatarUrlService,
    {
      toListResponse(items) {
        return { items };
      },
      toSnapshot(snapshot) {
        return snapshot;
      },
    },
  );

  const result = await service.getSubmissionSnapshot(
    { projectId: 'project-1', bidId: 'bid-legacy-1' },
    createContext('snapshot-legacy-attachments'),
  );

  assert.equal(result.attachmentSummary.count, 3);
  assert.deepEqual(result.attachments.map((item) => item.fileAssetId), [
    'file-understanding-legacy-1',
    'file-quote-legacy-1',
    'file-schedule-legacy-1',
  ]);
});
