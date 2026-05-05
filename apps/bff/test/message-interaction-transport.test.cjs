const path = require("path");
require("ts-node").register({
  transpileOnly: true,
  project: path.resolve(__dirname, "../tsconfig.json"),
});
require("reflect-metadata");

const test = require("node:test");
const assert = require("node:assert/strict");
const { AxiosError } = require("axios");
const { Module, RequestMethod } = require("@nestjs/common");
const { PATH_METADATA, METHOD_METADATA } = require("@nestjs/common/constants");
const { NestFactory } = require("@nestjs/core");

const {
  MessageInteractionController,
} = require("../src/routes/message_interaction/message-interaction.controller.ts");
const {
  MessageInteractionService,
} = require("../src/routes/message_interaction/message-interaction.service.ts");
const {
  ProjectCommunicationRealtimeGateway,
} = require("../src/routes/message_interaction/project-communication-realtime.gateway.ts");
const {
  ErrorNormalizerService,
} = require("../src/core/errors/error-normalizer.service.ts");

function createAxiosResponseError(
  status,
  data,
  message = `Request failed with status code ${status}`,
) {
  return new AxiosError(message, "ERR_BAD_REQUEST", {}, null, {
    status,
    statusText: "error",
    headers: {},
    config: {},
    data,
  });
}

