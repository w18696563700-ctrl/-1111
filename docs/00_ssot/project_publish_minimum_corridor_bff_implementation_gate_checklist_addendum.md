---
owner: Codex 总控
status: frozen
purpose: Freeze the stage gate checklist for the project publish minimum-corridor BFF implementation round only, after backend truth implementation has been completed and independently reviewed at source level.
layer: L0 SSOT
gate_basis:
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_minimum_corridor_backend_truth_implementation_gate_checklist_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_backend_truth_implementation_receipt.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_truth_map_and_preclosure_addendum.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-02
---

# 项目发布最小走廊 BFF 实现轮阶段门禁核查表

## 1. Scope

- Current stage object:
  - `项目发布最小走廊 / BFF implementation round`
- This stage applies only to:
  - app-facing to internal truth mapping in `apps/bff/src/**` for:
    - `POST /api/app/project/create`
    - `GET /api/app/project/detail`
    - `POST /api/app/file/upload/init`
    - `POST /api/app/file/upload/confirm`
  - current BFF route/module wiring needed by the above four paths only
  - current BFF request shaping, response shaping, and controlled failure
    mapping needed by the above four paths only
- This stage does not unlock:
  - Flutter App implementation
  - Admin implementation
  - integration verification
  - deployment
  - release-prep
  - release execution
  - forum / enterprise_hub / bid / order / contract / milestone /
    inspection / rating / dispute expansion

## 2. Gate Basis

- Current gate basis is frozen against:
  - `AGENTS.md`
  - `docs/00_ssot/gate_register_v1.md`
  - `docs/00_ssot/control_priority_ruling_round0_global_veto_vs_project_publish_board_freeze_chain_addendum.md`
  - `docs/00_ssot/project_publish_minimum_corridor_truth_map_and_preclosure_addendum.md`
  - `docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md`
  - `docs/00_ssot/project_publish_minimum_corridor_backend_truth_implementation_receipt.md`
  - `docs/01_contracts/openapi.yaml`

## 3. Passed Gates

- Current backend-truth gate:
  - passed
  - the four frozen backend internal truth paths have now been implemented in
    source
  - backend receipt exists
  - local build verification exists
- Current truth-order gate:
  - passed
  - L0 truth and L2 contracts were frozen before this stage
- Current architecture-boundary gate:
  - passed
  - BFF remains the only app-facing aggregation layer
  - Server remains the only business truth owner
- Current stage-control gate:
  - passed
  - this stage has one objective
  - touch-set is restricted to the minimum publish corridor only

## 4. Stage-local Non-Unlocked Items

- The following items remain blocked globally and remain outside this stage:
  - frontend implementation
  - integration acceptance
  - deployment
  - release
  - admin path remediation
  - environment purity remediation
- These items do not block source-level BFF implementation for the minimum
  corridor, but they continue to block later stages.

## 5. Stage-local Guard Conditions

- BFF may touch only `apps/bff/src/**` files needed for the four frozen
  corridor paths.
- This stage must not reopen or rewrite unrelated forum/file/enterprise_hub
  surfaces outside the current touch-set.
- This stage must actively reduce minimum-corridor `repo/runtime drift` for the
  touched paths.
- Compatibility aliases may remain as historical runtime residuals, but must
  not be promoted to canonical truth in source or docs.
- Any newly created or modified handwritten BFF business file in this stage
  must remain within file-length and single-responsibility gate.
- No cloud deployment, process restart, Nginx change, release switch, or live
  runtime modification is allowed in this stage.

## 6. Failed Gates

- Current frontend stage gate:
  - failed for this stage on purpose
  - no Flutter implementation is included
- Current integration gate:
  - failed for this stage on purpose
  - no runtime acceptance is included
- Current deployment gate:
  - failed for this stage on purpose
- Current release gate:
  - failed for this stage on purpose

## 7. Veto Gates

- No current veto gate blocks this exact BFF-only implementation stage,
  provided the stage-local guard conditions are obeyed.
- The unresolved global blockers remain vetoes for:
  - frontend implementation
  - integration acceptance
  - deployment
  - release

## 8. Stage Go / No-Go

- Stage decision:
  - `Go` for `项目发布最小走廊 / BFF implementation round`
  - `No-Go` for Flutter App implementation
  - `No-Go` for integration verification
  - `No-Go` for deployment
  - `No-Go` for release-prep
  - `No-Go` for release execution

## 9. Next Unique Action

- The next single action is:
  - issue the formal BFF implementation dispatch for the project publish
    minimum corridor only
