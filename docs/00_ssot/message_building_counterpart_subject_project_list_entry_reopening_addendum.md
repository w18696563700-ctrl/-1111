---
owner: Codex 总控
status: current
layer: L0 SSOT
scope: messages_building_counterpart_subject_entry
created_at: 2026-05-09
---

# 消息楼主体入口项目列表优先 Reopening Addendum

## 1. Reopening Reason

消息楼项目沟通首页的主体卡代表“与某一主体相关的项目集合”，不是某一个具体项目聊天线程。

本轮只修正 Flutter 首页主体卡点击落点：点击主体卡应先进入该主体项目列表；项目列表里的“进入沟通”才进入具体项目聊天。

## 2. Frozen Entry Semantics

- 消息楼主体卡：主体项目列表入口，使用 `conversationId` 和当前主体卡的 `projectId` 作为读取上下文。
- 主体项目列表中的“进入沟通”：具体项目聊天入口，必须具备 `projectId` 和 `threadId`。
- 铃铛通知 / 项目消息通知：深链入口，允许继续使用完整 `routeTarget` 直达具体项目聊天。

Flutter 不得把主体卡点击伪装成“最近项目聊天”或“默认项目聊天”。

## 3. ThreadId Boundary

本轮不降低 `threadId` 的真值要求。`threadId` 仍然是具体项目聊天和通知深链的必要上下文。

当前 `CounterpartConversationConsumerLayer.loadDetail` 仍要求 `conversationId + projectId` 才能读取主体项目列表，因此主体卡允许携带 `projectId` 作为只读详情上下文。

主体卡进入项目列表时不得携带 `threadId`；这只是入口语义差异，不是接口字段真值变化。

## 4. Allowed Scope

- Flutter 消息楼主体卡点击逻辑。
- Flutter targeted tests for subject-card entry and notification deep-link non-regression.

## 5. No-Go Scope

- 不改 BFF。
- 不改 Server。
- 不改 OpenAPI。
- 不改 generated types。
- 不改云端 runtime。
- 不新增接口、字段、状态、业务待办真值。
- 不改变通知 `routeTarget` 的深链语义。
- 不扩展成泛 IM 或项目沟通重构。

## 6. Acceptance

- 点击消息楼项目沟通主体卡后，先看到该主体项目列表。
- 项目列表中的“进入沟通”仍进入具体项目聊天。
- 铃铛中的具体项目沟通通知仍可直达具体项目聊天。
- 缺少 `conversationId` 或 `projectId` 时显示中文兜底，不进入英文错误页。
