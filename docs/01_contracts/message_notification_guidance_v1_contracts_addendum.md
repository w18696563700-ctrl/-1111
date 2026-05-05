---
owner: Codex 总控
status: frozen
purpose: Freeze the L2 contracts for messages-building notification guidance system V1.
layer: L2 Contracts
---

# 消息提示与引导体系 V1 Contracts Addendum

## 1. Contract Decision

本 addendum 冻结 `消息提示与引导体系 V1` 的 app-facing contracts：

- `/api/app/notifications/list` 必须支持来源分流读取。
- 每个 `AppNotificationReadModel.source` 必填。
- `AppNotificationUnreadProjection` 必须能解释铃铛总数。
- `routeTarget` 不可用时，Flutter 不得自动 mark-read。
- 业务待办继续走 `businessTodoSummary` 与 `entries[].badgeCount`，不混入普通通知 unread。

对应 L0：

- `docs/00_ssot/message_notification_guidance_v1_truth_freeze_addendum.md`

## 2. Notification List Query

`GET /api/app/notifications/list` 新增可选 query：

| Query | Required | Values | Meaning |
| --- | --- | --- | --- |
| `source` | false | `all`, `project_communication`, `forum_interaction`, `business_todo`, `system` | 当前通知列表读取来源。 |
| `lane` | false | same as `source` | 兼容别名；如果同时传入，以 `source` 为准。 |

规则：

- `all` 或缺省表示返回全部通知列表。
- `project_communication` 只返回项目沟通来源通知。
- `forum_interaction` 只返回论坛互动来源通知。
- `business_todo` 在 V1 是业务待办通知 lane，可映射既有 `bid_participation_request` 等待办类通知，但不替代 `businessTodoSummary`。
- `system` 只返回系统通知。

## 3. Unread Projection

`AppNotificationUnreadProjection` 必须包含：

- `total`
- `projectCommunication`
- `businessTodo`
- `forumInteraction`
- `system`

兼容字段：

- `bidParticipationRequest` 可继续保留，但在 V1 UI 语义中并入 `businessTodo`，不得形成第二套待办口径。

`unread` projection 是当前 actor / organization 的全局通知 unread projection，不随 `source` 列表过滤缩小。这样 Flutter 能在铃铛分组内同时展示各来源数量。

要求：

`total = projectCommunication + businessTodo + forumInteraction + system`

## 4. Route Target And Mark Read

`AppNotificationRouteTarget` 继续是受控跳转承接，不是 Flutter 本地路由真值。

如果 item 的 `routeTarget` 为 `null`、`state != enabled`、缺少必要 route params，或 Flutter 无法构造安全目标：

- Flutter 不得调用 `/api/app/notifications/read`。
- BFF 不得替 Flutter 自动 mark-read。
- Server 不得因为 list 被读取而自动 mark-read。

只有 Flutter 成功发起定位后，才允许调用 mark-read。

## 5. Forum Interaction Inbox

`/api/app/forum/interaction/inbox` 继续承接论坛互动列表。

本轮不强制把 forum inbox 读游标并入 notification unread。若后续要把论坛互动 item 级 read cursor 与 notification unread 合并，必须另行冻结。

## 6. Business Todo Boundary

业务待办红点仍由项目沟通 / workbench read model 承接：

- `businessTodoSummary`
- `entries[].badgeCount`
- `disabledReason`

`/api/app/notifications/list?source=business_todo` 只用于通知中心分组读取，不得作为项目沟通业务状态真值。

## 7. Layer Responsibilities

| Layer | Responsibility | Forbidden |
| --- | --- | --- |
| Server | notification source filter, unread buckets, routeTarget truth, mark-read truth | auto-read on list, mixing project/forum sources |
| BFF | pass through query and read model, validate known source values | recompute unread, merge forum inbox into notification list |
| Flutter | show source tabs, guide route, request mark-read after successful navigation | local business todo truth, mark-read when route unavailable |

## 8. Non-Goals

This contract does not define:

- generic IM
- private messages
- group chat
- notification preference center
- push channel preference governance
- new forum state machine
- new project state machine
- payment, wallet, settlement, invoice, guarantee deposit
- fulfillment, acceptance, rating, dispute
