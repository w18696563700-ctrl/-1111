---
owner: Codex 总控
status: frozen
layer: L0 execution receipt
scheduled_day: 2026-05-28
execution_recorded_at_local: 2026-04-25
purpose: Record the BFF and Flutter execution receipt for counterpart-conversation ProjectOrder business cards.
---

# Project Transaction Lifecycle Day28 Counterpart Order Card Execution Receipt

## 1. Scope

This receipt covers the bounded Day28 BFF + Flutter work:

- Messages list accepts `summary.latestCardType = project_order`.
- Counterpart conversation detail accepts `projectGroups[].cards[].cardType = project_order`.
- BFF validates `project_order` cards and their `projectId/orderId` anchors.
- BFF derives a display-only `project_order` card when Server returns an order anchor through `orderSummary`, `order`, or group-level `orderId`.
- Flutter renders the order business card in the existing project-group section.
- Flutter opens the existing order detail route through `order_detail.open`.

No new order thread, message-owned order state, Server truth change, cloud release, or production acceptance is claimed.

## 2. Frozen Truth Applied

The work follows:

- `docs/00_ssot/counterpart_conversation_project_order_card_day28_freeze_addendum.md`
- `docs/00_ssot/project_transaction_lifecycle_route_table_addendum.md`
- `docs/00_ssot/project_transaction_lifecycle_field_table_addendum.md`

The active rule remains:

- one messages entry
- one counterpart container
- project groups stay split by `projectId`
- order actions stay anchored to `ProjectOrder` through `orderId`

## 3. Implementation Summary

BFF:

- Added `project_order` to counterpart list/detail card-type validation.
- Added `project_order` to truth-anchor validation.
- Added `order_detail.open` as an allowed counterpart detail handoff.
- Added `orderSummary` read shaping for project groups.
- Added fail-closed checks for `project_order` card and route target anchor mismatch.

Flutter:

- Added `orderId` to counterpart truth-anchor model.
- Added `project_order` to counterpart list and detail parsers.
- Registered `order_detail.open` with required `projectId + orderId`.
- Added order card labels, icon, status labels, and fallback route handling.
- Added messages-list chip copy for latest business-card type.

## 4. Verification

Commands executed:

```bash
cd apps/bff && node --test test/message-interaction-transport.test.cjs
```

Result: passed, `8/8`.

```bash
cd apps/bff && npm run build
```

Result: passed.

```bash
cd apps/mobile && flutter test test/messages_instance_todo_test.dart
```

Result: passed, `8/8`.

```bash
cd apps/mobile && flutter test test/counterpart_conversation_chat_test.dart
```

Result: passed, `12/12`.

```bash
cd apps/mobile && flutter test test/bid_award_bridge_test.dart
```

Result: passed, `5/5`.

## 5. Gate Checklist

| Gate | Result | Notes |
|---|---:|---|
| Unified messages entry | Pass | Still `counterpart_conversation.open`. |
| Project boundary | Pass | `projectId` remains required for order card route targets. |
| Order truth boundary | Pass | Order detail and completion actions remain existing `ProjectOrder` routes. |
| BFF no second state machine | Pass | BFF only validates/shapes from Server-provided anchors. |
| Flutter BFF-only rule | Pass | Flutter opens `/api/app/order/detail` through registered route, no `/server/*`. |
| Local regression | Pass | Targeted BFF and Flutter tests passed. |
| Aliyun BFF/Server release | Not claimed | This receipt only records local source and local tests. |
| Dual-account UAT | Not claimed | Requires tunnel login and active cloud runtime carrying order anchors. |

## 6. Remaining Production Gates

Production acceptance still requires:

- Aliyun Server/BFF active runtime exposes counterpart detail with either `projectGroups[].cards[].cardType = project_order` or `projectGroups[].orderSummary`.
- Tunnel smoke verifies `GET /api/app/message/interactions` can return `latestCardType = project_order` under login.
- Tunnel smoke verifies `GET /api/app/message/counterpart-conversation/detail` returns a project group with `projectId/orderId`.
- Dual-account Computer Use verifies the publisher and contractor both enter the same counterpart conversation and open the order card.
- Seller completion request and buyer completion confirm still pass after entering through the order card.

## 7. Decision

Day28 local BFF + Flutter implementation is complete.

Go for:

- Aliyun BFF/Server runtime alignment.
- Dual-account tunnel UAT after active cloud routes expose the order anchors.

No-Go for:

- production completion claim from local tests alone.
- creating a separate order conversation or merged order state in messages.
