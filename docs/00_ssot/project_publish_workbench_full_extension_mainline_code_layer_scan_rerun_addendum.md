---
owner: Codex 总控
status: frozen
purpose: >
  Record the refreshed code-layer scan for
  `发布项目工作台及延伸功能全链`, focusing on the current runtime chain,
  present-day contradictions, and the direct coupling to `项目发布` and
  `项目展示` after the earlier diagnosis drifted from the live codebase.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_ruling_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/exhibition_workbench_summary_baseline_addendum.md
  - docs/00_ssot/project_visibility_boundary_freeze_addendum.md
  - docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_showcase_filter_and_project_create_form_refactor_bff_aggregation_app_facing_surface_freeze_addendum.md
  - docs/04_frontend/project_showcase_filter_and_project_create_form_refactor_frontend_consumption_freeze_addendum.md
  - packages/contracts/src/generated/app-api.types.ts
  - packages/contracts/openapi/openapi.bundle.json
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_source.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/order_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/milestone_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/inspection_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart
  - apps/mobile/lib/features/messages/data/messages_registered_entry_registry.dart
  - apps/mobile/test/exhibition_home_test.dart
  - apps/mobile/test/exhibition_mainline_flow_test.dart
  - apps/mobile/test/inspection_phase3_test.dart
  - apps/mobile/test/dispute_entry_test.dart
  - apps/mobile/test/shell_app_test.dart
  - apps/bff/src/routes/routes.module.ts
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/bff/src/routes/exhibition_workbench/exhibition-workbench.service.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/project/project.service.ts
  - apps/bff/src/routes/my_project/my-project.controller.ts
  - apps/bff/src/routes/my_project/my-project.service.ts
  - apps/bff/src/routes/bid/app-bid.controller.ts
  - apps/bff/src/routes/bid/bid.service.ts
  - apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts
  - apps/bff/src/routes/trading_read_corridor/trading-read-corridor.service.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.controller.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/project/project.presenter.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
  - apps/server/src/modules/bid/bid.controller.ts
  - apps/server/src/modules/bid/bid-write.service.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.query.service.ts
---

# 《发布项目工作台及延伸功能全链 code-layer rerun 诊断单》

## 1. Scope

- 本单只回答当前 live codebase 的三个问题：
  - `发布项目工作台` 真实接通到了哪一层
  - 它与 `项目发布 / 项目展示` 之间当前还卡着哪些代码级断点
  - 下一轮修复为什么不能再沿用上一版过时诊断
- 本单不是：
  - implementation unlock
  - direct implementation
  - integration
  - release-prep

## 2. 当前真实链路结论

- 当前真正已接通的主链不是零实现。
- 但它也绝不是 `发布项目工作台及延伸功能全链` 全量闭环。
- 当前 live code 更准确的结论是：
  1. `project_chain` 已形成真实 runtime：
     - `GET /api/app/exhibition/workbench`
     - `POST /api/app/project/create`
     - `GET /api/app/project/list`
     - `GET /api/app/project/detail`
     - `GET /api/app/my/projects`
     - `GET /api/app/my/projects/{projectId}`
  2. `order / fulfillment` 当前只有 read corridor 真接通：
     - `GET /api/app/order/detail`
     - `GET /api/app/contract/detail`
     - `GET /api/app/milestone/list`
     - `GET /api/app/inspection/detail`
  3. workbench 页面仍以“四容器工作台”形态消费：
     - 项目承接
     - 订单承接
     - 履约承接
     - 边界能力
  4. 但 `Server` workbench 真值现在只填满了 `project_chain`；
     另外三容器在真实返回里仍是空壳 carrier。

## 3. 当前阻断项

### 3.1 P0: 项目展示筛选链未打通到 `Server`

- `mobile` 列表页已经正式消费：
  - `provinceCode`
  - `cityCode`
  - `areaBucket`
  - `budgetBucket`
- `BFF` 也已显式承接并转发这些 query。
- 但 `Server.project.listProjects()` 当前完全不接 query 参数，只返回全部已发布项目。
- 这会直接造成：
  - “项目展示”页面看似支持筛选
  - 实际筛选真义没有落到 `Server`
  - `发布项目工作台 -> 项目展示` 的联动判断缺少真实展示面回读

证据：
- `apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart`
- `apps/bff/src/routes/project/app-project.controller.ts`
- `apps/bff/src/routes/project/project.service.ts`
- `apps/server/src/modules/project/project.controller.ts`
- `apps/server/src/modules/project/project-query.service.ts`
- `docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md`
- `docs/03_bff/project_showcase_filter_and_project_create_form_refactor_bff_aggregation_app_facing_surface_freeze_addendum.md`
- `docs/04_frontend/project_showcase_filter_and_project_create_form_refactor_frontend_consumption_freeze_addendum.md`

### 3.2 P0: workbench 真 summary 只有 `project_chain`，其余三容器还是空壳

- `Server` workbench query 只真实查了当前组织最近项目与发布资格。
- presenter 仍把：
  - `order_chain`
  - `fulfillment_chain`
  - `extension_boundary`
  全部硬编码为 `null / false / frozen`。
- 但 Flutter 页面和测试继续以“四容器可承接工作台”形态维护。
- 这不是 UI 问题，而是 runtime truth 与消费结构的成熟度错位。

证据：
- `apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts`
- `apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart`
- `apps/mobile/test/exhibition_home_test.dart`

### 3.3 P0: `project/create` 守卫直接依赖 workbench 真值

- 创建页不是独立资格判断。
- 当前它会先读取 `workbench.project_chain.canCreateProject`，再决定是否允许提交。
- 这意味着只要 workbench contract、缓存、真值或文案有漂移，创建页会一起失真。
- 所以“先修项目发布页，再回头修工作台”在当前代码结构里不可行。

