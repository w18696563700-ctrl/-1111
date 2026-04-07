---
owner: Codex 总控
status: draft
purpose: Freeze the minimum current-round identity, login, organization, permission, and guard baseline so the V1 identity blueprint can be dispatched without outrunning the current repo truth.
layer: L0 SSOT
---

# 账号登录与身份权限模块最小冻结单

## 1. Scope
- This file compresses the proposed V1 identity blueprint into the minimum dispatchable scope for the current repo.
- It freezes:
  - login and session minimum direction
  - organization and certification minimum direction
  - role, object-permission, and guard minimum direction
  - app-facing and admin-facing route naming alignment
  - the minimum persistence additions that must be frozen before implementation
- It does not by itself implement:
  - all identity pages
  - all security-center features
  - full SSO or multi-organization advanced collaboration

## 2. Current Asset Baseline

### 2.1 Already frozen and reusable
- `Server` domain ownership already freezes:
  - `identity / organization` owns user, session, organization, and membership context
  - `Server` is the only truth owner
  - `BFF` never owns business truth
- `Flutter App` already has:
  - shell bootstrap context carrier
  - controlled shell blocking states:
    - `unauthenticated`
    - `session_refreshing`
    - `no_organization`
  - read-only profile carrier for:
    - organization
    - certification
    - membership
- `BFF` already has route groups for:
  - `shell`
  - `profile`
- Current app-facing shell path is already frozen:
  - `GET /api/app/shell/context`
- Current app-facing profile path is already frozen:
  - `GET /api/app/profile/index`
- Current role and scoped object-permission baseline is already frozen in
  `docs/00_ssot/permission_matrix.md`.

### 2.2 Already present in persistence truth
- `organizations`
- `organization_members`
- `audit_logs`

### 2.3 Missing but required before full implementation
- No frozen persistence truth yet for:
  - `users`
  - `user_identities`
  - `sessions`
  - `organization_certifications`
  - `organization_invitations`
  - `login_otp_codes`
  - `devices`
  - `security_events`
- No frozen app-facing write routes yet for:
  - OTP send/login
  - organization create/join/switch
  - certification submit/resubmit
  - device revoke
- No full client page family yet for identity workflows.

## 3. Current-round Unique Goal
- The minimum identity mainline must be:
  - phone OTP login
  - session establishment
  - shell context load
  - create organization or join organization
  - certification gate
  - role and object-permission enforcement
  - audit and minimum risk traceability
- The current round must not jump directly into:
  - ten login methods
  - full security center
  - complex multi-organization collaboration
  - advanced SSO

## 4. Non-negotiable Principles
- `Organization` is the business主体; person-only business execution is not allowed.
- Role is not equal to object permission.
- Certification status must participate in key-action release.
- Final permission judgement must stay in `Server`, not in Flutter.
- `BFF` may normalize auth and shape shell context, but may not become identity truth.
- `Admin` uses `Server` Admin APIs directly, not `BFF`.

## 5. Role Freeze

### 5.1 App-facing role names must stay aligned with existing truth
- `buyer_admin`
- `buyer_member(scoped)`
- `supplier_admin`
- `supplier_member(scoped)`
- `platform_reviewer`
- `platform_support`
- `platform_super_admin`

### 5.2 Practical mapping rule
- The V1 proposal names:
  - `需求方管理员`
  - `需求方成员`
  - `供给方管理员`
  - `供给方成员`
  - `平台审核员`
  - `平台客服/争议处理`
  - `平台超管`
- These are accepted only as product labels.
- The formal backend role keys must keep the existing frozen English keys above.

### 5.3 Additional role rules
- Organization creator becomes organization admin by default.
- Platform roles are never self-applied from the app.
- One user may belong to multiple organizations.
- The same user may hold different roles in different organizations.

## 6. Minimum Object Family Freeze
- `User`
- `UserIdentity`
- `Session`
- `Organization`
- `OrganizationMember`
- `OrganizationCertification`
- `OrganizationInvitation`
- `AuditLog`
- `SecurityEvent`
- `Device`

## 7. P0 / P1 Freeze

### 7.1 P0 must-do
- phone OTP login
- access token + refresh token session model
- shell context load
- create organization
- join organization by invite code
- organization switch
- certification submit and review state consumption
- minimum RBAC + scoped object permission enforcement
- login guard
- organization guard
- certification guard
- permission guard
- minimum audit logging
- minimum risk signals

### 7.2 P1 later
- WeChat shortcut login
- password login
- SSO
- advanced multi-organization collaboration
- richer device trust system
- richer abnormal-behavior detection
- stronger legal or bank-account verification

## 8. Guard Order Freeze
- The current client-side guard order must be:
  1. shell bootstrap guard
  2. login guard
  3. session refresh guard
  4. organization guard
  5. hidden-building guard
  6. role and object-permission guard
  7. certification guard
