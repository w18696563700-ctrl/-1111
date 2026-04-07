---
title: Block P0 Implementation Unlock Judgment
status: frozen
owner: Codex Control
scope: docs-only-implementation-unlock-judgment
created_at: 2026-04-07
---

# Block P0 Implementation Unlock Judgment

## A. Judgment Object

This document is the Control judgment for:

`Block P0 implementation unlock`

It is docs-only. It does not implement code and does not directly dispatch Backend, BFF, Frontend, Admin, Result Verification, or Release Integration work.

## B. Judgment Question

Can `Block P0` proceed to bounded implementation execution-prompt authoring?

This question is not:

- whether `Block P0` is already implemented
- whether `Admin Review P0` may start
- whether private-message governance may start
- whether penalty / appeal may start
- whether AI / OCR / QR / precheck may start
- whether release-prep or launch approval may start

## C. Current Accepted Baseline

The following documents and results are accepted and not re-judged:

- `content_safety_governance_master_v1_control_package_positioning_addendum.md`
- `content_safety_governance_master_v1_usage_rules_addendum.md`
- `content_safety_capability_tracking_table_v1.md`
- `content_safety_p0_docs_only_bundle_freeze_addendum.md`
- `content_safety_p0_implementation_order_lock_addendum.md`
- `content_safety_p0_runtime_dependency_judgment_addendum.md`
- `content_safety_subpackage_dispatch_preconditions_addendum.md`
- `block_p0_freeze_addendum.md`
- `forum_report_p0_completion_filing_addendum.md`
- `content_safety_current_blocker_maintenance_after_forum_report_p0_completion_addendum.md`
- `block_p0_implementation_unlock_stage_gate_checklist_addendum.md`
- `profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md`
- `forum_report_p0_final_result_verification_rerun_addendum.md`

The current implementation order remains:

1. `Profile Safety P0 + Safety Audit P0`
2. `Forum Report P0`
3. `Block P0`
4. `Admin Review P0`
5. linked review

The first two packages have passed at their current P0 boundaries.

## D. Capability Mapping

This judgment covers only:

| Capability | Frozen meaning | Judgment result |
| --- | --- | --- |
| `CS-018` | user block relation | eligible for bounded execution-prompt authoring |
| `CS-019` | interaction blocking boundary after block | eligible for bounded execution-prompt authoring |

The following remain registered but outside this implementation unlock:

- `CS-020` private-message single report, P1
- `CS-021` private-message hard-rule interception, P2
- `CS-022` message-list preview governance, P2
- `CS-027` penalty action system, P1
- `CS-028` appeal ticket system, P1

## E. Allowed Next Authoring Scope

The next authoring step may prepare bounded execution prompts for the minimum Block P0 chain only.

### Server

Allowed:

- Server-owned user-to-user block relation truth
- minimum block / unblock command semantics
- minimum query needed for app-facing block status
- validation for self-block, duplicate block, nonexistent target user, and idempotent unblock behavior
- minimum audit / snapshot integration if required by existing Safety Audit P0 carriers
- interaction-blocking checks for the specific already-existing app-facing interaction points selected by the execution prompt

Not allowed:

- full user suspension system
- permanent-ban system
- penalty state machine
- appeal ticket system
- private-message governance rewrite
- group-chat governance
- complete message conversation state machine

### BFF

Allowed:

- app-facing block / unblock command shaping
- app-facing block status shaping
- controlled error mapping for unauthorized, invalid target, self-block, blocked interaction, and upstream unavailable

Not allowed:

- owning block relation truth
- maintaining a second block state machine
- Admin governance routes
- penalty or appeal behavior

### Flutter

Allowed:

- minimum block / unblock entry points where already supported by frozen interaction surfaces
- minimum blocked-user feedback and disabled-action feedback
- consumption of BFF-shaped block state

Not allowed:

- full block-management center unless separately frozen
- private-message moderation console
- report history center
- Admin review surface
- penalty / appeal UI

### Admin

No Admin implementation is unlocked by this judgment.

`Admin Review P0` remains a later locked package.

## F. Required Truth / Contract Ordering For Next Execution Prompts

The next bounded execution-prompt bundle must preserve the formal truth order:

1. update or confirm `docs/01_contracts/**` surfaces required for Block P0
2. update or confirm `docs/02_backend/**` Server truth and persistence specs
3. update or confirm `docs/03_bff/**` BFF shaping specs
4. update or confirm `docs/04_frontend/**` Flutter consumption specs
5. only then implement bounded code in the allowed execution threads

If a required contract or layer spec is missing, the execution prompt must stop at that missing docs/spec layer and must not jump directly into `apps/**`.

## G. Explicit Out Of Scope

This judgment does not open:

- `Admin Review P0`
- any P1 / P2 package
- AI runtime
- OCR / QR detection
- forum precheck
- automatic hiding or takedown
- penalty / appeal
- private-message single reporting
- private-message hard-rule interception
- message-list preview governance
- stranger-message risk control
- group-chat governance
- full user suspension or permanent-ban system
- release-prep
- launch approval

## H. Gate Result

### Passed Gates

- `Block P0` freeze exists.
- `CS-018` and `CS-019` are registered in `content_safety_capability_tracking_table_v1.md`.
- `CS-018` and `CS-019` are not marked completed.
- `CS-020`, `CS-021`, `CS-022`, `CS-027`, and `CS-028` remain deferred.
- `Profile Safety P0 + Safety Audit P0` has passed final implementation result verification.
- `Forum Report P0` completion filing exists and records current-boundary completion.
- `source_of_truth_map.md` registers the Forum Report P0 completion filing, current blocker maintenance filing, and Block P0 stage gate.
- P0 runtime remains `rule` / `manual`; AI remains P1 reserved carrier.

### Failed / Reality Gap Gates

- `Block P0` has not been implemented yet.
- Backend execution prompt has not been authored yet.
- BFF execution prompt has not been authored yet.
- Frontend execution prompt has not been authored yet.
- Result Verification prompt has not been authored yet.

These are expected implementation targets and do not block execution-prompt authoring.

### Veto Gates

The next stage is vetoed if it:

- treats this judgment as implementation completion
- opens `Admin Review P0`
- opens P1 / P2 capabilities
- introduces AI runtime
- introduces OCR / QR detection
- introduces forum precheck
- introduces penalty / appeal
- turns Block P0 into a suspension / permanent-ban system
- implements full private-message governance
- makes BFF or Flutter own block truth
- skips required contracts / backend / BFF / frontend spec updates before code
- enters release-prep or launch approval

## I. Stage Decision

`Go for Block P0 bounded implementation execution-prompt authoring.`

This means:

- Control may author the next bounded execution-prompt bundle for `Block P0`
- the bundle must remain limited to `CS-018` and `CS-019`
- code implementation is still not considered started by this document

This does not mean:

- `Block P0` is complete
- `Admin Review P0` is open
- P1 / P2 is open
- AI / OCR / QR / precheck / penalty / appeal is open
- release-prep or launch approval is open

## J. Tracking Table Update

After this judgment is filed, `content_safety_capability_tracking_table_v1.md` may mark:

- `CS-018` as `待实施`
- `CS-019` as `待实施`

This means only that bounded execution-prompt authoring is allowed. It does not mean implementation has started or completed.

## K. Next Unique Action

Author:

`Block P0 bounded implementation execution prompt`

The prompt must preserve this judgment boundary and must not include `Admin Review P0`, P1/P2, AI runtime, OCR / QR detection, forum precheck, private-message complex governance, penalty / appeal, release-prep, or launch approval.
