---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the detailed repair checklist for `发布项目工作台 / Package 4 /
  boundary and dead-family cleanup`, constraining the current fix scope to
  mobile dead-family residue removal and `my-project` 越界 truth cleanup
  while keeping the already-completed Packages 1-3 closed.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_freeze_landing_assessment_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_package3_shell_handoff_normalization_repair_checklist_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - apps/server/src/modules/my_project/my-project.query.service.ts
  - apps/server/src/modules/my_project/my-project.private-progress.ts
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_stage_demo_catalog.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart
---

# 《发布项目工作台 Package 4 boundary and dead-family cleanup 细化修复清单》

## 1. Scope

- 当前 package 只限：
  - `发布项目工作台 / Package 4 / boundary and dead-family cleanup`
- 本清单只回答两件事：
  - 冻结外命令族在 mobile 里还剩哪些 execution residue，应该如何收掉
  - `my-project` 对 `ratings / disputes` 的越界 truth 读取，应该如何退回已冻住的私域进度语义
- 本清单不是：
  - implementation unlock
  - root-guardrail exception unlock
  - 新交易主链扩面
  - `order / contract / rating / dispute` 重新开放
  - admin / governance / moderation backend
  - release-prep
  - production release

## 2. Package 4 唯一目标

- 当前 package 唯一目标只有两条：
  - 把 mobile 中仍会发起、消费、验证冻结外命令族的实现链彻底收回
  - 把 `my-project` 私域进度重新限定在当前 freeze 认可的 truth family 内
- 当前 package 只允许解决：
  - dead route / dead command / dead validation / dead page residue
  - `my_project` 对 `ratings / disputes` 的直接查询与派生
  - extension boundary 的 boundary-only posture 保持，但不得反推 executable family
- 当前 package 不允许解决：
  - 新增任何 `BFF` / `Server` active write surface
  - 评价提交、争议撤回、合同确认、合同变更、复检重开
  - `my-project` 新增第二套 formal completion state machine

## 3. 当前 package 边界

### 3.1 允许处理的文件族

- `docs/00_ssot/project_publish_workbench_full_extension_mainline_freeze_landing_assessment_addendum.md`
- `docs/00_ssot/project_publish_workbench_full_extension_mainline_package4_boundary_and_dead_family_cleanup_repair_checklist_addendum.md`
- `docs/00_ssot/source_of_truth_map.md`
- `apps/server/src/modules/my_project/my-project.query.service.ts`
- `apps/server/src/modules/my_project/my-project.private-progress.ts`
- `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart`
- `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_stage_demo_catalog.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart`
- 与上述直接相关的最小测试：
  - `apps/server/test/historical-projects-semantics.test.cjs`
  - `apps/mobile/test/shell_app_test.dart`

### 3.2 明确禁止处理的文件族

- `docs/01_contracts/openapi.yaml`
- `apps/server/src/modules/trading_shell_handoff/**`
- `apps/server/src/modules/trading_read_corridor/**`
- `apps/bff/**`
- `apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart`
- 所有 `enterprise_hub_*` 文件族
- 所有 admin / governance / moderation 文件族

## 4. 当前 package 的修复项

### 4.1 修复项 A: mobile 不再保留冻结外命令族执行链

- 问题：
  - 当前 mobile 仍保留
    - command
    - consumer
    - action service
    - load service
    - canonical path
    - contract validation
    - entry validation
    - page
    的整条执行链残留。
- 必须修成：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `inspection/recheck`
  - `rating/entry`
  - `rating/submit`
  - `dispute/withdraw`
  不再作为 current executable family 被 Flutter 工程继续维护。

### 4.2 修复项 B: blocked route 只保留受控不可进入，不再保留真实 page implementation

- 问题：
  - 当前路由层虽然已经挡掉冻结外路径，但 dead page 仍挂在当前 exhibition trade
    library 中。
- 必须修成：
  - blocked route 继续进入 `路由不可用`
  - 但相应 dead page、dead command、dead helper 不再作为当前 live
    library 的组成部分继续维护

### 4.3 修复项 C: validation 只覆盖当前仍被冻结的 executable family

- 问题：
  - 当前 `exhibition_contract_validation` 与
    `exhibition_entry_contract_validation` 仍继续承认冻结外路径。
- 必须修成：
  - success / entry validation 只覆盖当前仍存活的 path
  - dead-family path 不再存在真实 validation 分支

### 4.4 修复项 D: `my-project` 不再读取 `ratings / disputes`

- 问题：
  - 当前 `my-project` 仍直接查
    - `public.disputes`
    - `public.ratings`
  来推导私域正式进度。
- 必须修成：
  - `my-project` 私域进度只建立在当前仍被冻结的
    - order
    - contract
    - milestone
    truth 上
  - 不再通过评价 / 争议真值反推当前 formal-completion / evaluation

### 4.5 修复项 E: `my-project` 保持兼容字段，但语义回退到 freeze 内部

- 问题：
  - 前端当前仍消费 `afterSalesOrDisputeStatus` 与 `evaluationStatus`
    这些兼容字段。
- 必须修成：
  - 不强行打破兼容 carrier
  - 但 server 端不得再通过冻结外 truth 生成这些字段
  - 当前 package 可以保留字段为兼容投影，但值与派生必须回退到 freeze 内部

### 4.6 修复项 F: Package 4 的测试只证明 residue 已清，不证明新主链开放

- 当前 package 允许新增或更新的断言只限：
  - dead route 仍被受控拦截
  - dead-family consumer path 不再存在
  - `my-project` 不再依赖 dispute / rating truth
  - formal completion / evaluation 只由当前仍允许的 truth 派生
- 当前 package 不得新增的断言：
  - 评价提交已重开
  - 争议撤回已重开
  - 合同确认 / 合同变更已重开
  - 复检主链已开放

## 5. Package 4 明确不做

- 不做 `BFF` controller 扩面
- 不做 `Server` 新写链
- 不做 `openapi` contract 改写
- 不做 workbench 四容器新增字段
- 不做任何 admin / governance 配套
- 不做 `enterprise_hub` 编译修复

## 6. Package 4 验收口径

- Package 4 只能按以下口径验收：
  1. 冻结外命令族不再保留 live execution chain
  2. blocked route 继续受控不可进入，但不再保留 dead page implementation
  3. `my-project` 不再直接查 `ratings / disputes`
  4. `my-project` formal completion / evaluation 语义退回当前 freeze 内部
- Package 4 明确不能按以下口径验收：
  - “评价链已完成”
  - “争议撤回已完成”
  - “合同主链已完成”
  - “工作台 extension 已全部开放”

## 7. Package 4 交付物

- 本清单冻结后，唯一允许的下一步是：
  - 按本清单进入 `Package 4 / boundary and dead-family cleanup`
  - 只清冻结外命令族残留
  - 只清 `my-project` 越界 truth 读取
