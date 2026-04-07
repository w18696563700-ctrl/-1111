---
owner: Codex 总控
status: draft
purpose: Freeze the minimum action contract, permission truth, and L2/L3 consumer boundary for the next Rating planning round.
layer: L0 SSOT
---

# Rating entry + minimal action 契约与权限补充单

## Scope
- This addendum applies only to the next planned `Rating` round.
- It freezes the minimum action contract and permission boundary only.
- It does not unlock implementation by itself.

## Supersession Rule
- This addendum supersedes the old next-round scope ceiling in
  `rating_object_decision_addendum.md`.
- The current planning ceiling for `Rating` is no longer `entry/read`.
- The current planning ceiling is:
  - `entry + minimal action`

## Canonical Decision

### 1. Minimum action
- The only allowed `minimal action` is:
  - `submit existing draft rating`
- Canonical semantics:
  - submit an already-persisted `Rating` truth row
  - transition `draft -> submitted`
- This action is not:
  - rating truth creation
  - score-model editing
  - review or moderation
  - history or list retrieval

### 2. App-facing path boundary
- Existing allowed path:
  - `GET /api/app/rating/entry`
- The only new allowed app-facing path is:
  - `POST /api/app/rating/submit`
- Forbidden:
  - `POST /api/app/rating/create`
  - `GET /api/app/rating/detail`
  - `GET /api/app/rating/history`
  - `GET /api/app/rating/list`
  - `POST /api/app/rating/review`

### 3. Minimum submit request body
- The minimum request body for `POST /api/app/rating/submit` is:
  - `orderId`
- Canonical request:
  ```json
  {
    "orderId": "..."
  }
  ```
- `ratingId` is not required in the request body for this round.
- `BFF` and Flutter App must not invent score fields, comments, tags, or
  moderation flags for the minimum submit action.

### 4. Permission truth
- Allowed submit actors:
  - `buyer_admin`
  - `buyer_member(scoped)`
- Explicitly forbidden:
  - `supplier_admin`
  - `supplier_member`
  - `operator`
  - `Admin`
  - missing role header
- The submit action remains app-facing.
- It is not a Server-internal-only action.

### 5. Preconditions
- `Order.state = completed`
- persisted `Rating` truth exists for the current order
- `Rating.state = draft`
- current actor has buyer-side scope for the order
- a previously submitted rating may not be submitted again

### 6. Success response
- `POST /api/app/rating/submit`
  - HTTP `202`
  - minimum success body:
    - `ratingId`
    - `orderId`
    - `state`
    - `summary`
- canonical success state:
  - `submitted`

### 7. Error code boundary
- `400 + RATING_SUBMIT_INVALID`
  - request body invalid
  - missing `orderId`
- `409 + RATING_ENTRY_UNAVAILABLE`
  - `Order` not `completed`
  - or persisted `Rating` truth does not exist
- `409 + RATING_INVALID_STATE`
  - `Rating.state` is not `draft`
  - including repeated submit on `submitted`

### 8. Audit boundary
- Minimum audit action:
  - `RatingSubmitted`
- Minimum audit semantics:
  - before: `draft`
  - after: `submitted`
- Invalid submit attempts must not append `RatingSubmitted`.

## L2/L3 Sync Requirement
- The following files must stay aligned with this addendum:
  - `docs/01_contracts/openapi.yaml`
  - `docs/00_ssot/permission_matrix.md`
  - `docs/02_backend/audit_log_spec.md`
  - `docs/03_bff/bff_routes.md`
  - `docs/04_frontend/flutter_screen_map.md`
  - `docs/04_frontend/ui_state_contract.md`

## Non-goals
- No rating truth creation
- No GET lazy creation
- No detail or history page
- No list page
- No review or moderation workflow
- No resubmit flow
- No Contract / Inspection / Dispute reopen
- No implementation unlock by this document alone
