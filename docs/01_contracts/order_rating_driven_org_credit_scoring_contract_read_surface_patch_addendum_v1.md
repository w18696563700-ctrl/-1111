---
owner: 总控文书冻结 Agent
status: frozen
purpose: Patch the future-mainline reserve contract family for `订单评价驱动的组织信用评分主线` so the executable read-surface truth is concrete enough for bounded `BFF + Flutter` implementation without rewriting current `我的信用与约束 V2.1`.
layer: L2 Contracts
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

# 订单评价驱动的组织信用评分主线 Contract Read-surface Patch Addendum V1

## 1. Formal Positioning

- This addendum is a future-mainline reserve contract read-surface patch.
- This addendum patches only the executable read-surface contract truth required by the admitted `BFF + Flutter` implementation round.
- This addendum does not rewrite current `V2.1`.
- This addendum does not make the reserve family current effective truth.

## 2. Reserve App-facing Route Family

- The future reserve app-facing route family remains only:
  - `GET /api/app/profile/organization-credit-scoring/status`
  - `GET /api/app/profile/organization-credit-scoring/explanation`
  - `GET /api/app/profile/organization-credit-scoring/handoff`
- The three paths above remain reserve-only.
- The three paths above must not back-write into current:
  - `GET /api/app/profile/credit-and-constraints/status`
  - `GET /api/app/profile/credit-and-constraints/explanation`
  - `GET /api/app/profile/credit-and-constraints/handoff`

## 3. Status Read-surface Contract

- The minimum success payload for `status` is:
  - `score`: integer or `null`
  - `tierCode`: string or `null`
  - `tierLabel`: string or `null`
  - `sampleStatus`: `UNAVAILABLE | INSUFFICIENT | SUFFICIENT`
  - `riskPosture`: `UNAVAILABLE | LOW | MEDIUM | HIGH`
  - `ratedCompletedOrderCount`: integer
  - `positiveRate`: decimal or `null`
  - `negativeRate`: decimal or `null`
  - `verySatisfiedCount`: integer
  - `satisfiedCount`: integer
  - `passableCount`: integer
  - `negativeCount`: integer
  - `actionableState`: string or `null`
  - `updatedAt`: RFC3339 datetime string or `null`
- `score`, `tierCode`, `tierLabel`, `riskPosture`, and `actionableState` may be `null` when `sampleStatus` is `UNAVAILABLE` or `INSUFFICIENT`.
- The payload above is reserve-only and must not be interpreted as current `V2.1` truth.

## 4. Explanation Read-surface Contract

- The minimum success payload for `explanation` is:
  - `reasonSummary`: string
  - `reasonCodes`: string array
  - `sampleStatus`: `UNAVAILABLE | INSUFFICIENT | SUFFICIENT`
  - `riskPosture`: `UNAVAILABLE | LOW | MEDIUM | HIGH`
  - `ratedCompletedOrderCount`: integer
  - `positiveRate`: decimal or `null`
  - `negativeRate`: decimal or `null`
  - `verySatisfiedCount`: integer
  - `satisfiedCount`: integer
  - `passableCount`: integer
  - `negativeCount`: integer
  - `updatedAt`: RFC3339 datetime string or `null`
- `reasonCodes` is the reserve read-surface carrier for the patched shadow reason-code family.
- `explanation` is a bounded read projection only and must not carry any execution truth.

## 5. Handoff Read-surface Contract

- The minimum success payload for `handoff` is:
  - `actionableState`: string or `null`
  - `sampleStatus`: `UNAVAILABLE | INSUFFICIENT | SUFFICIENT`
  - `riskPosture`: `UNAVAILABLE | LOW | MEDIUM | HIGH`
  - `primaryActionCode`: string or `null`
  - `primaryActionLabel`: string or `null`
  - `handoffMessage`: string or `null`
  - `updatedAt`: RFC3339 datetime string or `null`
- `handoff` is a bounded reserve guidance projection only.
- `handoff` must not invent:
  - execution status
  - benefit execution result
  - governance execution result
  - payment or billing execution result

## 6. Reserve Error Family And Field Boundary

- The canonical reserve app-facing error family for the three read paths is:
  - `SHADOW_RESULT_UNAVAILABLE`
  - `SAMPLE_INSUFFICIENT`
  - `FUTURE_CREDIT_FAMILY_UNAVAILABLE`
  - `FUTURE_RESERVE_DEPENDENCY_UNAVAILABLE`
  - `FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE`
- The error family above remains reserve-only.
- The field boundary remains unchanged:
  - no reserve field may be written into current `credit-and-constraints/*`
  - no benefit-execution field may be admitted
  - no governance-execution field may be admitted

## 7. Formal Conclusion

- The executable reserve contract read surface is now concrete enough for bounded `BFF + Flutter` implementation authoring.
- Current `V2.1` remains unchanged.
- Current round remains:
  - `PASS` for executable truth patch filing
  - `NO-GO` for integration
  - `NO-GO` for release-prep
