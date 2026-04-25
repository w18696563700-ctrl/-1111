# Exhibition Trade Task P0-Pay BFF Day16-Day17 Execution Receipt Addendum V1.3

status: execution_receipt
freeze_date_local: 2026-05-11
actual_authoring_date_local: 2026-04-24
owner: Codex Control
scope: BFF only

## 0. Conclusion

2026-05-10 and 2026-05-11 BFF scope is completed locally:

1. P0-Pay app-facing route family is implemented under `/api/app/exhibition/trade-tasks*`.
2. Request shaping uses contract field allowlists, basic type/enum validation, and `idempotencyKey` forwarding.
3. BFF forwards to Server-owned `/server/exhibition/trade-tasks*` P0-Pay routes and does not create payment truth.
4. Error mapping normalizes route drift, auth, forbidden, conflict, channel unavailable, and summary unavailable states without returning empty success.
5. Task detail and message-building payment status are read-only projections; `messageDisplaySummary.readOnly` is forced to `true`.

## 1. Implemented BFF Files

- `apps/bff/src/routes/exhibition_p0_pay/app-exhibition-p0-pay.controller.ts`
- `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.service.ts`
- `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay-payload.service.ts`
- `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model.ts`
- `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay-error.service.ts`
- `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.module.ts`
- `apps/bff/src/routes/routes.module.ts`
- `apps/bff/test/exhibition-p0-pay-transport.test.cjs`

## 2. App-facing Routes Added

- `POST /api/app/exhibition/trade-tasks`
- `GET /api/app/exhibition/trade-tasks/:taskId`
- `POST /api/app/exhibition/trade-tasks/:taskId/authenticity-materials`
- `POST /api/app/exhibition/trade-tasks/:taskId/fixed-price-bids`
- `POST /api/app/exhibition/trade-tasks/:taskId/fixed-price-bids/:bidId/service-fee-authorizations`
- `POST /api/app/exhibition/trade-tasks/:taskId/fixed-price-bids/:bidId/service-fee-authorizations/:authorizationId/authorize-init`
- `GET /api/app/exhibition/trade-tasks/:taskId/fixed-price-bids/:bidId/service-fee-authorizations/:authorizationId`
- `POST /api/app/exhibition/trade-tasks/:taskId/inquiry-deposit/orders`
- `POST /api/app/exhibition/trade-tasks/:taskId/inquiry-deposit/orders/:depositOrderId/pay-init`
- `GET /api/app/exhibition/trade-tasks/:taskId/inquiry-deposit/orders/:depositOrderId`
- `POST /api/app/exhibition/trade-tasks/:taskId/inquiry-quotations`
- `POST /api/app/exhibition/trade-tasks/:taskId/inquiry-result`
- `POST /api/app/exhibition/trade-tasks/:taskId/contract-confirmations`
- `GET /api/app/exhibition/trade-tasks/:taskId/p0-pay-summary`

No `/api/app/payment/*`, wallet, balance, settlement, invoice, guarantee-deposit, or payment callback route was added.

## 3. Boundary Decisions

More stable:

- A dedicated `exhibition_p0_pay` BFF module was added instead of extending `project`, `message_interaction`, `profile`, or `trading_read_corridor`.
- This keeps P0-Pay forwarding separate from project detail, message center, and billing-status pre-embed concerns.

Lower cost:

- Existing `CoreModule` transport, auth forwarding, and error normalization services are reused.
- No new BFF persistence, cache table, payment adapter, callback listener, or state machine was introduced.

Best fit for current phase:

- BFF only exposes app-facing P0-Pay surfaces, shapes payloads, forwards idempotency as a carrier, and reads Server-derived summaries.

Higher risk and therefore not done:

- Letting BFF own payment order state, fee calculation truth, callback truth, message-building payment execution, or dispute judgment.
- Turning the message center into a payment operation console.
- Creating a generic app payment center before the trade-task P0-Pay route family is proven.

## 4. Read-only Aggregation

Task detail shaping:

- `p0PaySummary.readOnly` is forced to `true`.
- Only the frozen task-detail payment-summary fields are exposed.

Message-building shaping:

- `messageDisplaySummary.readOnly` is forced to `true`.
- The BFF response only keeps `displayAllowed`, `readOnly`, `statusTextKey`, and `routeTarget`.
- Payment execution actions, deduction judgment actions, and guarantee-deposit actions are not emitted by this BFF projection.

Truth boundary:

- The BFF summary route reads Server-owned `GET /server/exhibition/trade-tasks/:taskId/p0-pay-summary`.
- If the Server route is missing, BFF returns controlled `P0_PAY_SUMMARY_UNAVAILABLE` instead of a fake empty success.

## 5. Verification

Passed locally:

- `node --test apps/bff/test/exhibition-p0-pay-transport.test.cjs`
- `node --test apps/bff/test/message-interaction-transport.test.cjs`
- `npm run build` in `apps/bff`

Not executed in this receipt:

- Aliyun BFF deployment.
- Aliyun Server deployment.
- Real Alipay / WeChat SDK call.
- Tunnel smoke through `127.0.0.1:8080`.
- Computer Use UI 联调.

## 6. Remaining Gates

Next allowed work:

1. Cloud BFF runtime alignment for the new `/api/app/exhibition/trade-tasks*` route family.
2. Cloud Server runtime alignment for `GET /server/exhibition/trade-tasks/:taskId/p0-pay-summary`.
3. Flutter consumption for task detail, message-building read-only status, pay-init handoff, and polling.
4. Tunnel curl smoke after BFF and Server runtime both align.

Still blocked:

1. P1 履约保证金实缴、冻结、扣除、释放、争议协商、人工处理、律师协助.
2. Wallet, balance, coins, fund pool, settlement, invoice, finance-admin.
3. Platform-side user payment account binding.
4. BFF payment callback endpoint or payment-channel provider logic.
