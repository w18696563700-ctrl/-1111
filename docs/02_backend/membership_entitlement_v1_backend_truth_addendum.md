---
owner: Codex 总控
status: frozen
purpose: Freeze the dedicated backend truth, persistence carriers, summary-source rules, and audit boundaries for My Building V2.0 paid membership without widening into payment, billing, invoice, guarantee, or settlement execution.
layer: L3 Backend
---

# 我的楼 V2.0 付费会员 Backend Truth Addendum

## 1. Scope

- This addendum applies only to the first dedicated `docs/02_backend` package for:
  - paid membership current-cycle truth
  - paid membership entitlement summary truth
  - paid membership quota summary truth
  - paid membership upgrade-guide source truth
  - shell summary projection source truth
  - membership audit and quota-refresh ownership
- This addendum does not by itself:
  - unlock `apps/server` implementation
  - unlock `apps/bff` aggregation specs
  - approve payment execution
  - approve billing, invoice, or settlement runtime
  - approve guarantee, penalty, dispute, or governance runtime

## 2. Alignment Basis

- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [service_boundaries.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/service_boundaries.md)
  - [db_schema.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/db_schema.md)
  - [platform_capability_unified_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_capability_unified_baseline_addendum.md)
  - [my_building_v20_membership_minimum_package_boundary_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_minimum_package_boundary_addendum.md)
  - [my_building_v20_membership_entitlement_and_quota_rules_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md)
  - [membership_entitlement_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_entitlement_v1_contracts_addendum.md)
  - [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)

## 3. Addendum Role

- `platform capability` documents remain the generic membership capability baseline.
- This addendum upgrades that baseline into the first dedicated backend-truth package for:
  - `我的楼 V2.0 paid membership`
- The dedicated package therefore freezes:
  - which dynamic tables are the current canonical carriers
  - which catalog-like truths may remain lookup/config-backed
  - how current tier, entitlement summary, and quota summary are sourced
  - how shell/profile membership summaries are projected
  - how audit and quota refresh remain server-owned
- This addendum must not be read as:
  - approval for membership purchase runtime
  - approval for a second identity or organization truth
  - approval for billing, payment, invoice, or settlement truth

## 4. Current Truth Ownership Freeze

- `Server` remains the only truth owner for:
  - `users`
  - `sessions`
  - `organizations`
  - `organization_members`
  - `organization_certifications`
  - `audit_logs`
  - `config_entries`
  - `organization_paid_memberships`
  - `organization_membership_quota_snapshots`
- `Server` also remains the only verification owner for:
  - verified current-session context
  - current organization scope
  - organization-scoped membership read eligibility
- `BFF` may:
  - shape paid membership current
  - shape explanation
  - shape quota summary
  - shape upgrade guidance
  - project minimum shell summary
- `BFF` must not:
  - own paid-membership truth
  - own entitlement truth
  - own quota truth
  - own refresh progression truth
  - own payment or guarantee truth

## 5. Canonical Persistence Binding

- This dedicated package reuses the following existing table family:
  - `organizations`
  - `organization_members`
  - `audit_logs`
  - `config_entries`
- This dedicated package introduces the following minimum dynamic persistence family:
  - `organization_paid_memberships`
  - `organization_membership_quota_snapshots`
- No additional dedicated table may be introduced in this round for:
  - `membership_orders`
  - `membership_payments`
  - `billing_ledgers`
  - `invoice_profiles`
  - `guarantee_deposits`
  - `settlement_entries`
  - `membership_penalty_cases`

## 6. Current Paid-membership Cycle Truth Freeze

- `organization_paid_memberships` is the only current dynamic paid-membership cycle carrier.
- One current effective row represents:
  - one organization-scoped paid-membership cycle
  - one current tier posture
  - one current effective/expires time window
- It must not be overloaded to mean:
  - organization member status
  - certification status
  - payment completion ledger
  - guarantee qualification
- Current minimum fields must support:
  - `organization_id`
  - `tier_code`
  - `effective_at`
  - `expires_at`
  - `source_type`
  - `source_ref` optional
- Current hard rules:
  - `organization_id` must bind to an existing `organizations.id`
  - current paid-membership truth is organization-scoped, not user-scoped
  - Package 1 `organization_members.member_status` must not be reused as paid-membership truth
  - Package 1 `membershipStatus` projection must not be reused as paid-membership truth

## 7. Current Quota Truth Freeze

