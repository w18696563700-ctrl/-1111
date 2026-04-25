---
owner: Codex 总控
status: frozen
layer: L0 defect repair receipt
scheduled_days:
  - 2026-05-30
  - 2026-05-31
execution_recorded_at_local: 2026-04-25
purpose: Record the R1 defect-repair buffer result for the project transaction lifecycle without changing requirements.
---

# Project Transaction Lifecycle Day30-Day31 R1 Defect Repair Receipt

## 1. Scope

This receipt covers only the scheduled buffer work:

- 2026-05-30: R1 defect repair list, without requirement expansion.
- 2026-05-31: R1 defect repair list and dual-account basic-link verification attempt.

This receipt does not admit:

- new trading requirements
- a new order thread or message-owned order state machine
- payment, settlement, wallet, invoice, or guarantee-deposit expansion
- claiming production acceptance from unauthenticated route probes
- claiming dual-account UAT if the two active app instances are not both valid logged-in business accounts

## 2. Current Minimum Closure

The current minimum closure is:

- Aliyun `Server` and `BFF` processes remain active.
- 8080 tunnel app-facing routes return controlled `200 / 400 / 401`, not route-level `404` or uncontrolled `5xx`.
- Local Flutter order-card regression remains green.
- Project communication order actions stay anchored to `projectId + orderId`.
- Missing order buyer/seller organization anchors in the `counterpart_conversation` placement do not expose seller/buyer completion actions.

## 3. Defect Repair List

| ID | Finding | Decision | Result |
|---|---|---|---|
| D30-001 | Active Server `current` is `/srv/releases/server/20260425161006-p0-pay-day20-message-carry`, not the earlier Day29 target `/srv/releases/server/20260425150611-project-transaction-day29-r1`. | Do not force-switch back during buffer repair because the active package contains `OrderModule` and order completion routes, and switching back may regress the P0-Pay message carry package. Record as release-shape drift. | Non-blocking risk retained. |
| D30-002 | 8080 order and counterpart routes could have regressed after current drift. | Re-probe app-facing routes through the tunnel. | Pass: health `200`; order/counterpart routes return controlled `400/401`, not `404/5xx`. |
| D30-003 | `counterpart_conversation` order card could use role fallback when buyer/seller organization anchors are missing. | Minimal Flutter guard only in conversation placement: missing `organizationId`, `buyerOrganizationId`, or `sellerOrganizationId` makes the card read-only. | Fixed locally and covered by regression. |
| D31-001 | First app instance showed a valid project communication path with project-name result, bid communication, album, and chat sections. | Record as single-side visual evidence only. | Pass for one-side navigation. |
| D31-002 | Second app instance available to Computer Use resolved to `demo-user`, showed no project communication conversation, and bid submission page displayed `当前尚未登录`. | Do not claim dual-account business UAT. Requires two real logged-in business accounts or frozen sessions. | Blocks full Day31 pass. |

## 4. Code-Level Repair

Flutter repair:

- `apps/mobile/lib/features/exhibition/presentation/presentation_support/order_status_card.dart`
  - `_currentOrderActorSide` now receives `placement`.
  - In `_OrderStatusPlacement.conversation`, the order card requires `organizationId`, `buyerOrganizationId`, and `sellerOrganizationId` before resolving buyer/seller actions.
  - If anchors are missing, the card remains read-only with `当前账号仅可查看`.

Regression coverage:

- `apps/mobile/test/counterpart_conversation_chat_test.dart`
  - Added `conversation order card stays read-only when order organization anchors are missing`.

This is a defect guard, not a new requirement. Project-detail and order-detail placements keep the existing role fallback because those pages can still rely on backend state-machine rejection as the final authority.

## 5. Verification Evidence

Local Flutter:

| Command | Result |
|---|---:|
| `flutter test test/messages_instance_todo_test.dart test/counterpart_conversation_chat_test.dart test/bid_award_bridge_test.dart` | Pass, `26/26`. |

BFF:

| Command | Result |
|---|---:|
| `node --test test/project-order-completion-transport.test.cjs test/message-interaction-transport.test.cjs` | Pass, `13/13`. |

Server:

| Command | Result |
|---|---:|
| `node --test test/project-order-completion.test.cjs` | Pass, `5/5`. |

8080 tunnel probes:

| Probe | Result |
|---|---|
| `GET /health/bff/live` | `200` |
| `GET /health/server/live` | `200` |
| `GET /api/app/order/detail?orderId=route-smoke-order` | `401 AUTH_SESSION_INVALID` |
| `POST /api/app/order/complete/request` with empty body | `400 PROJECT_ORDER_COMPLETE_INVALID` |
| `POST /api/app/order/complete/confirm` with empty body | `400 PROJECT_ORDER_COMPLETE_INVALID` |
| `POST /api/app/order/complete/reject` with empty body | `400 PROJECT_ORDER_COMPLETE_INVALID` |
| `GET /api/app/message/interactions?lane=project_communication` | `401 AUTH_SESSION_INVALID` |
| `GET /api/app/message/counterpart-conversation/detail?conversationId=route-smoke-org&projectId=route-smoke-project` | `401 AUTH_SESSION_INVALID` |

Computer Use visual evidence:

| Side | Observation | Result |
|---|---|---|
| First observed app instance | Message center card opened project communication; project group showed project-name access result, bid communication, project album, and chat sections. | Single-side navigation pass. |
| Second observed app instance | `我的` showed `demo-user`; messages showed no project communication conversation; bid submission page showed `当前尚未登录`. | Not a valid dual-account UAT actor. |

## 6. Stage Gate Checklist

| Gate | Result | Notes |
|---|---:|---|
| No requirement expansion | Pass | Only one Flutter guard was added. |
| BFF remains aggregation only | Pass | No BFF truth mutation added. |
| Server remains order truth owner | Pass | No Server truth change in this buffer. |
| 8080 route materialization | Pass | No route-level `404/5xx` found. |
| Local regression | Pass | Flutter/BFF/Server targeted suites pass. |
| One-side project communication click path | Pass | Verified by Computer Use on the available project communication instance. |
| Dual-account business UAT | Blocked | The second active app instance is `demo-user` and has no project communication conversation. |
| Production acceptance | Blocked | Requires real two-account order chain with seller request and buyer confirm through valid sessions. |

## 7. Decision

Day30 R1 defect repair: Pass.

Day31 dual-account basic link: Conditional No-Go.

Reason:

- The code and cloud route regressions are clear.
- The Computer Use environment does not currently provide two valid logged-in business actors tied to the same project/order conversation.

Next allowed action:

- Reopen or provide two valid logged-in app instances:
  - publisher / buyer organization account
  - selected supplier / seller organization account
- Both must see the same project communication container or order anchor.
- Then rerun the Day31 dual-account UAT: message center -> counterpart conversation -> order card/detail -> seller completion request -> buyer confirm/reject -> status refresh.

## 8. Stability / Cost / Stage Fit

- More stable: keep `counterpart_conversation` as the unified entry and keep all order truth in `ProjectOrder`.
- More cost-efficient: fix only the missing-anchor UI guard and avoid release-pointer churn while routes are healthy.
- More suitable for the current stage: route smoke plus local regression plus explicit UAT blocker recording.
- Higher risk: force-switching active Server `current` back to the Day29 target or claiming dual-account pass from a `demo-user` instance.
