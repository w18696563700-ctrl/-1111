---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L2 contract additions for my-project lifecycle correction,
  introducing canonical withdraw, archive, and close command paths while
  keeping delete draft-only and extending project state consumption to
  `archived`.
layer: L2 Contract
freeze_date_local: 2026-04-13
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/my_project_lifecycle_correction_stage_gate_checklist_addendum.md
  - docs/00_ssot/my_project_lifecycle_correction_ruling_addendum.md
  - docs/00_ssot/lifecycle_state_machine.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
  - apps/server/src/modules/project/project.controller.ts
  - apps/bff/src/routes/project/app-project.controller.ts
  - apps/bff/src/routes/my_project/my-project.controller.ts
---

# 《我的项目生命周期修正规则第二轮 L2 contract freeze》

## 1. Canonical Action Family

- 当前新增 app-facing canonical paths：
  - `POST /api/app/project/withdraw`
  - `POST /api/app/project/archive`
  - `POST /api/app/project/close`
- 当前新增 server truth pairs：
  - `POST /server/projects/withdraw`
  - `POST /server/projects/archive`
  - `POST /server/projects/close`
- 当前继续保留：
  - `DELETE /api/app/my/projects/{projectId}`
  - `DELETE /server/projects/{projectId}`
  但这条 family 继续只服务 `draft`

## 2. Request / Response Freeze

- 三条新增 command path 均复用：
  - request: `ProjectLifecycleActionRequest`
  - success response: `ProjectLifecycleAcceptedResponse`
- accepted response 只允许返回：
  - `projectId`
  - `state`
- 当前不新增：
  - `deletedAt`
  - `archivedAt`
  - `closedAt`
  - `actionMatrix`
  - `canDelete / canClose / canWithdraw`

## 3. State Freeze

- `ProjectState` 当前正式扩展为：
  - `draft`
  - `submitted`
  - `published`
  - `bidding_closed`
  - `awarded`
  - `converted_to_order`
  - `archived`
- 当前新增动作的 accepted state 固定为：
  - `withdraw` => `draft`
  - `archive` => `archived`
  - `close` => `archived`

## 4. My-project Read Contract Correction

- `MyProjectListResponse` 当前正式修正为：
  - `historicalProjects`
    不再只对应 `privateSummary.formalCompletionStatus = formally_completed`
  - 它同时允许承接：
    - formally completed projects
    - owner-archived projects
- `ongoingProjects`
  继续承接 non-archived and not-formally-completed private continuation only

## 5. Error-code Freeze

- 当前新增 route-specific invalid request codes：
  - `PROJECT_WITHDRAW_INVALID`
  - `PROJECT_ARCHIVE_INVALID`
  - `PROJECT_CLOSE_INVALID`
- 当前继续沿用：
  - `PROJECT_INVALID_STATE`
  - `AUTH_PERMISSION_INSUFFICIENT`
  - `AUTH_RESOURCE_UNAVAILABLE`
  - `AUTH_SESSION_INVALID`

