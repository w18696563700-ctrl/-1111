---
owner: Codex 总控
status: draft
purpose: Freeze the dedicated backend truth, persistence, stop-loss restriction ownership, and audit/evidence linkage for fake-project report intake and adjudication under the current App truth system.
layer: L3 Backend
---

# 假项目举报与裁决规则 V1 Backend Truth Addendum

## 1. Scope
- This addendum applies only to the second dedicated `docs/02_backend` package for:
  - fake-project report intake truth
  - exhibition report-case persistence
  - temporary stop-loss restriction ownership
  - explanation and adjudication truth
  - report-to-review and escalation handoff
  - audit and evidence linkage
- This addendum does not by itself:
  - unlock `apps/server` implementation
  - unlock `apps/bff` aggregation specs
  - reopen dispute detail, resolution, appeal, or history families
  - approve blacklist, whitelist, penalty, or permanent-ban runtime
  - approve a public report center or a user-side report-history center

## 2. Alignment Basis
- This addendum is aligned against:
  - [AGENTS.md](/Users/wangweiwei/Desktop/展览装修之家总控/AGENTS.md)
  - [gate_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/gate_register_v1.md)
  - [fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/fake_project_report_and_adjudication_rules_v1_app_aligned_freeze_addendum.md)
  - [fake_project_report_and_adjudication_rules_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/fake_project_report_and_adjudication_rules_v1_contracts_addendum.md)
  - [review_ticket_risk_governance_baseline_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/review_ticket_risk_governance_baseline_addendum.md)
  - [dispute_entry_minimal_governance_action_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/dispute_entry_minimal_governance_action_addendum.md)
  - [backend_ssot.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/backend_ssot.md)
  - [service_boundaries.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/service_boundaries.md)
  - [db_schema.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/db_schema.md)
  - [audit_log_spec.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/audit_log_spec.md)

## 3. Addendum Role
- Current `L0` and `L2` documents have already frozen:
  - report and adjudication semantics
  - app-facing and admin path families
  - minimum transport status and result families
- This addendum upgrades that package into a dedicated backend-truth package for:
  - the case truth carrier
  - the stop-loss restriction carrier
  - the review-task linkage
  - the audit and evidence chain
- This addendum must not be read as:
  - approval for a second dispute truth
  - approval for a second review-ticket system
  - approval for the full downstream penalty and blacklist tree

## 4. Current Truth Ownership Freeze
- `Server` remains the only truth owner for:
  - exhibition project report intake truth
  - exhibition report-case lifecycle truth
  - stop-loss restriction truth
  - explanation-request truth
  - explanation-received truth
  - adjudication result truth
  - review and escalation handoff truth
  - audit attribution truth
- `BFF` may:
  - normalize actor and organization context
  - shape submit acknowledgements
  - shape blocked-state copy
  - return controlled unavailable and forbidden responses
- `BFF` must not:
  - own report-case state
  - own restriction truth
  - own adjudication truth
  - own escalation truth
- `Admin` consumes `Server` Admin APIs directly.
- `Admin` is not itself a truth owner.

## 5. Canonical Persistence Binding
- This dedicated package adopts the following current truth carriers:
  - existing business anchors:
    - `projects`
    - `bids`
    - `contracts`
    - `inspections`
    - `organizations`
  - existing governance carriers:
    - `review_tasks`
    - `audit_logs`
  - existing evidence carriers:
    - `file_assets`
    - `evidences`
  - one new dedicated case carrier:
    - `exhibition_report_cases`
- Current round does not approve new dedicated tables for:
  - `report_evidences`
  - `risk_freeze_actions`
  - `explanation_submissions`
  - `adjudication_records`
  - `refund_actions`
  - `case_notifications`
  - `case_audit_logs`
  - a second report-local `governance_tickets` table
- Product wording may still refer to:
  - report case
  - freeze action
  - explanation material
  - adjudication record
- But current relational truth must remain bound to:
  - `exhibition_report_cases`
  - existing `review_tasks`
  - existing `audit_logs`
  - existing `file_assets` / `evidences`

