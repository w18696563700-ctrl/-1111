---
owner: Codex 总控
status: draft
purpose: Freeze one current-stage authoritative blueprint for the approved exhibition mainline and its authority map.
layer: L0 SSOT
---

# Current Stage Mainline Blueprint Addendum

## Scope
- This file freezes one current-stage authoritative blueprint for the approved
  exhibition mainline only.
- It unifies the current approved chain narrative for:
  - `Project`
  - `Bid`
  - `Order`
  - `Contract`
  - `Milestone`
  - `Inspection`
  - `Rating / Dispute`
- It exists to stop current-stage traceability from being spread across
  lifecycle truth, object addenda, `L2 Contracts`, and `L3` consumer files.
- It does not unlock implementation by itself.
- It does not reorder the current active stage.
- The current active ranked item remains `Rating bigger-loop planning`, and that
  planning-only stage does not rewrite the already-approved mainline baseline
  frozen here.

## Canonical Mainline Sequence
- The current approved exhibition mainline sequence is:
  - `Project -> Bid -> Order -> Contract -> Milestone -> Inspection -> Rating / Dispute`
- Current container rule along the chain:
  - `Project` is the pre-trade demand container
  - `Bid` is the supplier-side proposal handoff attached to a `Project`
  - `Order` becomes the active post-award business container
  - `Contract`, `Milestone`, and `Inspection` remain attached to the active
    `Order` chain
  - `Rating` and `Dispute` are post-delivery governance continuations bound to an
    existing `Order`, not parallel free-standing objects
- Current chain discipline:
  - one mainline remains primary
  - no second mainline is introduced by message, profile, admin, or platform
    capability paths
  - `Contract / Inspection / Rating / Dispute` continue only through their current
    approved per-object truth ceilings; they are not reopened here as a parallel
    product expansion bundle

## Current Approved Stage-by-stage Boundary
- `Project`
  - current approved boundary:
    - list read
    - create command
    - detail read
  - currently not approved:
    - collaboration workflow
    - publish or award expansion
    - bid-compare truth
- `Bid`
  - current approved boundary:
    - submit command only
  - currently not approved:
    - compare
    - shortlist
    - win/loss management
- `Order`
  - current approved boundary:
    - create command
    - detail read
  - currently not approved:
    - order accept expansion
    - fulfillment dashboard expansion
    - second order-success model
- `Contract`
  - current approved boundary:
    - detail read
    - first confirm handoff
    - one minimum amendment handoff
    - amended read projection
  - currently not approved:
    - sign workflow
    - legal review
    - history or list
    - multi-round amendment system
- `Milestone`
  - current approved boundary:
    - list read
    - submit command
  - currently not approved:
    - approval console
    - evidence workflow expansion
    - second milestone workflow truth
- `Inspection`
  - current approved boundary:
    - detail read
    - first submit
    - one controlled decision branch
    - at most one rectification round
    - at most one recheck round
  - currently not approved:
    - list
    - history
    - governance queue
    - multi-round recheck expansion
- `Rating`
  - current approved boundary:
    - entry read
    - one minimum submit action on existing draft truth
  - currently not approved:
    - create
    - detail
    - history
    - list
    - moderation
    - richer scoring model
- `Dispute`
  - current approved boundary:
    - open command
    - withdraw command
  - currently not approved:
    - detail
    - list
    - escalation
    - resolution
    - governance console

## Current Entry / Minimal Action Map
| Segment | Current canonical entry | Current minimum approved action |
|---|---|---|
| `Project` | `GET /api/app/project/list` and `GET /api/app/project/detail` | `POST /api/app/project/create` |
| `Bid` | current continuation from project detail or create success | `POST /api/app/bid/submit` |
| `Order` | `GET /api/app/order/detail` as the current active order container read and controlled local continuation context via the already frozen `orderId` only | `POST /api/app/order/create` |
| `Contract` | `GET /api/app/contract/detail`, including controlled local continuation from existing `order/detail` using the already frozen `orderId` only | `POST /api/app/contract/confirm`, `POST /api/app/contract/amend` |
| `Milestone` | `GET /api/app/milestone/list` | `POST /api/app/milestone/submit` |
| `Inspection` | `GET /api/app/inspection/detail` | `POST /api/app/inspection/submit`, `POST /api/app/inspection/recheck` |
| `Rating` | `GET /api/app/rating/entry`, including controlled local continuation from existing `order/detail` using the already frozen `orderId` only | `POST /api/app/rating/submit` |
| `Dispute` | `POST /api/app/dispute/open` may enter from controlled local continuation out of existing `order/detail` using the already frozen `orderId`; `dispute/withdraw` still requires an existing dispute carrier with `disputeId` | `POST /api/app/dispute/open`, `POST /api/app/dispute/withdraw` |
- Internal-only note:
  - inspection decision remains a `Server`-internal controlled entry and is not an
    app-facing mainline action
