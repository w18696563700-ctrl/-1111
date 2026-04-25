---
owner: Codex 总控
status: frozen
layer: L0 full-chain UAT rerun receipt
scheduled_day: 2026-06-04 / 2026-06-05
execution_recorded_at_local: 2026-04-26
purpose: Record the attempted continuation of the dual-account full-chain UAT after the cloud Server/BFF runtime was aligned to the bid-candidate detail patch.
---

# Project Transaction Lifecycle Day06-04 Day06-05 Dual Account Full Chain UAT Rerun 20260426 No-Go Receipt

## 1. Conclusion

The remaining Day06-04 / Day06-05 full-chain UAT is still **No-Go** in this rerun.

The code/runtime blocker found earlier was fixed and released:

- owner-side project detail read model now exposes owner-only `bidCandidates`;
- BFF now carries `bidCandidates` / `bidSelection` to Flutter;
- cloud Server current is `20260426013000-project-detail-bid-candidates`;
- cloud BFF current is `20260426013000-project-detail-bid-candidates`;
- both cloud services are active;
- credit trigger / ledger tables both expose `source_type`.

The current blocker is no longer route/schema/materialization. The current blocker is the real App session gate:

- Computer Use can operate only one visible `mobile` window;
- that window is currently on the login page and shows `尚未登录`;
- no second visible Flutter session with the buyer/publisher account is available;
- no authenticated buyer action can be executed through the App.

Therefore the following production UAT actions were not executed:

- publisher selects the submitted bidder;
- Server creates a real `ProjectOrder`;
- seller requests completion;
- buyer confirms completion;
- buyer and seller submit real `ProjectCounterpartyRating`;
- credit shadow trigger / ledger rows are created from real rating submission.

No manual DB mutation was performed. No internal actor hint, demo session, rollback transaction, or old `/api/app/rating/submit` shortcut is promoted as production验收.

## 2. Current Minimum Loop

Minimum verified in this rerun:

1. cloud Server/BFF are active on the latest bid-candidate runtime;
2. tunnel can reach BFF;
3. cloud DB has one preserved real project;
4. cloud DB has one preserved real bid;
5. cloud DB still has zero orders, zero completed orders, zero counterparty ratings, zero rating credit triggers, and zero rating credit ledgers;
6. credit `source_type` columns exist on both trigger and ledger tables;
7. the local App session is not currently authenticated.

This is enough to record a truthful No-Go and a precise resume point. It is not enough for production acceptance.

## 3. Cloud Runtime Gate

| Item | Value | Result |
|---|---|---:|
| Server current | `/srv/releases/server/20260426013000-project-detail-bid-candidates` | Pass |
| BFF current | `/srv/releases/bff/20260426013000-project-detail-bid-candidates/apps/bff` | Pass |
| `exhibition-server.service` | `active` | Pass |
| `exhibition-bff.service` | `active` | Pass |
| local tunnel | `127.0.0.1:8080 -> cloud :80` | Pass |

## 4. Schema / Data Snapshot

Read-only DB snapshot:

| Object | Count |
|---|---:|
| projects | `1` |
| bids | `1` |
| orders | `0` |
| completed orders | `0` |
| project_counterparty_ratings | `0` |
| `project_counterparty_rating` credit triggers | `0` |
| `project_counterparty_rating` credit ledgers | `0` |

Credit source columns:

| Column | Result |
|---|---:|
| `organization_shadow_credit_recompute_triggers.source_type` | Present |
| `organization_shadow_credit_ledgers.source_type` | Present |

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

## 5. Computer Use State

Computer Use observation in this rerun:

| Item | Value | Result |
|---|---|---:|
| visible app | `mobile` / `com.example.mobile` | Pass |
| visible login state | `尚未登录` | Blocks |
| accessible buyer/publisher session | Not present | Blocks |
| accessible seller/bidder session | Not present in the active visible window | Blocks |
| visible second `mobile` window | Not present | Blocks |

Local process inspection found more than one `mobile.app` process, but macOS accessibility exposes only one usable window. A background process without a visible, operable window is not valid production UAT evidence.

## 6. Gate Checklist

| Gate | Result | Blocks |
|---|---:|---|
| Cloud Server/BFF active | Pass | No |
| Latest project detail bid-candidate patch deployed | Pass | No |
| Credit `source_type` schema aligned | Pass | No |
| Real project exists | Pass | No |
| Real submitted bid exists | Pass | No |
| Buyer Flutter session visible and logged in | Fail | Yes |
| Seller Flutter session visible and logged in | Fail in current active window | Yes |
| Publisher selects bidder through UI | Not run | Yes |
| Order generated with `projectId/orderId/buyerOrgId/sellerOrgId` | Not run | Yes |
| Seller requests completion through UI | Not run | Yes |
| Buyer confirms completion through UI | Not run | Yes |
| Buyer -> seller rating through UI | Not run | Yes |
| Seller -> buyer rating through UI | Not run | Yes |
| Credit trigger/ledger DB proof | Not present | Yes |

Decision: **No-Go for Day06-04 / Day06-05 production UAT acceptance**.

## 7. What Is Done

Done and retained:

- Server/BFF runtime is aligned to the bid-candidate project detail patch.
- Owner-only bid candidate projection is available in source/runtime.
- BFF response shaping keeps bid selection data at the App boundary.
- Credit schema can now record `source_type=project_counterparty_rating`.
- The preserved real project and real bid are still clean enough to resume UAT.

## 8. What Is Not Done

Not done:

- no real order row exists;
- no completed order exists;
- no real `ProjectCounterpartyRating` exists;
- no rating-derived credit trigger / ledger rows exist;
- no two-account Computer Use production验收 has passed.

## 9. Required Resume Procedure

To continue without weakening验收口径:

1. Open two visible `mobile` windows or run a controlled account-switch procedure.
2. Window A must be logged in as the buyer / publisher organization `重庆坤特展览展示有限公司`.
3. Window B must be logged in as the seller / bidder organization `重庆展宏展览展示有限公司`.
4. In Window A, open `EXH-2026-DD93A8 / 西洽会 - 泸州`, select bid `6e936969-3520-44bc-8804-1c804351423e`, and create the order.
5. Confirm DB has a new `orders` row carrying `project_id / id / buyer_organization_id / supplier_organization_id`.
6. In Window B, request completion.
7. In Window A, confirm completion.
8. Submit buyer -> seller rating and seller -> buyer rating through the new `ProjectCounterpartyRating` UI.
9. Confirm DB has two `project_counterparty_ratings` rows and rating-derived credit trigger / ledger rows.

## 10. Stability / Cost / Stage Fit

- More stable: stop at No-Go when real login sessions are missing.
- More cost-efficient: keep the existing real project and bid, then resume only the missing UI actions after login is restored.
- More suitable for the current stage: treat this as a production UAT gate, not as a developer shortcut test.
- Higher risk: using demo sessions, actor hints, or DB writes to manufacture order/rating/credit rows and label them as real dual-account验收.
