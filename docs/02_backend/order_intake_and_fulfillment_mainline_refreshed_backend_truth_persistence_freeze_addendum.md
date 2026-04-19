---
owner: Codex 总控
status: active
purpose: >
  Freeze the refreshed backend truth ownership, canonical persistence carriers,
  read-vs-submit binding, derived-vs-canonical split, and minimum
  audit/evidence boundary for `订单承接与履约承接主链` after the post-cleanup
  contract refresh.
layer: L3 Backend
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_refreshed_truth_boundary_freeze_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_fresh_asset_inventory_refresh_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_refreshed_contract_freeze_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/02_backend/project_transaction_skeleton_p0_backend_truth_addendum.md
  - docs/02_backend/contract_archive_and_mandatory_fulfillment_chain_rules_v1_backend_truth_addendum.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - docs/02_backend/db_schema.md
  - docs/02_backend/audit_log_spec.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.query.service.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.presenter.ts
  - apps/server/src/modules/trading_shell_handoff/trading-shell-handoff.service.ts
  - apps/server/src/modules/trading_shell_handoff/trading-shell-handoff.presenter.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
  - apps/server/src/modules/my_project/my-project.private-progress.ts
---

# 《订单承接与履约承接主链 refreshed backend truth / persistence freeze》

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
  - `apps/server/**` 实现扩写
  - migration authoring
  - BFF / Flutter 文书
  - integration
  - release-prep
  - production release

## 2. Refreshed Backend Freeze Conclusion

- 本轮 refreshed backend freeze 不是 `no-op`。
- 本轮只冻结当前对象纳入范围内的最小 backend truth / persistence 变化。
- 与旧版
  [order_intake_and_fulfillment_mainline_backend_truth_persistence_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/order_intake_and_fulfillment_mainline_backend_truth_persistence_freeze_addendum.md)
  相比，当前必须收正 4 件事：
  1. `Server` 当前 active source 已具备两组 module family：
     - `trading_read_corridor`
     - `trading_shell_handoff`
  2. `milestone/submit / inspection/submit`
     当前是 concrete shell / handoff runtime，
     但仍然不是“已持久化推进完成”的 truth 口径。
  3. `dispute/open`
     当前已在 `Server` 中存在相邻 shell / handoff runtime，
     但仍然不是本对象 included truth family。
  4. `my-project`
     当前只允许继续复用
     `orders / contracts / milestones`
     的 in-scope derived truth，
     不再混入 `ratings / disputes`。
