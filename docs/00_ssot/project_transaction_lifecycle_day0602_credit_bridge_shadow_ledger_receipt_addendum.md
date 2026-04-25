---
owner: Codex 总控
status: frozen
layer: L0 Server credit bridge receipt
scheduled_day: 2026-06-02
execution_recorded_at_local: 2026-04-25
purpose: Record the Server-side credit bridge closure from ProjectCounterpartyRating truth to credit shadow trigger and ledger with source_type=project_counterparty_rating.
---

# Project Transaction Lifecycle Day06-02 Credit Bridge Shadow Ledger Receipt

## 1. Conclusion

Day06-02 Server credit bridge is complete at the Server/schema/service-proof gate.

The current Server truth path proves:

- `ProjectCounterpartyRating` submit calls the credit shadow bridge after writing rating truth;
- the bridge writes `organization_shadow_credit_recompute_triggers.source_type = project_counterparty_rating`;
- the recompute path writes `organization_shadow_credit_ledgers.source_type = project_counterparty_rating`;
- the shadow aggregation service reads `public.project_counterparty_ratings` as the score source for this source family;
- legacy `order_rating` remains preserved as a separate source family.

This receipt does not claim:

- real dual-account Flutter submit passed;
- a permanent production `project_counterparty_ratings` row was created;
- production acceptance is complete;
- app-side completed-order creation and rating UAT has passed.

Because the confirmed test-project cleanup left the cloud database with zero completed orders and zero ratings, this proof used the running cloud Server compiled services inside a database transaction, then rolled the transaction back. That is the safest Server-level proof available without polluting the user's cleaned production-like data.

## 2. Truth Owner

| Object | Truth owner | Result |
|---|---|---|
| `ProjectCounterpartyRating` | Server | Pass |
| credit recompute trigger | Server | Pass |
| credit shadow ledger | Server | Pass |
| `source_type` source family | Server schema + Server service | Pass |
| BFF/Flutter | No truth ownership | Preserved |

## 3. Code Gate

Verified source/current runtime responsibilities:

| File | Verified gate |
|---|---|
| `apps/server/src/modules/project_counterparty_rating/project-counterparty-rating.service.ts` | Successful submit invokes `triggerCreditShadowBridge` with `sourceType = project_counterparty_rating`. |
| `apps/server/src/modules/credit_scoring_shadow/credit-scoring-shadow.aggregation.service.ts` | Accepts `sourceType`, stores it on trigger/ledger rows, and reads `public.project_counterparty_ratings` for the new source family. |
| `apps/server/src/modules/credit_scoring_shadow/entities/organization-credit-shadow-recompute-trigger.entity.ts` | Declares `source_type varchar(64)` defaulting to `order_rating`. |
| `apps/server/src/modules/credit_scoring_shadow/entities/organization-credit-shadow-ledger-entry.entity.ts` | Declares `source_type varchar(64)` defaulting to `order_rating`. |

The Server boundary remains unchanged: BFF and Flutter may request or display rating state, but cannot create credit truth, ledger truth, or a second credit state machine.

## 4. Local Verification Evidence

Local Server build and targeted tests passed:

| Command | Result |
|---|---:|
| `npm run build` in `apps/server` | Pass |
| `node --test test/credit-scoring-shadow.test.cjs test/project-counterparty-rating.test.cjs` | Pass, `15/15`. |

Targeted assertions covered:

- `ProjectCounterpartyRating` submit propagates `sourceType = project_counterparty_rating`;
- credit shadow trigger stores `sourceType = project_counterparty_rating`;
- credit shadow ledger stores `sourceType = project_counterparty_rating`;
- aggregation query reads `public.project_counterparty_ratings`;
- existing `order_rating` family remains available for legacy order rating flow.

## 5. Cloud Schema Gate

Cloud database read-only probes confirmed:

| Table | Column | Type | Default | Nullable | Result |
|---|---|---|---|---:|---:|
| `organization_shadow_credit_recompute_triggers` | `source_type` | `varchar(64)` | `order_rating` | No | Pass |
| `organization_shadow_credit_ledgers` | `source_type` | `varchar(64)` | `order_rating` | No | Pass |

Current cloud data baseline after the confirmed cleanup:

| Probe | Count |
|---|---:|
| `orders_total` | `0` |
| `completed_orders` | `0` |
| `ratings_total` | `0` |
| `project_counterparty_credit_triggers` | `0` |
| `project_counterparty_credit_ledgers` | `0` |

This baseline is expected after removing test projects. It blocks permanent real-rating UAT, but it does not block a rollback-transaction Server proof.

## 6. Cloud Runtime Fingerprint

Cloud `Server current` contains:

| Runtime proof | Result |
|---|---:|
| `credit-scoring-shadow.aggregation.service.js` reads `public.project_counterparty_ratings` | Pass |
| credit trigger entity contains `source_type` | Pass |
| credit ledger entity contains `source_type` | Pass |
| `project-counterparty-rating.service.js` submits bridge with `sourceType: 'project_counterparty_rating'` | Pass |

## 7. Rollback Transaction Proof

A safe cloud service proof was executed against the running compiled Server code in `/srv/apps/server/current`.

Proof method:

1. open a PostgreSQL transaction through TypeORM `QueryRunner`;
2. insert a temporary completed `ProjectOrder` inside the transaction under the preserved real project;
3. call the real compiled `ProjectCounterpartyRatingService.submit()` method;
4. query trigger and ledger rows inside the same transaction;
5. roll back the transaction;
6. verify no residual order, rating, trigger, or ledger rows remain.

Observed service-submit proof:

```json
{
  "mode": "rollback_transaction_cloud_service_submit_proof",
  "orderId": "day0602-proof-order-6004af8e-01d",
  "projectId": "c788eaff-6243-4e97-8be3-c4e174ee7944",
  "ratingId": "ebaeadb8-246e-4254-a22d-fbf8a45c3970",
  "submitState": "submitted",
  "triggerSourceType": "project_counterparty_rating",
  "triggerStatus": "processed",
  "ledgerSourceType": "project_counterparty_rating",
  "ledgerTriggerType": "formal_rating_submitted"
}
```

Post-rollback residual check:

```json
{
  "mode": "post_rollback_residual_check",
  "orders": "0",
  "ratings": "0",
  "triggers": "0",
  "ledgers": "0"
}
```

Conclusion from this proof: after rating submit, the Server can query both credit trigger and credit ledger rows with `source_type = project_counterparty_rating`; the proof produced no permanent cloud test data.

## 8. Stage Gate Checklist

| Gate | Result | Blocks |
|---|---:|---|
| Rating truth submit calls credit bridge | Pass | No |
| Trigger row carries `source_type=project_counterparty_rating` | Pass | No |
| Ledger row carries `source_type=project_counterparty_rating` | Pass | No |
| Aggregation reads `public.project_counterparty_ratings` | Pass | No |
| Legacy `order_rating` default preserved | Pass | No |
| Cloud schema has trigger/ledger `source_type` columns | Pass | No |
| Cloud current runtime contains source-type bridge code | Pass | No |
| Proof leaves no permanent cloud test rows | Pass | No |
| Real dual-account App submit against completed order | Not run | Blocks production acceptance only. |

Next stage may proceed to real dual-account completed-order UAT after a real completed order exists.

## 9. Current Minimum Loop

Current minimum loop is closed:

1. local Server source verified;
2. local Server build passed;
3. targeted credit/rating tests passed;
4. cloud schema confirmed;
5. cloud runtime fingerprint confirmed;
6. running compiled cloud services executed rating submit inside rollback transaction;
7. trigger and ledger `source_type = project_counterparty_rating` were queried;
8. transaction rollback left no test residue.

## 10. Retained But Not Opened

Retained:

- legacy `order_rating` source family;
- existing credit shadow trigger and ledger tables;
- Day35 source-type schema alignment;
- real dual-account UAT as the later production acceptance gate.

Not opened:

- permanent fake completed orders;
- permanent fake rating rows;
- manual DB insertion of credit trigger or ledger rows;
- treating rollback-transaction proof as Flutter dual-account acceptance.

## 11. Stability / Cost / Stage Fit

- More stable: prove the actual compiled Server service and real DB schema, instead of only inspecting local code.
- More cost-efficient: reuse the existing credit shadow infrastructure and avoid creating a separate credit bridge table.
- More suitable for the current stage: close the Server bridge before forcing a full dual-account app UAT.
- Higher risk: creating permanent fake production data just to satisfy a ledger query, or claiming full production acceptance without a real completed-order app submit.
