# Platform Pricing Day 10 Local Regression Execution Receipt

## Scope

Stage: Day 10 local regression and execution receipt packaging.

This stage validates the completed Server SP-1 through SP-5, BFF P1 through P4, and Flutter FP1 through FP4 implementation slices in the local workspace. It does not change cloud runtime, deploy, restart, rollback, remote data, or Aliyun services.

## Regression Matrix

### Server

Commands completed:

```bash
cd apps/server && npm run build
cd apps/server && node --test test/p0-pay-server-mainline.test.cjs test/p0-pay-calculator-idempotency.test.cjs test/project-lifecycle.test.cjs test/bid-submit.test.cjs test/message-interaction-bid-carry.test.cjs
```

Result:

- Build passed.
- Targeted Server tests passed: 40/40.

Covered boundaries:

- 200 yuan project authenticity sincerity gate.
- 4000 yuan bid service fee authorization gate.
- Bid submit fail-close until approved bidder has frozen authorization.
- Deal fee calculation with tiered fee, membership discount, and cap.
- Callback no longer auto-publishes project.
- Message interaction read-only pricing carry.

### BFF

Commands completed:

```bash
cd apps/bff && npm run build
cd apps/bff && node --test test/exhibition-p0-pay-transport.test.cjs test/project-lifecycle.test.cjs test/project-lifecycle-correction.test.cjs test/bid-participation-request-transport.test.cjs test/bid-submit-error-mapping.test.cjs test/message-interaction-transport.test.cjs
```

Result:

- Build passed.
- Targeted BFF tests passed: 40/40.

Covered boundaries:

- Project-scoped pricing route family.
- Legacy trade-task alias remains bounded and is not current authority.
- Publish fail-close error normalization.
- Approved bid participation handoff to 4000 authorization gate.
- Message interaction `pricingSummary` carry.
- No BFF-side fee calculation truth.

### Flutter

Commands completed:

```bash
cd apps/mobile && flutter analyze lib/features/exhibition/data/services/exhibition_canonical_paths.dart lib/features/exhibition/data/commands/p0_pay_commands.dart lib/features/exhibition/data/models/p0_pay_payment_polling.dart lib/features/exhibition/data/services/p0_pay_consumer_service.dart lib/features/exhibition/navigation/exhibition_routes.dart lib/shell/navigation/app_router.dart lib/features/messages/data/messages_registered_entry_registry.dart lib/features/exhibition/presentation/pages/project_name_access_thread_page.dart lib/features/exhibition/presentation/pages/bid_submit_page.dart lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_support.dart lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_actions.dart lib/features/exhibition/data/p0_pay_read_only_summary.dart lib/features/exhibition/presentation/pages/project_detail_page.dart lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart lib/features/exhibition/presentation/pages/my_project_detail_page.dart
cd apps/mobile && flutter test test/p0_pay_flutter_consumption_test.dart test/my_project_private_carry_test.dart test/trading_im_round_a_consumption_test.dart
cd apps/mobile && flutter test test/shell_app_test.dart --plain-name "bid submit service fee uses fixed validity and user-facing copy"
```

Result:

- Analyze passed.
- Targeted Flutter tests passed: 35/35.
- Shell bid submit authorization chain test passed: 1/1.

Covered boundaries:

- 200 yuan gate before formal project publish.
- 4000 yuan authorization freeze before bid submit.
- Project detail read-only pricing summary.
- Message entry route handoff to bid service fee authorization.
- No Flutter-side final fee calculation truth.

## Residual Scan

Commands completed:

```bash
rg -n "3%|estimatedFeeAmount|p0PaySummary" apps/mobile/lib/features/exhibition apps/mobile/lib/features/messages/data apps/mobile/lib/shell/navigation || true
rg -n "3%|estimatedFeeAmount|p0PaySummary" apps/bff/src/routes apps/server/src/modules/p0_pay apps/server/src/modules/message_interaction || true
rg -n "_submitP0PayFixedPriceBidAndAuthorize|submitP0PayFixedPriceBidAndAuthorize" apps/mobile/lib apps/mobile/test || true
```

Result:

- No active `3%` user-facing authority was found in the scanned implementation surfaces.
- `estimatedFeeAmount` remains in legacy compatibility and old helper/entity surfaces.
- The old Flutter fixed-price helper is retained but has no active call site.
- BFF keeps a bounded fallback from `p0PaySummary` to `pricingSummary` for compatibility; app-facing current authority is `pricingSummary`.

Residual risk classification:

- Non-blocking for Day 11 cloud validation.
- Should be scheduled as a later cleanup if the project wants to remove legacy naming entirely.

## Blocker List

No local regression blocker found.

Known non-blocking warnings:

- `trading_im_round_a_consumption_test.dart` emits existing Flutter scroll hit-test warnings. Tests still pass and this does not affect the pricing state machine validation.

## Boundary Confirmation

Touched in this stage:

- Regression commands.
- Execution receipt documentation.

Not touched in this stage:

- Application code.
- `apps/bff/**` implementation.
- `apps/server/**` implementation.
- Aliyun runtime.
- deploy / restart / rollback.
- tunnel validation.

## Gate Result

Day 10 result: Go for Day 11 cloud validation only.

Allowed next stage:

- Cloud deployed-version verification.
- Tunnel validation through `127.0.0.1:8080`.
- Real data checks for project publish chain, bid authorization chain, forum/message non-regression, and company/factory/supplier pages.

Still blocked:

- Release-prep.
- Any deploy / restart / rollback unless separately approved.
- Any new implementation work not caused by a Day 11 blocker.
