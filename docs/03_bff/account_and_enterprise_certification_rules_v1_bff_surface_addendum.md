---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side aggregation and shaping boundary for account access, organization handoff, certification consumption, and eligibility-blocked copy under the current App truth system without creating a second identity, organization, or certification owner.
layer: L3 BFF
---

# 账户与企业认证规则 V1 BFF Surface Addendum

## Scope
- This addendum applies only to the first dedicated `docs/03_bff` package for:
  - OTP login and logout handoff shaping
  - shell context aggregation
  - profile index aggregation
  - organization create, join, switch, and member-management handoff shaping
  - certification current, submit, and resubmit handoff shaping
  - security-device list and revoke handoff shaping
  - eligibility-blocked copy consumed by exhibition-side publish and bid entries
- This addendum does not by itself:
  - unlock `apps/bff` implementation
  - unlock `apps/server` implementation
  - approve a full personal real-name center
  - approve a second qualification center under `exhibition`
  - approve any admin review path through `BFF`

## Alignment Basis
- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [bff_ssot.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_ssot.md)
  - [bff_routes.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_routes.md)
  - [account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md)
  - [account_and_enterprise_certification_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md)
  - [account_and_enterprise_certification_rules_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/account_and_enterprise_certification_rules_v1_backend_truth_addendum.md)
  - [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md)
  - [permission_matrix.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/permission_matrix.md)

## Addendum Role
- Current `L0`, `L2`, and `L3 Backend` documents have already frozen:
  - identity and certification truth ownership
  - app-facing path families
  - backend persistence and state responsibilities
  - admin review ownership
- This addendum upgrades that package into a dedicated `BFF`-surface package for:
  - current route-group coverage
  - allowed shaping responsibilities
  - blocked and unavailable response shaping
  - cross-building consumption boundaries
- This addendum must not be read as:
  - approval for `BFF` truth ownership
  - approval for admin review through `BFF`
  - approval for a second eligibility state machine

## Current BFF Route-group Surface
- The only current `BFF` route groups relevant to this package are:
  - `auth`
  - `shell`
  - `profile`
- The current minimal path family is:
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
- Admin-side review and security paths remain:
  - `Server` Admin only
  - outside the current `BFF` surface package

## Current Aggregation Role
- `BFF` may do only:
  - auth consolidation
  - request and trace propagation
  - actor-context normalization
  - shell and profile read-model shaping
  - organization-switch handoff shaping
  - certification-blocked copy shaping
  - light idempotency where already allowed by the frozen `BFF` baseline
- `BFF` must not do:
  - certification final decision
  - review-state progression
  - role or permission final judgement
  - security-event final classification
  - device-trust final decision

## Non-owner Boundary
- `BFF` must not own:
  - `users`
  - `sessions`
  - `organizations`
  - `organization_members`
  - `organization_certifications`
  - `organization_invitations`
  - `devices`
  - `security_events`
  - derived eligibility truth
- `BFF` must not persist:
  - certification state
  - organization scope truth
  - membership truth
  - device truth
  - a second shell-summary store

## Auth Handoff Boundary
- For the current `auth` family, `BFF` may:
  - normalize current device metadata
  - normalize request id and trace id
  - forward OTP send, login, refresh, and logout to `Server`
  - shape the minimum success and failure envelope required by Flutter App
- `BFF` may not:
  - own OTP truth
  - own refresh-token truth
  - own session lifecycle
  - invent password-login, WeChat-login, or SSO behavior in this package
- Current bounded output family is limited to:
  - success
  - session invalid
  - rate limited
  - permission insufficient
  - controlled unavailable

## Shell Context Shaping Boundary
- `GET /api/app/shell/context` remains the only current shell bootstrap carrier.
- `BFF` may shape only the frozen minimum shell field family:
  - `userId`
  - `organizationId`
  - `roleKeys`
  - `certificationStatus`
  - `membershipStatus`
  - `visibleBuildings`
  - `featureFlagsVersion`
  - `unreadSummary`
- `BFF` may also shape currently allowed optional fields only when upstream truth is present and contracts already permit them.
- `BFF` must not:
  - synthesize missing organization scope
  - synthesize certification approval
  - synthesize role grants
  - hide missing critical fields behind fake success

