---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the backend truth-side cleanup for removing the obsolete exhibition
  workbench summary route after its compatibility responsibilities have already
  been split into shell context, project, my-project, and downstream trading
  carriers.
layer: L3 Backend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_workbench_retained_route_api_cleanup_stage_gate_checklist_addendum.md
  - docs/01_contracts/project_publish_workbench_retained_route_api_cleanup_contract_addendum.md
  - apps/server/src/modules/exhibition_workbench/exhibition-workbench.controller.ts
  - apps/server/src/app.module.ts
---

# 《发布项目工作台 Retained Route + API Cleanup Backend Truth Freeze》

## 1. Backend Conclusion

- `Server` 当前正式删除：
  - `/server/exhibition/workbench`
  - `modules/exhibition_workbench/**`
- 删除原因固定为：
  - 该 route 已不再承担 current effective truth transport
  - create eligibility 已迁至 shell context projection
  - owner continuation 已迁至 `project / my-project / trading` family

## 2. Remaining Truth Owners

- `Server` 当前仍通过以下 family 承担真实 read/write truth：
  - `shell`
  - `project`
  - `my_project`
  - `trading_read_corridor`
  - `trading_shell_handoff`
  - `rating`
  - `bid / bid_award`

## 3. Explicit Non-goals

- 本轮不删除：
  - enterprise display workbench backend family
  - project / my-project / trading current truth route
