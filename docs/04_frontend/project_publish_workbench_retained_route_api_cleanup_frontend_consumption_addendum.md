---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter-side consumption cleanup after the retained exhibition
  workbench compatibility shell is finally removed from the registered route
  graph.
layer: L5 Frontend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_retained_route_api_cleanup_stage_gate_checklist_addendum.md
  - docs/01_contracts/project_publish_workbench_retained_route_api_cleanup_contract_addendum.md
  - docs/03_bff/project_publish_workbench_retained_route_api_cleanup_bff_surface_addendum.md
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
---

# 《发布项目工作台 Retained Route + API Cleanup Frontend Consumption Freeze》

## 1. Frontend Conclusion

- Flutter 当前正式删除：
  - registered route `/exhibition/workbench`
  - compatibility shell `项目续接`
  - workbench summary demo fallback
  - workbench summary consumer / cache / view-model family

## 2. Current Effective Continuation Faces

- owner-private continuation 当前只允许通过：
  - `我的项目`
  - `我的项目详情`
  - `项目编辑`
  - `项目详情`
  - 已冻结的 downstream trading pages
- create gate 当前只允许通过：
  - `shellContext.projectCreateEligibility`

## 3. Route Deletion Rule

- 旧 deep link `/exhibition/workbench` 删除后必须进入：
  - `route unavailable`
- Flutter 不得把旧 route 静默改跳到：
  - `showcase`
  - `project create`
  - `my-project`

## 4. Explicit Non-goals

- 本轮不影响：
  - enterprise display workbench
  - exhibition home ordered marketplace
  - project attachment / public-resource zone authority
