---
owner: Codex 总控
status: draft
purpose: Freeze the Contract-only Phase 3 workflow boundary before any implementation unlock.
layer: L0 SSOT
---

# Contract Phase 3 单对象决策补充单

## Scope
- This addendum applies only to `Contract` in `Phase 3` planning.
- `full workflow` in this addendum means only the minimum self-contained `Contract`
  workflow.
- It does not automatically include:
  - full clause-editor design
  - multi-version amendment system
  - legal-review collaboration workflow
  - history, list, or reporting
  - deep external e-sign platform integration
- This addendum does not unlock implementation by itself.

## Canonical Decisions

### 1. Full workflow formal boundary
- `Contract` Phase 3 planning is limited to one minimum self-contained workflow:
  - contract detail read projection
  - first confirm handoff
  - one minimum amendment handoff
  - amended read projection
- This boundary does not include:
  - structured clause editing UI design
  - external signing workflow
  - legal review workflow
  - amendment history or list views
  - multi-round amendment negotiation

### 2. First-round main loop
- The first Phase 3 main loop is:
  - `GET /api/app/contract/detail`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
  - `GET /api/app/contract/detail`
- The main loop is single-threaded and single-amendment only.
- `confirm` remains the entry handoff into the contract workflow.
- `amend` is the only new app-facing workflow command considered in this Phase 3 plan.

### 3. Contract state diagram
- The canonical top-level `Contract` lifecycle remains:
  - `draft -> pending_confirm -> active -> amended -> archived`
- The first approved implementation subpath for Phase 3 planning is:
  - `pending_confirm -> active -> amended`
- `draft` remains a materialized truth state and is not a new app-facing command state.
- `archived` remains outside the first-round main loop.

### 4. Allowed and forbidden app-facing paths
- Allowed in Phase 3 planning:
  - `GET /api/app/contract/detail`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
- Explicitly not allowed:
  - `POST /api/app/contract/create`
  - `GET /api/app/contract/clauses`
  - `POST /api/app/contract/sign`
  - `GET /api/app/contract/history`
  - `GET /api/app/contract/list`
  - `POST /api/app/contract/legal-review`
  - any external signing callback or provider-specific contract path

### 5. Minimum error-code boundary
- `CONTRACT_ENTRY_UNAVAILABLE`
  - use when detail entry truth is absent or not yet available
- `CONTRACT_CONFIRM_INVALID`
  - use when the confirm request body is invalid
- `CONTRACT_INVALID_STATE`
  - use when confirm or amend is not allowed from the current contract state
- `CONTRACT_AMEND_INVALID`
  - use when the amend request body is invalid or missing minimum required fields
- `CONTRACT_AMEND_LIMIT_REACHED`
  - use when the first-round single-amendment ceiling would be exceeded

### 6. Minimum audit boundary
- `ContractConfirmed`
  - before: `pending_confirm`
  - after: `active`
- `ContractAmended`
  - before: `active`
  - after: `amended`

### 7. Fresh-chain verification checklist
- Branch A: confirm-only path
  - start from a fresh `Project -> Bid -> Order` chain
  - verify `Order.state = active`
  - verify `Contract.state = pending_confirm`
  - `GET /api/app/contract/detail -> 200`
  - `POST /api/app/contract/confirm -> 202`
  - verify `Contract.state = active`
  - verify exactly one `ContractConfirmed`
- Branch B: confirm then amend path
  - start from a fresh `Project -> Bid -> Order` chain, or continue from a fresh
    Branch A chain before any amendment exists
  - verify `Contract.state = active`
  - `POST /api/app/contract/amend -> 202`
  - verify `Contract.state = amended`
  - verify exactly one `ContractAmended`
- Branch C: invalid amendment branch
  - attempt a second amend after the contract is already `amended`, or attempt amend
    before `active`
  - expect `409`
  - expect `CONTRACT_INVALID_STATE` or `CONTRACT_AMEND_LIMIT_REACHED`
  - verify no new `ContractAmended` audit is appended

## Non-goals
- No clause editor full design
- No signature workflow unlock
- No legal review workflow unlock
- No amendment history or reporting
- No multi-version amendment system
