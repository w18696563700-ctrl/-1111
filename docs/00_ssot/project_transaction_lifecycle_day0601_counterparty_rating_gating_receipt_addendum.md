---
owner: Codex 总控
status: frozen
layer: L0 Server gating receipt
scheduled_day: 2026-06-01
execution_recorded_at_local: 2026-04-25
purpose: Record the Server-side ProjectCounterpartyRating gating verification for completed-order-only mutual rating and duplicate-direction rejection.
---

# Project Transaction Lifecycle Day06-01 Counterparty Rating Gating Receipt

## 1. Conclusion

Day06-01 Server gating is complete.

No new Server code change was required in this run because the current source and cloud runtime already satisfy the frozen gating requirements:

- only `completed` orders can submit `ProjectCounterpartyRating`;
- rating direction must be exactly buyer -> supplier or supplier -> buyer for the same order;
- one rater organization can rate one ratee organization once per order;
- duplicate direction is rejected before insert when already present;
- concurrent duplicate insertion is rejected by DB unique index and mapped to a stable duplicate error;
- invalid outside-order direction is rejected;
- successful submit triggers credit shadow bridge with `sourceType = project_counterparty_rating`.

This receipt does not claim:

- real dual-account completed-order rating UAT passed;
- a production rating row was submitted through the app;
- credit ledger evidence exists for a real completed-order submit.

## 2. Truth Owner

Truth owner remains Server.

| Object | Truth owner | Notes |
|---|---|---|
| `ProjectCounterpartyRating` | Server | BFF/Flutter may only carry and display. |
| order completion state | Server `ProjectOrder` | Rating only opens after `orders.state = completed`. |
| duplicate-direction prevention | Server + PostgreSQL | Service check plus unique index. |
| credit shadow trigger | Server | Triggered after rating truth submit. |

## 3. Code Gate

Verified source:

| File | Gate |
|---|---|
| `apps/server/src/modules/project_counterparty_rating/project-counterparty-rating.service.ts` | Fetches order by `orderId + projectId`; rejects non-completed order; enforces buyer/supplier direction; checks existing same direction; maps `23505` unique race to duplicate. |
| `apps/server/src/core/migrations/migrations.ts` | Creates `project_counterparty_ratings` table and unique direction index. |
| `apps/server/src/modules/project_counterparty_rating/entities/project-counterparty-rating.entity.ts` | Declares unique index on `orderId / raterOrganizationId / rateeOrganizationId`. |
| `apps/server/src/modules/credit_scoring_shadow/credit-scoring-shadow.aggregation.service.ts` | Accepts `sourceType` and defaults legacy ratings to `order_rating`. |

Key rules observed:

- `COMPLETED_ORDER_STATE = 'completed'`
- `SUBMITTED_RATING_STATE = 'submitted'`
- `sourceType = 'project_counterparty_rating'`

## 4. Cloud Schema Gate

Cloud DB schema check:

| Check | Result |
|---|---:|
| `idx_project_counterparty_ratings_unique_direction` exists | Pass |
| Unique columns are `order_id, rater_organization_id, ratee_organization_id` | Pass |
| Primary key on `id` exists | Pass |
| Score check `score_value BETWEEN 1 AND 5` exists | Pass |
| Score label check exists | Pass |
| Rating state check `rating_state = submitted` exists | Pass |
| Required columns are non-null | Pass |

Cloud runtime code fingerprint:

| Check | Result |
|---|---:|
| Runtime dist contains completed-order rejection copy | Pass |
| Runtime dist performs existing same-direction lookup | Pass |
| Runtime dist maps `23505` unique race | Pass |
| Runtime dist sends `sourceType: 'project_counterparty_rating'` | Pass |
| Runtime migration contains `idx_project_counterparty_ratings_unique_direction` | Pass |

## 5. Test Evidence

Local Server build:

| Command | Result |
|---|---:|
| `npm run build` in `apps/server` | Pass |

Targeted Server tests:

| Command | Result |
|---|---:|
| `node --test test/project-counterparty-rating.test.cjs` | Pass, `10/10`. |
| `node --test test/project-order-completion.test.cjs test/rating-entry-submit.test.cjs` | Pass, `12/12`. |

Covered behaviors:

- entry requires `orderId / projectId / rateeOrganizationId`;
- entry is read-only before order completion;
- entry is read-only after same direction submitted;
- submit writes truth and audit only for completed order;
- submit rejects active order before writing truth or credit trigger;
- submit allows reverse supplier -> buyer direction;
- submit rejects duplicate direction;
- submit maps unique-race `23505` to duplicate;
- submit rejects outside order boundary;
- order completion confirm opens completed-order rating gate.

## 6. Tunnel Probe

Unauthenticated 8080 route probes:

| Probe | Result | Meaning |
|---|---|---|
| `GET /api/app/project-counterparty-rating/entry?...` | `401 AUTH_SESSION_INVALID` | Route mounted and auth-gated. |
| `POST /api/app/project-counterparty-rating/submit` | `401 AUTH_SESSION_INVALID` | Submit route mounted and auth-gated. |

These probes are only route materialization evidence. They are not dual-account business UAT.

## 7. Stage Gate Checklist

| Gate | Result | Blocks |
|---|---:|---|
| Only completed order can submit rating | Pass | No |
| Same `orderId + projectId` anchor required | Pass | No |
| Rater must be buyer or supplier | Pass | No |
| Ratee must be the opposite order side | Pass | No |
| One direction only once | Pass | No |
| Concurrent duplicate race mapped to duplicate | Pass | No |
| Cloud DB unique index exists | Pass | No |
| Credit bridge source type retained | Pass | No |
| Real dual-account completed-order app submit | Not run | Blocks production acceptance only. |

Next stage may proceed to real completed-order dual-account UAT. Production acceptance remains blocked until real app submit and credit ledger proof pass.

## 8. Current Minimum Loop

Minimum completed loop:

1. local Server source reviewed;
2. local Server build passed;
3. local targeted gating tests passed;
4. cloud DB unique direction index verified;
5. cloud runtime dist fingerprint verified;
6. 8080 route materialization verified.

## 9. Retained But Not Opened

Retained:

- legacy `/api/app/rating/*`;
- old `order_rating` source type for historical rating flow;
- real dual-account UAT as separate gate.

Not opened:

- manual DB insertion of completed order or rating;
- bypassing auth with actor hints for business acceptance;
- claiming credit ledger closure without real rating submit.

## 10. Stability / Cost / Stage Fit

- More stable: rely on Server truth plus DB unique index, not Flutter-only button hiding.
- More cost-efficient: no code rewrite; verify existing implementation and schema.
- More suitable for the current stage: close the Server gating gate before rerunning real dual-account UAT.
- Higher risk: treating UI route probes as proof of duplicate-submit behavior.