- The server-side action gate must still be:
  - actor identity present
  - organization scope present when required
  - role allowed
  - object scope allowed
  - certification allowed when required
  - idempotency and audit checks where required

## 9. Shell Context Freeze

### 9.1 Required now
- `userId`
- `organizationId`
- `roleKeys`
- `certificationStatus`
- `membershipStatus`
- `visibleBuildings`
- `featureFlagsVersion`
- `unreadSummary`

### 9.2 Optional extension fields allowed next
- `availableOrganizations`
- `currentOrganization`
- `entitlements`
- `securityHints`

### 9.3 Constraint
- The required field set above remains the minimum formal contract.
- Optional fields may be added only through contract freeze first.
- Flutter must not guess them locally.

## 10. App-facing Route Freeze

### 10.1 Naming rule
- App-facing identity routes must stay under `/api/app/*`.
- Do not open a second public route family such as bare `/auth/*` or bare
  `/organizations/*` for Flutter.

### 10.2 Minimum route set to freeze next
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

### 10.3 Admin route set to freeze next
- `GET /server/admin/reviews/organizations`
- `GET /server/admin/reviews/organizations/{organizationId}`
- `POST /server/admin/reviews/organizations/{organizationId}/approve`
- `POST /server/admin/reviews/organizations/{organizationId}/reject`
- `GET /server/admin/security-events`

## 11. Persistence Freeze To Add Before Implementation
- `users`
- `user_identities`
- `sessions`
- `organization_certifications`
- `organization_invitations`
- `login_otp_codes`
- `devices`
- `security_events`

### 11.1 Keep / remove rule
- Keep current `organizations`, `organization_members`, and `audit_logs`.
- Add the missing tables above through backend truth freeze first.
- Do not duplicate session truth in Redis-only form.
- Redis may help with OTP rate-limit, refresh coordination, or temporary invite
  lookup, but it does not replace relational truth.

## 12. State Freeze

### 12.1 User
- `new`
- `active`
- `disabled`
- `frozen`
- `cancelled`

### 12.2 Session
- `valid`
- `expired`
- `revoked`
- `device_untrusted`

### 12.3 Organization
- `draft`
- `active`
- `suspended`
- `closed`

### 12.4 Certification
- `not_submitted`
- `pending_review`
- `approved`
- `rejected`
- `expired`

### 12.5 Member
- `invited`
- `pending_accept`
- `active`
- `disabled`
- `removed`

## 13. Minimum Client Page Freeze

### 13.1 Must build in the first implementation round
- startup check page
- login page
- OTP verify page
- first-login organization fork page
- create organization page
- join organization page
- certification submit page
- session-invalid handoff page

### 13.2 Must not be treated as already implemented
- organization switch page
- member management page
- identity and security page
- no-permission page
- certification rejected resubmit page
- admin review pages
- These may be planned now but are not to be marked complete before truth,
  routes, and client shells exist.

## 14. Minimum Action Gates
- Publish project:
  - `buyer_admin` or allowed scoped buyer role
  - valid organization scope
  - certification approved
- Submit bid:
  - `supplier_admin` or allowed scoped supplier role
  - valid organization scope
  - certification approved
- Confirm contract:
  - role allowed by current object scope
- Submit milestone or inspection:
  - role allowed by current object scope
- Open dispute:
  - organization scope must belong to the current instance side

## 15. Audit And Risk Minimum

### 15.1 Must audit
- login success
- login failure
- refresh token rotation
- logout
- organization create
- organization join
- organization switch
- role change
- member disable
- certification submit
- certification approve
- certification reject

### 15.2 Minimum risk signals
- same device high-frequency registration
- same USCC reused across multiple organizations
- same mobile short-period multi-organization join attempts
- OTP abuse and rate-limit breaches

## 16. Current Non-goals
- full personal profile center
- advanced member-center product
- all 14 client pages in one round
- bare `/auth/*` public route family
- client-side final permission judgement
- no-audit identity actions

## 17. Dispatch Order
1. Freeze this minimum SSOT.
2. Freeze L2 identity routes and payload contracts.
3. Freeze L3 backend persistence additions for identity and organization.
4. Freeze L3 BFF route mapping and shell/profile aggregation expansion.
5. Implement `Server`.
6. Implement `BFF`.
7. Implement Flutter auth-shell and guard-shell pages.
8. Run independent verification.

## 18. Acceptance Gate
- unauthenticated access to protected surfaces returns to login handoff and keeps
  the return target
- login success without organization enters create/join organization fork
- uncertified organization cannot publish project or submit bid
- organization switch changes shell context and page eligibility
- missing object scope returns controlled forbidden or unavailable response
- access expiry may refresh silently
- refresh expiry returns to login handoff
- identity actions produce audit evidence
- minimum risk signals are traceable in governance or security review

## 19. Current Total-control Ruling
- The V1 blueprint is accepted in direction.
- The current repo must implement it as a minimum staged identity system, not as
  a one-round full account platform.
- No team may skip contract freeze and jump directly into page or table sprawl.
