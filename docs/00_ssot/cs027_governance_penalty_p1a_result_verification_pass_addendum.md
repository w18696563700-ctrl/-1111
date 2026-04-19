---
title: CS-027 Governance Penalty P1-A Result Verification Pass
layer: L0 SSOT
created_at: 2026-04-08
owner: 总控
---

# CS-027 Governance Penalty P1-A Result Verification Pass

## A. Scope

This filing records the bounded completion of `CS-027 Governance Penalty P1-A`.

Accepted scope:

- Server-owned `governance_penalties` truth
- Server Admin penalty list
- Server Admin penalty detail
- Server Admin penalty apply
- minimum audit evidence on penalty apply
- Admin-only minimal penalty list/detail/apply consumption

This is not a full governance platform completion.

Still out of scope:

- `CS-028` appeal
- user-side penalty history
- my appeals
- permanent-ban full chain
- whitelist lifecycle
- cumulative violation score
- historical rescan
- AI / OCR / QR
- forum precheck
- `CS-019` / Block P0-B
- release-prep / launch approval

## B. Accepted Evidence

Server:

- cloud remote preflight passed in `/srv/apps/server/current`
- `/srv/apps/server/current` resolves to `/srv/releases/server/20260407113018`
- `exhibition-server.service` is active
- `governance_penalties` truth carrier exists
- `governance_penalty_apply` audit evidence is emitted through existing content-safety audit carriers
- Server build: `PASS`
- targeted `CS-027` Server test: `4/4 PASS`
- Server CJS test suite: `22/22 PASS`

Canonical route correction:

- canonical apply route is `POST /server/admin/governance/penalties`
- the temporary `/server/admin/governance/penalties/apply` route drift was corrected
- `POST /server/admin/governance/penalties` returns controlled auth response without a session, not route `404`
- `/server/admin/governance/penalties/apply` returns route `404`

Admin:

- cloud Admin preflight passed in `/srv/apps/admin/current`
- `/srv/apps/admin/current` resolves to `/srv/workspaces/exhibition-infra-monorepo/apps/admin`
- active Admin runtime is `next-server` on `127.0.0.1:3002`
- Admin build: `PASS`
- Admin lint: `PASS`
- Admin uses `SERVER_ADMIN_API_BASE_URL=http://127.0.0.1:3001/server/admin`
- Admin source does not consume BFF or `/api/app`
- Admin source does not consume the temporary `/penalties/apply` path
- Admin routes `/governance`, `/governance/penalties`, and `/governance/penalties/[penaltyId]` exist in the built route manifest

Ingress:

- Nginx was minimally updated to proxy `/governance` and `/governance/*` to `admin_upstream`
- no-cookie `/governance*` now returns a controlled login redirect through Admin instead of raw Nginx `404`
- `/api/admin/governance/penalties` returns controlled `AUTH_SESSION_INVALID`, proving it reaches Server Admin API rather than BFF

Source sync:

- active Server scoped files were synchronized back to local `apps/server/**`
- active Admin scoped files were synchronized back to local `apps/admin/**`
- no BFF or Flutter code was required for this package

## C. Scope Drift Check

No accepted evidence shows implementation of:

- appeal
- user-side penalty history
- my appeals
- permanent-ban full chain
- whitelist lifecycle
- cumulative violation score
- historical rescan
- AI / OCR / QR
- forum precheck
- `CS-019` / Block P0-B
- release-prep / launch approval

## D. Decision

`CS-027 Governance Penalty P1-A`: `PASS / completed`.

This completion is bounded to the Server/Admin minimum penalty action slice only.
