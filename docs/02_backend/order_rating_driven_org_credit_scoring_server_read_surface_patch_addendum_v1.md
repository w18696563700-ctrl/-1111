---
owner: 总控文书冻结 Agent
status: frozen
purpose: Patch the future-mainline reserve Server read truth for `订单评价驱动的组织信用评分主线` so bounded app-facing implementation no longer has to guess the Server read-surface family or its read projections.
layer: L3 Backend
freeze_date_local: 2026-04-14
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/order_rating_driven_org_credit_scoring_master_rules_v1.md
  - docs/02_backend/order_rating_driven_org_credit_scoring_server_shadow_aggregation_freeze_addendum_v1.md
  - docs/02_backend/order_rating_driven_org_credit_scoring_server_shadow_aggregation_materialization_persistence_freeze_addendum_v1.md
  - docs/02_backend/order_rating_driven_org_credit_scoring_server_shadow_aggregation_materialization_persistence_patch_addendum_v1.md
  - docs/00_ssot/order_rating_driven_org_credit_scoring_current_v21_non_pollution_verification_addendum_v1.md
  - docs/00_ssot/order_rating_driven_org_credit_scoring_backend_only_implementation_unlock_addendum_v1.md
  - docs/01_contracts/order_rating_driven_org_credit_scoring_contract_freeze_addendum_v1.md
  - docs/03_bff/order_rating_driven_org_credit_scoring_bff_surface_freeze_addendum_v1.md
  - docs/04_frontend/order_rating_driven_org_credit_scoring_frontend_projection_freeze_addendum_v1.md
  - docs/00_ssot/order_rating_driven_org_credit_scoring_app_facing_implementation_unlock_addendum_v1.md
  - docs/00_ssot/source_of_truth_map.md
---

# 订单评价驱动的组织信用评分主线 Server Read-surface Patch Addendum V1

## 1. Formal Positioning

- This addendum is a future-mainline reserve Server read-surface patch.
- This addendum patches only the future reserve `Server` read truth surface.
- This addendum is not a rewrite of current runtime authority.

## 2. Reserve Server Read Family

- The future reserve `Server` read family is fixed as:
  - `GET /server/profile/organization-credit-scoring/status`
  - `GET /server/profile/organization-credit-scoring/explanation`
  - `GET /server/profile/organization-credit-scoring/handoff`
- The three server paths above serve only the future reserve family.
- The three server paths above must not rewrite current:
  - `GET /server/profile/credit-and-constraints/status`
  - `GET /server/profile/credit-and-constraints/explanation`
  - `GET /server/profile/credit-and-constraints/handoff`

## 3. Status Read Projection Boundary

- `status` must project from the independent shadow aggregate carrier:
  - `organization_shadow_credit_aggregates`
- The minimum projection for `status` is:
  - `score` <- `public_score`
  - `tierCode` <- `tier_code`
  - `tierLabel` <- bounded label mapping of `tier_code`
  - `sampleStatus` <- `sample_status`
  - `riskPosture` <- `risk_posture`
  - `ratedCompletedOrderCount` <- `rated_completed_order_count`
  - `positiveRate` <- `positive_rate`
  - `negativeRate` <- `negative_rate`
  - `verySatisfiedCount` <- `very_satisfied_count`
  - `satisfiedCount` <- `satisfied_count`
  - `passableCount` <- `passable_count`
  - `negativeCount` <- `negative_count`
  - `actionableState` <- bounded reserve projection from `sample_status`, `risk_posture`, and patched reason codes
  - `updatedAt` <- `updated_at`
- `status` must not read from current `credit_constraints` carriers.

## 4. Explanation Read Projection Boundary

- `explanation` must be a bounded read projection only.
- `explanation` may project only:
  - `reasonSummary` <- `reason_summary`
  - `reasonCodes` <- merged ordered reserve read projection of `tier_reason_codes` and `posture_reason_codes`
  - `sampleStatus` <- `sample_status`
  - `riskPosture` <- `risk_posture`
  - `ratedCompletedOrderCount` <- `rated_completed_order_count`
  - `positiveRate` <- `positive_rate`
  - `negativeRate` <- `negative_rate`
  - `verySatisfiedCount` <- `very_satisfied_count`
  - `satisfiedCount` <- `satisfied_count`
  - `passableCount` <- `passable_count`
  - `negativeCount` <- `negative_count`
  - `updatedAt` <- `updated_at`
- `explanation` must not invent:
  - execution truth
  - benefit execution truth
  - governance execution truth

## 5. Handoff Read Projection Boundary

- `handoff` must be a bounded read projection only.
- `handoff` may project only:
  - `actionableState` <- bounded reserve projection from `sample_status`, `risk_posture`, and patched reason codes
  - `sampleStatus` <- `sample_status`
  - `riskPosture` <- `risk_posture`
  - `primaryActionCode` <- bounded reserve action mapping from `actionableState`
  - `primaryActionLabel` <- bounded reserve label mapping from `primaryActionCode`
  - `handoffMessage` <- bounded reserve message mapping from `actionableState` and `reason_summary`
  - `updatedAt` <- `updated_at`
- `handoff` must not become execution truth.

## 6. Non-pollution Query Boundary

- Current `V2.1` query family must remain unchanged.
- Current `V2.1` query service must not read the shadow aggregate.
- The future reserve read family must be served by dedicated future reserve read handlers only.

## 7. Reserve Error Boundary

- The canonical reserve read error family for the three server paths is:
  - `SHADOW_RESULT_UNAVAILABLE`
  - `SAMPLE_INSUFFICIENT`
  - `FUTURE_CREDIT_FAMILY_UNAVAILABLE`
  - `FUTURE_RESERVE_DEPENDENCY_UNAVAILABLE`
  - `FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE`
- The error family above remains reserve-only and must not be written into current `V2.1`.

## 8. Formal Conclusion

- The future reserve `Server` read surface is now concrete enough for bounded app-facing implementation.
- Current `V2.1` route family and query family remain unchanged.
- Current round remains:
  - `PASS` for executable truth patch filing
  - `NO-GO` for integration
  - `NO-GO` for release-prep
