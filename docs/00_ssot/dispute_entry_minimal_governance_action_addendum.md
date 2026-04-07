---
owner: Codex 总控
status: submitted
purpose: Freeze the minimum governance action semantics for the next planned Dispute round.
layer: L0 SSOT
---

# Dispute entry + minimal governance action 决策补充单

## Scope
- This addendum applies only to the next planned `Dispute` round.
- It freezes one minimum governance action only.
- It does not unlock implementation by itself.

## Supersession Rule
- For the next planned `Dispute` round, this addendum supersedes the old
  open-only boundary in `dispute_object_decision_addendum.md`.
- The already-closed historical `dispute/open` round remains valid as a
  historical baseline.

## Canonical Decision

### 1. Minimal governance action
- The only allowed `minimal governance action` is:
  - `withdraw existing opened dispute`
- Canonical semantics:
  - the current opener side may withdraw an already-opened dispute
  - transition:
    - `opened -> withdrawn`
- This action is not:
  - platform review
  - negotiation
  - escalation
  - resolution
  - history or detail retrieval

### 2. App-facing path boundary
- Existing allowed path:
  - `POST /api/app/dispute/open`
- The only new allowed app-facing path is:
  - `POST /api/app/dispute/withdraw`
- Forbidden:
  - `POST /api/app/dispute/create`
  - `GET /api/app/dispute/detail`
  - `GET /api/app/dispute/list`
  - `POST /api/app/dispute/resolve`
  - `POST /api/app/dispute/escalate`
  - `POST /api/app/dispute/review`
  - `GET /api/app/dispute/history`

### 3. Who may trigger it
- Allowed withdraw actors:
  - `buyer_admin`
  - `buyer_member(scoped)`
  - `supplier_admin`
  - `supplier_member(scoped)`
- The current actor must belong to the same organization side that originally
  opened the dispute.
- Explicitly forbidden:
  - `operator`
  - `platform_reviewer`
  - `platform_support`
  - `platform_super_admin`
  - missing role header
  - any actor outside the opener organization scope

### 4. Preconditions
- persisted `Dispute` truth exists
- `Dispute.state = opened`
- current actor is on the opener side of the dispute
- current actor organization matches the opener organization scope
- no later governance state has started in this round
- repeated withdraw on an already-withdrawn dispute is not allowed

### 5. Success response and error codes
- `POST /api/app/dispute/withdraw`
  - HTTP `202`
  - minimum success body:
    - `disputeId`
    - `orderId`
    - `state`
    - `summary`
- canonical success state:
  - `withdrawn`

- `400 + DISPUTE_WITHDRAW_INVALID`
  - request body invalid
  - missing `disputeId`

- `409 + DISPUTE_INVALID_STATE`
  - dispute truth does not exist
  - `Dispute.state` is not `opened`
  - current actor is not eligible to withdraw this dispute
  - repeated withdraw on `withdrawn`

### 6. Minimum audit boundary
- The minimum audit actions for the next planned Dispute round are:
  - `DisputeOpened`
  - `DisputeWithdrawn`
- Minimum withdraw audit semantics:
  - before: `opened`
  - after: `withdrawn`
- Invalid withdraw attempts must not append `DisputeWithdrawn`.

## Non-goals
- No dispute detail page
- No dispute list page
- No platform review workflow
- No escalation workflow
- No resolution workflow
- No reporting dashboard
- No Contract / Inspection / Rating reopen
- No implementation unlock by this document alone
