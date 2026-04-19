---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded Flutter-only implementation dispatch for round-2 retitling
  of the retained workbench compatibility shell.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_split_round2_compat_shell_retitle_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_workbench_split_round2_compat_shell_retitle_ruling_addendum.md
  - docs/04_frontend/project_publish_workbench_split_round2_compat_shell_retitle_frontend_consumption_addendum.md
---

# 《发布项目工作台拆分第二轮兼容壳改名前端实施派发表》

## 1. Allowed Files

- `apps/mobile/lib/features/exhibition/presentation/exhibition_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_workbench_view_model_text.dart`
- `apps/mobile/lib/shell/navigation/app_router.dart`
- `apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart`
- `apps/mobile/test/**` 中与 retained workbench title/copy 直接相关的最小测试

## 2. No-touch Files

- `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_panels.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_attachment_support.dart`
- `apps/bff/**`
- `apps/server/**`
- `docs/01_contracts/**`

## 3. Acceptance

- 用户主体验名不再把 retained route 叫成 `发布项目工作台`。
- workbench route 仍然可以打开。
- `canCreateProject` 依赖不被破坏。
- `我的项目详情` 中 `项目详情文书区` 与 `公共资源下载区` 归属不变。
