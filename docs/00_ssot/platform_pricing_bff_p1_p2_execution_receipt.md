# Platform Pricing BFF P1/P2 Execution Receipt

## Scope

P1/P2 closed the BFF route core and publish / withdraw pricing-gate alignment for the current platform pricing mainline.

In scope:

- New app-facing project pricing route family.
- BFF request shaping for `200 元项目真实性诚意金`.
- BFF request shaping for `4000 元竞标服务费预授权额度`.
- BFF request shaping for bounded deal confirmation.
- Read-model shaping for pricing summary, sincerity orders, authorization, release, and deal confirmation.
- Publish fail-closed message for `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED`.
- Withdraw-published pricing exit wording aligned to `竞标服务费预授权额度`.

Out of scope:

- Flutter implementation.
- BFF bid participation handoff and message carry P3/P4.
- Server implementation changes.
- Cloud deploy, restart, rollback, tunnel validation, or runtime verification.

## Changes

- Added app-facing project pricing controller:
  - `GET /api/app/project/:projectId/pricing-summary`
  - `POST /api/app/project/:projectId/authenticity-sincerity/orders`
  - `POST /api/app/project/:projectId/authenticity-sincerity/orders/:orderId/pay-init`
  - `GET /api/app/project/:projectId/authenticity-sincerity/orders/:orderId`
  - `POST /api/app/project/:projectId/bid-service-fee-authorizations`
  - `POST /api/app/project/:projectId/bid-service-fee-authorizations/:authorizationId/freeze-init`
  - `GET /api/app/project/:projectId/bid-service-fee-authorizations/:authorizationId`
  - `POST /api/app/project/:projectId/bid-service-fee-authorizations/:authorizationId/release`
  - `POST /api/app/project/:projectId/deal-confirmations`
  - `GET /api/app/project/:projectId/deal-confirmations/:dealConfirmationId`
- Kept old `/api/app/exhibition/trade-tasks/**` routes as bounded compatibility aliases only.
- Moved app-facing pricing summary output away from `p0PaySummary / inquiryDeposit / estimatedFeeAmount`.
- Pricing summary now shapes:
  - `publisherPricing`
  - `bidderPricing`
  - `dealSummary`
  - `readOnly: true`
- New 4000 authorization request shaping rejects non-4000 quota.
- BFF does not calculate service fee, membership discount, cap, release result, or deal truth.

## Files Touched

- `apps/bff/src/routes/exhibition_p0_pay/app-project-pricing.controller.ts`
- `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.module.ts`
- `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.service.ts`
- `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay-payload.service.ts`
- `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model.ts`
- `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay-error.service.ts`
- `apps/bff/src/routes/project/project.service.ts`
- `apps/bff/src/routes/project/project-lifecycle.service.ts`
- `apps/bff/test/exhibition-p0-pay-transport.test.cjs`
- `apps/bff/test/project-lifecycle.test.cjs`
- `apps/bff/test/project-lifecycle-correction.test.cjs`

## Validation

Passed:

```bash
cd apps/bff && npm run build
```

Passed after build:

```bash
cd apps/bff && node --test test/exhibition-p0-pay-transport.test.cjs test/project-lifecycle.test.cjs test/project-lifecycle-correction.test.cjs
```

Result:

- BFF build passed.
- Targeted tests passed: 20 / 20.

## Boundary Check

- Did not touch `apps/mobile/**`.
- Did not touch cloud runtime.
- Did not deploy / restart / rollback.
- Did not run tunnel validation.
- Did not implement P3/P4 bid handoff or message carry in this stage.

## Known Integration Note

The app-facing BFF route family is canonical under `/api/app/project/**`.

For `pricing-summary`, the current local Server SP-5 route is singular:

- `/server/project/:projectId/pricing-summary`

For the remaining new pricing write/read family, BFF forwards to the frozen canonical Server-facing family:

- `/server/projects/:projectId/bid-service-fee-authorizations*`
- `/server/projects/:projectId/deal-confirmations*`

If cloud Server has not yet exposed those canonical routes, this becomes a deployment/runtime integration blocker for the later cloud validation stage, not a BFF P1/P2 local build blocker.

## Gate Result

P1/P2 result: Go for BFF P3/P4 only.

Allowed next stage:

- BFF bid participation and bid-submit handoff alignment.
- BFF message interaction pricing carry.

Still not allowed:

- Flutter implementation before BFF P3/P4 passes.
- Cloud validation before local Server / BFF / Flutter regression is completed.
