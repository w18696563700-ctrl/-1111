---
owner: 总控文书冻结
status: frozen
purpose: Freeze the BFF-side app-facing surface for My Building V2.0 paid membership so the current package may expose bounded read-first membership projections without widening into payment, billing, guarantee, settlement, or purchase truth.
layer: L3 BFF
freeze_date_local: 2026-04-05
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/platform_capability_unified_baseline_addendum.md
  - docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md
  - docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md
  - docs/00_ssot/my_building_v20_membership_minimum_package_boundary_addendum.md
  - docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md
  - docs/01_contracts/membership_entitlement_v1_contracts_addendum.md
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
  - docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md
  - docs/02_backend/service_boundaries.md
---

# 我的楼 V2.0 paid membership BFF Surface Addendum

## Scope

- This addendum applies only to the first dedicated `docs/03_bff` package for:
  - paid membership current shaping
  - membership explanation shaping
  - membership quota shaping
  - membership upgrade-guide shaping
  - minimum shell membership summary projection
  - controlled failure shaping for the app-facing membership family
- This addendum does not by itself:
  - unlock `apps/bff` implementation
  - unlock `apps/server` implementation
  - approve frontend implementation
  - approve membership purchase runtime
  - approve payment, billing, invoice, guarantee, settlement, or dispute runtime

## Alignment Basis

- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [source_of_truth_map.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/source_of_truth_map.md)
  - [platform_capability_unified_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_capability_unified_baseline_addendum.md)
  - [profile_my_building_compact_hub_boundary_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md)
  - [profile_my_building_compact_hub_frontend_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md)
  - [my_building_v20_membership_minimum_package_boundary_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_minimum_package_boundary_addendum.md)
  - [my_building_v20_membership_entitlement_and_quota_rules_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md)
  - [membership_entitlement_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_entitlement_v1_contracts_addendum.md)
  - [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)
  - [membership_entitlement_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md)
  - [service_boundaries.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/service_boundaries.md)

## BFF Role Freeze

- `BFF` in this package may do only:
  - forward
  - normalize
  - shape
  - minimum shell summary projection
- `BFF` in this package must not own:
  - paid-membership truth
  - entitlement truth
  - quota truth
  - payment truth
  - guarantee truth
  - membership purchase truth
- `Server` remains the only truth owner for:
  - current paid-membership cycle
  - entitlement summary
  - quota summary
  - upgrade-guide source truth
  - controlled audit and refresh truth

## Current App-facing Route Family

- The current paid-membership app-facing route family is frozen as:
  - `GET /api/app/profile/membership/current`
  - `GET /api/app/profile/membership/explanation`
  - `GET /api/app/profile/membership/quota`
  - `GET /api/app/profile/membership/upgrade-guide`
- No write command is approved in this round for:
  - membership purchase
  - membership renewal
  - membership cancellation
  - membership billing retrieval
  - guarantee activation
- Current route family must remain under:
  - `/api/app/profile/membership/*`
- This addendum must not create:
  - bare `/membership/*`
  - bare `/payment/*`
  - bare `/billing/*`
  - bare `/guarantee/*`

## Shell Minimum Summary Projection Boundary

- Existing shell field:
  - `membershipStatus`
  remains the Package 1 organization-membership truth only.
- `membershipStatus` must not be reinterpreted as:
  - paid-membership truth
  - entitlement truth
  - quota truth
- Current paid-membership shell extension is limited to the following optional summary projection only:
  - `paidMembershipTier`
  - `paidMembershipEntitlementsSummary`
  - `paidMembershipQuotaSummary`
  - `paidMembershipNextRefreshAt`
- `BFF` may not expand shell/context into:
  - a full membership center payload
  - payment detail payload
  - billing detail payload
  - guarantee detail payload
- Rate-band display may belong to the dedicated membership read family only.
- Rate-band display must not be stuffed back into shell/context as a new shell truth root in this round.

## Response Shaping Boundary

- `GET /api/app/profile/membership/current` may shape only the minimum current read model:
  - `paidMembershipTier`
  - `rateBand`
  - `entitlementsSummary`
  - `quotaSummary`
  - `effectiveAt`
  - `expiresAt`
  - `nextRefreshAt`
- `GET /api/app/profile/membership/explanation` may shape only the minimum explanation read model:
  - `tiers`
  - `entitlementNotes`
  - `quotaNotes`
  - `disclaimer`
- `GET /api/app/profile/membership/quota` may shape only the minimum quota read model:
  - `items`
  - `nextRefreshAt`
- One quota item may shape only:
  - `quotaType`
  - `summary`
  - `currentValue`
  - `refreshRule`
- `GET /api/app/profile/membership/upgrade-guide` may shape only the minimum guide read model:
  - `currentTier`
  - `availableTiers`
  - `upgradeHighlights`
  - `commercialDisclosure`
- None of the four routes may be shaped into:
  - payment objects
  - billing objects
  - invoice objects
  - guarantee objects
  - settlement objects
  - membership purchase objects
- Candidate commercial display copy may appear only as:
  - explanatory
  - non-transactional
  - non-order-creating
- Candidate commercial display copy must not be rewritten by `BFF` as:
  - final launch price
  - final fee rate
  - final discount truth

## Controlled Failure Family

- The current app-facing controlled failure family for this package is frozen as:
  - `MEMBERSHIP_CURRENT_UNAVAILABLE`
  - `MEMBERSHIP_EXPLANATION_UNAVAILABLE`
  - `MEMBERSHIP_QUOTA_UNAVAILABLE`
  - `MEMBERSHIP_UPGRADE_GUIDE_UNAVAILABLE`
  - `MEMBERSHIP_ROUTE_UNAVAILABLE`
  - `AUTH_PERMISSION_INSUFFICIENT`
  - `AUTH_RESOURCE_UNAVAILABLE`
- `BFF` may only:
  - normalize these failures
  - preserve their app-facing meaning
  - shape them into bounded controlled-unavailable or permission-insufficient output
- `BFF` must not:
  - hide route drift behind fake success
  - rewrite unavailable as fake empty commercial data
  - invent purchase-success semantics

## Current Meaning

- This addendum means:
  - the dedicated `03_bff` surface for `我的楼 V2.0 paid membership` is now frozen
  - `BFF` may expose only bounded read-first membership routes plus minimum shell summary projection
  - `我的楼` shell remains a compact hub and is not expanded into a full membership center
- This addendum does not mean:
  - backend unlock
  - frontend implementation approval
  - membership purchase-chain opening
  - payment or billing readiness

## Explicit Non-goals

- No implementation dispatch
- No implementation unlock
- No purchase truth
- No payment truth
- No billing truth
- No invoice truth
- No guarantee truth
- No settlement truth
- No reinterpretation of existing Package 1 `membershipStatus`
- No full membership center payload inside shell/context

## Formal Conclusion

- Current formal conclusion:
  - this file freezes `我的楼 V2.0 paid membership` BFF surface only
  - `BFF` remains a shaping layer only and does not become a paid-membership truth owner
  - when paired with the current-round frontend surface freeze and source-map registration, the `V2.0 paid membership` document chain is completed through `04_frontend`
  - current outcome is still docs-only and is not implementation unlock

## Next Unique Action

- Next unique action:
  - total control may enter implementation-prep dispatch authoring for `我的楼 V2.0 paid membership` under the already frozen L0/L2/L3 boundaries only
