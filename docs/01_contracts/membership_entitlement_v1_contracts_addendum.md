---
owner: Codex 总控
status: frozen
purpose: Freeze the first dedicated L2 contract family for My Building V2.0 paid membership, including the minimum app-facing path family, shell summary extension, read-model boundaries, and error family without widening into payment, billing, guarantee, or settlement execution.
layer: L2 Contracts
---

# 我的楼 V2.0 付费会员 Contracts Addendum

## Scope

- This addendum applies only to the first dedicated `L2` contract package for:
  - paid membership current status
  - membership explanation
  - membership quota summary
  - membership upgrade guidance
  - minimum shell summary extension for paid membership
- This addendum does not by itself:
  - unlock implementation
  - approve release
  - freeze payment execution
  - freeze billing or invoice contracts
  - freeze guarantee, penalty, dispute, or settlement contracts
  - invent a second identity, certification, or organization truth

## Alignment Basis

- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [my_building_v20_membership_minimum_package_boundary_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_minimum_package_boundary_addendum.md)
  - [my_building_v20_membership_entitlement_and_quota_rules_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md)
  - [platform_capability_unified_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_capability_unified_baseline_addendum.md)
  - [profile_my_building_compact_hub_boundary_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/profile_my_building_compact_hub_boundary_addendum.md)
  - [profile_my_building_compact_hub_frontend_surface_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/profile_my_building_compact_hub_frontend_surface_addendum.md)
  - [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md)
  - [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)

## Contract Role

- `identity_permission_minimum_contracts.yaml` remains the minimum shell and identity transport baseline.
- This addendum upgrades that minimum baseline into the first dedicated
  `我的楼 V2.0 付费会员` contract family.
- `openapi.yaml` must therefore carry:
  - the current app-facing canonical paths for paid membership
  - the minimum schema family needed by those paths
  - the minimum shell summary extension fields allowed by this package
- `error_codes.yaml` must carry the minimum error-code family used by this package.

## Canonical Path-family Rule

- Flutter App paths remain under:
  - `/api/app/*`
- This contract package must not create:
  - bare `/membership/*`
  - bare `/billing/*`
  - bare `/payment/*`
  - bare `/guarantee/*`
  - bare `/settlement/*`
- The minimum paid-membership path family is frozen under:
  - `/api/app/profile/membership/*`

## Current App-facing Path Matrix

- Current paid-membership contract family is frozen as:
  - `GET /api/app/profile/membership/current`
  - `GET /api/app/profile/membership/explanation`
  - `GET /api/app/profile/membership/quota`
  - `GET /api/app/profile/membership/upgrade-guide`
- No write command is approved in this round for:
  - membership purchase
  - membership renewal
  - membership cancellation
  - membership order creation
  - payment confirmation

## Current Shell Summary Extension Rule

- Existing shell required fields remain unchanged:
  - `userId`
  - `organizationId`
  - `roleKeys`
  - `certificationStatus`
  - `membershipStatus`
  - `visibleBuildings`
  - `featureFlagsVersion`
  - `unreadSummary`
- `membershipStatus` remains the existing Package 1 organization-membership field.
- This contract package must not reinterpret that field as paid-membership truth.
- Current allowed optional-next shell summary fields for paid membership are:
  - `paidMembershipTier`
  - `paidMembershipEntitlementsSummary`
  - `paidMembershipQuotaSummary`
  - `paidMembershipNextRefreshAt`
- This package does not approve:
  - a full membership center payload inside `shell/context`
  - billing or payment detail inside `shell/context`
  - guarantee or penalty detail inside `shell/context`

## Contract Object Families

- This contract package freezes the following object families only:
  - paid membership current read model
  - membership explanation read model
  - membership quota summary read model
  - membership upgrade-guide read model
  - shell paid-membership summary extension
- This package does not freeze:
  - payment order objects
  - billing ledger objects
  - invoice objects
  - guarantee deposit objects
  - dispute adjudication objects
  - settlement objects

