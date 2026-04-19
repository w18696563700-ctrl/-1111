---
owner: Codex 总控
status: frozen
purpose: Freeze the current asset inventory for the corrected publish-project workbench full-extension mainline, so the next round can distinguish real runtime assets, verified development-stage chains, page-only handoff shells, read-corridor reuse, and explicit boundary-only nodes.
layer: L0 SSOT
based_on:
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_board_closure_conclusion_addendum.md
  - docs/00_ssot/three_board_real_chain_result_verification_rerun_addendum.md
  - docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_asset_inventory_addendum.md
  - docs/04_frontend/flutter_screen_map.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/my_project/my-project.controller.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.controller.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/my_project/my-project.controller.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts
freeze_date_local: 2026-04-11
---

# 《发布项目工作台及延伸功能全链 现有资产盘点单》

## 1. Scope

- 当前对象：
  - `发布项目工作台及延伸功能全链`
- 本盘点单只服务于：
  - 盘清当前 repo 已存在的
    - 真源文书
    - Flutter 页面/路由/命令壳
    - BFF active route family
    - Server active truth/query assets
    - 已验证 development-stage runtime 证据
    - 显式边界态与冻结态
- 本盘点单不代表：
  - direct implementation
  - integration
  - `release-prep`
  - production release

## 2. 当前总盘点结论

- 当前对象不是“完全空白”。
- 当前对象也不是“整张工作台及全部延伸点已经闭环”。
- 当前最准确的 repo 现状是：
  1. `project_chain` 及其直接延伸出去的
     `project create / project detail / project list / my-project`
     已经有真实资产，并且存在 development-stage runtime 证据。
  2. `order_chain` 与 `fulfillment_chain`
     已经有页面节点、路由、read corridor 资产，
     但当前 workbench summary 真值仍是默认占位，
     不等于 live continuation 主链已成立。
  3. `extension_boundary`
     当前主要还是边界说明与冻结态；
     `rating` / `dispute withdraw`
     仍不是已打开主链。
  4. 之前冻结出来的
     `订单承接与履约承接主链`
     仍然保留，但它现在只应理解为：
     - 当前对象下的从属子链资产
     - 不是当前完整主线对象本身

## 3. 当前页面定义资产

- 当前 `发布项目工作台` 页面定义不是两个容器，而是四个容器：
  - `项目承接`
  - `订单承接`
  - `履约承接`
  - `边界能力`
- 按当前页面定义，可见节点总数为 `15`：
  - `项目承接`：`2`
    - `最近项目承接`
    - `发布项目`
  - `订单承接`：`4`
    - `当前订单承接`
    - `订单详情`
    - `合同详情`
    - `争议开启`
  - `履约承接`：`5`
    - `当前里程碑承接`
    - `里程碑列表`
    - `里程碑提交`
    - `验收详情`
    - `验收提交`
  - `边界能力`：`4`
    - `合同详情`
    - `争议开启`
    - `评价入口边界`
    - `争议撤回边界`
- 因此当前对象的正式盘点单位必须是：
  - 四容器 + 十五节点
- 不能再收缩成：
  - 只盘 `order / fulfillment`

## 4. 已存在的真源文书资产

### 4.1 已成立的上游基础

- [workbench_private_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md)
  与
  [workbench_private_board_closure_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md)
  已写死：
  - `GET /api/app/exhibition/workbench`
  - 四容器 summary
  - summary/handoff 边界
- [project_publish_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_boundary_freeze_addendum.md)
  与
  [project_publish_board_closure_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_publish_board_closure_conclusion_addendum.md)
  已写死：
  - `/exhibition/projects/create`
  - `project/create`
  - upload 三段式复用
  - `create -> detail`
    最小发布走廊
- [three_board_real_chain_result_verification_rerun_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/three_board_real_chain_result_verification_rerun_addendum.md)
  与
  [three_board_mainline_integration_release_review_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md)
  已写死：
  - `项目发布工作台 / 项目发布 / 项目展示`
    的最小 development-stage canonical mainline
    曾经真实命中

### 4.2 已成立但现重新降级为从属的子链资产

- [order_intake_and_fulfillment_mainline_asset_inventory_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/order_intake_and_fulfillment_mainline_asset_inventory_addendum.md)
  已盘过：
  - `order/detail`
  - `contract/detail`
  - `milestone/list`
  - `inspection/detail`
    的 read corridor
  - 以及对应页面壳、命令壳与缺失 route family
- 但当前正式口径是：
  - 它只保留为当前对象下的从属子链资产
  - 不能再代表整张工作台主线

## 5. Flutter 现有资产盘点

### 5.1 当前真实存在的页面与路由

- `workbench` 页面定义已存在：
  - [exhibition_workbench_view_model_sections.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart)
- `project` 主链页面与路由已存在：
  - `/exhibition/workbench`
  - `/exhibition/projects/create`
  - `/exhibition/projects/detail`
  - `/exhibition/projects`
  - `/exhibition/my/projects`
  - `/exhibition/my/projects/detail`
- `order / fulfillment / boundary` 延伸页也已存在：
  - `/exhibition/orders/detail`
  - `/exhibition/milestones`
  - `/exhibition/milestones/submit`
  - 既有 `contract / inspection / dispute / rating` 相关页壳

### 5.2 Flutter 当前最准确的定位

