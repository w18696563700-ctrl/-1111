---
owner: Codex 总控
status: draft
purpose: Freeze the minimum backend truth, persistence, and state boundary for login, identity, organization, certification, session, and security implementation.
layer: L3 Backend
---

# 身份权限模块后端持久化最小冻结单

## 1. Scope
- This file freezes the minimum backend truth additions required to implement:
  - phone OTP login
  - user and session truth
  - organization create and join
  - organization certification
  - member role and status control
  - minimum device and security-event traceability
- It does not freeze:
  - full SSO
  - advanced multi-organization collaboration
  - full security-center feature family
  - advanced risk engine or device-trust engine

## 2. Current Asset Baseline

### 2.1 Already reusable truth
- `Server` already owns:
  - user, session, organization, and membership context at domain-boundary level
- Current DB truth already contains:
  - `organizations`
  - `organization_members`
  - `audit_logs`
- Current audit system is append-only and already formal truth.

### 2.2 Missing truth that blocks full implementation
- No frozen persistence truth yet for:
  - `users`
  - `user_identities`
  - `sessions`
  - `organization_certifications`
  - `organization_invitations`
  - `login_otp_codes`
  - `devices`
  - `security_events`
- Current repo therefore does not yet have a formal relational home for:
  - login identity binding
  - refresh-token truth
  - certification truth
  - invite-code truth
  - OTP verification truth
  - device trust trace
  - minimum identity security signals

## 3. Truth Ownership Freeze
- `Server` is the only truth owner for:
  - `User`
  - `UserIdentity`
  - `Session`
  - `Organization`
  - `OrganizationMember`
  - `OrganizationCertification`
  - `OrganizationInvitation`
  - `Device`
  - `SecurityEvent`
- `BFF` may normalize auth and session headers, but must not persist identity truth.
- Redis may assist with:
  - OTP send-rate limiting
  - refresh coordination
  - short-lived invite lookup acceleration
  - short-lived session cache
- Redis must not replace relational truth for:
  - refresh-token truth
  - certification truth
  - membership truth
  - device truth

## 4. Minimum Table Freeze

### 4.1 `users`
- purpose:
  - one human actor root
- minimum columns:
  - `id`
  - `mobile`
  - `mobile_verified_at`
  - `nickname`
  - `avatar_url`
  - `status`
  - `last_login_at`
  - `last_login_ip`
  - `created_at`
  - `updated_at`
- minimum constraints:
  - normalized `mobile` unique
- state set:
  - `new`
  - `active`
  - `disabled`
  - `frozen`
  - `cancelled`

### 4.2 `user_identities`
- purpose:
  - login-identity binding and future extensibility
- minimum columns:
  - `id`
  - `user_id`
  - `identity_type`
  - `identity_value`
  - `verified_at`
  - `created_at`
- minimum constraints:
  - `identity_type + identity_value` unique
- current-round allowed values:
  - `mobile`
- later-only reserved values:
  - `wechat`
  - `apple`
  - `email`

### 4.3 `sessions`
- purpose:
  - refresh-token and device session truth
- minimum columns:
  - `id`
  - `user_id`
  - `refresh_token_hash`
  - `device_id`
  - `device_name`
  - `ip`
  - `user_agent`
  - `expires_at`
  - `revoked_at`
  - `created_at`
- minimum constraints:
  - `refresh_token_hash` unique
- secret rule:
  - plaintext refresh token must never be stored
- state set:
  - `valid`
  - `expired`
  - `revoked`
  - `device_untrusted`

### 4.4 `organizations`
- keep existing table as truth
- minimum identity-related columns that must exist before implementation:
  - `name`
  - `organization_type`
  - `province_code`
  - `city_code`
  - `contact_name`
  - `contact_mobile`
  - `uscc`
  - `business_license_file_id`
  - `intro`
  - `status`
  - `created_by`
  - `created_at`
  - `updated_at`
- `business_license_file_id` must reference file truth, not object storage key
- state set:
  - `draft`
  - `active`
  - `suspended`
  - `closed`

### 4.5 `organization_members`
- keep existing table as truth
- minimum columns that must exist before implementation:
  - `id`
  - `organization_id`
  - `user_id`
  - `role_key`
  - `member_status`
  - `invited_by`
  - `invited_at`
  - `joined_at`
  - `disabled_at`
- minimum constraints:
  - `organization_id + user_id` unique within active membership truth
- `role_key` must stay aligned with current formal keys:
  - `buyer_admin`
  - `buyer_member(scoped)`
  - `supplier_admin`
  - `supplier_member(scoped)`
  - `platform_reviewer`
  - `platform_support`
  - `platform_super_admin`
- state set:
  - `invited`
  - `pending_accept`
  - `active`
  - `disabled`
  - `removed`

### 4.6 `organization_certifications`
- purpose:
  - certification review truth for one organization
