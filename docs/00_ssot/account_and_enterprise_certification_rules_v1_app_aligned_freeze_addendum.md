---
owner: Codex 总控
status: draft
purpose: Freeze the App-aligned governance rules for account access, organization qualification, certification release, and review responsibilities for V1, while staying inside the current organization-centered identity truth.
layer: L0 SSOT
---

# 账户与企业认证规则 V1 App 对齐冻结稿

## 1. Scope
- This file applies only to the current V1 governance package for:
  - account access
  - login and session entry
  - organization handoff
  - organization-centered certification release
  - certification review and resubmit loop
  - transaction eligibility gating derived from current truth
- This file does not by itself:
  - implement full personal real-name certification
  - replace current identity truth with a person-first truth
  - define report, penalty, appeal, contract, or fulfillment governance
  - approve implementation or release

## 2. Alignment Basis
- This file is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
  - [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md)
  - [exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/exhibition_trade_governance_four_documents_app_aligned_freeze_v1.md)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)

## 3. Current Formal Truth Boundary
- `Server` remains the only truth owner for:
  - user identity
  - session
  - organization
  - organization membership
  - organization certification
  - certification review result
- `BFF` may:
  - normalize auth
  - shape shell context
  - shape profile consumption payloads
  - return controlled forbidden and unavailable responses
- `BFF` must not:
  - own certification truth
  - own final eligibility truth
  - own review workflow truth
- `Flutter App` may:
  - host login, organization handoff, and certification consumption pages
  - enforce client-side handoff order
  - display current eligibility explanation
- `Flutter App` must not:
  - become final permission judge
  - invent a second certification state machine
  - guess certification outcome locally

## 4. Identity And Qualification Core Ruling
- The current V1 identity and qualification system remains organization-centered.
- Current formal truths remain:
  - `organization`
  - `organization_members`
  - `certificationStatus`
  - `roleKeys`
  - object scope
- Product language may still say:
  - account
  - enterprise certification
  - responsible actor
  - transaction qualification
- But the current implementation truth must not introduce:
  - a second “real-name actor” truth family for transaction eligibility
  - a parallel enterprise identity registry outside current organization truth
  - a second role system beside current `roleKeys`

## 5. One-line Goal
- The first certification-governance goal is:
  - a logged-in actor enters the shell
  - completes organization handoff where needed
  - consumes current certification state
  - is released or blocked for project publish and bid actions through the
    current eligibility chain

## 6. Current Formal Actor Release Model
- Current App-facing actor release must be derived from the combination of:
  - actor identity present
  - valid session
  - current organization scope present
  - membership status valid
  - certification status approved when required
  - role allowed by `permission_matrix.md`
  - object scope allowed when the action is instance-bound
- This document freezes:
  - no single Boolean field may replace that combined judgement
  - no page may skip organization or certification handoff and still claim
    transaction eligibility

## 7. Current Formal Route Family
- App-facing identity and certification routes must stay inside `/api/app/*`.
- The current minimum route family remains:
  - `POST /api/app/auth/otp/send`
  - `POST /api/app/auth/otp/login`
  - `POST /api/app/auth/refresh`
  - `POST /api/app/auth/logout`
  - `GET /api/app/shell/context`
  - `GET /api/app/profile/index`
  - `POST /api/app/profile/organization/create`
  - `POST /api/app/profile/organization/join-by-code`
  - `POST /api/app/profile/organization/switch`
  - `GET /api/app/profile/organization/mine`
  - `GET /api/app/profile/organization/members`
  - `PATCH /api/app/profile/organization/members/{memberId}/role`
  - `PATCH /api/app/profile/organization/members/{memberId}/disable`
  - `POST /api/app/profile/certification/submit`
  - `GET /api/app/profile/certification/current`
  - `POST /api/app/profile/certification/resubmit`
  - `GET /api/app/profile/security/devices`
  - `POST /api/app/profile/security/devices/{deviceId}/revoke`
- This document explicitly forbids:
  - bare `/auth/*` route families for Flutter
  - bare `/organizations/*` route families for Flutter
  - bare `/me/*` route families as a second identity family

## 8. Current Admin Review Route Family
- Admin review remains `Server`-admin only.
- The current admin baseline remains:
  - `GET /server/admin/reviews/organizations`
  - `GET /server/admin/reviews/organizations/{organizationId}`
  - `POST /server/admin/reviews/organizations/{organizationId}/approve`
  - `POST /server/admin/reviews/organizations/{organizationId}/reject`
  - `GET /server/admin/security-events`
