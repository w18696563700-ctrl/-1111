---
owner: Codex 总控
status: draft
purpose: Remove the remaining Phase 2.3 wording conflicts from L2/L3 truth after the Inspection Phase 3 minimum workflow boundary has already been frozen.
layer: L0 SSOT
---

# Inspection Phase 3 L2/L3 残留旧口径清理冻结单

## Scope
- This addendum clears only two residual wording conflicts that remained after the
  Phase 3 minimum Inspection workflow truth had already been frozen:
  - the old `Phase 2.3` wording in `inspection/submit` under `openapi.yaml`
  - the duplicate `Phase 2.3` and `Phase 3` route-responsibility descriptions for
    `inspection/detail` and `inspection/submit` in `flutter_screen_map.md`
- It does not add any new capability.
- It does not unlock implementation by itself.

## Canonical Decisions

### 1. L2 contract wording for inspection/submit
- `POST /api/app/inspection/submit` must no longer be described as a pure
  `Phase 2.3 entry-state` command.
- Its canonical wording now aligns to the already-frozen Phase 3 minimum
  Inspection self-workflow boundary:
  - first submission into the minimum closed loop
  - not a list, history, governance, or multi-round console capability

### 2. L3 frontend route responsibility wording
- `inspection/detail` and `inspection/submit` must not keep two concurrent route
  responsibility descriptions across `Phase 2.3` and `Phase 3`.
- For the current canonical truth:
  - `inspection/detail`
  - `inspection/submit`
  are governed by the `Phase 3` minimum Inspection workflow map.
- The old `Phase 2.3` inspection route rows are historical baseline only and must
  no longer remain as active route-responsibility truth in the current screen map.

### 3. Truth-sync impact
- This cleanup requires the following files to stay in sync:
  - `docs/00_ssot/inspection_phase3_l23_residual_cleanup_addendum.md`
  - `docs/00_ssot/source_of_truth_map.md`
  - `docs/01_contracts/openapi.yaml`
  - `docs/04_frontend/flutter_screen_map.md`
- `docs/04_frontend/ui_state_contract.md` does not require wording changes for this
  cleanup if its current state mapping already matches the Phase 3 minimum
  Inspection workflow boundary.

## Rules
- There must not be two concurrent active stage descriptions for the same
  `inspection/detail` or `inspection/submit` route.
- `inspection/recheck` remains the only new Phase 3 app-facing inspection path.
- This cleanup must not reopen any other object and must not expand scope.
