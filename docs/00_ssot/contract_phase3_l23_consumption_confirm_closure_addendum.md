---
owner: Codex 总控
status: draft
purpose: Freeze the remaining Contract Phase 3 L2/L3 consumer wording and confirm success-contract details before any implementation unlock.
layer: L0 SSOT
---

# Contract Phase 3 L2/L3 消费真源与 confirm 成功体契约收口冻结单

## Scope
- This addendum applies only to the remaining L2/L3 Contract Phase 3 consumer truth.
- It closes the final wording and success-body gaps before any Contract Phase 3
  implementation unlock.
- It does not unlock implementation by itself.

## Canonical Decisions

### 1. BFF contract boundary
- `contract/amend` is part of the `contract` route group in Phase 3.
- The unique BFF consumer boundary for `Contract` Phase 3 is:
  - `GET /api/app/contract/detail`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
- `BFF` may only:
  - normalize auth
  - forward `orderId` or `contractId`
  - shape the minimum success or failure response
- `BFF` may not expose:
  - clause-editor structures
  - sign workflow
  - legal review
  - history or list
  - reporting projections

### 2. Flutter page and entry boundary
- `contract/amend` must have its own page-level consumer boundary.
- The minimum Contract Phase 3 page set is:
  - detail read page
  - confirm command page
  - amend command page
- Frontend may show only:
  - current server-returned contract state
  - minimum `summary`
  - currently available confirm or amend action
  - controlled success and failure containers
- Frontend may not show:
  - clause editor
  - sign console
  - legal review panel
  - history, list, or reporting

### 3. contract/confirm success contract
- `POST /api/app/contract/confirm` remains a Phase 3 workflow handoff, not a
  Phase 2.3 entry-only description.
- Canonical success response code:
  - HTTP `202`
- Minimum success response body:
  ```json
  {
    "contractId": "string",
    "orderId": "string",
    "state": "active",
    "summary": {}
  }
  ```
- The minimum success response body must contain:
  - `contractId`
  - `orderId`
  - `state`
  - `summary`

## Non-goals
- No new implementation unlock by this addendum alone
- No sign or legal review unlock
- No history or list unlock
- No clause-editor expansion