test("message interactions route is materialized and no longer router 404 locally", async () => {
  const calls = [];
  const service = {
    getInteractions(lane) {
      calls.push(lane ?? null);
      return {
        lane: lane ?? "project_communication",
        items: [
          {
            interactionId: "org-1",
            interactionType: "counterpart_conversation",
            conversationId: "org-1",
            projectId: "project-1",
            counterpart: {
              organizationId: "org-1",
              displayName: "重庆海川展览工厂",
              avatarUrl: null,
              role: "counterpart",
            },
            summary: {
              focusProjectId: "project-1",
              title: "项目名称查看申请",
              text: "重庆海川展览工厂 申请查看当前项目名称。",
              projectCount: 1,
              latestCardType: "project_name_access_request",
            },
            updatedAt: "2026-04-29T10:00:00.000Z",
            routeTarget: {
              objectType: "counterpart_conversation",
              actionKey: "counterpart_conversation.open",
              canonicalPath:
                "/api/app/message/counterpart-conversation/detail",
              params: {
                conversationId: "org-1",
                projectId: "project-1",
              },
            },
          },
        ],
      };
    },
    getCounterpartConversationDetail(conversationId, projectId) {
      calls.push(`${conversationId}:${projectId}`);
      return {
        conversationId,
        counterpart: {
          organizationId: "org-1",
          displayName: "重庆海川展览工厂",
          nickname: null,
          companyName: "重庆海川展览工厂",
          avatarUrl: null,
          role: "counterpart",
          certificationSummary: null,
        },
        summary: {
          focusProjectId: projectId,
          title: "项目名称查看申请",
          text: "重庆海川展览工厂 申请查看当前项目名称。",
          projectCount: 1,
          latestCardType: "project_name_access_request",
        },
        focusProjectId: projectId,
        latestActivityAt: "2026-04-29T10:00:00.000Z",
        projectGroups: [],
      };
    },
    getProjectCommunicationThread(projectId, counterpartOrganizationId) {
      calls.push(`thread:${projectId}:${counterpartOrganizationId}`);
      return {
        threadId: "thread-1",
        projectId,
        ownerOrganizationId: "owner-org",
        counterpartOrganizationId,
        chatAvailability: {
          canSendMessage: true,
          lockReasonCode: null,
          lockReasonText: null,
          requiredNextAction: "none",
        },
        threadState: "open",
        lastMessageId: null,
        lastMessageAt: null,
        createdAt: "2026-04-30T10:00:00.000Z",
        updatedAt: "2026-04-30T10:00:00.000Z",
      };
    },
    listProjectCommunicationMessages(threadId, projectId) {
      calls.push(`messages:${threadId}:${projectId}`);
      return {
        items: [],
        nextCursor: null,
      };
    },
    sendProjectCommunicationMessage(payload) {
      calls.push(
        `send:${payload.threadId}:${payload.projectId}:${payload.body}`,
      );
      return {
        messageId: "message-1",
        threadId: payload.threadId,
        projectId: payload.projectId,
        senderUserId: "user-1",
        senderActorId: "actor-1",
        senderOrganizationId: "org-1",
        messageKind: "text",
        body: payload.body,
        clientMessageId: null,
        messageState: "active",
        createdAt: "2026-04-30T10:01:00.000Z",
      };
    },
    markProjectCommunicationReadCursor(payload) {
      calls.push(`read:${payload.threadId}:${payload.projectId}`);
      return {
        threadId: payload.threadId,
        projectId: payload.projectId,
        organizationId: "org-1",
        lastReadMessageId: payload.lastReadMessageId ?? null,
        lastReadAt: "2026-04-30T10:02:00.000Z",
        updatedAt: "2026-04-30T10:02:00.000Z",
      };
    },
  };

  class TestModule {}
  Module({
    controllers: [MessageInteractionController],
    providers: [{ provide: MessageInteractionService, useValue: service }],
  })(TestModule);

  const app = await NestFactory.create(TestModule, { logger: false });
  await app.listen(0, "127.0.0.1");

  try {
    const url = await app.getUrl();
    assert.equal(
      Reflect.getMetadata(PATH_METADATA, MessageInteractionController),
      "api/app/message",
    );
    assert.equal(
      Reflect.getMetadata(
        PATH_METADATA,
        MessageInteractionController.prototype.getInteractions,
      ),
      "interactions",
    );
    assert.equal(
      Reflect.getMetadata(
        METHOD_METADATA,
        MessageInteractionController.prototype.getInteractions,
      ),
      RequestMethod.GET,
    );
    assert.equal(
      Reflect.getMetadata(
        PATH_METADATA,
        MessageInteractionController.prototype.getCounterpartConversationDetail,
      ),
      "counterpart-conversation/detail",
    );
    assert.equal(
      Reflect.getMetadata(
        PATH_METADATA,
        MessageInteractionController.prototype.listProjectCommunicationMessages,
      ),
      "project-communication/messages",
    );

    const response = await fetch(
      `${url}/api/app/message/interactions?lane=project_communication`,
    );
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), {
      lane: "project_communication",
      items: [
        {
          interactionId: "org-1",
          interactionType: "counterpart_conversation",
          conversationId: "org-1",
          projectId: "project-1",
          counterpart: {
            organizationId: "org-1",
            displayName: "重庆海川展览工厂",
            avatarUrl: null,
            role: "counterpart",
          },
          summary: {
            focusProjectId: "project-1",
            title: "项目名称查看申请",
            text: "重庆海川展览工厂 申请查看当前项目名称。",
            projectCount: 1,
            latestCardType: "project_name_access_request",
          },
          updatedAt: "2026-04-29T10:00:00.000Z",
          routeTarget: {
            objectType: "counterpart_conversation",
            actionKey: "counterpart_conversation.open",
            canonicalPath: "/api/app/message/counterpart-conversation/detail",
            params: {
              conversationId: "org-1",
              projectId: "project-1",
            },
          },
        },
      ],
    });

    const detailResponse = await fetch(
      `${url}/api/app/message/counterpart-conversation/detail?conversationId=org-1&projectId=project-1`,
    );
    assert.equal(detailResponse.status, 200);
    assert.equal((await detailResponse.json()).conversationId, "org-1");

    const threadResponse = await fetch(
      `${url}/api/app/message/project-communication/thread?projectId=project-1&counterpartOrganizationId=org-1`,
    );
    assert.equal(threadResponse.status, 200);
    const threadBody = await threadResponse.json();
    assert.equal(threadBody.threadId, "thread-1");
    assert.equal(threadBody.chatAvailability.canSendMessage, true);

    const messagesResponse = await fetch(
      `${url}/api/app/message/project-communication/messages?threadId=thread-1&projectId=project-1`,
    );
    assert.equal(messagesResponse.status, 200);
    assert.deepEqual(await messagesResponse.json(), {
      items: [],
      nextCursor: null,
    });

    const sendResponse = await fetch(
      `${url}/api/app/message/project-communication/messages`,
      {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          threadId: "thread-1",
          projectId: "project-1",
          body: "在吗",
        }),
      },
    );
    assert.equal(sendResponse.status, 202);
    assert.equal((await sendResponse.json()).messageId, "message-1");

    const readResponse = await fetch(
      `${url}/api/app/message/project-communication/read-cursor`,
      {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          threadId: "thread-1",
          projectId: "project-1",
          lastReadMessageId: "message-1",
        }),
      },
    );
    assert.equal(readResponse.status, 202);
    assert.equal((await readResponse.json()).lastReadMessageId, "message-1");
  } finally {
    await app.close();
  }

  assert.deepEqual(calls, [
    "project_communication",
    "org-1:project-1",
    "thread:project-1:org-1",
    "messages:thread-1:project-1",
    "send:thread-1:project-1:在吗",
    "read:thread-1:project-1",
  ]);
});

