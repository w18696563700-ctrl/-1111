---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimal Flutter consumption boundary, controlled state handling,
  and continuation handoff for the order-intake and fulfillment mainline
  object only.
layer: L5 Frontend
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/post_project_showcase_filter_and_project_create_form_refactor_next_bounded_object_ruling_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_asset_inventory_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_contract_freeze_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/order_intake_and_fulfillment_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《订单承接与履约承接主链 frontend consumption freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `订单承接与履约承接主链`
- 本冻结单只服务于：
  - 当前对象 Flutter 页面消费边界
  - 当前对象 `loading / content / empty / blocker / failure` 状态边界
  - 当前对象 read-page 最小字段消费
  - 当前对象 submit-page 最小交互与受控反馈
  - 当前对象 continuation handoff 边界
- 本冻结单不进入：
  - `apps/mobile/**` 实现
  - 新路由族
  - 新页面 IA 重构
  - integration
  - release-prep
  - production release

## 2. Frontend Freeze Conclusion

- 本轮不是 `no-op`。
- 本轮只冻结当前对象纳入范围内的最小 Flutter consumption boundary。
- 当前不允许借 frontend 文书把排除项偷偷并入。
- 当前不是：
  - 重开完整交易写骨架
  - 重开 `contract/confirm`
  - 重开 `contract/amend`
  - 重开 `inspection/recheck`
  - 重开 `rating`
  - 重开 `dispute`

## 3. Frontend Truth Boundary

- Flutter 只允许做：
  - consume app-facing projection
  - controlled `loading / empty / blocker / failure`
  - controlled submit feedback
  - continuation route handoff
- Flutter 不得做：
  - truth owner
  - 第二状态机
  - 本地 `pass / complete / archive-ready` 推导
  - 本地 `rating / dispute eligibility` 推导
  - 本地 inspection `pass` 判定

### 3.1 Runtime-evidence Prohibition

- page shell / route shell / placeholder 不等于 runtime 已接通。
- demo fallback / controlled placeholder 不能被写成主链已通证据。
- route 存在不等于 `BFF / Server` active source 已通。

## 4. Route / Page Carrier Freeze

- 当前 frontend 只冻结以下最小 route/page carrier：
  - `/exhibition/orders/detail`
  - `/exhibition/contracts/detail`
  - `/exhibition/milestones`
  - `/exhibition/milestones/submit`
  - `/exhibition/inspections/detail`
  - `/exhibition/inspections/submit`

### 4.1 Explicitly Excluded Route/Page

- 当前必须明确禁止把以下 route/page 纳入本轮：
  - `/exhibition/contracts/confirm`
  - `/exhibition/contracts/amend`
  - `/exhibition/inspections/recheck`
  - `/exhibition/ratings/entry`
  - `/exhibition/ratings/submit`
  - `/exhibition/disputes/open`
  - `/exhibition/disputes/withdraw`

### 4.2 Reuse-only Pages

- `/exhibition/workbench` 只做 continuation handoff。
- `my/projects` / `my/projects/{projectId}` 只做项目级私域摘要复用。
- 两者都不是详情 truth carrier。

## 5. `order/detail` Frontend Consumption Freeze

- `/exhibition/orders/detail` 当前正式冻结为：
  - 当前对象中的订单只读消费页
- 页面只消费最小 app-facing projection。
- `orderId` 只作为 controlled continuation context。

### 5.1 Minimum Consumption Fields

- 最小消费字段至少包括：
  - `orderId`
  - `orderNo`
  - `projectId`
  - `bidId`
  - `state`
  - `summary`
  - 最小 order-bound continuation context

### 5.2 Hard Boundary

- 当前不得扩：
  - acceptance workflow
  - dispute detail / history
  - rating detail / history
- 当前不得把 workbench summary 写成 order detail 真相。

## 6. `contract/detail` Frontend Consumption Freeze

- `/exhibition/contracts/detail` 当前正式冻结为：
  - 当前对象中的合同只读消费页
- 页面只消费最小 app-facing projection。

### 6.1 Minimum Consumption Fields

- 最小消费字段至少包括：
  - `contractId`
  - `orderId`
  - `state`
  - `summary`

### 6.2 Read Sidecar Boundary

- 如提及条款信息，只能写成：
  - 只读 sidecar consumption

### 6.3 Hard Boundary

- 当前不得扩：
  - `contract/confirm`
  - `contract/amend`
  - 合同历史
  - 条款编辑器
  - 法务审核环

## 7. `milestone/list` Frontend Consumption Freeze

- `/exhibition/milestones` 当前正式冻结为：
  - 当前对象中的履约节点只读消费页
- 页面必须区分：
  - real content-state
  - real empty-state
  - blocker / failure state

### 7.1 Minimum Consumption Fields

