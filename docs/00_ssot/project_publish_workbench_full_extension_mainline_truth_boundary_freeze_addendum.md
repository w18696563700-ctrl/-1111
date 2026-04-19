---
owner: Codex 总控
status: frozen
purpose: Freeze the truth boundary for the corrected full publish-workbench and extension mainline, so the next contract round proceeds on a single meaning for the four-container object, its mixed maturity, its subordinate order/fulfillment subchain, and its owner boundaries.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_asset_inventory_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/three_board_real_chain_result_verification_rerun_addendum.md
  - docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stop_line_reentry_gate_path_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/01_contracts/openapi.yaml
  - docs/00_ssot/source_of_truth_map.md
---

# 《发布项目工作台及延伸功能全链 truth boundary freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `发布项目工作台及延伸功能全链`
- 本冻结单只服务于：
  - 当前对象纳入 / 排除边界
  - 四容器对象职责
  - verified-runtime / read-corridor / page-shell / boundary-only 四类成熟度边界
  - `workbench / my-project / publish corridor / downstream continuation`
    的 owner 边界
- 本冻结单不进入：
  - contract freeze
  - backend / BFF / frontend 实现
  - integration
  - `release-prep`
  - production release

## 2. Truth Freeze Conclusion

- 本轮不是 `no-op`。
- 本轮是对 corrected full object 的正式边界冻结。
- 当前不允许再把：
  - `订单承接与履约承接主链`
    当成真实主线对象
- 当前也不允许把整张工作台误写成：
  - “只剩 `order / fulfillment` 子链”
- 当前正式结论写死为：
  - `发布项目工作台及延伸功能全链`
    才是当前真实主线对象
  - `订单承接与履约承接主链`
    只保留为 subordinate screenshot-derived continuation subchain
  - 它不再代表：
    - 当前真实主线对象
    - 当前整张工作台的完成定义

## 3. Object Shape Freeze

- 当前对象由四个固定容器组成：
  - `project_chain` = `项目承接`
  - `order_chain` = `订单承接`
  - `fulfillment_chain` = `履约承接`
  - `extension_boundary` = `边界能力`
- 当前对象的正式盘点视图固定为：
  - 四容器 + `15` 节点
- 当前 `15` 个节点都属于盘点视图，但不等于 `15` 个节点都已 live。

### 3.1 Fifteen-node Inventory View

- `project_chain`：
  - `最近项目承接`
  - `发布项目`
- `order_chain`：
  - `当前订单承接`
  - `订单详情`
  - `合同详情`
  - `争议开启`
- `fulfillment_chain`：
  - `当前里程碑承接`
  - `里程碑列表`
  - `里程碑提交`
  - `验收详情`
  - `验收提交`
- `extension_boundary`：
  - `合同详情续接`
  - `争议开启续接`
  - `评价入口边界`
  - `争议撤回边界`

### 3.2 Mixed-maturity Rule

- 当前对象是一个 mixed-maturity object。
- 当前对象不是 single-maturity object。
- 当前四容器的成熟度不一致，必须分层理解，不得把最成熟 slice 的通过结论外溢到全部容器。

## 4. `project_chain` Truth Boundary

- `project_chain` 是当前对象里最成熟的 continuation slice。
- 它当前正式承接：
  - `recentProjectId`
  - `canCreateProject`
  - 与 publish / my-project 的私域续接关系
- 它当前真实下游资产包括：
  - `GET /api/app/exhibition/workbench`
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `GET /api/app/project/list`
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
- `project_publish_board` 的复用关系继续有效：
  - `project/create`
  - upload 三段式
    继续复用既有 publish corridor
- 但当前 full object 不得偷换成：
  - “只有 publish corridor”
- `three-board mainline` 的既有 verified chain 继续有效：
  - `项目发布工作台 / 项目发布 / 项目展示`
    的 verified development-stage chain 继续只对当前 `project_chain + publish corridor + my-project/private carry`
    部分构成有效背景
- 但它不得被写成：
  - 后续 `order / fulfillment / extension` 也已一并闭环
- `project_chain` 当前不是：
  - public home
  - 第二项目状态机
  - `bid / award / order conversion` owner

