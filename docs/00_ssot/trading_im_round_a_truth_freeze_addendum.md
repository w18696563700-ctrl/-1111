---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L0 truth boundary for Trading-scoped IM Round A, admitting only
  project public clarification, project-bid private thread, minimum
  confirmation cards, and messages-building reminder handoff while explicitly
  excluding general chat, forum DM, stranger DM, realtime transport, and
  post-deal full conversation workflows.
layer: L0 SSOT
freeze_date_local: 2026-04-16
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/s1_r06_messages_single_active_object_truth_ruling_controller_review_conclusion_addendum.md
  - docs/00_ssot/s1_c01_message_index_minimal_closure_execution_dispatch_receipt_addendum.md
  - docs/00_ssot/exhibition_app_full_function_register_v1.md
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - docs/02_backend/project_transaction_skeleton_p0_backend_truth_addendum.md
  - docs/02_backend/audit_log_spec.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
  - apps/server/src/modules/project/project.module.ts
  - apps/server/src/modules/bid/bid.module.ts
  - apps/server/src/modules/upload/upload-write.service.ts
  - apps/bff/src/routes/routes.module.ts
  - apps/mobile/lib/features/messages/presentation/messages_page.dart
---

# 《交易场景 IM Round A 真相冻结补充单》

## 1. Scope

- 本冻结单只覆盖 `交易场景 IM Round A`。
- 本轮唯一定位固定为：
  - 挂在交易对象上的工作沟通系统
  - 公开澄清负责统一项目口径
  - 私密线程负责项目与投标关系内的深入沟通
  - 确认卡负责关键结论结构化沉淀
  - `messages` building 只负责提醒与回跳
- 本轮不是：
  - 通用聊天平台
  - forum DM
  - stranger DM
  - group chat
  - post-deal full conversation suite
  - realtime transport package

## 2. Current Repository Judgment

- 仓库当前未找到 `project public clarification` 的正式 SSOT、contract、
  Server truth owner、BFF route、Flutter active consumer。
- 仓库当前未找到 `project-bid private thread` 的正式 SSOT、contract、
  Server truth owner、BFF route、Flutter active consumer。
- 当前 `messages` 证据只指向：
  - `forum interaction inbox`
  - `/api/app/message/index` placeholder
- 以上两者均不得解释为交易场景 IM active runtime。
- 当前可复用底座固定为：
  - Project truth anchor
  - Bid truth anchor
  - Auth / Organization / session / visibleBuildings
  - upload corridor
  - confirmed `FileAsset`
  - append-only audit
  - Flutter shell / messages building / exhibition route context
- 当前裁决固定为：
  - `Go for docs-freeze`
  - `No-Go for implementation`
  - `No-Go for release-prep`

## 3. Object 1: Project Public Clarification

- `project public clarification` 正式定义为：
  - 挂在 `project` 上的公开工作澄清区
  - 用于项目发布后统一补充、答疑、口径修正和公平信息披露
  - 其业务锚点是 `projectId`
- 它不是：
  - forum post/comment
  - public showcase attachment wall
  - generic message thread
  - Admin review ticket

### 3.1 Visibility

- 最小可见范围固定为：
  - project owner organization participants
  - admitted project viewers under the existing project-detail visibility
  - admitted bidders when they can access the referenced project
- 未登录、无项目可见权限、被 Server 判定不可见的 actor 不得读取。
- BFF 和 Flutter 不得自行扩大可见范围。

### 3.2 Write Authority

- 最小发起/写入权限固定为：
  - project owner organization with eligible buyer role
  - admitted bidder organization only when Server confirms project visibility
- Server owns final permission.
- Flutter may show or hide entry only from Server/BFF projection and must not
  invent permission.

### 3.3 Content Boundary

- 本轮允许内容只限项目口径相关工作信息：
  - dimensions supplement
  - material / craft clarification
  - site restriction
  - move-in / move-out timing
  - drawing or document update notice
  - organizer requirement supplement
  - unified Q&A
- 本轮不允许内容语义扩展为：
  - negotiation workflow
  - bid compare scoring
  - contract amendment
  - dispute evidence workflow
  - forum discussion loop

### 3.4 Attachment Boundary

- 附件只允许绑定 confirmed `FileAssetId`。
- Upload must stay `init -> direct upload -> confirm`.
- `objectKey` remains storage location only and must not become clarification
  business truth.
- 本轮不创建第二上传系统。
- 本轮不把 upload confirm 解释为 clarification business row creation.

### 3.5 Lifecycle

- 最小生命周期固定为：
  - `active`
  - `hidden`
  - `archived`
- Round A 只允许实现：
  - list
  - create
- Round A 明确 No-Go：
  - close command
  - hide command
  - archive command
  - moderation workbench
  - edit/delete history workflow
