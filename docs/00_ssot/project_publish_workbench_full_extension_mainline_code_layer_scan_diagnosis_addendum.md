---
owner: Codex 总控
status: frozen
purpose: >
  Record the code-layer scan diagnosis for
  `发布项目工作台及延伸功能全链`, focusing on concrete contradictions
  across freeze docs, generated contracts, mobile routes/pages/tests, and
  current BFF/Server implementations before any repair dispatch.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - apps/bff/src/shared/generated/app-api.types.ts
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_source.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/rating_entry_page.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/messages/data/messages_registered_entry_registry.dart
  - apps/mobile/test/contract_phase3_test.dart
  - apps/mobile/test/rating_entry_test.dart
  - apps/mobile/test/dispute_entry_test.dart
  - apps/mobile/test/inspection_phase3_test.dart
---

# 《发布项目工作台及延伸功能全链 code-layer 扫描诊断单》

## 1. Scope

- 本诊断单只回答：
  - 当前 repo 在代码层到底已经实现了什么
  - 当前 repo 在代码层把哪些能力写成了相互冲突的成熟度
  - 哪些矛盾会直接阻断“发布项目工作台”后续收口
- 本诊断单不是：
  - implementation unlock
  - repair dispatch
  - direct implementation
  - integration / `release-prep` / production release

## 2. 总结结论

- 当前对象不是“工作台完全没做”。
- 当前对象也不是“工作台及延伸链已经按同一成熟度闭环”。
- 当前最准确的代码层结论是：
  1. `BFF + Server` 真正接通的只有：
     - `workbench`
     - `project/create`
     - `project/detail`
     - `project/list`
     - `my/projects`
     - `my/projects/{projectId}`
     - `order/detail`
     - `contract/detail`
     - `milestone/list`
     - `inspection/detail`
  2. Flutter 代码面已经把更多下游路径和页面壳暴露出来：
     - `contract/confirm`
     - `contract/amend`
     - `milestone/submit`
     - `inspection/submit`
     - `inspection/recheck`
     - `rating/entry`
     - `rating/submit`
     - `dispute/open`
     - `dispute/withdraw`
  3. docs freeze、generated contract、mobile route/test、BFF/Server 实现，目前并不在同一成熟度口径上。
- 因此当前真正的主阻断不是“某一个页面没写完”，而是：
  - 同一个对象被 repo 同时编码成了两套互相冲突的能力模型。

## 3. 已确认矛盾

### 3.1 P0: docs freeze 与 generated contract / app-api 路径族直接打架

- `contract freeze` 明确只允许：
  - `workbench`
  - `project`
  - `my-project`
  - 四条 read corridor
  - `milestone/submit`
  - `inspection/submit`
  - `dispute/open` 作为 shell / handoff position
