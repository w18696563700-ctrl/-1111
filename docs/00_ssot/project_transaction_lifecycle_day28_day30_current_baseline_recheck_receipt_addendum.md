---
owner: Codex 总控
status: frozen
layer: L0 current-baseline recheck receipt
scheduled_days:
  - 2026-05-28
  - 2026-05-29
  - 2026-05-30
execution_recorded_at_local: 2026-04-25
purpose: Recheck Day28-Day30 transaction lifecycle deliverables against the current Day35 cloud Server baseline without switching back to Day29.
---

# Project Transaction Lifecycle Day28-Day30 Current Baseline Recheck Receipt

## 1. Conclusion

Day28-Day30 are complete under the current cloud baseline.

Current baseline:

- Server current: `/srv/releases/server/20260425185954-day32-day34-credit-source-type-align`
- BFF current: `/srv/releases/bff/20260425154325-day29-bff-runtime-routes/apps/bff`
- Services: `exhibition-server`, `exhibition-bff`, and `nginx` are all `active`

Decision:

- Do not switch Server back to Day29.
- Keep Day35 Server as the active baseline because it preserves Day29 order routes and also contains the later Day32-Day34 rating / credit source-type alignment.
- Treat Day29 R1 as a route-release receipt, not as the runtime that must remain current forever.

This receipt does not claim:

- dual-account business UAT completion;
- production acceptance;
- real completed-order rating submission;
- real credit ledger production evidence.

## 2. Day28 Recheck

Task:

- Flutter + BFF
- messages building / project communication page receives `counterpart_conversation` order business card
- unified entry remains messages / counterpart conversation
- business truth remains anchored to `projectId / orderId`

Result: Pass.

BFF evidence:

| Gate | Evidence |
|---|---|
| `project_order` is an admitted card type | `apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts:69` |
| `project_order` is an admitted truth type | `apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts:76` |
| `order_detail.open` is an admitted detail action | `apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts:83` |
| BFF derives a `project_order` business card from `orderSummary` | `apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts:184` |
| Derived card writes `truthAnchor.projectId` and `truthAnchor.orderId` | `apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts:209` |
| Derived card writes `/api/app/order/detail` route target with both anchors | `apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts:219` |
| BFF rejects `order_detail.open` without `projectId / orderId` | `apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts:346` |
| BFF rejects mismatched `project_order` card / truth / route anchors | `apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts:367` |

Flutter evidence:

| Gate | Evidence |
|---|---|
| `CounterpartConversationTruthAnchorView` carries `projectId` and optional `orderId` | `apps/mobile/lib/features/messages/data/counterpart_conversation_models.dart:32` |
| project group carries `orderSummary` and cards together | `apps/mobile/lib/features/messages/data/counterpart_conversation_models.dart:78` |
| parser admits `project_order` card type | `apps/mobile/lib/features/messages/data/counterpart_conversation_parser.dart:199` |
| parser rejects `project_order` without matching `projectId / orderId` | `apps/mobile/lib/features/messages/data/counterpart_conversation_parser.dart:230` |
| route registry requires `order_detail.open` params `projectId + orderId` | `apps/mobile/lib/features/messages/data/messages_registered_entry_registry.dart:158` |
| route builder refuses missing or extra params and opens existing order detail page | `apps/mobile/lib/features/messages/data/messages_registered_entry_registry.dart:219` |
| conversation page renders business cards from project groups | `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart:501` |
| conversation page opens card routeLocation, not Server direct path | `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart:557` |
| fallback route for `project_order` uses `projectId + orderId` | `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart:711` |
| existing order route preserves optional `projectId` into `OrderDetailPage` | `apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart:314` |

Meaning:

- Day28 unified entry requirement is satisfied.
- No new order thread or message-owned order state machine is introduced.
- Every actionable order card remains tied to `ProjectOrder` through `orderId` and to the project container through `projectId`.

## 3. Day29 Recheck

Task:

- Server + BFF cloud R1 route release and 8080 tunnel probe
- 8080 can access new order routes
- only route reachability is claimed, not dual-account success

Result: Pass under current Day35 baseline.

Cloud runtime:

| Item | Result |
|---|---|
| Server current | `/srv/releases/server/20260425185954-day32-day34-credit-source-type-align` |
| BFF current | `/srv/releases/bff/20260425154325-day29-bff-runtime-routes/apps/bff` |
| `exhibition-server` | `active` |
| `exhibition-bff` | `active` |
| `nginx` | `active` |

8080 route probes:

