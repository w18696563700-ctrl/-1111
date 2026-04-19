---
owner: Codex 总控
status: frozen
purpose: Freeze the current asset inventory for the order-intake and fulfillment mainline object, so the next round can distinguish reusable read-corridor/runtime assets from page-only handoff assets, placeholder summary carriers, and still-missing write-chain truth.
layer: L0 SSOT
based_on:
  - docs/00_ssot/post_project_showcase_filter_and_project_create_form_refactor_next_bounded_object_ruling_addendum.md
  - docs/00_ssot/order_intake_and_fulfillment_mainline_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md
  - docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md
  - docs/00_ssot/s2_order_contract_fulfillment_read_corridor_minimal_transport_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/s2_bff_order_contract_fulfillment_read_corridor_aggregation_result_verification_conclusion_addendum.md
  - docs/00_ssot/s2_mobile_order_contract_fulfillment_read_corridor_consumption_closure_result_verification_conclusion_addendum.md
  - docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md
  - docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_v1.md
  - docs/04_frontend/flutter_screen_map.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-11
---

# 《订单承接与履约承接主链 现有资产盘点单》

## 1. Scope

- 当前对象：
  - `订单承接与履约承接主链`
- 本盘点单只服务于：
  - 盘清当前 repo 里已经存在的
    - 真源文书
    - Flutter 页面/路由/测试
    - BFF route family
    - Server truth / query assets
    - workbench / my-project 对下游交易链的复用关系
- 本盘点单不代表：
  - 直接进入实现
  - 直接进入联调
  - `release-prep`
  - `production release`
- 本盘点单明确不把以下对象打包进当前主线：
  - `rating/submit`
  - `dispute/withdraw`
  - `inspection/recheck`
  - 支付、结算、发票、税务
  - 交易后治理后台

## 2. 当前总盘点结论

- 当前对象不是“完全空白”。
- 当前对象也不是“真实订单与履约主链已经成立”。
- 当前最准确的 repo 现状是：
  1. `工作台摘要层` 已存在，并且 `发布项目工作台` 已封板；
     但它只冻结了四容器摘要与受控 handoff，
     不是下游订单/履约主链完成。
  2. `S2 四条只读走廊`
     已在 `Server + BFF + Flutter` 三层形成现成资产：
     - `order/detail`
     - `contract/detail`
     - `milestone/list`
     - `inspection/detail`
  3. `命令与继续动作页`
     在 Flutter 已经有大量承接页、command wrapper 和测试，
     但当前 active source 里，
     BFF/Server 并没有对应成体系的 command route family。
  4. 因此当前对象的真实起点应判为：
     - `读走廊有资产`
     - `工作台摘要有壳`
     - `写主链仍未打开`

## 3. 已存在的真源文书资产

### 3.1 直接相关的主文书

- [project_transaction_skeleton_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/project_transaction_skeleton_freeze_addendum.md)
  已正式写死：
  - `order / contract / milestone / inspection`
    当前只到 `L2 交易读走廊`
  - 当前不得写成真实交易写闭环已成立
- [workbench_private_board_boundary_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/workbench_private_board_boundary_freeze_addendum.md)
  和
  [workbench_private_board_closure_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/workbench_private_board_closure_conclusion_addendum.md)
  已写死：
  - `order_chain`
  - `fulfillment_chain`
  只是摘要容器与 continuation handoff
- [contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/contract_archive_and_mandatory_fulfillment_chain_rules_v1_app_aligned_freeze_addendum.md)
  已冻结：
  - 合同、里程碑、验收对象族的 App 对齐边界
  - 但不是实现放行
- [exhibition_trade_governance_four_documents_delivery_scheme_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_delivery_scheme_v1.md)
  已明确记录：
  - Exhibition 有最小 handoff 页
  - 运行实现完成度低
  - 不得误判为治理闭环已上线

### 3.2 已存在的历史验证文书

