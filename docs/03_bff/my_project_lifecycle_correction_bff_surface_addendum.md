---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L4 BFF surface for my-project lifecycle correction, adding
  app-facing withdraw, archive, and close transport while keeping delete
  draft-only and forbidding any BFF-owned project lifecycle truth.
layer: L4 BFF
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/my_project_lifecycle_correction_ruling_addendum.md
  - docs/01_contracts/my_project_lifecycle_correction_contract_freeze_addendum.md
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/project/project.controller.ts
  - apps/bff/src/routes/project/project.service.ts
  - apps/bff/src/routes/my_project/my-project.controller.ts
  - apps/bff/src/routes/my_project/my-project.service.ts
---

# 《我的项目生命周期修正规则第二轮 L4 BFF surface freeze》

## 1. Surface Conclusion

- `BFF` 当前新增 app-facing transport only：
  - `POST /api/app/project/withdraw`
  - `POST /api/app/project/archive`
  - `POST /api/app/project/close`
- `BFF` 当前继续保留：
  - `DELETE /api/app/my/projects/{projectId}`
    但仅服务 `draft delete`

## 2. Mapping Rule

- `withdraw` 只 forward to `POST /server/projects/withdraw`
- `archive` 只 forward to `POST /server/projects/archive`
- `close` 只 forward to `POST /server/projects/close`
- `BFF` 不得：
  - 本地推导 project terminal state
  - 本地发明 `withdrawable / closable / archivable`
  - 把 `delete` 改写成新的 lifecycle family

## 3. Response Shaping Rule

- 三条新增 path 的 app-facing accepted response 继续只返回：
  - `projectId`
  - `state`
- 当前不新增本地 action-summary、二次提示字段、或第二 read model。

## 4. Error-normalization Rule

- `PROJECT_WITHDRAW_INVALID`
  => `当前项目撤回参数无效，请检查后再试。`
- `PROJECT_ARCHIVE_INVALID`
  => `当前项目作废归档参数无效，请检查后再试。`
- `PROJECT_CLOSE_INVALID`
  => `当前项目下架关闭参数无效，请检查后再试。`
- `PROJECT_INVALID_STATE`
  必须按 route-specific message 收口，不得把 server 原文直接裸透。

## 5. Read Fallout Rule

- `BFF my_project` 继续只 shape upstream owner-private list/detail truth
- archived item 进入 `historicalProjects` 时，
  `BFF` 只透传 upstream grouping，不本地重算第二历史状态机
