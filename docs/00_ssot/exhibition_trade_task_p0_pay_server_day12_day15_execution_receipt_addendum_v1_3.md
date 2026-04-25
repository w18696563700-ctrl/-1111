# Exhibition Trade Task P0-Pay Server Day12-Day15 Execution Receipt Addendum V1.3

status: execution_receipt
freeze_date_local: 2026-05-09
actual_authoring_date_local: 2026-04-24
owner: Codex Control
scope: Server only

## 0. Conclusion

2026-05-06 through 2026-05-09 Server scope is completed locally:

1. Inquiry quote task sincerity-money order creation, pay-init, readback, idempotency, and audit skeleton are implemented.
2. Payment-channel adapter skeleton, callback signature verification, callback event persistence, duplicate handling, and verified callback application are implemented.
3. Contract confirmation and post-contract-confirm platform service fee charge truth are implemented in `p0_pay`, without reusing the old `/server/contract/confirm` path as a payment trigger.
4. Server integration regression for migration truth, callback signature boundary, fixed 200 CNY sincerity money, no account binding, and no wallet/guarantee state passed.

## 1. Implemented Server Files

- `apps/server/src/modules/p0_pay/p0-pay-inquiry-deposit.service.ts`
- `apps/server/src/modules/p0_pay/p0-pay-payment-channel.service.ts`
- `apps/server/src/modules/p0_pay/p0-pay-callback.service.ts`
- `apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts`
- `apps/server/src/modules/p0_pay/entities/contract-confirmation.entity.ts`
- `apps/server/src/modules/p0_pay/entities/platform-service-fee-charge.entity.ts`
- `apps/server/src/modules/p0_pay/**` supporting parser, presenter, types, entities, and module wiring
- `apps/server/src/core/migrations/migrations.ts`
- `apps/server/test/p0-pay-server-mainline.test.cjs`

## 2. Server Routes Added

- `POST /server/exhibition/trade-tasks/:taskId/inquiry-deposit/orders`
- `POST /server/exhibition/trade-tasks/:taskId/inquiry-deposit/orders/:depositOrderId/pay-init`
- `GET /server/exhibition/trade-tasks/:taskId/inquiry-deposit/orders/:depositOrderId`
- `POST /server/exhibition/p0-pay/payment-callbacks/:paymentChannel`
- `POST /server/exhibition/trade-tasks/:taskId/contract-confirmations`

## 3. Persistence Expanded

Added or expanded:

- `inquiry_quote_deposits`
- `payment_orders`
- `payment_transactions`
- `payment_callback_events`
- `contract_confirmations`
- `platform_service_fee_charges`
- `payment_idempotency_records`

## 4. Boundary Decisions

More stable:

- P0-Pay owns contract confirmation and service-fee charge truth in a dedicated module.
- Existing `BidAward -> Order -> Contract seed` is treated as bridge evidence only.

Lower cost:

- Existing `ProjectEntity`, `BidEntity`, and `BidAwardTruthCarrier` are reused as anchors instead of introducing a full `TradeTask` rewrite in this slice.

Best fit for current phase:

- Order-level pay-init and callback truth, without wallet, account binding, settlement, invoice, or guarantee deposit.

Higher risk and therefore not done:

- Modifying `trading_shell_handoff` contract confirm into a payment trigger.
- Expanding `payment_billing` into execution payment truth.
- Letting BFF or Flutter own callback, charge, or funds truth.

## 5. Verification

Passed:

- `npm run build` in `apps/server`
- `node --test test/p0-pay-calculator-idempotency.test.cjs` in `apps/server`
- `node --test test/p0-pay-server-mainline.test.cjs` in `apps/server`
- `node --test test/bid-submit.test.cjs` in `apps/server`
- `node --test test/runtime-startup-guard.test.cjs` in `apps/server`

Not executed in this receipt:

- Aliyun cloud deployment.
- Real Alipay / WeChat SDK call.
- BFF forwarding.
- Flutter consumption.
- Tunnel smoke through `127.0.0.1:8080`.
- Computer Use UI联调.

## 6. Remaining Gates

Next allowed work:

1. BFF forwarding for inquiry deposit, callback-status read shaping, contract confirmation, and P0-Pay summary.
2. Flutter consumption and polling UI.
3. Cloud deployment, tunnel smoke, and Computer Use联调.

Still blocked:

1. P1履约保证金实缴、冻结、扣除、释放、争议协商、人工处理、律师协助.
2. Wallet, balance, coins, fund pool, generic payment center, settlement, invoice, finance-admin.
3. Platform-side user payment account binding.
