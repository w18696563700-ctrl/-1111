---
owner: Codex 总控
status: frozen
layer: L0 defect repair receipt
scheduled_days:
  - 2026-06-06
  - 2026-06-07
execution_recorded_at_local: 2026-04-26
purpose: Record the bounded defect-repair buffer after Day06-04/Day06-05 dual-account UAT remained blocked by unavailable real logged-in App sessions.
---

# Project Transaction Lifecycle Day06-06 Day06-07 Defect Repair Receipt

## 1. Conclusion

Day06-06 / Day06-07 is executed as a **blocking-defect repair window**, not as production acceptance.

Current result:

- known Flutter-side blockers around session restoration and order-card anchoring were reduced;
- bid selection / order status / completion / counterparty-rating UI routes remain on the frozen app-facing paths;
- local targeted tests and static analysis pass;
- no new business requirement was added;
- no BFF or Server truth was changed in this repair window;
- real dual-account production UAT is still **No-Go** until two visible logged-in App sessions are available.

This receipt must not be read as Day06-04 / Day06-05 production验收通过.

## 2. Current Minimum Closure

Minimum closure reached in this buffer:

1. formal macOS App startup can enable explicit persisted-session recovery through `APP_ENABLE_PERSISTED_SESSION`;
2. persisted recovery stores only `refreshToken`, `deviceId`, local login source, and prompt state;
3. restored sessions do not restore `accessToken`; the App must refresh through cloud BFF/Server before loading shell context;
4. formal macOS script defaults to the approved `127.0.0.1:8080` SSH tunnel and passes the persistence flags;
5. formal macOS script can avoid killing an existing mobile process when `APP_SKIP_KILL_EXISTING_MOBILE=1`;
6. project-detail owner bid selection remains driven by BFF `bidCandidates`;
7. selection success is covered when refreshed detail exposes only `orderSummary.orderId`;
8. order completion and ProjectCounterpartyRating frontend tests still pass.

## 3. Defect Repair List

| ID | Finding | Decision | Result |
|---|---|---|---|
| D0606-001 | Real App login state was lost after restart/rerun because the default session store was memory-only and shell bootstrap checked `hasAnySession` before any restore. | Add explicit persisted-session support and make shell bootstrap wait for restore before `initialize()`. | Fixed locally. |
| D0606-002 | Persisting access tokens would weaken the session boundary and could let UI use stale credentials without cloud validation. | Persist only refresh token and device id; never restore access token. | Fixed and tested. |
| D0606-003 | Formal macOS run script killed existing `mobile` processes by default, making dual-window UAT fragile. | Keep kill-by-default for clean single-window runs, but allow `APP_SKIP_KILL_EXISTING_MOBILE=1` for controlled dual-window attempts. | Fixed locally. |
| D0606-004 | After publisher selects a bidder, refreshed project detail may expose the order through `orderSummary.orderId` instead of `bidSelection.orderId`. | Add regression coverage for the `orderSummary`-only refreshed detail case. | Covered by test. |
| D0607-001 | Order completion and rating paths could regress while fixing session repair. | Run targeted completion / rating / counterpart conversation tests. | Pass. |
| D0607-002 | Messages should remain unified through `counterpart_conversation`, not a new direct `counterparty_rating.open` entry. | No registry expansion; keep rating action inside the project communication container / subject sheet. | Boundary retained. |

## 4. Code-Level Repair

Flutter repair:

- `apps/mobile/lib/core/auth/app_session_store.dart`
  - added optional persisted-session support;
  - added storage namespace support;
  - added restore flow that loads only refresh token and device id;
  - clearing session also removes the persisted carrier.
- `apps/mobile/lib/shell/shell_app.dart`
  - added `APP_ENABLE_PERSISTED_SESSION` and `APP_SESSION_STORAGE_NAMESPACE` compile-time gates;
  - default injected test stores remain non-persistent;
  - shell initialization waits for persisted-session restore before entering `AppBootstrapController.initialize()`.
- `apps/mobile/scripts/run_macos_formal.sh`
  - formal run now defaults to `ssh_tunnel`;
  - formal run passes `APP_ENABLE_PERSISTED_SESSION=true`;
  - formal run passes `APP_SESSION_STORAGE_NAMESPACE=formal`;
  - `APP_SKIP_KILL_EXISTING_MOBILE=1` can preserve another active mobile process for controlled dual-window UAT.
