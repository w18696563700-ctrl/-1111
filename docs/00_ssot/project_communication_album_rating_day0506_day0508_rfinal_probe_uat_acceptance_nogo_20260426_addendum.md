---
owner: Codex 总控
status: frozen
layer: L0 R-final probe and acceptance receipt
recorded_at_local: 2026-04-26
scope:
  - 2026-05-06 Server+BFF final probe
  - 2026-05-07 Computer Use double-account UAT
  - 2026-05-08 final acceptance pack
purpose: >
  Freeze the final route/schema/rollback probe evidence and record the final
  acceptance decision. Routes and schema are ready, but real double-account UAT
  and business evidence remain No-Go due invalid App sessions and unfinished
  order state.
---

# Day05-06 Day05-08 R-Final Probe / UAT / Acceptance No-Go Receipt

## 1. Conclusion

Day05-06 route/schema/rollback readiness: **Pass**.

Day05-07 double-account Computer Use UAT: **No-Go**.

Day05-08 final acceptance / cutover: **No-Go**.

Reason:

- cloud BFF and Server health checks pass;
- order, completion, counterparty rating, and credit routes are materialized and
  reachable;
- migration schema contains the required order/rating/credit tables and
  `source_type` columns;
- rollback targets remain present;
- but the real App sessions are invalid or incomplete, the order remains
  `active / none`, ratings remain `0`, and rating-driven credit trigger/ledger
  rows remain `0`.

This is a route/schema readiness pass, not a production acceptance pass.

## 2. Day05-06 R-Final Probe

### 2.1 Cloud Runtime

| Item | Value |
| --- | --- |
| Server current | `/srv/releases/server/20260426033000-order-detail-anchors` |
| BFF current | `/srv/releases/bff/20260426035500-bff-order-detail-anchors/apps/bff` |
| `exhibition-server` | `active` |
| `exhibition-bff` | `active` |
| Server rollback candidate | `/srv/releases/server/20260425204500-order-detail-projectid-cloud-patch` |
| BFF rollback candidate | `/srv/releases/bff/20260425204500-order-detail-projectid-cloud-patch` |

### 2.2 Health Probe Through 8080 Tunnel

| Route | Result |
| --- | --- |
| `GET /health/bff/live` | `200` |
| `GET /health/bff/ready` | `200` |
| `GET /health/server/live` | `200` |
| `GET /health/server/ready` | `200` |

### 2.3 App-Facing Route Reachability

Unauthenticated or empty-payload probes are expected to return `401` or
controlled `400`, not `404`.

| Route | Probe result | Ruling |
| --- | ---: | --- |
| `GET /api/app/order/detail` | `401 AUTH_SESSION_INVALID` | Route reachable, auth gate active. |
| `POST /api/app/order/complete/request` | `400 PROJECT_ORDER_COMPLETE_INVALID` | Route reachable, payload gate active. |
| `POST /api/app/order/complete/confirm` | `400 PROJECT_ORDER_COMPLETE_INVALID` | Route reachable, payload gate active. |
| `GET /api/app/project-counterparty-rating/entry` | `401 AUTH_SESSION_INVALID` | Route reachable, auth gate active. |
| `POST /api/app/project-counterparty-rating/submit` | `400 PROJECT_COUNTERPARTY_RATING_INVALID` | Route reachable, truth-anchor gate active. |
| `GET /api/app/profile/organization-credit-scoring/status` | `401` | Credit route reachable, visibility/auth gate active. |
| `GET /api/app/profile/credit-and-constraints/status` | `401 AUTH_SESSION_INVALID` | Credit/constraint route reachable, auth gate active. |

### 2.4 Materialized Route Files

BFF:

- `apps/bff/src/routes/order/app-order-completion.controller.ts`
- `apps/bff/src/routes/project_counterparty_rating/app-project-counterparty-rating.controller.ts`
- `apps/bff/src/routes/profile/app-profile-read.controller.ts`
- `apps/bff/src/routes/trading_read_corridor/app-trading-read-corridor.controller.ts`

Server:

- `apps/server/src/modules/order/project-order-completion.controller.ts`
- `apps/server/src/modules/project_counterparty_rating/project-counterparty-rating.controller.ts`
- `apps/server/src/modules/credit_scoring_shadow/organization-credit-scoring.controller.ts`
- `apps/server/src/modules/credit_constraints/credit-constraints.controller.ts`
- `apps/server/src/modules/trading_read_corridor/trading-read-corridor.controller.ts`

### 2.5 Migration / Schema Evidence

Read-only DB schema probe:

| Item | Value |
| --- | --- |
| `server_schema_migration` count | `58` |
| latest migration | `20260602_credit_shadow_source_type_truth` |
| order migration present | `20260520_project_order_truth_state_machine` |
| rating migration present | `20260428_project_counterparty_rating_truth` |
| project communication / album migration present | `20260428_project_communication_and_album_truth` |
| `orders` table | exists |
| `project_counterparty_ratings` table | exists |
| credit trigger table | exists |
| credit ledger table | exists |
| trigger `source_type` column | exists |
| ledger `source_type` column | exists |

