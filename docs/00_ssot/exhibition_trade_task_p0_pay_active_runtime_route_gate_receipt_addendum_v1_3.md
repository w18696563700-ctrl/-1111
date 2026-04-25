---
owner: Codex Control
status: systemd_main_active_route_gate_passed
purpose: Record the P0-Pay active-runtime route gate result after the earlier 404 blocker, including local package/build evidence, cloud release pointer capture, controlled systemd main cutover, log evidence, and cloud tunnel smoke evidence.
layer: L0 SSOT
actual_execution_date_local: 2026-04-25
scope:
  - P0-Pay BFF / Server active runtime route gate
  - pre-05-17 route-level smoke
  - release readiness receipt
---

# Exhibition Trade Task P0-Pay Active Runtime Route Gate Receipt Addendum V1.3

## 0. Conclusion

Current ruling:

- The P0-Pay cloud route-level blocker has been cleared.
- The formal main `exhibition-server` and `exhibition-bff` systemd units are now active.
- The active main release pointers are both `20260425095803-p0-pay-runtime-alignment`.
- The previous PM2 route processes occupying `3000 / 3001` were stopped before systemd main startup.
- `infra/scripts/p0_pay_cloud_route_smoke.sh` now passes against `http://127.0.0.1:8080`.
- The active tunnel no longer returns route-level `404` for `/api/app/exhibition/trade-tasks*`.
- The next stage may enter `2026-05-17 明价竞标、平台服务费预授权、未中标释放` integration preparation.

This receipt does not claim:

1. Real payment, preauthorization, release, refund, charge, or breach-hold business-chain success.
2. Valid logged-in actor packet readiness.
3. 05-17 or 05-18 dual-account UAT pass.
4. Production release readiness.

## 1. Current Minimum Closure

The minimum closure for this gate is:

1. `BFF` app-facing P0-Pay route family is mounted.
2. The route family no longer returns Nest/Nginx route-level `404`.
3. Missing-auth read route returns controlled `401`.
4. Empty or invalid mutation route returns controlled `400`.
5. State-action route is mounted and payload-gated.
6. `Server` and `BFF` health endpoints are reachable through the current tunnel.

More stable:

- Treat this receipt as a route-gate pass only, then run 05-17 before 05-18.

More cost-efficient:

- After this systemd handoff, do not repeat restart unless a new route/runtime blocker appears.

More suitable for the current stage:

- Proceed to bounded integration seeds and actor packet preparation.

Higher risk:

- Treat route-gate pass as full payment-chain pass, or skip 05-17 and go directly to 05-18.

## 2. Package Identity

Local package identity checked on 2026-04-25:

```text
git short HEAD: 9d01175
apps/server package: @exhibition/server@0.1.0
apps/bff package: @exhibition/bff@0.1.0
```

Dirty-worktree note:

- The workspace contains many modified and untracked files.
- Therefore `git short HEAD` alone is not a complete immutable release identity.
- Any formal cloud release artifact must carry its own artifact name, package manifest, and previous-current rollback target.

## 3. Local Build And Test Evidence

Commands run locally:

```text
corepack pnpm --filter @exhibition/server build
corepack pnpm --filter @exhibition/bff build
node --test apps/server/test/p0-pay-calculator-idempotency.test.cjs apps/server/test/p0-pay-server-mainline.test.cjs
node --test apps/bff/test/exhibition-p0-pay-transport.test.cjs
```

Result:

```text
Server build: passed
BFF build: passed
Server P0-Pay tests: 5 passed
BFF P0-Pay transport tests: 7 passed
```

## 4. Cloud Tunnel Health Evidence

Base:

```text
http://127.0.0.1:8080
```

Health probe:

```text
GET /health/bff/live
-> 200 {"status":"ok","service":"exhibition-bff","port":3000}

GET /health/server/live
-> 200 {"status":"ok","service":"exhibition-server","port":3001}
```

This proves:

1. The current tunnel reaches a live BFF process on port `3000`.
2. The current tunnel reaches a live Server process on port `3001`.
3. It is consistent with the separately captured root-level systemd status below.

## 5. Cloud Route Smoke Evidence

Command:

```text
infra/scripts/p0_pay_cloud_route_smoke.sh
```

Result:

```text
[info] P0-Pay cloud route smoke base: http://127.0.0.1:8080
[ok] exhibition home ingress baseline: 200
[ok] trade-task summary route mounted and auth-gated: 401
[ok] trade-task create route mounted and payload-gated: 400
[ok] state action route mounted and payload-gated: 400
[done] P0-Pay cloud route family is mounted with controlled gates.
```

Day 0.25 rerun result:

