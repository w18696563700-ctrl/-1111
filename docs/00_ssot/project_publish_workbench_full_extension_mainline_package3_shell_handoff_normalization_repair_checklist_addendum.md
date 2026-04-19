---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the detailed repair checklist for `发布项目工作台 / Package 3 /
  shell / handoff normalization`, constraining the current fix scope to
  `milestone/submit`、`inspection/submit`、`dispute/open` 的 shell /
  handoff posture normalization while keeping Package 4 closed.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/00_ssot/exhibition_workbench_summary_baseline_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_freeze_landing_assessment_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_package2_order_fulfillment_carrier_closure_repair_checklist_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart
  - apps/bff/src/routes/routes.module.ts
  - apps/server/src/app.module.ts
---

# 《发布项目工作台 Package 3 shell / handoff normalization 细化修复清单》

## 1. Scope

- 当前 package 只限：
  - `发布项目工作台 / Package 3 / shell / handoff normalization`
- 本清单只回答：
  - `milestone/submit`
  - `inspection/submit`
  - `dispute/open`
  应该如何从“前端像真命令、后端像占位”收口为 freeze 允许的 shell /
  handoff posture
- 本清单不是：
  - implementation unlock
  - root-guardrail exception unlock
  - 新交易主链扩面
  - active command write closure
  - 第二履约状态机
  - `rating / dispute` 完整业务闭环
  - admin / governance / moderation backend
  - release-prep
  - production release

## 2. Package 3 唯一目标

- 当前 package 唯一目标只有一条：
  - 让
    - `POST /api/app/milestone/submit`
    - `POST /api/app/inspection/submit`
    - `POST /api/app/dispute/open`
    从“缺少 app-facing shell truth owner，且 Flutter 页面误写成 active write”
    收口为“有真实 shell / handoff surface、但不拥有第二业务状态推进”的同一语义
- 当前 package 只允许解决：
  - shell / handoff controller 缺口
  - accepted surface 与 controlled failure normalization
  - shell page posture
  - contract validation 与 accepted payload 的一致性
- 当前 package 不允许解决：
  - `orders / milestones / inspections / disputes` 持久化写入
  - 任何新 truth table materialization
  - `inspection/recheck`
  - `dispute/withdraw`
  - `rating/submit`
  - `my-project` 越界清理

## 3. 当前 package 边界

### 3.1 允许处理的文件族

- `docs/00_ssot/project_publish_workbench_full_extension_mainline_freeze_landing_assessment_addendum.md`
- `docs/00_ssot/project_publish_workbench_full_extension_mainline_package3_shell_handoff_normalization_repair_checklist_addendum.md`
- `docs/00_ssot/source_of_truth_map.md`
- `docs/01_contracts/openapi.yaml`
- `apps/server/src/modules/trading_shell_handoff/**`
- `apps/server/src/app.module.ts`
- `apps/bff/src/routes/trading_shell_handoff/**`
- `apps/bff/src/routes/routes.module.ts`
- `apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart`
- `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart`
- 与上述直接相关的最小测试：
  - `apps/server/test/project-publish-eligibility.test.cjs`
  - `apps/mobile/test/inspection_phase3_test.dart`
  - `apps/mobile/test/dispute_entry_test.dart`
  - `apps/mobile/test/phase23_entry_test.dart`
  - `apps/mobile/test/shell_app_test.dart`

### 3.2 明确禁止处理的文件族

- `apps/server/src/modules/trading_read_corridor/**`
- `apps/server/src/modules/my_project/**`
- `apps/mobile/lib/features/exhibition/presentation/pages/inspection_recheck_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/dispute_withdraw_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/rating_*`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
- 所有 `enterprise_hub_*` 文件族
- 所有 admin / governance / moderation 文件族

## 4. 当前 package 的修复项

### 4.1 修复项 A: Server 必须拥有三条 shell / handoff truth position

- 问题：
  - 当前 `Server` 没有
    - `milestone/submit`
    - `inspection/submit`
    - `dispute/open`
    的 app-facing 同义 shell controller。
- 必须修成：
  - `Server` 必须提供最小 shell / handoff truth owner：
    - 校验当前 continuation anchor 是否存在
    - 校验当前 anchor 是否仍处于允许 handoff 的最小状态
    - 返回 accepted shell response 或 controlled failure
- 完成定义：
  - 三条 path 不再停留在“Flutter 在发单，但 Server 没有同义 surface”的断链态。

### 4.2 修复项 B: `milestone/submit` 只承认最小 accepted anchor，不推进 milestone truth

- 问题：
  - 当前 Flutter 与历史 tests 容易把它写成里程碑已真实提交。
- 必须修成：
  - `milestone/submit` 的 accepted body 只承认当前 `milestoneId` continuation anchor。
  - 不得在该 path 内推进 milestone state machine。
