---
owner: Codex 总控
status: frozen
purpose: >
  Record the bounded execution receipt for hard-deleting the last retained
  publish-workbench route and API family after the bid-award residual cleanup
  and project-create fallback cleanup had already passed.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_retained_route_api_cleanup_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_retained_route_api_cleanup_implementation_dispatch_addendum.md
  - docs/01_contracts/project_publish_workbench_retained_route_api_cleanup_contract_addendum.md
  - docs/02_backend/project_publish_workbench_retained_route_api_cleanup_backend_truth_addendum.md
  - docs/03_bff/project_publish_workbench_retained_route_api_cleanup_bff_surface_addendum.md
  - docs/04_frontend/project_publish_workbench_retained_route_api_cleanup_frontend_consumption_addendum.md
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/bff/src/routes/routes.module.ts
  - apps/server/src/app.module.ts
---

# 《发布项目工作台 Retained Route + API Cleanup 执行回执》

## 1. 本轮目标

- 已执行：
  - hard delete retained route `/exhibition/workbench`
  - hard delete retained app-facing API `GET /api/app/exhibition/workbench`
  - hard delete retained truth route `/server/exhibition/workbench`
  - hard delete mobile compatibility shell / summary consumer / cache / demo fallback family
  - hard delete obsolete `BFF` / `Server` exhibition-workbench module family
- 未执行：
  - `enterprise-hub/workbench` family cleanup
  - `我的项目 / 我的项目详情 / 项目详情 / 真实交易页` 主链语义变更
  - unrelated forum / enterprise-hub / 文书区 / 公共资源下载区 cleanup

## 2. 实际修改

- formal truth 已冻结：
  - `docs/01_contracts/openapi.yaml`
  - `docs/04_frontend/ui_state_contract.md`
  - `docs/04_frontend/flutter_screen_map.md`
  - 当前轮 `contracts / backend / bff / frontend` addendum
- Flutter 已删除：
  - [exhibition_routes.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart) 中 retained `workbench` route constant
  - [app_router.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/shell/navigation/app_router.dart) 中 retained route registration / title branch
  - [exhibition_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart) 与
    [exhibition_load_service.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart)
    中 exhibition workbench summary consumer / cache / invalidation family
  - [exhibition_canonical_paths.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart) 中 retained canonical path constant
  - compatibility shell / mapper / validator / view-model / demo fallback files
- BFF 已删除：
  - `apps/bff/src/routes/exhibition_workbench/**`
  - `routes.module.ts` 中 obsolete module registration
- Server 已删除：
  - `apps/server/src/modules/exhibition_workbench/**`
  - `app.module.ts` 中 obsolete module registration
- 直接相关测试已收口为当前真实 carrier：
  - mobile `shell_app_test.dart`
  - BFF `rating-entry-submit.test.cjs`
  - BFF `trading-shell-handoff-submit-error-cleanup.test.cjs`
  - Server `project-publish-eligibility.test.cjs`
  - Server `rating-entry-submit.test.cjs`

## 3. 残留扫描结论

- repo source 扫描后，exhibition 主线已不再残留：
  - `ExhibitionRoutes.workbench`
  - `ExhibitionCanonicalPaths.exhibitionWorkbench`
  - exhibition compatibility `loadWorkbench()` / `invalidateWorkbench()`
  - `ExhibitionWorkbenchService`
  - `ExhibitionWorkbenchQueryService`
  - `ExhibitionWorkbenchPresenter`
  - `GET /api/app/exhibition/workbench`
- 当前剩余 workbench 命中只属于：
  - `enterprise-hub/workbench` 独立对象链
  - 该对象链在本轮保持 no-touch，符合 stage dispatch

## 4. 通过的核验

- `flutter analyze` 已通过：
  - `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_load_service.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation_base.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
  - `apps/mobile/lib/shell/navigation/app_router.dart`
  - `apps/mobile/lib/dev/visual_demo/visual_demo_app.dart`
  - `apps/mobile/test/shell_app_test.dart`
- `flutter test` 已通过：
  - `test/shell_app_test.dart --plain-name "frozen workbench extension routes enter route unavailable page"`
  - `test/shell_app_test.dart --plain-name "project create blocks certification-not-approved actor before workbench qualification"`
  - `test/shell_app_test.dart --plain-name "project create keeps role guard controlled by shell create-eligibility projection"`
- `node --test` 已通过：
  - `apps/bff/test/rating-entry-submit.test.cjs`
  - `apps/bff/test/trading-shell-handoff-submit-error-cleanup.test.cjs`
  - `apps/server/test/project-publish-eligibility.test.cjs`
  - `apps/server/test/rating-entry-submit.test.cjs`

## 5. 当前结论

- `retained route + API cleanup = passed`
- `发布项目工作台 compatibility shell final technical cleanup = passed`
- exhibition 主线当前不再依赖 retained workbench route、API、consumer、cache、compatibility shell
- 当前仍不得把本轮结论扩大成：
  - `enterprise-hub/workbench` cleanup
  - unrelated scope expansion
  - release-prep judgment
