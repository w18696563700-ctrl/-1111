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

function createDisplayNameService(certifications = []) {
  const {
    CounterpartConversationDisplayNameService,
  } = require('../dist/modules/message_interaction/counterpart-conversation-display-name.service.js');
  return new CounterpartConversationDisplayNameService({
    async find() {
      return certifications;
    },
  });
}

function createProjectNameAccessRequestRepository(requests) {
  return {
    createQueryBuilder() {
      const builder = {
        innerJoin() {
          return builder;
        },
        where() {
          return builder;
        },
        orWhere() {
          return builder;
        },
        orderBy() {
          return builder;
        },
        addOrderBy() {
          return builder;
        },
        async getMany() {
          return requests;
        },
      };
      return builder;
    },
  };
}

function createBidParticipationRequestRepository(requests) {
  return {
    createQueryBuilder() {
      const builder = {
        innerJoin() {
          return builder;
        },
        where() {
          return builder;
        },
        orWhere() {
          return builder;
        },
        orderBy() {
          return builder;
        },
        addOrderBy() {
          return builder;
        },
        async getMany() {
          return requests;
        },
      };
      return builder;
    },
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

test('bid-thread counterpart displayName uses approved certification legalName first', async () => {
  const {
    CounterpartConversationBidThreadSource,
  } = require('../dist/modules/message_interaction/counterpart-conversation.bid-thread-source.js');
  const submittedAt = new Date('2026-04-24T08:00:00.000Z');
  const updatedAt = new Date('2026-04-24T08:05:00.000Z');
  const source = new CounterpartConversationBidThreadSource(
    {
      async find() {
        return [
          {
            id: 'thread-1',
            projectId: 'project-1',
            bidId: 'bid-1',
            updatedAt,
            lifecycleState: 'active',
          },
        ];
      },
    },
    {
      async find() {
        return [];
      },
    },
    {
      async findBy() {
        return [
          {
            id: 'bid-1',
            projectId: 'project-1',
            bidderOrganizationId: 'org-bidder',
            organizationId: 'org-bidder',
            userId: 'user-bidder',
            submittedBy: '提交人昵称',
            submittedAt,
          },
        ];
      },
    },
    {
      async findBy() {
        return [
          {
            id: 'project-1',
            organizationId: 'org-owner',
            creatorUserId: 'user-owner',
          },
        ];
      },
    },
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
        return [{ id: 'org-bidder', name: '海川组织简称' }];
      },
    },
    {
      async findBy() {
        return [
          {
            id: 'user-bidder',
            nickname: '江北嘴嘴帅',
            avatarUrl: null,
          },
        ];
      },
    },
    {
      async readAvatarUrl() {
        return null;
      },
    },
    createDisplayNameService([
      {
        organizationId: 'org-bidder',
        legalName: '重庆海川展览展示有限公司',
      },
    ]),
  );

  const seeds = await source.buildSeeds('org-owner');
  assert.equal(seeds.length, 1);
  assert.equal(seeds[0].counterpartDisplayName, '重庆海川展览展示有限公司');
  assert.equal(
    seeds[0].card.summary,
    '重庆海川展览展示有限公司 已对当前项目提交竞标。',
  );
});

test('project-name-access counterpart displayName falls back to organization name', async () => {
  const {
    CounterpartConversationProjectNameAccessSource,
  } = require('../dist/modules/message_interaction/counterpart-conversation.project-name-access-source.js');
  const now = new Date('2026-04-24T08:00:00.000Z');
  const source = new CounterpartConversationProjectNameAccessSource(
    createProjectNameAccessRequestRepository([
      {
        id: 'request-1',
        projectId: 'project-1',
        requesterOrganizationId: 'org-requester',
        requestedByUserId: 'user-requester',
        state: 'pending',
        createdAt: now,
        updatedAt: now,
        reviewedAt: null,
      },
    ]),
    {
      async findBy() {
        return [
          {
            id: 'project-1',
            organizationId: 'org-owner',
            creatorUserId: 'user-owner',
            state: 'published',
            publishedAt: now,
          },
        ];
      },
    },
    {
      async findBy() {
        return [{ id: 'org-requester', name: '海川组织简称' }];
      },
    },
    {
      async findBy() {
        return [
          {
            id: 'user-requester',
            nickname: '申请人昵称',
            avatarUrl: null,
          },
        ];
      },
    },
    {
      async readAvatarUrl() {
        return null;
      },
    },
    createDisplayNameService(),
  );

  const seeds = await source.buildSeeds('org-owner');
  assert.equal(seeds.length, 1);
  assert.equal(seeds[0].counterpartDisplayName, '海川组织简称');
  assert.equal(seeds[0].card.requesterCompanyName, '海川组织简称');
  assert.equal(seeds[0].card.requesterOrganizationId, 'org-requester');
  assert.match(seeds[0].card.summary, /海川组织简称/);
});

