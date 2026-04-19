---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded implementation dispatch for moving project-create
  eligibility primary consumption from retained workbench summary to shell
  context.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_ruling_addendum.md
  - docs/01_contracts/project_create_eligibility_shell_projection_decouple_contract_freeze_addendum.md
  - docs/02_backend/project_create_eligibility_shell_projection_decouple_backend_truth_addendum.md
  - docs/03_bff/project_create_eligibility_shell_projection_decouple_bff_surface_addendum.md
  - docs/04_frontend/project_create_eligibility_shell_projection_decouple_frontend_consumption_addendum.md
---

# 《项目创建资格 shell projection 脱钩实施派发表》

## 1. Allowed Files

- `docs/01_contracts/openapi.yaml`
- `apps/server/src/modules/shell/**`
- `apps/bff/src/routes/shell/**`
- `apps/mobile/lib/core/boot/**`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
- 与上述文件直接相关的最小测试

## 2. Acceptance

- shell context 返回 create-eligibility projection
- `ProjectCreatePage` primary dependency 不再是 workbench summary
- workbench fallback 仍可用
- retained workbench route 和文书区/公共资源区不受影响
