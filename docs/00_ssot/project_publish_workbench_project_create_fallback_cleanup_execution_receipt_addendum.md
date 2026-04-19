---
owner: Codex 总控
status: frozen
purpose: >
  Record the bounded execution receipt for removing the retained publish-
  workbench fallback from project-create while preserving the retained
  workbench route and API families.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_project_create_fallback_cleanup_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_project_create_fallback_cleanup_implementation_dispatch_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/test/exhibition_mainline_flow_test.dart
  - apps/mobile/test/project_publish_round_a_productization_test.dart
  - apps/mobile/test/project_showcase_filter_create_refactor_test.dart
  - apps/mobile/test/shell_app_test.dart
---

# 《发布项目工作台 Project Create Fallback 清理执行回执》

## 1. 本轮目标

- 只清：
  - `project_create_page.dart` 中的 retained workbench fallback
  - project-create success 后的 retained workbench refresh residual
- 不清：
  - retained route `/exhibition/workbench`
  - retained API `GET /api/app/exhibition/workbench`
  - compatibility shell 自身 copy / route graph

## 2. 实际修改

- 已从
  [project_create_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart)
  删除：
  - shell eligibility 缺失时的 `loadWorkbench(forceRefresh: true)` fallback
  - create/edit 成功后的 retained workbench refresh / invalidation residual
  - `_canCreateProjectFromWorkbench(...)` compatibility helper
- 创建资格当前只读取：
  - `shellContext.projectCreateEligibility.canCreateProject`
- shell eligibility 缺失时当前 fail-closed 为：
  - `当前暂时无法确认创建条件`
  - `当前无法确认当前创建资格，请稍后再试。`
- 已同步更新直接相关测试，使创建链按 shell-context-first 口径承接：
  - [exhibition_mainline_flow_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/exhibition_mainline_flow_test.dart)
  - [project_publish_round_a_productization_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/project_publish_round_a_productization_test.dart)
  - [project_showcase_filter_create_refactor_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/project_showcase_filter_create_refactor_test.dart)
  - [shell_app_test.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test/shell_app_test.dart) 中与 shell create-eligibility directly related 的最小用例

## 3. 通过的核验

- `flutter analyze` 已通过：
  - `project_create_page.dart`
  - `exhibition_mainline_flow_test.dart`
  - `project_publish_round_a_productization_test.dart`
  - `project_showcase_filter_create_refactor_test.dart`
  - `shell_app_test.dart`
- `flutter test` 已通过：
  - `test/exhibition_mainline_flow_test.dart`
  - `test/project_publish_round_a_productization_test.dart`
  - `test/project_showcase_filter_create_refactor_test.dart`
  - `test/shell_app_test.dart --plain-name "project create keeps role guard controlled by shell create-eligibility projection"`

## 4. 当前未并入本轮验收的旧测试债

- `shell_app_test.dart --plain-name "project create"` 当前仍暴露更早的 create-result copy / button / compatibility-shell copy 假设。
- `shell_app_test.dart --plain-name "workbench project chain copy keeps create qualification aligned to canCreateProject truth"` 当前仍在断言更早的 retained workbench copy，不适合作为本轮“只删 create fallback”的验收基线。
- 上述旧测试债未被本轮引入，也未在本轮一起修复。

## 5. 当前结论

- `project create fallback cleanup = passed`
- retained workbench 当前还剩最后一块兼容依赖：
  - `retained route + API`
- 当前仍不得把本轮结论扩大成：
  - route hard delete
  - API hard delete
  - compatibility shell final removal
