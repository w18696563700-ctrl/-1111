---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the round-2 ruling for the retained publish-workbench compatibility
  shell, formally renaming the user-facing page identity while preserving the
  route, current create-eligibility dependence, and my-project detail
  authority.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_split_round2_compat_shell_retitle_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_split_round1_frontend_ruling_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
---

# 《发布项目工作台拆分第二轮兼容壳改名前端总裁决补充单》

## 1. Round-2 Conclusion

- 当前保留 route 的 workbench 页面，用户侧正式主体验名改为：
  - `项目续接`
- 当前保留 route 的 workbench 页面，正式定位继续固定为：
  - `compatibility shell`
  - 不恢复 owner 一级入口
  - 不恢复工作台主面 authority

## 2. Retitle Freeze

- Flutter 当前正式允许改名的点包括：
  - page title
  - loading title
  - shell title override
  - feature-card name
  - refresh CTA
  - banner/copy 中直接面向用户的 `发布项目工作台` 旧称
- 当前第二轮不得改：
  - route path
  - route key
  - `canCreateProject` 的取数依赖

## 3. Hard Boundary

- 当前第二轮继续保留：
  - `ExhibitionRoutes.workbench`
  - `app_router.dart` 中 workbench route registration
  - `project_create_page.dart` 通过 workbench summary 读取 `canCreateProject`
- 当前第二轮继续不得改：
  - `我的项目详情` 中 `项目详情文书区`
  - `我的项目详情` 中 `公共资源下载区`
  - `apps/bff`
  - `apps/server`
  - contracts

## 4. User-facing Copy Freeze

- 当前 owner-facing 用户语义正式固定为：
  - `项目续接`
  - `兼容续接页`
  - `当前创建资格`
- 当前正式降级的旧称包括：
  - `发布项目工作台`
  - `发布项目工作台加载中`
  - `发布项目工作台可创建资格`

## 5. Current Priority

- 只要问题落在：
  - workbench retained route 的用户主体验名
  - workbench loading/title/copy retitle
  - 与 `workbench.canCreateProject` 相关的用户侧旧称清理
- 当前唯一最高优先级文书固定为：
  - `docs/00_ssot/project_publish_workbench_split_round2_compat_shell_retitle_ruling_addendum.md`
