---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 L5 Flutter consumption boundary for `对方主体会话容器`,
  covering the unified messages entry, project-sliced container rendering,
  old-carrier downgrade handoff, and the project-title click permission-sheet
  behavior.
layer: L5 Frontend
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/counterpart_conversation_contract_freeze_addendum.md
  - docs/03_bff/counterpart_conversation_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_name_access_request_frontend_consumption_freeze_addendum.md
  - docs/04_frontend/messages_interaction_center_and_bidder_carry_frontend_consumption_freeze_addendum.md
---

# 《对方主体会话容器 frontend consumption freeze》

## 1. Scope

- 本冻结单只覆盖 Flutter 消费面：
  - `MessagesPage` 统一入口中的 counterpart list
  - `CounterpartConversationPage` 容器详情页
  - 旧 carrier detail handoff
  - 项目详情标题点击权限 sheet
- 本冻结单不覆盖：
  - generic chat composer
  - 本地审批状态机
  - direct-to-Server

## 2. Unified Entry Consumption

- 统一消息入口当前允许新增：
  - `对方主体会话容器列表`
- Flutter 当前必须把每个列表项渲染为：
  - 一个对方主体一个 entry
  - 列表入口继续来自 `GET /api/app/message/interactions`
  - 点击后进入 `CounterpartConversationPage`
- Flutter 当前不得：
  - 把不同对方主体 merge 到一个会话 entry
  - 继续把旧 `project_name_access_thread / bid_thread` 直接挂在一级入口

## 3. Container Detail Consumption

- `CounterpartConversationPage` 当前必须按 `projectId` 分 section 渲染。
- 每个 section 只允许呈现：
  - `projectDisplayTitle`
  - `titleVisibility`
  - `projectState`
  - `cards`
- Flutter 当前不得：
  - 把多个 `projectId` 的业务状态揉平为一个总状态
  - 省略项目分组

## 4. Old Carrier Handoff Consumption

- `project_name_access_thread` 当前只允许作为：
  - 名称申请详情页 handoff
- `bid_thread` 当前只允许作为：
  - 竞标详情页 handoff
- Flutter 当前必须通过 `routeTarget.actionKey` 决定 handoff：
  - `project_name_access_thread.open`
  - `bid_thread.open`
  - `project_clarification.open`
- Flutter 当前不得：
  - 在本地猜测 thread 类型
  - 只靠 `threadId` 继续，不带 `projectId`

## 5. Title Click Permission Sheet

- 项目详情页标题 `项目名称需申请查看` 当前正式固定为可点击文本。
- 当 `projectTitleAccess.canOpenPermissionSheet = true` 时：
  - 点击标题必须弹出权限 sheet
  - 不得直接进入旧 thread
- sheet 当前只允许消费：
  - `displayTitle`
  - `reasonCode`
  - `canRequest`
  - `requestAction`
- 若允许申请，sheet 内只允许承接原动作：
  - `project_name_access.request.submit`

## 6. Frontend No-Go

- 不得 direct-to-Server
- 不得 local unified business state machine
- 不得把旧 carrier 继续当主入口
- 不得让标题点击绕过 permission sheet
- 不得丢失 `projectId`

## 7. Stage Conclusion

- `对方主体会话容器` 的 L5 frontend consumption boundary 现正式冻结。
- 当前已形成：
  - `L0 -> L5` Day-1 完整文书链
- 下一步只允许：
  - `Go for implementation sequencing within frozen boundary`
- 当前仍：
  - `No-Go for out-of-bound expansion`