- 完成定义：
  - `202 accepted` 只代表 shell / handoff 已受理。
  - `milestone` 真状态仍以后续 read-corridor truth 为准。

### 4.3 修复项 C: `inspection/submit` 只承认 inspection anchor readback，不推进 inspection truth

- 问题：
  - 当前 Flutter 页面和 tests 把 `inspection/submit` 写成 inspection 已正式提交。
- 必须修成：
  - `inspection/submit` accepted response 只允许回显当前 inspection anchor 与最小 summary。
  - 不得在该 path 内推进 inspection state machine。
- 完成定义：
  - accepted response 可继续沿用 `inspectionId / milestoneId / state / summary`
    最小字段，但语义必须收回为 shell / handoff accepted。
  - Flutter 不再把 accepted 结果写成 inspection truth 已推进。

### 4.4 修复项 D: `dispute/open` accepted response 不得伪造 dispute truth

- 问题：
  - 当前前端与 tests 把 `dispute/open` 写成真实创建 dispute 并返回 `disputeId`。
- 必须修成：
  - `dispute/open` accepted response 只允许以 `orderId` 为 continuation anchor，
    再附带最小 shell state / summary。
  - 不得伪造新的 `disputeId` 作为 business truth。
- 完成定义：
  - `dispute/open` 从“像真建单”收回到“受理当前订单的争议开启入口”。

### 4.5 修复项 E: BFF 只做同义 surface 与 controlled failure normalization

- 问题：
  - 当前 BFF 没有这三条 app-facing shell controller。
- 必须修成：
  - `BFF` 只负责：
    - 接收三条 app-facing POST
    - 转发到 `Server`
    - 规范 accepted body shape
    - 规范 controlled failure message
  - 不得在 BFF 内形成第二套 eligibility / state selection 逻辑。
- 完成定义：
  - `BFF` 不再是 route drift 占位。
  - 也不成为第二 business owner。

### 4.6 修复项 F: Flutter 页面必须改成 shell / handoff posture

- 问题：
  - 当前三个页面都在用“已提交 / 已开启 / 已完成”的语气讲述 accepted 结果。
- 必须修成：
  - 页面 summary、按钮文案、结果卡片、后续说明
    都必须改成：
    - shell / handoff 已受理
    - 当前页只保留 continuation
    - 当前页不代表 truth 已推进
- 完成定义：
  - route / page existence 继续保留
  - 但页面姿态不再误导成 active write closure

### 4.7 修复项 G: contract validation 必须允许 shell accepted，而不是强推 active truth

- 问题：
  - 当前 mobile validation 对 `dispute/open` 默认要求 `disputeId`，对 accepted 语义过深。
- 必须修成：
  - `milestone/submit`、`inspection/submit`、`dispute/open`
    的 accepted payload validation 必须与 shell / handoff posture 一致。
- 完成定义：
  - 不再因为“accepted 不等于真实建单”而把正确 shell response 判成非法。

### 4.8 修复项 H: 测试只证明 shell normalization，不证明 active write

- 当前 package 允许新增或更新的断言只限：
  - accepted response 已接通
  - accepted body 不再伪造 dispute truth
  - 页面 copy / result posture 已收回 shell / handoff
  - controlled failure 仍保持受控
- 当前 package 不得新增的断言：
  - state 真推进已闭环
  - 新 dispute persistence 已创建
  - inspection 正式提交已完成
  - admin / governance follow-up

## 5. Package 3 明确不做

- 不做 `orders / milestones / inspections / disputes` 真写入
- 不做 `inspection/recheck`
- 不做 `dispute/withdraw`
- 不做 `rating/submit`
- 不做 `my_project` 越界清理
- 不做 `enterprise_hub` 编译修复
- 不做 Package 4 dead-family cleanup

## 6. Package 3 验收口径

- Package 3 只能按以下口径验收：
  1. `milestone/submit`、`inspection/submit`、`dispute/open`
     三条 app-facing POST 都有真实 BFF / Server shell surface
  2. accepted response 明确是 shell / handoff，不是 active write closure
  3. `dispute/open` 不再伪造 `disputeId` 作为 business truth
  4. Flutter 页面、validation、测试与同一 accepted 语义一致
- Package 3 明确不能按以下口径验收：
  - “里程碑提交主链已完成”
  - “验收提交主链已完成”
  - “争议创建主链已完成”
  - “Package 4 已自动打开”

## 7. Package 3 交付物

- 本清单冻结后，唯一允许的下一步是：
  - 按本清单进入 `Package 3 / shell / handoff normalization`
  - 只补三条 shell / handoff surface
  - 只补与其直接相关的最小 validation、page posture、测试
