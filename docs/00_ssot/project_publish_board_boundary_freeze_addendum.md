---
owner: Codex 总控
status: draft
purpose: Freeze the board boundary, minimum success corridor, role responsibilities, stage gate result, closure conditions, and next action for the project publish board after the account login and identity board has already been closed.
layer: L0 SSOT
---

# 项目发布板块边界冻结单

## 1. Scope
- This addendum applies only to the `项目发布` board.
- It follows the already accepted board handoff frozen in:
  - `docs/00_ssot/account_identity_board_closure_conclusion_addendum.md`
- This round freezes only:
  - project publish board included scope
  - explicit non-goals
  - minimum success corridor
  - frontend / `BFF` / `Server` responsibility boundary
  - stage gate checklist for the current board-boundary round
  - board closure conditions
  - the next unique action
- It does not by itself:
  - unlock the project publish implementation round
  - approve release
  - rewrite the current development-stage host override
  - reopen `Bid`, `Order`, `Contract`, `Milestone`, `Inspection`, `Rating`, or
    `Dispute`

## 2. Board Included Scope
- The `项目发布` board is limited to the current minimum publish workbench and
  publish command corridor only.
- In-scope entry and continuation surfaces are:
  - exhibition ordered home publish entry
  - exhibition private workbench current create entry
  - project publish workbench route
  - current project create command
  - current upload three-step material intake reused by the publish page
  - current project detail continuation on returned `projectId`
- The current in-scope canonical paths are limited to:
  - `GET /api/app/exhibition/workbench`
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- The current route scope is limited to:
  - `/exhibition`
  - `/exhibition/workbench`
  - `/exhibition/projects/create`
  - `/exhibition/projects/detail`
- The current page-structure truth for publish remains the existing
  five-step workbench transition:
  - `基础信息`
  - `地址与范围`
  - `文件资料`
  - `文字说明与 AI 辅助`
  - `预览、支付与一键发布`
- In the current board, that five-step structure is page guidance truth only.
- It is not yet a dedicated preview, payment, or publish-commit contract family.

## 3. Explicit Non-goals
- No direct entry into the project publish implementation round by this file
  alone
- No new app-facing path
- No new `L2 Contracts`
- No new `L3` consumer family beyond the already frozen paths and routes
- No bid submit implementation round
- No order conversion
- No award, compare, shortlist, or collaboration flow
- No second project publish state machine
- No reinterpretation of `project/create` success into a full `Project` read
  model
- No new attachment-truth family outside the existing
  `init -> direct upload -> confirm` chain
- No preview, payment, or one-click publish settlement truth freeze in this
  round
- No production-release approval
- No change to the current development-stage host and tunnel baseline

## 4. Minimum Success Corridor
- The minimum success corridor for the `项目发布` board is frozen as:
  1. current authenticated actor reaches the publish entry from
     `/exhibition` or `/exhibition/workbench`
  2. frontend enters `/exhibition/projects/create`
  3. frontend collects only the already frozen publish fields and guidance
  4. file materials, if used, must reuse:
     - `POST /api/app/file/upload/init`
     - direct upload
     - `POST /api/app/file/upload/confirm`
  5. frontend submits `POST /api/app/project/create`
  6. success returns HTTP `202` with `projectId` only
  7. frontend continues with the returned `projectId` into
     `GET /api/app/project/detail`
- The corridor starts from a fresh publish attempt inside the current
  development-stage runtime.
- The corridor ends when:
  - the create command is accepted
  - a fresh `projectId` is returned
  - the existing detail page can consume the returned `projectId`
- The minimum corridor does not require:
  - `POST /api/app/bid/submit`
  - `POST /api/app/order/create`
  - any later contract, milestone, inspection, rating, or dispute action

## 5. Frontend Responsibility Boundary
- Frontend owns only the current publish consumer boundary inside
  `Flutter App`.
- Frontend may:
  - expose publish entry from the ordered home and current workbench
  - host `/exhibition/projects/create` as the current publish workbench route
  - use the existing five-step page structure as guidance truth
  - collect only the already frozen request fields:
    - `title`
    - `buildingType`
    - `budgetAmount`
    - `provinceName`
    - `cityName`
    - `districtName` optional
    - `detailAddress`
    - `scopeSummary`
    - `plannedStartAt` optional, format `YYYY-MM-DD`
    - `plannedEndAt` optional, format `YYYY-MM-DD`
    - `description` optional
  - keep the existing current-page guidance only for:
    - PDF drawing upload guidance
    - AI-assist entry guidance
  - reuse the existing upload chain
  - continue to `/exhibition/projects/detail` on returned `projectId`
