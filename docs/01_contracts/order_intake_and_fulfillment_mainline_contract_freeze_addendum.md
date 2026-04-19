---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the current L2 contract family for the order-intake and fulfillment
  mainline object, limited to the bounded continuation chain after active order
  and milestone anchors already exist.
layer: L2 Contracts
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/post_project_showcase_filter_and_project_create_form_refactor_next_bounded_object_ruling_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_asset_inventory_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/01_contracts/contract_archive_and_mandatory_fulfillment_chain_rules_v1_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《订单承接与履约承接主链 contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `订单承接与履约承接主链`
- 本冻结单只服务于：
  - 当前对象 app-facing / server-facing contract family
  - 当前对象 read-model 最小字段边界
  - 当前对象 submit handoff request / response 最小边界
  - 当前对象错误语义与 unavailable 语义
- 本冻结单不进入：
  - persistence / migration
  - backend / BFF / Flutter 实现
  - integration
  - release-prep
  - production release

## 2. Contract Freeze Conclusion

- 本轮 contract freeze 不是 `no-op`。
- 本轮只冻结当前对象纳入范围内的最小 contract 变化。
- 本轮不允许把以下排除项一并写进 contract 作用域：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/*`
  - `dispute/*`
- 本轮 contract 的正式意义是：
  - 把 continuation 主链收紧到
    `activeOrderId / activeMilestoneId` 已存在后的最小 read + submit handoff
  - 而不是重开完整交易写骨架

## 3. Canonical Path Family Freeze

### 3.1 App-facing Path Family

- 当前 contract family 只冻结以下 app-facing path：
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `GET /api/app/milestone/list`
  - `POST /api/app/milestone/submit`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`

### 3.2 Server-facing Minimal Corresponding Family

- 当前允许冻结的最小 server-facing 对应 family 为：
  - `GET /server/order/detail`
  - `GET /server/contract/detail`
  - `GET /server/milestone/list`
  - `POST /server/milestones/{milestoneId}/submit`
  - `GET /server/inspection/detail`
- 这里的正式含义是：
  - 若后续进入 backend truth / persistence freeze，
    只能围绕上述最小对应 family author
  - 不得发明与现有命名体系冲突的新 path
  - `inspection/submit` 的 server-facing 对应 path
    在本轮不单独冻结为新的 concrete path；
    若后续确需 author，必须先与既有 `Server` resource-style naming
    对齐，不得回写成 `POST /server/inspection/submit`

### 3.3 Explicitly Excluded Path Family

- 当前必须明确禁止把以下 path 纳入本轮：
  - `POST /api/app/order/create`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `POST /api/app/inspection/recheck`
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/open`
  - `POST /api/app/dispute/withdraw`

## 4. `order/detail` Contract Freeze

- `GET /api/app/order/detail` 当前正式冻结为：
  - 当前对象的订单只读主 carrier
- `orderId` 当前正式定义为：
  - continuation anchor
  - 不是 Flutter/BFF 本地状态机输入

### 4.1 Minimum Response Semantics

- 最小响应语义至少包括：
  - `orderId`
  - `orderNo`
  - `projectId`
  - `bidId`
  - `state`
  - `summary`
  - 可继续 handoff 的最小 order-bound context

### 4.2 Hard Boundary

- 当前不得把 `order/detail` 扩成：
  - `order/create` write contract
  - dispute detail / history contract
  - rating detail / history contract

## 5. `contract/detail` Contract Freeze

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

## 6. `milestone/list` Contract Freeze

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

## 7. `milestone/submit` Contract Freeze

- `POST /api/app/milestone/submit` 当前正式冻结为：
  - 当前对象里允许纳入的第一个 write-handoff contract

### 7.1 Minimum Request

- 最小 request 至少包括：
  - `milestoneId`
  - `submissionNote`
- 如涉及文件补充：
  - 只能继续复用既有三段式 upload truth
  - 不得把上传 schema 混进 milestone business truth

### 7.2 Minimum Accepted Response

- 最小 accepted response 至少包括：
  - `milestoneId`
  - `state`
  - `summary`

### 7.3 Hard Boundary

- 当前只冻结最小 submit contract。
- 当前不得扩到：
  - completion 推导
  - inspection close-loop

## 8. `inspection/detail` Contract Freeze

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

## 9. `inspection/submit` Contract Freeze

- `POST /api/app/inspection/submit` 当前正式冻结为：
  - 当前对象里允许纳入的第二个 write-handoff contract

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

## 10. Error / Unavailable / Non-goals / Stage Conclusion

### 10.1 Controlled Error And Unavailable Boundary

- 当前对象允许出现：
  - controlled unavailable
  - invalid-state
  - missing-anchor-style continuation failure
- 这些错误必须继续由 `Server` truth 决定。
- `BFF` 只允许做：
  - envelope
  - shaping
  - controlled failure normalization

### 10.2 Compatibility And Reuse Boundary

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
- upload 复用边界：
  - `milestone/submit` 如涉及补充凭证，
    继续复用既有：
    - `POST /api/app/file/upload/init`
    - direct upload
    - `POST /api/app/file/upload/confirm`
  - 但 upload truth 不得反客为主，变成当前对象业务主 contract

### 10.3 Explicit Non-goals

- `order/create`
- `contract/confirm`
- `contract/amend`
- `inspection/recheck`
- `rating`
- `dispute`
- payment / billing / settlement / tax

### 10.4 Stage Conclusion

- `Go for backend truth / persistence freeze authoring`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`
