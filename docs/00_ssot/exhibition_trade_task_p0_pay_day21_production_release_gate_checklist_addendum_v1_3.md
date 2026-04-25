# Exhibition Trade Task P0-Pay Day21 Production Release Gate Checklist Addendum V1.3

status: production_release_gate_checklist
planned_gate_date: 2026-05-21
actual_execution_date_local: 2026-04-25
owner: Codex Control
scope: P0-Pay production release gate judgment, not production cutover

## 0. Conclusion

2026-05-21 P0-Pay 生产发布门禁核查已完成。

Gate decision:

1. `Go` for 2026-05-22 controlled gray observation.
2. `No-Go` for public production release.
3. `No-Go` for real-money Alipay / WeChat payment trial.
4. `No-Go` for wallet, balance, coins, fund pool, settlement, invoice, finance admin, account-binding module, or P1 guarantee-deposit work.

Allowed next stage:

- `2026-05-22 灰度发布与首日观察闭环`

Allowed gray scope:

1. controlled account whitelist only.
2. Aliyun active runtime only.
3. order-level `other` / test-channel payment simulation only.
4. read-only payment status display in project detail and messages building.
5. immediate rollback to captured release targets if route smoke, callback idempotency, message readback, or status state machine fails.

Disallowed gray scope:

1. broad production traffic.
2. real Alipay or WeChat final money movement.
3. settlement, invoice, finance reconciliation, or merchant payout.
4. P1 guarantee-deposit freeze, release, deduction, dispute, artificial processing, or lawyer assist.

Current minimum closure:

- P0-Pay can enter controlled gray observation because L0/L2/L3/L4/L5 truth, cloud integration, UAT, Day20 repair, route smoke, active runtime, and targeted regression evidence are complete.

Need to retain but not open:

- real payment provider certification, merchant settlement, invoice, finance admin, stronger monitoring, wider rollback automation, and P1 guarantee-deposit rules.

Future extension slot:

- After real payment-channel sandbox and production merchant verification, reopen a separate `real-money payment channel release gate`.

More stable:

- controlled gray with whitelisted accounts and test-channel payment simulation.

More cost-efficient:

- reuse existing Server-owned state machine, BFF read-only projection, and current systemd rollback path without building wallet or finance modules.

More suitable for the current stage:

- release-gate pass only for controlled gray observation, not full public production.

Higher risk:

- treating this gate as approval for real-money Alipay / WeChat transactions or broad production cutover.

## 1. Source Truth Chain

Passed truth chain:

1. `docs/00_ssot/exhibition_trade_task_payment_mainline_p0_pay_freeze_v1_3.md`
2. `docs/01_contracts/exhibition_trade_task_p0_pay_contracts_addendum_v1_3.md`
3. `docs/00_ssot/exhibition_trade_task_p0_pay_l2_contract_review_freeze_addendum_v1_3.md`
4. `docs/02_backend/exhibition_trade_task_p0_pay_server_truth_addendum_v1_3.md`
5. `docs/02_backend/exhibition_trade_task_p0_pay_persistence_state_audit_freeze_addendum_v1_3.md`
6. `docs/03_bff/exhibition_trade_task_p0_pay_bff_surface_freeze_addendum_v1_3.md`
7. `docs/04_frontend/exhibition_trade_task_p0_pay_frontend_consumption_freeze_addendum_v1_3.md`
8. `docs/00_ssot/exhibition_trade_task_p0_pay_implementation_unlock_stage_gate_checklist_addendum_v1_3.md`

Execution and verification receipts:

1. `docs/00_ssot/exhibition_trade_task_p0_pay_active_runtime_route_gate_receipt_addendum_v1_3.md`
2. `docs/00_ssot/exhibition_trade_task_p0_pay_cloud_0516_0518_integration_receipt_addendum_v1_3.md`
3. `docs/00_ssot/exhibition_trade_task_p0_pay_day19_real_account_uat_receipt_addendum_v1_3.md`
4. `docs/00_ssot/exhibition_trade_task_p0_pay_day20_uat_repair_evidence_receipt_addendum_v1_3.md`

Interpretation:

- Day20 explicitly closes the Day19 UAT retained blockers and allows production-release-gate authoring.
- Day20 explicitly does not approve production release, gray release, or real-money payment trial.
- This Day21 checklist is therefore the formal gate that decides the next allowed step.

## 2. Active Runtime Capture

Cloud host:

- `47.108.180.198`

Tunnel:

- `127.0.0.1:8080 -> 127.0.0.1:80`

Server:

- process: `exhibition-server`
- systemd status: `active`
- unit `WorkingDirectory`: `/srv/apps/server/current`
- observed process cwd: `/srv/releases/server/20260425161006-p0-pay-day20-message-carry`
- `ExecStart`: `/usr/bin/node dist/main.js`
- boot log: `Nest application successfully started`

