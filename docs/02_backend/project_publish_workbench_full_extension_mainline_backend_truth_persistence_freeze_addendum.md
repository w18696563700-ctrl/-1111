---
owner: Codex 总控
status: frozen
purpose: Freeze the backend truth ownership, canonical persistence boundary, derived-vs-canonical split, and minimum upload/evidence/audit boundary for the corrected full publish-workbench and extension mainline only.
layer: L3 Backend
freeze_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_asset_inventory_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/three_board_real_chain_result_verification_rerun_addendum.md
  - docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stop_line_reentry_gate_path_addendum.md
  - docs/02_backend/db_schema.md
  - docs/02_backend/audit_log_spec.md
  - docs/01_contracts/openapi.yaml
  - docs/00_ssot/source_of_truth_map.md
---

# 《发布项目工作台及延伸功能全链 backend truth / persistence freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `发布项目工作台及延伸功能全链`
- 本冻结单只服务于：
  - 当前对象最小 `Server` truth ownership
  - 当前对象 canonical persistence boundary
  - 当前对象 verified runtime / read-corridor / shell-handoff / boundary-only 的 backend truth 区分
  - 当前对象 upload / evidence / audit 最小边界
  - 当前对象 controlled unavailable / invalid-state / frozen-boundary 的 `Server` 决策边界
- 本冻结单不进入：
  - migration authoring
  - `apps/server/**` 实现
  - BFF / frontend 文书
  - integration
  - `release-prep`
  - production release

## 2. Backend Freeze Conclusion

- 本轮不是 `no-op`。
- 本轮是 corrected full object 的正式 backend truth / persistence freeze。
- 当前对象继续固定为：
  - 四容器 + `15` 节点
  - mixed-maturity object
- 当前不允许再把：
  - `订单承接与履约承接主链`
    当成 full mainline backend object
- 当前不允许把：
  - shell 节点
  - boundary 节点
    偷写成 active command truth 已成立
- 当前不允许借 backend 文书把排除项偷偷并入。
- `订单承接与履约承接主链`
  当前只保留为：
  - subordinate screenshot-derived continuation subchain
  - subordinate stop-line asset

## 3. Unique Truth Owner Freeze

- `Server` 是当前对象唯一 truth owner。
- `BFF` 不是 truth owner。
- Flutter 不是 truth owner。
- `workbench` 不是 truth owner。
- `my-project` 不是 truth owner。

### 3.1 Derived Projection Boundary

- `workbench` 与 `my-project` 只允许承载：
  - summary
  - handoff
  - private carry derived projection
- 它们不得成为：
  - `project` 实例真值来源
  - `order` 实例真值来源
  - `contract` 实例真值来源
  - `milestone` 实例真值来源
  - `inspection` 实例真值来源

## 4. Canonical Persistence Boundary Freeze

- backend truth freeze 只允许冻结当前对象最小 canonical persistence family：
  - `projects`
  - `orders`
  - `contracts`
  - `milestones`
  - `inspections`
  - `evidences`
  - `file_assets`
  - `audit_logs`

### 4.1 Explicitly Excluded Persistence Family

- 当前不得发明或带入：
  - `ratings`
  - `disputes`
  - `contract_versions`
  - `contract_confirmations`
  - `inspection_console_state`
  - `milestone_projection_cache`
  - `project_reporting_cache`
  - `moderation_console_state`
  - 任何 BFF / Flutter local snapshot table

## 5. `project_chain` Backend Truth Freeze

- `project_chain` 是当前对象里最成熟的 continuation slice。
- `projects` 是当前对象 project instance 的唯一 canonical carrier。
- 以下路径对应的是当前对象里最成熟的一组 backend truth asset：
  - `GET /api/app/exhibition/workbench`
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `GET /api/app/project/list`
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`

### 5.1 Minimum Truth Semantics

- 最小 truth 语义至少包括：
  - `projectId`
  - `publicProject`
  - `privateProgress`
  - `recentProjectId`
  - `canCreateProject`

### 5.2 Projection And Reuse Boundary

- `GET /api/app/exhibition/workbench`
  只消费：
  - summary
  - handoff truth projection
- `project_publish_board` 复用关系继续有效：
  - `project/create`
  - upload 三段式
    继续复用既有 publish corridor
- 但当前 full object 不得偷换成：
  - “只有 publish corridor”
- `three-board mainline`
  的既有 verified chain 继续有效，但只对：
  - `project_chain`
  - publish corridor
  - `my-project` private carry
    构成有效背景
- 它不得被写成：
  - 后续 `order / fulfillment / extension`
    也已一并闭环

### 5.3 Hard Boundary

- `project_chain` 不是 public home truth owner。
- `project_chain` 不是第二项目状态机。
- `project_chain` 不是 `bid / award / order conversion` owner。

## 6. `order_chain` Backend Truth Freeze

- `order_chain` 当前是 subordinate continuation slice。
- `activeOrderId` 只是 continuation anchor。
- `orders` 与 `contracts` 是当前对象中 order-side 的最小 canonical truth family。
- 当前只允许冻结：
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `POST /api/app/dispute/open` 的 shell / handoff truth position

### 6.1 Truth Role

- `order/detail` 与 `contract/detail` 当前只代表：
  - read-corridor truth projection
- `dispute/open` 当前不得写成：
  - active command truth 已成立

### 6.2 Hard Boundary

- 当前明确不扩：
  - `POST /api/app/order/create`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/withdraw`

