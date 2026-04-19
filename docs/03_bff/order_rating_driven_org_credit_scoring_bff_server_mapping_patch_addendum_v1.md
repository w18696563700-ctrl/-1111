---
owner: 总控文书冻结 Agent
status: frozen
purpose: Patch the future-mainline reserve BFF-to-Server mapping truth for `订单评价驱动的组织信用评分主线` so bounded app-facing implementation no longer has to guess the unique mapping between reserve app-facing paths and reserve Server read paths.
layer: L4 BFF
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

# 订单评价驱动的组织信用评分主线 BFF-to-Server Mapping Patch Addendum V1

## 1. Formal Positioning

- This addendum is a future-mainline reserve `BFF`-to-`Server` mapping patch.
- This addendum patches only the unique mapping truth between the future reserve app-facing family and the future reserve `Server` read family.
- This addendum does not rewrite current app-facing authority.

## 2. Unique Legal Mapping

- The only legal mapping is:
  - `GET /api/app/profile/organization-credit-scoring/status`
    -> `GET /server/profile/organization-credit-scoring/status`
  - `GET /api/app/profile/organization-credit-scoring/explanation`
    -> `GET /server/profile/organization-credit-scoring/explanation`
  - `GET /api/app/profile/organization-credit-scoring/handoff`
    -> `GET /server/profile/organization-credit-scoring/handoff`
- No alternate `BFF`-to-`Server` mapping is admitted in this round.
- The mapping above must not back-write into current:
  - `GET /api/app/profile/credit-and-constraints/status`
  - `GET /api/app/profile/credit-and-constraints/explanation`
  - `GET /api/app/profile/credit-and-constraints/handoff`

## 3. BFF Responsibility Boundary

- `BFF` in this reserve family may do only:
  - forward
  - normalize
  - shape
  - visibility trim
  - error mapping
- `BFF` must not derive:
  - `score`
  - `tier`
  - `riskPosture`
- `BFF` must not persist a second credit snapshot.

## 4. Response-shaping Boundary

- For `status`, `explanation`, and `handoff`, the app-facing success payload must remain contract-exact with the executable read-surface contract patch.
- `BFF` may trim only visibility-sensitive reserve fields.
- `BFF` must not add:
  - execution truth
  - benefit execution truth
  - governance execution truth

## 5. Reserve Error-mapping Boundary

- The canonical reserve app-facing error family is:
  - `SHADOW_RESULT_UNAVAILABLE`
  - `SAMPLE_INSUFFICIENT`
  - `FUTURE_CREDIT_FAMILY_UNAVAILABLE`
  - `FUTURE_RESERVE_DEPENDENCY_UNAVAILABLE`
  - `FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE`
- `BFF` must map future reserve `Server` read failures only into the error family above.
- Unknown reserve `Server` failures must not be silently swallowed and must be normalized into:
  - `FUTURE_RESERVE_DEPENDENCY_UNAVAILABLE`

## 6. Non-conflict Boundary

- Current `V2.1` remains unchanged.
- Current `BFF` family for `credit-and-constraints/*` remains unchanged.
- The future reserve `BFF` family must remain parallel to and isolated from current app-facing authority.

## 7. Formal Conclusion

- The future reserve `BFF`-to-`Server` mapping truth is now concrete enough for bounded `BFF + Flutter` implementation.
- Current round remains:
  - `PASS` for executable truth patch filing
  - `NO-GO` for integration
  - `NO-GO` for release-prep
