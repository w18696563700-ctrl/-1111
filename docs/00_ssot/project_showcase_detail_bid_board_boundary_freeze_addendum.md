---
owner: Codex 总控
status: draft
purpose: Freeze the board boundary, explicit non-goals, minimum success corridor, guard boundary, role responsibilities, stage gate result, closure conditions, and next action for the project showcase, detail, and minimum bid continuation board.
layer: L0 SSOT
---

# 项目展示/详情/继续竞标板块边界冻结单

## 1. Scope
- This addendum applies only to the `项目展示/详情/继续竞标` board.
- It follows the already accepted next-board handoff frozen in:
  - `docs/00_ssot/project_publish_board_closure_conclusion_addendum.md`
- This round freezes only:
  - board included scope
  - explicit non-goals
  - minimum success corridor
  - guard boundary
  - frontend / `BFF` / `Server` responsibility boundary
  - stage gate checklist for the current board-boundary round
  - board closure conditions
  - the next unique action
- This round does not by itself:
  - unlock the showcase-detail-bid implementation round
  - reopen publish scope
  - reopen `Order create`
  - reopen award, compare, shortlist, or buyer-side award
  - reopen `Contract / Milestone / Inspection / Rating / Dispute`
  - activate `BidWorkspace`, `MyBidEntry`, `BidDecision`, or `BidRejection`
  - rewrite the current development-stage host override

## 2. Board Included Scope
- The board included scope is limited to:
  - `/exhibition/showcase`
  - `/exhibition/projects`
  - `/exhibition/projects/detail`
  - `/exhibition/bids/submit`
  - controlled handoff from ordered-home recommendation or module entry into
    `showcase` and project detail
  - controlled continuation from project detail into the minimum bid-submit face
- The current canonical path scope is limited to:
  - `GET /api/app/project/list`
  - `GET /api/app/project/detail`
  - `POST /api/app/bid/submit`
- The current reusable carrier rule is:
  - `project/list` and `project/detail` continue to share the same frozen
    minimum `Project` read model
  - `project/detail` continues to use the existing route-carried `projectId`
  - the only current detail-to-bid continuation carrier frozen by this board is
    the existing `projectId`-based handoff into `bid/submit`
- The board exists only for:
  - public project discovery through the showcase and project list/detail faces
  - minimum supplier-side continuation into bid submission
- The board does not own:
  - publish workbench semantics
  - workbench private summary semantics
  - downstream order or fulfillment continuation

## 3. Explicit Non-goals
- No new app-facing path family
- No dedicated showcase contract family
- No second list-only or detail-only project field model
- No order conversion
- No bid compare, shortlist, or win-loss management
- No buyer-side award
- No publish workflow rewrite or backflow change
- No workbench private-summary expansion
- No `BidWorkspace`
- No `MyBidEntry`
- No `BidDecision`
- No `BidRejection`
- No second state machine
- No reinterpretation of `bid/submit` success as order truth
- No reinterpretation of `project/detail` as contract, order, or governance
  detail
- No change to the current development-stage baseline
  `47.108.180.198 / 8080`

## 4. Minimum Success Corridor
- The minimum success corridor for this board is frozen as:
  1. user enters from `/exhibition` through the project recommendation section
     or the `项目展示` module entry
  2. user reaches `/exhibition/showcase` or `/exhibition/projects`
  3. user enters `/exhibition/projects/detail` directly or from the current
     list/module handoff
  4. the detail page consumes only the frozen minimum `Project` read model
  5. an actor that passes the current guard boundary enters
     `/exhibition/bids/submit` from project detail
  6. frontend submits `POST /api/app/bid/submit`
  7. the corridor ends at either:
     - minimum success `202 + { bidId }`
     - or a controlled failure result under the current auth / permission /
       unavailable boundary
- This corridor does not include:
  - `POST /api/app/order/create`
  - order detail continuation
  - compare, shortlist, award, or any later chain action

## 5. Guard Boundary
- `showcase`, `project list`, and `project detail` are frozen as public
  discovery surfaces by default.
- Their current constraints are limited to:
  - visibility boundary
  - controlled unavailable handling when the requested project carrier cannot be
    consumed
- `bid submit` is frozen as a guarded continuation surface.
- Minimum bid-submit guard conditions are:
  - login required
  - valid organization scope required
  - certification approved when required
  - supplier-side role or allowed scoped supplier object permission required
- Client-side guard order must continue to follow the already frozen sequence:
  - shell bootstrap
  - login
  - session refresh
  - organization
  - hidden-building
  - role and object-permission
  - certification
- Frontend may consume frozen shell context to route into controlled guards.
- Frontend must not invent a second permission system or make final permission
  judgement locally.
- `BFF` may normalize auth, forbidden, unavailable, and other controlled app-facing
  failures.
- Final business permission judgement remains `Server`-owned.

## 6. Frontend Responsibility Boundary
- Frontend is limited to:
  - `/exhibition/showcase`
  - `/exhibition/projects`
  - `/exhibition/projects/detail`
  - `/exhibition/bids/submit`
  - controlled handoff from ordered home into showcase or detail
  - controlled handoff from detail into the minimum bid-submit face
