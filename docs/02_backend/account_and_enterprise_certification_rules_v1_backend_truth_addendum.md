---
owner: Codex 总控
status: draft
purpose: Freeze the dedicated backend truth, persistence, review ownership, and audit/evidence linkage for account access and enterprise certification governance under the current App truth system.
layer: L3 Backend
---

# 账户与企业认证规则 V1 Backend Truth Addendum

## 1. Scope
- This addendum applies only to the first dedicated `docs/02_backend` package for:
  - phone OTP login and session truth
  - organization create, join, switch, and membership truth
  - organization-centered certification submit, resubmit, and review truth
  - transaction eligibility release derived from current truth
  - minimum device, security-event, audit, and file-evidence linkage
- This addendum does not by itself:
  - unlock `apps/server` implementation
  - unlock `apps/bff` aggregation specs
  - approve a full personal real-name truth family
  - approve full risk-center runtime
  - approve report, adjudication, penalty, blacklist, whitelist, or ban runtime

## 2. Alignment Basis
- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
  - [account_login_identity_permission_minimum_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md)
  - [account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/account_and_enterprise_certification_rules_v1_app_aligned_freeze_addendum.md)
  - [account_and_enterprise_certification_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/account_and_enterprise_certification_rules_v1_contracts_addendum.md)
  - [identity_permission_persistence_minimum_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/identity_permission_persistence_minimum_addendum.md)
  - [identity_permission_db_schema_increment_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/identity_permission_db_schema_increment_addendum.md)
  - [identity_permission_audit_log_increment_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/identity_permission_audit_log_increment_addendum.md)
  - [audit_log_spec.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/audit_log_spec.md)
  - [db_schema.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/db_schema.md)

## 3. Addendum Role
- `identity_permission_*` backend documents remain the generic minimum baseline.
- This addendum upgrades that baseline into the first dedicated backend-truth package for:
  - `账户与企业认证规则 V1`
- The dedicated package therefore freezes:
  - which baseline tables are the current canonical carriers
  - which state fields remain distinct
  - how eligibility is derived
  - which review projection is allowed
  - how file truth and audit truth must attach to certification
- This addendum must not be read as:
  - approval for a second identity registry
  - approval for a person-real-name review desk
  - approval for a wider exhibition transaction runtime package

## 4. Current Truth Ownership Freeze
- `Server` remains the only truth owner for:
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
- `Server` also remains the only verification owner for:
  - verified current-session context
  - protected-request actor and authorization truth
- `BFF` may:
  - normalize auth and session carriers
  - forward raw carriers and bounded hints as non-truth transport
  - shape shell and profile read models
  - return controlled unavailable and forbidden responses
- `BFF` must not:
  - certify current-session truth from raw carriers or header hints
  - persist certification truth
  - own eligibility truth
  - own review queue truth
  - own organization certification state progression
- `Admin` consumes `Server` Admin APIs directly.
- `Admin` is not itself a truth owner.

## 5. Canonical Persistence Binding
- This dedicated package adopts the following table set as the only current canonical persistence family:
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
  - `file_assets`
- No additional dedicated table may be introduced in this round for:
  - `real_identity_profiles`
  - `enterprise_certifications`
  - `qualification_assets`
  - `cert_review_tasks`
  - `eligibility_snapshots`
  - `responsible_person_profiles`
- Product wording may still refer to:
  - account
  - enterprise certification
  - responsible actor
  - transaction qualification
- But the relational truth must remain bound to the current table family above.
- The current auth/session truth split for this package remains:
  - raw `authorization` is transport carrier only
  - `sessions.refresh_token_hash` supports refresh-session persistence truth only
  - verified current-session context is a Server-side verification target
- The following raw inputs may enter the system only as carriers or hints and must not, alone or together, constitute final auth truth:
  - raw `authorization`
  - raw `x-actor-id`
  - raw `x-user-id`
  - raw `x-organization-id`
  - raw `x-actor-role`

## 6. Eligibility Derivation Freeze
- Current transaction eligibility is a derived decision, not an independent truth table.
- The canonical current-round decision inputs are:
  - verified current-session context under a trusted Server-side verification boundary
  - current actor `User.status = active`
  - current organization scope present
  - current `OrganizationMember.member_status = active`
  - current actor `role_key` allowed by `permission_matrix.md`
  - current `OrganizationCertification.certification_status = approved` when the action requires certification
  - current object-scope permission where the action is instance-bound
- Current-round hard rules:
  - raw `authorization` must not directly satisfy eligibility inputs
  - raw `x-actor-id`, `x-user-id`, `x-organization-id`, and `x-actor-role` must not directly satisfy eligibility inputs
  - the existence of any same-user valid session elsewhere must not substitute for the verified current-session context of the request being evaluated
- Current release surfaces may materialize a read projection for:
  - shell context
  - profile index
  - project-publish guard
  - bid-submit guard
- Current round must not persist a separate table whose sole purpose is:
  - replacing this derived decision with a duplicated eligibility truth

## 7. Organization And Certification State Responsibility Freeze
- `organizations.status` and `organization_certifications.certification_status` remain separate truth fields.
- `organizations.status` keeps organization lifecycle meaning:
  - `draft`
  - `active`
  - `suspended`
  - `closed`
- `organization_certifications.certification_status` keeps review meaning:
  - `not_submitted`
  - `pending_review`
  - `approved`
  - `rejected`
  - `expired`
- Current hard rules:
  - organization lifecycle state must not be overloaded to impersonate certification review state
  - certification review state must not be overloaded to impersonate organization lifecycle state
  - publish and bid release must key off certification truth, not organization lifecycle alone