- Continuation rule:
  - `order/detail` may support local continuation into the existing canonical
    `contract/detail`, `rating/entry`, and `dispute/open` entries by reusing the
    already frozen `orderId` only
  - this does not freeze a new `Order` response field, a second continuation
    carrier, or a second continuation model
  - `dispute/withdraw` remains outside the `order/detail` continuation context
    and still requires an existing dispute instance carrier

## Current First-release Frontend Happy-path Scope
- The current first-release frontend happy-path baseline remains the default
  minimum smoke corridor frozen in
  `docs/00_ssot/exhibition_write_chain_smoke_corridor_addendum.md`.
- That current happy path:
  - starts from a fresh `Project`
  - currently ends at successful `inspection/submit`
  - does not require any later extension action to be exercised for current
    first-release acceptance
- `rating/entry -> rating/submit` is excluded from the current first-release
  frontend happy path.
- Current first-release frontend acceptance may still resolve the rating side as:
  - controlled `rating/entry`
  - including controlled unavailable via `RATING_ENTRY_UNAVAILABLE`
  - without requiring `rating/submit` success in the current release-happy-path
    bundle
- `inspection/recheck` is excluded from the current first-release frontend happy
  path.
- Current first-release frontend acceptance may still stop at the current demo
  corridor endpoint:
  - successful `inspection/submit`
  - controlled returned projection on the fresh chain
- The internal operator decision -> `rectification_required` ->
  supplier-side `inspection/recheck` branch remains a separately approved
  extension round, not a current must-pass frontend happy-path segment.
- `dispute/withdraw` also remains outside the current first-release frontend
  happy-path scope and still requires an existing dispute instance carrier with
  `disputeId`.

## Current Explicit Non-goals Along the Chain
- No new object family
- No new state family
- No new app-facing path
- No object reopen by this blueprint alone
- No conversion of the current mainline blueprint into a bigger-loop execution plan
- No `Contract` sign, legal-review, history, or list reopen
- No `Inspection` list, history, or platform adjudication reopen
- No `Rating` detail, history, list, moderation, or richer scoring reopen
- No `Dispute` detail, list, escalation, resolution, or platform adjudication reopen
- No replacement of per-object truth with a single blueprint-owned second truth

## Authority Map To Existing Truth Files
- Top-level object order and canonical state graph:
  - owned by `docs/00_ssot/lifecycle_state_machine.md`
- `Project / Bid / Order / Milestone` current L2 command/read boundary:
  - owned by `docs/01_contracts/openapi.yaml`
- `Project / Bid / Order / Milestone` current Flutter consumer boundary:
  - owned by `docs/04_frontend/flutter_screen_map.md`
- `Contract` current workflow ceiling:
  - owned by `docs/00_ssot/contract_phase3_decision_addendum.md`
  - with current `L2` and `L3` consumer truth owned by
    `docs/01_contracts/openapi.yaml` and `docs/04_frontend/flutter_screen_map.md`
- `Inspection` current workflow ceiling:
  - owned by `docs/00_ssot/inspection_phase3_decision_addendum.md`
  - with current `L2` and `L3` consumer truth owned by
    `docs/01_contracts/openapi.yaml` and `docs/04_frontend/flutter_screen_map.md`
- `Rating` current workflow ceiling:
  - owned by `docs/00_ssot/rating_entry_minimal_action_contract_permission_addendum.md`
  - with current `L2` and `L3` consumer truth owned by
    `docs/01_contracts/openapi.yaml` and `docs/04_frontend/flutter_screen_map.md`
- `Dispute` current workflow ceiling:
  - owned by `docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md`
  - with current `L2` and `L3` consumer truth owned by
    `docs/01_contracts/openapi.yaml` and `docs/04_frontend/flutter_screen_map.md`
- Current active stage selection and current planning-only rank:
  - owned by `docs/00_ssot/next_stage_candidate_ranking_and_unique_goal.md`

## Boundary with Contracts / Frontend Map / Object Addenda
- Boundary with `docs/01_contracts/openapi.yaml`:
  - `openapi.yaml` remains the `L2` source of truth for current path, request, and
    response boundary
  - this file does not redefine field-level contract truth
- Boundary with `docs/04_frontend/flutter_screen_map.md`:
  - `flutter_screen_map.md` remains the `L3` source of truth for route
    responsibility and current consumer boundary
  - this file only narrates the chain-level blueprint
- Boundary with object addenda:
  - `Contract`, `Inspection`, `Rating`, and `Dispute` continue to be finally owned
    by their current per-object addenda
  - this file does not supersede or rewrite those addenda
- Boundary with implementation:
  - `apps/**` remain non-truth
  - `packages/**` remain projection or tooling layers only
  - no implementation is unlocked by this blueprint alone

## Non-goals
- No implementation plan
- No page implementation
- No `Server` API implementation
- No new app-facing path
- No new `L2 Contracts`
- No active-stage reordering
- No bigger-loop reopen by default
- No replacement of per-object truth with a second master truth
