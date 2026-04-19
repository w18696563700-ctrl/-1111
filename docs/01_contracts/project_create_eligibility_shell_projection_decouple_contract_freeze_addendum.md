---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the contract-level change that app-facing shell context may carry the
  minimal project-create eligibility projection while workbench summary keeps
  the old compatibility field for one bounded round.
layer: L2 Contracts
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《项目创建资格 shell projection 脱钩 contract freeze》

## 1. Contract Conclusion

- `GET /api/app/shell/context` 当前正式新增：
  - `projectCreateEligibility.canCreateProject: boolean`
- 该字段当前只承担：
  - app-facing create-entry gate projection
- 该字段当前不承担：
  - 发布资格真值
  - workbench 替代
  - 第二状态机

## 2. Compatibility

- `GET /api/app/exhibition/workbench.project_chain.canCreateProject` 当前继续保留：
  - compatibility fallback only

