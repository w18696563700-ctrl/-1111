# Platform Pricing BFF P3/P4 Execution Receipt

## Scope

Stage: BFF P3/P4 bid handoff and message carry.

This stage only changes BFF app-facing shaping and error normalization. BFF remains a forwarding/read-model layer and does not own pricing truth, payment state, fee calculation, deal state, audit, or risk decisions.

## Implemented Changes

### Bid participation handoff

- `apps/bff/src/routes/bid_participation_request/bid-participation-request.read-model.ts`
  - Added read-model fields for `pricingGateRequired`, `pricingGateType`, and `pricingGateRouteTarget`.
  - When a participation request is `approved`, BFF fail-closes to `bid_service_fee_authorization.open` unless Server explicitly says the pricing gate is not required.
  - The canonical handoff path is `/api/app/project/:projectId/bid-service-fee-authorizations`.
  - The handoff params include `projectId` and `bidParticipationRequestId`.

### Bid submit error normalization

- `apps/bff/src/routes/bid/bid.service.ts`
  - Added controlled user-facing messages for:
    - `BID_SERVICE_FEE_AUTHORIZATION_REQUIRED`
    - `BID_SERVICE_FEE_AUTHORIZATION_INVALID_STATE`
  - BFF still forwards bid submit to Server and does not infer frozen/approved state locally.

### Message carry

- `apps/bff/src/routes/message_interaction/message-interaction.read-model.ts`
  - Replaced app-facing `p0PaySummary` carry with `pricingSummary`.
  - Kept read-only validation for pricing summary surfaces.

- `apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts`
  - Project groups now carry `pricingSummary`.
  - Approved bid participation cards are rewritten from `bid_submit.open` to `bid_service_fee_authorization.open` unless Server explicitly marks the pricing gate as not required.
  - No BFF-side pricing state machine was added.

## Tests Added Or Updated

- `apps/bff/test/bid-participation-request-transport.test.cjs`
  - Covers approved participation request handoff to the 4000 authorization gate.

- `apps/bff/test/bid-submit-error-mapping.test.cjs`
  - Covers `BID_SERVICE_FEE_AUTHORIZATION_REQUIRED` user-facing normalization.

- `apps/bff/test/message-interaction-transport.test.cjs`
  - Covers message carry using `pricingSummary`.
  - Covers approved message card handoff to `bid_service_fee_authorization.open`.

## Validation

Commands completed:

```bash
cd apps/bff && npm run build
cd apps/bff && node --test test/bid-participation-request-transport.test.cjs test/bid-submit-error-mapping.test.cjs test/message-interaction-transport.test.cjs test/exhibition-p0-pay-transport.test.cjs
```

Result:

- BFF build passed.
- Targeted BFF tests passed: 29/29.
- Follow-up source scan found no `p0PaySummary` residue in:
  - `apps/bff/src/routes/message_interaction`
  - `apps/bff/test/message-interaction-transport.test.cjs`

## Boundary Confirmation

Touched in this stage:

- `apps/bff/src/routes/bid_participation_request/**`
- `apps/bff/src/routes/bid/**`
- `apps/bff/src/routes/message_interaction/**`
- BFF targeted tests

Not touched in this stage:

- `apps/mobile/**`
- `apps/server/**`
- Aliyun runtime
- deploy / restart / rollback
- tunnel validation

## Residual Risks

- BFF relies on Server to provide true authorization status, frozen state, deal status, fee calculation, and release results.
- If cloud Server has not deployed the matching pricing route family and response fields, cloud validation may still fail even though local BFF build/tests pass.
- `exhibition_p0_pay` keeps a bounded internal fallback from old `p0PaySummary` to `pricingSummary` for compatibility, but app-facing output key is `pricingSummary`.

## Gate Result

P3/P4 result: Go for Flutter FP1/FP2 only.

Allowed next stage:

- Flutter consumer base and 200 publish gate.

Still blocked:

- Cloud validation.
- Release-prep.
- Any BFF-side local calculation of pricing truth.
