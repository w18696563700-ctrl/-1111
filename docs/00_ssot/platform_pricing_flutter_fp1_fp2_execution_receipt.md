# Platform Pricing Flutter FP1/FP2 Execution Receipt

## Scope

Stage: Flutter FP1/FP2 consumer base and 200 project publish gate.

This stage only changes Flutter consumer paths, commands, readback handling, controlled error copy, and the project publish user flow. It does not change BFF, Server, contracts, cloud runtime, or deployment state.

## Implemented Changes

### Project-scoped pricing consumer

- Added project-scoped path helpers:
  - `/api/app/project/:projectId/pricing-summary`
  - `/api/app/project/:projectId/authenticity-sincerity/orders`
  - `/api/app/project/:projectId/authenticity-sincerity/orders/:orderId/pay-init`
  - `/api/app/project/:projectId/authenticity-sincerity/orders/:orderId`

- Added Flutter command objects:
  - `ProjectAuthenticitySincerityOrderCommand`
  - `ProjectPricingPayInitCommand`

- Added Flutter consumer methods:
  - `loadProjectPricingSummary`
  - `createProjectAuthenticitySincerityOrder`
  - `initProjectAuthenticitySincerityPayment`
  - `loadProjectAuthenticitySincerityOrderStatus`
  - `pollProjectAuthenticitySincerityOrderStatus`

### Publish gate

- The formal publish action in `MyProjectDetailPage` now fail-closes through the 200 yuan project authenticity sincerity gate.
- Publish sequence is:
  1. Verify required effect image attachment.
  2. Ask for publish confirmation.
  3. Load project pricing summary.
  4. If the 200 gate is not already satisfied, create the sincerity order.
  5. Initialize payment.
  6. Read back order status.
  7. Only if the sincerity status is paid/frozen/succeeded/satisfied/not_required, call `/api/app/project/publish`.
- If the 200 gate remains pending, Flutter shows a controlled message and does not call publish.

### Error copy

- Added controlled Chinese messages for project authenticity sincerity and pricing rule version errors.
- Added `projectAuthenticitySincerity` polling kind to keep status copy distinct from legacy inquiry deposit.

## Files Touched

- `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart`
- `apps/mobile/lib/features/exhibition/data/commands/p0_pay_commands.dart`
- `apps/mobile/lib/features/exhibition/data/models/p0_pay_payment_polling.dart`
- `apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart`
- `apps/mobile/test/p0_pay_flutter_consumption_test.dart`
- `apps/mobile/test/my_project_private_carry_test.dart`

## Validation

Commands completed:

```bash
cd apps/mobile && dart format ...
cd apps/mobile && flutter analyze lib/features/exhibition/data/services/exhibition_canonical_paths.dart lib/features/exhibition/data/commands/p0_pay_commands.dart lib/features/exhibition/data/models/p0_pay_payment_polling.dart lib/features/exhibition/data/services/p0_pay_consumer_service.dart lib/features/exhibition/presentation/pages/my_project_detail_page.dart lib/features/exhibition/presentation/widgets/exhibition_status_messages.dart lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart
cd apps/mobile && flutter test test/p0_pay_flutter_consumption_test.dart test/my_project_private_carry_test.dart
```

Result:

- Analyze passed.
- Targeted Flutter tests passed: 26/26.

## Boundary Confirmation

Touched in this stage:

- Flutter consumer base.
- Flutter publish action gate.
- Flutter targeted tests.

Not touched in this stage:

- `apps/bff/**`
- `apps/server/**`
- Aliyun runtime
- deploy / restart / rollback
- tunnel validation

## Gate Result

FP1/FP2 result: Go for Flutter FP3/FP4 only.

Allowed next stage:

- Flutter 4000 bid gate and read-only pricing summary.

Still blocked:

- Local full regression.
- Cloud validation.
- Release-prep.
