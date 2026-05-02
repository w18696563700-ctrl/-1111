---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the frontend consumption for reading project-create eligibility from
  shell context first and using workbench summary only as a bounded fallback.
layer: L5 Frontend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_ruling_addendum.md
  - apps/mobile/lib/core/boot/app_shell_context_consumer.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
---

# 《项目创建资格 shell projection 脱钩 frontend consumption freeze》

## 1. Frontend Conclusion

- `ProjectCreatePage` 当前正式先读：
  - `shellContext.projectCreateEligibility.canCreateProject`
- 当前只在 shell projection 缺失时允许：
  - fallback 到 workbench summary

## 2. Hard Rule

- Flutter 当前不得仅用：
  - `organizationId`
  - `roleKeys`
  - `certificationStatus`
  自己生成最终 create eligibility 真值。
