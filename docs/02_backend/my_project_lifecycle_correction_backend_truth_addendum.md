---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L3 backend truth for my-project lifecycle correction, keeping
  Server as the only lifecycle truth owner for withdraw, archive, close, the
  draft-only delete boundary, and the archived read-side fallout.
layer: L3 Backend
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/my_project_lifecycle_correction_ruling_addendum.md
  - docs/01_contracts/my_project_lifecycle_correction_contract_freeze_addendum.md
  - docs/00_ssot/lifecycle_state_machine.md
  - apps/server/src/modules/project/project.controller.ts
  - apps/server/src/modules/project/project-query.service.ts
  - apps/server/src/modules/project/project-write.service.ts
  - apps/server/src/modules/my_project/my-project.presenter.ts
  - apps/server/src/modules/my_project/my-project.query.service.ts
---

# 《我的项目生命周期修正规则第二轮 L3 backend truth freeze》

## 1. Truth Ownership

- `Server` 是唯一 project lifecycle truth owner。
- `BFF` 不得拥有 project lifecycle state progression。

## 2. Command Truth

- `draft -> delete`
  - 继续保留
  - 不变更当前 delete truth
- `submitted -> draft`
  - 作为 `withdraw` 正式落地
- `submitted -> archived`
  - 作为 `archive` 正式落地
- `published -> archived`
  - 作为 `close` 正式落地
  - 必须同时退出 public showcase corridor
- `awarded / converted_to_order`
  - 当前不得复用 `withdraw / archive / close`
  - 若触发上述动作，必须 fail closed through stable business error

## 3. Persistence Truth

- 当前 persisted carrier 继续只用：
  - `project.state`
  - `project.published_at`
  - `project.summary`
  - `audit_logs`
- 当前 round 不新增：
  - project close table
  - archive snapshot table
  - rollback truth
  - order-close bridge

## 4. Read-side Truth

- public `project` query：
  - `archived` must not be publicly readable
- owner-private `my_project` query：
  - `archived` remains owner-readable
  - archived items must enter `historicalProjects`
- current `my_project.privateProgress`：
  - 继续只派生 trade continuation
  - 不新增第二 lifecycle progress state machine

## 5. Audit Truth

- `withdraw` records `project_withdrawn_to_draft`
- `archive` records `project_archived`
- `close` records `project_closed`
- `delete` remains `project_deleted`

## 6. Migration Conclusion

- 当前结论：`No Migration`
- 原因：
  - `project.state` 当前是 `varchar(32)` carrier
  - 本轮复用已存在的 terminal state `archived`
  - 本轮不新增字段、不改约束、不改索引

