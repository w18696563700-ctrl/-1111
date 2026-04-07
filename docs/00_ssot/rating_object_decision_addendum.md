---
owner: Codex 总控
status: draft
purpose: Freeze the Rating-only semantic decisions that must be resolved before any next-round implementation unlock.
layer: L0 SSOT
---

# Rating 单对象决策补充单

## Scope
- This addendum applies only to `Rating`.
- It clarifies the canonical semantics required before any next-round Rating implementation unlock.
- It does not unlock implementation by itself.

## Canonical Decisions

### 1. Rating business semantics and level
- `Rating` is an `order`-level entry object, not a `milestone`-level object.
- `Rating` represents post-order evaluation visibility and eligibility only at the current stage.
- It is not the full scoring model, visibility workflow, review workflow, or appeal workflow.

### 2. Rating truth materialization owner and trigger
- `Rating` truth must be materialized by `Server` only.
- `Rating` truth must not be created by:
  - Flutter App
  - BFF
  - `GET /api/app/rating/entry`
  - a new app-facing `POST /api/app/rating/create`
- The unique upstream trigger event for rating entry readability is:
  - `Order` first enters `completed`
- Current canonical expectation:
  - if a persisted `Rating` truth record is used, it must be materialized by `Server`, not by read side effects, Flutter App, BFF, or a new app-facing create path
  - no other upstream event may make rating entry readable
  - `Order.completed` is a necessary gate for readability, but not yet a sufficient guarantee that persisted rating truth already exists

### 3. GET lazy creation is not accepted
- `GET /api/app/rating/entry` may not lazily create rating truth as canonical product semantics.
- Entry read may not be described as object creation.
- Transitional runtime behavior, if any, must not become formal product semantics.

### 4. Rating entry behavior when truth is absent
- `GET /api/app/rating/entry?orderId=...` must not create truth as a side effect.
- Before `Order` first enters `completed`, the canonical response must be a controlled unavailable semantic.
- If rating truth is still absent when the entry is requested after that trigger should already have happened, the canonical response remains the same controlled unavailable semantic until a later truth-freeze round explicitly introduces a materialize/backfill/pre-provision rule.
- The minimum error code for that condition is:
  - `RATING_ENTRY_UNAVAILABLE`
- Minimum response:
  ```json
  {
    "statusCode": 409,
    "code": "RATING_ENTRY_UNAVAILABLE",
    "message": "Rating entry is not yet available for this order."
  }
  ```

### 5. Frontend controlled-state mapping
- `RATING_ENTRY_UNAVAILABLE` must map to:
  - `error_non_retryable`
- Frontend may describe the state as rating entry unavailable, but may not promise that opening the page creates or submits a rating.

### 6. Historical next-round scope ceiling
- This file freezes the previously approved `entry/read` ceiling only.
- It is now a historical baseline for the already-closed Rating entry/read round.
- Any later next-round planning for `Rating` must follow:
  - `rating_entry_minimal_action_contract_permission_addendum.md`
- This file no longer acts as the current effective ceiling for the next planned
  `Rating` round.

## Historical Path Boundary
- This file freezes the historical path boundary for the already-closed
  `entry/read` round only.
- Current effective path truth for the next planned `Rating` round must follow:
  - `rating_entry_minimal_action_contract_permission_addendum.md`

## Historical Audit Boundary
- This file freezes the historical audit interpretation for the
  already-closed `entry/read` round only.
- Current effective audit truth for the next planned `Rating` round must follow:
  - `rating_entry_minimal_action_contract_permission_addendum.md`

## Non-goals
- No client-created rating truth
- No BFF-created rating truth
- No GET-triggered truth creation
- No app-facing rating submit unlock in the already-closed historical
  `entry/read` round
- No full rating workflow unlock
