---
owner: Codex 总控
status: frozen
purpose: Freeze Day 1 additive app-facing contract fields for project communication unread/read semantics.
layer: L2 Contracts
---

# Project Communication Unread And Read Contract Field Table Day1 Addendum

## 1. 总裁决

`Conditional Pass` for additive contract freeze.

本文件只冻结字段和 app-facing 读模型口径，不直接修改 `openapi.yaml`。进入实现前，若 Day 2/Day 3 要求严格合同生成，则必须把本表同步到正式 OpenAPI 和 generated types。

## 2. Contract Scope

涉及既有 app-facing surfaces：

| Surface | Route | Change type |
| --- | --- | --- |
| Shell context | `GET /api/app/shell/context` | additive fields inside `unreadSummary` |
| Message interactions | `GET /api/app/message/interactions` | additive fields for counterpart conversation card |
| Counterpart conversation detail | `GET /api/app/message/counterpart-conversation/detail` | additive fields for project relation tabs and project groups |
| Project communication messages | `GET /api/app/message/project-communication/messages` | additive fields for delivery/read display |
| Project communication read cursor | `POST /api/app/message/project-communication/read-cursor` | payload/result must carry `lastReadMessageId` in new implementation |

No new route is admitted by this Day 1 freeze.

## 3. `AppShellUnreadSummary`

| Field | Type | Required | Source | Rule |
| --- | --- | --- | --- | --- |
| `messages` | `number` | yes | Server unread aggregation | 当前组织项目沟通未读消息条数汇总。 |

Compatibility:

- Missing `messages` may be treated as `0` only for old runtime compatibility.
- Negative, non-number, or string values must fail BFF read-model validation in target implementation.

## 4. `MessageInteractionItemView`

For items where `interactionType = "counterpart_conversation"`:

| Field | Type | Required | Source | Rule |
| --- | --- | --- | --- | --- |
| `conversationUnreadCount` | `number` | yes | Server projection | 当前 counterpart 下所有项目未读消息条数。 |
| `hasUnread` | `boolean` | yes | Server projection | `conversationUnreadCount > 0`。 |
| `latestUnreadMessageAt` | `string | null` | yes | Server projection | 当前 counterpart 下最新未读消息时间；无未读为 `null`。 |

Rules:

- BFF must not compute this from stale local cache.
- Flutter must not infer this by summing locally if Server/BFF provides the field.

## 5. `CounterpartConversationDetailView`

Add relation-level unread summary:

| Field | Type | Required | Source | Rule |
| --- | --- | --- | --- | --- |
| `myPublishedUnreadCount` | `number` | yes | Server projection | 当前组织作为发布方相关项目未读消息条数。 |
| `myBidUnreadCount` | `number` | yes | Server projection | 当前组织作为竞标/承接方相关项目未读消息条数。 |

Compatibility:

- If the current detail model prefers `relationSummaries[]`, each item must carry `relation`, `projectCount`, `unreadCount`, `hasUnread`.
- Do not allow Flutter to infer relation ownership from display copy.

## 6. `CounterpartConversationProjectGroup`

| Field | Type | Required | Source | Rule |
| --- | --- | --- | --- | --- |
| `projectUnreadCount` | `number` | yes | Server projection | 该 `projectId + threadId` 下对当前组织未读消息条数。 |
| `hasProjectUnread` | `boolean` | yes | Server projection | `projectUnreadCount > 0`。 |
| `latestUnreadMessageAt` | `string | null` | yes | Server projection | 该项目最新未读消息时间。 |
| `threadId` | `string` | yes | Server truth | read cursor 和消息列表必须使用同一 thread。 |
| `projectId` | `string` | yes | Server truth | 所有动作必须锚定项目。 |

Rules:

- `projectUnreadCount` must mean unread message count, not unread thread count.
- A project group without `projectId` or `threadId` must not render unread actions.

## 7. `ProjectCommunicationMessageView`

| Field | Type | Required | Source | Rule |
| --- | --- | --- | --- | --- |
| `messageId` | `string` | yes | `ProjectCommunicationMessage.id` | Persisted message id. |
| `projectId` | `string` | yes | `ProjectCommunicationMessage.projectId` | Business boundary. |
| `threadId` | `string` | yes | `ProjectCommunicationMessage.threadId` | Conversation boundary. |
| `senderOrganizationId` | `string` | yes | `ProjectCommunicationMessage.senderOrganizationId` | Sender organization. |
| `deliveryState` | `"persisted"` | yes | Server persistence | Persisted messages are already stored. Draft states stay Flutter-local. |
| `readState` | `"unread_by_counterpart" | "read_by_counterpart" | "not_applicable"` | yes | Server read cursor projection | Applies mainly to current org's own messages. |
| `readByCounterpartAt` | `string | null` | yes | Counterpart read cursor | Null until counterpart cursor covers this message. |

Flutter-local draft states:

| Local field | Values | Rule |
| --- | --- | --- |
| `draftDeliveryState` | `sending`, `failed` | Not persisted, not sent to Server as truth. |

## 8. `ProjectCommunicationReadCursorPayload`

Target payload shape:

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `projectId` | `string` | yes | Must match target project. |
| `threadId` | `string` | yes | Must belong to project. |
| `lastReadMessageId` | `string` | yes | Must belong to target thread. |

Server-derived fields:

| Field | Rule |
| --- | --- |
| `organizationId` | Derived from authenticated current organization, not client-controlled. |
| `lastReadAt` | Server timestamp. |

Compatibility:

- Existing payloads that only carry project/thread may remain accepted temporarily by marking latest visible message, but Day 2 target implementation should prefer explicit `lastReadMessageId`.

## 9. Error Boundary

No new business error family is required for Day 1. Existing normalized auth/forbidden/invalid errors may be reused.

Required validation failures:

- Missing `projectId`.
- Missing `threadId`.
- Missing or invalid `lastReadMessageId` in target implementation.
- Message does not belong to `projectId + threadId`.
- Current organization is not a participant.

## 10. Explicit Non-Goals

- No push token route.
- No notification permission route.
- No APNs / FCM provider contract.
- No generic message center contract.
- No BFF-owned unread contract.
