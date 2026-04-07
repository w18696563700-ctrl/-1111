---
owner: Codex 总控
status: draft
purpose: Freeze the Admin-side controlled governance surface for Package 1 organization certification review and minimum security-event read access, without creating a second truth root or a sixth Admin module.
layer: L3 Admin
---

# 《账户与企业认证规则 V1》Admin Surface Addendum

## Scope
- This addendum applies only to the Package 1 Admin surface for:
  - organization certification review list and detail
  - organization certification approve and reject actions
  - minimum security-event read surface
- This addendum does not by itself:
  - unlock `apps/admin` implementation
  - create a sixth Admin module
  - create a second review truth
  - create a second security-event truth

## Alignment Basis
- This addendum is aligned against:
  - [admin_ssot.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/05_admin/admin_ssot.md)
  - [admin_governance_surface_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/05_admin/admin_governance_surface_matrix.md)
  - [account_and_enterprise_certification_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md)
  - [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)

## Module Ownership Rule
- Package 1 Admin surface must stay inside the existing Admin module constitution.
- The current accepted module binding is:
  - `review`
    - organization certification review list / detail / approve / reject
    - bounded read-only security-event companion surface for review triage
- This package must not create:
  - a sixth Admin module only for Package 1
  - a separate certification-center module
  - a separate security-center module

## Current Admin Route-family Freeze
- Package 1 Admin consumes only current `Server` Admin APIs:
  - `GET /server/admin/reviews/organizations`
  - `GET /server/admin/reviews/organizations/{organizationId}`
  - `POST /server/admin/reviews/organizations/{organizationId}/approve`
  - `POST /server/admin/reviews/organizations/{organizationId}/reject`
  - `GET /server/admin/security-events`
- Admin must not consume:
  - `BFF`
  - app-facing `/api/app/*` routes
  - direct database access

## Review Surface Freeze
- The Admin `review` module for Package 1 may expose only:
  - review list
  - review detail
  - approve action
  - reject action
  - current submitted/reviewed timestamps when already materialized by `Server`
  - current reject reason projection when already materialized by `Server`
- It must not expose:
  - second mutable review history store
  - second review task truth
  - direct row mutation outside the controlled review action path

## Security-event Companion Surface Freeze
- Package 1 may expose a bounded read-only `security-events` companion surface only for:
  - triage context
  - risk attention context
  - current event list filtering already exposed by `Server`
- This read surface may show only:
  - event type
  - risk level
  - actor id when materialized
  - organization id when materialized
  - created at
- It must not expose:
  - direct governance decision actions
  - second risk-case workflow
  - a separate platform risk-center in this package

## Query Boundary
- `GET /server/admin/reviews/organizations` remains limited to:
  - `page`
  - `pageSize`
  - `status`
  - `keyword`
- `GET /server/admin/security-events` remains limited to:
  - `page`
  - `pageSize`
  - `eventType`
  - `riskLevel`
- No richer analytics, export-center, or bulk-ops surface is approved in this package.

## Governance-action Boundary
- Package 1 Admin actions remain limited to:
  - approve one organization certification review item
  - reject one organization certification review item
- Package 1 Admin must not:
  - mutate organization membership
  - mutate session truth
  - mutate permission truth
  - mutate `security_events`
  - bypass the controlled `Server` review path

## Boundary With Existing Admin Matrix
- This addendum narrows Package 1 usage inside the existing Admin matrix.
- It does not replace [admin_governance_surface_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/05_admin/admin_governance_surface_matrix.md).
- If any conflict appears:
  - Package 1 current-route and current-object narrowing in this addendum applies only to Package 1
  - broader Admin matrix remains the top-level module constitution

## Explicit Non-goals
- No implementation unlock by this addendum alone
- No sixth Admin module
- No second certification review truth
- No second security-event truth
- No direct database access model
- No Admin call to `BFF`

## Formal Conclusion
- Current formal conclusion:
  - Package 1 Admin surface remains bounded to organization certification review and minimum security-event read access under the existing `review` module family
  - Admin continues to use controlled `Server` Admin APIs directly
  - current Package 1 Admin freeze is docs-only and does not unlock implementation
