---
owner: Codex 总控
status: frozen
layer: L0 BFF + Flutter execution receipt
scheduled_day: 2026-06-03
execution_recorded_at_local: 2026-04-26
purpose: Record the final BFF + Flutter counterparty-rating entry alignment to ProjectCounterpartyRating with orderId/projectId/rateeOrganizationId anchors and no new-entry fallback to legacy rating/submit.
---

# Project Transaction Lifecycle Day06-03 BFF Flutter Counterparty Rating Entry Receipt

## 1. Conclusion

Day06-03 BFF + Flutter execution is complete at the local engineering and route-materialization gate.

The new mutual-rating entry now stays on `ProjectCounterpartyRating`:

- BFF exposes `GET /api/app/project-counterparty-rating/entry`;
- BFF exposes `POST /api/app/project-counterparty-rating/submit`;
- BFF requires `orderId / projectId / rateeOrganizationId` before forwarding;
- Flutter `RatingEntryPage` reads and submits through the new project-counterparty-rating route family;
- Flutter avatar subject sheet submits through the new route family;
- avatar sheet submit success now refreshes the parent counterpart conversation detail;
- new entry path no longer calls legacy `POST /api/app/rating/submit`.

This receipt does not claim:

- real dual-account completed-order submit passed through the app;
- production acceptance is complete;
- legacy `rating/*` is deleted.

Legacy `rating/*` remains retained as a compatibility surface only. It is not the new mutual-rating path.

## 2. Truth Boundary

| Layer | Responsibility | Result |
|---|---|---:|
| Server | Owns `ProjectCounterpartyRating`, completed-order gating, duplicate gating, credit bridge. | Preserved |
| BFF | Auth forwarding, required-anchor validation, controlled error mapping, app-facing shape. | Pass |
| Flutter | Displays entry, carries anchors, submits command, refreshes visible state. | Pass |
| Legacy `rating/submit` | Compatibility only. | Retained but not used by new entry |

The required truth anchors are:

- `orderId`;
- `projectId`;
- `rateeOrganizationId`.

`raterOrganizationId` is not accepted from Flutter as body truth. It remains derived from auth/session on the Server side.

## 3. BFF Gate

No BFF code change was required in this run because the current BFF source already satisfies the frozen Day06-03 contract.

Verified files:

| File | Verified gate |
|---|---|
| `apps/bff/src/routes/project_counterparty_rating/app-project-counterparty-rating.controller.ts` | Mounts `api/app/project-counterparty-rating`, with `entry` and `submit`. |
| `apps/bff/src/routes/project_counterparty_rating/project-counterparty-rating.service.ts` | Forwards to `/server/project-counterparty-rating/entry` and `/server/project-counterparty-rating/submit`. |
| `apps/bff/src/routes/project_counterparty_rating/project-counterparty-rating.service.ts` | Requires `orderId / projectId / rateeOrganizationId`; strips non-frozen fields such as `scoreValue` and `extraFlag`. |
| `apps/bff/src/routes/routes.module.ts` | Registers `ProjectCounterpartyRatingModule`. |

Old `apps/bff/src/routes/rating/*` remains present, but is not used by the new counterparty-rating UI path.

## 4. Flutter Gate

Flutter already used the new route family for the rating page and avatar sheet. This run closed the remaining refresh gap in the avatar sheet.

Changed files:

| File | Change |
|---|---|
| `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_subject_sheet.dart` | Adds `onRatingSubmitted` callback and invokes it after successful `ProjectCounterpartyRating` submit. |
| `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart` | Passes `_load` as the post-submit refresh callback for the avatar subject sheet. |
| `apps/mobile/test/counterpart_conversation_chat_test.dart` | Asserts successful avatar-sheet rating submit triggers counterpart conversation detail reload. |

Existing verified new-entry files:

| File | Verified gate |
|---|---|
| `apps/mobile/lib/features/exhibition/presentation/pages/rating_entry_page.dart` | Requires route `orderId / projectId / rateeOrganizationId`; reads entry and submits new command. |
| `apps/mobile/lib/features/exhibition/data/commands/rating_submit_command.dart` | `ProjectCounterpartyRatingSubmitCommand` carries `orderId / projectId / rateeOrganizationId / scoreLabel / commentText`. |
| `apps/mobile/lib/features/exhibition/data/services/exhibition_action_service.dart` | New submit uses `ExhibitionCanonicalPaths.projectCounterpartyRatingSubmit`. |
| `apps/mobile/lib/features/messages/data/counterpart_conversation_consumer_layer.dart` | Avatar sheet path validates anchors and posts to `project-counterparty-rating/submit`. |

