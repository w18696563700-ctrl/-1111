---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the backend truth ownership, canonical persistence carriers,
  read-vs-submit binding, derived-vs-canonical split, and minimum audit/evidence
  boundary for the order-intake and fulfillment mainline object only.
layer: L3 Backend
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/post_project_showcase_filter_and_project_create_form_refactor_next_bounded_object_ruling_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_asset_inventory_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_contract_freeze_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/02_backend/project_transaction_skeleton_p0_backend_truth_addendum.md
  - docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - docs/02_backend/db_schema.md
  - docs/02_backend/audit_log_spec.md
  - docs/01_contracts/openapi.yaml
---

# 《订单承接与履约承接主链 backend truth / persistence freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `订单承接与履约承接主链`
- 本冻结单只服务于：
  - 当前对象最小 `Server` truth ownership
  - 当前对象 canonical persistence carriers
  - 当前对象 read-carrier 与 submit-handoff 的 backend truth 绑定
  - 当前对象 derived vs canonical split
  - 当前对象 controlled unavailable / invalid-state / missing-anchor 的 `Server` 决策边界
  - 当前对象最小 audit / evidence linkage 边界
- 本冻结单不进入：
  - `apps/server/**` 实现
  - migration authoring
  - BFF / Flutter 文书
  - integration
  - release-prep
  - production release

## 2. Backend Freeze Conclusion

- 本轮不是 `no-op`。
- 本轮只冻结当前对象纳入范围内的最小 backend truth / persistence 变化。
- 当前不允许借 backend 文书把排除项偷偷并入。
- 本轮不是：
  - 重开完整交易骨架
  - 重开 `contract/archive/recheck/rating/dispute`
  - 重开 payment / billing / settlement / tax

## 3. Unique Truth Owner Freeze

- `Server` 是当前对象唯一 truth owner。
- `BFF` 不是 truth owner。
- `Flutter` 不是 truth owner。
- `workbench` 不是 truth owner。
- `my-project` 不是 truth owner。

### 3.1 Reuse Boundary

- `workbench` 与 `my-project` 只允许承载：
  - continuation carrier
  - private summary derived projection
- 它们不得成为：
  - 订单实例真值来源
  - 合同实例真值来源
  - 履约实例真值来源
  - 验收实例真值来源

## 4. Canonical Persistence Carrier Freeze

- 当前对象只允许冻结以下最小 canonical persistence family：
  - `orders`
  - `contracts`
  - `milestones`
  - `inspections`
  - `evidences`
  - `file_assets`
  - `audit_logs`

### 4.1 Conditional Sidecar

- 只有在 detail read 明确依赖时，才允许谨慎提及：
  - `contract_clauses`
- 在当前对象里，`contract_clauses` 只能作为：
  - `contract/detail` 的 read sidecar
- 不得扩写成：
  - 合同历史系统
  - 版本系统
  - 法务审核系统

### 4.2 Explicitly Excluded Persistence Family

- 当前不得把以下对象带入本轮 canonical persistence family：
  - `change_orders`
  - `ratings`
  - `disputes`
  - `contract_versions`
  - `contract_confirmations`
  - `milestone_projection_cache`
  - `inspection_console_state`
  - `rectification_items`
  - 任何 list-only / detail-only shadow aggregate
  - 任何 BFF / Flutter local snapshot table

## 5. Read Object Truth Freeze

- `order/detail` 只读主 carrier 对应 `Order` truth。
- `contract/detail` 只读主 carrier 对应 `Contract` truth。
- `milestone/list` 只读主 carrier 对应 `Milestone` truth。
- `inspection/detail` 只读主 carrier 对应 `Inspection` truth。

### 5.1 Read-path Boundary

- 这些 read paths 只是 canonical truth 的只读回显。
- 它们不是：
  - 写命令来源
  - 第二状态机
  - runtime 已闭环证明

## 6. `order/detail` Backend Truth Freeze

- `Order` 当前在本对象里只承担 continuation read truth。
- `orderId` 是 continuation anchor。

### 6.1 Minimum Truth Semantics

- `orders` 是唯一 order instance carrier。
- `order.state` 仍由 `Server` 独占。
- `orderNo / projectId / bidId / summary` 只可由 canonical order truth 派生或聚合。

### 6.2 Hard Boundary

- 当前明确禁止：
  - 把 `order/detail` 扩成 `order/create`
  - 把 dispute / rating 状态塞回 `Order` 当前对象范围内

## 7. `contract/detail` Backend Truth Freeze

- `Contract` 当前在本对象里只承担 continuation read truth。
- 当前不纳入：
  - `contract/confirm`
  - `contract/amend`

### 7.1 Minimum Truth Semantics

