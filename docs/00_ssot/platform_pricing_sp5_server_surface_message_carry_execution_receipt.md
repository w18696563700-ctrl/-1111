# Platform Pricing SP-5 Server Surface And Message Carry Execution Receipt

## Scope

SP-5 only closed Server read surface and message carry for the new platform pricing mainline.

In scope:

- Server pricing summary route surface.
- P0-Pay presenter authorization quota output.
- Counterpart conversation message carry pricing summary.
- Server targeted tests for pricing surface and message carry.

Out of scope:

- BFF implementation.
- Flutter implementation.
- Cloud deploy, restart, rollback, tunnel validation, or runtime verification.
- Project publish and bid gate behavior beyond previously completed SP-2 / SP-3.

## Changes

- Kept canonical Server pricing summary route:
  - `GET server/project/:projectId/pricing-summary`
- Shifted trade task detail inline read model from `p0PaySummary` to `pricingSummary`.
- Shifted message interaction bid-thread carry from `p0PaySummary` to `pricingSummary`.
- Pricing summary now carries the new read-only shape:
  - `projectId`
  - `pricingRuleVersion`
  - `bidServiceFeeAuthorization.quotaAmount`
  - `projectAuthenticitySincerity`
  - `dealConfirmation`
  - `messageDisplaySummary.routeTarget.objectType = project_pricing`
  - `messageDisplaySummary.routeTarget.actionKey = pricing_summary.read`
  - canonical path `/api/app/project/:projectId/pricing-summary`
- P0-Pay presenter now surfaces `authorizationQuotaAmount` / `quotaAmount` instead of exposing `estimatedFeeAmount` as app-facing authorization authority.
- Removed the unused bid-thread helper that only existed to support old P0-Pay task summary labeling.

## Files Touched

- `apps/server/src/modules/p0_pay/p0-pay.controller.ts`
- `apps/server/src/modules/p0_pay/p0-pay.presenter.ts`
- `apps/server/src/modules/p0_pay/p0-pay-trade-task.service.ts`
- `apps/server/src/modules/message_interaction/counterpart-conversation.bid-thread-source.ts`
- `apps/server/src/modules/message_interaction/counterpart-conversation.seed.ts`
- `apps/server/src/modules/message_interaction/counterpart-conversation.types.ts`
- `apps/server/src/modules/message_interaction/counterpart-conversation.projection.service.ts`
- `apps/server/test/p0-pay-server-mainline.test.cjs`

## Validation

Passed:

```bash
cd apps/server && npm run build
```

Passed:

```bash
cd apps/server && node --test test/p0-pay-server-mainline.test.cjs test/message-interaction-bid-carry.test.cjs test/p0-pay-calculator-idempotency.test.cjs
```

Result:

- Server build passed.
- Targeted tests passed: 26 / 26.

## Boundary Check

- Did not touch `apps/bff/**` in this SP-5 patch.
- Did not touch `apps/mobile/**` in this SP-5 patch.
- Did not touch cloud runtime.
- Did not run deploy / restart / rollback.
- Did not run tunnel validation.

## Gate Result

SP-5 result: Go for BFF P1/P2 only.

Allowed next stage:

- P1/P2 BFF route core and publish gate.

Still not allowed:

- Flutter implementation before BFF P3/P4 passes.
- Cloud validation before local Server / BFF / Flutter regression is completed.