- 本轮仍然不允许借 backend 文书把以下对象偷偷并入：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/*`
  - `dispute/*`
  - payment / billing / settlement / tax

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
  - 争议实例真值来源

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
  - `daily_progress_logs`
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

## 6. `order/detail` Refreshed Backend Truth Freeze

- `Order` 当前在本对象里只承担 continuation read truth。
- `orderId` 是 continuation anchor。

### 6.1 Minimum Truth Semantics

- `orders` 是唯一 order instance carrier。
- `order.state` 仍由 `Server` 独占。
- `orderNo / projectId / bidId / summary`
  只可由 canonical order truth 派生或聚合。
- 当前 `TradingReadCorridorPresenter`
  可把 `order.state` 投影成最小 consumer state，
  但该投影不是第二状态机。

### 6.2 Hard Boundary

- 当前明确禁止：
  - 把 `order/detail` 扩成 `order/create`
  - 把 dispute / rating 状态塞回 `Order`
    当前对象范围内

## 7. `contract/detail` Refreshed Backend Truth Freeze

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

## 8. `milestone/list` + `milestone/submit` Refreshed Backend Truth Freeze

- `milestones` 是当前对象中唯一履约节点 truth carrier。
- `milestone/list` 只读。
- `milestone/submit` 是当前对象允许纳入的第一个 submit handoff truth。

### 8.1 Minimum Truth Semantics

- 最小 truth 语义至少包括：
  - `milestoneId`
  - `orderId`
  - `sequenceNo`
  - `title`
  - `amount`
  - `state`
  - `summary`
- 当前必须补充写死：
  - `trading_shell_handoff.submitMilestone`
    只校验 canonical milestone / order truth 是否允许继续 handoff
  - accepted body 只回：
    - `milestoneId`
  - 这不等于 `milestone.state`
    已因当前 path 完成持久化推进

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
  - 本地推导 `milestone completed`

## 9. `inspection/detail` + `inspection/submit` Refreshed Backend Truth Freeze

- `inspections` 是当前对象中唯一验收侧 truth carrier。
- `inspection/detail` 只读。
- `inspection/submit` 是当前对象允许纳入的第二个 submit handoff truth。

### 9.1 Minimum Truth Semantics

- 最小 truth 语义至少包括：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`
  - `rectificationCount`
  - `recheckCount`
- 当前必须补充写死：
  - `trading_shell_handoff.submitInspection`
    只校验 canonical inspection / order truth 是否允许继续 handoff
  - accepted body 当前只承载：
    - `inspectionId`
    - `milestoneId`
    - `state`
    - `summary`
  - 这不等于 inspection truth 已在当前 path 内持久化推进完成

### 9.2 Submit Boundary

- 当前对象不纳入：
  - `inspection/recheck`
- 当前对象不纳入：
  - `passed / archived` 最终闭环
- 当前对象不允许：
  - BFF / Flutter 本地判定验收通过
- 对于 server-facing submit 绑定，
  当前只允许写成：
  - inspection-bound minimal submit-handoff truth

### 9.3 Hard Boundary

- 当前明确禁止：
  - `inspection_console_state`
  - `rectification_items`
  - inspection history center
  - governance console
  - 任何“由 route presence 推导 pass/close”的口径

## 10. Adjacent `dispute/open` Backend Boundary Note

- `Server` 当前已存在：
  - `POST /server/dispute/open`
    的相邻 shell / handoff runtime
- 当前最小 backend truth 语义仅限：
  - 以 canonical `Order` truth
    校验当前 order 是否允许进入 dispute-open handoff
  - 返回 `orderId + state + summary`
    的 accepted shell body
- 但当前必须明确：
  - 这是邻接边界记录
  - 不是把 `disputes`
    纳入当前对象 canonical persistence family
  - 不是把 `dispute/open`
    升格成当前对象 included backend truth

## 11. Derived vs Canonical Split Freeze

- `orders / contracts / milestones / inspections`
  表记录是 canonical truth。
- `workbench order_chain / fulfillment_chain`
  只是 derived summary / continuation carrier。
- `my-project privateSummary / privateProgress`
  只是 derived projection。
- `summary.stateLabel` / UI wording
  永远不是真值。

### 11.1 Refreshed Reuse Rule

- `exhibition_workbench`
  当前允许继续从：
  - `orders`
  - `contracts`
  - `milestones`
  - `inspections`
    派生最小 continuation carrier
- `my-project`
  当前允许继续从：
  - `orders`
  - `contracts`
  - `milestones`
    派生项目级 private progress
- `my-project`
  当前不得再从：
  - `ratings`
  - `disputes`
    派生当前对象 truth 输入

### 11.2 Override Prohibition

- 任何 private summary / workbench summary
  都不能反向覆盖 `Server` canonical truth。

## 12. Audit / Error / Evidence Boundary

### 12.1 Audit Boundary

- `audit_logs` 是当前对象唯一业务审计 carrier。
- 当前对象最小必须留痕动作只允许讨论：
  - `MilestoneSubmitted`
  - `InspectionSubmitted`
- 当前不扩：
  - `OrderCreated`
  - `ContractConfirmed`
  - `ContractAmended`
  - `InspectionRecheckSubmitted`
  - `DisputeOpened`
  - `InspectionDecisionChanged`

### 12.2 Error Boundary

- 以下错误语义继续由 `Server` truth 决定：
  - controlled unavailable
  - invalid-state
  - missing-anchor-style continuation failure

### 12.3 Evidence Boundary

- evidence 语义只允许：
  - `evidences + file_assets`
- `objectKey` 不是业务真值。
- raw URL 不是业务真值。

## 13. Non-goals / Stage Conclusion

### 13.1 Non-goals

- `order/create`
- `contract/confirm`
- `contract/amend`
- `inspection/recheck`
- `rating`
- `dispute`
- payment / billing / settlement / tax
- migration authoring
- implementation unlock

### 13.2 Compatibility And Reuse Boundary

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
  - 不再把 `ratings / disputes`
    写成当前对象 truth 输入
- upload 复用边界：
  - `milestone/submit`
    如涉及补充凭证，继续复用既有：
    - `POST /api/app/file/upload/init`
    - direct upload
    - `POST /api/app/file/upload/confirm`
  - 但 upload truth 不得反客为主，
    变成当前对象业务主 contract 或 persistence family

### 13.3 Stage Conclusion

- `Go for refreshed BFF surface freeze authoring`
- `No-Go for Phase 0 implementation exception unlock`
- `No-Go for implementation dispatch send`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`

## 14. Next Unique Action

- 下一轮唯一动作：
  - 输出《订单承接与履约承接主链 refreshed BFF surface freeze》
