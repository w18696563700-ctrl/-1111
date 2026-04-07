---
owner: Codex 总控
status: draft
purpose: Freeze the minimum verification chain required to prove Inspection.passed, Milestone.completed, and Order.completed are reachable without adding app-facing paths.
layer: L0 SSOT
---

# Order.completed 上游最小复验链修正冻结单

## Scope
- This addendum freezes only the minimum verification chain required before the
  upstream completion implementation may be considered implementable.
- It does not unlock implementation by itself.
- It does not freeze the full `Inspection` workflow, rectification workflow,
  recheck workflow, `Rating`, `Dispute`, or `Phase 3`.
- It does not add any new app-facing path.

## Canonical Decisions

### 1. Formal verification order
- The formal fresh-chain verification order is frozen as:
  1. `POST /api/app/project/create`
  2. `POST /api/app/bid/submit`
  3. `POST /api/app/order/create`
  4. `POST /api/app/milestone/submit`
  5. verify that the associated inspection truth already exists and is
     currently `draft`
  6. `POST /api/app/inspection/submit`
  7. verify that the same inspection truth is now `submitted`
  8. invoke the internal `Server` entry
     `InspectionDecisionApplicationService.passInspectionDecision`
  9. verify the downstream branch result and append-only audit evidence
- No other verification order is canonical in this round.

### 2. Branch A: last remaining incomplete milestone
- Branch A is the canonical branch where the target milestone is the last
  remaining incomplete current effective milestone under the order.
- The minimum expected result is:
  - `Inspection.submitted -> Inspection.passed`
  - `Milestone.submitted -> Milestone.completed`
  - `Order.active -> Order.completed`
- The minimum expected audit set is:
  - `InspectionDecisionChanged`
  - `MilestoneCompleted`
  - `OrderCompleted`

### 3. Branch B: not the last remaining incomplete milestone
- Branch B is the canonical branch where at least one other current effective
  milestone under the same order remains incomplete after the target milestone
  completes.
- The minimum expected result is:
  - `Inspection.submitted -> Inspection.passed`
  - `Milestone.submitted -> Milestone.completed`
  - `Order` remains `active`
- The minimum expected audit set is:
  - `InspectionDecisionChanged`
  - `MilestoneCompleted`
  - no `OrderCompleted`

### 4. Minimum evidence checklist for each step
- Step 1 evidence:
  - `projectId`
  - `state=published`
- Step 2 evidence:
  - `bidId`
  - `state=submitted`
- Step 3 evidence:
  - `orderId`
  - `state=active`
- Step 4 evidence:
  - `milestoneId`
  - `state=submitted`
- Step 5 evidence:
  - the inspection truth for that milestone already exists before any passing
    decision
  - the inspection state is `draft`
- Step 6 evidence:
  - `inspectionId`
  - app-facing response aligned with frozen canonical contract
  - inspection state becomes `submitted`
- Step 7 evidence:
  - same `inspectionId`
  - no new duplicate inspection truth row
- Step 8 evidence:
  - the internal entry is invoked exactly once for the target fresh inspection
- Step 9 evidence, Branch A:
  - inspection state `passed`
  - milestone state `completed`
  - order state `completed`
  - audit rows:
    - `InspectionDecisionChanged: submitted -> passed`
    - `MilestoneCompleted: submitted -> completed`
    - `OrderCompleted: active -> completed`
- Step 9 evidence, Branch B:
  - inspection state `passed`
  - milestone state `completed`
  - order state remains `active`
  - audit rows:
    - `InspectionDecisionChanged: submitted -> passed`
    - `MilestoneCompleted: submitted -> completed`
    - no `OrderCompleted`

### 5. Branch construction rule
- Branch A may be verified using the minimum fresh chain where the target
  milestone is the last remaining incomplete current effective milestone.
- Branch B must be verified using a controlled `Server`-side prepared truth
  setup in which:
  - the target order has at least two current effective milestones
  - only one target milestone is driven through the minimum passing decision in
    the verification run
  - at least one other milestone remains incomplete afterward
- Branch B must not be simulated by app-facing path invention.

### 6. No new app-facing path
- This round freezes no new app-facing path for verification.
- The following paths remain explicitly non-existent unless a later truth-freeze
  round adds them:
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
