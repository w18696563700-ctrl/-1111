---
owner: Codex 总控
status: draft
purpose: Freeze the final canonical ruling for Rating entry readability when Order.completed has occurred but persisted rating truth may still be absent.
layer: L0 SSOT
---

# Rating truth 可读条件最终裁决单

## Scope
- This ruling applies only to `Rating` entry readability.
- It resolves the final semantic gap between:
  - `Order.completed` as the unique upstream gate event
  - `Rating` truth possibly still being absent
- It does not unlock implementation by itself.
- It does not adjudicate `rating submit` or any later `Rating` workflow boundary.

## Canonical Rulings

### 1. Formal behavior when Order.completed but rating truth is absent
- If `Order` has already entered `completed` but persisted `Rating` truth is
  still absent, the canonical response remains:
  - HTTP `409`
  - error code `RATING_ENTRY_UNAVAILABLE`
- Minimum response:
  ```json
  {
    "statusCode": 409,
    "code": "RATING_ENTRY_UNAVAILABLE",
    "message": "Rating entry is not yet available for this order."
  }
  ```
- This is not a fallback or temporary tolerance. It is the current formal
  semantics.

### 2. Internal materialize / backfill / pre-provision ruling
- The current truth freeze does **not** require:
  - proactive materialization
  - GET lazy creation
  - app-facing create path
  - mandatory internal backfill
  - mandatory pre-provision mechanism
- If a later round wants `Order.completed` to guarantee immediate readable
  `Rating` entry, that round must explicitly freeze:
  - the unique `Server` materialization trigger
  - whether backfill is required
  - the audit and error semantics for that mechanism
- Until then, lack of persisted rating truth remains a controlled unavailable
  condition, not an implementation bug by itself.

### 3. Correction to immediate-readable wording
- `Order.completed` remains the unique upstream gate event for `Rating`
  readability.
- But the current formal semantics are:
  - `Order.completed` is a **necessary** condition for readability
  - it is **not yet a sufficient guarantee** that persisted rating truth exists
- Therefore:
  - `GET /api/app/rating/entry` may return `200` only when
    - `Order.state = completed`
    - and persisted rating truth exists
  - otherwise it must return `409 + RATING_ENTRY_UNAVAILABLE`

### 4. Path and action boundary remain unchanged
- Allowed:
  - `GET /api/app/rating/entry`
- This ruling does not decide any `Rating` submit or later workflow boundary.
- Those boundaries are governed by separate `Rating` action and planning truth.

## Frontend State Mapping
- `RATING_ENTRY_UNAVAILABLE` continues to map to:
  - `error_non_retryable`
- No finer page-state split is introduced in this ruling.

## Non-goals
- No unlock of full rating workflow
- No unlock of `Dispute`
- No reopen of `Contract` or `Inspection`
- No `Phase 3` work