- [s2_order_contract_fulfillment_read_corridor_minimal_transport_closure_result_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s2_order_contract_fulfillment_read_corridor_minimal_transport_closure_result_verification_conclusion_addendum.md)
- [s2_bff_order_contract_fulfillment_read_corridor_aggregation_result_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s2_bff_order_contract_fulfillment_read_corridor_aggregation_result_verification_conclusion_addendum.md)
- [s2_mobile_order_contract_fulfillment_read_corridor_consumption_closure_result_verification_conclusion_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/s2_mobile_order_contract_fulfillment_read_corridor_consumption_closure_result_verification_conclusion_addendum.md)

这些文书共同说明：

- `order/detail`
- `contract/detail`
- `milestone/list`
- `inspection/detail`

曾经形成过一条 `S2 read corridor`，
但其正式口径仍然是：

- `PASS WITH RISK`
- `不是 stage2 implementation`
- `不是 release-prep`
- `不是 launch`

## 4. Flutter 现有资产盘点

### 4.1 已存在的路由与页面资产

当前 `apps/mobile` 已有以下页面/路由实物：

- 路由常量与 continuation helper：
  - [exhibition_routes.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart)
- 工作台容器页：
  - [exhibition_workbench_view_model_sections.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart)
- 交易/履约读页面：
  - [order_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/order_detail_page.dart)
  - [contract_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart)
  - [milestone_list_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/milestone_list_page.dart)
  - [inspection_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/inspection_detail_page.dart)
- 交易/履约命令承接页：
  - [contract_confirm_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/contract_confirm_page.dart)
  - [contract_amend_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/contract_amend_page.dart)
  - [milestone_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart)
  - [inspection_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart)
  - [inspection_recheck_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/inspection_recheck_page.dart)
- 邻接边界页：
  - [rating_entry_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/rating_entry_page.dart)
  - [rating_submit_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/rating_submit_page.dart)
  - [dispute_open_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart)
  - [dispute_withdraw_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/dispute_withdraw_page.dart)

### 4.2 已存在的 consumer / command 资产

