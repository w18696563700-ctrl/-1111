---
owner: Codex 总控
status: frozen
purpose: >
  Submit the formal stage gate checklist for the bounded cleanup round that
  removes the last retained publish-workbench compatibility route and API
  family after bid-award residual and project-create fallback have already been
  cleared.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_final_cleanup_dependency_inventory_addendum.md
  - docs/00_ssot/project_publish_workbench_bid_award_residual_cleanup_execution_receipt_addendum.md
  - docs/00_ssot/project_publish_workbench_project_create_fallback_cleanup_execution_receipt_addendum.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_ruling_addendum.md
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.controller.ts
---

# 《发布项目工作台 Retained Route + API Cleanup 阶段门禁核查表》

## 1. Stage Objective

- 当前唯一目标固定为：
  - 删除 retained route `/exhibition/workbench`
  - 删除 retained app-facing API `GET /api/app/exhibition/workbench`
  - 删除 mobile compatibility shell 与其 consumer/runtime family
  - 删除 BFF / Server `exhibition_workbench` compatibility module family
  - 收口直接相关测试与 formal truth
- 当前明确非目标：
  - 重开 `project_create` fallback
  - 重开 `BidAward` residual cleanup
  - 触碰 `enterprise-hub/workbench`
  - 移动 `项目详情文书区`
  - 移动 `公共资源下载区`

## 2. Passed Gates

- `owner primary continuation gate` 通过：
  - `我的项目 / 我的项目详情 / 项目详情 / 真实交易页` 已是主承接
- `bid-award residual cleanup gate` 通过：
  - `BidAward bridge` 的 retained workbench refresh 已移除
- `project create fallback cleanup gate` 通过：
  - 创建资格当前只认 `shellContext.projectCreateEligibility`
- `compatibility remainder isolation gate` 通过：
  - 当前最后残留已收敛到 route + API family 本身

## 3. Failed Gates

- `retained route zeroing gate` 当前失败：
  - `ExhibitionRoutes.workbench` 与 `app_router.dart` 注册仍存在
- `retained mobile consumer zeroing gate` 当前失败：
  - Flutter 仍保留 `loadWorkbench()`、compatibility shell、demo fallback 与 cached summary family
- `retained BFF route zeroing gate` 当前失败：
  - `GET /api/app/exhibition/workbench` 仍存在
- `retained Server truth route zeroing gate` 当前失败：
  - `/server/exhibition/workbench` 仍存在
- `direct test closure gate` 当前失败：
  - 多组 mobile / BFF / Server 测试仍直接 mock、assert、instantiate retained workbench family

## 4. Veto Gates

- 当前不得触碰：
  - `GET /api/app/exhibition/enterprise-hub/workbench`
  - enterprise display workbench Flutter / BFF / Server family
- 当前不得把已拆出的主承接重新回流到：
  - workbench summary
  - compatibility shell
  - 第二私域 dashboard
- 当前不得把本轮扩大成：
  - forum / enterprise hub unrelated cleanup
  - project detail attachment/public-resource boundary rollback
  - release-prep

## 5. Stage Decision

- `Go`：
  - bounded docs + mobile + BFF + Server cleanup for retained route/API hard delete
- `No-Go`：
  - enterprise-hub workbench cleanup
  - unrelated route-family cleanup
  - scope expansion beyond direct tests and direct consumers
