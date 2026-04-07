---
owner: Codex 总控
status: draft
purpose: Freeze the single current-stage exhibition private workbench summary path, container boundary, and truth-owner boundary.
layer: L0 SSOT
---

# Exhibition Workbench Summary Baseline Addendum

## Scope
- This addendum freezes only the current exhibition private-continuation
  workbench summary.
- It freezes one app-facing read-only summary path only:
  - `GET /api/app/exhibition/workbench`
- It exists to let the exhibition private continuation face consume one minimum
  summary projection without reopening a second dashboard workflow.
- It does not create business truth.
- It does not create a second state machine.
- It does not unlock implementation by itself.

## Canonical Path and Projection Role
- The only current private workbench summary path is:
  - `GET /api/app/exhibition/workbench`
- This path is a controlled `BFF` summary projection only.
- It is not the truth owner for:
  - `Project`
  - `Order`
  - `Contract`
  - `Milestone`
  - `Inspection`
  - `Rating`
  - `Dispute`
- It may reuse already frozen business IDs and current truth states only as
  workbench summary carriers.
- It must not freeze any second domain workflow model.

## Canonical Container Set
- The workbench summary freezes exactly four private-continuation containers:
  - `project_chain`
  - `order_chain`
  - `fulfillment_chain`
  - `extension_boundary`
- No fifth container, dashboard pane, governance queue, or history/list/reporting
  surface is frozen here.

## project_chain Boundary
- `project_chain` is a controlled workbench summary carrier only.
- Its current allowed carriers are:
  - `hasProjects`
  - `recentProjectId`
  - `recentProjectTitle`
  - `canCreateProject`
  - `canOpenProjectPool`
- Allowed workbench actions:
  - create project
  - open project pool
- Hidden workbench actions:
  - direct bid submit from the workbench summary itself
  - project publish or award actions
  - project collaboration controls
  - second project dashboard states
- `recentProjectId` and `recentProjectTitle` may expose the current recent
  project context only; they do not freeze a second project-detail truth.

## order_chain Boundary
- `order_chain` is a controlled workbench summary carrier only.
- Its current allowed carriers are:
  - `activeOrderId`
  - `activeOrderNo`
  - `activeOrderState`
  - `canOpenOrderDetail`
  - `canOpenContractDetail`
  - `canOpenDisputeOpen`
- Allowed workbench actions:
  - open order detail
  - open contract detail
  - open dispute-open entry
- Hidden workbench actions:
  - rating submit
  - dispute withdraw
  - contract history or list
  - change-order or second order workflow actions
- `activeOrderId` is the only current continuable order instance carrier in this
  summary container.

## fulfillment_chain Boundary
- `fulfillment_chain` is a controlled workbench summary carrier only.
- Its current allowed carriers are:
  - `activeMilestoneId`
  - `activeMilestoneTitle`
  - `inspectionState`
  - `canOpenMilestoneList`
  - `canOpenMilestoneSubmit`
  - `canOpenInspectionDetail`
  - `canOpenInspectionSubmit`
- Allowed workbench actions:
  - open milestone list
  - open milestone submit
  - open inspection detail
  - open inspection submit
- Hidden workbench actions:
  - inspection recheck
  - inspection list or history
  - platform-side decision controls
  - governance queue or multi-round workflow consoles
- `activeMilestoneId` is the only current continuable fulfillment instance
  carrier in this summary container.
- `inspectionState` is a projected current inspection truth indicator only; it
  must not become a second inspection state machine.

## extension_boundary Boundary
- `extension_boundary` is a controlled workbench boundary carrier only.
- It reuses the current `order_chain.activeOrderId` context and must not freeze
  a second extension carrier.
- Its current allowed carriers are:
  - `canOpenContractDetail`
  - `ratingEntryState`
  - `canOpenDisputeOpen`
  - `disputeWithdrawState`
- Allowed workbench actions:
  - open contract detail
  - open dispute-open entry
- Hidden workbench actions:
  - rating submit
  - inspection recheck
  - dispute withdraw
  - rating detail, history, list, moderation, or review surfaces
  - dispute detail, list, escalation, resolution, or governance surfaces
- `ratingEntryState` is a boundary-state carrier only:
  - it may show `controlled_unavailable`
  - or `extension_only`
- `ratingEntryState` does not make `rating/submit` part of the current
  first-release workbench action set.
- `disputeWithdrawState` remains:
  - `frozen`

## Current First-release Boundary Alignment
- Current first-release private workbench actions must stay aligned with the
  default minimum smoke corridor and current first-release happy-path boundary.
- Therefore:
  - `rating` happy-path is not part of current workbench executable actions
  - `inspection/recheck` is not part of current workbench executable actions
  - `dispute/withdraw` is not part of current workbench executable actions

## Authority and Boundary Map
- `docs/00_ssot/current_stage_mainline_blueprint_addendum.md`
  - owns the current approved mainline and first-release happy-path scope
- `docs/01_contracts/openapi.yaml`
  - owns the app-facing path and field-level contract for the workbench summary
- `docs/03_bff/bff_routes.md`
  - owns `BFF` shaping and route-group boundary
- `docs/04_frontend/flutter_screen_map.md`
  - owns workbench route responsibility and consumer boundary
- `docs/04_frontend/ui_state_contract.md`
  - owns UI-state mapping and non-domain state limits
- `docs/01_contracts/openapi.yaml`, `docs/02_backend/db_schema.md`, and
  per-object addenda continue to own all business truth outside this summary
  carrier.

## Non-goals
- No business truth creation
- No second workflow state machine
- No new history, detail, list, reporting, or governance console surface
- No rating happy-path unlock on the workbench
- No inspection recheck unlock on the workbench
- No dispute withdraw unlock on the workbench
- No implementation unlock by this document alone