Ruling:

- schema is aligned for order completion, counterparty rating, and credit bridge;
- no migration dry-run write was performed against production data;
- the evidence is read-only schema verification.

## 3. Current Business Truth

Read-only DB business state:

| Item | Value |
| --- | --- |
| orderId | `a3c63f04-8c10-44d1-9e0c-710ae00c7211` |
| projectId | `c788eaff-6243-4e97-8be3-c4e174ee7944` |
| buyerOrganizationId | `e6bf4567-016e-45f9-9420-9c950237690e` |
| supplierOrganizationId | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |
| order state | `active` |
| completionRequestState | `none` |
| completedAt | `NULL` |
| ratings for order | `0` |
| `project_counterparty_rating` credit triggers | `0` |
| `project_counterparty_rating` credit ledgers | `0` |

## 4. Day05-07 Computer Use UAT Ruling

Computer Use cannot complete the double-account UAT.

Observed App state:

- message center shows:
  - `Request must include a forwardable auth transport carrier or actor hint
    (authorization, x-actor-id, or x-user-id header).`
- another visible window can browse the exhibition home surface, but does not
  prove a valid publisher/buyer or supplier/contractor authenticated session.

Therefore:

- no `申请完工` retry is allowed until a valid supplier session is visible;
- no `确认完成` action is allowed until a valid publisher session is visible;
- no rating submit is allowed before order completion;
- no final UAT pass can be claimed.

## 5. Day05-08 Final Acceptance Pack

### 5.1 Release Note

Current R-final candidate contains:

- counterpart conversation order card entrance;
- order detail read corridor with order/project anchors;
- order completion request/confirm/reject route family;
- project counterparty rating entry/submit route family;
- credit shadow `source_type` bridge schema;
- Flutter order/rating/counterpart conversation controlled UI states.

### 5.2 Cutover Decision

Cutover status: **No-Go**.

Allowed:

- keep route/schema candidate as a checkpoint;
- keep gray UAT available;
- resume real UAT when two logged-in windows are restored;
- reuse the existing real order.

Not allowed:

- production acceptance announcement;
- full cutover;
- cleanup of fallback routes;
- manual DB mutation to set order completed or rating rows;
- treating `401/400` route reachability as business completion.

### 5.3 Rollback Position

No rollback is executed.

Rollback should be used only for runtime regression. The current blocker is
invalid App session plus unfinished business state, not a proven route/schema
runtime regression.

Known rollback targets:

- Server: `/srv/releases/server/20260425204500-order-detail-projectid-cloud-patch`
- BFF: `/srv/releases/bff/20260425204500-order-detail-projectid-cloud-patch`

## 6. Final Gate Checklist

| Gate | Result | Notes |
| --- | ---: | --- |
| Health checks | Pass | BFF/Server live and ready are `200`. |
| Order route reachability | Pass | `order/detail` and completion routes reachable with controlled auth/payload gates. |
| Rating route reachability | Pass | entry/submit routes reachable with controlled auth/truth-anchor gates. |
| Credit route reachability | Pass | credit status routes reachable with auth/visibility gates. |
| Migration/schema alignment | Pass | order/rating/credit tables and source_type columns exist. |
| Rollback target presence | Pass | previous order-detail release targets exist. |
| Valid double-account App sessions | Fail | Auth/session carrier unavailable in visible App state. |
| Real order completion | Fail | order remains `active / none`. |
| Real bilateral ratings | Fail | rating count remains `0`. |
| Real credit ledger evidence | Fail | project-counterparty-rating ledger count remains `0`. |
| Production acceptance | Blocked | Cannot write 100% production pass. |

## 7. Remaining Required Action

To convert this No-Go to Pass:

1. restore a valid supplier/contractor App session;
2. restore a valid publisher/buyer App session;
3. supplier requests completion through UI;
4. DB proves `completion_request_state=requested`;
5. publisher confirms completion through UI;
6. DB proves `orders.state=completed` and `completed_at IS NOT NULL`;
7. buyer rates supplier through UI;
8. supplier rates buyer through UI;
9. DB proves two opposite `project_counterparty_ratings` directions;
10. DB proves trigger and ledger rows with
    `source_type=project_counterparty_rating`.

## 8. Stability / Cost / Stage Fit

- More stable: keep final acceptance as No-Go until real UI and DB evidence are
  complete.
- More cost-efficient: reuse the existing real order and current R-final
  candidate; do not recreate data.
- More suitable for the current stage: repair/restore App login sessions, then
  rerun the same UAT script.
- Higher risk: bypassing UI with DB/API writes or treating route probes as final
  business acceptance.