test("message interactions service forwards frozen server path and hides raw route drift", async () => {
  const service = new MessageInteractionService(
    {
      async get(pathName, options) {
        assert.equal(pathName, "/server/message/interactions");
        assert.deepEqual(options.params, { lane: "project_communication" });
        return {
          lane: "project_communication",
          items: [
            {
              interactionId: "org-1",
              interactionType: "counterpart_conversation",
              conversationId: "org-1",
              projectId: "project-1",
              counterpart: {
                organizationId: "org-1",
                displayName: "重庆海川展览工厂",
                avatarUrl: null,
                role: "counterpart",
              },
              summary: {
                focusProjectId: "project-1",
                title: "订单状态已更新",
                text: "重庆海川展览工厂 的当前项目订单已有新状态。",
                projectCount: 1,
                latestCardType: "project_order",
              },
              updatedAt: "2026-04-29T10:00:00.000Z",
              conversationUnreadCount: 4,
              hasUnread: true,
              latestUnreadMessageAt: "2026-04-29T10:05:00.000Z",
              pricingSummary: {
                projectId: "project-1",
                bidServiceFeeAuthorization: {
                  status: "charged",
                  finalFeeAmount: "2700.00",
                },
                dealConfirmation: { status: "confirmed_deal" },
                messageDisplaySummary: {
                  displayAllowed: true,
                  readOnly: true,
                  statusTextKey: "charged",
                },
              },
              routeTarget: {
                objectType: "counterpart_conversation",
                actionKey: "counterpart_conversation.open",
                canonicalPath:
                  "/api/app/message/counterpart-conversation/detail",
                params: {
                  conversationId: "org-1",
                  projectId: "project-1",
                },
              },
            },
          ],
          trimmed: "ignore-me",
        };
      },
    },
    {
      buildForwardHeaders() {
        return {
          authorization: "Bearer token",
          "x-organization-id": "org-1",
          "x-actor-role": "supplier_admin",
        };
      },
    },
    new ErrorNormalizerService(),
  );

  const result = await service.getInteractions(undefined, {});
  assert.deepEqual(result, {
    lane: "project_communication",
    items: [
      {
        interactionId: "org-1",
        interactionType: "counterpart_conversation",
        conversationId: "org-1",
        projectId: "project-1",
        counterpart: {
          organizationId: "org-1",
          displayName: "重庆海川展览工厂",
          nickname: null,
          companyName: "重庆海川展览工厂",
          avatarUrl: null,
          role: "counterpart",
          certificationSummary: null,
        },
        summary: {
          focusProjectId: "project-1",
          title: "订单状态已更新",
          text: "重庆海川展览工厂 的当前项目订单已有新状态。",
          projectCount: 1,
          latestCardType: "project_order",
        },
        pricingSummary: {
          projectId: "project-1",
          bidServiceFeeAuthorization: {
            status: "charged",
            finalFeeAmount: "2700.00",
          },
          dealConfirmation: { status: "confirmed_deal" },
          messageDisplaySummary: {
            displayAllowed: true,
            readOnly: true,
            statusTextKey: "charged",
          },
        },
        updatedAt: "2026-04-29T10:00:00.000Z",
        conversationUnreadCount: 4,
        hasUnread: true,
        latestUnreadMessageAt: "2026-04-29T10:05:00.000Z",
        routeTarget: {
          objectType: "counterpart_conversation",
          actionKey: "counterpart_conversation.open",
          canonicalPath: "/api/app/message/counterpart-conversation/detail",
          params: {
            conversationId: "org-1",
            projectId: "project-1",
          },
        },
      },
    ],
  });

  const brokenService = new MessageInteractionService(
    {
      async get() {
        throw createAxiosResponseError(404, {
          statusCode: 404,
          message: "Cannot GET /server/message/interactions",
          source: "server",
        });
      },
    },
    {
      buildForwardHeaders() {
        return {};
      },
    },
    new ErrorNormalizerService(),
  );

  await assert.rejects(
    () => brokenService.getInteractions(undefined, {}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.deepEqual(error.getResponse(), {
        statusCode: 404,
        code: "MESSAGE_INTERACTION_UNAVAILABLE",
        message: "当前项目沟通入口暂不可用，请稍后再试。",
        source: "server",
      });
      return true;
    },
  );
});

