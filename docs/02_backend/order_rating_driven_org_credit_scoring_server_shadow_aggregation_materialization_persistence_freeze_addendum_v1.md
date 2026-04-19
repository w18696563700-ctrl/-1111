---
owner: 总控文书冻结 Agent
status: frozen
purpose: Freeze the future-mainline reserve materialization and persistence boundary for `订单评价驱动的组织信用评分主线` at the Server shadow-aggregation layer only, without rewriting the current V2.1 backend truth or any current app-facing route family.
layer: L3 Backend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/order_rating_driven_org_credit_scoring_master_rules_v1.md
  - docs/02_backend/order_rating_driven_org_credit_scoring_server_shadow_aggregation_freeze_addendum_v1.md
  - docs/00_ssot/order_rating_driven_org_credit_scoring_and_current_v21_non_conflict_ruling_addendum.md
  - docs/00_ssot/my_building_effective_truth_mother_file_v1.md
  - docs/00_ssot/my_building_feature_status_register_v1.md
  - docs/01_contracts/credit_deposit_transaction_guarantee_v1_contracts_addendum.md
  - docs/02_backend/credit_deposit_transaction_guarantee_v1_backend_truth_addendum.md
  - docs/03_bff/credit_deposit_transaction_guarantee_v1_bff_surface_addendum.md
  - docs/04_frontend/credit_deposit_transaction_guarantee_v1_frontend_surface_addendum.md
  - docs/00_ssot/source_of_truth_map.md
---

# 订单评价驱动的组织信用评分主线 Server Shadow Aggregation Materialization / Persistence Freeze Addendum V1

## 1. Formal Positioning

- This addendum is a future-mainline reserve.
- This addendum is a backend-only materialization and persistence freeze.
- This addendum freezes only the future Server shadow aggregation entity, ledger, trigger, reason-code, and persistence boundary.
- This addendum does not belong to current runtime backend truth.

## 2. Unique Truth Owner And Aggregation Level

- `Server` is the only truth owner for any shadow aggregation admitted by this mainline.
- Current round allows organization-level aggregation only.
- Current round does not allow personal-level aggregation.
- Shadow aggregation may absorb only:
  - completed-order legitimacy
  - formal rating events
  - organization-level aggregation

## 3. Minimum Carrier And Persistence Family

- The minimum future carrier family is frozen as:
  - aggregate carrier: `organization_shadow_credit_aggregates`
  - ledger carrier: `organization_shadow_credit_ledgers`
  - reason-code family: `organization_shadow_credit_reason_codes`
  - recompute trigger family: `organization_shadow_credit_recompute_triggers`
- These future carriers serve only:
  - reserve shadow aggregation materialization
  - reserve ledger replay and auditability
  - reserve reason-code normalization
  - reserve recompute scheduling and replay control

## 4. Aggregate Carrier Boundary

- `organization_shadow_credit_aggregates` may hold only:
  - `organization_id`
  - `aggregation_version`
  - `last_completed_order_cursor`
  - `last_formal_rating_event_cursor`
  - `shadow_state_code`
  - `updated_at`
- This aggregate carrier must represent only the current Server-side shadow rollup for one organization.
- This aggregate carrier must not overwrite or alias any current posture carrier.

## 5. Ledger Carrier Boundary

- `organization_shadow_credit_ledgers` may hold only the append-only internal reserve ledger for:
  - admitted completed-order legitimacy changes
  - admitted formal rating events
  - organization-level aggregation deltas
  - internal recompute replay checkpoints
- The ledger carrier must stay append-only by meaning.
- The ledger carrier must not become a current app-facing read model.

## 6. Reason-code Family Boundary

- `organization_shadow_credit_reason_codes` freezes only the normalized future reason-code family for:
  - legitimacy acceptance
  - legitimacy rejection
  - rating admission
  - rating rejection
  - anti-abuse hold
  - manual review hold
  - recompute source reason
- Reason codes remain internal Server-side truth only in this round.
- Reason codes must not be projected as current `V2.1` explanation truth.

## 7. Recompute Trigger Family Boundary

- `organization_shadow_credit_recompute_triggers` freezes only the minimum internal recompute-trigger family for:
  - formal rating accepted
  - completed-order legitimacy corrected
  - manual replay request
  - version bump replay
  - anti-abuse rollback or release
- Recompute triggers are internal Server-side control truth only.
- Recompute triggers must not be exposed as current route, BFF, or Flutter truth.

## 8. Versioning And UpdatedAt Discipline

- All future shadow carriers must keep:
  - `aggregation_version`
  - stable organization anchoring
  - monotonic recompute discipline
  - `updated_at`
- Recompute must be version-aware and replay-safe.
- A later version may supersede an older shadow snapshot, but must not silently mutate current V2.1 posture truth.

## 9. Isolation From Current V2.1 Truth

- Current materialization may create shadow carriers only.
- Current materialization must not cover, replace, or overwrite:
  - `organization_credit_constraint_postures`
  - `organization_deposit_postures`
  - `organization_transaction_guarantee_postures`
- Current materialization must not rewrite the current V2.1 backend truth package.
- Shadow aggregation and current posture carriers must remain isolated by carrier meaning and persistence ownership.

## 10. Current App-facing Boundary

- Current round does not add any current app-facing route family.
- Current round does not rewrite:
  - `GET /api/app/profile/credit-and-constraints/status`
  - `GET /api/app/profile/credit-and-constraints/explanation`
  - `GET /api/app/profile/credit-and-constraints/handoff`
- Current round does not require:
  - contracts unlock
  - BFF consumption
  - Flutter consumption
  - runtime active output

## 11. Formal Conclusion

- Current future-mainline reserve may materialize only the Server-side shadow carriers and persistence family frozen above.
- Go for backend-only shadow aggregation implementation authoring
- No-Go for app-facing unlock