- 同一份 freeze 又明确禁止：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/submit`
  - `dispute/withdraw`
- 证据：
  - [project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md#L60)
  - [project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md#L76)
- 但 generated `APP_API_PATHS` 仍把以下路径都列成正式 app-facing path：
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
- 证据：
  - [app-api.types.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/shared/generated/app-api.types.ts#L3)
- 直接后果：
  - 当前 repo 的“合同层真相”和“代码生成出来的正式路径清单”不是同一版本。
  - 任何继续基于 generated path list 开发或写测试，都会继续扩大漂移。

### 3.2 P0: frontend freeze 明确禁止的页面，mobile router 仍然直接放行

- `frontend consumption freeze` 明确禁止纳入本轮：
  - `/exhibition/contracts/confirm`
  - `/exhibition/contracts/amend`
  - `/exhibition/inspections/recheck`
  - `/exhibition/ratings/submit`
  - `/exhibition/disputes/withdraw`
- 证据：
  - [project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md#L79)
  - [project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md#L95)
- 但 `app_router.dart` 仍把这些路由全部注册成可直达页面：
  - `contractConfirm`
  - `contractAmend`
  - `inspectionRecheck`
  - `ratingEntry`
  - `ratingSubmit`
  - `disputeWithdraw`
- 证据：
  - [app_router.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/shell/navigation/app_router.dart#L350)
- 直接后果：
  - “前端 freeze 未纳入本轮”的页面，在客户端实际上仍然可导航。
  - 这不是 copy 误差，而是 route layer 已经放行。

### 3.3 P0: detail 页面和消息注册把冻结能力重新从旁路带出来了

- `contract detail` 当前仍会根据合同状态直接 handoff 到：
  - `继续合同确认`
  - `继续合同改单`
- 证据：
  - [contract_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/contract_detail_page.dart#L209)
- `rating entry` 当前会继续 handoff 到：
  - `继续提交评价`
- 证据：
  - [rating_entry_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/rating_entry_page.dart#L119)
- `messages` 注册表当前还把以下 actionKey 冻成 enabled：
  - `contract.confirm`
  - `contract.amend`
  - `inspection.submit`
  - `rating.submit`
  - `dispute.open`
  - `dispute.withdraw`
- 证据：
  - [messages_registered_entry_registry.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/messages/data/messages_registered_entry_registry.dart#L117)
- 直接后果：
  - 即便工作台本页没有直接把某些冻结能力放出来，合同详情页、评价入口页、消息页仍能把用户带过去。
  - 当前边界并没有被真实封住，只是换了入口继续暴露。

### 3.4 P0: mobile consumer 已经按“完整 command family 存在”写好，但 BFF / Server 并没有对应实现

- `ExhibitionCanonicalPaths` 和 consumer/action service 已经为以下路径提供正式调用入口：
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
- 证据：
  - [exhibition_canonical_paths.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart#L19)
  - [exhibition_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart#L161)
  - [exhibition_action_service.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart#L19)
- 但 `BFF` 当前真正暴露的 app-facing controller 只有：
  - `workbench`
  - `project/list|create|detail`
  - `order/detail`
  - `contract/detail`
  - `milestone/list`
  - `inspection/detail`
- 证据：
  - [app-exhibition-workbench.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts#L5)
  - [app-project.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/project/app-project.controller.ts#L5)
  - [app-trading-read-corridor.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts#L5)
- `Server` 当前真正暴露的 trading/workbench controller 也只有：
  - `server/exhibition/workbench`
  - `server/order/detail`
  - `server/contract/detail`
  - `server/milestone/list`
  - `server/inspection/detail`
- 证据：
  - [trading-read-corridor.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts#L6)
- 直接后果：
  - mobile 代码把大量 command/read 入口当成正式 BFF 能力消费了；
  - 但 BFF / Server 当前并没有对等 controller family。
  - 这是当前工作台最核心的“前后端成熟度错位”。

### 3.5 P1: 当前 workbench 真 summary 仍然只有 `project_chain` 真接通，其余三容器全是占位

- `Server` workbench presenter 当前写死：
  - `order_chain.activeOrderId = null`
  - `canOpenOrderDetail = false`
  - `canOpenContractDetail = false`
  - `canOpenDisputeOpen = false`
  - `fulfillment_chain.activeMilestoneId = null`
  - `canOpenMilestoneList = false`
  - `canOpenMilestoneSubmit = false`
  - `canOpenInspectionDetail = false`
  - `canOpenInspectionSubmit = false`
  - `extension_boundary.ratingEntryState = controlled_unavailable`
  - `extension_boundary.disputeWithdrawState = frozen`
- 证据：
  - [exhibition-workbench.presenter.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts#L19)
- 这意味着当前真实 runtime 状态是：
  - `项目承接` 有真实 summary
  - `订单承接 / 履约承接 / 边界能力` 仍然没有真实 continuation binding
- 直接后果：
  - 当前页面四容器外观已存在，但运行时真值只有第一容器真正接通。
  - 如果不先解决这一层，再去修下游页面，只会继续扩大“页面比真值先成熟”的假闭环。

### 3.6 P1: 测试层已经把未来路径写成了当前正式 happy path

- `contract_phase3_test.dart` 直接要求：
  - `POST /api/app/contract/confirm`
- 证据：
  - [contract_phase3_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/contract_phase3_test.dart#L187)
- `rating_entry_test.dart` 直接要求：
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
- 证据：
  - [rating_entry_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/rating_entry_test.dart#L140)
- `dispute_entry_test.dart` 直接要求：
  - `POST /api/app/dispute/withdraw`
- 证据：
  - [dispute_entry_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/dispute_entry_test.dart#L108)
- `inspection_phase3_test.dart` 直接要求：
  - `POST /api/app/inspection/recheck`
- 证据：
  - [inspection_phase3_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/inspection_phase3_test.dart#L293)
- 直接后果：
  - 当前测试集已经不只是“覆盖现状”，而是在给未实现或冻结中的路径背书。
  - 后续如果不先重构测试口径，任何修正边界的动作都会先撞上现有测试假设。

### 3.7 P1: `project_chain` 自身也存在 contract-carrier 与页面消费错位

- docs 冻结里，`项目工作台` 当前允许承接：
  - `hasProjects`
  - `recentProjectId`
  - `recentProjectTitle`
  - `canCreateProject`
  - `canOpenProjectPool`
- 证据：
  - [my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md#L72)
- 当前 `Server` query 也确实返回：
  - `canOpenProjectPool`
  - 且在有 scope 时恒定写成 `true`
- 证据：
  - [exhibition-workbench.query.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts#L36)
- 但 `Flutter` 项目承接容器当前真正消费的只有：
  - `recentProjectId`
  - `recentProjectTitle`
  - `canCreateProject`
- `canOpenProjectPool` 只被 parse 进 model，没有进入 view model 行为。
- 证据：
  - [exhibition_workbench_source.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_source.dart#L181)
  - [exhibition_workbench_view_model_sections.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart#L14)
- 直接后果：
  - `project_chain` 的 carrier 已经比当前页面实际可见动作更宽。
  - 如果后续继续围绕 `canOpenProjectPool` 实现，而不先决定它是否仍属于本轮节点，会继续制造多余漂移。

### 3.8 P2: 关键修复面已经出现明显超长文件债务

- 当前关键路径里至少有三处已明显越过 AGENTS 限制：
  - `project_create_page.dart` = `1266` 行
  - `app_router.dart` = `551` 行
  - `exhibition_stage_demo_catalog.dart` = `458` 行
- 证据：
  - [project_create_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart#L1)
  - [app_router.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/shell/navigation/app_router.dart#L1)
  - [exhibition_stage_demo_catalog.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_stage_demo_catalog.dart)
- 直接后果：
  - 下一轮如果直接在这些文件上继续补逻辑，极易把“边界修复”做成新的耦合堆积。

## 4. 当前代码层成熟度表

- 当前真实 runtime 已接通：
  - `workbench`
  - `project/create`
  - `project/detail`
  - `project/list`
  - `my/projects`
  - `my/projects/{projectId}`
  - `order/detail`
  - `contract/detail`
  - `milestone/list`
  - `inspection/detail`
- 当前只存在于 mobile page / route / consumer / test 的扩张面：
  - `contract/confirm`
  - `contract/amend`
  - `milestone/submit`
  - `inspection/submit`
  - `inspection/recheck`
  - `rating/entry`
  - `rating/submit`
  - `dispute/open`
  - `dispute/withdraw`
- 当前 workbench summary 真值层：
  - `project_chain = real`
  - `order_chain = placeholder`
  - `fulfillment_chain = placeholder`
  - `extension_boundary = boundary placeholder`

## 5. 对“发布项目工作台”收口的直接影响

- 当前不能直接进入“补一个页面或补一个接口”的实现节奏。
- 必须先解决以下三件事，否则修一处坏两处：
  1. 统一唯一口径：
     - 到底以最新 freeze 为准，还是以 current openapi / generated app-api / mobile route/test 为准。
  2. 收回越界入口：
     - router
     - detail handoff
     - messages registered entry
     - 以及对应测试假设
  3. 再决定剩余允许范围内的真修复：
     - 是先把 workbench 的 `order / fulfillment` summary 真绑定补上
     - 还是先把 shell / handoff path 真正落到 BFF / Server

## 6. 当前建议的修复顺序

- 第一优先级：
  - 先以最新 freeze 为准，清掉 `contract/confirm`、`contract/amend`、`inspection/recheck`、`rating/entry`、`rating/submit`、`dispute/withdraw` 的 contract/router/messages/test 漂移
- 第二优先级：
  - 统一 `milestone/submit`、`inspection/submit`、`dispute/open` 的真实定位：
    - 要么保持 shell-only，并去掉“像已接通 command family”的假象
    - 要么正式补齐 BFF / Server 对应实现
- 第三优先级：
  - 给 `workbench` 补真实 `order_chain / fulfillment_chain` summary 绑定，避免当前页面永远只有 `project_chain` 真接通
- 第四优先级：
  - 拆分超长文件，先降低工作台主修复面的耦合度

## 7. Formal Conclusion

- `发布项目工作台及延伸功能全链 / code-layer scan = 完成`
- 当前正式诊断结论：
  - 主阻断不是单点缺页
  - 主阻断是 freeze / contract / mobile / BFF / Server 五层编码口径不一致
- 当前不得偷换成：
  - “只要把某个页面补完，工作台就会正常”
  - “当前下游 command family 其实已经具备”

