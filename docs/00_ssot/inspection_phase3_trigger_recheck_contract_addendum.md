---
owner: Codex 总控
status: draft
purpose: Freeze the Phase 3 Inspection decision trigger and recheck contract details before any implementation unlock.
layer: L0 SSOT
---

# Inspection Phase 3 触发与 recheck 契约冻结单

## Scope
- This addendum applies only to `Inspection` in `Phase 3` planning.
- It fills the remaining trigger and recheck contract gaps that must be frozen before any Phase 3 implementation unlock.
- It does not unlock implementation by itself.

## Canonical Decisions

### 1. Decision trigger role and entry
- The unique canonical internal decision entry for `Inspection` Phase 3 is:
  - `InspectionDecisionApplicationService.applyInspectionDecision`
- This entry is:
  - `Server`-internal only
  - not app-facing
  - not exposed through BFF
  - not callable by Flutter App
- The only trigger role for this internal entry is:
  - `operator`
- The minimum supported decision set is:
  - `pass`
  - `require_rectification`
  - `archive_after_recheck`
- The previously frozen upstream-only internal entry:
  - `InspectionDecisionApplicationService.passInspectionDecision`
  remains the pre-Phase 3 subset binding for the minimum upstream completion path and
  must be treated as the `pass` subset of the broader Phase 3 decision contract.

### 2. inspection/recheck caller role
- `POST /api/app/inspection/recheck` is an app-facing path.
- Its caller role boundary is:
  - `supplier_admin`: allow
  - `supplier_member`: scoped
- The following roles may not call this path as a Phase 3 canonical action:
  - `buyer_admin`
  - `buyer_member`
  - any platform role
- `inspection/recheck` is the supplier-side resubmission handoff after the current
  inspection has already entered `rectification_required`.

### 3. inspection/recheck success contract
- Canonical response code:
  - HTTP `202`
- Minimum success response body:
  ```json
  {
    "inspectionId": "string",
    "milestoneId": "string",
    "state": "rechecked",
    "summary": {}
  }
  ```
- The minimum response body must contain:
  - `inspectionId`
  - `milestoneId`
  - `state`
  - `summary`
- The canonical success state for this command is:
  - `rechecked`

### 4. Error-code boundary for recheck
- `INSPECTION_RECHECK_INVALID`
  - use when the recheck request body itself is invalid
  - examples:
    - missing `inspectionId`
    - malformed request body
    - request violates minimum recheck input boundary
- `INSPECTION_INVALID_STATE`
  - use when inspection truth exists, but the current inspection state does not allow
    `rectification_required -> rechecked`
  - examples:
    - `draft`
    - `submitted`
    - `passed`
    - `archived`
- `INSPECTION_RECHECK_LIMIT_REACHED`
  - use when the request is otherwise valid, but Phase 3's workflow ceiling would be
    exceeded
  - examples:
    - second recheck attempt
    - second rectification cycle attempt

## Non-goals
- No app-facing decision path
- No buyer-side or platform-side app-facing recheck trigger
- No multi-round rectification or multi-round recheck
- No governance expansion