- canonical path 家族已在
  [exhibition_canonical_paths.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart)
  注册：
  - `GET /api/app/order/detail`
  - `POST /api/app/order/create`
  - `GET /api/app/contract/detail`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `GET /api/app/milestone/list`
  - `POST /api/app/milestone/submit`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`
  - `POST /api/app/inspection/recheck`
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
  - `POST /api/app/dispute/open`
  - `POST /api/app/dispute/withdraw`
- `order/create` 当前虽无独立 page 文件，
  但已有 command 资产：
  - [order_create_command.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/commands/order_create_command.dart)
  - [exhibition_action_service.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart)
  - [exhibition_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart)

### 4.3 Flutter 当前真实定位

- Flutter 现状不是“什么都没有”。
- 但 Flutter 当前大量资产属于：
  - `最小 handoff 页`
  - `命令壳`
  - `demo / futureReal 双态承接`
- 它们不能被偷换成：
  - BFF/Server 真正命令链已经存在
  - 订单/履约真实闭环已经成立

## 5. BFF 现有资产盘点

### 5.1 已存在的 active route/module 资产

当前 `apps/bff` 已实际存在：

- [trading-read-corridor.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/trading_read_corridor/trading-read-corridor.module.ts)
- [app-trading-read-corridor.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts)
- [trading-read-corridor.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/trading_read_corridor/trading-read-corridor.controller.ts)
- [trading-read-corridor.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/trading_read_corridor/trading-read-corridor.service.ts)
- [trading-read-corridor.read-model.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/trading_read_corridor/trading-read-corridor.read-model.ts)
- [trading-read-corridor.error.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/trading_read_corridor/trading-read-corridor.error.service.ts)

并且该模块已被：

- [routes.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/routes.module.ts)

正式导入。

### 5.2 当前真正已落地的 app-facing runtime

当前 `BFF` 实际源码里能确认的交易/履约 runtime 只有 4 条 `GET`：

- `GET /api/app/order/detail`
- `GET /api/app/contract/detail`
- `GET /api/app/milestone/list`
- `GET /api/app/inspection/detail`

这四条与 `S2 read corridor` 一致。

### 5.3 当前缺失的 BFF runtime 资产

当前在 `apps/bff/src` 里，未看到对应源码 controller / route family 的对象包括：

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

当前它们更多是：

- contract / OpenAPI 冻结资产
- Flutter canonical-path 资产
- 测试与演示承接资产

而不是当前 active BFF source 里的真实 route family。

### 5.4 BFF 当前定位

- `BFF` 当前在这条主线里的真实资产定位是：
  - `S2 read corridor aggregation`
- 还不能写成：
  - `订单与履约命令主链 BFF 已成立`

## 6. Server 现有资产盘点

### 6.1 已存在的 active truth/query 资产

当前 `apps/server` 已实际存在：

- [trading-read-corridor.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/trading_read_corridor/trading-read-corridor.module.ts)
- [trading-read-corridor.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts)
- [trading-read-corridor.query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/trading_read_corridor/trading-read-corridor.query.service.ts)
- [trading-read-corridor.presenter.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/trading_read_corridor/trading-read-corridor.presenter.ts)
- [trading-read-corridor.errors.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/trading_read_corridor/trading-read-corridor.errors.ts)

并且该模块已被：

- [app.module.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/app.module.ts)

正式导入。

### 6.2 当前真正已落地的 Server runtime

当前 `Server` 源码里能确认的交易/履约 runtime 仍只有 4 条 `GET`：

- `GET /server/order/detail`
- `GET /server/contract/detail`
- `GET /server/milestone/list`
- `GET /server/inspection/detail`

其底层已经真实读取：

- `public.orders`
- `public.contracts`
- `public.milestones`
- `public.inspections`

并带有：

- organization scope 约束
- state visibility 约束
- controlled unavailable / invalid error

### 6.3 当前缺失的 Server truth/module 资产

当前在 `apps/server/src/modules` 里，未看到 dedicated source module / controller family 的对象包括：

- `order create`
- `contract confirm`
- `contract amend`
- `milestone submit`
- `inspection submit`
- `inspection recheck`
- `rating entry`
- `rating submit`
- `dispute open`
- `dispute withdraw`

因此当前不能把已有的 persistence 表族或 contract 文书，
误判成“这些命令真值模块已经在 active source 落地”。

## 7. Workbench / My-project 复用资产盘点

### 7.1 workbench 的真实现状

当前 `发布项目工作台` 的 order/fulfillment 摘要不是 live runtime 主链。

证据：

- [exhibition-workbench.query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts)
  目前只查询：
  - `recentProject`
  - `canCreateProject`
- [exhibition-workbench.presenter.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts)
  对以下字段直接给出默认值：
  - `order_chain.activeOrderId = null`
  - `order_chain.canOpenOrderDetail = false`
  - `fulfillment_chain.activeMilestoneId = null`
  - `fulfillment_chain.canOpenMilestoneList = false`
  - `extension_boundary.ratingEntryState = controlled_unavailable`
  - `extension_boundary.disputeWithdrawState = frozen`

当前正式解释应为：

- workbench 的 `订单承接 / 履约承接` 容器壳子已存在
- 但当前 active Server summary 还没有把真实订单/里程碑 truth 接进去

### 7.2 my-project 的真实现状

`my_project` 已有一层项目级私域摘要复用：

- [my-project.query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/my_project/my-project.query.service.ts)
- [my-project.private-progress.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/my_project/my-project.private-progress.ts)

当前它能读时派生：

- `orderStatus`
- `contractStatus`
- `fulfillmentStatus`
- `afterSalesOrDisputeStatus`
- `ratingStatus`

但当前源码也明确写着：

- `acceptanceStatus: null`
- `The current runtime has no dedicated acceptance truth carrier wired into this repo.`

这说明：

- `my_project` 现在能复用部分订单/合同/履约摘要
- 但验收真值承接仍未闭合

## 8. 测试与验证资产盘点

### 8.1 Server

- 已存在：
  - [s2-order-contract-fulfillment-read-corridor.test.cjs](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/test/s2-order-contract-fulfillment-read-corridor.test.cjs)
- 这证明 Server 对四条 `GET` read corridor 有明确测试资产

### 8.2 Flutter

已存在的直接相关测试包括：

- [exhibition_read_corridor_closure_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/exhibition_read_corridor_closure_test.dart)
- [contract_phase3_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/contract_phase3_test.dart)
- [inspection_phase3_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/inspection_phase3_test.dart)
- [dispute_entry_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/dispute_entry_test.dart)
- [rating_entry_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/rating_entry_test.dart)
- [shell_app_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/shell_app_test.dart)
- [exhibition_home_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/exhibition_home_test.dart)

这些测试说明：

- Flutter 在这条主线上的页面与 command 承接并不稀薄
- 但很多用例仍是：
  - handoff semantics
  - controlled failure
  - demo / fake transport
  - route continuity

不等于 BFF/Server 命令主链已经真实打通

### 8.3 BFF

- 当前 repo 内未看到与 `trading_read_corridor` 对应的
  `apps/bff/test/**` 本地测试文件资产。
- 因此 BFF 当前资产更多体现在：
  - active source module/controller/service
  - 已冻结的历史结果校验文书

## 9. 对象级资产分类表

| 对象 | 文书/contract | Flutter | BFF | Server | 当前分类 |
|---|---|---|---|---|---|
| `order/detail` | 已有 | 已有页面 | 已有 route | 已有 query truth | `真实可复用只读资产` |
| `contract/detail` | 已有 | 已有页面 | 已有 route | 已有 query truth | `真实可复用只读资产` |
| `milestone/list` | 已有 | 已有页面 | 已有 route | 已有 query truth | `真实可复用只读资产` |
| `inspection/detail` | 已有 | 已有页面 | 已有 route | 已有 query truth | `真实可复用只读资产` |
| `order/create` | 已有 | 只有 command / 测试 / 演示承接 | 未见 active route | 未见 active truth module | `contract/page-only 资产` |
| `contract/confirm` | 已有 | 已有承接页 | 未见 active route | 未见 active truth module | `contract/page-only 资产` |
| `contract/amend` | 已有 | 已有承接页 | 未见 active route | 未见 active truth module | `contract/page-only 资产` |
| `milestone/submit` | 已有 | 已有承接页 | 未见 active route | 未见 active truth module | `contract/page-only 资产` |
| `inspection/submit` | 已有 | 已有承接页 | 未见 active route | 未见 active truth module | `contract/page-only 资产` |
| `inspection/recheck` | 已有 | 已有承接页 | 未见 active route | 未见 active truth module | `边界/战略预留资产` |
| `rating/dispute` 邻接页 | 已有 | 已有承接页 | 未见 active route | 未见 active truth module | `邻接边界资产，非当前主链核心` |
| `workbench order/fulfillment summary` | 已有 | 已有容器消费 | 已有 summary path | 当前 presenter 默认占位 | `摘要壳资产，不是 live 主链` |
| `my_project privateProgress` | 已有 | 已有消费 | 已有私域 path | 已有读时派生，但验收缺口仍在 | `项目级旁路摘要资产` |

## 10. 当前最关键的真实缺口

当前对象真正缺的不是“页面有没有”。

真正缺的是：

1. `对象级 truth boundary`
- 还没把当前对象正式写死为：
  - 这轮只收口读走廊
  - 还是要把部分命令走廊也纳入当前主线

2. `workbench live 绑定`
- 当前 `发布项目工作台` 的 `订单承接 / 履约承接`
  还没绑定真实 `Order / Milestone` carrier

3. `BFF/Server command family`
- 当前 active source 里没有与 Flutter 承接页一一对应的命令主链

4. `acceptance truth`
- `my_project` 当前仍明确缺少 dedicated acceptance truth carrier

5. `对象边界裁决`
- 还没正式写死：
  - `inspection/recheck`
  - `rating`
  - `dispute`
  在当前对象里到底属于排除项、边界项，还是下一轮对象

## 11. Formal Conclusion

- `订单承接与履约承接主链` 当前正式盘点结论为：
  - `有基础`
  - `未闭环`
  - `当前主资产是 S2 四条只读走廊`
  - `当前工作台 order/fulfillment 仍主要是摘要壳`
  - `当前写主链在 Flutter 页和 contract 层存在，但未在 active BFF/Server source 中闭合`
- 当前正式禁止改写成：
  - `订单承接与履约承接主链已经做完`
  - `工作台空态只是缺数据，后端主链其实已经都有`
  - `OpenAPI 注册了 path，就等于 runtime 已实现`

## 12. Next Unique Action

- 下一轮唯一动作：
  - 输出《订单承接与履约承接主链 truth boundary freeze》