test('bid-participation card exposes structured requester company fields', async () => {
  const {
    CounterpartConversationBidParticipationSource,
  } = require('../dist/modules/message_interaction/counterpart-conversation.bid-participation-source.js');
  const now = new Date('2026-04-24T08:00:00.000Z');
  const source = new CounterpartConversationBidParticipationSource(
    createBidParticipationRequestRepository([
      {
        id: 'bid-request-1',
        projectId: 'project-1',
        requesterOrganizationId: 'org-requester',
        requestedByUserId: 'user-requester',
        state: 'pending',
        createdAt: now,
        updatedAt: now,
        reviewedAt: null,
      },
    ]),
    {
      async findBy() {
        return [
          {
            id: 'project-1',
            organizationId: 'org-owner',
            creatorUserId: 'user-owner',
            state: 'published',
            publishedAt: now,
          },
        ];
      },
    },
    {
      async findBy() {
        return [{ id: 'org-requester', name: '坤特组织简称' }];
      },
    },
    {
      async findBy() {
        return [
          {
            id: 'user-requester',
            nickname: '申请人昵称',
            avatarUrl: null,
          },
        ];
      },
    },
    {
      async readAvatarUrl() {
        return null;
      },
    },
    createDisplayNameService([
      {
        organizationId: 'org-requester',
        legalName: '重庆坤特展览展示有限公司',
      },
    ]),
  );

  const seeds = await source.buildSeeds('org-owner');
  assert.equal(seeds.length, 1);
  assert.equal(seeds[0].card.cardType, 'bid_participation_request');
  assert.equal(seeds[0].card.requesterCompanyName, '重庆坤特展览展示有限公司');
  assert.equal(seeds[0].card.requesterOrganizationId, 'org-requester');
  assert.match(seeds[0].card.summary, /重庆坤特展览展示有限公司/);
});

