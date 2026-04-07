---
owner: Codex Control
status: frozen
purpose: Freeze the Server-owned Block P0 truth boundary for minimum user-to-user block relation and existing interaction fail-closed checks without opening messages governance, penalty, appeal, or Admin Review P0.
layer: L3 Backend
created_at: 2026-04-07
---

# Block P0 Backend Truth Addendum

## Scope

This addendum freezes Server truth for `Block P0`.

It covers only:

- `CS-018` user block relation
- `CS-019` interaction blocking boundary after block

It does not approve code implementation by itself.

## Server Ownership

`Server` is the only owner of block relation truth.

`BFF`, Flutter, and Admin must not own:

- block relation truth
- block status truth
- interaction blocking truth
- any second block state machine

## Minimum Truth Carrier

Server must materialize or reuse a minimum user-to-user block relation carrier with these semantics:

- `blockerUserId`
- `blockedUserId`
- active / inactive relation state or equivalent active-row semantics
- creation timestamp
- update or removal timestamp when applicable
- actor / trace attribution through the existing audit baseline when required

There must not be more than one active relation for the same `blockerUserId` and `blockedUserId`.

## Command Truth

Minimum block command:

- current actor becomes `blockerUserId`
- request target becomes `blockedUserId`
- self-block must be rejected
- nonexistent or unavailable target user must be rejected
- duplicate active block must not create duplicate active truth

Minimum unblock command:

- current actor must own the relation being removed
- absent relation may be treated as idempotent success or controlled no-op
- unblock must not remove the reverse direction relation

## Status Truth

Minimum single-target status query may project only:

- whether current actor blocks the target
- whether the current actor may interact with the target under the frozen P0 interaction boundary
- a generic blocked-interaction reason when interaction is not allowed

The status query must not become a block list center.

## Interaction Blocking Truth

P0 interaction blocking applies only to existing app-facing commands where Server can resolve a concrete counterparty user.

Minimum covered checks:

- forum comment / reply against content authored by a blocked counterparty
- forum like against content authored by a blocked counterparty

P0 explicitly excludes:

- private messages
- message-list preview governance
- group chat
- topic follow
- private bookmark-only behavior unless a later frozen spec proves it is a direct user-to-user interaction signal
- Admin moderation actions
- penalty / appeal actions

If current actor blocks the counterparty, or the counterparty blocks the current actor, the covered interaction must fail closed with `GOVERNANCE_BLOCKED_INTERACTION`.

## Error Truth

Server owns:

- `GOVERNANCE_BLOCK_INVALID`
- `GOVERNANCE_BLOCK_TARGET_UNAVAILABLE`
- `GOVERNANCE_BLOCKED_INTERACTION`

BFF may only shape these errors.

## Audit Boundary

If the existing P0 audit carrier is used, audit must stay limited to minimum block / unblock command evidence.

Audit must not introduce:

- penalty records
- appeal records
- permanent-ban records
- Admin review decisions
- AI review payloads

## Explicit Non-goals

- No messages governance
- No private-message reporting
- No private-message hard-rule interception
- No message-list preview governance
- No full privacy or block-management center
- No user suspension or permanent ban
- No penalty / appeal
- No Admin Review P0
- No AI / OCR / QR / precheck
- No release-prep or launch approval

## Formal Conclusion

Server truth is frozen as the only Block P0 truth owner.

Any implementation must keep `CS-018` and `CS-019` inside the minimum user-to-user block relation and bounded interaction fail-closed boundary.

## Next Unique Action

After this backend truth is frozen, freeze BFF surface and frontend consumption specs before any code implementation packet is sent.
