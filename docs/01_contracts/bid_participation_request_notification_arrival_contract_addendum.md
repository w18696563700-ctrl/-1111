---
owner: Codex 总控
status: frozen
purpose: Freeze app-facing contract additions for bid participation request arrival notifications.
layer: L2 Contracts
---

# Bid Participation Request Notification Arrival Contract Addendum

## 1. Contract Decision

本合同补丁对既有 notification 和 shell context 合同做加法冻结。

它不新增 app-facing route，不新增 Server Admin route，不改变参与竞标申请审核 API。

继续复用：

- `GET /api/app/notifications/list`
- `POST /api/app/notifications/read`
- `GET /api/app/shell/context`
- `GET /api/app/project/bid-participation/thread/detail`

## 2. Notification Type And Source

`AppNotificationReadModel.type` 新增允许值：

- `bid_participation_request`

`AppNotificationReadModel.source` 新增允许值：

- `bid_participation_request`

最小语义：

- `type=bid_participation_request`
- `source=bid_participation_request`
- 只表示 `bid_participation_request.pending.created` 到达提醒。

不得用该类型表示审批结果、竞标提交、支付、预授权、订单或合同动作。

## 3. Notification Read Model Fields

参与竞标申请到达提醒必须返回：

| Field | Rule |
| --- | --- |
| `notificationId` | Server-owned notification id |
| `type` | `bid_participation_request` |
| `source` | `bid_participation_request` |
| `title` | controlled copy, recommended `有新的参与竞标申请` |
| `body` | optional controlled copy, must not expose internal ids |
| `projectId` | target project id |
| `threadId` | same as request id for existing thread detail carrier |
| `routeTarget` | must point to existing bid participation request thread |
| `createdAt` | server timestamp |
| `readAt` | nullable |
| `unread` | `readAt == null` projection |

## 4. Route Target

参与竞标申请到达提醒的 `routeTarget` 必须满足：

| Field | Value |
| --- | --- |
| `canonicalPath` | `/api/app/project/bid-participation/thread/detail` |
| `localEntryKey` | `bid_participation_request.open` |
| `requiredParams` | `threadId`, `projectId`, `requestId` |
| `routeParams.threadId` | bid participation request id |
| `routeParams.projectId` | target project id |
| `routeParams.requestId` | bid participation request id |
| `state` | `enabled` |

Flutter 可根据既有 route registry 将其映射到本地审核线程页。
BFF 不得把该 routeTarget 改写到 Admin、Server internal path 或本地私有 route。

## 5. Shell Context Unread Summary

`GET /api/app/shell/context` 的 `unreadSummary.messages` 语义扩展为：

- 当前组织在消息楼内可见的 unread summary count。

允许计入：

1. project communication unread projection。
2. notification center unread projection 中 `source=bid_participation_request` 的 unread item。

去重规则：

- `source=project_communication` / `type=project_communication_message` 不得与 project communication read-cursor unread 重复计入。
- `source=bid_participation_request` 可以独立计入，因为它不是项目沟通 message。

## 6. Read Boundary

`POST /api/app/notifications/read` 对 `bid_participation_request` notification 的行为不变：

- Request: `notificationIds[]`
- Response: `readNotificationIds[]` and `unread`

它只写 notification read truth。
不得写 project communication read cursor，不得改变 `bid_participation_request.state`。

## 7. Compatibility

- 旧 runtime 不返回 `bid_participation_request` notification 时，Flutter 只能显示无提醒或 capability unavailable，不得本地补造。
- 未知 notification `type/source` 必须 fail-controlled 或按现有受控 fallback 展示，不得静默吞掉关键业务提醒。
- 缺失 routeTarget 时可显示提醒，但点击必须受控提示暂不可打开。

## 8. Implementation Scope Guard

允许实现范围：

- Server 在创建 pending 申请时创建 notification。
- Server shell unread 聚合加入可见 notification unread。
- BFF shape validation 放行新增 `type/source` 和 routeTarget。
- Flutter 展示新增 source 文案并复用既有 routeTarget jump。

禁止实现范围：

- 新增表或 migration。
- 新增 app-facing route。
- 新增 Admin route。
- BFF 持久化 notification 或计算 unread。
- Flutter 本地推断 badge。
- 将申请提醒写成聊天消息。