## 6. Exhibition Report-case Truth Freeze
- `exhibition_report_cases` becomes the only dedicated report-case persistence carrier for this package.
- Its semantic role is:
  - append-only report intake anchor
  - current processing-state carrier
  - current restriction-state carrier
  - current adjudication-result carrier
  - linkage anchor into review and escalation handling
- Minimum columns that must exist before implementation:
  - `id`
  - `target_type`
  - `target_id`
  - `reason_code`
  - `reason_detail`
  - `reporter_user_id`
  - `reporter_organization_id`
  - `status`
  - `temporary_restriction_state`
  - `review_task_id`
  - `governance_ticket_ref`
  - `explanation_requested_at`
  - `explanation_due_at`
  - `explanation_received_at`
  - `adjudication_result`
  - `decision_note`
  - `decided_at`
  - `closed_at`
  - `created_at`
  - `updated_at`
- Minimum target-type allow-list stays aligned to the frozen contract:
  - `project`
  - `project_profile`
  - `bid`
  - `contract`
  - `inspection`
- Minimum reason-code allow-list stays aligned to the frozen contract:
  - `fabricated_project`
  - `unauthorized_project_material`
  - `false_budget_or_schedule`
  - `fake_organization_or_contact`
  - `fraudulent_collection_attempt`
  - `other`

## 7. Report-case State Responsibility Freeze
- `exhibition_report_cases.status` is the only current report-case lifecycle field.
- Minimum state set remains:
  - `submitted`
  - `under_review`
  - `explanation_requested`
  - `escalated`
  - `decided`
  - `closed`
- `adjudication_result` remains a separate terminal-decision field and must not replace `status`.
- `temporary_restriction_state` remains a separate stop-loss field and must not replace `status`.
- Current hard rules:
  - `status` tells where the case is in handling
  - `temporary_restriction_state` tells whether stop-loss restriction is currently effective
  - `adjudication_result` tells what the decision concluded
  - none of the three may impersonate the others

## 8. Duplicate-active-case Rule
- Fake-project report intake must not fan out into unlimited equivalent active cases.
- The current minimum duplicate rule is:
  - equivalent active reports from the same reporter against the same target and same reason must resolve to one active current case
- Current backend implication:
  - `exhibition_report_cases` must support an idempotent active-case uniqueness rule
  - duplicate-equivalent active submit may re-ack the existing case instead of materializing a new one
- Current round does not approve:
  - unbounded repeated active rows for the same actor-target-reason triple

## 9. Review-task And Escalation Binding Freeze
- `review_tasks` remains the only currently approved cross-cutting review carrier reused by this package.
- Current case-handling meaning is:
  - an accepted report case may open or link one active `ReviewTask`
  - ordinary handling stays inside the ordinary review boundary
  - escalation follows the already-frozen review-to-ticket discipline
- `exhibition_report_cases.review_task_id` therefore binds the case to the current ordinary review carrier.
- `exhibition_report_cases.governance_ticket_ref` is reserved as the cross-cutting escalation reference for later governance-ticket materialization.
- This package explicitly forbids:
  - a second exhibition-only ticket store
  - a second review-case system outside `review_tasks`
  - keeping ordinary review and escalated ticket truth in parallel report-local tables

## 10. Temporary Restriction Truth Freeze
- Temporary stop-loss restriction remains a `Server`-owned overlay consumed by project- and transaction-side reads.
- Current minimum restriction family remains:
  - `not_applied`
  - `active`
  - `lifted`
- Current truth carrier is:
  - `exhibition_report_cases.temporary_restriction_state`
- Current minimum semantics are:
  - `not_applied`
    - no stop-loss restriction has been applied for the current case
  - `active`
    - the current case has produced a live stop-loss restriction and related reads must consume that restriction
  - `lifted`
    - a previously active stop-loss restriction has been formally lifted
- Current hard rules:
  - stop-loss restriction is not final conviction
  - stop-loss restriction must be auditable
  - stop-loss restriction must be reversible
  - stop-loss restriction must not be stored as a `BFF`-local state

## 11. Target-object Restriction Consumption Freeze
- The current package does not mutate `projects`, `bids`, `contracts`, or `inspections` into a second governance-state machine.
- Instead, target-object restricted reads must derive from:
  - current object truth
  - active `exhibition_report_cases` restriction overlay
  - current review-task or escalation truth where applicable