BFF:

- process: `exhibition-bff`
- systemd status: `active`
- unit `WorkingDirectory`: `/srv/apps/bff/current`
- observed process cwd: `/srv/releases/bff/20260425154325-day29-bff-runtime-routes/apps/bff`
- `ExecStart`: `/usr/bin/node dist/apps/bff/src/main.js`
- recent log: BFF forwards `/server/message/interactions` and `/server/exhibition/home` with upstream `200`

Release-pointer caveat:

- `/srv/releases/server/current` and `/srv/releases/bff/current` are not the active runtime truth paths on this host.
- The active runtime truth is captured from systemd `MainPID` process cwd.

Rollback targets retained:

1. Server rollback candidate: `/srv/releases/server/20260425150611-project-transaction-day29-r1`
2. BFF rollback candidate: `/srv/releases/bff/20260425150611-project-transaction-day29-r1/apps/bff`
3. Earlier BFF route-alignment fallback: `/srv/releases/bff/20260425095803-p0-pay-runtime-alignment`

Rollback rule:

- 05-22 controlled gray must not start unless the rollback operator records the active Server/BFF cwd immediately before cutover or observation start.

## 3. Route Smoke Gate

Command:

```bash
bash infra/scripts/p0_pay_cloud_route_smoke.sh
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

Gate result:

- `passed`

Interpretation:

- The previous active-runtime route-level `404` blocker is closed.
- Route smoke only proves route mounting and controlled gates.
- Route smoke does not prove real payment-provider settlement or public production readiness.

## 4. Regression Evidence

Server targeted regression:

```bash
node --test apps/server/test/p0-pay-calculator-idempotency.test.cjs apps/server/test/p0-pay-server-mainline.test.cjs apps/server/test/message-interaction-bid-carry.test.cjs
```

Result:

- `13/13 passed`

BFF targeted regression:

```bash
node --test apps/bff/test/message-interaction-transport.test.cjs apps/bff/test/exhibition-p0-pay-transport.test.cjs
```

Result:

- `15/15 passed`

Flutter targeted regression:

```bash
cd apps/mobile
flutter test test/p0_pay_flutter_consumption_test.dart test/trading_im_round_a_consumption_test.dart test/messages_instance_todo_test.dart
```

Result:

- `24/24 passed`
- Flutter emitted existing non-fatal `drag()` hit-test warnings in bid-thread scroll tests.

Script syntax checks:

```bash
node --check infra/scripts/p0_pay_cloud_full_e2e.js
node --check infra/scripts/p0_pay_day20_real_account_uat.js
```

Result:

- `passed`

Forbidden-boundary code scan:

```bash
rg -n "wallet|balance|金币|资金池|履约保证金|guarantee|account binding|支付宝账号|微信账号|银行卡号|payment account binding|direct Server|直连 Server" \
  apps/bff/src/routes/exhibition_p0_pay \
  apps/server/src/modules/p0_pay \
  apps/mobile/lib/features/exhibition/data/p0_pay_read_only_summary.dart \
  apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart \
  apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_support.dart \
  apps/mobile/lib/features/messages -S
