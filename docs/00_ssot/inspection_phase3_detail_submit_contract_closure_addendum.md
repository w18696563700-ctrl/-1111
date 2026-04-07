---
owner: Codex 总控
status: draft
purpose: Close the final L2/L3 contract wording gaps for Inspection Phase 3 detail and submit before any implementation unlock.
layer: L0 SSOT
---

# Inspection Phase 3 detail/submit 契约收口冻结单

## Scope
- This addendum closes only two remaining contract gaps:
  - the residual `Phase 2.3` wording on `inspection/detail`
  - the missing `202` minimum success response schema on `inspection/submit`
- It does not add any new capability.
- It does not unlock implementation by itself.

## Canonical Decisions

### 1. inspection/detail canonical wording
- `GET /api/app/inspection/detail` is no longer described as a pure Phase 2.3
  entry-state detail in the current effective truth.
- Its current canonical meaning is:
  - the minimum Phase 3 Inspection workflow read projection
  - limited to the server-returned current inspection state and minimum summary
  - not a list, history, governance, or multi-round console capability

### 2. inspection/submit 202 minimum success response
- `POST /api/app/inspection/submit` must freeze a minimum `202` success response
  body schema.
- The minimum success response body must contain:
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`
- The canonical success state for this command remains:
  - `submitted`
- This success response is still only the first command handoff in the minimum
  Phase 3 Inspection self-workflow boundary.

### 3. Truth-sync impact
- This contract closure requires the following files to stay in sync:
  - `docs/00_ssot/inspection_phase3_detail_submit_contract_closure_addendum.md`
  - `docs/00_ssot/source_of_truth_map.md`
  - `docs/01_contracts/openapi.yaml`
- `docs/04_frontend/ui_state_contract.md` does not require changes for this
  closure if it already maps submit/recheck success to controlled `content`
  rendering from the server-returned projection.

## Rules
- `inspection/recheck` remains the only new Phase 3 app-facing inspection path.
- `inspection/detail`, `inspection/submit`, and `inspection/recheck` together form
  the current Phase 3 minimum app-facing Inspection surface.
- This closure must not reopen any other object and must not expand scope.
