# Exhibition Trade Task P0-Pay Server Day10-Day11 Execution Receipt Addendum V1.3

status: execution_receipt
freeze_date_local: 2026-05-05
actual_authoring_date_local: 2026-04-24
owner: Codex Control
scope: Server only

## 0. Conclusion

2026-05-04 and 2026-05-05 Server scope is completed locally:

1. P0-Pay payment execution domain is implemented as a new `p0_pay` Server module.
2. Payment base models, migrations, idempotency carrier, callback carrier, transaction carrier, and audit writer skeleton are in place.
3. Fixed-price bid platform service fee authorization create/read/authorize-init Server routes are in place.
4. No wallet, balance, coins, guarantee deposit, settlement, invoice, or platform fund pool was introduced.
5. Existing `payment_billing` remains a profile read-only payment/billing status module and was not converted into payment execution truth.

## 1. Implemented Server Files

- `apps/server/src/modules/p0_pay/**`
- `apps/server/src/core/migrations/migrations.ts`
- `apps/server/src/app.module.ts`
- `apps/server/test/p0-pay-calculator-idempotency.test.cjs`

## 2. Server Routes Added

- `POST /server/exhibition/trade-tasks/:taskId/fixed-price-bids/:bidId/service-fee-authorizations`
- `POST /server/exhibition/trade-tasks/:taskId/fixed-price-bids/:bidId/service-fee-authorizations/:authorizationId/authorize-init`
- `GET /server/exhibition/trade-tasks/:taskId/fixed-price-bids/:bidId/service-fee-authorizations/:authorizationId`

## 3. Persistence Added

- `platform_service_fee_authorizations`
- `inquiry_quote_deposits`
- `payment_orders`
- `payment_transactions`
- `payment_callback_events`
- `payment_idempotency_records`

## 4. Boundary Decisions

More stable:

- New `p0_pay` execution module with its own tables and state skeleton.

Lower cost:

- Reusing existing `BidEntity` and `ProjectEntity` as the temporary fixed-price bid/task anchor for this Server slice.

Best fit for current phase:

- Order-level authorization and idempotency skeleton without binding user Alipay, WeChat, or bank accounts.

Higher risk and therefore not done:

- Expanding `payment_billing` into execution payment truth.
- Adding wallet, balance, settlement, invoice, or履约保证金冻结.
- Treating BFF or Flutter as the source of funds truth.

## 5. Verification

Passed:

- `npm run build` in `apps/server`
- `node --test test/p0-pay-calculator-idempotency.test.cjs` in `apps/server`
- `node --test test/bid-submit.test.cjs` in `apps/server`
- `node --test test/runtime-startup-guard.test.cjs` in `apps/server`

Not executed in this receipt:

- Aliyun cloud deployment.
- Payment channel SDK integration.
- BFF forwarding.
- Flutter consumption.
- Computer-use browser integration.

## 6. Remaining Gates

Next allowed work:

1. BFF forwarding and response shaping for the Server routes above.
2. Payment channel adapter design and callback verification.
3. Cloud deployment and tunnel smoke through `127.0.0.1:8080`.

Still blocked:

1. P1履约保证金实缴、冻结、扣除、释放、争议协商、人工处理、律师协助.
2. Wallet, balance, coins, fund pool, settlement, invoice.
3. Platform-side payment account binding.