- Current hard rule:
  - a fake-project report must not directly overwrite the canonical lifecycle state of the target object
- This package therefore does not approve:
  - `projects.status = restricted`
  - `bids.status = restricted`
  - `contracts.status = restricted`
  - `inspections.status = restricted`
  as a substitute for report restriction truth

## 12. Explanation And Decision Truth Freeze
- Explanation handling remains part of the report-case truth package.
- Current minimum explanation carriers are:
  - `explanation_requested_at`
  - `explanation_due_at`
  - `explanation_received_at`
- Current minimum adjudication carriers are:
  - `adjudication_result`
  - `decision_note`
  - `decided_at`
  - `closed_at`
- Current minimum adjudication-result family remains:
  - `not_established`
  - `partially_established`
  - `materially_established`
- Current round explicitly does not approve:
  - a separate `explanation_submissions` truth family
  - a separate `adjudication_records` truth family
  - mutable Admin-only side notes as a substitute for decision truth

## 13. Evidence And File Linkage Freeze
- `file_assets` and `evidences` remain the only current evidence carriers.
- `objectKey` and raw URL must never become fake-project evidence truth.
- The current minimum rule is:
  - app-facing evidence refs submitted with the report must resolve to current `FileAsset` truth
  - the report case must keep reconstructible linkage to those file refs through the existing evidence chain
- Current round does not approve:
  - a second report-local evidence table
  - a raw JSON URL blob as final evidence truth
  - Admin memory or comment-only evidence

## 14. Reporter And Scope Freeze
- Reporter legitimacy must remain derived from current identity and organization truth.
- `exhibition_report_cases.reporter_user_id` and `reporter_organization_id` are therefore the only current reporter truth carriers for this package.
- Current hard rules:
  - reporter user ref must stay stable after submit
  - reporter organization ref may be nullable only when the target does not require organization scope
  - transaction-side object reports must preserve the organization scope used at submit time
- This package does not approve:
  - anonymous public report truth as default V1 path
  - a second reporter identity family outside current session and organization scope

## 15. Audit Increment Freeze
- This dedicated package freezes the following must-audit actions:
  - `ExhibitionReportSubmitted`
  - `ExhibitionReportRestrictionApplied`
  - `ExhibitionReportExplanationRequested`
  - `ExhibitionReportExplanationReceived`
  - `ExhibitionReportDecided`
  - `ExhibitionReportEscalated`
  - `ExhibitionReportRestrictionLifted`
  - `ExhibitionReportClosed`
- Current semantics are:
  - report submit appends only on successful materialization or accepted idempotent reuse
  - stop-loss restriction append must happen only when restriction becomes active
  - explanation-request append must happen only when the request is formally issued
  - adjudication append must happen only on a valid decision transition
  - close append must happen only when the case enters terminal closure
- Invalid attempts must not be written as successful restriction or decision audit rows.

## 16. Cross-object Boundary Freeze
- This package may anchor to:
  - `Project`
  - `Bid`
  - `Contract`
  - `Inspection`
  - `Organization`
- But it does not reopen or redefine:
  - project publish lifecycle
  - bid lifecycle
  - contract lifecycle
  - inspection lifecycle
  - dispute lifecycle
- Current meaning:
  - report governance overlays those objects
  - report governance does not replace those object truths

## 17. Explicit Non-goals
- No second dispute truth
- No second review-ticket system
- No full governance-ticket persistence package in this document
- No user-side report history truth
- No appeal truth
- No penalty, blacklist, whitelist, or permanent-ban truth
- No implementation unlock

## 18. Formal Conclusion
- Current formal conclusion:
  - `假项目举报与裁决规则 V1` now has a dedicated backend-truth package under `docs/02_backend`
  - `exhibition_report_cases` becomes the only dedicated fake-project report-case truth carrier in this package
  - stop-loss restriction remains a `Server`-owned overlay recorded on the report case and consumed by target-object reads
  - `review_tasks`, `audit_logs`, `file_assets`, and `evidences` remain the only approved reused governance and evidence carriers for this package
  - no second dispute, ticket, evidence, or adjudication table family is approved here
- Current stage meaning:
  - backend truth and persistence freeze only
  - no implementation unlock by this document alone