- 最小消费字段至少包括：
  - `items[]`
  - `milestoneId`
  - `orderId`
  - `sequenceNo`
  - `title`
  - `amount`
  - `state`
  - `summary`

### 7.2 Hard Boundary

- 当前不得扩：
  - milestone history
  - approval console
  - 第二履约状态机
  - 本地 `milestone.completed` 推导

## 8. `milestone/submit` Frontend Consumption Freeze

- `/exhibition/milestones/submit` 当前正式冻结为：
  - 当前对象允许纳入的第一个 command consumption page
- 页面只承接最小 submit 交互与受控反馈。

### 8.1 Minimum Request Consumption

- 最小 request 消费至少包括：
  - `milestoneId`
  - `submissionNote`

### 8.2 Minimum Success / Accepted Feedback

- 最小 success / accepted feedback 至少包括：
  - `milestoneId`
  - `state`
  - `summary`

### 8.3 Upload Reuse Boundary

- 如提及补充凭证，必须写清：
  - 继续复用 upload 三段式
  - 只消费 confirmed file asset handoff
  - 不消费 `objectKey`
  - 不消费 raw URL 作为业务真值

### 8.4 Hard Boundary

- 当前不得在前端本地实现 milestone 完整提交条件计算。
- 当前不得在前端本地推导：
  - `milestone.completed`
  - `order.completed`

## 9. `inspection/detail` Frontend Consumption Freeze

- `/exhibition/inspections/detail` 当前正式冻结为：
  - 当前对象中的验收只读消费页
- 页面只消费最小 app-facing projection。

### 9.1 Minimum Consumption Fields

- 最小消费字段至少包括：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`
  - `rectificationCount`
  - `recheckCount`

### 9.2 Hard Boundary

- 当前不得扩：
  - inspection history
  - governance console
  - 不把 route presence 写成验收闭环完成

## 10. `inspection/submit` Frontend Consumption Freeze

- `/exhibition/inspections/submit` 当前正式冻结为：
  - 当前对象允许纳入的第二个 command consumption page
- 页面只承接最小 submit 交互与受控反馈。

### 10.1 Minimum Request Consumption

- 最小 request 消费至少包括：
  - `inspectionId`

### 10.2 Minimum Success / Accepted Feedback

- 最小 success / accepted feedback 至少包括：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`

### 10.3 Hard Boundary

- 当前对象不纳入：
  - `inspection/recheck`
- 当前对象不纳入：
  - `passed / archived` 最终闭环
- 当前不允许 Flutter 本地判定验收通过。
- 当前不得把 route shell 写成验收链已通。
- 当前不得把 `inspection/submit` 成功包装成全链闭环完成。

## 11. State / Failure / Controlled Feedback Boundary

- Flutter 页面允许出现：
  - `loading`
  - `content`
  - `empty`
  - `blocker`
  - `failure`
  - `controlled unavailable`
  - `invalid-state`
  - `missing-anchor-style continuation failure`
- 这些状态必须基于 app-facing surface 消费，
  不得本地伪造业务完成。

### 11.1 Hard Boundary

- 不得把 `empty-state` 伪装成“已接通成功”。
- 不得把 page shell / placeholder 写成已完成。
- 不得把没有 active route / 没有 active truth module 包装成 happy-path `pass`。

## 12. Compatibility / Reuse / Non-goals / Stage Conclusion

### 12.1 Workbench Reuse Boundary

- `activeOrderId`
- `activeMilestoneId`
  只承担 continuation carrier
- 不承担对象真值
- 不承担列表 / 详情 owner

### 12.2 My-project Reuse Boundary

- `privateSummary / privateProgress` 只继续复用项目级摘要
- 不能被写成当前对象详情页 owner
- 不能被写成当前对象 truth owner

### 12.3 Upload Reuse Boundary

- `POST /api/app/file/upload/init`
- direct upload
- `POST /api/app/file/upload/confirm`
  继续复用
- 但 upload truth 不得反客为主

### 12.4 Explicit Non-goals

- `order/create`
- `contract/confirm`
- `contract/amend`
- `inspection/recheck`
- `rating`
- `dispute`
- payment / billing / settlement / tax
- implementation unlock

### 12.5 Extra Prohibitions

- 不得把 Flutter 页面壳写成 runtime 已通。
- route 存在不等于 `BFF / Server` active source 已通。
- page shell 存在不等于主链已闭环。
- controlled placeholder 不等于真实完成。
- `workbench` 不是 `order/detail` owner。
- `workbench` 不是 `milestone/list` owner。
- `my-project` 不是 `contract/detail` owner。
- `my-project` 不是 `inspection/detail` owner。
- 不得把排除项借“邻接 route”带回来。
- 不得顺带冻结：
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/*`
  - `dispute/*`

### 12.6 Stage Conclusion

- `Go for docs-only freeze review conclusion authoring`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`