- Flutter 不是“什么都没有”。
- 但 Flutter 当前大量延伸页资产属于：
  - `consumer page`
  - `command shell`
  - `controlled handoff`
- 当前不能因为页面或 route 已存在，就写成：
  - 对应的 BFF / Server runtime family 已经成立

## 6. BFF 现有资产盘点

### 6.1 当前 active app-facing route family

- 当前 `apps/bff` 可确认存在的 active app-facing family 包括：
  - `GET /api/app/exhibition/workbench`
  - `GET /api/app/project/list`
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `GET /api/app/milestone/list`
  - `GET /api/app/inspection/detail`

### 6.2 BFF 当前缺失的延伸命令链

- 当前 `apps/bff/src` 里，没有看到对应 active route family 的对象包括：
  - `POST /api/app/order/create`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `POST /api/app/milestone/submit`
  - `POST /api/app/inspection/submit`
  - `POST /api/app/inspection/recheck`
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/open`
  - `POST /api/app/dispute/withdraw`

### 6.3 BFF 当前最准确的角色拆分

- 对当前对象来说，BFF 现阶段已成立的真实资产分成两类：
  1. `project / workbench / my_project`
     的 active app-facing route
  2. `trading_read_corridor`
     的 4 条 read-only route
- 当前还不能写成：
  - 全部延伸命令主链的 BFF 已成立

## 7. Server 现有资产盘点

### 7.1 当前 active Server 模块

- 当前 `apps/server` 已实际存在并纳入 app module 的 family 包括：
  - `exhibition_workbench`
  - `project`
  - `my_project`
  - `trading_read_corridor`

### 7.2 当前 `project_chain` 的真实状态

- `server/exhibition/workbench`
  当前确实在 active source 中存在。
- 但其 query/presenter 当前只真实聚合：
  - `recentProject`
  - `canCreateProject`
  - `canOpenProjectPool`
- 这意味着：
  - `project_chain`
    现在不是纯页面壳，它有真实 Server summary truth 支撑

### 7.3 当前 `order / fulfillment / extension` 的真实状态

- 当前 `exhibition-workbench.presenter.ts`
  里写死的仍然是：
  - `order_chain.activeOrderId = null`
  - `canOpenOrderDetail = false`
  - `canOpenContractDetail = false`
  - `canOpenDisputeOpen = false`
  - `fulfillment_chain.activeMilestoneId = null`
  - `canOpenMilestoneList = false`
  - `canOpenMilestoneSubmit = false`
  - `canOpenInspectionDetail = false`
  - `canOpenInspectionSubmit = false`
  - `extension_boundary.canOpenContractDetail = false`
  - `ratingEntryState = controlled_unavailable`
  - `canOpenDisputeOpen = false`
  - `disputeWithdrawState = frozen`
- 这说明当前 workbench summary 在 Server 真值层的正式状态是：
  - `project_chain` 有真实聚合
  - `order_chain / fulfillment_chain / extension_boundary`
    仍然主要是默认占位或边界态

### 7.4 当前 Server 已成立的下游真值族

- `project` family 已有 active query + write：
  - `GET /server/projects`
  - `POST /server/projects`
  - `GET /server/projects/{projectId}`
- `my_project` family 已有 active query：
  - `GET /server/my/projects`
  - `GET /server/my/projects/{projectId}`
- `trading_read_corridor` 已有 active query：
  - `GET /server/order/detail`
  - `GET /server/contract/detail`
  - `GET /server/milestone/list`
  - `GET /server/inspection/detail`

### 7.5 当前缺失的 Server 延伸命令族

- 当前 `apps/server/src` 里，未见对应 active source 的对象包括：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `milestone/submit`
  - `inspection/submit`
  - `inspection/recheck`
  - `rating/entry`
  - `rating/submit`
  - `dispute/open`
  - `dispute/withdraw`

## 8. 当前对象成熟度拆分

### 8.1 已有真实资产且已有 development-stage 证据的部分

- `project_chain` summary read
- `project create` 最小发布走廊
- `project detail`
- `project list`
- `my-project list/detail`

### 8.2 已有页面/契约/read-corridor 资产，但还不是同等成熟度的部分

- `order detail`
- `contract detail`
- `milestone list`
- `inspection detail`
- `milestone submit` 页面壳
- `inspection submit` 页面壳
- `dispute open` 页面壳
- `rating` / `dispute withdraw`
  的边界页或边界说明

### 8.3 当前明确仍是边界态/冻结态的部分

- `评价入口边界`
  - `controlled_unavailable`
- `争议撤回边界`
  - `frozen`

## 9. 当前正式盘点结论

- `发布项目工作台及延伸功能全链`
  当前正式盘点结论为：
  - `不是空白`
  - `不是全链闭环`
  - `是一个成熟度明显分层的混合对象`
- 其中最关键的分层事实是：
  1. `project_chain + publish corridor + my-project/private carry`
     是当前对象里最成熟、最接近已验证主链的部分
  2. `order / fulfillment`
     当前主要还是：
     - summary placeholder
     - read corridor
     - page shell
     - boundary carry
  3. `extension_boundary`
     当前更多是：
     - 合同详情 / 争议开启的受控续接说明
     - 评价与争议撤回的冻结边界说明

## 10. Next Unique Action

- 下一轮唯一动作：
  - 输出《发布项目工作台及延伸功能全链 truth boundary freeze》
