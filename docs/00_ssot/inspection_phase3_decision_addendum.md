---
owner: Codex 总控
status: draft
purpose: Freeze the Inspection-only Phase 3 semantic decisions before any full-workflow implementation unlock.
layer: L0 SSOT
---

# Inspection Phase 3 单对象决策补充单

## Scope
- This addendum applies only to `Inspection` in `Phase 3` planning.
- It freezes the minimum full closed-loop boundary for `Inspection` only.
- It does not unlock implementation by itself.
- Detailed trigger-role and recheck-contract semantics are governed by:
  - `docs/00_ssot/inspection_phase3_trigger_recheck_contract_addendum.md`
- Top-level `Milestone` and `Order` lifecycle alignment for this Phase 3 minimum
  closed loop is governed by:
  - `docs/00_ssot/inspection_phase3_lifecycle_alignment_addendum.md`
- The `full workflow` in this document means only the minimum `Inspection` closed loop.
- It does not automatically include:
  - list
  - history
  - governance expansion
  - platform adjudication
  - cross-object workflow expansion

## Canonical Decisions

### 1. Phase 3 full workflow boundary
- `Inspection` Phase 3 reopens only the minimum acceptance closed loop:
  - entry detail
  - first submit
  - one controlled decision
  - at most one rectification round
  - at most one recheck round
  - final close as `passed` or `archived`
- It does not reopen:
  - multi-round rectification
  - multi-round recheck
  - inspection list
  - inspection history
  - platform governance or arbitration

### 2. Formal state graph
- Canonical Phase 3 inspection graph:
  - `draft -> submitted`
  - first decision:
    - `submitted -> passed`
    - `submitted -> rectification_required`
  - rectification resubmission:
    - `rectification_required -> rechecked`
  - final decision after recheck:
    - `rechecked -> passed`
    - `rechecked -> archived`
- The graph may not loop back into:
  - a second `rectification_required`
  - a second `rechecked`
- Phase 3 supports:
  - at most one rectification round
  - at most one recheck round

### 3. Maximum rectification / recheck rounds
- Maximum rectification rounds:
  - `1`
- Maximum recheck rounds:
  - `1`
- A second rectification or second recheck attempt is outside Phase 3 scope and must be rejected as controlled invalid-state behavior.

### 4. Allowed and forbidden paths
- Allowed app-facing paths at the Phase 3 planning ceiling:
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`
  - `POST /api/app/inspection/recheck`
- Internal-only controlled decision entry:
  - Server-internal inspection decision entry remains internal and is not an app-facing path.
- Forbidden app-facing paths:
  - `POST /api/app/inspection/create`
  - `POST /api/app/inspection/approve`
  - `POST /api/app/inspection/reject`
  - `GET /api/app/inspection/history`
  - `GET /api/app/inspection/list`
  - `POST /api/app/inspection/review`

### 5. Minimum error codes
- Existing minimum codes still apply:
  - `INSPECTION_ENTRY_UNAVAILABLE`
  - `INSPECTION_SUBMIT_INVALID`
  - `INSPECTION_INVALID_STATE`
  - `INSPECTION_DECISION_INVALID_STATE`
  - `MILESTONE_COMPLETE_INVALID_STATE`
  - `ORDER_COMPLETE_INVALID_STATE`
- New minimum Phase 3 codes:
  - `INSPECTION_RECHECK_INVALID`
  - `INSPECTION_RECHECK_LIMIT_REACHED`

### 6. Minimum audit actions
- Existing minimum audit actions still apply:
  - `InspectionSubmitted`
  - `InspectionDecisionChanged`
  - `MilestoneCompleted`
  - `OrderCompleted`
- New minimum Phase 3 audit action:
  - `InspectionRecheckSubmitted`
- Minimum before/after semantics:
  - `InspectionSubmitted`
    - before: `draft`
    - after: `submitted`
  - `InspectionDecisionChanged`
    - before: `submitted`
    - after: `passed`
  - `InspectionDecisionChanged`
    - before: `submitted`
    - after: `rectification_required`
  - `InspectionRecheckSubmitted`
    - before: `rectification_required`
    - after: `rechecked`
  - `InspectionDecisionChanged`
    - before: `rechecked`
    - after: `passed`
  - `InspectionDecisionChanged`
    - before: `rechecked`
    - after: `archived`

### 7. Fresh chain verification branches and evidence
- Branch A: direct pass
  - fresh chain:
    - `project/create`
    - `bid/submit`
    - `order/create`
    - `milestone/submit`
    - `inspection/detail`
    - `inspection/submit`
    - internal decision: `submitted -> passed`
  - minimum evidence:
    - fresh IDs for project, bid, order, milestone, inspection
    - inspection state = `passed`
    - milestone state = `completed`
    - if this is the last incomplete milestone, order state = `completed`
    - audits:
      - `InspectionSubmitted`
      - `InspectionDecisionChanged: submitted -> passed`
      - `MilestoneCompleted`
      - optional `OrderCompleted` when last milestone
- Branch B: rectification then pass
  - fresh chain:
    - `project/create`
    - `bid/submit`
    - `order/create`
    - `milestone/submit`
    - `inspection/detail`
    - `inspection/submit`
    - internal decision: `submitted -> rectification_required`
    - app-facing `inspection/recheck`
    - internal decision: `rechecked -> passed`
  - minimum evidence:
    - inspection state = `passed`
    - exactly one rectification round
    - exactly one recheck round
    - audits:
      - `InspectionSubmitted`
      - `InspectionDecisionChanged: submitted -> rectification_required`
      - `InspectionRecheckSubmitted: rectification_required -> rechecked`
      - `InspectionDecisionChanged: rechecked -> passed`
      - `MilestoneCompleted`
      - optional `OrderCompleted` when last milestone
- Branch C: rectification then final close without pass
  - fresh chain:
    - same setup as Branch B
    - internal final decision: `rechecked -> archived`
  - minimum evidence:
    - inspection state = `archived`
    - no second rectification
    - no second recheck
    - no `MilestoneCompleted`
    - no `OrderCompleted`
    - audits:
      - `InspectionSubmitted`
      - `InspectionDecisionChanged: submitted -> rectification_required`
      - `InspectionRecheckSubmitted: rectification_required -> rechecked`
      - `InspectionDecisionChanged: rechecked -> archived`

## Non-goals
- No inspection list or history
- No multi-round rectification
- No multi-round recheck
- No platform governance expansion
- No `Rating` or `Dispute` reopen
- No `Contract` reopen