test("message interactions service preserves server-owned counterpart identity without name ownership", async () => {
  const service = new MessageInteractionService(
    {
      async get(pathName, options) {
        assert.equal(pathName, "/server/message/interactions");
        assert.deepEqual(options.params, { lane: "project_communication" });
        return {
          lane: "project_communication",
          items: [
            {
              interactionId: "org-certified",
              interactionType: "counterpart_conversation",
              conversationId: "org-certified",
              projectId: "project-1",
              counterpart: {
                organizationId: "org-certified",
                displayName: "重庆海川展览展示有限公司",
                legalName: "BFF 不应读取这个字段",
                certifiedCompanyName: "BFF 不应新增这个字段",
                nickname: "海川小张",
                companyName: "重庆海川展览展示有限公司",
                avatarUrl: null,
                role: "counterpart",
                certificationSummary: {
                  certificationStatus: "approved",
                  legalName: "重庆海川展览展示有限公司",
                  usccMasked: "9150****1234",
                  businessType: "有限责任公司",
                  address: "重庆市",
                  establishedAt: "2020-01-01",
                  reviewedAt: "2026-04-29T09:00:00.000Z",
                },
              },
              summary: {
                focusProjectId: "project-1",
                title: "新的竞标已提交",
                text: "重庆海川展览展示有限公司 已对当前项目提交竞标。",
                projectCount: 1,
                latestCardType: "bid_thread",
              },
              updatedAt: "2026-04-29T10:00:00.000Z",
              routeTarget: {
                objectType: "counterpart_conversation",
                actionKey: "counterpart_conversation.open",
                canonicalPath:
                  "/api/app/message/counterpart-conversation/detail",
                params: {
                  conversationId: "org-certified",
                  projectId: "project-1",
                },
              },
            },
          ],
        };
      },
    },
    {
      buildForwardHeaders() {
        return {
          authorization: "Bearer token",
          "x-organization-id": "org-1",
          "x-actor-role": "supplier_admin",
        };
      },
    },
    new ErrorNormalizerService(),
  );

  const result = await service.getInteractions(undefined, {});
  assert.deepEqual(Object.keys(result.items[0].counterpart).sort(), [
    "avatarUrl",
    "certificationSummary",
    "companyName",
    "displayName",
    "nickname",
    "organizationId",
    "role",
  ]);
  assert.equal(result.items[0].conversationUnreadCount, 0);
  assert.equal(result.items[0].hasUnread, false);
  assert.equal(result.items[0].latestUnreadMessageAt, null);
  assert.deepEqual(result.items[0].counterpart, {
    organizationId: "org-certified",
    displayName: "重庆海川展览展示有限公司",
    nickname: "海川小张",
    companyName: "重庆海川展览展示有限公司",
    avatarUrl: null,
    role: "counterpart",
    certificationSummary: {
      certificationStatus: "approved",
      legalName: "重庆海川展览展示有限公司",
      usccMasked: "9150****1234",
      businessType: "有限责任公司",
      address: "重庆市",
      establishedAt: "2020-01-01",
      reviewedAt: "2026-04-29T09:00:00.000Z",
    },
  });
});

