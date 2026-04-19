---
owner: Codex 总控
status: active
purpose: >
  Freeze the refreshed L2 contract family for `订单承接与履约承接主链` after
  the post-cleanup truth-boundary refresh, limiting the current object to the
  included continuation mainline while explicitly recording adjacent-but-excluded
  shell/handoff runtime and retaining all implementation and release vetoes.
layer: L2 Contracts
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_refreshed_truth_boundary_freeze_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_fresh_asset_inventory_refresh_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_reentry_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_successor_reentry_ruling_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_maintenance_only_follow_up_judgment_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/commands/milestone_submit_command.dart
  - apps/mobile/lib/features/exhibition/data/commands/inspection_submit_command.dart
  - apps/mobile/lib/features/exhibition/data/commands/dispute_open_command.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart
  - apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts
  - apps/bff/src/routes/trading_shell_handoff/app-trading-shell-handoff.controller.ts
  - apps/bff/src/routes/trading_shell_handoff/trading-shell-handoff.service.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts
  - apps/server/src/modules/trading_shell_handoff/trading-shell-handoff.controller.ts
  - apps/server/src/modules/trading_shell_handoff/trading-shell-handoff.presenter.ts
---

# 《订单承接与履约承接主链 refreshed contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `订单承接与履约承接主链`
- 本冻结单只服务于：
  - 当前对象 included mainline 的 app-facing / server-facing contract family
  - 当前对象 read-model 最小字段边界
  - 当前对象 submit handoff request / accepted response 最小边界
  - 当前对象 controlled error / unavailable 语义
  - 当前对象 adjacent-but-excluded runtime 的 contract 边界声明
- 本冻结单不进入：
  - persistence / migration
  - backend / BFF / Flutter 实现
  - integration
  - `release-prep`
  - `production release`

## 2. Refreshed Contract Freeze Conclusion

- 本轮 refreshed contract freeze 不是 `no-op`。
- 本轮只冻结当前对象纳入范围内的最小 contract 变化。
- 与旧版
  [order_intake_and_fulfillment_mainline_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/order_intake_and_fulfillment_mainline_contract_freeze_addendum.md)
  相比，当前必须收正 3 件事：
  1. `milestone/submit` 的最小 accepted body
     当前只冻结到 `milestoneId`，
     不再要求旧版的 `state + summary`。
  2. 当前 repo 里的 shell / handoff server-facing 对应 path
     已经是 concrete path：
     - `POST /server/milestone/submit`
     - `POST /server/inspection/submit`
     而不是旧文书里的占位式 resource-style 写法。
  3. `dispute/open`
     虽然当前已在 repo / openapi 中存在相邻 shell / handoff runtime，
     但它仍然不属于本对象 included contract family。
