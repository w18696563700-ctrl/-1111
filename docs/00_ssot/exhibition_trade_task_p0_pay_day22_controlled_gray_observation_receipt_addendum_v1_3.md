# Exhibition Trade Task P0-Pay Day22 Controlled Gray Observation Receipt Addendum V1.3

status: controlled_gray_day1_observation_closed
planned_gate_date: 2026-05-22
actual_execution_date_local: 2026-04-25
owner: Codex Control
scope: P0-Pay controlled gray observation, test-channel only

## 0. Conclusion

2026-05-22 P0-Pay 受控灰度发布与首日观察闭环已完成。

Final result:

1. controlled gray observation: `passed`
2. inquiry / sincerity-money / quotation seats / refund-pending chain: `passed`
3. fixed-price bid / platform service fee preauthorization / non-winning release chain: `passed`
4. contract confirmation charge / publisher-breach release / factory-refusal hold chain: `passed`
5. real-account message-building and project-detail read-only P0-Pay carry: `passed`
6. duplicate callback idempotency observation: `passed`
7. post-observation route smoke and active-runtime health: `passed`
8. stop-line findings: `none`

This receipt closes the planned P0-Pay P0 controlled gray observation loop.

It does not approve:

1. public production release
2. real-money Alipay / WeChat payment trial
3. wallet, balance, coins, or fund pool
4. payment-account binding
5. settlement, invoice, finance admin, or merchant payout
6. P1 guarantee-deposit freeze, release, deduction, dispute, artificial processing, or lawyer assist

Current minimum closure:

- P0-Pay P0 can keep controlled gray enabled under whitelist and test-channel limits.

Need to retain but not open:

- real payment provider sandbox and production merchant verification.
- settlement / invoice / finance-admin reconciliation.
- P1 guarantee-deposit independent rules package.

Future extension slot:

- Open a separate `real-money payment-channel release gate` only after Alipay / WeChat sandbox, merchant qualification, callback-domain review, and finance reconciliation rules are frozen.

More stable:

- Continue with whitelisted controlled gray and test-channel callbacks.

More cost-efficient:

- Keep using existing Server-owned P0-Pay state machine and BFF read-only projections; do not build wallet or finance center.

More suitable for the current stage:

- Close P0-Pay controlled gray and prepare a separate real-payment gate later.

Higher risk:

- Treating this controlled gray as public production or real-money approval.

## 1. Entry Gate

Entry source:

- `docs/00_ssot/exhibition_trade_task_p0_pay_day21_production_release_gate_checklist_addendum_v1_3.md`

Allowed scope from Day21:

1. controlled account whitelist only.
2. Aliyun active runtime only.
3. order-level `other` / test-channel payment simulation only.
4. project-detail and messages-building read-only payment status display.
5. rollback on route smoke, callback idempotency, message readback, or state-machine mismatch.

Day22 stayed inside this scope.

## 2. Active Runtime And Rollback Capture

Cloud host:

- `47.108.180.198`

Tunnel:

- `127.0.0.1:8080 -> 127.0.0.1:80`

Server before and after observation:

- process: `exhibition-server`
- status: `active`
- process cwd: `/srv/releases/server/20260425161006-p0-pay-day20-message-carry`

BFF before and after observation:

- process: `exhibition-bff`
- status: `active`
- process cwd: `/srv/releases/bff/20260425154325-day29-bff-runtime-routes/apps/bff`

Rollback candidates retained:

1. Server: `/srv/releases/server/20260425150611-project-transaction-day29-r1`
2. BFF: `/srv/releases/bff/20260425150611-project-transaction-day29-r1/apps/bff`
3. BFF route-alignment fallback: `/srv/releases/bff/20260425095803-p0-pay-runtime-alignment`

Release-pointer caveat retained:

- `/srv/releases/server/current` and `/srv/releases/bff/current` are not the active runtime truth paths on this host.
- Runtime truth must be read from systemd `MainPID` process cwd.

## 3. Route Smoke

Command:

```bash
bash infra/scripts/p0_pay_cloud_route_smoke.sh
```

Pre-observation and post-observation result:

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

## 4. Controlled Gray Business Chain Evidence

Execution harness:

- temporary cloud copy: `/tmp/p0_pay_cloud_full_e2e_day22.js`
- source script: `infra/scripts/p0_pay_cloud_full_e2e.js`
- evidence file on cloud host: `/tmp/p0_pay_day22_gray_evidence.json`
- payment channel mode: `other` test-channel callback simulation
- real-money provider calls: `none`