## 7. `fulfillment_chain` Backend Truth Freeze

- `fulfillment_chain` 当前也是 subordinate continuation slice。
- `activeMilestoneId` 只是 continuation anchor。
- `milestones` 与 `inspections` 是当前对象中 fulfillment-side 的最小 canonical truth family。
- 当前只允许冻结：
  - `GET /api/app/milestone/list`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/milestone/submit` 的 shell / handoff truth position
  - `POST /api/app/inspection/submit` 的 shell / handoff truth position

### 7.1 Truth Role

- `milestone/list` 与 `inspection/detail` 当前只代表：
  - read-corridor truth projection
- `milestone/submit` 与 `inspection/submit` 当前不得写成：
  - active command truth 已成立

### 7.2 Hard Boundary

- 当前明确不扩：
  - `POST /api/app/inspection/recheck`
  - approval / governance console
  - 第二履约状态机

## 8. `extension_boundary` Backend Truth Freeze

- `extension_boundary` 不是完整业务子链。
- 它只承接 boundary-state 与 limited continuation posture。
- 当前只允许写清：
  - 合同详情续接
  - 争议开启续接
  - `ratingEntryState`
  - `disputeWithdrawState`
- 当前必须明确：
  - `评价入口边界` 当前不是 open action
  - `争议撤回边界` 当前不是 open action
  - 不得把边界说明写成 live capability
  - 不得把它扩成 `rating / dispute` full backend truth family

## 9. Verified Runtime vs Read Corridor vs Shell vs Boundary Split

- 当前四类 backend truth 语义正式写死如下：
  1. verified development-stage runtime truth
     - `projects` 驱动的：
       - `workbench` summary / handoff projection
       - `project/create`
       - `project/detail`
       - `project/list`
       - `my-project` private carry
  2. active read-corridor truth projection
     - `orders`
     - `contracts`
     - `milestones`
     - `inspections`
       的只读回显
  3. shell / handoff truth position
     - `milestone/submit`
     - `inspection/submit`
     - `dispute/open`
       只保留为 shell / handoff truth position
  4. boundary-only / frozen-state truth marker
     - `ratingEntryState`
     - `disputeWithdrawState`
     - `评价入口边界`
     - `争议撤回边界`
- 当前必须明确：
  - route / page existence != runtime closure
  - summary presence != downstream truth closure
  - historical subchain docs != current full object closure
  - shell / handoff position != active command family already implemented

## 10. Upload / Evidence / Audit Boundary

- upload 继续复用三段式：
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- `objectKey` 不是 business truth。
- `file_assets` 与 `evidences` 才是可承认的业务承载。
- `audit_logs` 是当前对象最小业务审计 carrier。

### 10.1 Minimum Audit And Evidence Semantics

- 当前对象只允许最小 audit / evidence 边界。
- 已有 verified publish corridor 所涉及的最小审计语义，只能继续承认：
  - `ProjectPublished`
  - `UploadConfirmed`
- `MilestoneSubmitted`
- `InspectionSubmitted`
- `DisputeOpened`
  当前在本对象里只可被理解为：
  - audit_log_spec 中已存在的保留审计语义
  - 不是当前 full object 已形成 active command family 的证据
  - 不是当前 runtime write chain 已闭环的证据
- 当前不得借此扩成：
  - payment 第二协议族
  - publish-commit 第二协议族
  - moderation / reporting 第二协议族

## 11. Workbench / My-project / Derived Projection Boundary

- `workbench` 只是 summary + handoff。
- `my-project` 只是 private carry reuse。
- `summary label` / `state label` / UI wording 永远不是真值。
- derived projection 不能反向覆盖 `Server` canonical truth。
- 当前必须明确：
  - `my-project` 不能被写成 `workbench` 替代物
  - `workbench` 不能被写成：
    - `my-project` 真值页
    - `project detail` 真值页
    - `order detail` 真值页

## 12. Non-goals / Stage Conclusion

### 12.1 Non-goals

- `order/create`
- `contract/confirm`
- `contract/amend`
- `inspection/recheck`
- `rating/submit`
- `dispute/withdraw`
- payment / billing / settlement / tax
- governance / reporting / moderation console
- history / list / reporting 扩面
- bid / award / order conversion 扩面
- migration authoring
- implementation unlock

### 12.2 Stage Conclusion

- `Go for BFF surface freeze authoring`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`