- This document does not yet freeze:
  - a separate person-real-name review desk
  - a full qualification-material multi-desk review system

## 9. Current Formal Object Family
- Already present or already directionally frozen:
  - `users`
  - `user_identities`
  - `sessions`
  - `organizations`
  - `organization_members`
  - `organization_certifications`
  - `organization_invitations`
  - `login_otp_codes`
  - `devices`
  - `security_events`
  - `audit_logs`
- Keep rule:
  - keep `organizations`, `organization_members`, and `audit_logs`
  - extend only through formal backend truth freeze first
- This document does not approve:
  - speculative new entity families not already tied to login,
    organization, certification, or security

## 10. Current State Families
- User:
  - `new`
  - `active`
  - `disabled`
  - `frozen`
  - `cancelled`
- Session:
  - `valid`
  - `expired`
  - `revoked`
  - `device_untrusted`
- Organization:
  - `draft`
  - `active`
  - `suspended`
  - `closed`
- Certification:
  - `not_submitted`
  - `pending_review`
  - `approved`
  - `rejected`
  - `expired`
- Member:
  - `invited`
  - `pending_accept`
  - `active`
  - `disabled`
  - `removed`

## 11. Certification Release Rule
- Project publish release:
  - actor identity present
  - organization scope present
  - buyer-side role allowed
  - `certificationStatus = approved`
- Bid submit release:
  - actor identity present
  - organization scope present
  - supplier-side role allowed
  - `certificationStatus = approved`
- These release rules must be explained to users through:
  - blocked-state copy
  - route handoff
  - current status display
- They must not be implemented through:
  - hidden local feature toggles
  - undocumented client-side bypass

## 12. Current Guard Order
- The current guard order remains:
  1. shell bootstrap
  2. login
  3. session refresh
  4. organization
  5. hidden building
  6. role and object permission
  7. certification
- This document freezes one additional interpretation:
  - certification is not the first gate
  - certification is meaningful only after actor identity and organization
    scope are already present

## 13. Current Client Surface Freeze
- The current client family accepted in direction is:
  - login page
  - OTP verify page
  - first-login organization fork
  - organization create
  - organization join
  - organization switch
  - certification current / submit / resubmit
  - session-invalid handoff
  - company summary under `profile`
- Current concrete presence in the repo already includes at least:
  - login handoff
  - organization handoff
  - certification current page
  - company view
  - session center
- This document explicitly forbids downstream agent wording such as:
  - “full certification center already implemented”
  - “full security center already implemented”
  - “my page already contains the full governance hub”

## 14. Current Audit Requirements
- The following actions must remain auditable:
  - login success
  - login failure
  - refresh rotation
  - logout
  - organization create
  - organization join
  - organization switch
  - role change
  - member disable
  - certification submit
  - certification approve
  - certification reject
- Audit records must remain `Server` truth, not `BFF` truth.

## 15. Current Risk Minimum
- The following minimum risk signals remain in scope:
  - same device high-frequency registration
  - same USCC reused across multiple organizations
  - same mobile short-period multi-organization join attempts
  - OTP abuse and rate-limit breaches
- This document does not yet freeze:
  - full trust score
  - full blacklist and appeal workflow
  - advanced abnormal-behavior scoring

## 16. Explicit Non-goals
- No second real-name certification truth for current Flutter transaction gating
- No person-only transaction eligibility path
- No second app-facing role family
- No second organization registry
- No bare non-`/api/app/*` identity route family
- No client-side final permission judgement
- No direct implementation claim for all planned identity pages

## 17. Acceptance Gate For This Rule Set
- Unauthenticated access to protected transaction surfaces must hand off to
  login and preserve continuation target.
- Login success with no organization must hand off to organization create/join.
- Organization scope without approved certification must not pass project publish
  or bid-submit release.
- Organization switch must change shell context and page eligibility.
- Certification submit / approve / reject must produce audit evidence.
- Controlled blocked-state copy must explain:
  - why the action is blocked
  - where the user should go next

## 18. Next Single Action
- The next single action after this freeze is:
  - freeze the L2 contract package for account and enterprise certification
    against the current `/api/app/profile/*` and `/server/admin/reviews/*`
    families only
