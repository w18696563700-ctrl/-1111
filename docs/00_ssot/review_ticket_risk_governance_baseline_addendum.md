---
owner: Codex 总控
status: draft
purpose: Freeze the minimum L0 semantics for ReviewTask workflow, risk-governance escalation, ticket closure, and audit attribution.
layer: L0 SSOT
---

# Review Ticket Risk Governance Baseline Addendum

## Scope
- This file freezes the formal `L0 SSOT` baseline for `ReviewTask`, risk-governance
  classification, governance-ticket lifecycle, and their audit handoff rules.
- It applies only to the controlled governance path already owned by `Server`.
- It does not define implementation, Admin page prototype, `Server` API shape,
  database schema, or cloud execution steps.
- It does not add any app-facing path, new role family, second audit system, or
  second ticket truth.

## Canonical ReviewTask Workflow
- `ReviewTask` is a `Server`-materialized governance task for a controlled review
  subject that already exists in business truth.
- Controlled input:
  - review-subject snapshot ref already materialized by `Server`
  - actor and organization scope refs already allowed by existing permission truth
  - attached `FileAsset` / `Evidence` refs
  - current risk tags or governance reason refs
  - prior review or ticket refs when they already exist
- Minimum state set:
  - `pending_review`
  - `needs_supplement`
  - `approved`
  - `rejected`
  - `escalated`
  - `archived`
- Allowed actions:
  - request supplement on an open `ReviewTask`
  - approve an open `ReviewTask`
  - reject an open `ReviewTask`
  - escalate an open `ReviewTask` into the controlled ticketing path
- Allowed transition boundary:
  - `pending_review -> needs_supplement`
  - `pending_review -> approved`
  - `pending_review -> rejected`
  - `pending_review -> escalated`
  - `needs_supplement -> pending_review`
  - `needs_supplement -> rejected`
  - `needs_supplement -> escalated`
  - `approved -> archived`
  - `rejected -> archived`
  - `escalated -> archived`
- Forbidden actions:
  - direct mutation of business truth outside the controlled `Server` review
    decision boundary
  - reopening an archived `ReviewTask` without a newly materialized `Server` task
  - bypassing ticket handoff when escalation is already required
  - minting a second role or approval system inside review handling
- Closure condition:
  - a `ReviewTask` reaches closure only when it has a terminal review outcome
    (`approved` or `rejected`) plus audit attribution, or when an escalation handoff
    has produced a linked governance ticket and the task is archived as escalated

## Canonical Risk Decision Categories
- Risk classification is a controlled governance decision attached to an existing
  `ReviewTask` or governance ticket; it is not a second business-truth object.
- Controlled input:
  - the current review subject snapshot ref
  - evidence refs and file refs already owned by `Server`
  - actor, reason, and prior governance history refs
  - existing dispute, appeal, or review anchors when already materialized by
    `Server`
- Minimum category set:
  - `clear`
  - `supplement_required`
  - `restricted`
  - `ticket_required`
- Minimum semantic rule:
  - `clear`: the review subject may stay inside the ordinary review boundary
  - `supplement_required`: the review subject is incomplete or inconsistent and
    must stay in review until supplement arrives
  - `restricted`: the review subject cannot pass inside the current review cycle
    and requires an explicit controlled deny or hold outcome
  - `ticket_required`: the issue exceeds single-task review and must hand off to
    the governance ticket path
- Allowed actions:
  - classify or reclassify risk before the review or ticket reaches terminal
    closure
  - upgrade a case from a lower category to `ticket_required` when controlled
    escalation signals appear
- Risk escalation boundary:
  - cross-object conflict that cannot be decided by a single review task
  - repeated or high-severity suspicious pattern requiring governance handling
  - evidence contradiction that requires ticket-based adjudication
  - dispute, appeal, or platform-side governance handling that exceeds ordinary
    approve/reject review scope
- Forbidden actions:
  - using a risk category to bypass permission truth
  - using a risk category as a direct business-state mutation command
  - downgrading a ticketed case back to ordinary review without a recorded
    governance resolution path
- Closure condition:
  - a risk decision is closed only when it is consumed by a terminal review
    outcome or by a resolved governance ticket chain with audit attribution

## Canonical Ticket Lifecycle
- A governance ticket is a `Server`-owned governance case object used for escalated
  review, dispute, appeal, or platform-handling work.
