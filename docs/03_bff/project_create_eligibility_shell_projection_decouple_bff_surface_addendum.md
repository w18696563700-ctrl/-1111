---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF surface change for the new shell-context create-eligibility
  projection, requiring pass-through validation only and forbidding any BFF
  owned truth.
layer: L4 BFF
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_ruling_addendum.md
  - apps/bff/src/routes/shell/shell.service.ts
---

# 《项目创建资格 shell projection 脱钩 BFF surface freeze》

## 1. BFF Conclusion

- BFF 当前正式允许在 `shell/context` 中透传：
  - `projectCreateEligibility.canCreateProject`
- BFF 当前正式不得：
  - 改写该资格真值
  - 用 shell context 生成第二资格状态机

