---
owner: Codex 总控
status: draft
purpose: Freeze the minimum controlled trigger entry that may advance Inspection.passed, Milestone.completed, and Order.completed.
layer: L0 SSOT
---

# Order.completed 上游最小触发入口冻结单

## Scope
- This addendum freezes only the minimum controlled trigger entry required to
  make the upstream completion chain executable in a future round.
- It does not unlock implementation by itself.
- It does not freeze the full `Inspection` workflow, rectification workflow,
  recheck workflow, `Rating`, `Dispute`, or `Phase 3`.

## Canonical Decisions

### 1. Inspection.passed unique minimum trigger entry
- The unique minimum trigger entry for `Inspection.passed` is a controlled
  internal `Server` inspection decision entry.
- This entry is not an app-facing canonical path in the current round.
- This entry represents only the minimum positive decision
  `Inspection.submitted -> Inspection.passed`.
- It must not be expanded in this round into:
  - full inspection decision matrix
  - reject flow
  - rectification flow
  - recheck flow

### 2. Entry type and path boundary
- The minimum trigger entry is frozen as an internal `Server`-side controlled
  entry only.
- No new app-facing path is added in this round.
- The following paths remain explicitly non-existent unless a later truth freeze
  adds them:
  - `POST /api/app/inspection/pass`
  - `POST /api/app/inspection/decision`
  - `POST /api/app/milestone/complete`
  - `POST /api/app/order/complete`

### 3. Who may trigger the entry
- The trigger actor is a controlled backend-side reviewer or operator role using
  a future controlled `Server` internal entry.
- `Flutter App` must not trigger this entry.
- `BFF` must not own or synthesize this decision.
- Ad-hoc shortcuts outside a later truth freeze are forbidden.

### 4. Downstream synchronous derivation rule
- Once the minimum passing decision is accepted by the `Server`, the same truth
  flow must synchronously evaluate downstream completion derivation.
- Minimum synchronous derivation rule:
  - first advance the current inspection to `passed`
  - then derive the associated milestone to `completed`
  - then, if that milestone is the last remaining incomplete current effective
    milestone under the order, derive the order to `completed`
- Partial downstream derivation is forbidden:
  - `Inspection.passed` without evaluating `Milestone.completed`
  - `Milestone.completed` without evaluating `Order.completed`

### 5. Minimum error-code boundary for the trigger chain
- The minimum error-code boundary for this trigger chain is:
  - `INSPECTION_DECISION_INVALID_STATE`
  - `MILESTONE_COMPLETE_INVALID_STATE`
  - `ORDER_COMPLETE_INVALID_STATE`
- No additional error-code namespace is frozen in this round.

### 6. Minimum audit boundary for the trigger chain
- The minimum append-only audit actions for this trigger chain are:
  - `InspectionDecisionChanged`
  - `MilestoneCompleted`
  - `OrderCompleted`
- The minimum positive passing transition frozen in this round is:
  - `InspectionDecisionChanged` with `submitted -> passed`

## Non-goals
- No unlock of `Inspection` full workflow
- No unlock of rectification or recheck flow
- No unlock of `Rating`
- No unlock of `Dispute`
- No new app-facing path
- No `Phase 3` work
