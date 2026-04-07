---
owner: 总控文书冻结
status: frozen
purpose: Freeze the Flutter-side surface for My Building V2.0 paid membership so `我的会员` may enter `profile / 我的楼` as a bounded first-level entry and consume only the minimum read-first membership package without widening into payment, billing, guarantee, or a second dashboard.
layer: L3 Frontend
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
  - docs/03_bff/membership_entitlement_v1_bff_surface_addendum.md
  - docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md
---

# 我的楼 V2.0 paid membership Frontend Surface Addendum

## Scope

- This addendum applies only to the first dedicated `docs/04_frontend` package for:
  - `我的楼 / 我的会员` bounded first-level entry
  - membership first-screen minimum summary consumption
  - membership status page
  - membership explanation page
  - membership quota page
  - membership upgrade-guide page
- This addendum does not by itself:
  - unlock `apps/mobile` implementation
  - approve launch
  - approve a full membership center
  - approve payment, billing, invoice, guarantee, settlement, or governance surfaces

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
  - [membership_entitlement_v1_bff_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/membership_entitlement_v1_bff_surface_addendum.md)
  - [membership_entitlement_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md)

## My-building Entry Rule

- `我的会员` is now accepted as a bounded first-level entry under:
  - `profile / 我的楼`
- `我的会员` must not squeeze out or replace the existing first-level handoff family:
  - `我的公司`
  - `认证与成员身份`
  - `我的项目`
  - `我的论坛`
  - `设置`
- `设置` remains the bottom-most first-level entry family.
- `我的项目` remains the existing formal private-project entry and must not be swallowed, renamed, or visually downgraded by membership copy.
- `我的楼` must still read as:
  - compact current-user hub
  - private identity and asset center
  - bounded entry aggregation surface
- `我的楼` must not be presented as:
  - a second dashboard
  - a business center
  - a member operating console

## First-screen Load Governance

- The first-level `我的会员` surface may show only the current minimum summary:
  - current membership tier
  - current rate band
  - current entitlements summary
  - current remaining quota summary
  - next refresh time
- The first-level surface must not heavy-load:
  - entitlement detail matrix
  - quota detail matrix
  - candidate price detail
  - payment or billing detail
  - guarantee or settlement detail
  - rich commercial history
- Shell/context may continue to carry only the minimum optional summary extension:
  - `paidMembershipTier`
  - `paidMembershipEntitlementsSummary`
  - `paidMembershipQuotaSummary`
  - `paidMembershipNextRefreshAt`
- Flutter must not turn shell/context into:
  - a full membership center payload
  - a commercial object cache
  - a second membership truth root
- Where rate-band display is needed on the bounded first-level membership surface, frontend must consume it through the frozen membership read family rather than stuffing a larger payload back into shell/context.
- `我的楼` first screen must still optimize for:
  - private identity confirmation
  - key status hint
  - key asset summary
  - bounded secondary handoff

## Second-level Page-family Freeze

- Current frontend membership read family remains limited to:
  - `GET /api/app/profile/membership/current`
  - `GET /api/app/profile/membership/explanation`
  - `GET /api/app/profile/membership/quota`
  - `GET /api/app/profile/membership/upgrade-guide`
- The current legal membership second-level page family is frozen as:
  - 会员状态页
  - 权益说明页
  - 配额说明页
  - 升级引导页
- These pages remain:
  - bounded frontend surface
  - read-first membership package pages
- These pages do not become:
  - payment center
  - billing center
  - guarantee center
  - settlement center
  - governance center

## Copy And Field Projection Boundary

- Current frontend may display:
  - candidate commercial display copy
  - current membership tier copy
  - current rate-band copy
  - current entitlement summary copy
  - current quota summary copy
- Current frontend must not rewrite candidate commercial display into:
  - final launch price
  - final launch rate
  - final launch discount
  - final purchase commitment
- Flutter must not:
  - infer missing shell fields
  - guess missing membership fields
  - synthesize paid-membership truth locally
  - reuse current Package 1 `membershipStatus` as paid-membership truth
- Current Package 1 `membershipStatus` remains:
  - organization membership truth
  - not paid membership truth

## Route / Page / Truth Owner Split

- Page owner may remain:
  - `profile`
- Route owner may remain:
  - `profile/membership`
- Truth owner does not automatically move to:
  - `profile`
- Truth owner remains:
  - `Server`
  - paid-membership truth family
- `我的楼` remains the entry owner for the bounded membership handoff only.

## Current Meaning

- This addendum means:
  - `我的会员` is now a bounded first-level entry family under `我的楼`
  - membership frontend surface is frozen only as a read-first bounded package
  - the first screen remains compact and cannot evolve into a second dashboard
- This addendum does not mean:
  - implementation unlock
  - launch approval
  - a complete member center
  - payment, billing, guarantee, or settlement opening

## Explicit Non-goals

- No implementation unlock
- No launch approval
- No payment center
- No billing center
- No invoice center
- No guarantee center
- No settlement center
- No governance center
- No new scope
- No new package
- No reinterpretation of Package 1 `membershipStatus`
- No dashboard-style first screen

## Formal Conclusion

- Current formal conclusion:
  - this file freezes `我的楼 V2.0 paid membership` frontend surface only
  - `我的会员` may exist only as a bounded first-level entry plus four bounded second-level read pages
  - `我的楼` remains a compact current-user hub rather than a business center
  - when paired with the current-round BFF surface freeze and source-map registration, the `V2.0 paid membership` document chain is completed through `04_frontend`
  - current outcome is still docs-only and is not implementation unlock

## Next Unique Action

- Next unique action:
  - total control may enter implementation-prep dispatch authoring for `我的楼 V2.0 paid membership` under the already frozen L0/L2/L3 boundaries only
