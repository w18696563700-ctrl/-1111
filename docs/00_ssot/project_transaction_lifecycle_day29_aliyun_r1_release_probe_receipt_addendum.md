---
owner: Codex 总控
status: frozen
layer: L0 release receipt
scheduled_day: 2026-05-29
execution_recorded_at_local: 2026-04-25
purpose: Record the Aliyun R1 Server/BFF runtime alignment and tunnel route-probe result for project transaction lifecycle order routes.
---

# Project Transaction Lifecycle Day29 Aliyun R1 Release / Probe Receipt

## 1. Scope

This receipt covers only the Day29 R1 runtime alignment and route-level smoke for:

- Server `ProjectOrder` read / completion routes.
- BFF app-facing order routes.
- BFF app-facing counterpart conversation routes.
- 8080 tunnel route materialization.

This receipt does not claim:

- dual-account business UAT completion
- seller/buyer real-login order completion success
- production acceptance
- payment, settlement, invoice, or wallet readiness
- a new message-owned order state machine

## 2. Runtime Decision

Initial check found:

- Server current before switch:
  - `/srv/releases/server/20260425121535-p0-pay-fulfillment-no-fix`
- Target Server release:
  - `/srv/releases/server/20260425150611-project-transaction-day29-r1`
- BFF current:
  - `/srv/releases/bff/20260425154325-day29-bff-runtime-routes/apps/bff`

The target Server release existed and contained the Day29 source routes, but initially did not contain:

- `dist/`
- `node_modules`
- `.env`

Because `exhibition-server.service` runs with:

- `WorkingDirectory=/srv/apps/server/current`
- `ExecStart=/usr/bin/node dist/main.js`

the target release was not safe to switch directly.

Control decision:

- Copy the previous active `.env` into the target release.
- Link the existing compatible `node_modules` into the target release.
- Build the target release before switching.
- Switch `/srv/apps/server/current` only after `dist/main.js` exists.
- Restart `exhibition-server`.
- Roll back to the previous current target if systemd does not return `active`.

## 3. Server Release Result

Final Server runtime:

- `server_current=/srv/releases/server/20260425150611-project-transaction-day29-r1`
- `server_active=active`
- `server_dist=yes`
- `server_env=yes`
- `server_node_modules=yes`

Sub-agent read-only verification confirmed:

- `exhibition-server` main process cwd resolves to the Day29 R1 release.
- `dist/main.js` and `dist/app.module.js` exist.
- `OrderModule`, `MessageInteractionModule`, and `TradingReadCorridorModule` are present in the built app.
- Order completion source and compiled controller exist.
- Order detail source and compiled controller exist.
- Counterpart conversation source and compiled controller exist.

Known release-shape note:

- `node_modules` is a symlink to an existing compatible release dependency directory, not a fully self-contained copied dependency tree.
- This is acceptable for R1 route smoke but should be replaced by self-contained release packaging in a later release-hardening gate.

## 4. BFF Runtime Result

Final BFF runtime:

- `bff_current=/srv/releases/bff/20260425154325-day29-bff-runtime-routes/apps/bff`
- `bff_active=active`

BFF was already aligned to the Day29 runtime route package before the Server current correction.

## 5. Tunnel Probe Evidence

Tunnel entry:

- `http://127.0.0.1:8080`

Health:

| Probe | Result |
|---|---:|
| `GET /health/bff/live` | `200` |
| `GET /health/server/live` | `200` |

App-facing route smoke:

| Probe | Result | Meaning |
|---|---:|---|
| `GET /api/app/order/detail?orderId=route-smoke-order` | `401 AUTH_SESSION_INVALID` | Route mounted; auth gated; not route-level `404`. |
| `POST /api/app/order/complete/request` | `401 AUTH_SESSION_INVALID` | Route mounted; auth gated; not route-level `404`. |
| `POST /api/app/order/complete/confirm` | `401 AUTH_SESSION_INVALID` | Route mounted; auth gated; not route-level `404`. |
| `POST /api/app/order/complete/reject` | `401 AUTH_SESSION_INVALID` | Route mounted; auth gated; not route-level `404`. |
| `GET /api/app/message/interactions?lane=project_communication` | `401 AUTH_SESSION_INVALID` | Route mounted; auth gated; not route-level `404`. |
| `GET /api/app/message/counterpart-conversation/detail?conversationId=route-smoke-org&projectId=route-smoke-project` | `401 AUTH_SESSION_INVALID` | Route mounted; auth gated; not route-level `404`. |

Server direct route smoke on `127.0.0.1:3001`:

| Probe | Result | Meaning |
|---|---:|---|
| `GET /server/order/detail?orderId=route-smoke-order` | `401 AUTH_SESSION_INVALID` | Server route mounted; auth gated. |
| `POST /server/order/complete/request` | `401 AUTH_SESSION_INVALID` | Server route mounted; auth gated. |
| `POST /server/order/complete/confirm` | `401 AUTH_SESSION_INVALID` | Server route mounted; auth gated. |
| `POST /server/order/complete/reject` | `401 AUTH_SESSION_INVALID` | Server route mounted; auth gated. |
| `GET /server/message/counterpart-conversation/detail?conversationId=route-smoke-org&projectId=route-smoke-project` | `401 AUTH_SESSION_INVALID` | Server route mounted; auth gated. |

The direct path `GET 127.0.0.1:3001/health/server/live` returns `404` because the formal health route is exposed through the Nginx/BFF tunnel entry. The Day29 gate uses `127.0.0.1:8080/health/server/live`, which returned `200`.

## 6. Gate Checklist

| Gate | Result | Notes |
|---|---:|---|
| Previous Server current captured | Pass | Previous target recorded before switch. |
| Target Server release exists | Pass | `/srv/releases/server/20260425150611-project-transaction-day29-r1`. |
| Target Server built before switch | Pass | `npm run build`; `dist/main.js` exists. |
| Server current switched | Pass | Current now points to Day29 R1 target. |
| Server systemd active | Pass | `exhibition-server active`. |
| BFF systemd active | Pass | `exhibition-bff active`. |
| 8080 health | Pass | BFF and Server health return `200`. |
| 8080 order routes | Pass | Mounted and auth-gated; no route-level `404`. |
| 8080 counterpart routes | Pass | Mounted and auth-gated; no route-level `404`. |
| Real-login write UAT | Not claimed | Requires dual-account auth context. |
| Production acceptance | Not claimed | Blocked until real account UAT. |

## 7. Rollback Target

Recorded rollback point:

- Server rollback target:
  - `/srv/releases/server/20260425121535-p0-pay-fulfillment-no-fix`
- BFF rollback target:
  - existing Day29 BFF current before this correction was already:
    - `/srv/releases/bff/20260425154325-day29-bff-runtime-routes/apps/bff`

No rollback was performed because the post-switch checks passed.

## 8. Result

Day29 Aliyun R1 route-level release gate is complete.

Completion level:

- `Server+BFF cloud route materialization`: complete.
- `8080 tunnel can access new order routes`: complete.
- `real-login seller/buyer order completion`: not included in this R1 receipt.

Next allowed stage:

- Real-login dual-account UAT through Flutter / Computer Use.

Still blocked:

- Production acceptance.
- Claiming end-to-end completed-order / rating / credit success without real-login UAT evidence.
