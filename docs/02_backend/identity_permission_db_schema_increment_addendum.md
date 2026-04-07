---
owner: Codex 总控
status: draft
purpose: Freeze the exact db_schema increment for the minimum identity, session, organization, certification, invitation, OTP, device, and security persistence round.
layer: L3 Backend
---

# 身份权限模块 db_schema 增量冻结单

## 1. Scope
- This file freezes the exact relational increment that must be added to
  `db_schema` for the minimum identity and permission round.
- It covers:
  - new tables
  - required columns
  - foreign keys
  - unique constraints
  - minimum indexes
  - required deltas on existing tables
- It does not cover:
  - service-layer implementation
  - BFF aggregation
  - Flutter pages
  - full security-engine expansion

## 2. Current Baseline
- Existing tables already frozen in `db_schema.md` and reused here:
  - `organizations`
  - `organization_members`
  - `audit_logs`
  - `file_assets`
- This round is additive.
- No existing identity-related valid table may be deleted or replaced.
- No Redis structure may replace relational truth in this round.

## 3. New Tables To Add
- `users`
- `user_identities`
- `sessions`
- `organization_certifications`
- `organization_invitations`
- `login_otp_codes`
- `devices`
- `security_events`

## 4. Existing Tables To Extend
- `organizations`
- `organization_members`
- `audit_logs`

## 5. Table Increment Freeze

### 5.1 `users`
- primary role:
  - root human actor truth
- columns:
  - `id uuid primary key`
  - `mobile varchar(32) not null`
  - `mobile_verified_at timestamptz null`
  - `nickname varchar(128) null`
  - `avatar_url text null`
  - `status varchar(32) not null default 'new'`
  - `last_login_at timestamptz null`
  - `last_login_ip inet null`
  - `created_at timestamptz not null`
  - `updated_at timestamptz not null`
- constraints:
  - unique index on normalized `mobile`
- allowed `status` values:
  - `new`
  - `active`
  - `disabled`
  - `frozen`
  - `cancelled`

### 5.2 `user_identities`
- primary role:
  - login identity binding
- columns:
  - `id uuid primary key`
  - `user_id uuid not null`
  - `identity_type varchar(32) not null`
  - `identity_value varchar(256) not null`
  - `verified_at timestamptz null`
  - `created_at timestamptz not null`
- foreign keys:
  - `user_id -> users.id`
- constraints:
  - unique index on `identity_type, identity_value`
- current-round allowed `identity_type`:
  - `mobile`
- reserved later values only:
  - `wechat`
  - `apple`
  - `email`

### 5.3 `devices`
- primary role:
  - per-user device trace and revoke carrier
- columns:
  - `id uuid primary key`
  - `user_id uuid not null`
  - `device_fingerprint varchar(256) not null`
  - `device_name varchar(128) null`
  - `os_type varchar(32) null`
  - `app_version varchar(64) null`
  - `first_seen_at timestamptz not null`
  - `last_seen_at timestamptz not null`
  - `trust_status varchar(32) not null default 'unknown'`
- foreign keys:
  - `user_id -> users.id`
- constraints:
  - unique index on `user_id, device_fingerprint`
- allowed `trust_status` values:
  - `unknown`
  - `trusted`
  - `untrusted`
  - `revoked`

### 5.4 `sessions`
- primary role:
  - refresh-token and device session truth
- columns:
  - `id uuid primary key`
  - `user_id uuid not null`
  - `refresh_token_hash varchar(256) not null`
  - `device_id uuid null`
  - `device_name varchar(128) null`
  - `ip inet null`
  - `user_agent text null`
  - `status varchar(32) not null default 'valid'`
  - `expires_at timestamptz not null`
  - `revoked_at timestamptz null`
  - `created_at timestamptz not null`
- foreign keys:
  - `user_id -> users.id`
  - `device_id -> devices.id`
- constraints:
  - unique index on `refresh_token_hash`
- rules:
  - plaintext refresh token must never be stored
  - `status='revoked'` and `revoked_at is not null` must stay aligned
- allowed `status` values:
  - `valid`
  - `expired`
  - `revoked`
  - `device_untrusted`

### 5.5 `organization_certifications`
- primary role:
  - one organization certification truth stream
- columns:
  - `id uuid primary key`
  - `organization_id uuid not null`
  - `certification_status varchar(32) not null`
  - `legal_name varchar(256) not null`
  - `uscc varchar(64) not null`
  - `license_file_id uuid not null`
  - `submitted_at timestamptz null`
  - `reviewed_at timestamptz null`
  - `reviewed_by uuid null`
  - `reject_reason text null`
  - `expires_at timestamptz null`
  - `created_at timestamptz not null`
  - `updated_at timestamptz not null`
- foreign keys:
  - `organization_id -> organizations.id`
  - `license_file_id -> file_assets.id`
  - `reviewed_by -> users.id`
- constraints:
  - partial unique index for one current active certification row per
    `organization_id`
- allowed `certification_status` values:
  - `not_submitted`
  - `pending_review`
  - `approved`
  - `rejected`
  - `expired`
- hard rule:
  - `license_file_id` is file truth
  - `objectKey` must never become certification truth

### 5.6 `organization_invitations`
- primary role:
  - invite-code join truth
