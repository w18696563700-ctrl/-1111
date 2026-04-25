---
owner: Codex 总控
status: frozen
layer: L0 execution receipt
scheduled_day: 2026-06-03
execution_recorded_at_local: 2026-04-25
purpose: Record Day34 BFF + Flutter completion for routing the final rating entry to ProjectCounterpartyRating instead of legacy rating/submit.
---

# Project Transaction Lifecycle Day34 BFF + Flutter Counterparty Rating Entry Receipt

## 1. Conclusion

Day34 local BFF / Flutter execution is complete.

This receipt records:

- BFF `project-counterparty-rating` app-facing routes are already materialized and verified.
- Flutter `RatingEntryPage` now consumes `GET /api/app/project-counterparty-rating/entry`.
- Flutter rating submit now uses `POST /api/app/project-counterparty-rating/submit`.
- The rating page requires `orderId / projectId / rateeOrganizationId`.
- Order status / order detail only opens the rating page when the completed order can safely derive the ratee organization from `buyerOrganizationId / sellerOrganizationId` and the current account organization.
- The route from message order business cards preserves `projectId` into `OrderDetailPage`.
- The avatar subject sheet remains the primary safe rating entry when the conversation projection carries `ratingEntry`.

This receipt does not claim:

- Server Day32-Day33 local source has been released to Aliyun.
- a real completed-order dual-account submit has been executed.
- cloud DB verification for rating truth / credit shadow / ledger rows.
- production acceptance.

## 2. Current Minimum Loop

Minimum loop now admitted locally:

1. BFF exposes `GET /api/app/project-counterparty-rating/entry`.
2. BFF exposes `POST /api/app/project-counterparty-rating/submit`.
3. Flutter opens the rating page only with `orderId / projectId / rateeOrganizationId`.
4. Flutter submits `scoreLabel` and optional `commentText` to the new route.
5. Flutter refreshes:
   - counterparty rating entry
   - order detail
   - my project list

The old `POST /api/app/rating/submit` is not used by the Day34 rating page or avatar sheet path.

## 3. BFF Gate

| Gate | Result | Evidence |
|---|---:|---|
| New route family exists | Pass | `AppProjectCounterpartyRatingController` mounted under `api/app/project-counterparty-rating`. |
| Entry forwards to Server truth | Pass | Service forwards to `/server/project-counterparty-rating/entry`. |
| Submit forwards to Server truth | Pass | Service forwards to `/server/project-counterparty-rating/submit`. |
| Required anchors enforced | Pass | BFF test rejects missing `projectId / rateeOrganizationId`. |
| Old `/rating/submit` not mixed into new module | Pass | New transport tests capture only `/server/project-counterparty-rating/*`. |

No BFF source rewrite was needed for Day34 because the required route module already matched the frozen contract.

## 4. Flutter Gate

| Gate | Result | Evidence |
|---|---:|---|
| Rating page no longer reads old entry | Pass | `RatingEntryPage` calls `loadProjectCounterpartyRatingEntry`. |
| Rating page no longer submits old rating | Pass | Submit calls `submitProjectCounterpartyRating`. |
| Three anchors required | Pass | Missing `orderId / projectId / rateeOrganizationId` returns controlled not-found state. |
| Order card does not infer ratee unsafely | Pass | New route opens only when completed order plus current org plus buyer/seller org anchors exist. |
| Order detail missing anchors remains safe | Pass | It shows controlled guidance and does not call the old rating path. |
| Avatar sheet remains new truth submit | Pass | Existing path submits `orderId / projectId / rateeOrganizationId / scoreLabel / commentText`. |
| Submit refreshes state | Pass | Rating page refreshes entry, order detail, and my project list after accepted submit. |

## 5. Verification

Local BFF targeted test:

| Command | Result |
|---|---:|
| `node --test test/project-counterparty-rating-transport.test.cjs` | Pass, `5/5`. |

Local Flutter targeted tests:

| Command | Result |
|---|---:|
| `flutter test test/rating_entry_test.dart test/counterpart_conversation_chat_test.dart` | Pass, `15/15`. |
| `flutter test test/shell_app_test.dart --plain-name "counterparty rating entry route reaches the new app-facing read request"` | Pass. |
| `flutter test test/shell_app_test.dart --plain-name "order detail enters read-only content from route orderId and exposes contract detail plus rating entry continuation actions"` | Pass. |

Local Flutter static check:

| Command | Result |
|---|---:|
| `flutter analyze lib/features/exhibition/presentation/pages/rating_entry_page.dart lib/features/exhibition/presentation/presentation_support/order_status_card.dart lib/features/exhibition/presentation/pages/order_detail_page.dart lib/features/exhibition/data/exhibition_consumer_layer.dart lib/features/exhibition/data/services/exhibition_contract_validation.dart` | Pass. |

8080 tunnel route probes:

| Probe | Result | Meaning |
|---|---|---|
| `GET /api/app/project-counterparty-rating/entry?orderId=day34-order&projectId=day34-project&rateeOrganizationId=day34-ratee` | `401 AUTH_SESSION_INVALID` | Route is materialized and auth-gated; no route-level `404`. |
| `POST /api/app/project-counterparty-rating/submit` | `401 AUTH_SESSION_INVALID` | Submit route is materialized and auth-gated; no route-level `404`. |

## 6. Stage Gate Checklist

| Gate | Passed | Failed | Veto | Next Stage |
|---|---:|---:|---:|---|
| SSOT / route truth says new counterparty rating owns this flow | Yes | No | No | Allowed. |
| BFF route exists and preserves Server truth ownership | Yes | No | No | Allowed. |
| Flutter no longer uses legacy `rating/submit` for this entry | Yes | No | No | Allowed. |
| Three-anchor boundary enforced | Yes | No | No | Allowed. |
| Real dual-account completed-order cloud UAT | No | Yes | No | Blocks production claim only. |
| Cloud DB credit-shadow verification | No | Yes | No | Blocks production claim only. |

Next stage is allowed only as integration / release verification, not as production acceptance.

## 7. Retained But Not Opened

Retained:

- Legacy `/api/app/rating/entry`.
- Legacy `/api/app/rating/submit`.

These remain historical order-rating surfaces and are not the Day34 counterparty-rating path.

Not opened:

- rating history
- rating detail page
- moderation review workflow
- appeal workflow
- public credit score display after submit

## 8. Expansion Slots

Future expansion may add:

- completed-order fixture creator for cloud UAT
- dual-account Computer Use submit script
- DB probe for `project_counterparty_ratings`
- DB probe for `organization_shadow_credit_recompute_triggers.source_type`
- DB probe for `organization_shadow_credit_ledgers.source_type`
- rating history / dispute / appeal only after a separate truth freeze

## 9. Stability / Cost / Stage Fit

- More stable: keep `ProjectCounterpartyRating` as the only new mutual-rating truth and keep old `rating/submit` out of this UI path.
- More cost-efficient: reuse current BFF route module and Flutter page shell instead of deleting legacy rating routes.
- More suitable for the current stage: make the safe local client switch now, while leaving production claim gated by completed-order dual-account UAT.
- Higher risk: inferring `rateeOrganizationId` from only `orderId`, or deleting old `RatingModule` without a separate compatibility gate.