- `contracts` 是唯一 contract instance carrier。
- `contract.state` 仍由 `Server` 独占。
- 如需 detail read 侧附带条款信息，只允许：
  - `contracts + contract_clauses`
  的只读绑定。

### 7.2 Hard Boundary

- 当前明确禁止：
  - `contract_versions`
  - `contract_confirmations`
  - 条款编辑器
  - 法务审核环

## 8. `milestone/list` + `milestone/submit` Backend Truth Freeze

- `milestones` 是当前对象中唯一履约节点 truth carrier。
- `milestone/list` 只读。
- `milestone/submit` 是当前对象允许纳入的第一个 write-handoff truth。

### 8.1 Minimum Truth Semantics

- 最小 truth 语义至少包括：
  - `milestoneId`
  - `orderId`
  - `sequenceNo`
  - `title`
  - `amount`
  - `state`
  - `summary`

### 8.2 Evidence Reuse Boundary

- 如涉及文件补充，必须继续复用：
  - `Evidence -> FileAsset`
  - `init -> direct upload -> confirm`
- `objectKey` 不是业务真值。

### 8.3 Hard Boundary

- 当前明确禁止：
  - `milestone_projection_cache`
  - `daily_progress_logs`
  - milestone history center
  - approval console
  - 第二履约状态机
  - 本地推导 milestone completed

## 9. `inspection/detail` + `inspection/submit` Backend Truth Freeze

- `inspections` 是当前对象中唯一验收侧 truth carrier。
- `inspection/detail` 只读。
- `inspection/submit` 是当前对象允许纳入的第二个 write-handoff truth。

### 9.1 Minimum Truth Semantics

- 最小 truth 语义至少包括：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`
  - `rectificationCount`
  - `recheckCount`

### 9.2 Submit Boundary

- 当前对象不纳入：
  - `inspection/recheck`
- 当前对象不纳入：
  - `passed / archived` 最终闭环
- 当前对象不允许：
  - BFF / Flutter 本地判定验收通过
- 对于 server-facing submit 绑定，
  当前只能写成：
  - inspection-bound minimal submit truth
- 当前不得擅自发明 concrete server-facing path。

### 9.3 Hard Boundary

- 当前明确禁止：
  - `inspection_console_state`
  - `rectification_items`
  - inspection history center
  - governance console
  - 任何“由 route presence 推导 pass/close”的口径

## 10. Derived vs Canonical Split Freeze

- `orders / contracts / milestones / inspections` 表记录是 canonical truth。
- `workbench order_chain / fulfillment_chain` 只是 derived summary / continuation carrier。
- `my-project privateSummary / privateProgress` 只是 derived projection。
- `summary.stateLabel` / UI wording 永远不是真值。

### 10.1 Override Prohibition

- 任何 private summary / workbench summary 都不能反向覆盖 `Server` canonical truth。

## 11. Audit / Error / Evidence Boundary

### 11.1 Audit Boundary

- `audit_logs` 是当前对象唯一业务审计 carrier。
- 当前对象最小必须留痕动作只允许讨论：
  - `MilestoneSubmitted`
  - `InspectionSubmitted`
- 当前不扩：
  - `OrderCreated`
  - `ContractConfirmed`
  - `ContractAmended`
  - `InspectionRecheckSubmitted`
  - `InspectionDecisionChanged`

### 11.2 Error Boundary

- 以下错误语义继续由 `Server` truth 决定：
  - controlled unavailable
  - invalid-state
  - missing-anchor-style continuation failure

### 11.3 Evidence Boundary

- evidence 语义只允许：
  - `evidences + file_assets`
- `objectKey` 不是业务真值。
- raw URL 不是业务真值。

## 12. Non-goals / Stage Conclusion

### 12.1 Non-goals

- `order/create`
- `contract/confirm`
- `contract/amend`
- `inspection/recheck`
- `rating`
- `dispute`
- payment / billing / settlement / tax
- migration authoring
- implementation unlock

### 12.2 Compatibility And Reuse Boundary

- workbench 复用边界：
  - `activeOrderId`
  - `activeMilestoneId`
  只承担 continuation carrier
  - 不承担对象真值
  - 不承担列表 / 详情 owner
- my-project 复用边界：
  - `privateSummary / privateProgress`
    只继续复用项目级摘要
  - 不能被写成当前对象的 persistence owner
  - 不能被写成当前对象的 truth owner
- upload 复用边界：
  - `milestone/submit` 如涉及补充凭证，继续复用既有：
    - `POST /api/app/file/upload/init`
    - direct upload
    - `POST /api/app/file/upload/confirm`
  - 但 upload truth 不得反客为主，变成当前对象业务主 contract 或 persistence family

### 12.3 Stage Conclusion

- `Go for BFF surface freeze authoring`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`
