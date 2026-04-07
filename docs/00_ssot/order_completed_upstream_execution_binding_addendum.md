---
owner: Codex 总控
status: draft
purpose: Freeze the unique internal execution binding required to make the Order.completed upstream chain implementable in a future round.
layer: L0 SSOT
---

# Order.completed 上游内部承接方式冻结单

## Scope
- This addendum freezes only the minimum internal execution binding needed to
  make the upstream chain `Inspection.passed -> Milestone.completed ->
  Order.completed` implementable in a future round.
- It does not unlock implementation by itself.
- It does not freeze the full `Inspection` workflow, rectification workflow,
  recheck workflow, `Rating`, `Dispute`, or `Phase 3`.

## Canonical Decisions

### 1. Unique internal ownership module
- The unique internal ownership module for the minimum passing decision is the
  `Inspection` module.
- `Milestone` and `Order` remain downstream truth owners for their own derived
  states, but the minimum passing decision must not be owned by those modules.

### 2. Unique internal entry name
- The unique internal entry name is frozen as:
  - `InspectionDecisionApplicationService.passInspectionDecision`
- This is a controlled internal `Server` entry only.
- This entry is not an app-facing canonical path in the current round.

### 3. Unique trigger actor
- The unique trigger actor frozen in this round is:
  - `operator`
- `Flutter App` must not trigger this entry.
- `BFF` must not trigger or synthesize this decision.
- `internal task` is not the canonical trigger actor in this round.

### 4. Idempotency and invalid-state rules
- If the current effective inspection is already `passed`, a repeated positive
  decision through the same internal entry must be treated as an idempotent
  no-op.
- An idempotent repeated decision must not:
  - append a second `InspectionDecisionChanged`
  - append a second `MilestoneCompleted`
  - append a second `OrderCompleted`
  - generate a second downstream state transition
- If the current effective inspection truth does not exist, the minimum error is:
  - `INSPECTION_ENTRY_UNAVAILABLE`
- If the current effective inspection is neither `submitted` nor already
  `passed`, the minimum error is:
  - `INSPECTION_DECISION_INVALID_STATE`
- If downstream derivation finds that the milestone may not enter `completed`,
  the minimum error is:
  - `MILESTONE_COMPLETE_INVALID_STATE`
- If downstream derivation finds that the order may not enter `completed`, the
  minimum error is:
  - `ORDER_COMPLETE_INVALID_STATE`

### 5. Same truth-flow synchronous derivation
- The minimum positive decision must synchronously advance within the same
  `Server` truth flow:
  - `Inspection.submitted -> Inspection.passed`
  - `Milestone.submitted -> Milestone.completed`
  - `Order.active -> Order.completed`, but only if the milestone is the last
    remaining incomplete current effective milestone under the order
- It is forbidden to accept the passing decision without synchronously
  evaluating downstream milestone and order completion derivation.

### 6. Fresh-chain minimum verification entry and method
- No new app-facing path is added in this round.
- The fresh-chain setup remains:
  - `POST /api/app/project/create`
  - `POST /api/app/bid/submit`
  - `POST /api/app/order/create`
  - `POST /api/app/milestone/submit`
- The minimum verification entry after that setup is the internal `Server`
  entry:
  - `InspectionDecisionApplicationService.passInspectionDecision`
- The minimum verification method is:
  - create a fresh upstream chain through the existing app-facing paths
  - locate the freshly materialized inspection truth for the new milestone
  - invoke the internal entry once for that fresh inspection
  - verify state transitions and append-only audit evidence in the same chain

### 7. Minimum error-code set
- The minimum error-code set for this internal execution binding is:
  - `INSPECTION_ENTRY_UNAVAILABLE`
  - `INSPECTION_DECISION_INVALID_STATE`
  - `MILESTONE_COMPLETE_INVALID_STATE`
  - `ORDER_COMPLETE_INVALID_STATE`
- No new error code is added in this round.

### 8. Minimum audit actions and before/after semantics
- The minimum append-only audit actions are:
  - `InspectionDecisionChanged`
  - `MilestoneCompleted`
  - `OrderCompleted`
- Their minimum before/after semantics are frozen as:
  - `InspectionDecisionChanged`: `submitted -> passed`
  - `MilestoneCompleted`: `submitted -> completed`
  - `OrderCompleted`: `active -> completed`
- An idempotent repeated passing decision must not append duplicate audit rows.

## Explicit Non-existence Rule
- The following app-facing paths remain explicitly non-existent unless a later
  truth-freeze round adds them:
  - `POST /api/app/inspection/pass`
  - `POST /api/app/inspection/decision`
  - `POST /api/app/milestone/complete`
  - `POST /api/app/order/complete`

## Non-goals
- No unlock of `Inspection` full workflow
- No unlock of rectification or recheck flow
- No unlock of `Rating`
- No unlock of `Dispute`
- No reopen of `Contract`
- No `Phase 3` work
