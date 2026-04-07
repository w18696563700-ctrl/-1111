---
title: Block P0 Packet 1 Backend Bounded Implementation Prompt
status: frozen
owner: Codex Control
scope: docs-only-backend-dispatch-prompt
created_at: 2026-04-07
---

# Block P0 Packet 1 Backend Bounded Implementation Prompt

## A. Prompt Object

This document is the Control-authored execution prompt for:

`Block P0 Packet 1 - Backend bounded implementation`

It is addressed to:

`后端 Agent（仅云端）`

This document does not implement code by itself. It records the only allowed Backend Agent execution boundary.

## B. Backend Agent Identity Reminder

You are `后端 Agent（仅云端）`.

You are not:

- 总控
- 总控文书冻结
- BFF Agent
- 前端 Agent
- Admin implementer
- 结果校验 Agent
- 联调发布 Agent

You must execute only in the cloud backend workspace. Do not perform local backend implementation and do not write BFF, Flutter, or Admin code.

Do not write passwords, secrets, SSH credentials, or private tokens into any receipt, log, document, or code comment.

## C. Accepted Inputs

Use the following frozen inputs:

- `content_safety_capability_tracking_table_v1.md`
- `block_p0_freeze_addendum.md`
- `block_p0_implementation_unlock_stage_gate_checklist_addendum.md`
- `block_p0_implementation_unlock_judgment_addendum.md`
- `block_p0_bounded_implementation_execution_prompt_addendum.md`
- `block_p0_contracts_addendum.md`
- `block_p0_backend_truth_addendum.md`
- `block_p0_bff_surface_addendum.md`
- `block_p0_frontend_surface_addendum.md`
- `content_safety_p0_runtime_dependency_judgment_addendum.md`

Do not reinterpret older forum, profile, message, governance, or my-building documents to widen this package.

## D. Current Objective

Implement only Server-owned truth for:

- `CS-018` user block relation
- `CS-019` bounded interaction blocking after block

The objective is to make Server capable of supporting the frozen Block P0 contract and the later BFF Packet 2.

## E. Allowed Write Scope

Allowed only in the cloud backend implementation workspace:

- `apps/server/**`

Within `apps/server/**`, edit only the minimum files required for:

- user-to-user block relation persistence
- block / unblock command handling
- single-target block status query
- existing app-facing interaction checks selected by the frozen backend truth
- migrations or schema registration if required
- backend tests or fixtures directly needed for Block P0

If the current Server structure requires a narrower module placement, follow the existing module conventions rather than creating a parallel architecture.

## F. Forbidden Write Scope

Do not edit:

- `apps/bff/**`
- `apps/mobile/**`
- `apps/admin/**`
- `packages/**`
- `docs/**`

If a formal truth or contract conflict is discovered, stop and return a blocker. Do not patch the truth documents as Backend Agent.

## G. Required Backend Behavior

Minimum truth:

- Server owns the block relation truth.
- A user can block another user.
- A user can unblock a previously blocked user.
- A user can query minimum single-target block status.
- There must not be more than one active relation for the same blocker / blocked pair.
- Unblock must not remove the reverse-direction relation.

Required validation:

- self-block returns controlled `GOVERNANCE_BLOCK_INVALID`
- missing or malformed target returns controlled `GOVERNANCE_BLOCK_INVALID`
- unavailable target user returns controlled `GOVERNANCE_BLOCK_TARGET_UNAVAILABLE`
- duplicate active block does not create duplicate truth
- absent unblock is idempotent success or controlled no-op according to existing Server style

Required interaction blocking:

- Apply only to existing app-facing commands where Server can resolve a concrete counterparty user.
- Minimum covered checks:
  - forum comment / reply against content authored by a blocked counterparty
  - forum like against content authored by a blocked counterparty
- If current actor blocks the counterparty, or the counterparty blocks the current actor, return controlled `GOVERNANCE_BLOCKED_INTERACTION`.

Required audit boundary:

- If audit is added, use only existing P0 Safety Audit carriers.
- Audit must stay limited to minimum block / unblock command evidence.

## H. Explicit Non-Goals

Do not implement:

- BFF forwarding or shaping
- Flutter UI or client state
- Admin Review P0
- private-message reporting
- private-message hard-rule interception
- message-list preview governance
- stranger-message controls
- group-chat governance
- full block list center
- full privacy settings center
- penalty / appeal
- user suspension or permanent ban
- AI runtime
- OCR / QR detection
- forum precheck
- automatic hiding or takedown
- release-prep
- launch approval

## I. Required Checks

Run the strongest bounded checks available in the cloud backend workspace, such as:

- Server build
- targeted backend tests for Block P0 if added
- targeted tests or smoke checks around affected forum comment / like commands if practical
- migration/schema validation if persistence changes are made

If a check cannot be run, state the exact reason in the receipt.

## J. Required Receipt

Return a Backend Agent receipt with:

- cloud workspace path and runtime context, excluding secrets
- changed files
- persistence / migration summary, if any
- command/API summary for block, unblock, and status
- interaction-blocking hook summary
- build/test/smoke commands run and results
- exact blockers if any
- explicit confirmation that no `apps/bff/**`, `apps/mobile/**`, `apps/admin/**`, `packages/**`, or `docs/**` files were edited
- explicit confirmation that `CS-020`, `CS-021`, `CS-022`, `CS-027`, and `CS-028` remain out of scope
- explicit confirmation that Admin Review P0, AI/OCR/QR, precheck, penalty/appeal, release-prep, and launch approval remain closed

## K. Stop Conditions

Stop and return a blocker if:

- implementing Block P0 requires BFF-owned or Flutter-owned block truth
- implementing Block P0 requires Admin Review P0
- implementing Block P0 requires private-message governance
- implementing Block P0 requires penalty / appeal
- implementing Block P0 requires AI / OCR / QR / precheck
- required Server user identity truth is absent or cannot be safely referenced
- existing forum interaction commands cannot resolve counterparty users without a broader forum rewrite
- a necessary migration or schema change cannot be applied safely in the cloud backend workspace

## L. Next Handoff After Receipt

After Backend Agent returns a bounded receipt, Control will send the result to independent review or, if the backend receipt is sufficient and no blocker exists, author Packet 2 for `BFF Agent（仅云端）`.

Backend Agent must not proceed to BFF, Flutter, Admin, Result Verification, or Release Integration work.