```

Result:

- Only expected UI boundary copy was found: messages building states it only shows a read-only fund-state summary and does not execute payment, judge fee deduction, or handle guarantee deposit.

## 5. Business-Chain Evidence From Prior Passed Gates

05-16 cloud integration:

- inquiry task create: passed
- 200 yuan sincerity-money payment order and callback: passed
- 5 quotation seats: passed
- sixth quotation rejected: passed
- result processing and deposit refund-pending: passed

05-17 cloud integration:

- fixed-price task create: passed
- two factory bids: passed
- both platform service fee authorizations: `authorized`
- award winner: passed
- non-winning authorization release: `authorization_released`

05-18 cloud integration:

- contract confirmation charge: `charged`
- publisher breach release: `authorization_released`
- factory refusal hold: `breach_hold`

05-19 UAT:

- real-account publisher and factory sessions: valid
- fixed-price bid, preauthorization, award, contract confirmation, charged service fee: passed through BFF/Server
- message-building handoff and full Flutter read-only display: retained as Day20 repair items

05-20 repair:

- Server message carrier seed: passed
- BFF message index readback: passed
- Flutter project-detail read-only P0-Pay summary regression: passed
- Computer Use messages building readback: passed

## 6. Passed Gates

Passed:

1. L0 V1.3 mother truth freeze.
2. L2 contract freeze and review.
3. L3 Server truth / persistence / state / audit freeze.
4. L4 BFF surface freeze.
5. L5 Flutter consumption freeze.
6. implementation unlock gate.
7. active-runtime route gate.
8. 05-16 inquiry / sincerity-money / quotation-seat / refund integration.
9. 05-17 fixed-price bid / preauthorization / non-winning release integration.
10. 05-18 contract-confirm charge / publisher-breach release / factory-refusal hold integration.
11. 05-19 real-account UAT business chain.
12. 05-20 UAT issue repair and evidence补齐.
13. current route smoke `200 / 401 / 400 / 400`.
14. current Server/BFF systemd active status.
15. current targeted Server/BFF/Flutter regressions.
16. Server remains the business truth, payment truth, callback truth, state-machine truth, and audit owner.
17. BFF remains app-facing request shaping / response shaping / read-only aggregation only.
18. Flutter remains BFF-only and does not own payment truth.
19. messages building carries read-only P0-Pay status only.

## 7. Failed Or Conditional Gates

Failed for public production:

1. Real Alipay payment-provider production money movement has not been validated.
2. Real WeChat payment-provider production money movement has not been validated.
3. Merchant settlement, invoice, finance reconciliation, and payout are not in scope.
4. Broad production traffic and non-whitelisted user exposure have not been UATed.

Conditional for controlled gray:

1. Only whitelisted accounts may enter.
2. Only test-channel / `other` signed callbacks may be used.
3. No public traffic cutover.
4. No real user money movement.
5. No payment-account binding.
6. No wallet, balance, coins, or fund pool.
7. No P1 guarantee-deposit feature.

Operational caveats:

1. The git worktree is dirty and contains many pre-existing modified and untracked files.
2. The release identity must therefore be recorded by deployed artifact path, not by `git HEAD` alone.
3. `/srv/releases/*/current` is not the active runtime truth on this host; process cwd must be captured.
4. Full-app regression was not executed; only P0-Pay targeted gates were executed.

## 8. Veto Gates

The following veto gates remain active for 05-22:

1. If route smoke returns route-level `404`, stop gray.
2. If `exhibition-server` or `exhibition-bff` is not `active`, stop gray.
3. If BFF writes or owns payment truth, stop gray.
4. If Flutter calls Server directly for P0-Pay, stop gray.
5. If messages building produces, modifies, or judges fund status, stop gray.
6. If platform service fee preauthorization is treated as a bid fee, seat fee, or signup fee, stop gray.
7. If inquiry sincerity money is labeled as deposit, penalty, guarantee deposit, or platform deduction, stop gray.
8. If non-winning factories are charged platform service fee, stop gray.
9. If final platform service fee is calculated from publisher budget instead of final confirmed amount, stop gray.
10. If P1 guarantee deposit is opened inside P0-Pay, stop gray.
11. If wallet, balance, coins, fund pool, settlement, invoice, finance admin, or account-binding module appears, stop gray.
12. If real Alipay / WeChat money movement is attempted without a separate real-payment release gate, stop gray.

## 9. 05-22 Entry Conditions

05-22 controlled gray may start only after recording:

1. active Server process cwd.
2. active BFF process cwd.
3. rollback targets.
4. route smoke pass.
5. whitelisted publisher/factory accounts.
6. payment channel mode: `other` / test-channel only.
7. observation owner.
8. stop-line owner.

Mandatory 05-22 observation checks:

1. inquiry create, sincerity-money payment, 5 quote seats, sixth quote rejection, and refund-pending.
2. fixed-price bid, platform service fee preauthorization, award, and non-winning release.
3. contract confirmation charge, publisher-breach release, and factory-refusal hold.
4. project detail read-only P0-Pay status.
5. messages building read-only P0-Pay status.
6. Server callback idempotency and audit logs.
7. BFF error mapping and no raw upstream route drift.
8. app failure state and polling terminal behavior.

Mandatory stop lines:

1. any payment state mismatch between Server DB and BFF projection.
2. duplicate callback double-apply.
3. route-level `404` for P0-Pay route family.
4. missing audit row for payment state transition.
5. message-building mutation or judgment of money state.
6. any real-money provider redirect or capture.

## 10. Final Gate Result

The current P0-Pay production release gate result is:

```text
CONDITIONAL PASS FOR 2026-05-22 CONTROLLED GRAY OBSERVATION
NO-GO FOR PUBLIC PRODUCTION RELEASE
NO-GO FOR REAL-MONEY ALIPAY / WECHAT TRIAL
NO-GO FOR WALLET / BALANCE / COINS / FUND POOL
NO-GO FOR SETTLEMENT / INVOICE / FINANCE ADMIN
NO-GO FOR P1 GUARANTEE DEPOSIT
```

Final ruling:

- 05-21 production release gate is completed.
- 05-22 may enter controlled gray observation under the constraints above.
- This checklist itself is not a production cutover command.
