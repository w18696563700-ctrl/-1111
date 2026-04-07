---
owner: Codex 总控
status: draft
purpose: Freeze the minimum upstream semantic chain required for Order.completed to become a real, reachable, verifiable event.
layer: L0 SSOT
---

# Order.completed 上游事件决策补充单

## Scope
- This addendum freezes only the minimum upstream semantics required to make
  `Order.completed` a real future target event.
- It does not unlock any implementation by itself.
- It does not freeze the full `Inspection` workflow, rectification workflow,
  recheck workflow, `Dispute`, or `Phase 3`.

## Canonical Decisions

### 1. Inspection.passed minimum semantics
- `Inspection.passed` is the minimum positive acceptance outcome for the current
  inspection entry after `Inspection.submitted`.
- It means the associated inspection has passed the minimum acceptance decision
  boundary and no rectification is required for that accepted entry.
- It does not freeze:
  - rectification semantics
  - recheck semantics
  - full inspection decision matrix

### 2. Milestone.completed minimum entry condition
- `Milestone.completed` may be entered only after the current effective
  inspection for that milestone reaches `passed`.
- `Milestone.completed` must be derived or transitioned by `Server` only.
- `Milestone.completed` must not be created by:
  - Flutter App
  - BFF
  - ad-hoc admin shortcuts outside a later truth freeze
- A milestone without a `passed` inspection may not enter `completed`.

### 3. Order.completed minimum aggregation rule
- `Order.completed` may be entered only when every current effective milestone
  under that order is already in `completed`.
- Partial milestone completion must not complete the order.
- The minimum aggregate trigger is:
  - the last remaining incomplete milestone first enters `completed`
- `Order.completed` must be derived by `Server` only.

### 4. Minimum audit boundary for the upstream chain
- The minimum append-only audit actions for this upstream chain are:
  - `InspectionDecisionChanged` with the minimum passing transition
    `submitted -> passed`
  - `MilestoneCompleted`
  - `OrderCompleted`
- Existing `InspectionSubmitted` remains valid, but this addendum freezes only
  the additional minimum audit boundary needed to make `Order.completed`
  verifiable.

### 5. Minimum error-code boundary
- The minimum error-code boundary for this upstream chain is:
  - `INSPECTION_DECISION_INVALID_STATE`
  - `MILESTONE_COMPLETE_INVALID_STATE`
  - `ORDER_COMPLETE_INVALID_STATE`
- Meanings:
  - `INSPECTION_DECISION_INVALID_STATE`
    - the current inspection may not enter the minimum passing transition from
      its current state
  - `MILESTONE_COMPLETE_INVALID_STATE`
    - the current milestone may not enter `completed`, including the case where
      its effective inspection has not yet reached `passed`
  - `ORDER_COMPLETE_INVALID_STATE`
    - the current order may not enter `completed`, including the case where not
      every current effective milestone is already `completed`

### 6. Paths that do not exist in this freeze
- No app-facing path is frozen in this round for:
  - `POST /api/app/inspection/pass`
  - `POST /api/app/inspection/decision`
  - `POST /api/app/milestone/complete`
  - `POST /api/app/order/complete`
- No BFF alias or Flutter-consumable canonical path may be assumed for those
  transitions unless a later truth-freeze round explicitly adds them.

## Non-goals
- No unlock of `Inspection` full workflow
- No freeze of rectification or recheck flow
- No unlock of `Rating` implementation
- No unlock of `Dispute`
- No `Phase 3` work
