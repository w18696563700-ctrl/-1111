---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the detailed repair checklist for `发布项目工作台 / Package 2 /
  order / fulfillment carrier closure`, constraining the current fix scope to
  minimal real carrier projection for `order_chain` and `fulfillment_chain`
  while keeping Packages 3-4 closed.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_truth_boundary_freeze_addendum.md
  - docs/00_ssot/exhibition_workbench_summary_baseline_addendum.md
  - docs/01_contracts/project_publish_workbench_full_extension_mainline_contract_freeze_addendum.md
  - docs/02_backend/project_publish_workbench_full_extension_mainline_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_publish_workbench_full_extension_mainline_bff_surface_freeze_addendum.md
  - docs/04_frontend/project_publish_workbench_full_extension_mainline_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_freeze_landing_assessment_addendum.md
  - docs/00_ssot/project_publish_workbench_full_extension_mainline_package1_workbench_truth_alignment_repair_checklist_addendum.md
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.presenter.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.query.service.ts
  - apps/server/src/modules/trading_read_corridor/trading-read-corridor.presenter.ts
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/bff/src/routes/exhibition_workbench/exhibition-workbench.service.ts
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_source.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/mobile/test/exhibition_home_test.dart
---

# 《发布项目工作台 Package 2 order / fulfillment carrier closure 细化修复清单》

## 1. Scope

- 当前 package 只限：
  - `发布项目工作台 / Package 2 / order / fulfillment carrier closure`
- 本清单只回答：
  - Package 2 要补哪些真实 carrier
  - 哪些 carrier 允许从既有 read-corridor truth 投影
  - 哪些能力仍必须留给 Package 3 / 4
- 本清单不是：
  - implementation unlock
  - root-guardrail exception unlock
  - 新交易主链扩面
  - shell active-command 化
  - admin / governance / reporting backend
  - release-prep
  - production release

## 2. Package 2 唯一目标

- 当前 package 唯一目标只有一条：
  - 让 `workbench.order_chain / fulfillment_chain` 从“容器存在但真值空壳”
    收口为“基于现有 read-corridor truth 的最小真实 continuation carrier”
- 当前 package 只允许解决：
  - `activeOrderId`
  - `activeOrderNo`
  - `activeOrderState`
  - `activeMilestoneId`
  - `activeMilestoneTitle`
  - `inspectionState`
  - 与上述同一 anchor 对齐的最小布尔位
- 当前 package 不允许解决：
  - `order/create`
  - `contract/confirm`
  - `contract/amend`
  - `milestone/submit` 与 `inspection/submit` 的 active write closure
  - `inspection/recheck`
  - `rating/submit`
  - `dispute/withdraw`

## 3. 当前 package 边界

### 3.1 允许处理的文件族

- `apps/server/src/modules/exhibition_workbench/**`
- `apps/bff/src/routes/exhibition_workbench/**`
- 与 workbench summary shape 直接对齐的最小 supporting touch
- 与 workbench summary 直接相关的最小测试：
  - `apps/mobile/test/exhibition_home_test.dart`
  - `apps/server/test/project-publish-eligibility.test.cjs`

### 3.2 明确禁止处理的文件族

- `apps/server/src/modules/trading_read_corridor/**` 的 app-facing route 扩面
- `apps/server/src/modules/my_project/**`
- `apps/mobile/lib/features/exhibition/presentation/pages/milestone_submit_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/inspection_submit_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/dispute_open_page.dart`
- `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_entry_contract_validation.dart`
- 所有 `enterprise_hub_*` 文件族
- 所有 admin / governance / moderation 文件族

## 4. 当前 package 的修复项

### 4.1 修复项 A: `activeOrderId` 从真实 active order truth 投影

- 问题：
  - 当前 `workbench.presenter` 把 `activeOrderId` 固定返回 `null`。
- 必须修成：
  - `activeOrderId`、`activeOrderNo`、`activeOrderState`
    必须来自当前 organization scope 下真实可见的 active order truth。
- 完成定义：
  - workbench 在存在 active order 时返回真实 order carrier。
  - workbench 在不存在 active order 时继续 fail-closed 为 `null / false`。

### 4.2 修复项 B: `order_chain` 布尔位和同一 anchor 对齐

- 问题：
  - 当前 `canOpenOrderDetail / canOpenContractDetail / canOpenDisputeOpen`
    全部是 presenter 空壳。
- 必须修成：
  - `canOpenOrderDetail` 只跟随 `activeOrderId`。
  - `canOpenContractDetail` 只在当前 active order 下存在可见 contract truth 时开放。
  - `canOpenDisputeOpen` 只在当前 active order continuation anchor 存在时开放。