| Probe | Result | Meaning |
|---|---|---|
| `GET /health/bff/live` | `200` | BFF health reachable through tunnel. |
| `GET /health/server/live` | `200` | Server health reachable through tunnel. |
| `GET /api/app/order/detail?orderId=route-smoke-order` | `401 AUTH_SESSION_INVALID` | Order detail route exists and is auth-gated. |
| `POST /api/app/bid/select-bid-and-create-order` | `400 BID_AWARD_INVALID` | Route exists; request reached BFF/Server validation. |
| `POST /api/app/order/complete/request` | `401 AUTH_SESSION_INVALID` | Completion request route exists and is auth-gated. |
| `POST /api/app/order/complete/confirm` | `401 AUTH_SESSION_INVALID` | Completion confirm route exists and is auth-gated. |
| `POST /api/app/order/complete/reject` | `401 AUTH_SESSION_INVALID` | Completion reject route exists and is auth-gated. |
| `GET /api/app/message/interactions?lane=project_communication` | `401 AUTH_SESSION_INVALID` | Unified messages list route exists and is auth-gated. |
| `GET /api/app/message/counterpart-conversation/detail?...` | `401 AUTH_SESSION_INVALID` | Unified detail container route exists and is auth-gated. |

Meaning:

- Day29 route materialization remains valid after Day35 Server became current.
- `401` and controlled `400` are not production UAT evidence; they only prove no route-level `404 / 5xx`.

## 4. Day30 Defect Repair List

Task:

- R1 defect repair buffer
- fix list only
- no requirement expansion

Result: Pass.

Current repair list:

| ID | Finding | Current status |
|---|---|---|
| D30-001 | Server current drifted beyond the original Day29 release. | Retained as intentional current-baseline update. Do not switch back because Day35 contains Day29 routes plus rating / credit alignment. |
| D30-002 | 8080 order and counterpart routes could regress after release drift. | Rechecked. Routes return controlled `200 / 400 / 401`, not `404 / 5xx`. |
| D30-003 | project communication order card could expose role actions when buyer/seller org anchors are missing. | Rechecked. In conversation placement, missing current org, buyer org, or seller org forces read-only `unknown` actor side. |

Flutter guard evidence:

| Gate | Evidence |
|---|---|
| order card receives `placement` | `apps/mobile/lib/features/exhibition/presentation/presentation_support/order_status_card.dart:7` |
| actor side resolution sees placement | `apps/mobile/lib/features/exhibition/presentation/presentation_support/order_status_card.dart:330` |
| conversation placement requires current org plus buyer/seller org anchors | `apps/mobile/lib/features/exhibition/presentation/presentation_support/order_status_card.dart:338` |
| missing anchors return `unknown` | `apps/mobile/lib/features/exhibition/presentation/presentation_support/order_status_card.dart:342` |
| unknown actor sees only read-only text | `apps/mobile/lib/features/exhibition/presentation/presentation_support/order_status_card.dart:267` |

No new requirement was added in this recheck.

## 5. Regression Evidence

BFF targeted regression:

```bash
cd apps/bff
node --test test/message-interaction-transport.test.cjs test/project-order-completion-transport.test.cjs
```

Result: Pass, `13/13`.

Flutter targeted regression:

```bash
cd apps/mobile
flutter test test/messages_instance_todo_test.dart test/counterpart_conversation_chat_test.dart test/bid_award_bridge_test.dart
```

Result: Pass, `26/26`.

## 6. Stage Gate Checklist

| Gate | Passed | Failed | Veto | Next Stage |
|---|---:|---:|---:|---|
| Day28 unified counterpart conversation entry retained | Yes | No | No | Allowed. |
| Day28 `project_order` card carries `projectId / orderId` | Yes | No | No | Allowed. |
| BFF remains shaping / validation only | Yes | No | No | Allowed. |
| Flutter remains BFF-only and opens registered route | Yes | No | No | Allowed. |
| Day29 8080 order routes reachable under current baseline | Yes | No | No | Allowed. |
| Day30 fix list stays inside no-new-requirement buffer | Yes | No | No | Allowed. |
| Dual-account basic business UAT | No | Yes | No | Blocks production claim only. |

Next stage allowed:

- Day31 dual-account basic chain UAT on current Day35 Server baseline.

Next stage not allowed:

- production acceptance;
- rating / credit closure claim;
- rollback to Day29 without a separate incident reason.

## 7. Current Minimum Loop

The current minimum loop is now:

1. message list opens `counterpart_conversation`;
2. counterpart detail remains grouped by `projectId`;
3. project group may carry `project_order`;
4. order card opens existing order detail by `projectId + orderId`;
5. order completion actions stay on `ProjectOrder`;
6. route probes pass through 8080 under current cloud baseline;
7. missing organization anchors keep conversation order actions read-only.

## 8. Retained But Not Opened

Retained:

- original Day29 release receipt as route-release evidence;
- current Day35 Server as active baseline;
- legacy route probes as smoke checks only;
- dual-account UAT as the next required gate.

Not opened:

- new order conversation type;
- message-owned order state machine;
- direct Flutter-to-Server calls;
- DB mutation to fake orders or completion;
- production acceptance from unauthenticated probes.

## 9. Stability / Cost / Stage Fit

- More stable: continue on Day35 Server because it includes Day29 routes and later rating / credit schema alignment.
- More cost-efficient: recheck route and targeted regression instead of re-releasing or rolling back.
- More suitable for the current stage: freeze Day28-Day30 as current-baseline complete, then spend effort on Day31 real dual-account click UAT.
- Higher risk: switching back to Day29 or treating route-level `401` probes as dual-account business success.
