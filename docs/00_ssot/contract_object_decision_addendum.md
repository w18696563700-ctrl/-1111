---
owner: Codex 总控
status: draft
purpose: Freeze the Contract-only semantic decisions that must be resolved before any next-round implementation unlock.
layer: L0 SSOT
---

# Contract 单对象决策补充单

## Scope
- This addendum applies only to `Contract`.
- It clarifies the canonical semantics required before any next-round Contract implementation unlock.
- It does not unlock implementation by itself.

## Canonical Decisions

### 1. GET lazy creation is not accepted
- `GET /api/app/contract/detail` may not lazily create contract truth as canonical product semantics.
- Phase 2.3 runtime behavior is treated as transitional only and must not be preserved as the next-round product contract.

### 2. Contract truth materialization owner and trigger
- `Contract` truth must be materialized by `Server` only.
- `Contract` truth must not be created by:
  - Flutter App
  - BFF
  - `GET /api/app/contract/detail`
  - a new app-facing `POST /api/app/contract/create`
- Recommended trigger:
  - Server materializes `Contract` truth automatically when `Order` enters the allowed contract-entry state.
- Current canonical expectation:
  - `Order.state = active` is the minimum contract-entry state for the next round.

### 3. Contract detail behavior when truth is absent
- `GET /api/app/contract/detail?orderId=...` must not create truth as a side effect.
- If contract truth is absent when the entry is requested, the canonical response must be a controlled unavailable semantic.
- The minimum error code for that condition is:
  - `CONTRACT_ENTRY_UNAVAILABLE`

### 4. Frontend controlled-state mapping
- `CONTRACT_ENTRY_UNAVAILABLE` must map to:
  - `error_non_retryable`
- Frontend may describe the state as contract entry unavailable, but may not promise that opening the page creates the contract.

### 5. Allowed next-round scope ceiling
- Even if the next round unlocks `Contract`, the maximum allowed scope is:
  - `entry + minimal action`
- The next round may not expand `Contract` to:
  - full workflow
  - clause editing
  - signature flow
  - amendment flow

## Allowed and Forbidden Paths
- Allowed:
  - `GET /api/app/contract/detail`
  - `POST /api/app/contract/confirm`
- Forbidden:
  - `POST /api/app/contract/create`
  - `GET /api/app/contract/clauses`
  - `POST /api/app/contract/sign`
  - `POST /api/app/contract/amend`

## Non-goals
- No client-created contract truth
- No BFF-created contract truth
- No GET-triggered truth creation
- No full contract workflow unlock