## 8. Certification Transition Freeze
- Current minimum certification transition family remains:
  - `not_submitted -> pending_review`
  - `rejected -> pending_review`
  - `expired -> pending_review`
  - `pending_review -> approved`
  - `pending_review -> rejected`
  - `approved -> expired`
- Current-round transition rules:
  - `submit` and `resubmit` may only materialize `pending_review`
  - `approve` and `reject` are admin-only review actions
  - a second submit while already `pending_review` must be rejected
  - `approved` truth may expire by platform policy or certificate-validity policy, but must not silently re-enter `pending_review`

## 9. Organization Activation Coupling Freeze
- Current backend truth must support the following coupling rule:
  - when the first effective organization certification becomes `approved`, an organization still in `draft` may enter `active` in the same transaction
- Current backend truth must also support the following limits:
  - `approve` must not auto-restore an organization already in `suspended`
  - `approve` must not auto-restore an organization already in `closed`
  - `reject` must not silently set `organizations.status = closed`
- This keeps:
  - organization lifecycle governance
  - certification review governance
  - transaction release governance
  as related but still distinct truths

## 10. Certification Review Ownership Freeze
- The current admin review queue for this package must be a projection over:
  - `organizations`
  - `organization_certifications`
  - reviewer `users`
- Reviewer authorization must be derived from:
  - verified actor identity
  - active `organization_members` truth
  - role key `platform_reviewer` or `platform_super_admin`
  - `organizations.organization_type = platform`
- Raw `x-actor-role` must never be enough for review authorization.
- This round must not introduce:
  - a dedicated `organization_review_tasks` table
  - a second review-ticket table for the same certification decision
- Current admin review actions mutate:
  - `organization_certifications`
  - optionally `organizations.status` under the activation coupling rule above
  - `audit_logs`
  - `security_events` only when a risk signal is formally emitted
- Current admin review actions must not mutate:
  - membership role truth
  - session truth
  - object-permission truth
  unless there is a separately frozen governance package for that action

## 11. File Truth And Evidence Linkage Freeze
- `file_assets` remains the only file-truth carrier.
- `objectKey` is never certification or organization business truth.
- The current minimum certification evidence link family is:
  - `organizations.business_license_file_id`
  - `organization_certifications.license_file_id`
- Current semantics are:
  - `organizations.business_license_file_id`
    - current organization-facing display reference
  - `organization_certifications.license_file_id`
    - current submitted certification review reference
- The same `file_assets.id` may appear in both places.
- If they differ, review truth must use:
  - `organization_certifications.license_file_id`
- Current round does not add:
  - a separate evidence table for certification material bundles
  - OCR truth
  - raw file URL truth

## 12. Read-model Source Freeze
- `GET /api/app/shell/context` must derive from:
  - verified current-session context under a trusted Server-side verification boundary
  - current user
  - current organization scope
  - current active membership
  - current certification projection
- `GET /api/app/profile/index` must derive from:
  - current user
  - current organization projection
  - current membership projection
  - current certification projection
- `GET /server/admin/reviews/organizations` and detail must derive from:
  - `organizations`
  - `organization_certifications`
  - reviewer attribution
- `GET /server/admin/security-events` must derive from:
  - `security_events`
  - linked actor and organization attribution already materialized by `Server`
  - current admin-scope visibility and auditable query boundary
- None of those handlers may use:
  - raw `authorization` as final auth truth
  - raw `x-actor-id`
  - raw `x-user-id`
  - raw `x-organization-id`
  - raw `x-actor-role`
  - cached BFF-only truth
  - handwritten shadow state fields
  - Redis-only truth

## 13. Audit Increment Freeze
- This dedicated package adopts the current identity audit baseline as must-audit truth:
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
- Current dedicated package also freezes one interpretation:
  - certification submit and resubmit share the same audit action family `OrganizationCertificationSubmitted`
  - review detail reads current truth only; historical review reasoning depends on append-only audit and not on mutable in-row comment history
- Current round must not introduce:
  - mutable review history blobs inside the certification row
  - silent approve or reject without an audit row

## 14. Security-event Linkage Freeze
- `security_events` remains the minimum risk-signal carrier.
- This dedicated package accepts only the current minimum identity-governance event family:
  - `same_device_high_frequency_registration`
  - `same_uscc_reused_across_multiple_organizations`
  - `same_mobile_short_period_multi_organization_join`
  - `otp_rate_limit_breach`
- Current package meaning:
  - these events may influence admin attention and later governance packages
  - these events do not themselves become final certification or eligibility truth
- Current round must not introduce:
  - a second fraud case table
  - automatic penalty truth
  - blacklist truth

## 15. Explicit Non-goals
- No second person-real-name truth family
- No second enterprise identity registry
- No separate qualification-material package beyond the current certification file reference
- No full appeal, penalty, blacklist, whitelist, or permanent-ban truth in this package
- No transaction runtime widening beyond the current project-publish and bid eligibility gate
- No direct implementation unlock

## 16. Formal Conclusion
- Current formal conclusion:
  - `账户与企业认证规则 V1` now has a dedicated backend-truth package under `docs/02_backend`
  - the current canonical truth stays bound to the existing identity, organization, certification, file, audit, and security tables
  - transaction eligibility remains a derived server-side decision, not a duplicated persistence truth
  - organization certification review stays a projection-and-decision flow over current organization and certification truth, not a second review-ticket system
- Current stage meaning:
  - backend truth and persistence freeze only
  - no implementation unlock by this document alone
