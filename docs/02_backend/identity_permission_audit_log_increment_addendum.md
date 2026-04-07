---
owner: Codex 总控
status: draft
purpose: Freeze the exact audit_log_spec increment for the minimum identity, login, organization, certification, session, and security round.
layer: L3 Backend
---

# 身份权限模块 audit_log_spec 增量冻结单

## 1. Scope
- This file freezes the exact audit increment that must be added for the
  minimum identity round.
- It covers:
  - newly required identity and organization audit actions
  - before and after state semantics
  - attribution requirements
  - failed-attempt logging boundary
  - relationship with `security_events`
- It does not cover:
  - full fraud-event taxonomy
  - observability log pipeline design
  - admin console UI

## 2. Current Baseline
- `audit_logs` is already the formal append-only audit carrier.
- Existing business-chain audit truth must stay unchanged.
- This round adds identity-domain minimum audit semantics only.

## 3. Required Fields Still Apply
- All current required audit fields remain mandatory:
  - `id`
  - `object_type`
  - `object_id`
  - `object_no`
  - `action`
  - `actor_id`
  - `actor_role`
  - `before_state`
  - `after_state`
  - `reason`
  - `request_id`
  - `trace_id`
  - `occurred_at`

## 4. New Must-audit Actions For Identity Round
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

## 5. Object-type Freeze
- `OtpSent`
  - `object_type: login_otp_code`
- `LoginSucceeded`
  - `object_type: session`
- `LoginFailed`
  - `object_type: user_identity | session_recovery`
- `SessionRefreshed`
  - `object_type: session`
- `LogoutSucceeded`
  - `object_type: session`
- `OrganizationCreated`
  - `object_type: organization`
- `OrganizationJoinRequested`
  - `object_type: organization_member`
- `OrganizationSwitched`
  - `object_type: organization_scope`
- `OrganizationMemberRoleChanged`
  - `object_type: organization_member`
- `OrganizationMemberDisabled`
  - `object_type: organization_member`
- `OrganizationCertificationSubmitted`
  - `object_type: organization_certification`
- `OrganizationCertificationApproved`
  - `object_type: organization_certification`
- `OrganizationCertificationRejected`
  - `object_type: organization_certification`

## 6. Minimum Audit Semantics

### 6.1 `OtpSent`
- before:
  - `null`
- after:
  - `sent`
- rule:
  - only successful OTP send materialization appends `OtpSent`
  - rate-limited or rejected sends must not append `OtpSent`; they may only
    open `security_events`

### 6.2 `LoginSucceeded`
- before:
  - `unauthenticated`
- after:
  - `authenticated`
- rule:
  - append only when OTP verification succeeds and a session truth row is
    materialized or rotated successfully

### 6.3 `LoginFailed`
- before:
  - `unauthenticated`
- after:
  - `unauthenticated`
- rule:
  - append only for credential or OTP verification failure
  - transport timeout or infrastructure failure is not `LoginFailed`

### 6.4 `SessionRefreshed`
- before:
  - `valid`
- after:
  - `valid`
- rule:
  - append only when refresh rotation actually succeeds
  - duplicate or replayed refresh that is rejected must not append
    `SessionRefreshed`

### 6.5 `LogoutSucceeded`
- before:
  - `valid`
- after:
  - `revoked`
- rule:
  - append when current or selected session is successfully revoked

### 6.6 `OrganizationCreated`
- before:
  - `null`
- after:
  - `draft | active`
- rule:
  - append only when `Organization` truth row and creator admin membership are
    both materialized successfully

### 6.7 `OrganizationJoinRequested`
- before:
  - `null | removed`
- after:
  - `invited | pending_accept | active`
- rule:
  - append when join-by-code request is accepted into membership truth
  - duplicate invalid join requests must not append a second successful row

### 6.8 `OrganizationSwitched`
- before:
  - previous `organization_id`
- after:
  - next `organization_id`
- rule:
  - append only when the target organization is actually accessible to the
    actor and shell scope is switched successfully

### 6.9 `OrganizationMemberRoleChanged`
- before:
  - previous `role_key`
- after:
  - next `role_key`
- rule:
  - append only when membership row is updated successfully

### 6.10 `OrganizationMemberDisabled`
- before:
  - `active`
- after:
  - `disabled | removed`
- rule:
  - append only when disable or remove succeeds

### 6.11 `OrganizationCertificationSubmitted`
- before:
  - `not_submitted | rejected | expired`
- after:
  - `pending_review`
- rule:
  - append only when certification truth row is created or updated

### 6.12 `OrganizationCertificationApproved`
- before:
  - `pending_review`
- after:
  - `approved`

### 6.13 `OrganizationCertificationRejected`
- before:
  - `pending_review`
- after:
  - `rejected`

## 7. Actor Attribution Freeze
- `actor_id` must be:
  - current app actor user id for user-triggered actions
  - reviewer user id for admin review actions
- `actor_role` must be:
  - current effective organization-scoped role for app actions
  - current platform role for admin actions
- `actor_role` must not be empty on successful identity or certification
  decisions unless the actor is a public unauthenticated login attempt
- For `LoginFailed` before identity binding is completed:
  - `actor_id` may be null
  - `reason` must carry the failure scene

## 8. Reason-field Freeze
- `reason` is mandatory for:
  - `LoginFailed`
  - `OrganizationMemberDisabled`
  - `OrganizationCertificationRejected`
- `reason` is recommended but optional for:
  - `OtpSent`
  - `OrganizationJoinRequested`
  - `OrganizationSwitched`

## 9. Request and Trace Freeze
- Every identity audit row must carry:
  - `request_id`
  - `trace_id`
- login, refresh, logout, organization, and certification chains must preserve
  those ids end to end
- missing `request_id` or `trace_id` on identity success actions is a release
  blocker

## 10. Failed-attempt Boundary
- The following failed attempts must append audit:
  - `LoginFailed`
- The following failed attempts must not append a success-shaped audit row:
  - OTP send blocked by rate limit
  - refresh rejected
  - logout rejected
  - organization create rejected
  - join-by-code rejected
  - certification submit rejected
  - certification approve rejected
  - certification reject rejected
- These non-success failures may still open `security_events` or normal
  application logs, but must not fake a successful audit transition.

## 11. Security-event Relation Freeze
- `audit_logs` remains the carrier for successful high-risk identity actions and
  the single explicitly required failed action `LoginFailed`
- `security_events` remains the carrier for:
  - OTP abuse
  - high-frequency registration
  - abnormal multi-organization join attempts
  - suspicious device behavior
- one request may produce:
  - one audit row
  - zero or more security events
- `security_events` must not replace required audit rows

## 12. Release-blocking Rules
- Identity round is blocked from release if any of the following is true:
  - successful login has no `LoginSucceeded` audit
  - successful refresh has no `SessionRefreshed` audit
  - successful organization create has no `OrganizationCreated` audit
  - successful certification submit has no `OrganizationCertificationSubmitted`
    audit
  - successful certification review decision has no approve or reject audit
  - identity audit row misses `request_id` or `trace_id`
  - implementation appends duplicate success audits for one idempotent action

## 13. Dispatch Conclusion
- This file is the exact `audit_log_spec` increment for the minimum identity
  round.
- Backend Agent may use it to update:
  - `docs/02_backend/audit_log_spec.md`
  - server audit application services
  - migration and test planning
- Code still must not start until:
  - `db_schema` increment freeze
  - L2 route contract freeze
  - identity persistence freeze
  are all aligned.