- minimum columns:
  - `id`
  - `organization_id`
  - `certification_status`
  - `legal_name`
  - `uscc`
  - `license_file_id`
  - `submitted_at`
  - `reviewed_at`
  - `reviewed_by`
  - `reject_reason`
  - `expires_at`
- minimum constraints:
  - current active certification row unique per `organization_id`
- file rule:
  - `license_file_id` references `file_assets.id`
  - `objectKey` is never certification truth
- state set:
  - `not_submitted`
  - `pending_review`
  - `approved`
  - `rejected`
  - `expired`

### 4.7 `organization_invitations`
- purpose:
  - invite-code join truth
- minimum columns:
  - `id`
  - `organization_id`
  - `invite_code`
  - `role_key`
  - `inviter_user_id`
  - `expires_at`
  - `used_at`
  - `used_by`
- minimum constraints:
  - `invite_code` unique

### 4.8 `login_otp_codes`
- purpose:
  - OTP send and consume truth
- minimum columns:
  - `id`
  - `mobile`
  - `otp_code_hash`
  - `scene`
  - `expires_at`
  - `consumed_at`
  - `send_ip`
  - `send_device_id`
- secret rule:
  - plaintext OTP must never be stored
- current-round allowed scenes:
  - `login`

### 4.9 `devices`
- purpose:
  - user device trace and revoke surface
- minimum columns:
  - `id`
  - `user_id`
  - `device_fingerprint`
  - `device_name`
  - `os_type`
  - `app_version`
  - `first_seen_at`
  - `last_seen_at`
  - `trust_status`
- minimum constraints:
  - `user_id + device_fingerprint` unique

### 4.10 `security_events`
- purpose:
  - minimum risk and security-signal persistence
- minimum columns:
  - `id`
  - `user_id`
  - `organization_id`
  - `event_type`
  - `risk_level`
  - `detail_json`
  - `created_at`

## 5. Relationship Freeze
- `users.id` -> root for `user_identities`, `sessions`, `devices`
- `organizations.id` -> root for `organization_members`,
  `organization_certifications`, `organization_invitations`
- `organization_members.user_id` references `users.id`
- `organization_members.organization_id` references `organizations.id`
- `organization_certifications.organization_id` references `organizations.id`
- `organization_invitations.organization_id` references `organizations.id`
- `organizations.business_license_file_id` references `file_assets.id`
- `organization_certifications.license_file_id` references `file_assets.id`

## 6. Minimum Write-chain Freeze

### 6.1 OTP login chain
1. send OTP
2. verify OTP
3. create or bind `UserIdentity`
4. create or rotate `Session`
5. append audit

### 6.2 Organization create chain
1. authenticated actor without required organization scope
2. create `Organization`
3. create `OrganizationMember` as admin
4. append audit

### 6.3 Organization join-by-code chain
1. authenticated actor
2. validate `OrganizationInvitation`
3. create or update `OrganizationMember`
4. mark invitation used when applicable
5. append audit

### 6.4 Certification submit chain
1. organization admin only
2. validate file truth reference
3. create or update `OrganizationCertification`
4. append audit

## 7. Audit Freeze For Identity Round
- This round extends the minimum must-audit backend action set with:
  - `OtpSent`
  - `LoginSucceeded`
  - `LoginFailed`
  - `SessionRefreshed`
  - `LogoutSucceeded`
  - `OrganizationCreated`
  - `OrganizationJoinRequested`
  - `OrganizationSwitched`
  - `OrganizationMemberRoleChanged`
  - `OrganizationMemberDisabled`
  - `OrganizationCertificationSubmitted`
  - `OrganizationCertificationApproved`
  - `OrganizationCertificationRejected`
- These actions must still follow append-only audit rules from
  `docs/02_backend/audit_log_spec.md`.

## 8. Minimum Risk Freeze
- The current minimum persisted risk signals are:
  - same device high-frequency registration
  - same USCC reused across multiple organizations
  - same mobile short-period multi-organization join attempts
  - OTP abuse and rate-limit breach
- These are persisted in `security_events`, not in ad hoc logs only.

## 9. Non-goals
- no weather-style provider cache truth
- no Redis-only session truth
- no file `objectKey` as certification truth
- no second identity truth in `BFF`
- no full legal-entity risk engine in this round
- no advanced device graph or fraud scoring in this round

## 10. Dispatch Readiness
- This file is sufficient to dispatch the next backend truth-freeze tasks:
  - extend `docs/02_backend/db_schema.md`
  - extend `docs/02_backend/audit_log_spec.md`
  - align L2 route payloads with relational truth
- This file is not by itself enough to start full backend implementation.
- Code may begin only after:
  1. `db_schema.md` absorbs the missing identity tables
  2. `audit_log_spec.md` absorbs the identity audit subset
  3. the L2 contracts are aligned with the persisted truth above