- 若后续需要隐藏或归档，必须先另行冻结治理与审计动作。

### 3.6 Messages Building Relation

- `messages` building 只可消费 clarification reminder projection and jump target。
- `messages` building 不拥有 clarification truth。
- `messages` building 不得成为 clarification list/detail/write owner。

## 4. Object 2: Project-Bid Private Thread

- `project-bid private thread` 正式定义为：
  - 挂在 `project + bid` 或 `project + bidder relation` 上的关系级私密工作线程
  - 用于项目发布方与某个投标方围绕当前投标关系沟通
- 本轮冻结的 canonical business anchor 为：
  - `projectId`
  - `bidId`
- 若实现阶段发现既有 bid carrier 不足以表达 pre-submit bidder relation，
  必须停下回到真相冻结，不得在代码中临时发明第二关系模型。

### 4.1 Participants

- 最小参与方固定为：
  - project owner organization participants
  - bidder organization participants for the targeted bid
- 不得进入的 actor：
  - unrelated bidder
  - unrelated buyer organization
  - ordinary viewer without bid relation
  - forum actor without project-bid relation
  - Admin operator through app-facing route

### 4.2 Initiation And Reply Authority

- 发布方可发起私密线程。
- 投标方可申请沟通或在已有 thread 内按 Server permission 回复。
- Server owns final participant and permission truth.
- BFF only normalizes headers and shapes response.
- Flutter only consumes projected capability.

### 4.3 Content Boundary

- 本轮允许内容只限项目投标关系内的工作沟通：
  - proposal understanding
  - quote item explanation
  - craft feasibility
  - schedule feasibility
  - attachment supplement
  - local risk explanation
- 本轮不进入：
  - full negotiation system
  - order/contract/dispute full conversation
  - private social chat
  - phone or WeChat disclosure workflow

### 4.4 Attachment Boundary

- Thread message attachments only accept confirmed `FileAssetId`.
- The thread or message business row must bind `FileAssetId`; it must not bind
  raw `objectKey`.
- Upload confirm alone never creates thread message truth.

### 4.5 Lifecycle

- 最小 lifecycle 固定为：
  - `open`
  - `restricted`
  - `archived`
- Round A 只允许实现：
  - detail
  - message list as part of detail or equivalent bounded read
  - send message
- Round A 明确 No-Go：
  - read receipt
  - typing
  - online presence
  - websocket / SSE / push
  - thread transfer
  - full moderation console
  - delete/edit workflow

### 4.6 Messages Building Relation

- `messages` building 只可消费 bid-thread reminder projection and jump target。
- `messages` building 不拥有 thread truth, message truth, or participant truth。
- Reminder click must jump back to the project-bid object surface.

## 5. Object 3: Confirmation Card Minimum

- `confirmation card` 正式定义为：
  - `project-bid private thread` 的子对象
  - thread 中关键结论的结构化沉淀记录
- 它不是：
  - chat body itself
  - independent generic confirmation system
  - contract confirmation
  - order confirmation
  - dispute evidence carrier
- 本轮只允许三种 confirmation type：
  - `quote`
  - `craft_material`
  - `schedule`
- 本轮不引入独立复杂状态机。
- 本轮不引入撤回/作废工作台。
- 若需要否定旧结论，默认通过新增后续确认记录承接，不回写原记录。

### 5.1 Authority And Visibility

- 发起方必须是 thread participant。
- 查看方必须是 thread participant。
- Server owns final permission.
- Confirmation card must be strongly bound to the thread.

### 5.2 Audit

- Confirmation card create must be independently auditable.
- Minimum audit action:
  - `ConfirmationCardCreated`
- It must not be recorded by BFF or Flutter as second audit truth.

## 6. Audit Boundary

- Minimum must-audit actions for Round A:
  - `ProjectClarificationCreated`
  - `BidThreadMessageSent`
  - `ConfirmationCardCreated`
- Audit must be Server-owned and append-only.
- BFF and Flutter must not create a second audit system.

## 7. Global No-Go

- No generic message center.
- No station inbox.
- No forum DM.
- No stranger DM.
- No group chat.
- No audio or video call.
- No WebSocket.
- No SSE.
- No push.
- No typing.
- No online status.
- No read receipt.
- No order/contract/dispute full conversation.
- No private-message reporting / stranger controls / message preview governance.
- No commercial model, fee model, commission model.
- No Admin implementation in Round A.

## 8. Formal Conclusion

- `Trading-scoped IM Round A` is admitted as a bounded docs-freeze package.
- The current active objects are newly frozen only by this document:
  - `project public clarification`
  - `project-bid private thread`
  - `confirmation card minimum`
  - `messages building reminder handoff`
- Current status:
  - `Go for contracts freeze`
  - `No-Go for implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