test("counterpart conversation detail service forwards frozen server path and hides raw route drift", async () => {
  const service = new MessageInteractionService(
    {
      async get(pathName, options) {
        assert.equal(
          pathName,
          "/server/message/counterpart-conversation/detail",
        );
        assert.deepEqual(options.params, {
          conversationId: "org-1",
          projectId: "project-1",
        });
        return {
          conversationId: "org-1",
          counterpart: {
            organizationId: "org-1",
            displayName: "重庆海川展览工厂",
            avatarUrl: null,
            role: "counterpart",
          },
          summary: {
            focusProjectId: "project-1",
            title: "项目名称查看申请",
            text: "重庆海川展览工厂 申请查看当前项目名称。",
            projectCount: 1,
            latestCardType: "project_name_access_request",
          },
          focusProjectId: "project-1",
          latestActivityAt: "2026-04-29T10:00:00.000Z",
          conversationUnreadCount: 2,
          hasUnread: true,
          latestUnreadMessageAt: "2026-04-29T10:04:00.000Z",
          myPublishedUnreadCount: 2,
          myBidUnreadCount: 0,
          projectGroups: [
            {
              projectId: "project-1",
              projectDisplayTitle: "西洽会 - 泸州",
              titleVisibility: "visible",
              projectRelation: "my_published",
              projectState: "published",
              projectPublishedAt: "2026-04-28T09:00:00.000Z",
              projectUpdatedAt: "2026-04-29T08:30:00.000Z",
              latestActivityAt: "2026-04-29T10:00:00.000Z",
              projectUnreadCount: 2,
              hasProjectUnread: true,
              latestUnreadMessageAt: "2026-04-29T10:04:00.000Z",
              businessTodoSummary: {
                bidParticipationReviewPendingCount: 1,
                publisherMaterialReviewPendingCount: 0,
                bidMaterialReviewPendingCount: 0,
                dealConfirmationPendingCount: 0,
                totalPendingCount: 1,
              },
              orderSummary: {
                orderId: "order-1",
                projectId: "project-1",
                buyerOrganizationId: "owner-org",
                sellerOrganizationId: "org-1",
                state: "active",
                completionRequestState: "requested",
              },
              ratingEntry: {
                orderId: "order-1",
                projectId: "project-1",
                rateeOrganizationId: "org-1",
                canRate: false,
                reason: "当前项目尚未结束，评价入口不会开放。",
                ratingState: "draft",
              },
              cards: [
                {
                  cardId: "project-name-access:request-1",
                  cardType: "project_name_access_request",
                  title: "项目名称查看申请",
                  summary: "重庆海川展览工厂 申请查看当前项目名称。",
                  status: "pending",
                  updatedAt: "2026-04-29T10:00:00.000Z",
                  requesterCompanyName: "重庆海川展览工厂",
                  requesterOrganizationId: "org-1",
                  truthAnchor: {
                    truthType: "project_name_access_request",
                    projectId: "project-1",
                    requestId: "request-1",
                    threadId: "request-1",
                  },
                  detailRouteTarget: {
                    objectType: "project_name_access_thread",
                    actionKey: "project_name_access_thread.open",
                    canonicalPath: "/api/app/project/name-access/thread/detail",
                    params: {
                      threadId: "request-1",
                      projectId: "project-1",
                      requestId: "request-1",
                    },
                  },
                  decisionAvailability: {
                    canApprove: true,
                    canReject: true,
                  },
                },
                {
                  cardId: "project-order:order-1",
                  cardType: "project_order",
                  title: "订单状态",
                  summary: "当前订单正在履约中，承接方已申请完工。",
                  status: "requested",
                  updatedAt: "2026-04-29T10:01:00.000Z",
                  truthAnchor: {
                    truthType: "project_order",
                    projectId: "project-1",
                    orderId: "order-1",
                  },
                  detailRouteTarget: {
                    objectType: "order",
                    actionKey: "order_detail.open",
                    canonicalPath: "/api/app/order/detail",
                    params: {
                      projectId: "project-1",
                      orderId: "order-1",
                    },
                  },
                  decisionAvailability: null,
                },
                {
                  cardId: "bid-participation:request-2",
                  cardType: "bid_participation_request",
                  title: "竞标申请已通过",
                  summary: "供应商已获得竞标资格。",
                  status: "approved",
                  updatedAt: "2026-04-29T10:02:00.000Z",
                  requesterCompanyName: "重庆海川展览工厂",
                  requesterOrganizationId: "org-1",
                  truthAnchor: {
                    truthType: "bid_participation_request",
                    projectId: "project-1",
                    requestId: "request-2",
                    threadId: "request-2",
                  },
                  detailRouteTarget: {
                    objectType: "bid_submit",
                    actionKey: "bid_submit.open",
                    canonicalPath: "/api/app/bid/submit",
                    params: {
                      projectId: "project-1",
                    },
                  },
                  decisionAvailability: null,
                },
              ],
            },
          ],
        };
      },
    },
    {
      buildForwardHeaders() {
        return {
          authorization: "Bearer token",
          "x-organization-id": "org-owner",
          "x-actor-role": "project_owner",
        };
      },
    },
    new ErrorNormalizerService(),
  );

  const result = await service.getCounterpartConversationDetail(
    "org-1",
    "project-1",
    {},
  );
  assert.equal(
    result.projectGroups[0].cards[0].truthAnchor.projectId,
    "project-1",
  );
  assert.equal(result.projectGroups[0].projectDisplayTitle, "西洽会 - 泸州");
  assert.equal(result.projectGroups[0].titleVisibility, "visible");
  assert.equal(result.projectGroups[0].projectRelation, "my_published");
  assert.equal(result.projectGroups[0].projectPublishedAt, "2026-04-28T09:00:00.000Z");
  assert.equal(result.projectGroups[0].projectUpdatedAt, "2026-04-29T08:30:00.000Z");
  assert.equal(result.conversationUnreadCount, 2);
  assert.equal(result.hasUnread, true);
  assert.equal(result.latestUnreadMessageAt, "2026-04-29T10:04:00.000Z");
  assert.equal(result.myPublishedUnreadCount, 2);
  assert.equal(result.myBidUnreadCount, 0);
  assert.equal(result.projectGroups[0].projectUnreadCount, 2);
  assert.equal(result.projectGroups[0].hasProjectUnread, true);
  assert.equal(result.projectGroups[0].latestUnreadMessageAt, "2026-04-29T10:04:00.000Z");
  assert.equal(result.projectGroups[0].businessTodoSummary.totalPendingCount, 1);
  assert.equal(
    result.projectGroups[0].businessTodoSummary.bidParticipationReviewPendingCount,
    1,
  );
  assert.deepEqual(result.projectGroups[0].orderSummary, {
    orderId: "order-1",
    projectId: "project-1",
    buyerOrganizationId: "owner-org",
    sellerOrganizationId: "org-1",
    state: "active",
    completionRequestState: "requested",
  });
  const orderCard = result.projectGroups[0].cards.find(
    (card) => card.cardType === "project_order",
  );
  assert.equal(orderCard.truthAnchor.orderId, "order-1");
  assert.deepEqual(orderCard.detailRouteTarget.params, {
    projectId: "project-1",
    orderId: "order-1",
  });
  const bidParticipationCard = result.projectGroups[0].cards.find(
    (card) => card.cardType === "bid_participation_request",
  );
  assert.equal(bidParticipationCard.requesterCompanyName, "重庆海川展览工厂");
  assert.equal(bidParticipationCard.requesterOrganizationId, "org-1");
  assert.deepEqual(bidParticipationCard.detailRouteTarget, {
    objectType: "bid_service_fee_authorization",
    actionKey: "bid_service_fee_authorization.open",
    canonicalPath: "/api/app/project/{projectId}/bid-service-fee-authorizations",
    params: {
      projectId: "project-1",
      bidParticipationRequestId: "request-2",
    },
  });
  assert.deepEqual(result.projectGroups[0].ratingEntry, {
    orderId: "order-1",
    projectId: "project-1",
    rateeOrganizationId: "org-1",
    canRate: false,
    reason: "当前项目尚未结束，评价入口不会开放。",
    ratingState: "draft",
  });

  const brokenService = new MessageInteractionService(
    {
      async get() {
        throw createAxiosResponseError(404, {
          statusCode: 404,
          message: "Cannot GET /server/message/counterpart-conversation/detail",
          source: "server",
        });
      },
    },
    {
      buildForwardHeaders() {
        return {};
      },
    },
    new ErrorNormalizerService(),
  );

  await assert.rejects(
    () =>
      brokenService.getCounterpartConversationDetail("org-1", "project-1", {}),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.deepEqual(error.getResponse(), {
        statusCode: 404,
        code: "COUNTERPART_CONVERSATION_UNAVAILABLE",
        message: "当前对方沟通容器暂不可用，请稍后再试。",
        source: "server",
      });
      return true;
    },
  );
});

