---

## Pricing Override Note

当前 publish workbench 的页面壳、提交流程主壳和 continuation 边界继续沿用本文件。

但自 [platform_pricing_frontend_consumption_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md) 生效后，本文件不再拥有收费 gate authority。

当前正式补充冻结如下：

1. `/exhibition/projects/create` 仍是当前项目发布主页壳
2. 若当前项目需先完成 `200 元项目真实性诚意金`，Flutter 必须先走收费 gate，再显示正式发布成功
3. 本文件不得再被误读为“发布工作台天然不含收费前置”
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter-side consumption, page-state, submit-feedback, and continuation-handoff boundary for the corrected full publish-workbench and extension mainline only.
layer: L5 Frontend
freeze_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_asset_inventory_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/three_board_real_chain_result_verification_rerun_addendum.md
  - docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stop_line_reentry_gate_path_addendum.md
  - docs/00_ssot/source_of_truth_map.md
---

# 《发布项目工作台及延伸功能全链 frontend consumption freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `发布项目工作台及延伸功能全链`
- 本冻结单只服务于：
  - 当前对象 Flutter 页面消费边界
  - 当前对象 `loading / content / empty / blocker / failure` 状态边界
  - 当前对象 verified runtime / read-corridor / shell-handoff / boundary-only 的 frontend consumption 区分
  - 当前对象 controlled submit feedback
  - 当前对象 continuation handoff 边界
- 本冻结单不进入：
  - `apps/mobile/**` 实现
  - 新路由族
  - integration
  - `release-prep`
  - production release

## 2. Frontend Freeze Conclusion

- 本轮不是 `no-op`。
- 本轮是 corrected full object 的正式 frontend consumption freeze。
- 当前不允许再把：
  - `订单承接与履约承接主链`
    当成 full mainline frontend object
- 当前不允许把：
  - shell 节点
  - boundary 节点
    偷写成 active command consumption 已成立
- 当前不允许借 frontend 文书把排除项偷偷并入。
- `订单承接与履约承接主链`
  当前只保留为：
  - subordinate screenshot-derived continuation subchain
  - subordinate stop-line asset

## 3. Frontend Truth Boundary

- Flutter 只允许做：
  - consume app-facing projection
  - controlled `loading / content / empty / blocker / failure`
  - controlled submit feedback
  - continuation route handoff
- Flutter 不得做：
  - truth owner
  - 第二状态机
  - 本地 `pass / complete / closed / withdrawable / rateable` 推导
  - 本地把 shell 节点升级成 active command family
- page shell / route shell / placeholder 不等于 runtime 已通。
- `Server` 仍是唯一 truth owner。
- `BFF` 只是 app-facing layer。
- `workbench` / `my-project` 不是 frontend truth owner。

## 4. Canonical Route / Page Carrier Freeze

- 当前 frontend 只允许冻结以下 route / page carrier：
  - `/exhibition/workbench`
  - `/exhibition/projects/create`
  - `/exhibition/projects/detail`
  - `/exhibition/projects`
  - `/exhibition/my/projects`
  - `/exhibition/my/projects/detail`
  - `/exhibition/orders/detail`
  - `/exhibition/contracts/detail`
  - `/exhibition/milestones`
  - `/exhibition/inspections/detail`
  - `/exhibition/milestones/submit` 的 shell / handoff page position
  - `/exhibition/inspections/submit` 的 shell / handoff page position
  - `/exhibition/disputes/open` 的 shell / handoff page position
- 当前必须明确禁止把以下 route / page 纳入本轮：
  - `/exhibition/orders/create`
  - `/exhibition/contracts/confirm`
  - `/exhibition/contracts/amend`
  - `/exhibition/inspections/recheck`
  - `/exhibition/ratings/submit`
  - `/exhibition/disputes/withdraw`

## 5. `project_chain` Frontend Consumption Freeze

- `project_chain` 是当前对象里最成熟的 continuation slice。
- `/exhibition/workbench` 只承担：
  - summary
  - handoff page
- 以下页面共同构成当前对象里最成熟的一组 frontend consumption asset：
  - `/exhibition/projects/create`
  - `/exhibition/projects/detail`
  - `/exhibition/projects`
  - `/exhibition/my/projects`
  - `/exhibition/my/projects/detail`

