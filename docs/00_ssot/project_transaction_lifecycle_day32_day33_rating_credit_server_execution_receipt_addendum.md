---
owner: Codex 总控
status: frozen
layer: L0 execution receipt
scheduled_days:
  - 2026-06-01
  - 2026-06-02
execution_recorded_at_local: 2026-04-25
purpose: Record the Server execution result for completed-order counterparty rating gating and credit shadow/ledger bridge closure.
---

# Project Transaction Lifecycle Day32-Day33 Rating / Credit Server Execution Receipt

## 1. Conclusion

Day32 / Day33 Server source execution is complete.

This receipt records:

- `ProjectCounterpartyRating` gating is hardened for completed-order-only eligibility.
- Same-direction duplicate submission is rejected both by pre-check and unique-constraint race handling.
- Counterparty rating submit now carries `sourceType = project_counterparty_rating` into the credit shadow bridge.
- Credit shadow trigger and ledger persistence now carry `source_type`, so `rating truth -> shadow recompute/ledger` can be queried by source family.

This receipt does not claim:

- Aliyun release of the new local Server source.
- real dual-account completed-order UAT.
- real cloud DB row verification after an actual app submit.
- public production acceptance.

## 2. Code Changes

Server rating gating:

- `apps/server/test/project-counterparty-rating.test.cjs`
  - added active-order entry read-only coverage.
  - added duplicate-direction entry read-only coverage.
  - added active-order submit rejection with no truth/audit/credit trigger.
  - added unique-constraint race mapping to `PROJECT_COUNTERPARTY_RATING_DUPLICATE`.
- `apps/server/src/modules/project_counterparty_rating/project-counterparty-rating.service.ts`
  - passes `sourceType: 'project_counterparty_rating'` to the credit shadow bridge.

Credit bridge source typing:

- `apps/server/src/modules/credit_scoring_shadow/credit-scoring-shadow.types.ts`
  - adds optional `sourceType` to `RecomputeTriggerInput`.
- `apps/server/src/modules/credit_scoring_shadow/credit-scoring-shadow.aggregation.service.ts`
  - resolves `sourceType`, defaulting legacy calls to `order_rating`.
  - persists `sourceType` on recompute trigger and ledger rows.
- `apps/server/src/modules/credit_scoring_shadow/entities/organization-credit-shadow-recompute-trigger.entity.ts`
  - adds `sourceType`.
- `apps/server/src/modules/credit_scoring_shadow/entities/organization-credit-shadow-ledger-entry.entity.ts`
  - adds `sourceType`.
- `apps/server/src/modules/credit_scoring_shadow/credit-scoring-shadow.bootstrap.service.ts`
  - includes `source_type` in first-time table creation.
- `apps/server/src/core/migrations/migrations.ts`
  - adds `20260602_credit_shadow_source_type_truth`.
  - conditionally adds `source_type` to existing shadow trigger / ledger tables.
  - conditionally adds source indexes without failing if the shadow tables are created later by the bootstrap path.
- `apps/server/src/modules/rating/rating.write.service.ts`
  - legacy `/rating/submit` now explicitly uses `sourceType: 'order_rating'`.

Credit bridge tests:

- `apps/server/test/credit-scoring-shadow.test.cjs`
  - asserts trigger / ledger `triggerType`.
  - asserts trigger / ledger `sourceType`.
  - asserts `sourceOrderId` / `sourceRatingId`.
  - asserts `public.project_counterparty_ratings` is consumed.
- `apps/server/test/rating-entry-submit.test.cjs`
  - asserts legacy rating uses `sourceType: 'order_rating'`.

## 3. Day32 Acceptance

| Gate | Result | Evidence |
|---|---:|---|
| Missing rating anchors rejected | Pass | `PROJECT_COUNTERPARTY_RATING_INVALID` test. |
| Entry opens only for completed order | Pass | completed order entry returns `canRate=true`. |
| Entry read-only before order completed | Pass | active order returns `canRate=false` and reason. |
| Entry read-only after same direction submitted | Pass | duplicate direction returns `canRate=false` and submitted state. |
| Submit rejects non-completed order | Pass | active order returns `PROJECT_COUNTERPARTY_RATING_UNAVAILABLE`. |
| Submit rejects outside order boundary | Pass | outside ratee returns `PROJECT_COUNTERPARTY_RATING_FORBIDDEN`. |
| Submit rejects duplicate direction | Pass | existing direction returns `PROJECT_COUNTERPARTY_RATING_DUPLICATE`. |
| Unique race maps to duplicate | Pass | simulated `23505` maps to `PROJECT_COUNTERPARTY_RATING_DUPLICATE`. |
| Successful submit writes truth and audit | Pass | saved rating and `ProjectCounterpartyRatingSubmitted` audit asserted. |