- `organization_membership_quota_snapshots` is the only current dynamic quota-summary carrier for V2.0.
- One row represents:
  - one organization
  - one quota type
  - one current value posture
  - one refresh-rule posture
- Current minimum fields must support:
  - `organization_id`
  - `quota_type`
  - `current_value`
  - `refresh_rule`
  - `next_refresh_at`
  - `last_refreshed_at`
- Current hard rules:
  - quota truth is summary truth only in this round
  - no separate quota-consumption workflow is approved in this round
  - no billing, payment, or guarantee amount may be stored in quota snapshots

## 8. Catalog And Explanation Source Freeze

- Tier catalog, entitlement notes, quota notes, and upgrade-display copy may remain server-owned catalog-like truth in either:
  - registered constant lookup tables
  - `config_entries`
- This round does not require a dedicated dynamic DB table for:
  - tier display copy
  - explanation notes
  - upgrade guidance disclosure copy
- Current hard rules:
  - these catalog-like truths must remain `Server`-owned
  - `BFF` and Flutter must not hardcode them as primary truth
  - candidate commercial display copy must remain non-transactional and non-order-creating

## 9. Current Activation Source Freeze

- V2.0 currently approves no end-user membership purchase flow.
- Therefore current paid-membership cycle truth may only be materialized by:
  - controlled server-side grant
  - controlled seed or migration
  - controlled backoffice or internal operation path after separate freeze
  - future dedicated payment package after separate freeze
- Current hard rules:
  - App and BFF must not create paid-membership cycle truth directly
  - no payment-order dependency is required for V2.0 read surfaces
  - no invoice, billing, or settlement truth may be inferred from the presence of a paid-membership cycle

## 10. Read-model Source Freeze

- `GET /api/app/profile/membership/current` must derive from:
  - verified current-session context
  - current organization scope
  - current effective row in `organization_paid_memberships`
  - current quota summary rows in `organization_membership_quota_snapshots`
  - server-owned tier/rule catalog
- `GET /api/app/profile/membership/explanation` must derive from:
  - server-owned tier/rule catalog
  - current package explanation notes
- `GET /api/app/profile/membership/quota` must derive from:
  - current organization-scoped quota snapshot rows
- `GET /api/app/profile/membership/upgrade-guide` must derive from:
  - current tier posture
  - server-owned tier catalog
  - candidate commercial disclosure copy
- `GET /api/app/shell/context` minimum paid-membership extension must derive from:
  - current effective paid-membership cycle
  - current quota summary
  - server-owned tier/rule catalog
- None of those handlers may use:
  - raw authorization as final auth truth
  - BFF-only cached truth
  - handwritten shadow state
  - client-reported tier or quota values

## 11. Summary Projection Freeze

- Current shell summary projection may expose only:
  - `paidMembershipTier`
  - `paidMembershipEntitlementsSummary`
  - `paidMembershipQuotaSummary`
  - `paidMembershipNextRefreshAt`
- These fields must be derived read-only projections.
- They must not become:
  - write targets
  - independent persisted shell truth
  - a second paid-membership state machine

## 12. Audit And Refresh Freeze

- Current package must audit at minimum:
  - paid-membership grant
  - paid-membership cycle replacement
  - paid-membership expiration materialization
  - quota refresh
  - quota manual adjustment
- Quota refresh remains server-owned only.
- Current quota refresh may be triggered by:
  - controlled scheduled job
  - controlled server-side lazy refresh before read
- Quota refresh must not be triggered by:
  - BFF-owned scheduler
  - Flutter client timing
  - raw shell refresh alone

## 13. Explicit Non-goals

- No membership purchase order truth
- No billing ledger truth
- No invoice truth
- No guarantee deposit truth
- No settlement truth
- No payment-provider callback truth in this package
- No second meaning for existing Package 1 `membershipStatus`
- No rich commercial history timeline

## 14. Current Meaning

- This addendum means:
  - the first dedicated backend-truth package for `我的楼 V2.0 paid membership` is now formally separated from the broader V2 planning baseline
  - current paid-membership read surfaces now have frozen dynamic carriers, summary-source rules, and audit ownership
- This addendum does not mean:
  - the current App already supports membership purchase
  - payment and billing runtime are approved
  - guarantee and settlement runtime are approved

## 15. Next Unique Action

- Next unique action:
  - freeze `docs/03_bff/membership_entitlement_v1_bff_surface_addendum.md`
