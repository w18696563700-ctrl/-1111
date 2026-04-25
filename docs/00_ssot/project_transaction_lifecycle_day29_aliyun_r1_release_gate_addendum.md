---
owner: Codex 总控
status: frozen
layer: L0 release gate
scheduled_day: 2026-05-29
gate_recorded_at_local: 2026-04-25
purpose: Freeze the Day29 Aliyun R1 release and tunnel route-probe gate for the project transaction lifecycle order routes.
---

# Project Transaction Lifecycle Day29 Aliyun R1 Release Gate

## 1. Scope

This gate admits only:

- Aliyun `Server` and `BFF` runtime alignment for the already frozen project transaction lifecycle routes.
- Controlled release artifact creation under `/srv/releases/server` and `/srv/releases/bff`.
- `current` symlink switch for `exhibition-server` and `exhibition-bff`.
- Route-level smoke through the current tunnel entry `http://127.0.0.1:8080`.

This gate does not admit:

- production acceptance
- dual-account business UAT completion
- payment or settlement expansion
- a new order conversation state machine
- direct Flutter-to-Server calls

## 2. Current Minimum Closure

The R1 minimum closure is:

- `GET /health/bff/live` returns `200`.
- `GET /health/server/live` returns `200`.
- `GET /api/app/order/detail` is mounted and no longer returns route-level `404`.
- `POST /api/app/order/complete/request` is mounted and payload/auth gated.
- `POST /api/app/order/complete/confirm` is mounted and payload/auth gated.
- `POST /api/app/order/complete/reject` is mounted and payload/auth gated.
- `GET /api/app/message/interactions?lane=project_communication` is mounted and auth gated.
- `GET /api/app/message/counterpart-conversation/detail` is mounted and query/auth gated.

Missing login may return `401`. Missing required parameters may return controlled `400`. Forbidden business scope may return controlled `403`. Conflict may return controlled `409`. Route-level `404`, raw upstream stack trace, or Nginx fallback page fails this gate.

## 3. Required Runtime Procedure

The deploy procedure must follow the existing systemd mainline:

- Record previous targets:
  - `readlink -f /srv/apps/server/current`
  - `readlink -f /srv/apps/bff/current`
- Create unique release artifacts:
  - `/srv/releases/server/<release-id>`
  - `/srv/releases/bff/<release-id>/apps/bff`
- Build inside the cloud release artifacts.
- Copy approved env snapshots into the new release artifacts.
- Switch current symlinks.
- Restart:
  - `systemctl restart exhibition-server`
  - `systemctl restart exhibition-bff`
- Verify:
  - `systemctl is-active exhibition-server`
  - `systemctl is-active exhibition-bff`
  - health endpoints through `127.0.0.1:8080`

Rollback target is the recorded previous `current` target. No rollback may be claimed if the previous targets were not captured before switching.

## 4. More Stable / Cheaper / Current-Stage Fit

- More stable: release `Server` first, then `BFF`, then route smoke.
- More cost-efficient: route-smoke only, no dual-account click UAT in this gate.
- More suitable for the current stage: prove cloud route materialization and order anchors are reachable.
- Higher risk: treating this R1 as production acceptance or adding cloud-only hotfix logic outside the frozen source.

## 5. Veto Gates

- Do not deploy without previous `current` targets.
- Do not use PM2 sidecar as the formal proof path.
- Do not hide route-level `404` as success.
- Do not claim dual-account UAT from unauthenticated route smoke.
- Do not mutate business truth directly from BFF or Flutter.

## 6. Decision

Go for Day29 Aliyun R1 runtime alignment and tunnel route probe.

No-Go for production acceptance until a later real-login dual-account UAT proves the order card, order detail, seller completion request, and buyer completion confirmation path end to end.
