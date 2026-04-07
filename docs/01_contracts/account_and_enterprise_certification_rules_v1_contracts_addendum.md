---
owner: Codex 总控
status: draft
purpose: Freeze the first dedicated L2 contract family for account access, organization handoff, enterprise certification, and organization review under the current App truth system.
layer: L2 Contracts
---

# 账户与企业认证规则 V1 Contracts Addendum

## Scope
- This addendum applies only to the first dedicated `L2` contract package for:
  - phone OTP login
  - session refresh and logout
  - shell context loading
  - organization create, join, switch, and member management
  - organization certification submit, current, and resubmit
  - organization certification admin review
  - minimum security-event read surface
- This addendum does not by itself:
  - unlock implementation
  - approve release
  - invent a second identity, organization, or permission truth
  - freeze a full personal real-name review family

## Alignment Basis
- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md)
  - [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md)
  - [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)
  - [identity_permission_minimum_contracts.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/identity_permission_minimum_contracts.yaml)
  - [openapi.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml)
  - [error_codes.yaml](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml)

## Contract Role
- `identity_permission_minimum_contracts.yaml` remains the minimum identity and
  permission transport baseline.
- This addendum upgrades that minimum baseline into the first dedicated
  `账户与企业认证规则 V1` contract family.
- `openapi.yaml` must therefore carry:
  - the current app-facing canonical paths
  - the current admin review canonical paths
  - the minimum schema family needed for those paths
- `error_codes.yaml` must carry the minimum error-code family used by this
  package.

## Canonical Path-family Rule
- Flutter App paths remain under:
  - `/api/app/*`
- Admin review paths remain under:
  - `/server/admin/*`
- This contract package must not create:
  - bare `/auth/*`
  - bare `/organizations/*`
  - bare `/me/*`
  - bare `/reviews/*`
  - bare `/security/*`

## Current App-facing Path Matrix
- Current app-facing identity and certification contract family is:
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

## Current Admin Path Matrix
- Current admin-side review and security contract family is:
  - `GET /server/admin/reviews/organizations`
  - `GET /server/admin/reviews/organizations/{organizationId}`
  - `POST /server/admin/reviews/organizations/{organizationId}/approve`
  - `POST /server/admin/reviews/organizations/{organizationId}/reject`
  - `GET /server/admin/security-events`

## Contract Object Families
- This contract package freezes the following object families only:
  - login command and session command objects
  - shell context read model
  - profile index read model
  - organization create, join, switch, and membership command objects
  - certification submit, current, and resubmit objects
  - organization review list and detail read models
  - organization review approve and reject command objects
  - security event list read model
- This package does not freeze:
  - person-real-name certification contracts
  - bank-account verification contracts
  - advanced device trust contracts
  - full risk-center contracts

## State Responsibility Freeze
- User, session, organization, membership, and certification state truth remain
  `Server` truth only.
- `BFF` may shape:
  - shell context
  - profile index
  - controlled unavailable responses
- `BFF` must not define:
  - review state progression
  - certification final decision truth
  - organization final eligibility truth

## Current Response-shape Freeze
- App-facing responses must preserve:
  - explicit organization scope
  - explicit membership state
  - explicit certification state
  - controlled nullable fields where scope may be absent
- Admin-facing responses must preserve:
  - list versus detail separation
  - organization review current status
  - submitted and reviewed timestamps where materialized
  - reject reason only as current review result projection, not as mutable
    client-owned text

## Admin Review Minimum Query Freeze
- `GET /server/admin/reviews/organizations` may expose only minimum review-list
  query fields in this round:
  - `page`
  - `pageSize`
  - `status`
  - `keyword`
- `GET /server/admin/security-events` may expose only minimum security-event
  query fields in this round:
  - `page`
  - `pageSize`
  - `eventType`
  - `riskLevel`
- No richer search or analytics query family is approved by this addendum.

## Admin Review Schema Freeze
- Organization review list must return:
  - `items`
  - `pagination`