- `apps/mobile/test/auth_entry_copy_and_device_id_test.dart`
  - added persisted refresh-token recovery regression.
- `apps/mobile/test/bid_award_bridge_test.dart`
  - added/strengthened order-summary-only order-card regression after bid selection.

## 5. Verification Evidence

Static analysis:

| Command | Result |
|---|---:|
| `flutter analyze lib/core/auth/app_session_store.dart lib/shell/shell_app.dart test/auth_entry_copy_and_device_id_test.dart test/bid_award_bridge_test.dart` | Pass, no issues. |

Targeted Flutter tests:

| Command | Result |
|---|---:|
| `flutter test test/auth_entry_copy_and_device_id_test.dart test/bid_award_bridge_test.dart test/counterpart_conversation_chat_test.dart test/rating_entry_test.dart` | Pass, `24/24`. |

Covered chains:

| Chain | Evidence |
|---|---|
| Session restoration | refresh token can be persisted/restored without access token; restored store requires refresh before authorized headers exist. |
| Bid selection | owner selects a bidder through `select-bid-and-create-order`; refreshed detail can expose only `orderSummary.orderId`; order card still appears. |
| Order completion | seller request and buyer confirm tests remain green. |
| Counterparty rating | new `project-counterparty-rating` entry/submit tests remain green. |
| Counterpart conversation | order card, rating sheet, chat, album, and realtime fallback tests remain green. |

## 6. Stage Gate Checklist

| Gate | Result | Notes |
|---|---:|---|
| No requirement expansion | Pass | No new business card, state machine, or message type added. |
| Flutter only talks to BFF | Pass | No direct Server call added. |
| BFF remains aggregation only | Pass | No BFF code changed in this repair window. |
| Server remains business truth owner | Pass | No Server code changed in this repair window. |
| No local order/rating truth | Pass | Flutter still only consumes BFF projections and submits frozen commands. |
| Session repair avoids access-token persistence | Pass | Only refresh carrier is restored; access token must be refreshed. |
| Unified message entrance retained | Pass | No `counterparty_rating.open` registry expansion. |
| Local targeted verification | Pass | Analysis and tests passed. |
| Real dual-account production UAT | Blocked | Requires two visible logged-in App sessions. |
| Production acceptance | Blocked | Requires real order row, completed order, two real ratings, and credit trigger/ledger DB evidence. |

## 7. Decision

Day06-06 blocking-defect repair: **Pass**.

Day06-07 pre-UAT regression gate: **Conditional Pass** for code-side known blockers, **No-Go** for production acceptance.

Precise wording for the schedule:

- acceptable: `核心链路代码与路由侧无新增已知阻断，等待 Computer Use 双账号真实点击完成最终验收`;
- not acceptable: `核心链路真实双账号验收通过`;
- not acceptable: `生产验收 100% 完成`.

## 8. Remaining Required Action

To resume the full-chain production UAT:

1. Open two visible `mobile` windows.
2. Keep Window A logged in as `重庆坤特展览展示有限公司 / 重庆海川展览工厂`.
3. Keep Window B logged in as `重庆展宏展览展示有限公司 / 江北嘴嘴帅`.
4. Window A selects bid `6e936969-3520-44bc-8804-1c804351423e` for project `c788eaff-6243-4e97-8be3-c4e174ee7944`.
5. DB read-only check confirms one real `orders` row with `project_id / id / buyer_organization_id / supplier_organization_id`.
6. Window B requests completion.
7. Window A confirms completion.
8. Both sides submit ProjectCounterpartyRating through the new UI.
9. DB read-only check confirms two rating rows and credit trigger / ledger rows with `source_type=project_counterparty_rating`.

## 9. Stability / Cost / Stage Fit

- More stable: fix the session-restore and order-anchor blockers while preserving Server/BFF truth boundaries.
- More cost-efficient: avoid cloud release churn and use the existing real project plus bid for the next UAT attempt.
- More suitable for the current stage: keep this as a defect-repair receipt and retain production No-Go until real two-account evidence exists.
- Higher risk: claiming pass from local tests, a single account, demo-user, internal actor hints, or manual DB mutation.
