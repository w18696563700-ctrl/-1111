---
owner: Codex 总控
status: frozen
purpose: >
  Submit the formal stage gate checklist for the bounded cleanup round that
  removes the retained publish-workbench fallback from project-create while
  preserving the retained workbench route and app-facing API families.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_final_cleanup_dependency_inventory_addendum.md
  - docs/00_ssot/project_publish_workbench_bid_award_residual_cleanup_execution_receipt_addendum.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_ruling_addendum.md
  - docs/04_frontend/project_create_eligibility_shell_projection_decouple_frontend_consumption_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
---

# 《发布项目工作台 Project Create Fallback 清理阶段门禁核查表》

## 1. Stage Objective

- 当前唯一目标固定为：
  - 删除 `project_create_page.dart` 对 retained workbench summary 的 compatibility fallback
  - 删除创建成功后的 workbench refresh residual
  - 把创建资格读取收口为 `shellContext.projectCreateEligibility`
  - 保留 retained workbench route、retained workbench API、不动 compatibility shell
- 当前明确非目标：
  - 删除 `/exhibition/workbench`
  - 删除 `GET /api/app/exhibition/workbench`
  - 删除 BFF / Server workbench compatibility family
  - 移动 `项目详情文书区`
  - 移动 `公共资源下载区`

## 2. Passed Gates

- `owner continuation split gate` 通过：
  - owner 主承接已迁至 `我的项目 / 我的项目详情`
- `bid-award residual gate` 通过：
  - `BidAward bridge` 的 workbench refresh residual 已移除
- `create eligibility primary carrier gate` 通过：
  - `shellContext.projectCreateEligibility.canCreateProject`
    已冻结为 app-facing primary carrier
- `retained compatibility gate` 通过：
  - retained route 与 retained app-facing API 仍存在，可作为本轮 no-touch boundary

## 3. Failed Gates

- `project create fallback zeroing gate` 当前失败：
  - `project_create_page.dart` 仍在 shell eligibility 缺失时读取
    `loadWorkbench(forceRefresh: true)`
- `project create success refresh cleanup gate` 当前失败：
  - 创建成功后仍刷新 retained workbench summary
- `create test closure gate` 当前失败：
  - 多组创建链测试仍直接 mock / assert `GET /api/app/exhibition/workbench`

## 4. Veto Gates

- 当前不得直接删除：
  - `/exhibition/workbench`
  - `GET /api/app/exhibition/workbench`
  - BFF / Server workbench controllers
- 当前不得把 shell create-eligibility 缺失重新解释成第二套 truth
- 当前不得把当前对象扩大成：
  - retained route cleanup
  - retained API cleanup
  - workbench final hard delete

## 5. Stage Decision

- `Go`：
  - bounded Flutter cleanup for `project create fallback`
- `No-Go`：
  - retained route deletion
  - retained API deletion
  - compatibility shell hard delete
