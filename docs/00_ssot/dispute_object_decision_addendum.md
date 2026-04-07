---
owner: Codex 总控
status: draft
purpose: Freeze the Dispute-only semantic decisions that must be resolved before any next-round implementation unlock.
layer: L0 SSOT
---

# Dispute 单对象决策补充单

## Scope
- This addendum applies only to `Dispute`.
- It clarifies the canonical semantics required before any next-round Dispute implementation unlock.
- It does not unlock implementation by itself.

## Supersession Rule
- This file remains the historical baseline for the already-closed
  dispute-open-only round.
- The current effective truth for the next planned `Dispute` round must follow:
  - `dispute_entry_minimal_governance_action_addendum.md`

## Canonical Decisions

### 1. Dispute business semantics and level
- `Dispute` is an `order`-level explicit dispute-open handoff, not a `milestone`-level object.
- It represents the first user-side escalation entry into order-bound governance handling.
- It is not the negotiation workflow, platform review workflow, escalation workflow, or final resolution workflow.

### 2. Dispute truth materialization owner and trigger
- `Dispute` truth must be materialized by `Server` only.
- `Dispute` truth must not be created by:
  - Flutter App
  - BFF
  - any GET-side effect
  - proactive materialize
  - a new app-facing `POST /api/app/dispute/create`
- The only canonical truth-creation trigger at the current stage is:
  - successful acceptance of `POST /api/app/dispute/open`
- Current canonical expectation:
  - a valid `orderId` exists
  - `Order.state` must already be in a dispute-open-eligible state
  - the current minimum eligible order states are:
    - `active`
    - `completed`

### 3. Historical app-facing entry boundary
- `POST /api/app/dispute/open` is the historical app-facing dispute entry for the
  already-closed round.
- Current next-round path truth must follow:
  - `dispute_entry_minimal_governance_action_addendum.md`

### 4. Dispute-open behavior when conditions are not met
- If required entry-state request fields are missing, the minimum error code remains:
  - `DISPUTE_OPEN_INVALID`
- If dispute opening conditions are not met, the canonical controlled response must be:
  - HTTP `409`
  - error code `DISPUTE_INVALID_STATE`
- Minimum response semantics:
  ```json
  {
    "statusCode": 409,
    "code": "DISPUTE_INVALID_STATE",
    "message": "Dispute cannot be opened from the current order state."
  }
  ```
- The current stage does not define any GET-based dispute readability contract, so "truth absent on read" is not a dispute-entry semantic in scope.

### 5. Frontend controlled-state mapping
- `DISPUTE_OPEN_INVALID` must map to:
  - `error_non_retryable`
- `DISPUTE_INVALID_STATE` must map to:
  - `error_non_retryable`
- Frontend may describe the state as dispute open unavailable, but may not promise negotiation, review, escalation, or resolution capabilities.

### 6. Allowed next-round scope ceiling
- Even if the next round unlocks `Dispute`, the maximum allowed scope is:
  - `entry + minimal action`
- The next round may not expand `Dispute` to:
  - full governance workflow
  - negotiation flow
  - platform review flow
  - escalation flow
  - resolution flow
  - dispute detail or history pages

## Historical Path Boundary
- This file freezes the historical path boundary for the already-closed
  dispute-open-only round.
- Current next-round path truth must follow:
  - `dispute_entry_minimal_governance_action_addendum.md`

## Historical Audit Boundary
- This file freezes the historical audit interpretation for the
  already-closed dispute-open-only round.
- Current next-round audit truth must follow:
  - `dispute_entry_minimal_governance_action_addendum.md`

## Non-goals
- No client-created dispute truth
- No BFF-created dispute truth
- No proactive dispute materialize
- No new app-facing dispute path beyond `POST /api/app/dispute/open` in the
  already-closed historical round
- No full dispute governance workflow unlock