### 5.1 Minimum Consumption Semantics

- 最小消费语义至少包括：
  - `recentProjectId`
  - `canCreateProject`
  - `projectId`
  - `publicProject`
  - `privateProgress`

### 5.2 Hard Boundary

- `workbench` 不是 public home。
- `workbench` 不是第二项目状态机。
- `workbench` 不是 `bid / award / order conversion` owner。
- `project_publish_board` 复用关系继续有效：
  - `project/create`
  - upload 三段式
    继续复用既有 publish corridor
- 但当前 full object 不得偷换成：
  - “只有 publish corridor”

## 6. `order_chain` Frontend Consumption Freeze

- `order_chain` 当前是 subordinate continuation slice。
- `activeOrderId` 只是 continuation carrier。
- 当前只允许冻结：
  - `/exhibition/orders/detail`
  - `/exhibition/contracts/detail`
  - `/exhibition/disputes/open` 的 shell / handoff page position

### 6.1 Consumption Role

- `order/detail` 与 `contract/detail` 当前只代表：
  - read-corridor consumption
- `dispute/open` 当前不得写成：
  - active command consumption 已成立

### 6.2 Hard Boundary

- 当前明确不扩：
  - `/exhibition/orders/create`
  - `/exhibition/ratings/submit`
  - `/exhibition/disputes/withdraw`

## 7. `fulfillment_chain` Frontend Consumption Freeze

- `fulfillment_chain` 当前也是 subordinate continuation slice。
- `activeMilestoneId` 只是 continuation carrier。
- 当前只允许冻结：
  - `/exhibition/milestones`
  - `/exhibition/inspections/detail`
  - `/exhibition/milestones/submit` 的 shell / handoff page position
  - `/exhibition/inspections/submit` 的 shell / handoff page position

### 7.1 Consumption Role

- `milestone/list` 与 `inspection/detail` 当前只代表：
  - read-corridor consumption
- `milestone/submit` 与 `inspection/submit` 当前不得写成：
  - active command consumption 已成立

### 7.2 Hard Boundary

- 当前明确不扩：
  - `/exhibition/inspections/recheck`
  - approval / governance console
  - 第二履约状态机

## 8. `extension_boundary` Frontend Consumption Freeze

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
  - 不得把它扩成 `rating / dispute` full frontend family

## 9. Verified Runtime vs Read Corridor vs Shell vs Boundary Split

- 当前四类 frontend consumption 语义正式写死如下：
  1. verified development-stage runtime consumption
     - `workbench`
     - `project/create`
     - `project/detail`
     - `project list`
     - `my-project` private carry
  2. active read-corridor consumption
     - `order/detail`
     - `contract/detail`
     - `milestone/list`
     - `inspection/detail`
  3. shell / handoff page position
     - `milestone/submit`
     - `inspection/submit`
     - `dispute/open`
  4. boundary-only / frozen-state consumption marker
     - `ratingEntryState`
     - `disputeWithdrawState`
     - `评价入口边界`
     - `争议撤回边界`
- 当前必须明确：
  - route / page existence != runtime closure
  - summary presence != downstream truth closure
  - historical subchain docs != current full object closure
  - shell / handoff page position != active command family already implemented

## 10. State / Failure / Controlled Feedback Boundary

- Flutter 页面允许出现：
  - `loading`
  - `content`
  - `empty`
  - `blocker`
  - `failure`
  - `controlled unavailable`
  - `invalid-state`
  - `frozen-boundary`
- 这些状态必须基于 app-facing surface 消费，不得本地伪造业务完成。
- 当前必须明确：
  - 不得把 empty-state 伪装成“已接通成功”
  - 不得把 page shell / placeholder 写成已完成
  - 不得把没有 active route / 没有 active truth module 包装成 happy-path pass

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
- implementation unlock

### 12.2 Stage Conclusion

- `Go for docs-only freeze review conclusion authoring`
- `No-Go for direct implementation`
- `No-Go for integration`
- `No-Go for release-prep`
- `No-Go for production release`