test("project communication routes forward thread, message list, send, and read cursor paths", async () => {
  const calls = [];
  const service = new MessageInteractionService(
    {
      async get(pathName, options) {
        calls.push({ method: "GET", pathName, params: options.params });
        if (pathName === "/server/project-communication/thread") {
          return {
            threadId: "thread-1",
            projectId: options.params.projectId,
            ownerOrganizationId: "owner-org",
            counterpartOrganizationId: options.params.counterpartOrganizationId,
            chatAvailability: {
              canSendMessage: true,
              lockReasonCode: null,
              lockReasonText: null,
              requiredNextAction: "none",
            },
            threadState: "open",
            lastMessageId: null,
            lastMessageAt: null,
            createdAt: "2026-04-30T10:00:00.000Z",
            updatedAt: "2026-04-30T10:00:00.000Z",
          };
        }
        return {
          items: [
            {
              messageId: "message-1",
              threadId: options.params.threadId,
              projectId: options.params.projectId,
              senderUserId: "user-1",
              senderActorId: "actor-1",
            senderOrganizationId: "org-1",
            messageKind: "text",
            body: "在吗",
            payload: null,
            clientMessageId: null,
            messageState: "active",
            createdAt: "2026-04-30T10:01:00.000Z",
            },
          ],
          nextCursor: "2026-04-30T10:01:00.000Z",
        };
      },
      async post(pathName, body) {
        calls.push({ method: "POST", pathName, body });
        if (pathName === "/server/project-communication/read-cursor") {
          return {
            threadId: body.threadId,
            projectId: body.projectId,
            organizationId: "org-1",
            lastReadMessageId: body.lastReadMessageId,
            lastReadAt: "2026-04-30T10:02:00.000Z",
            updatedAt: "2026-04-30T10:02:00.000Z",
          };
        }
        return {
          messageId: "message-2",
          threadId: body.threadId,
          projectId: body.projectId,
          senderUserId: "user-1",
          senderActorId: "actor-1",
          senderOrganizationId: "org-1",
          messageKind: "text",
          body: body.body,
          payload: null,
          clientMessageId: body.clientMessageId ?? null,
          messageState: "active",
          createdAt: "2026-04-30T10:03:00.000Z",
        };
      },
    },
    {
      buildForwardHeaders() {
        return {
          authorization: "Bearer token",
          "x-organization-id": "org-1",
          "x-actor-role": "supplier_admin",
        };
      },
    },
    new ErrorNormalizerService(),
  );

  const thread = await service.getProjectCommunicationThread(
    "project-1",
    "owner-org",
    {},
  );
  assert.equal(thread.threadId, "thread-1");

  const messages = await service.listProjectCommunicationMessages(
    "thread-1",
    "project-1",
    undefined,
    "20",
    {},
  );
  assert.equal(messages.items[0].messageId, "message-1");
  assert.equal(messages.items[0].deliveryState, "persisted");
  assert.equal(messages.items[0].readState, "not_applicable");
  assert.equal(messages.items[0].readByCounterpartAt, null);

  const message = await service.sendProjectCommunicationMessage(
    {
      threadId: "thread-1",
      projectId: "project-1",
      body: "收到",
      clientMessageId: "client-1",
    },
    {},
  );
  assert.equal(message.body, "收到");
  assert.equal(message.payload, null);

  const cursor = await service.markProjectCommunicationReadCursor(
    {
      threadId: "thread-1",
      projectId: "project-1",
      lastReadMessageId: "message-2",
    },
    {},
  );
  assert.equal(cursor.lastReadMessageId, "message-2");
  assert.deepEqual(calls, [
    {
      method: "GET",
      pathName: "/server/project-communication/thread",
      params: {
        projectId: "project-1",
        counterpartOrganizationId: "owner-org",
      },
    },
    {
      method: "GET",
      pathName: "/server/project-communication/messages",
      params: {
        threadId: "thread-1",
        projectId: "project-1",
        cursor: undefined,
        limit: 20,
      },
    },
    {
      method: "POST",
      pathName: "/server/project-communication/messages",
      body: {
        threadId: "thread-1",
        projectId: "project-1",
        body: "收到",
        clientMessageId: "client-1",
      },
    },
    {
      method: "POST",
      pathName: "/server/project-communication/read-cursor",
      body: {
        threadId: "thread-1",
        projectId: "project-1",
        lastReadMessageId: "message-2",
      },
    },
  ]);
});