## State Responsibility Freeze

- User, organization, certification, and existing organization-membership truth remain `Server` truth only.
- Paid-membership truth, entitlement truth, and quota truth must also remain server-owned truth families.
- `BFF` may shape:
  - paid membership current
  - explanation
  - quota summary
  - upgrade guidance
  - shell summary projection
- `BFF` must not define:
  - membership purchase success truth
  - billing truth
  - payment truth
  - guarantee truth
  - a second role system

## Current Response-shape Freeze

- App-facing responses in this package must preserve:
  - clear separation between current tier, entitlement summary, and quota summary
  - explicit nullable timestamps where no current paid-membership cycle exists
  - explicit summary versus detail separation
- This package must not overload:
  - `membershipStatus`
  - `certificationStatus`
  - organization role fields
  with paid-membership semantics.

## Membership Schema Freeze

- `GET /api/app/profile/membership/current` must return:
  - `paidMembershipTier`
  - `rateBand`
  - `entitlementsSummary`
  - `quotaSummary`
  - `effectiveAt`
  - `expiresAt`
  - `nextRefreshAt`
- `GET /api/app/profile/membership/explanation` must return at minimum:
  - `tiers`
  - `entitlementNotes`
  - `quotaNotes`
  - `disclaimer`
- `GET /api/app/profile/membership/quota` must return at minimum:
  - `items`
  - `nextRefreshAt`
- One quota item must carry at minimum:
  - `quotaType`
  - `summary`
  - `currentValue`
  - `refreshRule`
- `GET /api/app/profile/membership/upgrade-guide` must return at minimum:
  - `currentTier`
  - `availableTiers`
  - `upgradeHighlights`
  - `commercialDisclosure`

## Candidate-commercial-display Boundary

- Upgrade guidance may carry candidate commercial display copy.
- This package does not by itself freeze:
  - final launch price
  - final fee rate
  - final discount value
  - final payment execution path
- Therefore current commercial display must stay:
  - explanatory
  - non-transactional
  - non-order-creating

## Query Freeze

- This round accepts no rich search or analytics query family for paid membership.
- Current minimum query posture is:
  - read current state
  - read explanation
  - read quota summary
  - read upgrade guidance
- No list, page, sort, filter, or history timeline family is approved by this addendum.

## Error-family Freeze

- This contract package relies on the following existing namespaces:
  - `AUTH`
  - `MEMBERSHIP`
- Minimum added or affirmed error-code family in this package must cover:
  - `MEMBERSHIP_CURRENT_UNAVAILABLE`
  - `MEMBERSHIP_EXPLANATION_UNAVAILABLE`
  - `MEMBERSHIP_QUOTA_UNAVAILABLE`
  - `MEMBERSHIP_UPGRADE_GUIDE_UNAVAILABLE`
  - `MEMBERSHIP_ROUTE_UNAVAILABLE`
  - `AUTH_PERMISSION_INSUFFICIENT`
  - `AUTH_RESOURCE_UNAVAILABLE`

## Current Meaning

- This addendum means:
  - the first dedicated `我的楼 V2.0 付费会员` contract family is now formally separated from the broader V2 planning baseline
  - app-facing paid-membership current, explanation, quota, and upgrade-guide reads are bound into one contract family
  - shell may extend only by minimum paid-membership summary projection
- This addendum does not mean:
  - the current App already implements a full member center
  - payment and billing contracts are approved
  - guarantee or settlement contracts are approved

## Explicit Non-goals

- No second identity family
- No second organization registry
- No second membership meaning for existing Package 1 `membershipStatus`
- No payment transaction contract
- No billing ledger contract
- No invoice contract
- No guarantee deposit contract
- No settlement contract
- No rich visibility contract for exhibition transaction information

## Next Unique Action

- Next unique action:
  - update `docs/01_contracts/identity_permission_minimum_contracts.yaml` and `docs/01_contracts/openapi.yaml` so they carry the minimum paid-membership contract family frozen by this addendum
