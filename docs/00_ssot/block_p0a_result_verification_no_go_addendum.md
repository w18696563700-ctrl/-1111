---
title: Block P0-A Result Verification NO-GO
status: frozen
owner: Codex Control
scope: docs-only-verification-conclusion
created_at: 2026-04-07
---

# Block P0-A Result Verification NO-GO

## A. Verification Object

`Block P0-A result verification`

Scope:

- `CS-018` relation/status-only
- block relation truth
- block command
- unblock command
- single-target block status query

Out of scope:

- `CS-019` interaction blocking
- Block P0-B
- Admin Review P0
- P1 / P2
- AI / OCR / QR
- forum precheck
- penalty / appeal
- release-prep / launch approval

## B. Result

`NO-GO`

Block P0-A cannot enter completion filing.

## C. Evidence Reviewed

Result verification reported:

- active BFF profile block routes forward upstream to Server 404
- `/api/app/relation/block/status` returns nginx raw 404
- active DB does not contain `user_block_relations`
- cloud Server build/tests pass
- cloud BFF build passes
- Flutter targeted route tests and analyze pass
- `CS-019` interaction blocking was not implemented

Control independently checked cloud runtime on `2026-04-07`:

- `exhibition-server.service` is active and owns the active Server runtime on port `3001`
- active systemd Server process:
  - pid: `1272934`
  - cwd: `/srv/releases/server/20260407113018`
  - command: `/usr/bin/node dist/main.js`
  - started before the latest Block P0-A route-bearing dist was loaded
- PM2 `server-staging` process:
  - pid: `1320781`
  - cwd: `/srv/releases/server/20260407113018`
  - listens on port `3101`
  - uses `POSTGRES_DB=exhibition_app_staging_smoke_20260326141556`
- active `:3001` direct Server requests still return:
  - `GET /server/profile/block/status`: `404`
  - `POST /server/profile/block`: `404`
  - `POST /server/profile/unblock`: `404`
- active BFF logs show upstream `404` for `/server/profile/block*`
- active `POSTGRES_DB` for systemd Server is `exhibition_app`
- `exhibition_app` has no `user_block_relations` table and no `user_block_relations` indexes
- `user_block_relations` exists only in the smoke DB `exhibition_app_staging_smoke_20260326141556`

## D. Failure Reasons

1. Active Server route is not materialized on the real app-facing Server runtime.

   The route exists in the accepted artifact source/dist, and PM2 logs mapped it, but active app-facing traffic on `:3001` is owned by systemd `exhibition-server.service`, not by PM2 `server-staging`.

2. Active DB schema is missing.

   The active DB `exhibition_app` does not contain `user_block_relations`. The table exists only in a smoke DB.

3. Flutter route surface drifts from frozen Block P0 surface.

   Frozen BFF/Frontend surface uses:

   - `/api/app/profile/block`
   - `/api/app/profile/unblock`
   - `/api/app/profile/block/status`

   Current Flutter test/source references still include:

   - `/api/app/relation/block`
   - `/api/app/relation/block/status`

## E. Scope Drift Check

No accepted out-of-scope implementation was found for:

- `CS-019` interaction blocking
- forum comment/reply write commands
- forum like write commands
- Block P0-B
- Admin Review P0
- AI / OCR / QR
- forum precheck
- penalty / appeal
- release-prep / launch approval

## F. Anti-Omission Check

- `CS-018` remains registered and uncompleted.
- `CS-019` remains registered and deferred to Block P0-B.
- `CS-020`, `CS-021`, `CS-022`, `CS-027`, and `CS-028` remain out of scope.
- No Block P0-A completion filing is allowed.
- BFF / Frontend completion cannot be accepted before active Server route/schema alignment and Flutter route-surface correction pass.

## G. Decision

`Block P0-A result verification`: NO-GO.

`CS-018`: pause / blocked pending one bounded active Server runtime and schema correction, then Flutter route-surface correction and result-verification rerun.

`CS-019`: remains explicitly deferred to Block P0-B.

## H. Allowed Correction Action

`Block P0-A active Server runtime and schema correction`

This is the one allowed correction round after result-verification NO-GO.

The correction must be limited to:

- active systemd Server runtime alignment on port `3001`
- active DB `exhibition_app` schema application for `user_block_relations`
- route smoke for `/server/profile/block*`