- 完成定义：
  - 不再出现“没有 activeOrderId 但布尔位漂浮”的状态。

### 4.3 修复项 C: `activeMilestoneId` 从同一 active order 下的真实 milestone truth 投影

- 问题：
  - 当前 `fulfillment_chain` 全量空壳。
- 必须修成：
  - `activeMilestoneId` 与 `activeMilestoneTitle`
    必须来自当前 active order 下真实可见的 continuable milestone truth。
- 完成定义：
  - workbench 在存在 continuable milestone 时返回真实 milestone carrier。
  - 未命中时继续返回 `null / false`，不伪造履约承接实例。

### 4.4 修复项 D: `inspectionState` 与 inspection read truth 对齐

- 问题：
  - 当前 `inspectionState` 固定为 `null`。
- 必须修成：
  - `inspectionState` 只允许投影当前 active milestone 下的 current inspection truth indicator。
- 完成定义：
  - `inspectionState` 只返回受 freeze 允许的最小状态指示。
  - 不得在 workbench 内形成第二 inspection state machine。

### 4.5 修复项 E: `fulfillment_chain` 布尔位与同一 anchor 对齐

- 问题：
  - 当前 `canOpenMilestoneList / canOpenMilestoneSubmit / canOpenInspectionDetail /
    canOpenInspectionSubmit` 全量空壳。
- 必须修成：
  - `canOpenMilestoneList` 只跟随 `activeOrderId`。
  - `canOpenMilestoneSubmit` 只跟随 `activeMilestoneId`。
  - `canOpenInspectionDetail` 与 `canOpenInspectionSubmit`
    只在当前 active milestone 下存在可见 inspection truth 时开放。
- 完成定义：
  - 不再出现“milestone anchor 有值但相关布尔位仍全 false”的空壳形态。

### 4.6 修复项 F: `extension_boundary` 只允许做同 anchor 的 supporting alignment

- 问题：
  - `extension_boundary.canOpenContractDetail / canOpenDisputeOpen`
    当前仍与 `order_chain` 脱节。
- 必须修成：
  - 若 Package 2 已计算 `activeOrderId` 与对应可见 contract truth，
    则 `extension_boundary` 允许复用同一 anchor 做 supporting alignment。
- 完成定义：
  - `extension_boundary` 不再和 `order_chain` 自相矛盾。
  - 但 `ratingEntryState / disputeWithdrawState` 继续保持原 freeze 边界，不得借机扩面。

### 4.7 修复项 G: BFF 只透传，不拥有第二 carrier 语义

- 问题：
  - 当前 BFF 虽已校验四容器存在，但对 Package 2 没有额外真实约束。
- 必须修成：
  - BFF 只继续保证 shape 完整与 controlled-failure normalization。
  - 不得在 BFF 内新建第二套 `order / fulfillment` 选择逻辑。
- 完成定义：
  - Carrier 选择逻辑只在 Server truth owner。

### 4.8 修复项 H: 最小测试只证明 carrier closure

- 当前 package 允许新增或更新的断言只限：
  - workbench summary 在有真实 order / milestone carrier 时返回非空 anchor
  - 同一 anchor 相关布尔位对齐
  - 无 carrier 时继续 fail-closed
- 当前 package 不得新增的断言：
  - shell active submit 成功
  - dispute write closure
  - admin / governance follow-up

## 5. Package 2 明确不做

- 不做 active submit runtime
- 不做 `trading_read_corridor` 新路由
- 不做 `enterprise_hub` 编译修复
- 不做 `my_project` 跨对象清理
- 不做 Package 3 shell normalization
- 不做 Package 4 dead-family cleanup

## 6. Package 2 验收口径

- Package 2 只能按以下口径验收：
  1. workbench summary 中 `order_chain / fulfillment_chain` 不再是全量空壳
  2. 所有新 carrier 均可回指到既有 `orders / contracts / milestones / inspections` truth
  3. Server 仍是唯一 carrier 选择 owner
  4. 移动端 workbench 页面不需要新增第二套本地推导即可消费这些 carrier
- Package 2 明确不能按以下口径验收：
  - “订单链路已经完成”
  - “履约链路已经完成”
  - “milestone/inspection/dispute submit 已正式通”
  - “可以开始 Package 3 / 4”

## 7. Package 2 交付物

- 本清单冻结后，唯一允许的下一步是：
  - 按本清单进入 `Package 2 / order / fulfillment carrier closure`
  - 只补最小真实 carrier projection
  - 只补与该 projection 直接相关的最小测试或校验
