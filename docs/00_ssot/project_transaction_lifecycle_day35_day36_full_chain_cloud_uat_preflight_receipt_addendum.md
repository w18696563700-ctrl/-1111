---
owner: Codex 总控
status: frozen
layer: L0 cloud UAT preflight receipt
scheduled_days:
  - 2026-06-04
  - 2026-06-05
execution_recorded_at_local: 2026-04-25
purpose: Record the current cloud preflight result before dual-account full-chain UAT for project publish, bid, bid selection, order completion, counterparty rating, and credit shadow/ledger verification.
---

# Project Transaction Lifecycle Day35-Day36 Full-Chain Cloud UAT Preflight Receipt

## 1. Conclusion

This is a preflight receipt, not a completed dual-account UAT receipt.

Current result:

- Day35 `发布项目 -> 承接方竞标 -> 发布方选中 -> 生成订单` is route-materialized and has cloud seed data, but has not been executed through two real logged-in accounts in this run.
- Day36 `订单完成 -> 双方互评 -> 信用触发` is **No-Go for production acceptance** right now.
- The cloud database currently has no completed orders, no `ProjectCounterpartyRating` rows, and no credit trigger / ledger rows.
- The cloud credit trigger / ledger tables do not yet expose the Day33 local `source_type` field, so the new `project_counterparty_rating` credit-source proof cannot be completed on the active cloud runtime.
- Computer Use currently sees one logged-in `mobile` window/account only; a true dual-account click UAT needs two logged-in actors or a controlled account-switch procedure.

Therefore, the stable next move is:

1. align cloud Server release / schema for Day32-Day34 source, especially credit `source_type`;
2. open or provide two logged-in app sessions;
3. then execute the real Day35 / Day36 Computer Use UAT and DB proof.

## 2. Cloud Current Runtime

Read-only SSH probe at `2026-04-25 18:10 CST`:

| Item | Value |
|---|---|
| Server current | `/srv/releases/server/20260425161006-p0-pay-day20-message-carry` |
| BFF current | `/srv/releases/bff/20260425154325-day29-bff-runtime-routes/apps/bff` |
| `exhibition-server` | `active` |
| `exhibition-bff` | `active` |
| `nginx` | `active` |

Meaning:

- Cloud is live and reachable.
- Current Server is not proven to include the latest Day32-Day34 local source.
- Current BFF does expose the needed app-facing route families at the auth boundary.

## 3. Route Materialization Probe

All probes below were unauthenticated. A controlled `401` means the route exists and is auth-gated; it is not a route-level `404`.

| Route | Result | Gate |
|---|---|---|
| `POST /api/app/project/create` | `401 AUTH_SESSION_INVALID` | Pass, auth-gated. |
| `POST /api/app/project/publish` | `401 AUTH_SESSION_INVALID` | Pass, auth-gated. |
| `POST /api/app/bid/submit` | `401 AUTH_SESSION_INVALID` | Pass, auth-gated. |
| `POST /api/app/bid/select-bid-and-create-order` | `401 AUTH_SESSION_INVALID` | Pass, auth-gated. |
| `GET /api/app/order/detail` | `401 AUTH_SESSION_INVALID` | Pass, auth-gated. |
| `POST /api/app/order/complete/request` | `401 AUTH_SESSION_INVALID` | Pass, auth-gated. |
| `POST /api/app/order/complete/confirm` | `401 AUTH_SESSION_INVALID` | Pass, auth-gated. |
| `GET /api/app/project-counterparty-rating/entry` | `401 AUTH_SESSION_INVALID` | Pass, auth-gated. |
| `POST /api/app/project-counterparty-rating/submit` | `401 AUTH_SESSION_INVALID` | Pass, auth-gated. |
| `GET /api/app/profile/organization-credit-scoring/status` | `401 FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE` | Pass, reserve read surface exists and is gated. |
| `GET /api/app/profile/organization-credit-scoring/explanation` | `401 FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE` | Pass, reserve read surface exists and is gated. |
| `GET /api/app/profile/organization-credit-scoring/handoff` | `401 FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE` | Pass, reserve read surface exists and is gated. |

## 4. DB Schema Probe

Cloud DB connection source:

- Server unit uses `EnvironmentFile=/srv/apps/server/.env`.
- DB is `POSTGRES_HOST/POSTGRES_PORT/POSTGRES_DB/POSTGRES_USER/POSTGRES_PASSWORD`.
- Password was not printed.

Schema existence:

| Table | Result |
|---|---:|
| `project` | Present |
| `bids` | Present |
| `orders` | Present |
| `project_counterparty_ratings` | Present |
| `organization_shadow_credit_recompute_triggers` | Present |
| `organization_shadow_credit_ledgers` | Present |

Critical column probe:

| Column | Result |
|---|---:|
| `project_counterparty_ratings.rater_organization_id` | Present |
| `project_counterparty_ratings.ratee_organization_id` | Present |
| `project_counterparty_ratings.rating_state` | Present |
| `organization_shadow_credit_recompute_triggers.source_order_id` | Present |
| `organization_shadow_credit_recompute_triggers.source_rating_id` | Present |
| `organization_shadow_credit_recompute_triggers.source_type` | Missing |
| `organization_shadow_credit_ledgers.source_order_id` | Present |
| `organization_shadow_credit_ledgers.source_rating_id` | Present |
| `organization_shadow_credit_ledgers.source_type` | Missing |

Migration ledger:

- `server_schema_migration` contains `20260428_project_counterparty_rating_truth`.
- `server_schema_migration` contains `20260520_project_order_truth_state_machine`.
- It does not show the Day33 local `20260602_credit_shadow_source_type_truth` migration as applied.

## 5. DB Data Probe

Cloud DB counts:

| Object | Count |
|---|---:|
| `project` | 31 |
| `bids` | 30 |
| `orders` | 9 |
| completed orders | 0 |
| `project_counterparty_ratings` | 0 |
| credit recompute triggers | 0 |
| credit ledgers | 0 |

State distribution:

| Object | State | Count |
|---|---|---:|
| project | `published` | 21 |
| project | `converted_to_order` | 9 |
| project | `draft` | 1 |
| bids | `submitted` | 16 |
| bids | `awarded` | 9 |
| bids | `lost` | 3 |
| bids | `breach_hold` | 2 |
| orders | `active / none` | 9 |

Meaning:

- Day35 has enough cloud seed shape to attempt a real order-generation UAT.
- Day36 currently has no completed order to rate.
- Credit ledger cannot be verified until a real rating submit exists and cloud schema/source migration is aligned.

## 6. Computer Use State

Computer Use read-only observation:

- App `mobile` is running.
- Visible account: `江北嘴嘴帅`, logged in.
- Only one `mobile` window was visible through Computer Use.
- No second logged-in app window was available in this probe.

This blocks a true two-account UI UAT in this run.

## 7. Gate Checklist

| Gate | Result | Blocks |
|---|---:|---|
| Cloud services active | Pass | No |
| Day35 route materialization | Pass | No |
| Day36 route materialization | Pass | No |
| DB tables exist | Pass | No |
| Credit `source_type` cloud schema | Fail | Blocks credit-source proof. |
| Completed order exists | Fail | Blocks rating UAT. |
| Rating truth exists after real submit | Fail | Blocks credit trigger proof. |
| Credit trigger / ledger rows exist | Fail | Blocks Day36 acceptance. |
| Two logged-in UI accounts visible | Fail | Blocks Computer Use dual-account UAT. |

Next stage:

- Day35 can proceed only after two logged-in accounts are available, or after an explicit controlled account-switch plan is approved.
- Day36 cannot proceed to acceptance until cloud Server/schema is aligned and a completed order exists.

## 8. Current Minimum Loop

The current minimum completed loop is:

1. cloud route/current preflight;
2. cloud DB schema/data read-only preflight;
3. one visible app account UI state check;
4. No-Go decision for production UAT claim.

This is the lowest-cost, safest action for the current stage.

## 9. Retained But Not Opened

Retained:

- legacy `/api/app/rating/*`;
- direct DB fixtures;
- internal actor-hint headers;
- direct Server write calls;
- one-account shortcut testing.

Not opened:

- bypassing login by sending `x-user-id` / `x-actor-id` manually;
- direct DB mutation to create completed orders;
- claiming double-account UAT from route probes;
- claiming credit ledger closure from local tests only.

## 10. Expansion Slots

Next allowed execution package:

1. Release / migration gate:
   - switch cloud Server to the source containing Day32-Day34 rating / credit changes;
   - apply/verify `source_type` on credit trigger and ledger tables;
   - rerun auth-gated route probes.
2. Day35 UI UAT:
   - account A publishes project;
   - account B submits bid;
   - account A selects bid and creates order;
   - DB confirms one new `orders` row with correct `project_id / bid_id / buyer_organization_id / supplier_organization_id`.
3. Day36 UI UAT:
   - account B requests completion;
   - account A confirms completion;
   - both sides submit `ProjectCounterpartyRating`;
   - DB confirms `project_counterparty_ratings`, recompute triggers, and ledger rows.

## 11. Stability / Cost / Stage Fit

- More stable: align cloud release/schema before touching dual-account business data.
- More cost-efficient: route and DB read-only probes first; they already exposed the real blockers.
- More suitable for the current stage: treat today as preflight and gate correction, not as future-dated production acceptance.
- Higher risk: using internal auth hints, direct DB mutation, or one visible account to simulate two-account UAT.
