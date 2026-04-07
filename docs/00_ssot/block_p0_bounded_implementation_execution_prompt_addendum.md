---
title: Block P0 Bounded Implementation Execution Prompt
status: frozen
owner: Codex Control
scope: docs-only-execution-prompt
created_at: 2026-04-07
---

# Block P0 Bounded Implementation Execution Prompt

## A. Prompt Object

This document freezes the bounded execution-prompt bundle for:

`Block P0`

It may be used to dispatch the next work packets only in the sequence below.

This document does not mean `Block P0` is implemented, result-verified, release-ready, or launch-ready.

## B. Current Dispatch Basis

Accepted basis:

- `block_p0_freeze_addendum.md`
- `block_p0_implementation_unlock_stage_gate_checklist_addendum.md`
- `block_p0_implementation_unlock_judgment_addendum.md`
- `content_safety_capability_tracking_table_v1.md`
- `content_safety_p0_implementation_order_lock_addendum.md`
- `content_safety_p0_runtime_dependency_judgment_addendum.md`
- `forum_report_p0_completion_filing_addendum.md`
- `profile_safety_plus_safety_audit_p0_final_implementation_result_verification_rerun_addendum.md`
- `forum_report_p0_final_result_verification_rerun_addendum.md`

Current allowed capabilities:

- `CS-018` user block relation
- `CS-019` interaction blocking boundary after block

Current global status remains:

`package-level controlled progression`

## C. Current Spec Gap

The current repository does not yet contain Block P0 layer-specific documents under:

- `docs/01_contracts/**`
- `docs/02_backend/**`
- `docs/03_bff/**`
- `docs/04_frontend/**`

Therefore direct app implementation must not start before Packet 0 is completed.

## D. Execution Order

The execution order is fixed:

1. Packet 0: Document Freeze creates or confirms Block P0 layer specs.
2. Packet 1: Backend Agent implements Server truth in cloud only, if Packet 0 passes.
3. Packet 2: BFF Agent implements app-facing shaping in cloud only, if Backend truth is available.
4. Packet 3: Frontend Agent implements local Flutter consumption, if BFF surface is available.
5. Packet 4: Result Verification independently verifies implementation and runtime evidence.

Packets must not be reordered.

## E. Packet 0 - Document Freeze Prompt

Send to:

`总控文书冻结`

Allowed action:

Create or update only the Block P0 layer-spec documents needed before implementation.

Allowed write scope:

- `docs/01_contracts/**`
- `docs/02_backend/**`
- `docs/03_bff/**`
- `docs/04_frontend/**`
- `docs/00_ssot/source_of_truth_map.md`
- `docs/00_ssot/content_safety_capability_tracking_table_v1.md` only if a status/reference correction is required

Required outputs:

- `docs/01_contracts/block_p0_contracts_addendum.md`
- `docs/02_backend/block_p0_backend_truth_addendum.md`
- `docs/03_bff/block_p0_bff_surface_addendum.md`
- `docs/04_frontend/block_p0_frontend_surface_addendum.md`
- source-map registration for those files

Required content:

- `CS-018` / `CS-019` capability mapping
- minimum user-to-user block relation contract
- minimum block / unblock semantics
- minimum block status query semantics
- interaction-blocking boundary for existing app-facing interaction surfaces only
- Server as block truth owner
- BFF as forwarding / shaping only
- Flutter as consumption layer only
- no Admin Review P0
- no private-message complex governance
- no penalty / appeal
- no AI / OCR / QR / precheck

Stop conditions:

- If any proposed spec requires `Admin Review P0`, stop.
- If any proposed spec requires P1 / P2 message governance, stop.
- If any proposed spec requires BFF-owned block truth, stop.
- If any proposed spec requires app implementation before docs/spec freeze, stop.

Packet 0 must not edit:

- `apps/**`
- `packages/**`

## F. Packet 1 - Backend Agent Prompt

Send to:

`后端 Agent（仅云端）`

Precondition:

Packet 0 must be complete and source-map registered.

Allowed action:

Implement Server-owned `Block P0` truth in the cloud only.

Allowed implementation scope:

- `apps/server/**` only where required for existing user identity, minimum block relation, app-facing interaction checks, persistence, validation, and tests

Required behavior:

- Server owns the block relation truth.
- A user may block another user.
- A user may unblock a previously blocked user.
- Self-block must be rejected with a controlled error.
- Nonexistent target user must be rejected with a controlled error.
- Duplicate block must be idempotent or controlled without creating duplicate truth.
- Unblock for an absent relation must be idempotent or controlled according to the frozen contract.
- Existing app-facing interaction points selected by the frozen spec must fail closed when the block relation forbids the interaction.
- Audit/snapshot integration must use existing P0 Safety Audit carriers only if required by the frozen backend truth document.

