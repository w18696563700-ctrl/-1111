---
owner: Codex 总控
status: effective
purpose: Submit Day-1 stage gate checklist for message-building project communication readability and in-app unread reminders.
layer: L0 SSOT
---

# Counterpart Conversation Message Building Readability Day1 Stage Gate Checklist

## 阶段结论

Day 1 冻结通过，允许进入第 2 天 Server 只读投影补齐。

## 门禁核查

| Gate | Result | Evidence |
| --- | --- | --- |
| 真源门禁 | Pass | L0 真相冻结于 `counterpart_conversation_message_building_readability_day1_truth_freeze_addendum.md`。 |
| 目录洁癖门禁 | Pass | 新增文件均位于 `docs/00_ssot` 与 `docs/01_contracts`。 |
| 架构边界门禁 | Pass | Flutter 仍只访问 BFF；BFF 不拥有业务真值；Server 仍是字段和未读聚合 owner。 |
| 契约门禁 | Pass | L2 合同冻结 `projectPublishedAt`, `projectUpdatedAt`, `requesterCompanyName`, `requesterOrganizationId`, `projectUnreadCount`, `hasProjectUnread`, `unreadSummary.messages`。 |
| 状态机门禁 | Pass | 不新增状态机，不改聊天发送、读取、审核、订单状态。 |
| 数据与上传门禁 | Pass | 不涉及上传，不新增表，不新增迁移。 |
| 前端体验门禁 | Pass | 冻结总框非聊天容器、项目入口发布时间、业务说明 + `进入审核`、App 内未读。 |
| 云上运行门禁 | Pending for Day 5 | Day 1 不动云端；云上对齐保留到第 5 天。 |
| 阶段控制门禁 | Pass | 第 2 天仅允许 Server 只读 projection 和 targeted tests。 |
| 文件职责门禁 | Pass | Day 1 仅新增文书，不改业务代码。 |

## Veto Check

| Veto Item | Status |
| --- | --- |
| 用 `latestActivityAt` 冒充发布时间 | Blocked |
| 从 `summary` 截取公司名 | Blocked |
| 把 App 内未读扩大成系统 push | Blocked |
| 在总框页显示聊天框 | Blocked |
| 聊天脱离 `projectId + threadId` | Blocked |

## Next Stage Permission

允许进入第 2 天：

- Server 可以在 `apps/server/src/modules/message_interaction/**`、`apps/server/src/modules/project_communication/**`、`apps/server/src/modules/shell/**` 内做只读 projection 补齐。
- Server 可以补 targeted tests。
- 不允许新增表、迁移、写命令或状态机。