- Frontend may:
  - consume `project/list` as the current project-display carrier
  - consume `project/detail` using the shared frozen minimum `Project` read
    model plus route-carried `projectId`
  - expose bid-submit entry only from the current project detail continuation
  - submit only the frozen request fields for `bid/submit`:
    - `projectId`
    - `quoteAmount`
    - `proposalSummary`
  - handle only the frozen success continuation result:
    - `bidId`
    - controlled success or controlled failure feedback
- Frontend must not:
  - own project truth or bid truth
  - reinterpret `project/list` and `project/detail` as two field models
  - reinterpret `bid/submit` as compare, shortlist, award, or order truth
  - expose workbench-private summary semantics through this board
  - bypass `BFF`

## 7. BFF Responsibility Boundary
- `BFF` remains the only app-facing aggregation layer for this board.
- `BFF` is limited to:
  - `project/list` app-facing shaping
  - `project/detail` app-facing shaping
  - `bid/submit` app-facing handoff
  - controlled home-to-showcase/detail handoff support through the existing
    ordered-home aggregation family
- `BFF` may:
  - shape list/detail read models for current Flutter consumption
  - forward the minimum bid-submit command
  - normalize auth, unavailable, validation, and permission failures into the
    current app-facing error envelope
  - preserve the current canonical path family only
- `BFF` must not:
  - own `Project` truth or `Bid` truth
  - invent compare, shortlist, win-loss, award, or order-conversion
    projections
  - invent a second permission system
  - expose a new showcase-only or bid-workspace path family
  - create a second state machine

## 8. Server Responsibility Boundary
- `Server` remains the only business truth owner for this board.
- `Server` is limited to:
  - `Project` read truth for list/detail
  - `Bid` submit command truth
  - final permission judgement
  - state transition judgement
  - append-only audit where required
- `Server` may:
  - serve the shared minimum `Project` read model to the app-facing chain
  - accept the frozen minimum bid-submit request
  - return only the frozen minimum bid-submit success body
  - enforce organization, role, object-scope, and certification gates
- `Server` must not:
  - move final truth or final permission judgement into `BFF` or frontend
  - expand the board into order creation or award management
  - introduce a second bid workflow state machine
  - reopen downstream object families under this board

## 9. Stage Gate Checklist

### 9.1 Passed gates
- 真源门禁：
  - the accepted publish-board closure already selected
    `项目展示/详情/继续竞标` as the next active board
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
  - the board reuses already frozen canonical paths in
    `docs/01_contracts/openapi.yaml`
  - no new `/api/app/*` path family is introduced
- 阶段控制门禁：
  - the current round has one objective only:
    - freeze the showcase-detail-bid board boundary
  - it has explicit non-goals
  - it does not jump directly into implementation
- 云上运行门禁：
  - the current development-stage runtime baseline continues to follow
    `docs/00_ssot/development_stage_cloud_host_override_addendum.md`
    on `47.108.180.198 / 8080`

### 9.2 Failed gates
- 无当前板块边界冻结轮阻断失败项

### 9.3 Veto gates
- Implementation-stage veto remains:
  - this file freezes board boundary only
  - it does not equal the showcase-detail-bid implementation round
- Release-stage veto remains:
  - development-stage runtime evidence does not equal release approval

### 9.4 Stage go / no-go
- Stage decision:
  - `Go` for the `项目展示/详情/继续竞标板块边界冻结轮`
  - `Go` for preparing the formal showcase-detail-bid dispatch bundle
  - `No-Go` for entering the implementation round by this file alone
  - `No-Go` for expanding into `Order create` or later-chain implementation

## 10. Board Closure Conditions
- This board may be considered closed only when all of the following exist:
  - frontend receipt exists for showcase/list/detail consumption and controlled
    detail-to-bid handoff
  - `BFF` receipt exists for `project/list`, `project/detail`, and `bid/submit`
    app-facing support
  - backend receipt exists for `Project` read truth, `Bid` submit truth,
    permission enforcement, and required audit support
  - the minimum success corridor has evidence on the current development-stage
    runtime `47.108.180.198 / 8080`
  - project detail successfully consumes the frozen shared minimum
    `Project` read model
  - `bid/submit` reaches either canonical minimum success or controlled failure
    without fake success
  - no new app-facing path, no second state machine, and no order-create or
    award-management expansion were bundled into the board
  - independent verification returns a passed conclusion for this board

## 11. Next Unique Action
- The next unique action is:
  - issue the formal `项目展示/详情/继续竞标板块派工单`
- That next round may do only:
  - showcase/list/detail/bid-submit implementation strictly inside the frozen
    board boundary
  - development-stage verification on the approved host and tunnel baseline
- That next round must not do:
  - `Order create`
  - award, compare, shortlist, or buyer-side award
  - publish-board rewrite
  - downstream contract, fulfillment, inspection, rating, or dispute expansion
