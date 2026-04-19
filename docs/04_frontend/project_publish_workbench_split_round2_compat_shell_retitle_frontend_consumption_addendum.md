---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L5 frontend consumption for round-2 retitling of the retained
  workbench compatibility shell, replacing the remaining user-facing
  publish-workbench naming with project-continuation naming while preserving
  route compatibility and the no-touch boundary on my-project detail zones.
layer: L5 Frontend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_split_round2_compat_shell_retitle_ruling_addendum.md
  - docs/00_ssot/project_detail_document_zone_and_public_resource_download_ruling_addendum.md
  - docs/00_ssot/project_public_resource_download_zone_ruling_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart
  - apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model.dart
  - apps/mobile/lib/shell/navigation/app_router.dart
  - apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart
---

# 《发布项目工作台拆分第二轮兼容壳改名 L5 frontend consumption freeze》

## 1. Frontend Freeze Conclusion

- retained workbench route 当前正式显示为：
  - `项目续接`
- retained workbench route 当前正式定位为：
  - `兼容续接页`

## 2. Visible Copy Rule

- 当前正式允许改成 `项目续接` 的点包括：
  - `ExhibitionPage` loading title
  - `ExhibitionWorkbenchPageViewModel.title`
  - `app_router.dart` title override
  - hidden feature-status card 中的功能名称
  - workbench refresh CTA
- 当前正式允许改成 `当前创建资格` 的点包括：
  - `profile_identity_access_pages.dart` 中面向用户的认证更正文案

## 3. Excluded Family

- 当前正式禁止：
  - 改 workbench route path
  - 造新 `project_continuation` path
  - 删除 workbench route
  - 把 `项目详情文书区` 或 `公共资源下载区` 迁回 workbench
  - 改 BFF / Server / contracts

## 4. Test Expectation Rule

- 直接相关测试当前正式应改成：
  - `发布项目工作台` -> `项目续接`
  - `发布项目工作台加载中` -> `项目续接加载中`
  - `回到发布项目工作台` 旧断言继续清空
- `findsNothing` 断言当前仍可保留在：
  - 一级入口
  - owner CTA
  - homepage 回流按钮

