---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day5-Day6 frontend-only implementation gate for the current
  project create and prepublish-detail experience convergence round, allowing
  only Flutter presentation/copy changes while blocking ordinary create
  payload changes, BFF/Server changes, and any new lifecycle state.
layer: L0 SSOT
freeze_date_local: 2026-04-26
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_create_prepublish_experience_day1_scope_freeze_addendum.md
  - docs/00_ssot/project_create_prepublish_and_factory_bid_day2_flow_brief_addendum.md
  - docs/00_ssot/project_create_day3_create_page_revision_brief_addendum.md
  - docs/00_ssot/project_prepublish_day4_confirmation_flow_brief_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
---

# 《Day5-Day6 前端实现阶段门禁核查表》

## 0. 总结论

Day5-Day6 允许进入 Flutter 前端实现。

当前更稳的方案：

- 只在创建页预算旁放 `明价意向 / 询价意向`，并隐藏创建页 P0-Pay 技术区块。

当前更省成本的方案：

- 不改普通项目创建、保存、提交、发布请求体，不改 BFF / Server / contracts。

当前阶段最适合的方案：

- 用前端文案把“创建页只负责基础信息和预发布入口，预发布详情负责补资料后确认发布”讲清楚。

风险更大的方案：

- 把 `明价 / 询价` 写入 project payload，继续在创建页暴露 trade-task / 诚意金动作，或新增 `prepublish / prepublished` 状态。

## 1. Passed Gates

1. Day1 范围冻结已完成：本轮只收敛创建页和预发布页体验，不改普通创建接口。
2. Day2 流程说明已完成：主线为发布方预发布闭环与工厂竞标报价闭环，创建页不是交易总控台。
3. Day3 创建页方案已完成：预算旁 `明价意向 / 询价意向` 只做页面内意向选择，不成为业务真相。
4. Day4 预发布方案已完成：正式发布确认留在 `我的项目 -> 预发布列表 -> 单项目详情`，只复用现有 `submitted` 与 `publish / withdraw / archive`。
5. 实现层范围已收窄到 Flutter 展示与测试：本地仅有前端，BFF / Server 仍按云上运行真相处理。

## 2. Failed Or Pending Gates

1. 尚未执行 Day5-Day6 Flutter 代码改动。
2. 尚未运行目标 Flutter 回归测试。
3. 尚未执行隧道 + Computer Use 联调；该项必须在本地 Flutter 改动和目标测试通过后再判断是否需要。

## 3. Veto Gates

以下任一情况出现，本阶段立即 No-Go：

1. 修改 `ProjectCreateCommand`、`ProjectSaveCommand` 或 lifecycle action command，使普通请求体新增 `taskType`、`quoteMode`、`isInquiry`、`prepublish` 或类似字段。
2. 创建页仍可触发 P0-Pay trade-task 创建、询价报价单、200 元发单诚意金或服务费预授权。
3. 新增 `prepublish / prepublished / confirmPublish` 状态、路径或本地二态机。
4. 修改 `apps/bff/**`、`apps/server/**`、`packages/contracts/**` 或 OpenAPI 来配合本轮前端文案。
5. 将 `预发布列表` 当成新的业务状态写入请求或持久化字段，而不是 canonical `submitted` 的用户侧文案。

## 4. Allowed Implementation Surface

本阶段仅允许改动：

1. `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
2. `apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart`
3. `apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart`
4. `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
5. 与上述展示变化直接对应的 Flutter widget tests。
6. 本阶段门禁与执行回执文书。

## 5. Required Acceptance Evidence

Day5-Day6 完成后必须记录：

1. 创建页出现预算旁 `报价方式意向`。
2. 创建页不再展示 `P0-Pay 交易任务`、`创建明价竞标单`、`创建询价报价单并拉起发单诚意金`。
3. 普通 create / save / submit 请求体保持不变，不出现 `taskType / quoteMode / isInquiry / prepublish`。
4. 我的项目 / 预发布详情文案明确 `补资料后确认发布`。
5. 预发布详情正式发布确认文案复用 Day4 正文，不新增 Server 状态机。

## 6. Stage Decision

下一阶段结论：

```text
Go for Flutter-only implementation.
No-Go for BFF implementation.
No-Go for Server implementation.
No-Go for contracts/OpenAPI changes.
No-Go for payment/trade-task creation from the create page.
Conditional Go for tunnel/Computer Use verification after local Flutter tests pass.
```