- One organization review list item must carry at minimum:
  - `organizationId`
  - `name`
  - `organizationType`
  - `certificationStatus`
  - `submittedAt`
- Organization review detail must carry at minimum:
  - `organizationId`
  - `name`
  - `organizationType`
  - `certificationStatus`
  - `legalName`
  - `uscc`
  - `licenseFileId`
  - `contactName`
  - `contactMobile`
  - `submittedAt`
  - `reviewedAt`
  - `rejectReason`
- Review approve request may carry only:
  - `note`
- Review reject request must carry:
  - `reason`
  - optional `note`

## Security-event Schema Freeze
- Security-event list must return:
  - `items`
  - `pagination`
- One security-event item must carry at minimum:
  - `eventId`
  - `eventType`
  - `riskLevel`
  - `actorId`
  - `organizationId`
  - `createdAt`
- This round accepts only the current minimum event-type family aligned to the
  identity baseline:
  - `same_device_high_frequency_registration`
  - `same_uscc_reused_across_multiple_organizations`
  - `same_mobile_short_period_multi_organization_join`
  - `otp_rate_limit_breach`

## Error-family Freeze
- This contract package relies on the following existing namespaces:
  - `AUTH`
  - `ORG`
  - `CERTIFICATION`
  - `SECURITY`
  - `ORG_REVIEW`
- Minimum added or affirmed error-code family in this package must cover:
  - `AUTH_SESSION_INVALID`
  - `AUTH_OTP_SEND_INVALID`
  - `AUTH_OTP_LOGIN_INVALID`
  - `AUTH_REFRESH_INVALID`
  - `AUTH_LOGOUT_INVALID`
  - `AUTH_OTP_RATE_LIMITED`
  - `AUTH_PERMISSION_INSUFFICIENT`
  - `AUTH_RESOURCE_UNAVAILABLE`
  - `ORG_CREATE_INVALID`
  - `ORG_JOIN_INVALID`
  - `ORG_JOIN_DUPLICATE`
  - `ORG_SWITCH_INVALID`
  - `ORG_MEMBER_ROLE_INVALID`
  - `ORG_MEMBER_DISABLE_INVALID`
  - `CERTIFICATION_SUBMIT_INVALID`
  - `CERTIFICATION_RESUBMIT_INVALID`
  - `CERTIFICATION_DUPLICATE_SUBMIT`
  - `CERTIFICATION_CURRENT_UNAVAILABLE`
  - `ORG_REVIEW_RESOURCE_UNAVAILABLE`
  - `ORG_REVIEW_APPROVE_INVALID`
  - `ORG_REVIEW_REJECT_INVALID`
  - `ORG_REVIEW_INVALID_STATE`
  - `SECURITY_EVENTS_UNAVAILABLE`
  - `SECURITY_DEVICE_UNAVAILABLE`
  - `SECURITY_DEVICE_REVOKE_INVALID`

## Current Meaning
- This addendum means:
  - the first dedicated `账户与企业认证规则 V1` contract family is now formally
    separated from the broader four-document mother package
  - app-facing and admin-facing identity, organization, certification, and
    minimum review contracts are bound into one contract family
- This addendum does not mean:
  - the current profile building already contains a full governance center
  - the current App already implements all certification runtime
  - person-real-name review contracts are approved

## Explicit Non-goals
- No second identity family
- No second organization registry
- No second permission system
- No exhibition transaction report, penalty, blacklist, or appeal contracts in
  this package
- No automatic widening of the current project-publish board corridor

## Formal Conclusion
- Current formal conclusion:
  - `账户与企业认证规则 V1` enters `L2 contracts freeze`
  - the canonical route family remains inside `/api/app/*` and
    `/server/admin/*`
  - current minimum admin review and security-event contracts must now be
    materialized in `openapi.yaml` and `error_codes.yaml`
- Current stage meaning:
  - contract freeze only
  - no implementation unlock by this document alone