证据：
- `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
- `apps/mobile/test/shell_app_test.dart`

### 3.4 P0: workbench contract 带了 `canOpenProjectPool`，但 UI 没把“项目展示/项目池”接出来

- SSOT 明确允许 `project_chain` 具备：
  - `canOpenProjectPool`
  - `open project pool`
- `Server` presenter 也实际返回了该字段。
- Flutter workbench 只渲染：
  - 最近项目承接
  - 发布项目
- 没有把“项目池 / 项目展示”作为 handoff 动作落到工作台上。
- 这正好卡在你要求的“工作台必须和项目发布、项目展示一起正常”这个交汇点。

证据：
- `docs/00_ssot/exhibition_workbench_summary_baseline_addendum.md`
- `docs/00_ssot/project_visibility_boundary_freeze_addendum.md`
- `apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart`

### 3.5 P1: 路由和生成合同已经收缩，但 mobile 内部 command family 还没收干净

- 当前 `app_router` 已经不再放行：
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/entry`
  - `rating/submit`
  - `dispute/withdraw`
- `shell_app_test` 也明确要求这些路由进入 `RouteUnavailablePage`。
- `packages/contracts/src/generated/app-api.types.ts` 也已经把这些路径从正式 `APP_API_PATHS` 删掉。
- 但 mobile consumer 层、canonical path 常量、contract validation 仍然保留了这些路径与 payload 校验逻辑。
- 这说明当前 repo 已从“前后端都放开”变成“外层已收缩，内层残留没收完”。

证据：
- `apps/mobile/lib/shell/navigation/app_router.dart`
- `apps/mobile/test/shell_app_test.dart`
- `packages/contracts/src/generated/app-api.types.ts`
- `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart`

### 3.6 P1: shell / handoff 路径仍被 mobile 当成真 happy-path POST 在跑

- 本轮 freeze 已把：
  - `milestone/submit`
  - `inspection/submit`
  - `dispute/open`
  定义成 shell / handoff position，而不是“active command family 已闭环”。
- 但当前 mobile 页面与测试仍把它们作为正式提交页和正式成功返回维护。
- 同时 `BFF` 当前与本对象相关的 app-facing controller 实际只有：
  - `workbench`
  - `project`
  - `my-project`
  - `bid`
  - `trading-read-corridor` 四条 GET
- 没有与 `milestone/submit`、`inspection/submit`、`dispute/open` 对等的 app-facing command controller family。

证据：
- `docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md`
- `docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md`
- `apps/mobile/lib/shell/navigation/app_router.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart`
- `apps/mobile/test/inspection_phase3_test.dart`
- `apps/mobile/test/dispute_entry_test.dart`
- `apps/bff/src/routes/routes.module.ts`
- `apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts`

### 3.7 P1: `bid/submit` 仍在真实链路里，但不在本对象 freeze path family 内

- `project/detail` non-owner 继续通过“继续竞标”进入 `bid/submit`。
- `mobile`、`BFF`、`Server` 都仍保留了真实 `bid/submit` 实现。
- 但当前“发布项目工作台及延伸功能全链” freeze 文书并没有把 `bid/submit` 纳入 canonical path family。
- 这意味着：
  - 当前 repo 里仍有一条与项目展示强耦合的旁支主链
  - 它会继续把对象边界从 `publish-workbench` 拉向 `bid -> order`

证据：
- `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart`
- `apps/mobile/test/exhibition_mainline_flow_test.dart`
- `apps/bff/src/routes/bid/app-bid.controller.ts`
- `apps/bff/src/routes/bid/bid.service.ts`
- `apps/server/src/modules/bid/bid.controller.ts`
- `apps/server/src/modules/bid/bid-write.service.ts`
- `docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md`

### 3.8 P1: `my-project` 进度投影把冻结外 `disputes / ratings` 又混了回来

- backend freeze 对当前对象明确排除了：
  - `ratings`
  - `disputes`
  持久化族
- 但 `Server.my_project` 当前仍直接查询：
  - `public.disputes`
  - `public.ratings`
  来推导：
  - `afterSalesOrDisputeStatus`
  - `evaluationStatus`
- 这会让 `my-project` 在“继续处理”区把冻结外对象重新混入私域进度。

证据：
- `docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md`
- `apps/server/src/modules/my_project/my-project.query.service.ts`

## 4. 与旧诊断相比已变化的事实

- 旧诊断里有两类结论已经过时，后续不得继续沿用：
  1. “router 仍直接放行所有冻结外路由”
     - 当前不成立
     - 这些路由多数已转为 `route unavailable`
  2. “generated app-api 仍保留全部冻结外路径”
     - 当前不成立
     - 生成路径清单已收缩，但 mobile 内部残留还在

## 5. 当前修复顺序建议

- 第一优先级：
  - 先修 `project/list` 筛选真链
  - 再修 workbench 与 `project/create` 的资格联动
- 第二优先级：
  - 决定 `canOpenProjectPool` 是否必须在当前 workbench 落成可见 handoff
- 第三优先级：
  - 清理 mobile 内部残留 command family 与过时 validation
- 第四优先级：
  - 裁定 `bid/submit` 是并入当前对象，还是显式剥离到相邻旁支对象
- 第五优先级：
  - 清理 `my-project` 对 `ratings / disputes` 的越界依赖

## 6. Stage Conclusion

- 当前结论：
  - `Go` for targeted repair planning and repair dispatch
  - `No-Go` for直接声称“发布项目工作台已经完成”
  - `No-Go` for把 `项目展示` 筛选视为已真实接通
  - `No-Go` for把 shell / handoff 页视为完整 command family 已闭环
