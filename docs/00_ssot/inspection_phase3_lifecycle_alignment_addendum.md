---
owner: Codex 总控
status: draft
purpose: Align the top-level Milestone and Order lifecycle truth with the already-approved minimum Inspection closed-loop semantics before any Phase 3 implementation unlock.
layer: L0 SSOT
---

# Inspection Phase 3 生命周期总真源对齐冻结单

## Scope
- This addendum resolves only one truth conflict:
  - the mismatch between the top-level `Milestone` and `Order` lifecycle truth
    and the already-frozen minimum Inspection closed-loop semantics.
- It does not unlock implementation by itself.
- It does not reopen any other object.

## Canonical Decisions

### 1. Milestone top-level lifecycle truth
- The canonical top-level `Milestone` lifecycle now aligns to the already-verified
  minimum closed-loop semantics:
  - `pending_submission -> submitted -> completed`
- The following previously listed intermediate states are not part of the current
  canonical top-level truth:
  - `pending_decision`
  - `approved`
  - `rejected`
- If a later phase truly needs those intermediate states, they must be reintroduced
  only through a new dedicated truth freeze.

### 2. Order top-level lifecycle truth
- The canonical top-level `Order` lifecycle now aligns to the already-verified
  minimum closed-loop semantics:
  - `draft -> pending_confirm -> active -> completed | disputed -> archived`
- The previously listed intermediate state:
  - `pending_acceptance`
  is not part of the current canonical top-level truth.
- If a later phase truly needs `pending_acceptance`, it must be reintroduced only
  through a new dedicated truth freeze.

### 3. Current approved minimum execution subpaths
- The currently approved implementation baseline follows these minimum execution
  subpaths only:
  - `Milestone`
    - `pending_submission -> submitted -> completed`
  - `Order`
    - `draft -> pending_confirm -> active -> completed`
- Within the approved `Inspection` Phase 3 minimum closed loop:
  - Branch A:
    - `submitted -> passed`
    - then `Milestone -> completed`
    - and `Order -> completed` only when this is the last incomplete milestone
  - Branch B:
    - `submitted -> rectification_required -> rechecked -> passed`
    - then `Milestone -> completed`
    - and `Order -> completed` only when this is the last incomplete milestone
  - Branch C:
    - `submitted -> rectification_required -> rechecked -> archived`
    - no `MilestoneCompleted`
    - no `OrderCompleted`
    - therefore `Milestone` remains on the current non-completed top-level branch
      and `Order` remains `active`

### 4. Truth-sync impact
- This alignment requires the following truth files to stay in sync:
  - `docs/00_ssot/lifecycle_state_machine.md`
  - `docs/00_ssot/inspection_phase3_decision_addendum.md`
  - `docs/00_ssot/inspection_phase3_lifecycle_alignment_addendum.md`
  - `docs/00_ssot/source_of_truth_map.md`
- No L2 contract file changes are required for this alignment itself.
- No L3 backend, BFF, or frontend truth files require additional changes for this
  alignment itself, because they already follow the minimum closed-loop semantics.

## Rules
- There must not be two concurrent top-level lifecycle truths for `Milestone`.
- There must not be two concurrent top-level lifecycle truths for `Order`.
- Implementation must follow the minimum approved execution subpaths until a later
  dedicated truth freeze explicitly expands them.
