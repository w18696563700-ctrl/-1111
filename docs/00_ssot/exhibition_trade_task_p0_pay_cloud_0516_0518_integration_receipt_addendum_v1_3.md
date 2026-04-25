# Exhibition Trade Task P0-Pay Cloud 05-16 To 05-18 Integration Receipt Addendum V1.3

status: cloud_integration_receipt
planned_gate_dates: 2026-05-16, 2026-05-17, 2026-05-18
actual_execution_date_local: 2026-04-25
owner: Codex Control
scope: Aliyun active BFF/Server runtime, P0-Pay business-chain integration

## 0. Conclusion

The planned 2026-05-16, 2026-05-17, and 2026-05-18 P0-Pay cloud integration gates were executed early on 2026-04-25 against the Aliyun active runtime and all three business chains passed.

Go decision:

1. 2026-05-16 inquiry quote / sincerity money / quote seats / refund-return chain: `passed`.
2. 2026-05-17 fixed-price bid / platform service fee preauthorization / non-winning release chain: `passed`.
3. 2026-05-18 contract-confirm charge / publisher-breach release / factory-refusal breach hold chain: `passed`.

This receipt authorizes entry into the next UAT-prep gate. It does not authorize production release, real-money trial, wallet, balance, settlement, invoice, account binding, or P1 guarantee-deposit work.

## 1. Active Runtime

Server:

- active release: `/srv/releases/server/20260425121535-p0-pay-fulfillment-no-fix`
- rollback target: `/srv/releases/server/20260425121100-p0-pay-award-diagnostics`
- process: `exhibition-server`
- status: `active`

BFF:

- active release: `/srv/releases/bff/20260425095803-p0-pay-runtime-alignment`
- process: `exhibition-bff`
- status: `active`

Runtime preconditions:

- `P0_PAY_CALLBACK_SECRET` is present in the Server process environment. The secret value is not recorded in this receipt.
- P0-Pay callbacks were verified through signed `other` channel simulation.
- No Alipay or WeChat real-money channel call was executed.

## 2. Route Gate

Command:

```bash
bash infra/scripts/p0_pay_cloud_route_smoke.sh
```

Result:

- exhibition home ingress baseline: `200`
- trade-task summary route mounted and auth-gated: `401`
- trade-task create route mounted and payload-gated: `400`
- state action route mounted and payload-gated: `400`

Decision:

- Previous route-level `404` blocker is closed.
- 05-16, 05-17, and 05-18 cloud business-chain integration was allowed to run.

## 3. Cloud E2E Harness

Script:

- `infra/scripts/p0_pay_cloud_full_e2e.js`

Harness changes in this receipt:

- Added `P0_PAY_E2E_DAYS` so 05-16, 05-17, and 05-18 can run as isolated cloud threads.
- Each thread creates independent test users, organizations, sessions, projects, bids, quotes, deposits, and authorizations.
- Tokens and payment secrets are not printed.

Execution mode:

- BFF ingress: `http://127.0.0.1/api/app`
- Server callback ingress: `http://127.0.0.1:3001`
- database seeding: direct PostgreSQL seed for test actors only
- payment provider: signed `other` callback simulation

## 4. 2026-05-16 Evidence

Run:

- runId: `p0pay-1777090615064-35ff68`
- taskId: `cd9ce873-950e-4857-b635-5727301b37da`
- depositOrderId: `211c1c02-5030-4c0b-9b04-599ac0ce3ace`

Observed steps:

1. Inquiry task created through BFF: HTTP `202`, task status `draft`, publish gate `payment_required`.
2. Inquiry sincerity-money order created and pay-init executed: HTTP `202`.
3. Signed callback applied: `applied`.
4. Deposit readback: `paid`.
5. Five factories submitted inquiry quotations.
6. Fifth seat readback: `seatLimit=5`, `seatUsed=5`, `seatRemaining=0`, `quoteEntryOpen=false`.
7. Sixth quotation was rejected with HTTP `400`.
8. Publisher selected one quotation: `select_factory`.
9. Deposit after result processing: `refund_pending`, refund status `refund_pending`.

Gate result:

- `passed`

## 5. 2026-05-17 Evidence

Run:

- runId: `p0pay-1777090615085-e1c662`
- taskId: `7ffb011e-91e5-47a7-b85a-8fd5d53635d8`

Observed steps:

1. Fixed-price task created through BFF.
2. Two factories submitted fixed-price bids.
3. Both platform service fee preauthorizations reached `authorized`.
4. Publisher awarded the first bid.
5. Award readback: `converted_to_order`.
6. Non-winning release action changed one authorization.
7. Winner authorization readback: `authorized`.
8. Loser authorization readback: `authorization_released`.

Gate result:

- `passed`

## 6. 2026-05-18 Evidence

Run:

- runId: `p0pay-1777090615215-025aa6`

Observed steps:

Contract-confirm charge:

- award readback: `converted_to_order`
- publisher confirmation readback: `pending_counterparty`
- factory confirmation readback: `confirmed`
- platform service fee status: `charged`
- final platform service fee: `2820.00`
- authorization readback: `charged`

Publisher-breach release:

- release action changed count: `1`
- authorization readback: `authorization_released`

Factory-refusal breach hold:

- hold action changed count: `1`
- authorization readback: `breach_hold`
- bid readback: `breach_hold`

Gate result:

- `passed`

## 7. Blocking Fixes Included

The cloud 05-17 and 05-18 chains were blocked by `award -> order` bridge closure before this receipt. The active Server release includes the following bounded compatibility fixes:

1. Inquiry deposit successful callback publishes the inquiry task after deposit payment is applied.
2. Platform service fee authorization status read is allowed after award, release, charge, or breach hold, while create/init still requires the pre-award submitted state.
3. Bid award now seeds default fulfillment rows compatible with the active cloud `milestones` and `inspections` schemas.
4. Generated `milestone_no` and `inspection_no` values are capped within the active cloud `varchar(32)` limit.
5. `platform_service_fee_authorizations` cloud persistence was aligned with release/refund/breach-hold readback fields by additive columns only.

Verification before cloud run:

- `node --test apps/server/test/p0-pay-calculator-idempotency.test.cjs apps/server/test/p0-pay-server-mainline.test.cjs`
- `corepack pnpm --filter @exhibition/server build`
- `node --check infra/scripts/p0_pay_cloud_full_e2e.js`

## 8. Boundary Confirmation

This cloud integration did not implement or validate:

1. platform wallet
2. platform balance
3. coins
4. fund pool
5. user payment-account binding
6. generic payment center
7. generic billing center
8. settlement
9. invoice
10. P1履约保证金实缴、冻结、释放、扣除、争议协商、人工处理或律师协助
11. Alipay / WeChat real-money provider settlement
12. production release or real-money trial

Message-building and project-detail payment surfaces remain read-only projections and may only read Server/BFF aggregated payment state.

## 9. Next Gate

Allowed next work:

1. UAT 第 1 轮双账号完整链路 preparation and execution.
2. Computer Use UI verification on the cloud-backed app path.
3. UAT issue repair with formal evidence.

Still blocked:

1. production release gate
2. gray release
3. real-money payment trial
4. P1 guarantee-deposit implementation
5. wallet / balance / settlement / invoice expansion
