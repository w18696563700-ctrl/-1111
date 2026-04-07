---
owner: Codex Control
status: frozen
purpose: Freeze the minimum app-facing Block P0 contract for user-to-user block relation and bounded interaction blocking without opening messages governance, penalty, appeal, or Admin Review P0.
layer: L2 Contracts
created_at: 2026-04-07
---

# Block P0 Contracts Addendum

## Scope

This addendum applies only to `Block P0`.

It freezes the minimum contract for:

- `CS-018` user block relation
- `CS-019` interaction blocking boundary after block

It does not approve implementation completion, release-prep, launch approval, `Admin Review P0`, P1 / P2 capabilities, AI runtime, OCR / QR detection, forum precheck, penalty, appeal, or complex messages governance.

## App-facing Route Boundary

The minimum app-facing Block P0 route family is under the existing `profile` route group:

- `POST /api/app/profile/block`
- `POST /api/app/profile/unblock`
- `GET /api/app/profile/block/status`

No `message` route family is opened by Block P0.

No `Admin` route family is opened by Block P0.

## Minimum Request Contracts

`POST /api/app/profile/block`

- request body:
  - `targetUserId`: required string
- meaning:
  - the current actor blocks the target user

`POST /api/app/profile/unblock`

- request body:
  - `targetUserId`: required string
- meaning:
  - the current actor removes the active block relation against the target user

`GET /api/app/profile/block/status`

- query:
  - `targetUserId`: required string
- meaning:
  - returns the minimum current-actor block projection for a single target user

## Minimum Response Contracts

The minimum block command result may expose only:

- `targetUserId`
- `blockedByMe`
- `canInteract`
- `effectiveAt`

The minimum unblock command result may expose only:

- `targetUserId`
- `blockedByMe`
- `canInteract`
- `effectiveAt`

The minimum status result may expose only:

- `targetUserId`
- `blockedByMe`
- `canInteract`
- optional `interactionBlockedReason`

`interactionBlockedReason`, when present, must stay generic:

- `blocked_relation`

It must not disclose a full private relationship graph or a block list.

## Interaction Blocking Contract

Block P0 may affect only existing app-facing interaction commands where Server can resolve a concrete user-to-user interaction target.

The minimum P0 interaction-blocking boundary covers:

- commenting or replying on forum content authored by a blocked counterparty
- liking forum content authored by a blocked counterparty

The P0 boundary does not cover:

- private messages
- message-list previews
- group chats
- topic follow
- private bookmark-only behavior, unless a later frozen spec proves it produces a direct user-to-user interaction signal
- Admin moderation actions
- penalty or appeal actions

If either side of a resolved user-to-user interaction is blocked by the other, Server must fail closed with a controlled app-facing error.

## Error Boundary

The current Block P0 contract adds the following minimum error codes:

- `GOVERNANCE_BLOCK_INVALID`
- `GOVERNANCE_BLOCK_TARGET_UNAVAILABLE`
- `GOVERNANCE_BLOCKED_INTERACTION`

Meanings:

- `GOVERNANCE_BLOCK_INVALID`: block or unblock request is missing required fields, targets self, or violates the minimum command boundary.
- `GOVERNANCE_BLOCK_TARGET_UNAVAILABLE`: target user is unavailable, hidden, or outside the current app-facing user boundary.
- `GOVERNANCE_BLOCKED_INTERACTION`: the requested interaction is blocked by an active user block relation.

## Idempotency Boundary

Duplicate block against the same target must not create duplicate active truth.

Unblock against an absent active relation may be treated as idempotent success or controlled no-op according to the Server truth document.

The contract must not require BFF or Flutter to own a second idempotency state.

## Explicit Non-goals

- No block list center
- No full privacy settings center
- No private-message reporting
- No private-message hard-rule interception
- No message-list preview governance
- No stranger-message controls
- No group-chat governance
- No Admin Review P0
- No penalty / appeal
- No user suspension or permanent-ban contract
- No AI / OCR / QR / precheck
- No release-prep or launch approval

## Formal Conclusion

Block P0 L2 contract is frozen only for:

- minimum current-actor block
- minimum current-actor unblock
- minimum single-target block status
- minimum existing interaction fail-closed behavior for resolved blocked counterparties

BFF and Flutter may consume this contract only after Server truth and BFF surface are frozen and dispatched.

## Next Unique Action

Freeze `docs/02_backend/block_p0_backend_truth_addendum.md`, then BFF and frontend surfaces, before any `apps/**` implementation packet is sent.
