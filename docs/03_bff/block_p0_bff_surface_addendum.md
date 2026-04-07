---
owner: Codex Control
status: frozen
purpose: Freeze the BFF-side Block P0 app-facing shaping boundary without transferring block truth from Server to BFF or opening Admin Review P0, messages governance, penalty, or appeal.
layer: L3 BFF
created_at: 2026-04-07
---

# Block P0 BFF Surface Addendum

## Scope

This addendum freezes BFF surface for `Block P0`.

It covers only app-facing shaping for:

- `CS-018` user block relation
- `CS-019` interaction blocking boundary after block

It does not approve implementation completion, release-prep, or launch approval.

## BFF Route Boundary

BFF may expose only the following app-facing routes for Block P0:

- `POST /api/app/profile/block`
- `POST /api/app/profile/unblock`
- `GET /api/app/profile/block/status`

These routes remain under the existing `profile` app-facing route group.

BFF must not expose:

- Admin block routes
- messages block routes
- penalty routes
- appeal routes
- AI / OCR / QR / precheck routes

## BFF Responsibility Boundary

BFF may do only:

- auth consolidation
- request forwarding to Server
- response shaping for Flutter App
- controlled error mapping
- visibility trimming already frozen upstream

BFF must not own:

- block relation truth
- block status truth
- interaction blocking truth
- a second block state machine
- reporter / penalty / appeal truth

## Request Shaping

For `POST /api/app/profile/block`, BFF may forward only:

- current actor context from the existing auth/session boundary
- `targetUserId`

For `POST /api/app/profile/unblock`, BFF may forward only:

- current actor context from the existing auth/session boundary
- `targetUserId`

For `GET /api/app/profile/block/status`, BFF may forward only:

- current actor context from the existing auth/session boundary
- `targetUserId`

## Response Shaping

BFF may shape only:

- `targetUserId`
- `blockedByMe`
- `canInteract`
- `effectiveAt`
- optional generic `interactionBlockedReason`

BFF must not expose:

- full block relation graph
- block list center
- reverse-direction private relationship details beyond the frozen generic interaction result
- internal audit rows
- Admin review routing
- penalty or appeal status

## Error Shaping

BFF may shape these Server-owned errors:

- `GOVERNANCE_BLOCK_INVALID`
- `GOVERNANCE_BLOCK_TARGET_UNAVAILABLE`
- `GOVERNANCE_BLOCKED_INTERACTION`
- `AUTH_SESSION_INVALID`
- upstream unavailable errors through the existing common envelope

BFF must not invent separate block truth to recover from a Server error.

## Explicit Non-goals

- No BFF-owned block truth
- No Admin Review P0 route
- No messages governance route
- No private-message reporting
- No private-message hard-rule interception
- No message-list preview governance
- No penalty / appeal
- No user suspension or permanent ban
- No AI / OCR / QR / precheck
- No release-prep or launch approval

## Formal Conclusion

BFF Block P0 surface is frozen as app-facing forwarding and shaping only.

Server remains the only block truth owner.

## Next Unique Action

After Server truth and BFF surface are frozen, frontend may freeze its minimum consumption surface before local implementation begins.
