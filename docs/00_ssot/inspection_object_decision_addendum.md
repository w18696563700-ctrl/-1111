---
owner: Codex 总控
status: draft
purpose: Freeze the Inspection-only semantic decisions that must be resolved before any next-round implementation unlock.
layer: L0 SSOT
---

# Inspection 单对象决策补充单

## Scope
- This addendum applies only to `Inspection`.
- It clarifies the canonical semantics required before any next-round Inspection implementation unlock.
- It does not unlock implementation by itself.
- This addendum remains the Phase 2.x entry-stage baseline only.
- Phase 3 planning and any future minimum full-workflow semantics are governed by:
  - `docs/00_ssot/inspection_phase3_decision_addendum.md`

## Canonical Decisions

### 1. Inspection business semantics
- `Inspection` is the buyer-side acceptance intake entry after `Milestone.submitted`.
- It is the first controlled handoff into post-delivery acceptance handling.
- It is not the rectification workflow, recheck workflow, or final decision workflow.

### 2. Inspection truth materialization owner and trigger
- `Inspection` truth must be materialized by `Server` only.
- `Inspection` truth must not be created by:
  - Flutter App
  - BFF
  - `GET /api/app/inspection/detail`
  - a new app-facing `POST /api/app/inspection/create`
- Recommended trigger:
  - Server materializes `Inspection` truth automatically when `Milestone` first enters the allowed inspection-entry state.
- Current canonical expectation:
  - `Milestone.state = submitted` is the minimum inspection-entry state for the next round.
- New materialized `Inspection` truth must start in:
  - `draft`
- For the current effective truth boundary:
  - one `milestoneId` may correspond to at most one current effective `Inspection` truth
  - materialization must be idempotent
  - repeated reads or repeated entry checks may not create duplicate inspection truth

### 3. GET lazy creation is not accepted
- `GET /api/app/inspection/detail` may not lazily create inspection truth as canonical product semantics.
- Phase 2.3 runtime behavior is treated as transitional only and must not be preserved as the next-round product contract.

### 4. Inspection detail behavior when truth is absent
- `GET /api/app/inspection/detail?milestoneId=...` must not create truth as a side effect.
- If inspection truth is absent when the entry is requested, the canonical response must be a controlled unavailable semantic.
- The minimum error code for that condition is:
  - `INSPECTION_ENTRY_UNAVAILABLE`

### 5. Frontend controlled-state mapping
- `INSPECTION_ENTRY_UNAVAILABLE` must map to:
  - `error_non_retryable`
- Frontend may describe the state as inspection entry unavailable, but may not promise that opening the page creates the inspection.

### 6. Allowed next-round scope ceiling
- Even if the next round unlocks `Inspection`, the maximum allowed scope is:
  - `entry + minimal action`
- The next round may not expand `Inspection` to:
  - full workflow
  - approval / rejection decision flow
  - rectification flow
  - recheck flow
  - inspection history or governance flow
- This ceiling applies to the pre-Phase 3 entry-stage expansion only and is superseded
  by the dedicated Phase 3 planning addendum when Phase 3 truth freeze begins.

## Allowed and Forbidden Paths
- Allowed:
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`
- Forbidden:
  - `POST /api/app/inspection/create`
  - `POST /api/app/inspection/approve`
  - `POST /api/app/inspection/reject`
  - `POST /api/app/inspection/recheck`
  - `GET /api/app/inspection/rectification`
  - `GET /api/app/inspection/history`

## Minimum Audit Boundary
- The minimum audit action remains:
  - `InspectionSubmitted`

## Non-goals
- No client-created inspection truth
- No BFF-created inspection truth
- No GET-triggered truth creation
- No approval / rejection / rectification / recheck workflow unlock
