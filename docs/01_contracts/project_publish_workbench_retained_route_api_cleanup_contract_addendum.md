---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the contract-level withdrawal of the retained exhibition private
  workbench route after create eligibility has already been migrated to shell
  context and owner continuation has already migrated to project and
  my-project carriers.
layer: L2 Contracts
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_retained_route_api_cleanup_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_create_eligibility_shell_projection_decouple_ruling_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《发布项目工作台 Retained Route + API Cleanup Contract Freeze》

## 1. Contract Conclusion

- `GET /api/app/exhibition/workbench` 当前正式删除。
- Flutter App 当前不再拥有：
  - exhibition private compatibility-shell summary read path
  - workbench summary contract family
  - `project_chain.canCreateProject` compatibility contract

## 2. Current Effective Carriers

- app-facing create eligibility 当前只允许来自：
  - `GET /api/app/shell/context.projectCreateEligibility.canCreateProject`
- owner-private continuation 当前只允许来自：
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
  - `GET /api/app/project/edit/detail`
  - 真实交易 continuation contract family

## 3. Explicit Non-goals

- 本轮不影响：
  - `GET /api/app/exhibition/enterprise-hub/workbench`
  - enterprise display workbench contract family
  - `project/detail`、`my/projects`、`trading_*` 现有 contract family