- 本轮不允许把以下排除项一并写进当前对象 contract 作用域：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/*`
  - `dispute/withdraw`
- 本轮 contract 的正式意义是：
  - 把 continuation 主链收紧到
    `activeOrderId / activeMilestoneId`
    已存在后的最小 read + submit handoff
  - 同时把相邻但不纳入当前对象的 shell / handoff runtime
    明确写成邻接边界，而不是自动回流

## 3. Canonical Path Family Freeze

### 3.1 Included App-facing Path Family

- 当前对象只冻结以下 included app-facing path：
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `GET /api/app/milestone/list`
  - `POST /api/app/milestone/submit`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`

### 3.2 Included Server-facing Minimal Corresponding Family

- 当前允许冻结的最小 server-facing 对应 family 为：
  - `GET /server/order/detail`
  - `GET /server/contract/detail`
  - `GET /server/milestone/list`
  - `POST /server/milestone/submit`
  - `GET /server/inspection/detail`
  - `POST /server/inspection/submit`
- 这里的正式含义是：
  - 若后续进入 refreshed backend truth / persistence freeze，
    只能围绕上述最小对应 family author
  - 不得再沿用旧版占位式 server-facing 命名
  - 不得发明与当前 active source 冲突的新 path

### 3.3 Adjacent-but-excluded Runtime

- 当前 repo 中已存在、但不纳入当前对象 contract family 的邻接 path 只有：
  - `POST /api/app/dispute/open`
  - `POST /server/dispute/open`
- 当前正式意义固定为：
  - 它们是相邻 shell / handoff runtime
  - 可以被当前对象的 order-bound continuation 邻接引用
  - 但不构成当前对象的 included contract family

### 3.4 Explicitly Excluded Path Family

- 当前必须明确禁止把以下 path 纳入本轮：
  - `POST /api/app/order/create`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `POST /api/app/inspection/recheck`
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/withdraw`

## 4. `order/detail` Refreshed Contract Freeze

- `GET /api/app/order/detail` 当前正式冻结为：
  - 当前对象的订单只读主 carrier
- `orderId` 当前正式定义为：
  - continuation anchor
  - 不是 Flutter / BFF 本地状态机输入

### 4.1 Minimum Response Semantics

- 最小响应语义至少包括：
  - `orderId`
  - `orderNo`
  - `projectId`
  - `bidId`
  - `state`
  - `summary`
  - 当前 order-bound continuation 所需的最小上下文

### 4.2 Hard Boundary

- 当前不得把 `order/detail` 扩成：
  - `order/create` write contract
  - dispute truth contract
  - rating truth contract
  - dispute detail / history contract
  - rating detail / history contract

## 5. `contract/detail` Refreshed Contract Freeze

- `GET /api/app/contract/detail` 当前正式冻结为：
  - 当前对象中的合同只读主 carrier
- 但以下 path 不在本轮：
  - `contract/confirm`
  - `contract/amend`

### 5.1 Minimum Response Semantics

- 最小响应语义至少包括：
  - `contractId`
  - `orderId`
  - `state`
  - `summary`

### 5.2 Hard Boundary

- 当前 detail 只服务于 continuation read。
- 当前不得扩到：
  - 合同历史
  - 条款编辑器
  - 法务审核环

## 6. `milestone/list` Refreshed Contract Freeze

- `GET /api/app/milestone/list` 当前正式冻结为：
  - 当前对象中的履约节点只读主 carrier

### 6.1 Minimum Response Semantics

- 最小响应语义至少包括：
  - `items[]`
  - `milestoneId`
  - `orderId`
  - `sequenceNo`
  - `title`
  - `amount`
  - `state`
  - `summary`

### 6.2 Hard Boundary

- 当前不得扩到：
  - milestone history
  - approval console
  - 第二履约状态机

## 7. `milestone/submit` Refreshed Contract Freeze

- `POST /api/app/milestone/submit` 当前正式冻结为：
  - 当前对象里允许纳入的第一个 write-handoff contract
- 当前正式语义是：
  - minimum submit shell / handoff accepted contract
  - 不是 milestone truth already advanced

### 7.1 Minimum Request

- 最小 request 至少包括：
  - `milestoneId`
  - `submissionNote` 为可选字段

### 7.2 Minimum Accepted Response

- 最小 accepted response 只冻结到：
  - `milestoneId`

### 7.3 Upload Reuse Boundary

- 如涉及文件补充：
  - 只能继续复用既有 upload 三段式 truth
  - 不得把上传 schema 混进 milestone business truth
  - 不得把 `objectKey` 写成业务主 contract 字段

### 7.4 Hard Boundary

- 当前只冻结最小 shell / handoff contract。
- 当前不得扩到：
  - `milestone.completed` 推导
  - inspection workflow truth
  - approval flow
  - 第二 milestone success field model

## 8. `inspection/detail` Refreshed Contract Freeze

- `GET /api/app/inspection/detail` 当前正式冻结为：
  - 当前对象中的验收只读主 carrier

### 8.1 Minimum Response Semantics

- 最小响应语义至少包括：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`
  - `rectificationCount`
  - `recheckCount`

### 8.2 Hard Boundary

- 当前不得扩到：
  - inspection history
  - governance console
  - 把 route presence 写成验收闭环完成

## 9. `inspection/submit` Refreshed Contract Freeze

- `POST /api/app/inspection/submit` 当前正式冻结为：
  - 当前对象里允许纳入的第二个 write-handoff contract
- 当前正式语义是：
  - inspection submit shell / handoff accepted contract
  - 不是 inspection truth already advanced

### 9.1 Minimum Request

- 最小 request 至少包括：
  - `inspectionId`

### 9.2 Minimum Accepted Response

- 最小 accepted response 至少包括：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`

### 9.3 Hard Boundary

- 当前不纳入：
  - `inspection/recheck`
- 当前不纳入：
  - `passed / archived` 最终闭环
- 当前不允许：
  - Flutter / BFF 本地判定验收通过

## 10. Adjacent `dispute/open` Contract Boundary Note

- `POST /api/app/dispute/open`
  当前在 repo / openapi 中已存在 shell / handoff accepted contract。
- 当前最小 request / accepted body 继续是：
  - request:
    - `orderId`
    - `reason` 为可选字段
  - accepted response:
    - `orderId`
    - `state`
    - `summary`
- 但当前必须明确：
  - 这是邻接边界记录
  - 不是把 `dispute/open`
    纳入当前对象 refreshed contract family

## 11. Controlled Error / Reuse Boundary / Stage Conclusion

### 11.1 Controlled Error And Unavailable Boundary

- 当前对象允许出现：
  - controlled unavailable
  - invalid-state
  - missing-anchor-style continuation failure
- 这些错误必须继续由 `Server` truth 决定。
- `BFF` 只允许做：
  - envelope
  - shaping
  - controlled failure normalization

### 11.2 Compatibility And Reuse Boundary

- `workbench` 复用边界：
  - `activeOrderId`
  - `activeMilestoneId`
    只承担 continuation carrier
  - 不承担对象真值
  - 不承担列表 / 详情 owner
- `my-project` 复用边界：
  - `privateSummary / privateProgress`
    只继续复用项目级摘要
  - 不能被写成当前对象的 contract family owner
  - 不再把 `ratings / disputes`
    写成当前对象 truth 输入
- upload 复用边界：
  - `milestone/submit` 如涉及补充凭证，
    继续复用既有：
    - `POST /api/app/file/upload/init`
    - direct upload
    - `POST /api/app/file/upload/confirm`
  - 但 upload truth 不得反客为主，
    变成当前对象业务主 contract

### 11.3 Explicit Non-goals

- `order/create`
- `contract/confirm`
- `contract/amend`
- `inspection/recheck`
- `rating`
- `dispute`
- payment / billing / settlement / tax
- implementation unlock

### 11.4 Stage Conclusion

- `Go for refreshed backend truth / persistence freeze authoring`
- `No-Go for Phase 0 implementation exception unlock`
- `No-Go for implementation dispatch send`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`

## 12. Next Unique Action

- 下一轮唯一动作：
  - 输出《订单承接与履约承接主链 refreshed backend truth / persistence freeze》