Forbidden:

- do not implement BFF code
- do not implement Flutter code
- do not implement Admin Review P0
- do not implement private-message reporting
- do not implement message hard-rule interception
- do not implement message-list preview governance
- do not implement penalty / appeal
- do not implement user suspension or permanent ban
- do not introduce AI / OCR / QR / precheck
- do not make BFF or Flutter own truth

Required receipt:

- changed files
- migration / persistence summary if any
- build/test commands run
- runtime/cloud evidence if available
- explicit statement that `CS-020`, `CS-021`, `CS-022`, `CS-027`, and `CS-028` remain out of scope

## G. Packet 2 - BFF Agent Prompt

Send to:

`BFF Agent（仅云端）`

Precondition:

Packet 1 must provide Server truth or an exact blocker. If Server truth is missing, stop.

Allowed action:

Implement app-facing BFF shaping for Block P0 in the cloud only.

Allowed implementation scope:

- `apps/bff/**` only where required for Block P0 app-facing route shaping, error normalization, and tests

Required behavior:

- BFF forwards block / unblock / block-status requests to Server.
- BFF maps controlled Server errors into app-facing errors.
- BFF does not own block relation truth.
- BFF does not maintain a second block state machine.
- BFF preserves auth/session context.

Forbidden:

- do not implement Server truth
- do not implement Flutter UI
- do not create Admin governance routes
- do not implement Admin Review P0
- do not implement private-message complex governance
- do not implement penalty / appeal
- do not introduce AI / OCR / QR / precheck

Required receipt:

- changed files
- build/test commands run
- active cloud artifact or route evidence if available
- explicit statement that BFF owns no block truth

## H. Packet 3 - Frontend Agent Prompt

Send to:

`前端 Agent（仅本地）`

Precondition:

Packet 2 must provide BFF app-facing surface or an exact blocker. If BFF surface is missing, stop.

Allowed action:

Implement minimum Flutter consumption for Block P0 locally.

Allowed implementation scope:

- `apps/mobile/**` only where required for existing frozen app-facing surfaces and Block P0 consumption

Required behavior:

- provide minimum block / unblock entry where the frozen frontend surface allows it
- consume BFF-shaped block status
- show minimum blocked-interaction feedback
- fail closed on controlled BFF errors
- preserve existing forum/profile/messages routing boundaries

Forbidden:

- do not call Server directly
- do not implement BFF or Server code locally
- do not create a full block-management center unless separately frozen
- do not implement Admin Review P0
- do not implement report history
- do not implement private-message moderation
- do not implement penalty / appeal UI
- do not introduce AI / OCR / QR / precheck

Required receipt:

- changed files
- analyze/test commands run
- bounded UX evidence
- explicit statement that no unblocked P1 / P2 capability entered the package

## I. Packet 4 - Result Verification Prompt

Send to:

`结果校验 Agent`

Precondition:

Packets 0 through 3 must provide receipts or exact blockers.

Required verification:

- no duplicate implementation
- no role-boundary breach
- no scope drift beyond `CS-018` and `CS-019`
- no BFF-owned block truth
- no Flutter-owned block truth
- no Admin Review P0 implementation
- no P1 / P2 implementation
- no AI / OCR / QR / precheck
- no private-message complex governance
- no penalty / appeal
- line-length and one-responsibility gates
- accepted topology for runtime evidence
- anti-omission check against `CS-001` through `CS-034`

Allowed conclusions:

- PASS
- CONDITIONAL PASS
- NO-GO

Result Verification must not implement code.

## J. Current Non-Goals

This execution prompt does not open:

- `Admin Review P0`
- P1 / P2 packages
- AI runtime
- OCR / QR detection
- forum precheck
- automatic hiding / takedown
- private-message report flow
- private-message hard-rule interception
- message-list preview governance
- stranger-message risk control
- group-chat governance
- penalty / appeal
- user suspension / permanent ban
- release-prep
- launch approval

## K. Current Tracking Meaning

`CS-018` and `CS-019` may remain `待实施` until the bounded implementation execution actually starts and receipts are returned.

They must not be marked `已完成` until independent result verification passes and Control files final completion.

## L. Next Unique Action

Send Packet 0 to `总控文书冻结`.

Packet 0 must freeze the Block P0 contract, backend truth, BFF surface, and frontend consumption specs before any `apps/**` implementation packet is sent.