- Controlled input:
  - source `ReviewTask` ref, or an already-materialized dispute or appeal ref
  - linked `Order` / `Contract` / `Inspection` / `Rating` / `Project` anchors when
    they already exist
  - evidence refs, file refs, and risk-classification reason refs
  - current handling owner ref and routing history ref
- Minimum state set:
  - `opened`
  - `triaged`
  - `in_progress`
  - `resolved`
  - `closed`
  - `archived`
- Allowed actions:
  - classify an open ticket
  - route or assign an open ticket
  - append controlled follow-up notes
  - record a controlled handling outcome
  - close a handled ticket only when the underlying `Server` truth supports that
    closure
- Allowed transition boundary:
  - `opened -> triaged`
  - `triaged -> in_progress`
  - `in_progress -> resolved`
  - `resolved -> closed`
  - `closed -> archived`
- Forbidden actions:
  - direct rewrite of `Dispute`, `Rating`, `Order`, `Contract`, `Inspection`, or
    other business truth outside the controlled governance path
  - maintaining a second ticket store in `Admin`
  - closing a ticket without a recorded handling outcome and audit attribution
  - using ticketing to bypass `Server` truth ownership or permission truth
- Closure condition:
  - a governance ticket reaches closure only when the handling outcome is recorded,
    the linked `Server` truth or policy outcome is in a consistent state, and the
    ticket can be closed with audit attribution before archival

## Review-to-ticket Handoff Rule
- A `ReviewTask` may hand off into ticketing only when its active risk category is
  `ticket_required`, or when the review subject cannot be decided within the
  ordinary review boundary.
- The minimum handoff payload must already have:
  - source `ReviewTask` ref
  - review-subject anchor refs
  - linked evidence and file refs
  - current risk category and escalation reason
- Once the handoff is accepted by the controlled `Server` ticket path:
  - the source `ReviewTask` must no longer continue an ordinary approve/reject path
  - the source `ReviewTask` must close only as `escalated -> archived`
- Ordinary supplement-only or ordinary approve/reject cases must stay in review and
  must not be promoted to ticketing merely to bypass review closure discipline.

## Audit Attribution Rule
- `ReviewTask`, risk-governance, and ticket handling all remain under append-only
  audit discipline.
- Minimum audit requirement:
  - every terminal `ReviewTask` decision must have audit attribution
  - every review-to-ticket escalation must have audit attribution
  - every ticket routing, handling, and closure action must have audit attribution
- The minimum evidence chain for governance attribution must preserve:
  - `object_type`
  - `object_id`
  - `object_no`
  - `actor_id`
  - `actor_role`
  - `reason`
  - `request_id`
  - `trace_id`
- High-risk governance actions without audit attribution remain release blockers.

## Boundary with Admin / Permission / Audit / Backend Truth
- Boundary with `docs/05_admin/admin_governance_surface_matrix.md`:
  - `admin_governance_surface_matrix.md` freezes module surface, module object
    families, and module action boundary
  - this file freezes the upstream `L0` semantics for `ReviewTask`, risk decision,
    ticket lifecycle, handoff, and closure
- Boundary with `docs/05_admin/admin_ssot.md`:
  - `admin_ssot.md` freezes Admin truth location, directory allow-list, and
    non-truth boundaries
  - this file does not define any `apps/admin/**` implementation structure
- Boundary with `docs/00_ssot/permission_matrix.md`:
  - role grants, actor eligibility, and role names remain owned by the permission
    matrix
  - this file does not mint new reviewer, support, or operator roles
- Boundary with `docs/02_backend/audit_log_spec.md`:
  - required audit fields, append-only rules, and named must-audit actions remain
    owned by the audit-log spec
  - this file only freezes when governance handling must remain audit-attributed
- Boundary with `docs/02_backend/service_boundaries.md`:
  - `Server` remains the only business-truth owner
  - `Admin` continues to use controlled `Server` Admin APIs directly
  - this file does not let review or ticketing bypass domain-service boundaries

## Non-goals
- No implementation plan
- No Admin page prototype
- No `Server` API implementation
- No database schema or migration
- No new app-facing path
- No new `L2 Contracts`
- No second role system
- No second audit system
- No second ticket truth
- No implementation unlock by this file alone
