---
owner: Codex 总控
status: frozen
purpose: >
  Submit the formal stage gate checklist for round-1 frontend-only splitting
  of the publish-project workbench, covering only entry removal, copy cleanup,
  guarded rerouting, and compatibility-shell thinning inside apps/mobile.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/project_publish_workbench_split_round1_frontend_executable_change_table_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/bid_submit_guard_support.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_sections.dart
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.query.service.ts
---

# 《发布项目工作台拆分第一轮前端阶段门禁核查表》

## 1. Stage Objective

- 当前唯一目标固定为：
  - 删除 `发布项目工作台` 的一级入口和显性 owner CTA
  - 清理 owner-facing 与 bid guard 中对 workbench 的错误导流文案
  - 把 `/exhibition/workbench` 收成兼容壳
  - 保留创建资格校验与最小续接锚点
- 当前明确非目标：
  - 删除 workbench route
  - 改 BFF / Server / contracts
  - 改 `我的项目详情` 中的 `项目详情文书区`
  - 改 `我的项目详情` 中的 `公共资源下载区`
  - release-prep
  - production release

## 2. Passed Gates

- `同对象门禁` 通过：
  - 当前仍只在 `项目发布对象簇` 内收口
  - 只动 owner-facing frontend 入口、文案、可见性和兼容壳
- `真值不变门禁` 通过：
  - 当前 workbench summary 真值仍由既有 `Server/BFF` 路径提供
  - 当前 round 不需要新增 state、path 或 schema
- `兼容路由门禁` 通过：
  - `ExhibitionRoutes.workbench` 仍可保留
  - `app_router.dart` 仍可保留当前 route 注册
- `创建资格门禁` 通过：
  - `project_create_page.dart` 当前仍可继续读取 workbench 返回的
    `canCreateProject`
- `owner 主面门禁` 通过：
  - `我的项目` 与 `我的项目详情` 已成为 owner continuation 主面
  - 文书区与公共资源区 authority 已单独冻结，不必回流到 workbench

## 3. Failed Gates

- `入口洁净门禁` 当前失败：
  - profile 仍存在 `发布项目工作台` 一级入口
  - 首页空态仍把 workbench 当成 owner fallback
  - owner 公域详情仍直接暴露 `打开发布项目工作台`
- `文案一致性门禁` 当前失败：
  - 创建 guard、bid guard、owner 详情文案仍把 workbench 当成主要去向
- `兼容壳洁净门禁` 当前失败：
  - workbench 页面仍带较重的四容器说明墙与讲解 copy
- `测试断言门禁` 当前失败：
  - 多组测试仍显式断言 `发布项目工作台` 入口、按钮和旧错误文案

## 4. Veto Gates

- 不得删除：
  - `ExhibitionRoutes.workbench`
  - `app_router.dart` 中的 workbench route
  - `project_create_page.dart` 当前对 `canCreateProject` 的读取
- 不得把：
  - `项目详情文书区`
  - `公共资源下载区`
  迁回 workbench
- 不得把 bid guard 一刀切回到同一路由
- 不得改动 `Server/BFF/contracts`

## 5. Stage Decision

- `Go`：
  - docs-only freeze authoring
  - docs 冻结后的 bounded Flutter implementation
- `No-Go`：
  - route deletion
  - backend-first implementation
  - integration / release-prep / production release
