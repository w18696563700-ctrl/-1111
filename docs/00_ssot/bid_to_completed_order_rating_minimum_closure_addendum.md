---
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-04-25
purpose: >
  Freeze the minimum product path that turns a published exhibition project
  into an order-completed, counterparty-rating-eligible project without
  expanding into payment, settlement, full inspection governance, or dispute.
---

# Bid -> Completed Order -> Counterparty Rating Minimum Closure

## 1. Current Judgment

- If the App only shows the project as `published / 竞标中`, the project has not
  entered the order truth chain.
- Counterparty rating must remain blocked while the order truth is not
  `completed`.
- The next product gap is therefore not a rating button gap. It is the missing
  minimum path from bid award to completed order.

## 2. Minimum Closed Loop

The current round admits only this path:

1. Project owner awards one submitted bid.
2. Server writes `BidAward` truth and synchronously creates:
   - `Order.state = active`
   - `Contract.state = pending_confirm`
   - one default `Milestone.state = pending_submission`
   - one default `Inspection.state = draft`
3. Supplier submits the default milestone.
4. Buyer submits the inspection when appropriate.
5. Buyer passes the submitted inspection.
6. Server synchronously derives:
   - `Inspection.state = passed`
   - `Milestone.state = completed`
   - `Order.state = completed`
7. `ProjectCounterpartyRating` entry becomes eligible through existing
   `orderId / projectId / rater / ratee` truth.

## 3. Allowed App-Facing Routes

- Existing routes remain valid:
  - `POST /api/app/bid/award`
  - `GET /api/app/order/detail`
  - `GET /api/app/contract/detail`
  - `GET /api/app/milestone/list`
  - `POST /api/app/milestone/submit`
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`
  - `GET /api/app/project-counterparty-rating/entry`
  - `POST /api/app/project-counterparty-rating/submit`
- New route admitted in this round:
  - `POST /api/app/inspection/pass`

## 4. Truth Ownership

- `Server` remains the only business truth owner.
- `BFF` may only forward, shape, normalize errors, and preserve auth context.
- `Flutter App` may expose the continuation entry and render accepted results.
- `Flutter App` must not locally derive `order.completed` or `rating eligible`.

## 5. State Rules

- `BidAward` is valid only while project is `published`.
- `Milestone.submit` may move only:
  - `pending_submission -> submitted`
- `Inspection.submit` may move only:
  - `draft -> submitted`
- `Inspection.pass` may move only:
  - `submitted -> passed`
- `Order.completed` may be derived only after all current milestones under the
  order are completed.
- Repeated `inspection.pass` against an already passed inspection is idempotent
  and must not append duplicate completion changes.

## 6. Non-Goals

- No payment, billing, settlement, tax, or split-billing.
- No electronic signature.
- No full compare console.
- No full inspection matrix, reject, rectification, or recheck expansion.
- No dispute opening or governance escalation.
- No second order state machine in BFF or Flutter.
- No direct database state shortcut for acceptance.

## 7. Stage Gate

- `Go` for bounded Server/BFF/Flutter implementation of this path.
- `No-Go` for direct production data mutation outside the routes above.
- `No-Go` for claiming cloud acceptance until the route is deployed and verified
  with both buyer and supplier logged in.