## 5. `order_chain` Truth Boundary

- `order_chain` 当前是 subordinate continuation slice。
- 它当前可正式纳入的对象只限：
  - `activeOrderId` carrier
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `POST /api/app/dispute/open` 的 page-shell / handoff target
- `order/detail` 与 `contract/detail` 当前属于 read-corridor asset。
- `dispute/open` 当前不得写成已存在 active command family。
- 当前明确不扩：
  - `POST /api/app/order/create`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/withdraw`

## 6. `fulfillment_chain` Truth Boundary

- `fulfillment_chain` 当前也是 subordinate continuation slice。
- 它当前可正式纳入的对象只限：
  - `activeMilestoneId` carrier
  - `GET /api/app/milestone/list`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/milestone/submit` 的 page-shell / handoff target
  - `POST /api/app/inspection/submit` 的 page-shell / handoff target
- `milestone/list` 与 `inspection/detail` 当前属于 read-corridor asset。
- `milestone/submit` 与 `inspection/submit` 当前不得写成 active command family。
- 当前明确不扩：
  - `POST /api/app/inspection/recheck`
  - approval / governance console
  - 第二履约状态机

## 7. `extension_boundary` Truth Freeze

- `extension_boundary` 不是完整业务子链。
- 它只承接 boundary-state 和 limited continuation posture。
- 当前只允许写清：
  - 合同详情续接
  - 争议开启续接
  - `ratingEntryState`
  - `disputeWithdrawState`
- 当前必须明确：
  - `评价入口边界` 当前不是 open action
  - `争议撤回边界` 当前不是 open action
  - 当前不得把边界说明写成 live capability
- `extension_boundary` 中的合同详情续接与争议开启续接，只能被理解为：
  - 对既有 downstream continuation 的 boundary mirror
  - 不是新的 truth family
  - 不是新的 active command family

## 8. Verified Runtime vs Placeholder Split

- 当前四类成熟度正式写死如下：
  1. verified development-stage runtime
     - `GET /api/app/exhibition/workbench`
     - `POST /api/app/project/create`
     - `GET /api/app/project/detail`
     - `GET /api/app/project/list`
     - `GET /api/app/my/projects`
     - `GET /api/app/my/projects/{projectId}`
  2. active read-corridor runtime
     - `GET /api/app/order/detail`
     - `GET /api/app/contract/detail`
     - `GET /api/app/milestone/list`
     - `GET /api/app/inspection/detail`
  3. page-shell / command-shell
     - `POST /api/app/milestone/submit`
     - `POST /api/app/inspection/submit`
     - `POST /api/app/dispute/open`
  4. boundary-only / frozen state
     - `评价入口边界`
     - `争议撤回边界`
     - `ratingEntryState`
     - `disputeWithdrawState`
- 当前必须明确：
  - route / page existence != runtime closure
  - summary presence != downstream truth closure
  - historical subchain docs != current full object closure

## 9. Workbench / My-project / Owner Boundary

- `workbench` 当前仍只允许被写成：
  - summary
  - handoff
- `my-project` 当前仍只允许被写成：
  - private carry reuse
- `Server` 仍是唯一 business truth owner。
- `BFF` 仍只是 app-facing aggregation layer。
- Flutter 仍只是 consumer。
- 当前必须明确：
  - `workbench` 不是第二工作台状态机
  - `workbench` 不是治理后台
  - `workbench` 不是整条下游交易链的真值 owner
  - `my-project` 不能被写成 `workbench` 替代物
  - `workbench` 不能被写成：
    - `my-project` 真值页
    - `project detail` 真值页
    - `order detail` 真值页

## 10. Non-goals / Stage Conclusion

- 当前 non-goals 明确如下：
  - `POST /api/app/order/create`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `POST /api/app/inspection/recheck`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/withdraw`
  - payment / billing / settlement / tax
  - governance / reporting / moderation console
- 当前阶段结论只允许写：
  - `Go for contract freeze authoring`
  - `No-Go for direct implementation`
  - `No-Go for integration`
  - `No-Go for release-prep`
  - `No-Go for production release`
