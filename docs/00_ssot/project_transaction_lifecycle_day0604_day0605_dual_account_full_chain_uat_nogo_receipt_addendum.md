---
owner: Codex 总控
status: frozen
layer: L0 full-chain UAT receipt
scheduled_day: 2026-06-04 / 2026-06-05
execution_recorded_at_local: 2026-04-26
purpose: Record the attempted dual-account full-chain UAT for bid award, order completion, mutual counterparty rating, and credit trigger/ledger proof.
---

# Project Transaction Lifecycle Day06-04 Day06-05 Dual Account Full Chain UAT No-Go Receipt

## 1. Conclusion

Day06-04 / Day06-05 full-chain production UAT is **No-Go** in this run.

The cloud runtime and route surfaces are reachable, and the real data baseline contains one real project and one real bid. However, the actual Computer Use environment currently provides only one usable Flutter account session:

- current visible app account: `江北嘴嘴帅`;
- current visible organization: `重庆展宏展览展示有限公司`;
- role in the target chain: bidder / seller;
- target project owner / buyer organization: `重庆坤特展览展示有限公司`;
- buyer account is not currently available in a second Flutter window/session.

Therefore the required buyer-side actions cannot be executed through real UI:

- publisher selects bidder and creates order;
- buyer confirms completion;
- buyer submits buyer -> seller counterparty rating.

No manual DB mutation was performed. No order, rating, credit trigger, or credit ledger was inserted manually.

This receipt records the No-Go honestly. It must not be read as production acceptance.

## 2. Current Minimum Loop

Minimum verified in this run:

1. cloud Server/BFF runtime is active;
2. tunnel reaches app-facing BFF routes;
3. DB contains the real preserved project;
4. DB contains one real bid from the current seller organization;
5. Computer Use can see the seller organization session;
6. DB confirms zero orders, zero counterparty ratings, and zero `project_counterparty_rating` credit rows.

This is enough for preflight/no-go evidence. It is not enough for Day06-04/05 pass.

## 3. Cloud Runtime Gate

| Item | Value | Result |
|---|---|---:|
| Server current | `/srv/releases/server/20260425204500-order-detail-projectid-cloud-patch` | Pass |
| BFF current | `/srv/releases/bff/20260425204500-order-detail-projectid-cloud-patch/apps/bff` | Pass |
| `exhibition-server.service` | `active` | Pass |
| `exhibition-bff.service` | `active` | Pass |
| local tunnel | `127.0.0.1:8080 -> cloud :80` | Pass |

## 4. Account Matrix

| Business side | Organization | User/person | Availability in Computer Use | Result |
|---|---|---|---:|---:|
| Buyer / publisher | `重庆坤特展览展示有限公司` | `重庆海川展览工厂` | Not available in visible Flutter session | Blocks UAT |
| Seller / bidder | `重庆展宏展览展示有限公司` | `江北嘴嘴帅` | Available in visible Flutter session | Pass |

DB role anchors:

| Anchor | Value |
|---|---|
| buyerOrganizationId | `e6bf4567-016e-45f9-9420-9c950237690e` |
| buyer organization name | `重庆坤特展览展示有限公司` |
| buyer userId | `99c99709-3786-4d8a-a0c3-5e1a0e945821` |
| buyer nickname | `重庆海川展览工厂` |
| sellerOrganizationId | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |
| seller organization name | `重庆展宏展览展示有限公司` |
| seller userId | `ebb8d922-e7da-43fa-897b-360214dfd6e4` |
| seller nickname | `江北嘴嘴帅` |

Computer Use evidence:

- `我的` page shows `江北嘴嘴帅 / 当前账号：已登录`;
- `我的公司` page shows `重庆展宏展览展示有限公司 / 当前主体可发布项目 / 可参与竞标`;
- no second `mobile` process/window with buyer session was available during this run.

## 5. DB Before/After Snapshot

The DB snapshot remained unchanged by this run.

| Object | Count |
|---|---:|
| projects | `1` |
| bids | `1` |
| orders | `0` |
| project_counterparty_ratings | `0` |
| `project_counterparty_rating` credit triggers | `0` |
| `project_counterparty_rating` credit ledgers | `0` |

Project anchor:

| Field | Value |
|---|---|
| projectId | `c788eaff-6243-4e97-8be3-c4e174ee7944` |
| projectNo | `EXH-2026-DD93A8` |
| title | `西洽会 - 泸州` |
| ownerOrganizationId | `e6bf4567-016e-45f9-9420-9c950237690e` |
| ownerOrganizationName | `重庆坤特展览展示有限公司` |
| state | `published` |

