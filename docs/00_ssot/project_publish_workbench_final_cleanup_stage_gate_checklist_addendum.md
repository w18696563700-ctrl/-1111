---
owner: Codex 总控
status: frozen
purpose: >
  Submit the formal stage gate checklist for the final technical cleanup
  inventory of the retained publish-workbench compatibility dependencies,
  covering only bounded docs-only dependency authoring before any hard delete.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_split_round1_frontend_ruling_addendum.md
  - docs/00_ssot/project_publish_workbench_split_round2_compat_shell_retitle_ruling_addendum.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_ruling_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_award_support.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/bff/src/routes/exhibition_workbench/app-exhibition-workbench.controller.ts
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.controller.ts
---

# 《发布项目工作台最终技术清理盘点阶段门禁核查表》

## 1. Stage Objective

- 当前唯一目标固定为：
  - 冻结 `发布项目工作台` 最后一轮技术清理的兼容依赖盘点
  - 明确删除顺序、风险级别、联调要求和测试影响面
  - 把残留依赖拆成三块：
    - `BidAward bridge / workbench refresh`
    - `project_create fallback / canCreateProject compatibility`
    - `retained workbench route + app-facing API`
- 当前明确非目标：
  - 直接删除 route
  - 直接删除 BFF / Server workbench 接口
  - 直接删除创建页 fallback
  - release-prep
  - production release

## 2. Passed Gates

- `owner 主面迁移门禁` 通过：
  - `我的项目 / 我的项目详情` 已完成 owner continuation 主承接
- `文书区边界门禁` 通过：
  - `项目详情文书区` 已独立冻结，不属于 workbench authority
- `公共资源区边界门禁` 通过：
  - `公共资源下载区` 已独立冻结并封账，不属于 workbench authority
- `兼容壳降级门禁` 通过：
  - retained route 当前已降级为 `项目续接` compatibility shell
- `创建资格主 carrier 门禁` 通过：
  - `shellContext.projectCreateEligibility.canCreateProject`
    已升格为 app-facing primary carrier

## 3. Failed Gates

- `BidAward 刷新洁净门禁` 当前失败：
  - `bid_award_support.dart` 成功后仍刷新 `loadWorkbench(forceRefresh: true)`
- `创建 fallback 清零门禁` 当前失败：
  - `project_create_page.dart` 仍保留 workbench fallback 读取
- `route/API 删除门禁` 当前失败：
  - `/exhibition/workbench`
  - `GET /api/app/exhibition/workbench`
  仍是有效兼容依赖
- `测试收口门禁` 当前失败：
  - 多组测试仍直接 mock / assert `GET /api/app/exhibition/workbench`

## 4. Veto Gates

- 在以下任一项未单独收口前，不得直接删除：
  - `project_create_page.dart` 中的 workbench fallback
  - `bid_award_support.dart` 中的 workbench refresh
  - `ExhibitionRoutes.workbench`
  - `GET /api/app/exhibition/workbench`
- 不得把：
  - `项目详情文书区`
  - `公共资源下载区`
  迁回 workbench
- 不得把当前对象扩大成：
  - 全仓 route cleanup
  - 全仓 API cleanup
  - 全仓 production decision

## 5. Stage Decision

- `Go`：
  - docs-only final cleanup dependency inventory authoring
- `No-Go`：
  - immediate route deletion
  - immediate BFF / Server workbench API deletion
  - immediate create fallback deletion
  - immediate bid-award family deletion
