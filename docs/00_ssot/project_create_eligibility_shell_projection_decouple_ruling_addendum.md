---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the ruling that project-create eligibility must stop depending on the
  retained workbench summary as the primary mobile carrier and instead move to
  the canonical shell-context projection while preserving one-round fallback.
layer: L0 SSOT
freeze_date_local: 2026-04-14
based_on:
  - AGENTS.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/server/src/modules/shell/shell-query.service.ts
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
---

# 《项目创建资格 shell projection 脱钩总裁决补充单》

## 1. 总结论

- 当前 `project create eligibility` 的唯一真值继续固定为：
  - `CurrentActorEligibilityService.canPublishProjectInScope(scope)`
- 当前 app-facing primary carrier 正式改为：
  - `GET /api/app/shell/context`
    中的 `projectCreateEligibility.canCreateProject`
- 当前 `GET /api/app/exhibition/workbench.project_chain.canCreateProject` 正式降级为：
  - compatibility fallback only
  - 不再作为 `ProjectCreatePage` 的 primary dependency

## 2. Boundary

- 本轮不得：
  - 在 Flutter 中重算最终 create eligibility
  - 新开第二个 project-create eligibility path
  - 删除 workbench route
- 本轮允许：
  - shell context 最小扩展
  - workbench fallback 保留一轮

## 3. Current Priority

- 只要问题落在：
  - project create guard 与 workbench summary 的耦合
  - shell context 新增 create-eligibility projection
- 当前唯一最高优先级文书固定为：
  - `docs/00_ssot/project_create_eligibility_shell_projection_decouple_ruling_addendum.md`