test("project communication service passes through image and confirmation payloads", async () => {
  const calls = [];
  const service = new MessageInteractionService(
    {
      async post(pathName, body) {
        calls.push({ pathName, body });
        return {
          messageId: "message-attachment-1",
          threadId: body.threadId,
          projectId: body.projectId,
          senderUserId: "user-1",
          senderActorId: "actor-1",
          senderOrganizationId: "org-1",
          messageKind: body.messageKind,
          body: body.body ?? "",
          payload: body.payload,
          clientMessageId: body.clientMessageId ?? null,
          messageState: "active",
          createdAt: "2026-04-30T10:03:00.000Z",
        };
      },
    },
    {
      buildForwardHeaders() {
        return {
          authorization: "Bearer token",
          "x-organization-id": "org-1",
        };
      },
    },
    new ErrorNormalizerService(),
  );

  const imagePayload = {
    attachment: {
      fileAssetId: "file-1",
      fileName: "booth.png",
      mimeType: "image/png",
      size: 128,
      category: "image",
    },
  };
  const image = await service.sendProjectCommunicationMessage(
    {
      threadId: "thread-1",
      projectId: "project-1",
      messageKind: "image",
      payload: imagePayload,
      clientMessageId: "client-image-1",
    },
    {},
  );

  assert.equal(image.messageKind, "image");
  assert.deepEqual(image.payload, imagePayload);

  const confirmationPayload = {
    confirmation: {
      confirmationType: "quote",
      title: "报价确认",
      summary: "确认当前报价为 12000 元。",
      status: "proposed",
    },
  };
  const confirmation = await service.sendProjectCommunicationMessage(
    {
      threadId: "thread-1",
      projectId: "project-1",
      messageKind: "confirmation_card",
      body: "报价确认",
      payload: confirmationPayload,
    },
    {},
  );

  assert.equal(confirmation.messageKind, "confirmation_card");
  assert.deepEqual(confirmation.payload, confirmationPayload);
  assert.deepEqual(calls, [
    {
      pathName: "/server/project-communication/messages",
      body: {
        threadId: "thread-1",
        projectId: "project-1",
        body: undefined,
        clientMessageId: "client-image-1",
        messageKind: "image",
        payload: imagePayload,
      },
    },
    {
      pathName: "/server/project-communication/messages",
      body: {
        threadId: "thread-1",
        projectId: "project-1",
        body: "报价确认",
        clientMessageId: undefined,
        messageKind: "confirmation_card",
        payload: confirmationPayload,
      },
    },
  ]);
});

test("project communication service hides raw upstream route drift", async () => {
  const service = new MessageInteractionService(
    {
      async get() {
        throw createAxiosResponseError(404, {
          statusCode: 404,
          message: "Cannot GET /server/project-communication/messages",
          source: "server",
        });
      },
    },
    {
      buildForwardHeaders() {
        return {};
      },
    },
    new ErrorNormalizerService(),
  );

  await assert.rejects(
    () =>
      service.listProjectCommunicationMessages(
        "thread-1",
        "project-1",
        undefined,
        undefined,
        {},
      ),
    (error) => {
      assert.equal(error.getStatus(), 404);
      assert.deepEqual(error.getResponse(), {
        statusCode: 404,
        code: "PROJECT_COMMUNICATION_UNAVAILABLE",
        message: "当前项目沟通消息暂不可用，请稍后再试。",
        source: "server",
      });
      return true;
    },
  );
});

