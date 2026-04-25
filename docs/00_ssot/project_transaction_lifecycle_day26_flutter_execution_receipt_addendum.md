---
owner: Codex 总控
status: frozen
layer: L0 execution receipt
scheduled_day: 2026-05-26
execution_recorded_at_local: 2026-04-25
purpose: Record the Flutter implementation receipt for publisher-side bid selection entry and status display on project detail.
---

# Project Transaction Lifecycle Day26 Flutter Execution Receipt

## 1. Scope

This receipt covers only the Flutter layer for the frozen project transaction lifecycle.

- Project detail now exposes the publisher-only `发布方选择合作方` section.
- The section consumes BFF-projected `bidCandidates` and `bidSelection`.
- The selection action posts to the frozen BFF route `POST /api/app/bid/select-bid-and-create-order`.
- The confirmation sheet submits `projectId / winningBidId / reasonCode / reasonText`.
- The accepted result displays order/contract carry and refreshes project detail plus my-project list.

No Server truth, BFF route implementation, cloud release, production acceptance, or dual-account UAT is claimed by this receipt.

## 2. Flutter Consumption Contract

### 2.1 Project Detail Projection

`GET /api/app/project/detail` may include the following display-only fields for owner surfaces:

- `bidCandidates[]`
- `bidCandidates[].bidId`
- `bidCandidates[].bidNo`
- `bidCandidates[].bidderOrganizationId`
- `bidCandidates[].bidderOrganizationName`
- `bidCandidates[].quoteAmount`
- `bidCandidates[].proposalSummary`
- `bidCandidates[].state`
- `bidCandidates[].submittedAt`
- `bidSelection`
- `bidSelection.winningBidId`
- `bidSelection.orderId`
- `bidSelection.contractId`

Flutter does not synthesize bid candidates, winner state, order state, or contract state.

### 2.2 Selection Command

Flutter submits:

- `projectId`
- `winningBidId`
- `reasonCode = publisher_selected_partner`
- `reasonText`

The app-facing canonical path is:

```text
POST /api/app/bid/select-bid-and-create-order
```

The accepted response is consumed as a bid-award/order-conversion carrier and may include:

- `bidAwardId`
- `projectId`
- `winningBidId`
- `orderId`
- `contractId`
- `state = converted_to_order`
- `actionKey`
- `routeTarget`

## 3. Boundary Ruling

- Flutter does not own `BidAward`, `BidSelection`, `ProjectOrder`, audit, or the single-winner invariant.
- Flutter only renders BFF read-model fields and submits the frozen command.
- The owner entry is shown only when `viewerProjectRelation = owner`.
- The select button is enabled only while the project remains in the selectable published state and no `bidSelection.orderId` exists.
- If BFF does not return `bidCandidates`, Flutter shows a controlled empty state instead of fabricating a list.
- Existing legacy `/api/app/bid/award` support remains fallback/compatibility code and is not the Day26 primary entry.

## 4. Implementation Files

- `apps/mobile/lib/features/exhibition/data/commands/bid_award_command.dart`
- `apps/mobile/lib/features/exhibition/data/exhibition_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart`
- `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_validation.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_trade_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_bid_selection_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/project_bid_selection_models.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart`
- `apps/mobile/test/bid_award_bridge_test.dart`

## 5. Verification

Target Day26 test:

```bash
flutter test test/bid_award_bridge_test.dart --name "owner project detail selects one bid candidate through select-bid-and-create-order"
```

Result: passed.

Related bid-award bridge regression:

```bash
flutter test test/bid_award_bridge_test.dart
```

Result: `4` tests passed.

## 6. Gate Checklist

| Gate | Result | Notes |
|---|---:|---|
| Project detail owner entry | Pass | Owner-only selection section is wired into project detail. |
| Bid candidate projection | Pass | `bidCandidates` and `bidSelection` are sanitized and consumed. |
| Confirmation sheet | Pass | Publisher confirms selected bid before submit. |
| BFF route consumption | Pass | Flutter posts to `POST /api/app/bid/select-bid-and-create-order`. |
| Flutter owns no truth | Pass | Selection/order state remains Server/BFF owned. |
| Local Flutter test | Pass | Target test and related bridge regression passed. |
| Cloud route smoke | Not claimed | Requires Aliyun BFF/Server deployment and tunnel/login verification. |
| Dual-account UAT | Not claimed | Requires logged-in publisher and bidder accounts on cloud data. |

## 7. Next Allowed Stage

The next bounded stage may proceed to cloud route smoke and dual-account UAT only after Aliyun BFF/Server are aligned with the Day25 route package. Production acceptance remains blocked until a real publisher account selects a real bidder, the order is created once, and both accounts can observe the resulting state through the tunnel.
