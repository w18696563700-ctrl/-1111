---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded Flutter implementation dispatch for removing the retained
  publish-workbench fallback from project-create without touching the retained
  workbench route or API families.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_project_create_fallback_cleanup_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_final_cleanup_dependency_inventory_addendum.md
  - docs/04_frontend/project_create_eligibility_shell_projection_decouple_frontend_consumption_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/test/exhibition_mainline_flow_test.dart
  - apps/mobile/test/project_publish_round_a_productization_test.dart
  - apps/mobile/test/project_showcase_filter_create_refactor_test.dart
  - apps/mobile/test/shell_app_test.dart
---

# 《发布项目工作台 Project Create Fallback 清理实施派工单》

## 1. Allowed Scope

- 只允许修改：
  - `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
  - `apps/mobile/test/exhibition_mainline_flow_test.dart`
  - `apps/mobile/test/project_publish_round_a_productization_test.dart`
  - `apps/mobile/test/project_showcase_filter_create_refactor_test.dart`
  - `apps/mobile/test/shell_app_test.dart`
- 允许最小化补充：
  - `docs/00_ssot/source_of_truth_map.md`
  - 当前轮 execution receipt

## 2. Required Changes

- 必须移除：
  - `project_create_page.dart` 中对
    `loadWorkbench(forceRefresh: true)` 的资格 fallback
  - 创建成功后的 workbench refresh residual
- 必须保留：
  - `shellContext.projectCreateEligibility` 作为唯一 app-facing 创建资格 carrier
  - retained `/exhibition/workbench`
  - retained `GET /api/app/exhibition/workbench`
- shell eligibility 缺失时，必须 fail-closed：
  - 只给受控 blocked copy
  - 不得回退到 workbench

## 3. Explicit No-Touch Boundary

- 不得修改：
  - `app_router.dart`
  - `exhibition_canonical_paths.dart`
  - BFF / Server workbench controllers
  - `项目详情文书区`
  - `公共资源下载区`

## 4. Acceptance

- 创建页成功后不再刷新 retained workbench summary
- 创建页 guard 不再读取 retained workbench summary
- 直接相关测试完成收口：
  - shell-context-first create eligibility
  - no stale workbench refresh assertion
- retained route / API 仍保持可用，但不再是创建页主链依赖
