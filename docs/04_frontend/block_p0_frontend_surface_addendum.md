---
owner: Codex Control
status: frozen
purpose: Freeze the Flutter-side Block P0 consumption boundary for minimum block, unblock, and blocked-interaction feedback without opening a block-management center, messages governance, Admin Review P0, penalty, or appeal.
layer: L3 Frontend
created_at: 2026-04-07
---

# Block P0 Frontend Surface Addendum

## Scope

This addendum freezes Flutter consumption for `Block P0`.

It covers only:

- `CS-018` user block relation consumption
- `CS-019` bounded interaction-blocking feedback

It does not approve implementation completion, release-prep, or launch approval.

## Frontend Consumption Boundary

Flutter may consume only the BFF-shaped routes:

- `POST /api/app/profile/block`
- `POST /api/app/profile/unblock`
- `GET /api/app/profile/block/status`

Flutter must not call Server directly.

Flutter must not own block relation truth or interaction-blocking truth.

## Minimum UI Surface

Flutter may provide only:

- minimum block action on existing allowed user/author surfaces
- minimum unblock action where the same frozen surface needs reversal
- minimum blocked-interaction disabled state or controlled feedback
- minimum fail-closed message for controlled BFF errors

Allowed user-facing copy meaning:

- block succeeded
- unblock succeeded
- current interaction is unavailable
- target user is unavailable
- request could not be completed

The copy must not imply:

- the target user has been penalized
- the target user has been suspended or permanently banned
- Admin Review P0 has processed the user
- an appeal route exists

## Interaction Boundary

Flutter may only reflect interaction blocking for existing app-facing interactions frozen by the backend and BFF specs.

Minimum P0 feedback may appear on:

- forum comment / reply interaction attempts against a blocked counterparty
- forum like interaction attempts against a blocked counterparty
- author or user-facing surfaces where BFF provides `blockedByMe` or `canInteract`

Flutter must not add:

- private-message blocking center
- message-list preview governance
- harassment settings center
- group-chat governance
- full block list center unless separately frozen

## State Boundary

Flutter state must remain a consumer cache only.

It must not become:

- block relation truth
- a second block state machine
- a local-only block enforcement source
- Admin review state
- penalty or appeal state

## Explicit Non-goals

- No full block-management center
- No private-message moderation
- No report history center
- No Admin Review P0 surface
- No penalty / appeal UI
- No user suspension / permanent-ban UI
- No AI / OCR / QR / precheck UI
- No release-prep or launch approval

## Formal Conclusion

Flutter Block P0 surface is frozen as minimum consumption and feedback only.

Block relation truth remains Server-owned and BFF-shaped.

## Next Unique Action

After this frontend surface is frozen and source-map registered, Control may dispatch Packet 1 to `后端 Agent（仅云端）` for bounded Server implementation.