## 5. Verification Evidence

BFF:

| Command | Result |
|---|---:|
| `npm run build` in `apps/bff` | Pass |
| `node --test test/project-counterparty-rating-transport.test.cjs test/rating-entry-submit.test.cjs` | Pass, `11/11`. |

Flutter:

| Command | Result |
|---|---:|
| `dart format apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_subject_sheet.dart apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart apps/mobile/test/counterpart_conversation_chat_test.dart` | Pass |
| `flutter test test/rating_entry_test.dart` | Pass, `2/2`. |
| `flutter test test/counterpart_conversation_chat_test.dart --plain-name "ended project avatar sheet submits rating once when server rating anchor allows it"` | Pass, `1/1`. |
| `flutter test test/shell_app_test.dart --plain-name "counterparty rating entry route reaches the new app-facing read request"` | Pass, `1/1`. |

Covered behaviors:

- rating page uses `GET /api/app/project-counterparty-rating/entry`;
- rating page uses `POST /api/app/project-counterparty-rating/submit`;
- rating page submit carries `orderId / projectId / rateeOrganizationId`;
- rating page does not call legacy `ratingSubmit`;
- avatar sheet submit carries `orderId / projectId / rateeOrganizationId`;
- avatar sheet duplicate tap submits only once;
- avatar sheet successful submit refreshes counterpart conversation detail;
- shell route passes all three anchors to `RatingEntryPage`.

## 6. Tunnel Probe

Unauthenticated 8080 probes are expected to return controlled `401`, not business data.

| Probe | Result | Meaning |
|---|---|---|
| `GET /api/app/project-counterparty-rating/entry?orderId=day0603-order&projectId=day0603-project&rateeOrganizationId=day0603-ratee` | `401 AUTH_SESSION_INVALID` | App route is reachable and auth-gated through tunnel. |
| `POST /api/app/project-counterparty-rating/submit` with all three anchors | `401 AUTH_SESSION_INVALID` | Submit route is reachable and auth-gated through tunnel. |

These probes prove route materialization only. They are not real-account business acceptance.

## 7. Stage Gate Checklist

| Gate | Result | Blocks |
|---|---:|---|
| BFF new entry route exists | Pass | No |
| BFF new submit route exists | Pass | No |
| BFF requires `orderId / projectId / rateeOrganizationId` | Pass | No |
| Flutter rating page requires all three anchors | Pass | No |
| Flutter rating page submits new route | Pass | No |
| Flutter avatar sheet submits new route | Pass | No |
| Flutter avatar sheet refreshes detail after success | Pass | No |
| New entry avoids legacy `rating/submit` | Pass | No |
| Legacy `rating/*` deletion | Not done | Does not block current stage |
| Real dual-account completed-order App submit | Not run | Blocks production acceptance only |

Next stage may proceed to dual-account completed-order UAT once a real order exists and both accounts are on the correct buyer/seller sides.

## 8. Current Minimum Loop

Current minimum closed loop:

1. BFF validates and forwards three-anchor entry/submit;
2. Flutter page entry requires three anchors;
3. Flutter avatar sheet consumes Server-provided `ratingEntry`;
4. both Flutter entry surfaces submit new `ProjectCounterpartyRating`;
5. submit success refreshes local UI state;
6. tests prove no new-entry call to old `rating/submit`;
7. 8080 route probe proves cloud app route is materialized and auth-gated.

## 9. Retained But Not Opened

Retained:

- legacy `GET /api/app/rating/entry`;
- legacy `POST /api/app/rating/submit`;
- old `RatingSubmitCommand` and `submitRating` compatibility code.

Not opened:

- deleting legacy rating routes;
- fallback from new mutual-rating UI to old one-anchor submit;
- Flutter inference of `rateeOrganizationId`;
- claiming production acceptance without real completed-order dual-account submit.

## 10. Stability / Cost / Stage Fit

- More stable: new mutual rating always carries `orderId / projectId / rateeOrganizationId` and lets Server derive rater identity.
- More cost-efficient: keep legacy `rating/*` compatibility code but isolate it from the new entry.
- More suitable for the current stage: finish BFF/Flutter consumption and refresh behavior before real dual-account UAT.
- Higher risk: deleting legacy `rating/*` without a compatibility gate, or allowing new UI to fall back to old `rating/submit`.
