---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day5-Day6 Flutter frontend execution result for the current
  project create and prepublish-detail experience convergence round, including
  changed surfaces, preserved request/body boundaries, and local verification
  evidence.
layer: L0 SSOT
freeze_date_local: 2026-04-26
inputs_canonical:
  - docs/00_ssot/project_create_prepublish_day5_day6_frontend_implementation_gate_checklist_addendum.md
  - docs/00_ssot/project_create_day3_create_page_revision_brief_addendum.md
  - docs/00_ssot/project_prepublish_day4_confirmation_flow_brief_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart
---

# 《Day5-Day6 前端执行回执》

## 0. 总结论

Day5-Day6 Flutter 前端改动已完成，且未改普通项目请求体、BFF、Server、contracts 或状态机。

当前更稳的结果：

- 创建页只保留预算旁 `明价意向 / 询价意向`，P0-Pay 交易任务区不再从创建页展示入口出现。

当前更省成本的结果：

- 未新增 `taskType / quoteMode / isInquiry / prepublish` 字段，未新增 app-facing path，未改云上 BFF / Server。

当前阶段最适合的结果：

- 我的项目列表引导进入预发布详情；预发布详情承担“补资料后确认发布”的正式动作。

风险更大的路径已拦截：

- 列表或创建页直接创建交易任务、直接拉起 200 元诚意金、直接新增 `prepublish` 状态，均未进入实现。

## 1. Flutter Changes

1. 创建页基础信息区：
   - 在 `预算金额` 旁加入 `报价方式意向`。
   - 选项为 `明价意向 / 询价意向`。
   - 选择只影响当前页面文案提示，不进入 create / save / submit command。

2. 创建页 P0-Pay 收敛：
   - 移除页面 body 对 `P0-Pay 交易任务` 技术区块的展示追加入口。
   - 当前创建页不再展示 `创建明价竞标单`、`创建询价报价单并拉起发单诚意金`。
   - 保留后续 P0-Pay 代码扩展位，但当前无 UI 触发入口。

3. 我的项目入口：
   - `submitted = 预发布列表` 卡片主动作改为 `补资料后确认发布`。
   - 卡片主动作进入我的项目详情，不再在列表卡片上直接执行 publish。

4. 预发布详情：
   - 当前下一步改为 `先补充项目详情文书，再检查无误并正式发布`。
   - 阶段动作区新增 `发布前确认` 提示。
   - publish / withdraw / archive 确认正文按 Day4 冻结稿补强。

## 2. Boundary Evidence

1. 普通创建请求体保持不变：
   - `ProjectCreateCommand.toJson()` 未新增 `taskType / quoteMode / isInquiry / prepublish`。
   - `ProjectSaveCommand` 与 lifecycle action command 未改。

2. 状态机保持不变：
   - 继续使用 canonical `submitted`，用户侧文案为 `预发布列表`。
   - 未新增 `prepublish / prepublished / confirmPublish`。

3. BFF / Server 保持不变：
   - 未修改 `apps/bff/**`。
   - 未修改 `apps/server/**`。
   - 未修改 contracts / OpenAPI。

## 3. Verification

本地验证已完成：

```text
dart format apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart apps/mobile/lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart apps/mobile/test/project_showcase_filter_create_refactor_test.dart apps/mobile/test/my_project_private_carry_test.dart
flutter analyze lib/features/exhibition/presentation/pages/project_create_page.dart lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart lib/features/exhibition/presentation/presentation_support/my_project_stage_support.dart lib/features/exhibition/presentation/pages/my_project_detail_page.dart lib/features/exhibition/presentation/pages/my_project_list_page.dart test/project_showcase_filter_create_refactor_test.dart test/my_project_private_carry_test.dart
flutter test test/project_showcase_filter_create_refactor_test.dart test/my_project_private_carry_test.dart
```

结果：

```text
flutter analyze: No issues found.
flutter test: 26 tests passed.
```

验证备注：

- 验证期间曾有并发 Flutter test/analyze 进程导致 `.dart_tool/package_config.json` 短暂不可读；清理并发进程并重新 `flutter pub get` 后，同一组目标验证通过。
- `flutter pub get` 造成的 `pubspec.lock` 版本副作用已还原，不纳入本轮改动。

## 4. Remaining Gates

1. Cloud tunnel route smoke：本轮未执行。
2. Computer Use 双端联调：本轮未执行。
3. BFF / Server release：本轮 No-Go。

下一步结论：

```text
Go for Day5-Day6 frontend closure.
No-Go for BFF / Server / contract changes.
Conditional Go for later tunnel + Computer Use verification if product wants real runtime screenshot evidence.
```