## Profile Index Shaping Boundary
- `GET /api/app/profile/index` remains the current profile-side summary carrier.
- `BFF` may shape only:
  - current account summary projection
  - current organization summary projection
  - current membership summary projection
  - current certification summary projection
  - current security-device entry hints
- `BFF` must not shape:
  - a full governance center
  - a full risk center
  - a second enterprise registry
  - a person-real-name certification center

## Organization Handoff Boundary
- `BFF` may forward and shape only the current organization handoff family:
  - create
  - join-by-code
  - switch
  - mine
  - members
  - member role change
  - member disable
- Current `BFF` shaping rule is:
  - organization switch must hand off through existing shell reload semantics
  - organization create and join may return only bounded success or bounded failure envelopes
  - member role and disable actions may return only bounded action acknowledgements and controlled invalid or forbidden responses
- `BFF` must not:
  - decide final member role validity
  - decide final member disable legality
  - own invite-code truth

## Certification Handoff Boundary
- `BFF` may forward and shape only the current certification family:
  - submit
  - current
  - resubmit
- `BFF` may shape only:
  - current certification state read model
  - bounded submit acceptance
  - bounded resubmit acceptance
  - reject-reason projection already owned by `Server`
- `BFF` must not:
  - approve certification
  - reject certification
  - define a local certification workflow graph
  - expose admin review queue semantics to ordinary app actors

## Device And Security Boundary
- `BFF` may forward and shape only:
  - `GET /api/app/profile/security/devices`
  - `POST /api/app/profile/security/devices/{deviceId}/revoke`
- `BFF` may shape:
  - device list read model
  - revoke acknowledgement
  - bounded unavailable or invalid responses
- `BFF` must not:
  - own device truth
  - own device trust score
  - expose admin `security-events` through the app-facing profile family

## Blocked-state Copy Boundary
- `BFF` may shape only bounded user-facing blocked or unavailable explanations such as:
  - 当前需先登录
  - 当前需先完成组织承接
  - 当前企业认证未完成
  - 当前认证审核中
  - 当前认证未通过，请按驳回原因补充后重试
  - 当前权限不足
- `BFF` may not expose:
  - raw reviewer notes beyond already frozen reject-reason projection
  - raw internal security-event detail
  - raw permission-matrix internals
  - internal review-task or ticket-routing semantics

## Exhibition-side Consumption Rule
- `exhibition` may consume only:
  - current shell context fields required by publish and bid gates
  - bounded blocked-state copy
  - current organization and certification summary cues already shaped by `BFF`
- `exhibition` must not receive from `BFF`:
  - a second certification page tree
  - a second organization-truth projection outside `profile`
  - local bypass flags that override current permission and certification truth

## Profile-side Consumption Rule
- `profile` remains the only current primary building for:
  - organization handoff
  - certification current, submit, and resubmit
  - device list and revoke
- `BFF` may support `profile` with:
  - shell-aware shaping
  - current organization and certification projections
  - bounded action acknowledgements
- `BFF` must not turn `profile` into:
  - an admin review console
  - a second security-event console
  - a full governance center in this package

## Explicit Non-goals
- No admin review routes through `BFF`
- No person-real-name review family
- No second eligibility state machine
- No second organization registry
- No risk-center or governance-center surface in this package
- No implementation unlock by this addendum alone

## Formal Conclusion
- Current formal conclusion:
  - `BFF` may aggregate and shape only the current `auth / shell / profile` surface required by `账户与企业认证规则 V1`
  - `BFF` may provide bounded blocked-state copy and shell/profile shaping only
  - `BFF` may not own identity, organization, certification, eligibility, review, or security-event truth
  - admin review remains outside `BFF` and continues to use `Server` Admin APIs directly
- Current meaning:
  - `L3 BFF` aggregation and surface freeze only
  - no implementation unlock by this document alone

## Next Unique Action
- After this BFF surface package is frozen, continue with:
  - `假项目举报与裁决规则 V1` BFF surface freeze
- Keep the next dispatch bounded to:
  - report submit acknowledgment shaping
  - temporary restriction read shaping
  - controlled admin non-exposure
