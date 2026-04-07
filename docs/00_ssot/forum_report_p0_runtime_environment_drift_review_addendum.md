---
title: Forum Report P0 Runtime Environment Drift Review
status: frozen
date: 2026-04-07
owner: Codex Control
scope: docs-only-review
---

# Forum Report P0 Runtime Environment Drift Review

## Scope

This document reviews the `Forum Report P0 cloud BFF/Server artifact alignment correction` receipt.

This review is limited to runtime-environment evidence. It does not open new product capabilities.

## Claimed Runtime

The requested correction required proof through:

`127.0.0.1:8080 -> cloud nginx :80 -> BFF :3000 -> Server :3001`

The receipt instead reports the current available host runtime:

- Server: `node apps/server/dist/main.js`, listener `*:3001`
- BFF: `node apps/bff/dist/apps/bff/src/main.js`, listener `*:3000`
- ingress: local Node shim, listener `127.0.0.1:8080`
- no nginx, no Docker daemon, no systemd `exhibition-bff.service` / `exhibition-server.service`

## Control Probe

Control verified the current 8080 listener:

```text
node -e const http=require('http'); ...
forum_report_ingress_shim listening 127.0.0.1:8080 -> 127.0.0.1:3000
```

Control also probed:

```text
GET /health/live -> 200
POST /api/app/forum/report/submit -> 401 AUTH_SESSION_INVALID
```

The route no longer raw-404s in the current local-shim runtime.

## Review Result

The correction is not accepted as a `cloud nginx :80` artifact-alignment proof.

Reason:

- the active proof was performed against a local Node ingress shim, not cloud nginx
- active release symlink / systemd service proof is absent
- nginx proof is absent
- Docker / systemd are reported unavailable on this host

However, the correction is partially acceptable as current-host runtime evidence:

- the app-facing route is no longer route-missing in the current 8080 runtime
- BFF and Server Node processes are running from the repo cwd
- the no-auth route is controlled by BFF instead of raw Express 404

## Decision

`Forum Report P0`: remains `PENDING / NO-GO for final package completion`.

The blocking issue is now an environment-definition drift:

- previous requirement: cloud nginx active ingress
- current proof: local host Node shim ingress

The project must not silently treat these as equivalent.

## Next Unique Action

Author a docs-only judgment:

`Forum Report P0 runtime environment acceptance judgment`

That judgment must decide whether the current-host Node shim runtime may be accepted as the development-stage active ingress for `Forum Report P0`, or whether the package must return to a true cloud nginx / systemd runtime before final verification can proceed.

Until that judgment is complete, do not open:

- `Block P0`
- `Admin Review P0`
- AI runtime
- OCR / QR detection
- forum precheck
- automatic takedown
- penalty / appeal
- release-prep / launch approval
