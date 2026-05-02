---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the backend truth that shell context may expose project-create
  eligibility only as a projection derived from the same current eligibility
  service, without creating a second carrier or separate state machine.
layer: L3 Backend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_ruling_addendum.md
  - apps/server/src/modules/organization/current-actor-eligibility.service.ts
  - apps/server/src/modules/shell/shell-query.service.ts
---

# 《项目创建资格 shell projection 脱钩 backend truth freeze》

## 1. Backend Truth

- shell context 中的 `projectCreateEligibility.canCreateProject` 必须直接派生自：
  - `CurrentActorEligibilityService.canPublishProjectInScope(scope)`
- Server 不得：
  - 为 shell context 单独发明 create-eligibility 规则
  - 让 shell context 与 workbench summary 出现两套不同资格判定

## 2. Compatibility

- workbench summary 仍可继续输出 `project_chain.canCreateProject`
- 但它当前只作为 fallback compatibility projection