- Frontend must not:
  - own project truth
  - invent a second publish state machine
  - reinterpret `project/create` success as a full `Project` read projection
  - jump directly into bid, order, or later chain truth under this board
  - create a local `BFF` or local `Server` truth substitute

## 6. BFF Responsibility Boundary
- `BFF` remains the only app-facing aggregation layer for the current publish
  board.
- `BFF` may:
  - shape the current publish entry context from
    `GET /api/app/exhibition/workbench`
  - forward the current `project/create` command
  - shape the minimum accepted response for current Flutter consumption
  - forward the existing upload init and confirm handoff
  - normalize auth, request context, response envelope, and controlled failures
- `BFF` must not:
  - own `Project` business truth
  - own attachment truth
  - create a second publish workflow state machine
  - add a dedicated preview, payment, or publish-commit path family in this
    round
  - expose direct order conversion, award, or collaboration semantics through
    the publish board

## 7. Server Responsibility Boundary
- `Server` remains the only business truth owner for the current publish board.
- `Server` may own only the current minimum truth support required for:
  - project create command acceptance
  - project persistence
  - project detail read on the fresh `projectId`
  - file truth confirmation through `FileAsset` and existing upload confirm
    semantics
  - permission judgement, validation, and append-only audit where required
- `Server` must not:
  - move final business truth or state judgement into `BFF` or frontend
  - reinterpret storage `objectKey` as business truth
  - unlock downstream bid, order, or later-chain execution under this board
  - mix controller, aggregator, and truth-owner responsibilities into a second
    app-facing workflow model

## 8. Stage Gate Checklist

### 8.1 Passed gates
- 真源门禁：
  - the accepted identity-board closure already selected `项目发布` as the next
    active board
  - this board-freeze file is authored under `docs/**`
- 架构边界门禁：
  - the board remains inside the existing `exhibition` building
  - `Flutter App -> BFF -> Server` remains unchanged
  - no hidden building is reopened
- 契约门禁：
  - the board reuses already frozen canonical paths in
    `docs/01_contracts/openapi.yaml`
  - no new `/api/app/*` family is introduced in this round
- 阶段控制门禁：
  - the current round is explicitly limited to `项目发布板块边界冻结轮`
  - it has one board objective and explicit non-goals
  - it does not jump directly into implementation
- 云上运行门禁：
  - the current development-stage runtime baseline continues to follow
    `docs/00_ssot/development_stage_cloud_host_override_addendum.md`
    on `47.108.180.198 / 8080`

### 8.2 Failed gates
- 无当前板块边界冻结轮阻断失败项

### 8.3 Veto gates
- Implementation-stage veto remains:
  - this file freezes board boundary only
  - it does not equal the project publish implementation round
- Release-stage veto remains:
  - development-stage runtime baseline does not equal release approval

### 8.4 Stage go / no-go
- Stage decision:
  - `Go` for the `项目发布板块边界冻结轮`
  - `Go` for preparing the formal project publish dispatch bundle
  - `No-Go` for entering the project publish implementation round by this file
    alone
  - `No-Go` for expanding into bid, order, or later-chain implementation under
    this board

## 9. Board Closure Conditions
- The `项目发布` board may be considered closed only when all of the following
  are present:
  - frontend receipt exists for publish entry, create page, controlled upload
    reuse, and detail continuation
  - `BFF` receipt exists for workbench/project/file boundary support
  - backend receipt exists for project truth, upload confirm truth support,
    validation, and audit support where required
  - the minimum success corridor has evidence on the current development-stage
    runtime `47.108.180.198 / 8080`
  - a fresh `projectId` is produced through `POST /api/app/project/create`
  - `GET /api/app/project/detail` succeeds on that returned `projectId`
  - no new app-facing path, no second state machine, and no downstream chain
    expansion were bundled into the board
  - independent verification returns a passed conclusion for this board

## 10. Next Unique Action
- The next unique action is:
  - issue the formal `项目发布板块派工单`
- That next round may do only:
  - project publish implementation inside the already frozen board boundary
  - frontend / `BFF` / `Server` work strictly scoped to the minimum success
    corridor
  - development-stage verification on the approved host and tunnel baseline
- That next round must not do:
  - bid or order expansion
  - new path family expansion
  - release sign-off
