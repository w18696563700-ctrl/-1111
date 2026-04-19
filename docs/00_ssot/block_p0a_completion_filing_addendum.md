---
title: Block P0-A Completion Filing
status: frozen
owner: Codex Control
scope: docs-only-completion-filing
created_at: 2026-04-07
---

# Block P0-A Completion Filing

## A. Filing Object

`Block P0-A relation/status-only`

Capability scope:

- `CS-018` user block relation
- block command
- unblock command
- single-target block status query

Explicitly out of scope:

- `CS-019` interaction blocking
- Block P0-B
- forum comment/reply write commands
- forum like write commands
- block list center
- messages complex governance
- Admin Review P0
- P1 / P2
- AI / OCR / QR
- forum precheck
- penalty / appeal
- release-prep / launch approval

## B. Accepted Evidence

Result verification rerun returned `PASS` for `CS-018 relation/status-only`.

Accepted runtime and implementation evidence:

- Server active release: `/srv/apps/server/current -> /srv/releases/server/20260407113018`
- BFF active release: `/srv/apps/bff/current -> /srv/releases/bff/20260407125632/apps/bff`
- `exhibition-server.service` active on `:3001`
- `exhibition-bff.service` active on `:3000`
- active DB `exhibition_app` contains `user_block_relations`
- `idx_user_block_relations_active_pair` exists as the active-pair unique partial index
- direct Server no-auth route smoke returns controlled `401 AUTH_SESSION_INVALID`, not route `404`
- direct Server authenticated status / block / status / unblock / status smoke returns `200`
- BFF app-facing authenticated status / block / status / unblock / status smoke returns `200`
- Flutter no longer references `/api/app/relation/block*`
- Flutter consumes only:
  - `/api/app/profile/block`
  - `/api/app/profile/unblock`
  - `/api/app/profile/block/status`
- targeted Flutter analyze passed
- `flutter test test/forum_routes_test.dart` passed with `19/19`

## C. Completion Conclusion

`Block P0-A relation/status-only`: `COMPLETED`

`CS-018`: `COMPLETED`

This completion is limited to the current Block P0-A boundary:

- Server remains the block relation truth owner.
- BFF only forwards and shapes app-facing responses.
- Flutter only consumes BFF profile block routes.
- No second block truth or state machine is accepted outside Server.

## D. Deferred Scope

`CS-019` remains explicitly deferred to `Block P0-B`.

This completion filing does not complete or unlock:

- interaction blocking
- forum comment/reply hook
- forum like hook
- Block P0-B
- Admin Review P0
- P1 / P2
- AI / OCR / QR
- forum precheck
- penalty / appeal
- release-prep / launch approval

## E. Anti-Omission Check

- `CS-018` is registered, implemented, independently verified, and now filed as completed.
- `CS-019` is registered and remains deferred to Block P0-B.
- No content-safety capability point is deleted by this filing.
- No formal surface is rewritten as a broader unlock.
- No release or launch approval is granted.

## F. Next Unique Action

Return to Control for the next package selection judgment.

The likely next candidate is `Admin Review P0`, but it remains blocked until Control explicitly issues the next allowed package action under the current four-action development-priority flow.
