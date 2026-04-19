---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimal BFF aggregation, app-facing handoff, envelope shaping, and
  continuation-anchor surface for the order-intake and fulfillment mainline
  object only.
layer: L4 BFF
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/post_project_showcase_filter_and_project_create_form_refactor_next_bounded_object_ruling_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_asset_inventory_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/order_intake_and_fulfillment_mainline_contract_freeze_addendum.md
  - docs/02_backend/order_intake_and_fulfillment_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/bff_ssot.md
  - docs/03_bff/bff_routes.md
  - docs/03_bff/contract_archive_and_mandatory_fulfillment_chain_rules_v1_bff_surface_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《订单承接与履约承接主链 BFF surface freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `订单承接与履约承接主链`
- 本冻结单只服务于：
  - 当前对象 app-facing surface
  - 当前对象最小 query / command handoff
  - 当前对象 read-model projection 最小边界
  - 当前对象 envelope / shaping / controlled failure normalization
  - 当前对象 continuation anchor 透出边界
- 本冻结单不进入：
  - 新 path family
  - `apps/bff/**` 实现
  - frontend 文书
  - integration
  - release-prep
  - production release

## 2. BFF Freeze Conclusion

- 本轮不是 `no-op`。
- 本轮只冻结当前对象纳入范围内的最小 BFF surface。
- 当前不允许借 BFF 文书把排除项偷偷并入。
- 当前不是：
  - 重开完整交易写骨架
  - 重开 `contract/confirm`
  - 重开 `contract/amend`
  - 重开 `inspection/recheck`
  - 重开 `rating`
  - 重开 `dispute`

## 3. BFF Truth Boundary

- `BFF` 当前只允许做：
  - app-facing transport
  - query / command handoff
  - envelope / shaping
  - controlled unavailable / invalid-state / missing-anchor normalization
  - continuation anchor projection
  - upload-related app-facing reuse boundary
- `BFF` 当前不得做：
  - truth owner
  - 第二状态机
  - 本地 `pass / complete / archive-ready` 推导
  - 本地 `rating / dispute eligibility` 推导
  - 本地 inspection `pass` 判定

### 3.1 Summary Boundary

- `workbench` / `my-project` 不是当前对象的 BFF contract family owner。
- `BFF` 不能把 summary 容器写成实例真值 surface。
- `BFF` 不得把 `order_chain / fulfillment_chain / privateSummary / privateProgress`
  反写为：
  - 订单实例真相
  - 合同实例真相
  - 履约实例真相
  - 验收实例真相

## 4. App-facing Path Family Freeze

- 当前 BFF surface 只冻结以下 app-facing path：
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `GET /api/app/milestone/list`
  - `POST /api/app/milestone/submit`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`

### 4.1 Explicitly Excluded Path Family

- 当前必须明确禁止把以下 path 纳入本轮：
  - `POST /api/app/order/create`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `POST /api/app/inspection/recheck`
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/open`
  - `POST /api/app/dispute/withdraw`

### 4.2 No New Path Rule

- 当前不得擅自发明新的 app-facing path。
- 当前不得擅自发明新的 server-facing path。
- 尤其不得把 `inspection/submit` 发明成新的 concrete server path。

## 5. `order/detail` BFF Surface Freeze

- `GET /api/app/order/detail` 当前正式冻结为：
  - 当前对象中的订单只读 app-facing carrier
- `BFF` 只可投影最小字段并透出 continuation anchor。

### 5.1 Minimum App-facing Projection

- 最小 app-facing projection 至少包括：
  - `orderId`
  - `orderNo`
  - `projectId`
  - `bidId`
  - `state`
  - `summary`
  - 最小 order-bound continuation context

### 5.2 Hard Boundary

- 当前不得扩成：
  - `order create` surface
  - dispute detail / history surface
  - rating detail / history surface
- 当前不得把 workbench summary 反写成 order detail 真相。

## 6. `contract/detail` BFF Surface Freeze

- `GET /api/app/contract/detail` 当前正式冻结为：
  - 当前对象中的合同只读 app-facing carrier
- `BFF` 只做最小字段投影。

### 6.1 Minimum Projection

- 最小 projection 至少包括：
  - `contractId`
  - `orderId`
  - `state`
  - `summary`