```text
SERVER_ACTIVE=active
BFF_ACTIVE=active
SERVER_CURRENT=/srv/releases/server/20260425095803-p0-pay-runtime-alignment
BFF_CURRENT=/srv/releases/bff/20260425095803-p0-pay-runtime-alignment

[info] P0-Pay cloud route smoke base: http://127.0.0.1:8080
[ok] exhibition home ingress baseline: 200
[ok] trade-task summary route mounted and auth-gated: 401
[ok] trade-task create route mounted and payload-gated: 400
[ok] state action route mounted and payload-gated: 400
[done] P0-Pay cloud route family is mounted with controlled gates.
```

Gate interpretation:

- Previous route-level `404` blocker is closed for this route gate.
- The active runtime now satisfies the prerequisite for entering 05-17.
- 05-17 must still prove actual fixed-price bid, platform service-fee preauthorization, and non-winning release state transitions.

## 6. Root Release Pointer, Rollback Target, And Cutover

Captured before the controlled systemd cutover:

```text
SERVER_PREV=/srv/releases/server/20260425095803-p0-pay-runtime-alignment
BFF_PREV=/srv/releases/bff/20260425095803-p0-pay-runtime-alignment
```

The main `current` pointers after cutover:

```text
SERVER_CURRENT=/srv/releases/server/20260425095803-p0-pay-runtime-alignment
BFF_CURRENT=/srv/releases/bff/20260425095803-p0-pay-runtime-alignment
```

Runtime correction performed:

1. Recorded `SERVER_PREV` and `BFF_PREV`.
2. Stopped PM2 processes `server-s6-r6` and `bff-s6-r4`, which were occupying `3001 / 3000`.
3. Started `exhibition-server`.
4. Started `exhibition-bff`.
5. Verified systemd active status.
6. Verified route smoke `200 / 401 / 400 / 400`.

PM2 post-state:

```text
server-s6-r6: stopped
bff-s6-r4: stopped
```

Rollback note:

- Because the pre-cutover and post-cutover `current` pointers are the same release artifact, rollback for this correction is process-manager rollback rather than release-pointer rollback.
- If systemd main fails, restart the stopped PM2 entries only as an emergency fallback:

```text
pm2 restart server-s6-r6
pm2 restart bff-s6-r4
```

## 7. Server Active Ruling

Observed:

- Server health through tunnel returns `200`.
- P0-Pay route smoke reaches the app-facing path family and receives controlled responses.
- Local Server package builds and P0-Pay route tests pass.
- `systemctl is-active exhibition-server` returns `active`.
- Port `3001` is owned by the main `exhibition-server` node process.

Ruling:

- `Server active for route-gate prerequisite`: pass.
- `Server full 05-17/05-18 business-chain integration`: not yet proven.
- `Fresh root-level Server restart in this session`: completed.

## 8. BFF Active Ruling

Observed:

- BFF health through tunnel returns `200`.
- `/api/app/exhibition/trade-tasks*` no longer returns route-level `404`.
- Local BFF package builds and P0-Pay transport tests pass.
- `systemctl is-active exhibition-bff` returns `active`.
- Port `3000` is owned by the main `exhibition-bff` node process.

Ruling:

- `BFF active for route-gate prerequisite`: pass.
- `BFF full 05-17/05-18 business-chain integration`: not yet proven.
- `Fresh root-level BFF restart in this session`: completed.

## 9. Gate Decision

Passed gates:

1. Local Server build.
2. Local BFF build.
3. Local Server P0-Pay targeted tests.
4. Local BFF P0-Pay targeted tests.
5. Cloud BFF live health.
6. Cloud Server live health.
7. `infra/scripts/p0_pay_cloud_route_smoke.sh`.
8. Route-level `404` blocker closed for `/api/app/exhibition/trade-tasks*`.
9. Main `exhibition-server` systemd unit active.
10. Main `exhibition-bff` systemd unit active.
11. PM2 route processes stopped after handoff to main systemd units.

Failed / not-yet-proven gates:

1. Valid publisher/factory actor packet not proven.
2. 05-17 seed not proven.
3. 05-18 seed not proven.
4. Real payment-channel state transitions not proven.

Veto gates retained:

1. Do not claim 05-17 pass until fixed-price bid, preauthorization, and non-winning release readback pass.
2. Do not claim 05-18 pass until contract charge, publisher breach release/refund, and factory refusal `breach_hold` readback pass.
3. Do not claim production readiness from route smoke alone.

Next stage allowed:

- `2026-05-17 云上联调：明价竞标、平台服务费预授权、未中标释放`.

Next stage not allowed:

- `2026-05-18` before 05-17 passes.
- UAT.
- Production release.
- Real-money trial.

## 10. Formal Result

The current P0-Pay active runtime route gate is:

```text
PASS FOR 05-17 ENTRY
NO-GO FOR 05-18 UNTIL 05-17 PASSES
NO-GO FOR UAT / PRODUCTION / REAL-MONEY TRIAL
```
