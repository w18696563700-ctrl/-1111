# Platform Pricing Flutter FP3/FP4 Execution Receipt

## Scope

Stage: Flutter FP3/FP4 4000 bid authorization gate and read-only pricing summary.

This stage only changes Flutter route consumption, bid submit gating, message entry handoff, project detail read-only rendering, controlled error copy, and targeted tests. It does not change BFF, Server, contracts, cloud runtime, deployment state, or remote data.

## Implemented Changes

### Project-scoped 4000 authorization consumer

- Added project-scoped path helpers:
  - `/api/app/project/:projectId/bid-service-fee-authorizations`
  - `/api/app/project/:projectId/bid-service-fee-authorizations/:authorizationId/freeze-init`
  - `/api/app/project/:projectId/bid-service-fee-authorizations/:authorizationId`

- Added Flutter command object:
  - `BidServiceFeeAuthorizationCommand`

- Added Flutter consumer methods:
  - `createProjectBidServiceFeeAuthorization`
  - `initProjectBidServiceFeeAuthorizationFreeze`
  - `loadProjectBidServiceFeeAuthorizationStatus`
  - `pollProjectBidServiceFeeAuthorizationStatus`

### Bid submit gate

- `BidSubmitPage` now accepts `bidParticipationRequestId` from route query and message-entry handoff.
- Approved bid participation message entries now route to `bid_service_fee_authorization.open` before bid submit.
- Bid submit now fail-closes through the 4000 yuan bid service fee authorization gate.
- Submit sequence is:
  1. Validate bid form and required attachments.
  2. Resolve `projectId` and `bidParticipationRequestId`.
  3. Load project pricing summary.
  4. If bidder authorization is already frozen or otherwise satisfied, continue.
  5. Otherwise create a 4000 yuan bid service fee authorization.
  6. Initialize freeze.
  7. Read back authorization status.
  8. Only if the authorization status is frozen/succeeded/satisfied/not_required, call `/api/app/bid/submit`.
- If the 4000 gate remains pending or missing, Flutter shows a controlled message and does not call bid submit.

### Read-only pricing summary

- Project detail now loads `/api/app/project/:projectId/pricing-summary`.
- Read-only parsing supports the new `pricingSummary` shape:
  - `publisherPricing`
  - `bidderPricing`
  - `projectAuthenticitySincerity`
  - `bidServiceFeeAuthorization`
  - `dealSummary`
- User-facing copy no longer treats old 3% estimated service fee as authority.
- Bid authorization UI copy now presents fixed `4000 元竞标服务费预授权额度`; Flutter does not locally calculate final platform service fee.

## Files Touched

- `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
- `apps/mobile/lib/features/exhibition/data/commands/p0_pay_commands.dart`
- `apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart`
- `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart`
- `apps/mobile/lib/shell/navigation/app_router.dart`
- `apps/mobile/lib/features/messages/data/messages_registered_entry_registry.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_name_access_thread_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_actions.dart`
- `apps/mobile/lib/features/exhibition/data/p0_pay_read_only_summary.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart`
- `apps/mobile/test/p0_pay_flutter_consumption_test.dart`
- `apps/mobile/test/trading_im_round_a_consumption_test.dart`
- `apps/mobile/test/shell_app_test.dart`

## Validation

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
- Existing scroll hit-test warnings appeared in `trading_im_round_a_consumption_test.dart`; they did not fail tests and were not introduced as a blocking regression in this stage.

## Boundary Confirmation

Touched in this stage:

- Flutter 4000 bid authorization gate.
- Flutter message-entry handoff to authorization gate.
- Flutter project detail pricing summary read-only rendering.
- Flutter targeted tests.

Not touched in this stage:

- `apps/bff/**`
- `apps/server/**`
- Aliyun runtime
- deploy / restart / rollback
- tunnel validation

## Residual Risks

- Cloud validation still depends on matching BFF and Server deployments exposing the project-scoped pricing routes.
- If an approved bid participation request lacks `bidParticipationRequestId` in cloud message carry, Flutter will correctly fail-close instead of submitting.
- The legacy bid authorization helper file is retained for compatibility, but active submit flow no longer uses old 3% estimated fee authority.

## Gate Result

FP3/FP4 result: Go for Day 10 local full regression only.

Allowed next stage:

- Local Server/BFF/Flutter regression and execution receipt packaging.

Still blocked:

- Cloud validation.
- Release-prep.
- Any Flutter-side fee calculation authority.