- columns:
  - `id uuid primary key`
  - `organization_id uuid not null`
  - `invite_code varchar(128) not null`
  - `role_key varchar(64) not null`
  - `inviter_user_id uuid not null`
  - `expires_at timestamptz not null`
  - `used_at timestamptz null`
  - `used_by uuid null`
  - `created_at timestamptz not null`
- foreign keys:
  - `organization_id -> organizations.id`
  - `inviter_user_id -> users.id`
  - `used_by -> users.id`
- constraints:
  - unique index on `invite_code`

### 5.7 `login_otp_codes`
- primary role:
  - OTP send and consume truth
- columns:
  - `id uuid primary key`
  - `mobile varchar(32) not null`
  - `otp_code_hash varchar(256) not null`
  - `scene varchar(32) not null`
  - `expires_at timestamptz not null`
  - `consumed_at timestamptz null`
  - `send_ip inet null`
  - `send_device_id varchar(256) null`
  - `created_at timestamptz not null`
- rules:
  - plaintext OTP must never be stored
- current-round allowed `scene`:
  - `login`

### 5.8 `security_events`
- primary role:
  - minimum risk and security signal persistence
- columns:
  - `id uuid primary key`
  - `user_id uuid null`
  - `organization_id uuid null`
  - `event_type varchar(64) not null`
  - `risk_level varchar(32) not null`
  - `detail_json jsonb not null`
  - `created_at timestamptz not null`
- foreign keys:
  - `user_id -> users.id`
  - `organization_id -> organizations.id`
- current-round allowed `risk_level`:
  - `low`
  - `medium`
  - `high`
  - `critical`

## 6. Existing-table Delta Freeze

### 6.1 `organizations` delta
- required columns that must exist before identity implementation:
  - `name varchar(256) not null`
  - `organization_type varchar(32) not null`
  - `province_code varchar(32) null`
  - `city_code varchar(32) null`
  - `contact_name varchar(128) null`
  - `contact_mobile varchar(32) null`
  - `uscc varchar(64) null`
  - `business_license_file_id uuid null`
  - `intro text null`
  - `status varchar(32) not null default 'draft'`
  - `created_by uuid null`
  - `created_at timestamptz not null`
  - `updated_at timestamptz not null`
- foreign keys:
  - `business_license_file_id -> file_assets.id`
  - `created_by -> users.id`
- allowed `organization_type` values:
  - `demand`
  - `supplier`
  - `both`
  - `platform`
- allowed `status` values:
  - `draft`
  - `active`
  - `suspended`
  - `closed`

### 6.2 `organization_members` delta
- required columns that must exist before identity implementation:
  - `role_key varchar(64) not null`
  - `member_status varchar(32) not null`
  - `invited_by uuid null`
  - `invited_at timestamptz null`
  - `joined_at timestamptz null`
  - `disabled_at timestamptz null`
- foreign keys:
  - `invited_by -> users.id`
- constraints:
  - partial unique index on `organization_id, user_id` for non-removed rows
- allowed `member_status` values:
  - `invited`
  - `pending_accept`
  - `active`
  - `disabled`
  - `removed`
- allowed `role_key` values must stay aligned with
  `docs/00_ssot/permission_matrix.md`

### 6.3 `audit_logs` delta
- no new table is introduced for identity auditing
- identity actions must reuse `audit_logs`
- required action expansion:
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

## 7. Minimum Index Freeze
- `users`
  - unique index on normalized `mobile`
- `user_identities`
  - unique index on `identity_type, identity_value`
  - index on `user_id`
- `devices`
  - unique index on `user_id, device_fingerprint`
  - index on `last_seen_at`
- `sessions`
  - unique index on `refresh_token_hash`
  - index on `user_id, status`
  - index on `expires_at`
- `organization_certifications`
  - index on `organization_id, certification_status`
  - unique current-row index on `organization_id`
- `organization_invitations`
  - unique index on `invite_code`
  - index on `organization_id, expires_at`
- `login_otp_codes`
  - index on `mobile, scene, created_at`
  - index on `expires_at`
- `security_events`
  - index on `user_id, created_at`
  - index on `organization_id, created_at`
  - index on `event_type, risk_level, created_at`

## 8. Referential Rules
- `Organization` creator must exist in `users` before admin membership materializes.
- `OrganizationCertification.license_file_id` must point to confirmed file truth.
- `OrganizationInvitation.used_by` must not be filled before a successful join.
- `Session.device_id` may be null only when the client did not provide a device
  carrier in the current round.
- `OrganizationMember.role_key` must remain one of the currently frozen role keys.

## 9. No-go Rules
- no new table for plaintext token storage
- no new table for plaintext OTP storage
- no Redis-only session truth
- no `objectKey` as organization or certification truth
- no BFF-owned identity mirror table
- no second membership table

## 10. Migration-readiness Gate
- This increment is ready to be translated into forward-only migrations.
- Migration authoring must:
  - add new tables above
  - add missing columns to `organizations` and `organization_members`
  - add indexes and foreign keys above
  - avoid destructive replacement of existing valid tables
- Migration authoring is not allowed yet to:
  - rename current valid role keys
  - delete current valid organization truth
  - move audit into a second table
  - skip `file_assets.id` linkage for certification materials

## 11. Dispatch Conclusion
- This file is the exact `db_schema` increment freeze for the minimum identity round.
- Backend Agent may use it to prepare:
  - migration design
  - repository persistence patch scope
  - service write-chain implementation plan
- Code still must wait for:
  - audit-spec identity increment freeze
  - BFF route-to-truth alignment freeze
