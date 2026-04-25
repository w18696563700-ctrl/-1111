---
owner: Codex 总控
status: frozen
layer: L0 execution receipt
scheduled_day: 2026-05-25
execution_recorded_at_local: 2026-04-25
purpose: Record the BFF implementation receipt for app-facing bid selection, order detail carry, and order completion actions.
---

# Project Transaction Lifecycle Day25 BFF Execution Receipt

## 1. Scope

This receipt covers only the BFF layer for the frozen project transaction lifecycle.

- BFF app-facing route added: `POST /api/app/bid/select-bid-and-create-order`.
- BFF upstream target: `POST /server/bid/select-bid-and-create-order`.
- Existing BFF app-facing order detail route retained and verified: `GET /api/app/order/detail`.
- BFF app-facing order completion routes added:
  - `POST /api/app/order/complete/request`
  - `POST /api/app/order/complete/confirm`
  - `POST /api/app/order/complete/reject`
- BFF upstream targets:
  - `POST /server/order/complete/request`
  - `POST /server/order/complete/confirm`
  - `POST /server/order/complete/reject`

No Server truth, migration, cloud release, Flutter implementation, or production acceptance is claimed by this receipt.

## 2. BFF DTO / Read Model

### 2.1 Select Bid And Create Order

`BidSelectAndCreateOrderAcceptedResponse` exposes the Server award/order-conversion carrier plus navigation handoff:

- `bidAwardId`
- `projectId`
- `winningBidId`
- `orderId`
- `contractId`
- `state = converted_to_order`
- `actionKey = bid_select_create_order.submit`
- `routeTarget.objectType = order`
- `routeTarget.actionKey = order_detail.open`
- `routeTarget.canonicalPath = /api/app/order/detail`
- `routeTarget.params = orderId / projectId / winningBidId / bidAwardId / contractId`

### 2.2 Order Completion

`OrderCompletionAcceptedResponse` exposes only the Server completion carrier plus navigation handoff:

- `orderId`
- `projectId`
- `state = active / completed`
- `completionRequestState = requested / confirmed / rejected / dispute_reserved`
- `summary`
- `actionKey = order_completion_request.submit / order_completion_confirm.submit / order_completion_reject.submit`
- `routeTarget.objectType = order`
- `routeTarget.actionKey = order_detail.open`
- `routeTarget.canonicalPath = /api/app/order/detail`
- `routeTarget.params = orderId / projectId`

## 3. Boundary Ruling

- BFF does not own `BidAward`, `ProjectOrder`, completion state, rating gate, audit, or any second transaction state machine.
- BFF only normalizes request payloads, forwards auth/org headers, shapes accepted responses, and maps upstream errors to stable app-facing messages.
- `select-bid-and-create-order` requires `projectId / winningBidId / reasonCode / reasonText` because the current Server command reuses the frozen bid-award truth command.
- Order completion request requires `orderId` and may forward `note`.
- Order completion confirm requires only `orderId`.
- Order completion reject requires `orderId` and may forward `reason / reserveDispute`.

## 4. Implementation Files

- `apps/bff/src/routes/bid/app-bid-order-selection.controller.ts`
- `apps/bff/src/routes/bid/bid-order-selection.service.ts`
- `apps/bff/src/routes/bid/bid-order-selection.read-model.ts`
- `apps/bff/src/routes/bid/bid-order-selection.error.ts`
- `apps/bff/src/routes/bid/bid.module.ts`
- `apps/bff/src/routes/order/app-order-completion.controller.ts`
- `apps/bff/src/routes/order/order-completion.service.ts`
- `apps/bff/src/routes/order/order-completion.read-model.ts`
- `apps/bff/src/routes/order/order-completion.error.service.ts`
- `apps/bff/src/routes/order/order.module.ts`
- `apps/bff/src/routes/routes.module.ts`
- `apps/bff/test/bid-select-create-order-transport.test.cjs`
- `apps/bff/test/project-order-completion-transport.test.cjs`

## 5. Verification

Build:

```bash
npm --prefix apps/bff run build
```

Result: passed.

Target route tests:

```bash
node --test apps/bff/test/bid-select-create-order-transport.test.cjs apps/bff/test/project-order-completion-transport.test.cjs apps/bff/test/trading-read-corridor-order-contract.test.cjs
```

Result: `12` tests passed.

Related transaction BFF regression:

```bash
node --test apps/bff/test/bid-result-error-mapping.test.cjs apps/bff/test/bid-select-create-order-transport.test.cjs apps/bff/test/project-order-completion-transport.test.cjs apps/bff/test/trading-read-corridor-order-contract.test.cjs apps/bff/test/trading-read-corridor-milestone-inspection.test.cjs apps/bff/test/trading-shell-handoff-submit-error-cleanup.test.cjs
```

Result: `37` tests passed.

## 6. Gate Checklist

| Gate | Result | Notes |
|---|---:|---|
| BFF route implementation | Pass | App-facing route family is locally wired. |
| BFF DTO/read-model | Pass | Accepted responses carry frozen `routeTarget/actionKey`. |
| BFF owns no truth | Pass | Server remains truth owner for bid selection and order completion. |
| Existing order detail route | Pass | `GET /api/app/order/detail` retained and tested. |
| Local build | Pass | BFF build passed. |
| Target BFF tests | Pass | Target and related transaction tests passed. |
| Cloud release | Not claimed | No Aliyun BFF deployment was requested or performed. |
| Dual-account UAT | Not claimed | Requires cloud route alignment and logged-in actor execution. |

## 7. Next Allowed Stage

Go for the next bounded BFF/Flutter consumption stage only after the operator confirms whether to deploy the BFF package to Aliyun. Production acceptance remains blocked until cloud route smoke and dual-account transaction UAT pass.
