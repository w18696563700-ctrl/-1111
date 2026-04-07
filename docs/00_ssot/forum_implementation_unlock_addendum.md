---
owner: Codex 总控
status: draft
purpose: Freeze the bounded unlock that allows forum business-page implementation after the current forum truth package is complete, while preserving the five-building shell and the existing forum/messages/profile ownership split.
layer: L0 SSOT
---

# Forum Implementation Unlock Addendum

## Scope
- This addendum applies only to the current forum board.
- It freezes only:
  - the current implementation unlock decision
  - the current passed / failed / veto gates for entering implementation
  - the currently approved implementation scope
  - the current retained non-goals
- It does not by itself:
  - approve Docker migration
  - approve a sixth building
  - approve a new bottom tab
  - approve ads, recommendation, ranking, or moderation-console scope

## Current Active Board
- Current active board:
  - `论坛模块`

## Passed Gates
- Forum domain truth baseline already exists:
  - `docs/00_ssot/forum_domain_truth_baseline_addendum.md`
- Forum ownership split and navigation boundary are already frozen:
  - `docs/00_ssot/forum_navigation_building_ownership_boundary_addendum.md`
  - `docs/00_ssot/forum_navigation_boundary_revision_addendum.md`
- Forum IA visual validation is complete and accepted by total control.
- Forum L2 and L3 truth refinement is already frozen:
  - `docs/01_contracts/forum_app_facing_contracts_addendum.md`
  - `docs/03_bff/forum_bff_route_group_truth_addendum.md`
  - `docs/04_frontend/forum_frontend_consumption_truth_addendum.md`
- Current forum implementation-facing truth now exists:
  - `docs/02_backend/forum_server_implementation_truth_addendum.md`
  - `docs/03_bff/forum_bff_implementation_surface_addendum.md`
  - `docs/04_frontend/forum_frontend_implementation_surface_addendum.md`
- Current forum contracts are now implementation-complete at the app-facing
  layer through:
  - `docs/01_contracts/openapi.yaml`
  - `docs/01_contracts/forum_app_facing_contracts_addendum.md`

## Failed Gates
- 无当前 implementation unlock 轮直接阻断项

## Veto Gates That Remain Active
- no sixth shell building
- no new bottom tab
- `messages` must not become the second forum homepage
- `profile` must not become the forum main browsing building
- no second forum path family outside `/api/app/forum/*`
- Flutter App still may not call `Server` directly
- Docker migration remains outside the current forum implementation scope
- moderation console, report dashboard, recommendation, ranking, ads, and
  resource-slot work remain outside the current forum implementation scope

## Phase 0 Guardrail Revision
- The root baseline Phase 0 rule of `no business pages` remains true by
  default.
- The current forum board is the approved bounded exception.
- The exception applies only after the current forum truth package is frozen.
- The exception scope is limited to:
  - `exhibition/forum` main browsing chain
  - `messages` interaction center for forum-originated inbox semantics only
  - `profile` forum asset entry surfaces only
  - matching `BFF` and `Server` implementation needed to support those
    approved surfaces

## Current Implementation Scope
- Current implementation is allowed for:
  - forum container-home under `exhibition`
  - forum `广场 / 本地 / 关注` feeds
  - topic classification select / label / filter surfaces
  - post detail and comment chain
  - post like
  - topic follow
  - post bookmark
  - post draft save / list / delete
  - publish from draft
  - forum search
  - forum me assets:
    - my posts
    - my comments
    - my bookmarks
    - my follows
    - drafts
  - forum-originated interaction inbox for `messages`:
    - replies
    - likes
    - follows

## Current Explicit Non-goals
- No moderation console
- No report submission UI
- No recommendation or ranking engine
- No ad slot or resource slot
- No sixth building
- No new bottom tab
- No Docker migration
- No second forum state machine in `BFF` or Flutter App

## Formal Conclusion
- Current formal conclusion:
  - forum implementation is now allowed within the frozen current boundary
  - the old blanket Phase 0 business-page veto no longer blocks the current
    forum board
  - all retained veto items above remain active
- Current meaning:
  - bounded forum implementation unlock only
- Current non-approved meaning:
  - no architecture expansion
  - no Docker unlock
  - no recommendation / moderation / ads unlock