### 6.2 Read Sidecar Boundary

- 如提及条款信息，只能写成：
  - 只读 sidecar projection

### 6.3 Hard Boundary

- 当前不得扩：
  - `contract/confirm`
  - `contract/amend`
  - 合同历史
  - 条款编辑器
  - 法务审核环

## 7. `milestone/list` BFF Surface Freeze

- `GET /api/app/milestone/list` 当前正式冻结为：
  - 当前对象中的履约节点只读 app-facing carrier
- `BFF` 只允许最小列表投影。

### 7.1 Minimum Projection

- 最小 projection 至少包括：
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

## 8. `milestone/submit` BFF Surface Freeze

- `POST /api/app/milestone/submit` 当前正式冻结为：
  - 当前对象允许纳入的第一个 command handoff surface
- `BFF` 只做：
  - command forward
  - envelope shaping

### 8.1 Minimum Request Handoff

- 最小 request handoff 至少包括：
  - `milestoneId`
  - `submissionNote`

### 8.2 Minimum Accepted Response

- 最小 accepted response 至少包括：
  - `milestoneId`
  - `state`
  - `summary`

### 8.3 Upload Reuse Boundary

- 如提及补充凭证，必须写清：
  - 只能承接既有 upload 三段式后得到的 confirmed file asset 引用
  - 不得把 upload schema 混进 milestone business truth
  - 不得透传 `objectKey`
  - 不得透传 raw URL

### 8.4 Hard Boundary

- 当前不得在本地实现 milestone 完整提交条件计算。
- 当前不得在本地推导：
  - `milestone.completed`
  - `order.completed`

## 9. `inspection/detail` BFF Surface Freeze

- `GET /api/app/inspection/detail` 当前正式冻结为：
  - 当前对象中的验收只读 app-facing carrier
- `BFF` 只做最小字段投影。

### 9.1 Minimum Projection

- 最小 projection 至少包括：
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
  - 把 route presence 写成验收闭环完成

## 10. `inspection/submit` BFF Surface Freeze

- `POST /api/app/inspection/submit` 当前正式冻结为：
  - 当前对象允许纳入的第二个 command handoff surface
- `BFF` 只做：
  - command forward
  - envelope shaping

### 10.1 Minimum Request Handoff

- 最小 request handoff 至少包括：
  - `inspectionId`

### 10.2 Minimum Accepted Response

- 最小 accepted response 至少包括：
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`

### 10.3 Hard Boundary

- 当前对象不纳入：
  - `inspection/recheck`
- 当前对象不纳入：
  - `passed / archived` 最终闭环
- 当前不允许 BFF 本地判定验收通过。
- 当前不得擅自发明 concrete server-facing submit path。
- 尤其不得写成：
  - `POST /server/inspection/submit`

## 11. Error / Envelope / Continuation Boundary

- `BFF` 只允许做：
  - unified envelope
  - shaping
  - controlled failure normalization
  - continuation anchor projection

### 11.1 Allowed Error Semantics

- 错误语义只允许围绕：
  - controlled unavailable
  - invalid-state
  - missing-anchor-style continuation failure
- 这些错误根源继续由 `Server` truth 决定。

### 11.2 Error Prohibitions

- `BFF` 不得新增本地业务错误命名空间。
- `BFF` 不得吞掉 `Server` 核心失败语义。
- `BFF` 不得把“没有 active route / 没有 active truth module”包装成已完成。

## 12. Compatibility / Reuse / Non-goals / Stage Conclusion

### 12.1 Workbench Reuse Boundary

- `activeOrderId`
- `activeMilestoneId`
  只承担 continuation carrier
- 不承担对象真值
- 不承担列表 / 详情 owner

### 12.2 My-project Reuse Boundary

- `privateSummary / privateProgress` 只继续复用项目级摘要
- 不能被写成当前对象的 BFF contract family owner

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

- 不得把 `BFF` 写成 truth owner。
- 不得拥有：
  - `Order / Contract / Milestone / Inspection` 业务真相
  - `archive-ready / pass / complete / downstream eligibility` 真相
- 不得把排除项借“邻接 continuation”带回来。
- 不得顺带冻结：
  - `rating/*`
  - `dispute/*`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`

### 12.6 Stage Conclusion

- `Go for frontend consumption freeze authoring`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`