## 4. Day33 Acceptance

| Gate | Result | Evidence |
|---|---:|---|
| New counterparty rating bridge targets ratee org | Pass | `organizationId = rateeOrganizationId` asserted. |
| Bridge payload carries source type | Pass | `sourceType = project_counterparty_rating` asserted. |
| Bridge payload carries order/rating anchors | Pass | `sourceOrderId` and `sourceRatingId` asserted. |
| Shadow consumes counterparty rating truth | Pass | SQL includes `public.project_counterparty_ratings`. |
| Shadow does not treat 1-5 score as 0-100 score | Pass | counterparty rows feed `scoreLabel`; `scoreValue` is `null::numeric`. |
| Trigger row is created and processed | Pass | mock trigger saved as `pending`, then updated to `processed`. |
| Ledger row is appended | Pass | mock ledger saved with source type/order/rating anchors. |
| Aggregate is recomputed | Pass | mock aggregate saved and snapshot returned. |

## 5. Verification

Local Server build:

| Command | Result |
|---|---:|
| `npm run build` | Pass |

Local Server targeted tests:

| Command | Result |
|---|---:|
| `node --test test/project-counterparty-rating.test.cjs test/credit-scoring-shadow.test.cjs test/rating-entry-submit.test.cjs` | Pass, `22/22`. |
| `node --test test/project-order-completion.test.cjs test/project-counterparty-rating.test.cjs test/credit-scoring-shadow.test.cjs test/rating-entry-submit.test.cjs` | Pass, `27/27`. |

8080 tunnel route probes:

| Probe | Result | Meaning |
|---|---|---|
| `GET /api/app/project-counterparty-rating/entry?orderId=route-smoke-order&projectId=route-smoke-project&rateeOrganizationId=route-smoke-org` | `401 AUTH_SESSION_INVALID` | Route remains materialized and auth-gated; no route-level `404`. |
| `POST /api/app/project-counterparty-rating/submit` with smoke body | `401 AUTH_SESSION_INVALID` | Submit route remains materialized and auth-gated; no route-level `404`. |

Active Aliyun runtime observed during this receipt:

- Server current: `/srv/releases/server/20260425161006-p0-pay-day20-message-carry`
- BFF current: `/srv/releases/bff/20260425154325-day29-bff-runtime-routes/apps/bff`
- `exhibition-server`: active
- `exhibition-bff`: active

The active cloud runtime is route-reachable, but this receipt does not claim that the newly edited local Server source has been released to Aliyun.

## 6. Remaining Gates

Still blocked:

- Aliyun release / current switch for this source revision.
- completed-order dual-account UAT.
- DB-level cloud verification that:
  - `project_counterparty_ratings` receives one submitted row per direction.
  - duplicate direction returns `PROJECT_COUNTERPARTY_RATING_DUPLICATE`.
  - `organization_shadow_credit_recompute_triggers` receives `source_type = project_counterparty_rating`.
  - `organization_shadow_credit_ledgers` receives `source_type = project_counterparty_rating`.

Next allowed stage:

- Day34-style Aliyun release and DB probe only after a completed `ProjectOrder` fixture and two valid logged-in business actors are available.

## 7. Stability / Cost / Stage Fit

- More stable: keep `ProjectOrder.state = completed` as the only rating gate and `ProjectCounterpartyRating` as the only new counterparty-rating truth.
- More cost-efficient: add `sourceType` to the existing trigger / ledger family rather than creating a second credit bridge table.
- More suitable for the current stage: Server-only hardening and local proof before BFF/Flutter or cloud release work.
- Higher risk: claiming Day33 cloud completion from local mocks, unauthenticated `401` route probes, or old `/rating/submit` credit triggers.
