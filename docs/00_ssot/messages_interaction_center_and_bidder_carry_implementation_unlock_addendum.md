---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded implementation unlock that allows `消息楼互动中心` plus
  `我的竞标承接 / 竞标摘要` to enter real implementation after the completed
  docs chain, while preserving the five-building shell, the single-channel
  `Flutter -> BFF -> Server` architecture, and all retained non-goals outside
  the approved interaction-carry scope.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_bounded_object_ruling_addendum.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_stage_gate_checklist_addendum.md
  - docs/00_ssot/messages_interaction_center_truth_freeze_addendum.md
  - docs/00_ssot/my_bids_and_bid_submission_snapshot_truth_freeze_addendum.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_contract_freeze_addendum.md
  - docs/02_backend/messages_interaction_center_and_bidder_carry_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/messages_interaction_center_and_bidder_carry_bff_surface_freeze_addendum.md
  - docs/04_frontend/messages_interaction_center_and_bidder_carry_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_root_guardrail_blocker_removal_planning_addendum.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_active_mainline_change_review_conclusion_addendum.md
---

# 《消息楼互动中心与我的竞标承接 implementation unlock addendum》

## Scope

- This addendum applies only to the current bounded object:
  - `消息楼互动中心`
  - `我的竞标承接 / 竞标摘要`
- It freezes only:
  - the current bounded implementation unlock decision
  - the passed / failed / retained veto gates for entering implementation
  - the currently approved implementation scope
  - the currently retained non-goals
- It does not by itself:
  - approve `participant-card`
  - approve generic DM / group chat
  - approve compare / award / post-award bridge
  - approve payment / billing / settlement
  - approve launch

## Current Active Object

- Current active bounded object:
  - `messages interaction center and bidder carry`

## Passed Gates

- Current bounded object ruling exists and is frozen.
- Current cloud baseline evidence is frozen.
- Current stage gate checklist is frozen.
- Current `Package A/B` `L0` truth is frozen.
- Current `Package A/B` `L2` contracts are frozen.
- Current `L3 Backend` truth is frozen.
- Current `L4 BFF` surface is frozen.
- Current `L5 Frontend` consumption is frozen.
- Current backend truth already writes down:
  - `BidSubmitted -> BidThreadResolved -> BidSubmittedSystemSeedCreated -> MessagesInteractionProjectionUpserted`
- Current backend truth already writes down:
  - no second chat state machine
- Current BFF / frontend chain already freezes:
  - `MessagesPage` dual lane
  - thread-first `system_seed`
  - read-only `BidSubmissionSnapshot`

## Failed Gates That Remain Non-blocking For This Unlock

- `participant-card` remains outside the current unlock scope.
- `formal-info` full-page takeover remains outside the current unlock scope.
- cloud runtime for:
  - `/api/app/message/interactions`
  - `/api/app/my/bids`
  - `/api/app/bid/submission/snapshot`
  is not yet materialized, but this addendum exists precisely to allow the
  bounded implementation needed to materialize them.

## Retained Veto Gates

- no sixth shell building
- no new bottom tab
- `Flutter App` still may not call `Server` directly
- `BFF` must not own business truth or a second state machine
- `Server` remains the only business truth owner
- no `participant-card` implementation in this unlock
- no generic DM / stranger DM / group chat
- no compare / award / loser board / post-award bridge
- no payment / billing / settlement
- no `formal-info` full-page takeover
- no push / WebSocket / SSE / read-receipt / typing / online-state

## Phase 0 Guardrail Revision

- The root baseline Phase 0 rule of `no business pages` remains true by default.
- The current forum board remains an approved bounded exception.
- A second bounded exception is now approved for:
  - `messages interaction center and bidder carry`
- The trading-flow blanket veto is revised from:
  - `No trading flow implementation`
- To:
  - `No trading flow implementation by default`
- The current trading bounded exception applies only after the current
  `messages interaction center and bidder carry` truth package is frozen.
- The exception scope is limited to:
  - `GET /api/app/message/interactions`
  - `GET /api/app/my/bids`
  - `GET /api/app/bid/submission/snapshot`
  - bounded `system_seed` supplement on existing `GET /api/app/bid/thread/detail`
  - matching `Server`, `BFF`, and Flutter implementation needed to support the
    approved surfaces above

## Current Implementation Scope

- Current implementation is allowed for:
  - Server read family:
    - `GET /server/message/interactions`
    - `GET /server/my/bids`
    - `GET /server/bid/submission/snapshot`
  - Server write/read supplement:
    - `BidSubmitted -> thread resolve/create -> system seed message`
    - interaction projection upsert
  - BFF app-facing family:
    - `GET /api/app/message/interactions`
    - `GET /api/app/my/bids`
    - `GET /api/app/bid/submission/snapshot`
  - bounded thread-detail shaping:
    - `messageKind`
    - `systemSeedType`
    - `systemSeedAction`
  - Flutter consumption:
    - `MessagesPage` dual lane
    - `MyProjectListPage` bidder carry
    - `BidThreadPage` system-seed card
    - `BidSubmissionSnapshot` page or bottom sheet
    - `BidSubmitPage` success posture handoff
    - bounded `ProjectDetailPage` CTA handoff

## Current Explicit Non-goals

- No `participant-card`
- No `formal-info` full-page takeover
- No generic DM / group chat
- No compare / award / loser board / post-award bridge
- No payment / billing / settlement
- No additional trading object families
- No second chat state machine in `BFF` or Flutter

## Formal Conclusion

- Current formal conclusion:
  - bounded implementation for `messages interaction center and bidder carry`
    is now allowed within the frozen current boundary
  - the old blanket Phase 0 trading-flow veto no longer blocks this current
    bounded object
  - all retained veto items above remain active
- Current meaning:
  - bounded interaction-carry implementation unlock only
- Current non-approved meaning:
  - no participant-card unlock
  - no wider trading unlock
  - no architecture expansion
