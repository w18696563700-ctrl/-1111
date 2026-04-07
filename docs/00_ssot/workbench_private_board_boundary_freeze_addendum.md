---
owner: Codex 总控
status: draft
purpose: Freeze the board boundary, non-goals, minimum success corridor, container boundary, guard boundary, role responsibilities, stage gate result, closure conditions, and next action for the workbench private board.
layer: L0 SSOT
---

# 工作台私域板块边界冻结单

## 1. Scope
- This addendum applies only to the `工作台私域` board.
- It follows the already accepted next-board handoff frozen in:
  - `docs/00_ssot/project_showcase_detail_bid_board_closure_conclusion_addendum.md`
- This round freezes only:
  - board included scope
  - explicit non-goals
  - minimum success corridor
  - container boundary
  - guard boundary
  - frontend / `BFF` / `Server` responsibility boundary
  - stage gate checklist for the current board-boundary round
  - board closure conditions
  - the next unique action
- This round does not by itself:
  - unlock the workbench-private implementation round
  - reopen showcase-detail-bid scope
  - reopen `rating/submit`
  - reopen `dispute/withdraw`
  - reopen `inspection/recheck`
  - reopen governance console, history, list, or reporting surfaces
  - create a second workbench state machine
  - create a second dashboard
  - rewrite the current development-stage host override

## 2. Board Included Scope
- The board included scope is limited to:
  - `/exhibition/workbench`
  - `GET /api/app/exhibition/workbench`
  - the four already frozen private summary containers:
    - `project_chain`
    - `order_chain`
    - `fulfillment_chain`
    - `extension_boundary`
  - controlled handoff from those containers into already frozen downstream
    canonical entries only
- The current board reuses only the already frozen continuable instance carriers:
  - `recentProjectId`
  - `activeOrderId`
  - `activeMilestoneId`
  - already frozen boundary-state carriers under `extension_boundary`
- The current board may still display the already frozen summary booleans,
  titles, and state projections, but those remain summary projection only and
  must not become a second truth-owner model.
- The board does not own business truth for:
  - `Project`
  - `Order`
  - `Contract`
  - `Milestone`
  - `Inspection`
  - `Rating`
  - `Dispute`

## 3. Explicit Non-goals
- No new app-facing path family
- No fifth workbench summary container
- No second workbench private state machine
- No rewrite of `/exhibition/workbench` into the public home
- No governance console, control tower, or reporting desk expansion
- No `rating/submit`
- No `dispute/withdraw`
- No `inspection/recheck`
- No detail/list/history/reporting projections through workbench summary
- No second extension carrier outside the frozen `order_chain.activeOrderId`
  reuse rule
- No change to the current development-stage baseline
  `47.108.180.198 / 8080`

## 4. Minimum Success Corridor
- The minimum success corridor for this board is frozen as:
  1. a logged-in actor with valid private-side conditions enters
     `/exhibition/workbench`
  2. frontend requests `GET /api/app/exhibition/workbench`
  3. the summary successfully returns and displays all four frozen containers:
     - `project_chain`
     - `order_chain`
     - `fulfillment_chain`
     - `extension_boundary`
  4. the actor may continue only through controlled handoff into already frozen
     downstream canonical entries
  5. the board corridor ends at either:
     - successful workbench summary display
     - or controlled handoff into an already frozen downstream entry
- This board does not count downstream object execution as part of its own
  success body.
- This corridor does not include:
  - `rating/submit`
  - `dispute/withdraw`
  - `inspection/recheck`
  - governance queue
  - list/history/reporting expansion

## 5. Container Boundary
- `project_chain`
  - remains a controlled summary carrier only
  - may expose only the current private project context and frozen create or
    project-pool booleans
  - may reuse `recentProjectId` only as the current continuable project
    instance carrier
  - must hide direct bid-submit, publish or award controls, collaboration
    controls, and second project-dashboard states
- `order_chain`
  - remains a controlled summary carrier only
  - may expose only the current active order context and booleans for:
    - open order detail
    - open contract detail
    - open dispute-open entry
  - may reuse `activeOrderId` only as the current continuable order instance
    carrier
  - must hide `rating/submit`, `dispute/withdraw`, contract history/list, and
    second order workflow actions
- `fulfillment_chain`
  - remains a controlled summary carrier only
  - may expose only the current active milestone context, `inspectionState`,
    and booleans for:
    - open milestone list
    - open milestone submit
    - open inspection detail
    - open inspection submit
  - may reuse `activeMilestoneId` only as the current continuable fulfillment
    instance carrier
  - must hide `inspection/recheck`, inspection list/history, governance queue,
    and multi-round workflow consoles
- `extension_boundary`
  - remains a controlled boundary container only
  - must reuse the current `order_chain.activeOrderId` context and must not
    freeze a second extension carrier
  - may expose only:
    - open contract detail
    - controlled `ratingEntryState`
    - open dispute-open entry
    - frozen `disputeWithdrawState`
  - must hide `rating/submit`, `inspection/recheck`, `dispute/withdraw`,
    rating/dispute detail, list, history, moderation, escalation, resolution,
    and governance surfaces

## 6. Guard Boundary
- `/exhibition/workbench` is frozen as a private surface.
- Entering `/exhibition/workbench` requires at minimum:
  - login
  - valid organization context
- Client-side guard order must continue to follow the already frozen sequence:
  - shell bootstrap
  - login
  - session refresh
  - organization
  - hidden-building
  - role and object-permission
  - certification
