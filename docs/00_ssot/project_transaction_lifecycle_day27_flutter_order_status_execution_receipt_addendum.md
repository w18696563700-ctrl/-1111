---
owner: Codex 总控
status: frozen
layer: L0 execution receipt
scheduled_day: 2026-05-27
execution_recorded_at_local: 2026-04-25
purpose: Record the Flutter implementation receipt for project/detail and conversation order status cards plus role-scoped completion actions.
---

# Project Transaction Lifecycle Day27 Flutter Order Status Execution Receipt

## 1. Scope

This receipt covers only the Flutter layer for the frozen project transaction lifecycle.

- Project detail consumes `orderSummary / order / orderId` in addition to `bidSelection.orderId`.
- Counterpart conversation project groups consume `orderSummary` independently from `ratingEntry`.
- `OrderStatusCard` remains the shared UI for project detail, counterpart conversation, and order detail.
- Seller-side UI exposes `申请完工` and submits `POST /api/app/order/complete/request`.
- Buyer-side UI exposes `确认完成 / 拒绝完工` and submits `POST /api/app/order/complete/confirm` or `POST /api/app/order/complete/reject`.

No Server truth, BFF route implementation, cloud deployment, production acceptance, or dual-account UAT is claimed by this receipt.

## 2. Stable Consumption Model

### 2.1 Project Detail

Flutter now keeps the following optional order anchors from `GET /api/app/project/detail`:

- `orderSummary.orderId`
- `order.orderId`
- top-level `orderId`
- fallback `bidSelection.orderId`

This prevents project detail from depending only on the bid-selection response carrier.

### 2.2 Counterpart Conversation

`CounterpartConversationProjectGroupView` now includes:

- `orderSummary.orderId`
- `orderSummary.projectId`
- `orderSummary.buyerOrganizationId`
- `orderSummary.sellerOrganizationId`
- `orderSummary.state`
- `orderSummary.completionRequestState`

The conversation page uses `group.orderSummary?.orderId ?? group.ratingEntry?.orderId`.

This removes the previous hidden coupling where an order status card only appeared after `ratingEntry` existed. That coupling was unsafe because unfinished orders do not necessarily have a rating entry.

## 3. Boundary Ruling

- Flutter does not create or mutate `ProjectOrder` truth directly.
- Flutter does not infer completion eligibility beyond role-specific button display.
- Final acceptance/rejection still belongs to Server `ProjectOrder` state machine.
- BFF remains the only app-facing layer; Flutter only consumes canonical BFF routes.
- Rating entry remains downstream of completed order and is not reused as the order-status anchor.

## 4. Implementation Files

- `apps/mobile/lib/features/messages/data/counterpart_conversation_models.dart`
- `apps/mobile/lib/features/messages/data/counterpart_conversation_parser.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
- `apps/mobile/test/counterpart_conversation_chat_test.dart`
- `apps/mobile/test/bid_award_bridge_test.dart`

Related pre-existing Day27 surface files verified:

- `apps/mobile/lib/features/exhibition/presentation/presentation_support/order_status_card.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/order_detail_page.dart`

## 5. Verification

Project detail seller completion request:

```bash
flutter test test/bid_award_bridge_test.dart --name "project detail order status card lets seller request completion from orderSummary"
```

Result: passed.

Counterpart conversation buyer/seller role actions:

```bash
flutter test test/counterpart_conversation_chat_test.dart --name "conversation order summary"
```

Result: `2` tests passed.

Related full regressions:

```bash
flutter test test/bid_award_bridge_test.dart
flutter test test/counterpart_conversation_chat_test.dart
```

Result:

- `bid_award_bridge_test.dart`: `5` tests passed.
- `counterpart_conversation_chat_test.dart`: `11` tests passed.

## 6. Gate Checklist

| Gate | Result | Notes |
|---|---:|---|
| Project detail order card | Pass | Uses `orderSummary/order/orderId/bidSelection` anchors. |
| Conversation order card | Pass | Uses `orderSummary` before fallback `ratingEntry`. |
| Seller action | Pass | Seller sees and submits `申请完工`. |
| Buyer action | Pass | Buyer sees and submits `确认完成`; reject route is wired by shared card. |
| Flutter owns no order truth | Pass | Server remains state-machine owner. |
| Local Flutter tests | Pass | Target and related regressions passed. |
| Cloud route smoke | Not claimed | Requires Aliyun BFF/Server deployment alignment and tunnel login. |
| Dual-account UAT | Not claimed | Requires real publisher and contractor accounts. |

## 7. Residual Engineering Note

`counterpart_conversation_page.dart` is already above the default handwritten file warning/limit and should be split in a separate refactor gate. The Day27 change did not introduce a new business truth owner, but future edits should move project-group rendering and order-card mounting into support files before adding more behavior.

## 8. Next Allowed Stage

Go for cloud route smoke and dual-account UAT after Aliyun BFF/Server are confirmed to expose:

- `GET /api/app/project/detail` with an order anchor after selection
- `GET /api/app/message/counterpart-conversation/detail` with `projectGroups[].orderSummary`
- `GET /api/app/order/detail`
- `POST /api/app/order/complete/request`
- `POST /api/app/order/complete/confirm`
- `POST /api/app/order/complete/reject`

Production acceptance remains blocked until a real seller requests completion and a real buyer confirms completion through the tunnel.