test("project communication realtime gateway validates subscription through server truth", async () => {
  const calls = [];
  const sent = [];
  const gateway = new ProjectCommunicationRealtimeGateway({
    async listProjectCommunicationMessages(
      threadId,
      projectId,
      cursor,
      limit,
      headers,
    ) {
      assert.equal(headers.authorization, "Bearer token");
      calls.push({
        pathName: "/server/project-communication/messages",
        params: { projectId, threadId, limit: Number(limit) },
        headers: {
          authorization: headers.authorization,
          "x-organization-id": headers["x-organization-id"],
        },
      });
      return { items: [], nextCursor: null };
    },
  });

  const accepted = await gateway.handleSubscribe(
    {
      send(message) {
        sent.push(JSON.parse(message));
      },
    },
    {
      action: "project_communication.subscribe",
      projectId: " project-1 ",
      threadId: " thread-1 ",
      counterpartOrganizationId: " org-2 ",
    },
    {
      authorization: "Bearer token",
      "x-organization-id": "org-1",
    },
  );

  assert.deepEqual(calls, [
    {
      pathName: "/server/project-communication/messages",
      params: {
        projectId: "project-1",
        threadId: "thread-1",
        limit: 1,
      },
      headers: {
        authorization: "Bearer token",
        "x-organization-id": "org-1",
      },
    },
  ]);
  assert.deepEqual(accepted, {
    eventType: "project_communication.subscription.accepted",
    projectId: "project-1",
    threadId: "thread-1",
    counterpartOrganizationId: "org-2",
  });
  assert.deepEqual(sent, [accepted]);
});

test("project communication realtime gateway rejects missing fields and unauthorized subscriptions", async () => {
  const gateway = new ProjectCommunicationRealtimeGateway({
    async listProjectCommunicationMessages() {
      throw {
        getResponse() {
          return {
            statusCode: 403,
            code: "PROJECT_COMMUNICATION_FORBIDDEN",
            message: "Current organization is not a participant.",
            source: "server",
          };
        },
      };
    },
  });

  assert.deepEqual(
    await gateway.handleSubscribe(
      {},
      {
        action: "project_communication.subscribe",
        projectId: "project-1",
      },
    ),
    {
      eventType: "project_communication.subscription.rejected",
      code: "PROJECT_COMMUNICATION_INVALID",
      message: "Subscription requires projectId and threadId.",
    },
  );

  assert.deepEqual(
    await gateway.handleSubscribe(
      {},
      {
        action: "project_communication.subscribe",
        projectId: "project-1",
        threadId: "thread-1",
      },
      { authorization: "Bearer token" },
    ),
    {
      eventType: "project_communication.subscription.rejected",
      code: "PROJECT_COMMUNICATION_FORBIDDEN",
      message: "Current organization is not a participant.",
    },
  );
});

test("project communication realtime gateway forwards only matching message-created events", async () => {
  const sentA = [];
  const sentB = [];
  const gateway = new ProjectCommunicationRealtimeGateway({
    async listProjectCommunicationMessages() {
      return { items: [], nextCursor: null };
    },
  });

  await gateway.handleSubscribe(
    {
      send(message) {
        sentA.push(JSON.parse(message));
      },
    },
    {
      action: "project_communication.subscribe",
      projectId: "project-1",
      threadId: "thread-1",
    },
  );
  await gateway.handleSubscribe(
    {
      send(message) {
        sentB.push(JSON.parse(message));
      },
    },
    {
      action: "project_communication.subscribe",
      projectId: "project-2",
      threadId: "thread-2",
    },
  );

  assert.equal(
    gateway.forwardMessageCreated({
      eventType: "project_communication.message.created",
      eventId: "event-1",
      messageId: "message-1",
      threadId: "thread-1",
      projectId: "project-1",
      senderOrganizationId: "org-1",
      messageKind: "text",
      body: "hello",
      clientMessageId: "client-1",
      createdAt: "2026-05-18T00:00:00.000Z",
    }),
    1,
  );
  assert.equal(
    gateway.forwardMessageCreated({
      eventType: "project_communication.typing",
      threadId: "thread-1",
      projectId: "project-1",
    }),
    0,
  );

  assert.equal(sentA.length, 2);
  assert.equal(sentA[1].eventType, "project_communication.message.created");
  assert.equal(sentA[1].messageId, "message-1");
  assert.equal(sentB.length, 1);
});