- Specific container actions continue to follow each downstream object's
  existing guard truth, including:
  - project create
  - order detail
  - contract detail
  - milestone list
  - milestone submit
  - inspection detail
  - inspection submit
  - dispute open
- Frontend must not invent a second permission system locally.
- `BFF` may normalize visible/unavailable/forbidden style app-facing failures
  and apply visibility trimming only within the already frozen truth boundary.
- Final business permission judgement remains `Server`-owned.

## 7. Frontend Responsibility Boundary
- Frontend is limited to:
  - `/exhibition/workbench`
  - summary-container consumption
  - controlled handoff from the four containers into already frozen downstream
    entries
- Frontend may:
  - render only the four frozen containers
  - consume only the current frozen summary carriers and booleans
  - use `recentProjectId`, `activeOrderId`, and `activeMilestoneId` only as
    controlled continuation carriers
  - render controlled boundary states such as `ratingEntryState` and
    `disputeWithdrawState`
- Frontend must not:
  - own business truth for any downstream object
  - invent a second workbench state machine
  - reinterpret workbench summary as public home, governance console, or
    reporting surface
  - bypass `BFF`

## 8. BFF Responsibility Boundary
- `BFF` remains the only app-facing aggregation layer for this board.
- `BFF` is limited to:
  - `GET /api/app/exhibition/workbench` summary shaping
  - error normalization
  - visibility trimming
  - controlled handoff support through frozen booleans and carriers only
- `BFF` may:
  - shape only `project_chain`, `order_chain`, `fulfillment_chain`, and
    `extension_boundary`
  - reuse current recent-project, order, fulfillment, and boundary-state
    carriers only
  - normalize auth, unavailable, forbidden, and other controlled summary
    failures into the app-facing envelope
- `BFF` must not:
  - own any business truth
  - create a fifth container
  - create a second dashboard or second state machine
  - emit history, list, governance, moderation, or reporting projections
    through workbench summary
  - create a second extension carrier

## 9. Server Responsibility Boundary
- `Server` remains the only business truth owner for this board.
- `Server` is limited to:
  - underlying truth for `Project`, `Order`, `Contract`, `Milestone`,
    `Inspection`, `Rating`, and `Dispute`
  - state judgement
  - permission judgement
  - required audit support
- `Server` may:
  - provide the truth inputs that `BFF` reuses for summary shaping
  - enforce the final action gates behind each downstream continuation
- `Server` must not:
  - downshift truth ownership into workbench summary
  - convert the summary into a second business workflow owner
  - expose governance-console or reporting truth through this board

## 10. Stage Gate Checklist

### 10.1 Passed gates
- 真源门禁：
  - the accepted showcase-detail-bid closure already selected `工作台私域` as the
    next active board
  - this board-freeze file is authored under `docs/**`
- 目录洁癖门禁：
  - the current round is docs-only
  - the allowed directory set for this round is:
    - `docs/00_ssot/**`
- 架构边界门禁：
  - the board remains inside the existing `exhibition` building
  - `Flutter App -> BFF -> Server` remains unchanged
  - no hidden building is reopened
- 契约门禁：
  - the board reuses the already frozen path and summary schema in
    `docs/01_contracts/openapi.yaml`
  - no new `/api/app/*` path family is introduced
- 阶段控制门禁：
  - the current round has one objective only:
    - freeze the workbench-private board boundary
  - it has explicit non-goals
  - it does not jump directly into implementation
- 云上运行门禁：
  - the current development-stage runtime baseline continues to follow
    `docs/00_ssot/development_stage_cloud_host_override_addendum.md`
    on `47.108.180.198 / 8080`

### 10.2 Failed gates
- 无当前板块边界冻结轮阻断失败项

### 10.3 Veto gates
- Implementation-stage veto remains:
  - this file freezes board boundary only
  - it does not equal the workbench-private implementation round
- Release-stage veto remains:
  - development-stage runtime evidence does not equal release approval

### 10.4 Stage go / no-go
- Stage decision:
  - `Go` for the `工作台私域板块边界冻结轮`
  - `Go` for preparing the formal workbench-private dispatch bundle
  - `No-Go` for entering the implementation round by this file alone
  - `No-Go` for expanding into `rating/submit`, `dispute/withdraw`,
    `inspection/recheck`, governance console, or reporting surfaces

## 11. Board Closure Conditions
- This board may be considered closed only when all of the following exist:
  - frontend receipt exists for workbench summary container consumption and
    controlled handoff
  - `BFF` receipt exists for `GET /api/app/exhibition/workbench` summary
    shaping, visibility trimming, and controlled failure handling
  - backend receipt exists for the underlying truth inputs, permission
    enforcement, state judgement, and required audit support
  - the minimum success corridor has evidence on the current development-stage
    runtime `47.108.180.198 / 8080`
  - all four frozen containers display in a controlled way
  - workbench actions hand off only into already frozen downstream canonical
    entries
  - no fifth container, no second state machine, and no governance/reporting
    expansion were bundled into the board
  - independent verification returns a passed conclusion for this board

## 12. Next Unique Action
- The next unique action is:
  - issue the formal `工作台私域板块派工单`
- That next round may do only:
  - workbench summary implementation strictly inside the frozen board boundary
  - development-stage verification on the approved host and tunnel baseline
- That next round must not do:
  - `rating/submit`
  - `dispute/withdraw`
  - `inspection/recheck`
  - governance, history, list, or reporting expansion
