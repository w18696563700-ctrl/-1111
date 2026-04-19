---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded implementation dispatch for removing the last retained
  publish-workbench route and API family across Flutter, BFF, Server, and
  direct tests only.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_retained_route_api_cleanup_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_final_cleanup_dependency_inventory_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart
  - apps/bff/src/routes/routes.module.ts
  - apps/server/src/app.module.ts
---

# 《发布项目工作台 Retained Route + API Cleanup 实施派工单》

## 1. Allowed Scope

- 只允许修改：
  - `docs/00_ssot/source_of_truth_map.md`
  - 当前轮 `stage gate / implementation dispatch / execution receipt`
  - 当前轮 `contracts / backend / bff / frontend` addendum
  - `docs/01_contracts/openapi.yaml`
  - `docs/04_frontend/ui_state_contract.md`
  - `docs/04_frontend/flutter_screen_map.md`
  - `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
  - `apps/mobile/lib/shell/navigation/app_router.dart`
  - `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
  - `apps/mobile/lib/features/exhibition/data/services/exhibition_*workbench*.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_page*.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_*.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
  - `apps/mobile/lib/dev/visual_demo/visual_demo_app.dart`
  - direct mobile tests that still mock or navigate retained workbench
  - `apps/bff/src/routes/routes.module.ts`
  - `apps/bff/src/routes/exhibition_workbench/**`
  - direct BFF tests that instantiate `ExhibitionWorkbenchService`
  - `apps/server/src/app.module.ts`
  - `apps/server/src/modules/exhibition_workbench/**`
  - direct Server tests that instantiate `ExhibitionWorkbenchQueryService`

## 2. Required Changes

- 必须删除：
  - retained route `/exhibition/workbench`
  - retained app-facing API `GET /api/app/exhibition/workbench`
  - retained truth route `/server/exhibition/workbench`
  - mobile compatibility shell、demo fallback、workbench summary consumer、cache、contract validation family
- 必须保留：
  - `shell/context.projectCreateEligibility` 作为唯一 app-facing create gate projection
  - `我的项目 / 我的项目详情 / 项目详情 / 交易页` 作为真实 continuation carrier
  - `enterprise-hub/workbench` 全家桶不动
- `/exhibition/workbench` 旧 deep link 删除后必须进入：
  - unknown route / route unavailable
  - 不得静默改跳 `showcase`、`my-project`、`project-create`

## 3. Explicit No-Touch Boundary

- 不得修改：
  - `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart`
  - `apps/bff/src/routes/enterprise_hub/**`
  - `apps/server/src/modules/enterprise_hub/**`
  - `项目详情文书区`
  - `公共资源下载区`
  - 当前真实交易页的主 carrier 语义

## 4. Acceptance

- repo source 中不再存在：
  - `ExhibitionRoutes.workbench`
  - `ExhibitionCanonicalPaths.exhibitionWorkbench`
  - `loadWorkbench()` / `invalidateWorkbench()` for exhibition compatibility shell
  - `apps/bff/src/routes/exhibition_workbench/**`
  - `apps/server/src/modules/exhibition_workbench/**`
- `openapi.yaml` 不再暴露：
  - `/api/app/exhibition/workbench`
- 旧 `/exhibition/workbench` 导航进入受控 unavailable
- 直接相关测试完成收口，并只验证当前真实主链