Run:

- runId: `p0pay-1777106113801-e68d25`
- blockers: `[]`

### 4.1 Inquiry / Sincerity Money / Seats / Refund

Task:

- taskId: `bb621320-3a81-4abf-86fc-f6ab28042670`
- depositOrderId: `93c47332-b1ac-4541-8342-0c649b7d762f`

Observed:

1. inquiry task create: HTTP `202`
2. task status: `draft`
3. publish gate: `payment_required`
4. sincerity-money order create: HTTP `202`
5. payment init: HTTP `202`
6. signed callback apply status: `applied`
7. deposit status after callback: `paid`
8. submitted quotations: `5`
9. fifth seat summary:
   - seatLimit: `5`
   - seatUsed: `5`
   - seatRemaining: `0`
   - quoteEntryOpen: `false`
10. sixth quotation status: HTTP `400`
11. result action: `select_factory`
12. deposit status after result: `refund_pending`
13. refund status: `refund_pending`

Result:

- `passed`

The sixth quotation HTTP `400` is expected controlled rejection, not a stop-line error.

### 4.2 Fixed-Price Bid / Preauthorization / Non-Winning Release

Task:

- taskId: `810cae20-939c-495e-8bc8-5f3a37715fa2`

Observed:

1. two fixed-price bids submitted.
2. both platform service fee authorizations reached `authorized`.
3. award state: `converted_to_order`
4. non-winning release changed count: `1`
5. winner authorization readback: `authorized`
6. loser authorization readback: `authorization_released`

Result:

- `passed`

### 4.3 Contract Charge / Publisher Breach / Factory Refusal

Observed:

Contract charge:

- award state: `converted_to_order`
- publisher contract status: `pending_counterparty`
- factory contract status: `confirmed`
- platform service fee status: `charged`
- final service fee: `2820.00`
- authorization readback: `charged`

Publisher breach:

- changed count: `1`
- authorization readback: `authorization_released`

Factory refusal:

- changed count: `1`
- authorization readback: `breach_hold`
- bid readback: `breach_hold`

Result:

- `passed`

## 5. Message-Building And Read-Only Status Evidence

Execution harness:

- temporary cloud copy: `/tmp/p0_pay_day22_message_readonly_uat.js`
- source script: `infra/scripts/p0_pay_day20_real_account_uat.js`
- evidence file on cloud host: `/tmp/p0_pay_day22_message_readonly_evidence.json`
- real accounts:
  - publisher organization: `e6bf4567-016e-45f9-9420-9c950237690e`
  - factory organization: `bdfb4523-aeb7-4b56-89a1-992170fb5d98`
- payment channel mode: `other` test-channel callback simulation

Run:

- runId: `uat-day20-1777106145567-4cac72`
- taskId: `b1078b97-ee44-4b75-8c4d-d9a49cb6c46c`
- bidId: `05566f80-7e99-4238-9c16-9a60b97a2d1a`
- authorizationId: `54c4a697-1eb0-4812-9a53-f9ad4ab8e571`
- status: `passed`
- blockers: `[]`

Observed business chain:

1. fixed-price task create: HTTP `202`, task status `published`, publish gate `passed`
2. fixed bid submit: HTTP `202`, bid status `pending_service_fee_authorization`
3. platform service fee authorization create/init: HTTP `202` / `202`
4. signed callback apply status: `applied`
5. authorization readback: `authorized`
6. award state: `converted_to_order`
7. dual contract confirmation final status: `confirmed`
8. platform service fee status: `charged`
9. final fee: `2700.00`

P0-Pay summary readback:

- platformServiceFee.status: `charged`
- finalFeeAmount: `2700.00`
- contractConfirmation.status: `confirmed`
- messageDisplaySummary.readOnly: `true`
- messageDisplaySummary.statusTextKey: `charged`

Message carrier DB readback:

- bidPrivateThreads: `1`
- bidThreadMessages: `1`
- projectCommunicationThreads: `0`

Publisher message index:

- itemCount: `1`
- containsTask: `true`
- itemP0PayStatus: `charged`
- itemReadOnly: `true`

Factory message index:

- itemCount: `1`
- containsTask: `true`
- itemP0PayStatus: `charged`
- itemReadOnly: `true`

Result:

- `passed`

Interpretation:

- messages building continues to act as read-only information center.
- It does not execute payment, create payment truth, modify payment state, judge deduction, or handle guarantee deposit.

## 6. Callback And Audit Observation

Callback-event query:

- gray run callback events:
  - runId: `p0pay-1777106113801-e68d25`
  - verificationStatus: `verified`
  - applyStatus: `applied`
  - count: `6`
- message-readonly run callback events:
  - runId: `uat-day20-1777106145567-4cac72`
  - verificationStatus: `verified`
  - applyStatus: `applied`
  - count: `1`

Duplicate callback observation:

- source runId: `p0pay-1777106113801-e68d25`
- sourceCallbackEventId: `e540ff88-756e-4ead-bcd4-5a55a47d6b74`
- response status: HTTP `202`
- duplicate: `true`
- applyStatus: `duplicate`
- verificationStatus: `verified`
- callback row count before: `1`
- callback row count after: `1`

Result:

- duplicate callback did not double apply.
- callback idempotency observation: `passed`

Audit-log query:

Gray run recorded expected P0-Pay audit actions including:

- `TradeTaskCreated`
- `InquiryDepositOrderCreated`
- `PaymentChannelInitIssued`
- `PaymentCallbackVerified`
- `InquiryDepositPaid`
- `InquiryTaskPublishedAfterDepositPaid`
- `PlatformServiceFeePreauthorizationCreated`
- `PlatformServiceFeePreauthorizationInit`
- `PlatformServiceFeePreauthorizationAuthorized`
- `BidAwarded`
- `PlatformServiceFeePreauthorizationReleased`
- `ContractConfirmationSubmitted`
- `PlatformServiceFeeCharged`
- `P0PayPublisherBreachMarked`
- `P0PayFactoryRefusalMarked`

Message-readonly run recorded expected P0-Pay audit actions including:

- `TradeTaskCreated`
- `PlatformServiceFeePreauthorizationCreated`
- `PlatformServiceFeePreauthorizationInit`
- `PaymentCallbackVerified`
- `PlatformServiceFeePreauthorizationAuthorized`
- `BidAwarded`
- `PlatformServiceFeeAuthorizationMovedToContractPending`
- `ContractConfirmationSubmitted`
- `PlatformServiceFeeCharged`

Result:

- audit observation: `passed`

## 7. Post-Observation Health

Post-observation active status:

- `exhibition-server`: `active`
- `exhibition-bff`: `active`

Post-observation route smoke:

- `200 / 401 / 400 / 400`

Stop-line log scan:

- no `fatal`
- no `exception`
- no `uncaught`
- no `duplicate key`
- no P0-Pay route-level `404`
- no `Cannot GET /api/app/exhibition/trade-tasks`

Expected controlled error:

- The sixth inquiry quotation generated an expected BFF upstream HTTP `400`.
- This is the frozen seat-limit behavior and not a stop-line finding.

## 8. Stop-Line Result

Stop lines checked:

1. payment state mismatch between Server DB and BFF projection: `not observed`
2. duplicate callback double-apply: `not observed`
3. route-level `404` for P0-Pay route family: `not observed`
4. missing audit row for payment state transition: `not observed`
5. message-building mutation or judgment of money state: `not observed`
6. real-money provider redirect or capture: `not observed`

Stop-line result:

- `none`

## 9. Retained No-Go List

Still blocked:

1. public production release
2. real-money Alipay / WeChat payment trial
3. real payment-provider settlement
4. invoice / finance-admin / payout
5. payment-account binding
6. wallet / balance / coins / fund pool
7. P1 guarantee-deposit implementation
8. guarantee-deposit dispute, artificial processing, or lawyer assist
9. broad non-whitelisted traffic exposure

## 10. Final Result

The current P0-Pay Day22 controlled gray observation result is:

```text
CONTROLLED GRAY DAY-1 OBSERVATION CLOSED
P0-PAY P0 TEST-CHANNEL BUSINESS LOOP PASSED
MESSAGE-BUILDING READ-ONLY CARRY PASSED
CALLBACK IDEMPOTENCY OBSERVED AND PASSED
NO STOP-LINE FINDINGS
NO-GO FOR PUBLIC PRODUCTION / REAL-MONEY PAYMENT
```

Final ruling:

- P0-Pay P0 controlled gray observation is complete.
- The P0 business loop may remain in controlled gray under Day21 constraints.
- Any next move toward real Alipay / WeChat or broader production exposure requires a new independent release gate.
