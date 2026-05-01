---
owner: Codex 总控
status: effective
purpose: Freeze additive L2 app-facing contract fields for message-building project communication readability and in-app unread reminders.
layer: L2 Contracts
---

# Counterpart Conversation Message Building Readability Contract Addendum

## 结论

本合同补丁是对既有 `GET /api/app/message/interactions`、`GET /api/app/message/counterpart-conversation/detail` 和 `GET /api/app/shell/context` 的加法字段冻结。它不新增 app-facing route，不新增写命令，不改变聊天 `projectId + threadId` 真值。

## `CounterpartConversationProjectGroup` Additive Fields

`GET /api/app/message/counterpart-conversation/detail` 的 `projectGroups[]` 允许新增：

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `projectPublishedAt` | `string | null` | yes | 项目真实发布时间，来源为 Server `ProjectEntity.publishedAt`。 |
| `projectUpdatedAt` | `string | null` | yes | 项目更新时间，来源为 Server `ProjectEntity.updatedAt`。 |
| `projectUnreadCount` | `number` | yes | 当前组织在该项目沟通 thread 上的最小未读计数。 |
| `hasProjectUnread` | `boolean` | yes | `projectUnreadCount > 0` 的布尔投影。 |

展示口径：

- `projectPublishedAt` 用于项目列表卡片 `发布时间：yyyy-MM-dd HH:mm`。
- `latestActivityAt` 仍仅表示 counterpart conversation 最新活动，不得当作发布时间。
- `projectUnreadCount` 本阶段允许按 thread 粒度返回 `0 | 1`，后续精确消息条数需另行冻结。

## `CounterpartConversationBusinessCard` Additive Fields

`GET /api/app/message/counterpart-conversation/detail` 的 `projectGroups[].cards[]` 允许新增：

| Field | Type | Required | Applies to |
| --- | --- | --- | --- |
| `requesterCompanyName` | `string | null` | yes | `project_name_access_request`, `bid_participation_request` |
| `requesterOrganizationId` | `string | null` | yes | `project_name_access_request`, `bid_participation_request` |

规则：

- Server 必须从真实 requester organization / approved certification projection 得到 `requesterCompanyName`。
- BFF 不得从 `summary` 文案截取公司名。
- Flutter 项目页业务入口应消费该结构化字段。
- 对不适用的 card type，字段返回 `null`。

## `AppShellUnreadSummary` Additive Bucket

`GET /api/app/shell/context` 的 `unreadSummary` 允许新增 bucket：

| Bucket | Type | Meaning |
| --- | --- | --- |
| `messages` | `number` | 当前组织项目沟通未读项目计数或最小未读摘要计数。 |

规则：

- `messages` 是 App 内 badge 汇总，不是系统通知真值。
- `messages` 只用于底部消息楼 badge 和 App 内项目沟通提醒。
- 不产生 push、声音、震动、锁屏通知语义。

## Error And Compatibility Boundary

- 新字段缺失时，Flutter 在本轮实现中应进入受控兼容：
  - `projectPublishedAt == null` 隐藏发布时间。
  - `requesterCompanyName == null` 使用受控文案 `对方公司`，不得从 summary 截取。
  - `projectUnreadCount` 缺失按 `0` 处理仅限旧 runtime 兼容。
- BFF read-model 在云上目标版本中必须校验字段类型，避免错误类型进入 Flutter。
- 本合同不改变既有错误码：
  - `COUNTERPART_CONVERSATION_UNAVAILABLE`
  - `COUNTERPART_CONVERSATION_FORBIDDEN`
  - `COUNTERPART_CONVERSATION_INVALID`
  - `AUTH_SESSION_INVALID`

## Explicit Non-Goals

- 不新增 `/api/app/messages/*`。
- 不新增 generic notification route。
- 不新增 push-token route。
- 不新增系统通知权限 contract。
- 不改变 `POST /api/app/message/project-communication/read-cursor`。