It must not modify business scope, implement `CS-019`, or open BFF / Frontend / Admin / P1 / P2 / release work.

## I. Correction Follow-Up

After the allowed correction, Control accepts the active Server runtime / schema alignment as `PASS` based on the returned cloud receipt and independent runtime smoke:

- `/srv/apps/server/current` resolves to `/srv/releases/server/20260407113018`.
- `exhibition-server.service` is active and owns active Server port `3001`.
- active Server process cwd is `/srv/releases/server/20260407113018`.
- active `/server/profile/block/status`, `/server/profile/block`, and `/server/profile/unblock` no longer return route `404`; unauthenticated smoke returns controlled `401 AUTH_SESSION_INVALID`.
- active DB `exhibition_app` contains `user_block_relations`.
- active DB contains `idx_user_block_relations_active_pair` as a unique partial active-pair index.
- `CS-019` interaction blocking remains unimplemented, with no forum comment/reply write command or forum like write command added.

Updated decision:

- active Server route/schema blocker: closed.
- `Block P0-A` completion filing: still not allowed.
- residual blocker: Flutter route surface still references `/api/app/relation/block*` instead of frozen `/api/app/profile/block*`.
- `CS-018`: moves from `pause` to `pending frontend route-surface correction and result-verification rerun`.
- `CS-019`: remains explicitly deferred to Block P0-B.

Next unique action:

`Block P0-A Frontend route-surface correction`

This action is local-frontend only and must not modify Server, BFF, Admin, docs, packages, or any out-of-scope content-safety package.

## J. Frontend Route-Surface Correction Follow-Up

After the frontend route-surface correction receipt, Control accepts the local frontend correction as `PASS` for the previous route-drift blocker:

- Flutter block route now uses `/api/app/profile/block`.
- Flutter unblock route now uses `/api/app/profile/unblock`.
- Flutter block-status route now uses `/api/app/profile/block/status`.
- No `/api/app/relation/block*` consumer route remains under `apps/mobile/lib` or `apps/mobile/test`.
- Targeted `flutter analyze` for the affected forum/mobile files passed.
- `flutter test test/forum_routes_test.dart` passed with `19/19`.
- No Server, BFF, Admin, docs, or packages implementation change is accepted as part of this frontend correction.
- `CS-019` / Block P0-B remains unimplemented and deferred.

Updated decision:

- active Server route/schema blocker: closed.
- Flutter route-surface blocker: closed.
- `Block P0-A` completion filing: still not allowed until result-verification rerun passes.
- `CS-018`: pending result-verification rerun.
- `CS-019`: remains explicitly deferred to Block P0-B.

Next unique action:

`Block P0-A result verification rerun`

The rerun must verify active Server runtime/schema, active BFF app-facing surface, local Flutter route consumption, and scope drift controls before any completion filing.

## K. Result Verification Rerun Follow-Up

Result verification rerun returned `NO-GO`.

Accepted pass items:

- active Server runtime and schema: `PASS`
- direct Server authenticated smoke for status / block / unblock: `PASS`
- Flutter route consumption: `PASS`
- legacy `/api/app/relation/block*` route removal from Flutter: `PASS`
- `CS-019` / Block P0-B scope exclusion: `PASS`

Residual blocker:

- BFF app-facing profile block surface: `NO-GO`

The BFF routes exist and forward to Server, but the BFF read-model / shaping layer still expects the old `ok / traceId / relationStatus / blocked` response shape while the current Server response shape is:

- `targetUserId`
- `blockedByMe`
- `canInteract`
- `effectiveAt` for command responses where applicable
- `interactionBlockedReason` for blocked status where applicable

Updated decision:

- `CS-018`: not complete; pending one bounded BFF shaping/read-model correction.
- `CS-019`: remains explicitly deferred to Block P0-B.
- Block P0-A completion filing remains blocked.

Next unique action:

`Block P0-A BFF shaping/read-model correction`

This correction must be limited to cloud BFF code under `apps/bff/**`, must keep Server as truth owner, must not change Server or Flutter, and must not open Block P0-B, Admin Review P0, P1/P2, AI/OCR/QR, precheck, penalty/appeal, release-prep, or launch approval.