Bid anchor:

| Field | Value |
|---|---|
| bidId | `6e936969-3520-44bc-8804-1c804351423e` |
| projectId | `c788eaff-6243-4e97-8be3-c4e174ee7944` |
| bidderOrganizationId | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |
| bidderOrganizationName | `重庆展宏展览展示有限公司` |
| state | `submitted` |

No order anchor exists yet:

- no `orderId`;
- no `buyerOrganizationId` / `supplierOrganizationId` persisted on `orders`;
- no `completed_at`;
- no rating rows;
- no credit rows.

## 6. Route Materialization Probe

These probes only prove app-facing route materialization. They do not prove business success.

| Probe | Result | Meaning |
|---|---|---|
| `POST /api/app/bid/select-bid-and-create-order` with empty body | `400 BID_AWARD_INVALID` | Route exists and validates payload. |
| `POST /api/app/order/complete/request` with empty body | `400 PROJECT_ORDER_COMPLETE_INVALID` | Route exists and validates payload. |
| `POST /api/app/order/complete/confirm` with empty body | `400 PROJECT_ORDER_COMPLETE_INVALID` | Route exists and validates payload. |
| `POST /api/app/project-counterparty-rating/submit` with empty body | `400 PROJECT_COUNTERPARTY_RATING_INVALID` | Route exists and requires `orderId`. |
| `GET /api/app/order/detail?...` without login carrier | `401 AUTH_SESSION_INVALID` | Auth-gated read route. |
| `GET /api/app/project-counterparty-rating/entry?...` without login carrier | `401 AUTH_SESSION_INVALID` | Auth-gated read route. |

## 7. Gate Checklist

| Gate | Result | Blocks |
|---|---:|---|
| Cloud Server/BFF active | Pass | No |
| Tunnel reaches app-facing routes | Pass | No |
| Real project exists | Pass | No |
| Real bid exists | Pass | No |
| Buyer Flutter session visible | Fail | Yes |
| Seller Flutter session visible | Pass | No |
| Publisher selects bidder through UI | Not run | Yes |
| Order generated with `projectId/orderId/buyerOrgId/sellerOrgId` | Not run | Yes |
| Seller requests completion through UI | Not run | Yes |
| Buyer confirms completion through UI | Not run | Yes |
| Buyer -> seller rating through UI | Not run | Yes |
| Seller -> buyer rating through UI | Not run | Yes |
| Credit trigger/ledger DB proof | Not present | Yes |

Decision: **No-Go for Day06-04 / Day06-05 production UAT acceptance**.

## 8. Not Claimed

This receipt does not claim:

- dual-account UI UAT passed;
- order generation passed;
- order completion passed;
- either side submitted a real counterparty rating;
- credit trigger/ledger proof exists for a real submitted rating;
- production acceptance is complete.

## 9. Manual DB Mutation Statement

Manual DB mutation in this run: **No**.

Forbidden shortcuts were not used:

- no manual `orders` insert/update;
- no manual `project_counterparty_ratings` insert;
- no manual credit trigger/ledger insert;
- no rollback-transaction proof promoted to production UAT;
- no actor-hint request promoted to real-login UAT;
- no old `/api/app/rating/submit` used to replace `ProjectCounterpartyRating`.

## 10. Current Blocker And Next Required Action

Required to continue:

1. Open or restore a second Flutter `mobile` instance/session logged in as `重庆海川展览工厂 / 重庆坤特展览展示有限公司`.
2. Keep the current seller session `江北嘴嘴帅 / 重庆展宏展览展示有限公司` available.
3. Rerun Day06-04:
   - buyer selects `bidId=6e936969-3520-44bc-8804-1c804351423e`;
   - Server creates an order anchored to `projectId / orderId / buyerOrganizationId / supplierOrganizationId`.
4. Rerun Day06-05:
   - seller requests completion;
   - buyer confirms completion;
   - buyer rates seller;
   - seller rates buyer;
   - DB read-only checks confirm rating rows plus credit trigger/ledger rows with `source_type=project_counterparty_rating`.

## 11. Stability / Cost / Stage Fit

- More stable: stop at No-Go when the buyer session is missing, instead of inventing order/rating/ledger truth.
- More cost-efficient: use the existing real project and bid once both sessions are available.
- More suitable for the current stage: preserve this as a UAT/no-go receipt and rerun only the missing real-account actions.
- Higher risk: manually creating `orders`, ratings, or credit ledger rows and labeling that as production验收.