test('clarification counterpart displayName uses approved certification legalName first', async () => {
  const {
    CounterpartConversationClarificationSource,
  } = require('../dist/modules/message_interaction/counterpart-conversation.clarification-source.js');
  const now = new Date('2026-04-24T08:00:00.000Z');
  const project = {
    id: 'project-1',
    organizationId: 'org-owner',
    creatorUserId: 'user-owner',
    state: 'published',
    publishedAt: now,
  };
  const source = new CounterpartConversationClarificationSource(
    {
      async find() {
        return [];
      },
    },
    {
      async find() {
        return [project];
      },
      async findBy() {
        return [project];
      },
    },
    {
      async find() {
        return [
          {
            id: 'clarification-1',
            projectId: 'project-1',
            authorOrganizationId: 'org-supplier',
            authorUserId: 'user-supplier',
            body: '请确认进场时间。',
            lifecycleState: 'active',
            createdAt: now,
            updatedAt: now,
          },
        ];
      },
    },
    {
      async findBy() {
        return [{ id: 'org-supplier', name: '供应商组织简称' }];
      },
    },
    {
      async findBy() {
        return [
          {
            id: 'user-supplier',
            nickname: '供应商昵称',
            avatarUrl: null,
          },
        ];
      },
    },
    {
      async readAvatarUrl() {
        return null;
      },
    },
    createDisplayNameService([
      {
        organizationId: 'org-supplier',
        legalName: '重庆供应商认证公司',
      },
    ]),
  );

  const seeds = await source.buildSeeds('org-owner');
  assert.equal(seeds.length, 1);
  assert.equal(seeds[0].counterpartDisplayName, '重庆供应商认证公司');
  assert.equal(seeds[0].card.cardType, 'project_clarification');
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

test('counterpart conversation project title uses concrete project title when visible', async () => {
  const {
    CounterpartConversationProjectionService,
  } = require('../dist/modules/message_interaction/counterpart-conversation.projection.service.js');
  const now = '2026-04-24T08:05:00.000Z';
  const publishedAt = new Date('2026-04-20T02:30:00.000Z');
  const projectUpdatedAt = new Date('2026-04-21T03:40:00.000Z');
  const project = {
    id: 'project-luzhou',
    organizationId: 'org-owner',
    creatorUserId: 'user-owner',
    title: '西洽会 - 泸州',
    exhibitionName: '西洽会',
    brandName: '泸州',
    state: 'published',
    publishedAt,
    updatedAt: projectUpdatedAt,
  };
  const card = {
    cardId: 'bid-thread:bid-luzhou',
    cardType: 'bid_thread',
    title: '新的竞标已提交',
    summary: '重庆展宏展览展示有限公司 已对当前项目提交竞标。',
    status: 'submitted',
    updatedAt: now,
    truthAnchor: {
      truthType: 'bid_thread',
      projectId: 'project-luzhou',
      bidId: 'bid-luzhou',
    },
    detailRouteTarget: null,
    decisionAvailability: null,
  };
  const sourceWithSeed = {
    async buildSeeds() {
      return [
        {
          counterpartOrganizationId: 'org-counterpart',
          counterpartDisplayName: '重庆展宏展览展示有限公司',
          counterpartAvatarUrl: null,
          projectId: 'project-luzhou',
          updatedAt: now,
          card,
        },
      ];
    },
  };
  const emptySource = {
    async buildSeeds() {
      return [];
    },
  };
  const service = new CounterpartConversationProjectionService(
    {
      async findBy() {
        return [project];
      },
      async query() {
        return [];
      },
    },
    {
      async buildPublicProjectionMap(input) {
        assert.equal(input.viewerOrganizationId, 'org-owner');
        return new Map([
          [
            'project-luzhou',
            {
              displayTitle: '西洽会',
              title: '西洽会 - 泸州',
              exhibitionName: '西洽会',
              brandName: '泸州',
              nameAccess: {
                status: 'visible',
                canRequest: false,
                requestId: null,
              },
            },
          ],
        ]);
      },
    },
    sourceWithSeed,
    emptySource,
    emptySource,
    {
      async buildUnreadStatsForCounterpartProjects(projectIds, viewerOrganizationId) {
        assert.deepEqual(projectIds, ['project-luzhou']);
        assert.equal(viewerOrganizationId, 'org-owner');
        return new Map([
          [
            'project-luzhou',
            {
              unreadCount: 2,
              hasUnread: true,
              latestUnreadMessageAt: '2026-04-24T09:30:00.000Z',
            },
          ],
        ]);
      },
    },
  );

  const result = await service.getConversationDetail({
    viewerOrganizationId: 'org-owner',
    conversationId: 'org-counterpart',
    focusProjectId: 'project-luzhou',
  });

  assert.equal(result.projectGroups.length, 1);
  assert.equal(result.projectGroups[0].titleVisibility, 'visible');
  assert.equal(result.projectGroups[0].projectDisplayTitle, '西洽会 - 泸州');
  assert.equal(result.projectGroups[0].projectPublishedAt, publishedAt.toISOString());
  assert.equal(result.projectGroups[0].projectUpdatedAt, projectUpdatedAt.toISOString());
  assert.equal(result.projectGroups[0].latestActivityAt, now);
  assert.equal(result.projectGroups[0].projectUnreadCount, 2);
  assert.equal(result.projectGroups[0].hasProjectUnread, true);
  assert.equal(result.projectGroups[0].latestUnreadMessageAt, '2026-04-24T09:30:00.000Z');
  assert.equal(result.conversationUnreadCount, 2);
  assert.equal(result.hasUnread, true);
  assert.equal(result.latestUnreadMessageAt, '2026-04-24T09:30:00.000Z');
  assert.equal(result.myPublishedUnreadCount, 2);
  assert.equal(result.myBidUnreadCount, 0);
});

test('counterpart conversation list badge includes pending business todos', async () => {
  const {
    CounterpartConversationProjectionService,
  } = require('../dist/modules/message_interaction/counterpart-conversation.projection.service.js');
  const now = '2026-04-24T08:05:00.000Z';
  const project = {
    id: 'project-pending',
    organizationId: 'org-owner',
    creatorUserId: 'user-owner',
    title: '重庆电子展',
    exhibitionName: '重庆电子展',
    brandName: '海力士',
    state: 'published',
    publishedAt: new Date('2026-04-20T02:30:00.000Z'),
    updatedAt: new Date('2026-04-21T03:40:00.000Z'),
  };
  const sourceWithSeed = {
    async buildSeeds() {
      return [
        {
          counterpartOrganizationId: 'org-counterpart',
          counterpartDisplayName: '重庆鸿川展览工厂',
          counterpartAvatarUrl: null,
          projectId: 'project-pending',
          updatedAt: now,
          card: {
            cardId: 'bid-participation-request:req-1',
            cardType: 'bid_participation_request',
            title: '新的参与申请',
            summary: '重庆鸿川展览工厂 申请参与当前项目。',
            status: 'pending',
            updatedAt: now,
            truthAnchor: {
              truthType: 'bid_participation_request',
              projectId: 'project-pending',
              requestId: 'req-1',
            },
            detailRouteTarget: null,
            decisionAvailability: {
              canApprove: true,
              canReject: true,
            },
          },
        },
      ];
    },
  };
  const emptySource = {
    async buildSeeds() {
      return [];
    },
  };
  const service = new CounterpartConversationProjectionService(
    {
      async findBy() {
        return [project];
      },
      async query() {
        return [];
      },
    },
    {
      async buildPublicProjectionMap() {
        return new Map([
          [
            'project-pending',
            {
              displayTitle: '重庆电子展 - 海力士',
              nameAccess: {
                status: 'visible',
                canRequest: false,
                requestId: null,
              },
            },
          ],
        ]);
      },
    },
    sourceWithSeed,
    emptySource,
    emptySource,
    {
      async buildUnreadStatsForCounterpartProjects(projectIds) {
        assert.deepEqual(projectIds, ['project-pending']);
        return new Map([
          [
            'project-pending',
            {
              unreadCount: 0,
              hasUnread: false,
              latestUnreadMessageAt: null,
            },
          ],
        ]);
      },
    },
    {
      async buildForPair() {
        return {
          businessTodoSummary: {
            bidParticipationReviewPendingCount: 1,
            publisherMaterialReviewPendingCount: 0,
            bidMaterialReviewPendingCount: 0,
            dealConfirmationPendingCount: 0,
            totalPendingCount: 1,
          },
        };
      },
      emptyBusinessTodoSummary() {
        return {
          bidParticipationReviewPendingCount: 0,
          publisherMaterialReviewPendingCount: 0,
          bidMaterialReviewPendingCount: 0,
          dealConfirmationPendingCount: 0,
          totalPendingCount: 0,
        };
      },
    },
  );

  const [result] = await service.listConversations('org-owner');

  assert.equal(result.conversationUnreadCount, 1);
  assert.equal(result.hasUnread, true);
});

test('project communication unread query counts counterpart unread messages', async () => {
  const {
    ProjectCommunicationUnreadQueryService,
  } = require('../dist/modules/project_communication/project-communication-unread.query.service.js');
  const threads = [
    {
      id: 'thread-unread',
      projectId: 'project-1',
      ownerOrganizationId: 'org-viewer',
      counterpartOrganizationId: 'org-other',
      lastMessageId: 'message-other-new-3',
      lastMessageAt: new Date('2026-04-24T09:40:00.000Z'),
    },
    {
      id: 'thread-read',
      projectId: 'project-1',
      ownerOrganizationId: 'org-viewer',
      counterpartOrganizationId: 'org-third',
      lastMessageId: 'message-other-read',
      lastMessageAt: new Date('2026-04-24T08:00:00.000Z'),
    },
    {
      id: 'thread-own-last',
      projectId: 'project-2',
      ownerOrganizationId: 'org-other',
      counterpartOrganizationId: 'org-viewer',
      lastMessageId: 'message-own',
      lastMessageAt: new Date('2026-04-24T07:00:00.000Z'),
    },
  ];
  const service = new ProjectCommunicationUnreadQueryService(
    {
      async find() {
        return threads;
      },
    },
    {
      async find() {
        return [
          {
            threadId: 'thread-unread',
            organizationId: 'org-viewer',
            projectId: 'project-1',
            lastReadMessageId: 'message-viewer-read-boundary',
            lastReadAt: new Date('2026-04-24T08:30:00.000Z'),
          },
          {
            threadId: 'thread-read',
            organizationId: 'org-viewer',
            projectId: 'project-1',
            lastReadMessageId: 'message-other-read',
            lastReadAt: new Date('2026-04-24T08:30:00.000Z'),
          },
        ];
      },
    },
    {
      async find({ where }) {
        assert.ok(where.threadId);
        return [
          {
            id: 'message-viewer-read-boundary',
            threadId: 'thread-unread',
            projectId: 'project-1',
            senderOrganizationId: 'org-viewer',
            messageState: 'active',
            createdAt: new Date('2026-04-24T08:30:00.000Z'),
          },
          {
            id: 'message-other-new-1',
            threadId: 'thread-unread',
            projectId: 'project-1',
            senderOrganizationId: 'org-other',
            messageState: 'active',
            createdAt: new Date('2026-04-24T09:00:00.000Z'),
          },
          {
            id: 'message-other-new-2',
            threadId: 'thread-unread',
            projectId: 'project-1',
            senderOrganizationId: 'org-other',
            messageState: 'active',
            createdAt: new Date('2026-04-24T09:10:00.000Z'),
          },
          {
            id: 'message-viewer-own-after',
            threadId: 'thread-unread',
            projectId: 'project-1',
            senderOrganizationId: 'org-viewer',
            messageState: 'active',
            createdAt: new Date('2026-04-24T09:20:00.000Z'),
          },
          {
            id: 'message-other-new-3',
            threadId: 'thread-unread',
            projectId: 'project-1',
            senderOrganizationId: 'org-other',
            messageState: 'active',
            createdAt: new Date('2026-04-24T09:40:00.000Z'),
          },
          {
            id: 'message-other-read',
            threadId: 'thread-read',
            projectId: 'project-1',
            senderOrganizationId: 'org-third',
            messageState: 'active',
            createdAt: new Date('2026-04-24T08:00:00.000Z'),
          },
          {
            id: 'message-own',
            threadId: 'thread-own-last',
            projectId: 'project-2',
            senderOrganizationId: 'org-viewer',
            messageState: 'active',
            createdAt: new Date('2026-04-24T07:00:00.000Z'),
          },
        ];
      },
      async findBy() {
        return [
          {
            id: 'message-viewer-read-boundary',
            threadId: 'thread-unread',
            projectId: 'project-1',
            createdAt: new Date('2026-04-24T08:30:00.000Z'),
          },
          {
            id: 'message-other-read',
            threadId: 'thread-read',
            projectId: 'project-1',
            createdAt: new Date('2026-04-24T08:00:00.000Z'),
          },
        ];
      },
    },
  );

  const unreadStatsByProject = await service.buildUnreadStatsForCounterpartProjects(
    ['project-1', 'project-2'],
    'org-viewer',
  );
  const unreadByProject = await service.buildUnreadMapForCounterpartProjects(
    ['project-1', 'project-2'],
    'org-viewer',
  );
  assert.equal(unreadStatsByProject.get('project-1').unreadCount, 3);
  assert.equal(unreadStatsByProject.get('project-1').hasUnread, true);
  assert.equal(
    unreadStatsByProject.get('project-1').latestUnreadMessageAt,
    '2026-04-24T09:40:00.000Z',
  );
  assert.equal(unreadByProject.get('project-1'), 3);
  assert.equal(unreadByProject.get('project-2'), 0);
  assert.equal(await service.countUnreadForShell('org-viewer'), 3);
});

test('project communication mark read rejects message outside project thread', async () => {
  const {
    ProjectCommunicationMessageService,
  } = require('../dist/modules/project_communication/project-communication-message.service.js');
  const {
    ProjectCommunicationPresenter,
  } = require('../dist/modules/project_communication/project-communication.presenter.js');
  const thread = {
    id: 'thread-1',
    projectId: 'project-1',
    ownerOrganizationId: 'org-viewer',
    counterpartOrganizationId: 'org-other',
  };
  const manager = {
    getRepository(entity) {
      if (entity?.name === 'ProjectCommunicationThreadEntity') {
        return {
          async findOneBy(where) {
            assert.deepEqual(where, {
              id: 'thread-1',
              projectId: 'project-1',
            });
            return thread;
          },
        };
      }
      if (entity?.name === 'ProjectCommunicationMessageEntity') {
        return {
          async findOneBy(where) {
            assert.deepEqual(where, {
              id: 'message-other-thread',
              threadId: 'thread-1',
              projectId: 'project-1',
            });
            return null;
          },
        };
      }
      if (entity?.name === 'ProjectCommunicationReadCursorEntity') {
        throw new Error('read cursor repository should not be reached');
      }
      throw new Error(`Unexpected repository ${entity?.name}`);
    },
  };
  const service = new ProjectCommunicationMessageService(
    {},
    {
      manager,
      async transaction(callback) {
        return callback(manager);
      },
    },
    {
      async requireExistingThreadParticipant(candidateThread) {
        assert.equal(candidateThread.id, 'thread-1');
        return {
          organizationId: 'org-viewer',
          currentSession: {
            userId: 'user-1',
            actorId: 'actor-1',
          },
        };
      },
    },
    {},
    new ProjectCommunicationPresenter(),
    {},
  );

  await assert.rejects(
    () =>
      service.markRead(
        {
          projectId: 'project-1',
          threadId: 'thread-1',
          lastReadMessageId: 'message-other-thread',
        },
        createContext('project-communication-mark-read-cross-thread'),
      ),
    /lastReadMessageId/,
  );
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
