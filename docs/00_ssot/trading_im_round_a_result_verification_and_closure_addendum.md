# Trading IM Round A Independent Verification, Integration Release, and Closure Addendum

## 0. Supersession

The previous self-issued closure wording was withdrawn first, then this object
completed independent Stage 8 and independent Stage 9 verification.

Current formal status:

- `Stage 8 independent result verification: Passed`
- `Stage 9 independent integration release verification: Passed`
- `Stage 10 closure: Accepted within frozen Round A scope`

This filing is now the formal Stage 8 / Stage 9 / Stage 10 conclusion for the
bounded Trading IM Round A object only.

## 1. Scope Boundary

This filing covers only the implementation receipt for `Trading-scoped IM Round A`:

- project public clarification
- project-bid private work thread
- minimum confirmation card
- messages-building reminder and jump-back entry

Still closed:

- general chat
- forum private messages
- stranger private messages
- group chat
- realtime transport
- read receipts
- typing indicators
- online presence
- push notifications
- full order / contract / dispute conversations

## 2. Implementation Completion

Server truth implementation is complete for the bounded Round A slice:

- `apps/server/src/modules/trading_im/**`
- `apps/server/src/core/migrations/migrations.ts`
- `apps/server/src/app.module.ts`

Server owns the new persistence truth:

- `project_clarifications`
- `bid_private_threads`
- `bid_thread_messages`
- `bid_thread_confirmation_cards`

BFF app-facing implementation is complete for the bounded Round A slice:

- `apps/bff/src/routes/trading_im/**`
- `apps/bff/src/routes/routes.module.ts`

BFF remains only the app-facing aggregation / shaping / auth-forwarding layer.
It does not own Trading IM business truth or a second state machine.

Flutter consumption implementation is complete for the bounded Round A slice:

- `apps/mobile/lib/features/exhibition/data/trading_im_models.dart`
- `apps/mobile/lib/features/exhibition/data/trading_im_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/trading_im_project_clarification_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/trading_im_bid_thread_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/presentation_support/trading_im_attachment_support.dart`
- route and shell registration in `exhibition_routes.dart`, `app_router.dart`,
  `shell_app.dart`, and `exhibition_trade_pages.dart`
- messages-building Round A reminder registration in
  `messages_registered_entry_registry.dart`, `messages_consumer_layer.dart`,
  `messages_page.dart`, and `messages_page_support.dart`

Flutter only talks to BFF. Attachment submission uses confirmed `FileAsset` IDs;
`objectKey` is not treated as business truth.

## 3. Patch-return Chain

Final return mechanism for this round:

1. Cloud real git workspace implementation.
2. Auditable cloud commits and patch generation.
3. Local formal repository patch reception.
4. Local formal repository as final source truth.

Cloud workspace:

- `/srv/git/exhibition-infra-monorepo`
- branch `feature/trading-im-round-a`

Cloud implementation commits retained for audit:

- `6e46054 implement trading im round a server truth`
- `b7d7920 implement trading im round a bff surface`
- `5960115 align trading im round a contract responses`
- `e1de046 fix trading im bff core module wiring`

Local formal repository reception:

- Server/BFF patch returned from cloud and applied locally.
- The final BFF wiring fix was applied locally and mirrored back to the cloud
  workspace before release.
- Final hash parity between cloud workspace and local formal repository passed
  for the Round A Server/BFF files changed by the cloud implementation commits.

## 4. Implementation Evidence

Local checks:

- `corepack pnpm --filter @exhibition/server build` passed.
- `corepack pnpm --filter @exhibition/bff build` passed.
- `corepack pnpm contracts:check` passed.
- `flutter test test/trading_im_round_a_consumption_test.dart test/exhibition_read_corridor_closure_test.dart test/messages_instance_todo_test.dart` passed.

File responsibility / length gate spot check:

- `apps/server/src/modules/trading_im/trading-im.service.ts`: 434 lines.
- `apps/bff/src/routes/trading_im/trading-im.service.ts`: 223 lines.
- `apps/mobile/lib/features/exhibition/data/trading_im_consumer_layer.dart`: 392 lines.
- `apps/mobile/lib/features/exhibition/presentation/pages/trading_im_bid_thread_page.dart`: 403 lines.

All checked files remain below the 450-line hard gate. The bid-thread page is
above the 400-line warning line but below the hard gate and still carries one
primary page responsibility.

Cloud deploy/update:

- Server release switched to
  `/srv/releases/server/20260416102030-trading-im-round-a`.
- Initial BFF release
  `/srv/releases/bff/20260416102030-trading-im-round-a/apps/bff` failed startup
  because `TradingImModule` did not import the existing `CoreModule`.
- BFF was immediately rolled back to the previous current symlink, the module
  wiring was fixed in `e1de046`, and BFF was redeployed.
- BFF release switched to
  `/srv/releases/bff/20260416102334-trading-im-round-a-bff-fix/apps/bff`.
- `exhibition-server` restarted and is active.
- `exhibition-bff` restarted and is active.
- Nginx config was not modified, reloaded, or restarted.
- Server migration runner applied `20260416_trading_im_round_a_truth` during
  startup.

Cloud smoke:

- `GET http://127.0.0.1/health/server/live` returned `200`.
- `GET http://127.0.0.1/health/bff/live` returned `200`.
- `GET /api/app/project/clarification/list?projectId=smoke-project` returned
  controlled `401 AUTH_SESSION_INVALID`, not route-level `Cannot GET`.
- `GET /api/app/bid/thread/detail?projectId=smoke-project&bidId=smoke-bid`
  returned controlled `401 AUTH_SESSION_INVALID`, not route-level `Cannot GET`.
- `POST /api/app/project/clarification/create` with an empty body returned
  controlled `400 PROJECT_CLARIFICATION_UNAVAILABLE`, proving the route is
  mounted and request validation is controlled.

## 5. Stage 8 Independent Result Verification

Independent result verification thread conclusion:

- `PASS`
- veto findings: `none`

Independent verification checkpoints passed:

- object ownership:
  - `Server` remains the only business truth owner for Trading IM Round A
  - `BFF` remains app-facing forwarding / shaping only
  - `Flutter` consumes only BFF canonical paths
- permissions:
  - bounded project owner / bidder / viewer checks remain server-owned and
    controlled
- attachment / `FileAsset` boundary:
  - confirmed `FileAsset` IDs are consumed
  - `objectKey` is not business truth
- audit:
  - bounded Server audit entries are written for clarification, message, and
    confirmation-card actions
- entry surface:
  - bounded entry points exist only in project detail, my-project detail,
    bid-submit success, and messages-building reminder/jump-back
- No-Go boundary:
  - no evidence of general chat, stranger/forum private messages, group chat,
    realtime, read receipts, typing, online, push, or full
    order/contract/dispute conversation expansion

Independent verification evidence is recorded against:

- Server truth / permissions / audit:
  - `[trading-im.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/trading_im/trading-im.service.ts:72)`
  - `[trading-im.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/trading_im/trading-im.service.ts:104)`
  - `[trading-im.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/trading_im/trading-im.service.ts:234)`
  - `[trading-im.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/trading_im/trading-im.service.ts:309)`
  - `[trading-im.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/trading_im/trading-im.service.ts:400)`
- BFF bounded shaping:
  - `[trading-im.service.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/trading_im/trading-im.service.ts:17)`
  - `[trading-im.controller.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/bff/src/routes/trading_im/trading-im.controller.ts:11)`
- Flutter bounded consumption and entry:
  - `[trading_im_consumer_layer.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/data/trading_im_consumer_layer.dart:49)`
  - `[project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart:293)`
  - `[my_project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/my_project_detail_page.dart:182)`
  - `[messages_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/messages/presentation/messages_page.dart:102)`
- No-Go freeze baseline:
  - `[trading_im_round_a_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md:35)`
  - `[trading_im_round_a_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md:121)`
  - `[trading_im_round_a_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md:153)`
  - `[trading_im_round_a_truth_freeze_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md:271)`

Non-veto residuals retained by the independent verification thread:

- unrelated repository changes still exist outside this object
- existing Flutter analyzer noise remains outside the new Trading IM files

## 6. Stage 9 Independent Integration Release Verification

Independent integration release thread conclusion:

- `PASS`
- veto findings: `none`

Independent integration checks passed:

- local `127.0.0.1:8080` SSH forward to the cloud runtime was available
- server / bff health over the local `8080` forward returned `200`
- Round A app-facing routes were mounted and returned controlled errors, not
  route-level `Cannot GET`
- current / release / service state were stable and explicit
- rollback mouthpiece remained concrete:
  - restore previous `current` symlink target
  - restart the corresponding systemd service

Independent integration evidence:

- `lsof -nP -iTCP:8080 -sTCP:LISTEN`
- `curl http://127.0.0.1:8080/health/server/live`
- `curl http://127.0.0.1:8080/health/bff/live`
- `curl http://127.0.0.1:8080/api/app/project/clarification/list?projectId=smoke-project`
- `curl http://127.0.0.1:8080/api/app/bid/thread/detail?projectId=smoke-project&bidId=smoke-bid`
- `curl -X POST http://127.0.0.1:8080/api/app/project/clarification/create -d '{}'`
- `readlink -f /srv/apps/server/current`
- `readlink -f /srv/apps/bff/current`
- `systemctl is-active exhibition-server`
- `systemctl is-active exhibition-bff`
- `systemctl is-active nginx`

Validated runtime state:

- server current:
  - `/srv/releases/server/20260416102030-trading-im-round-a`
- bff current:
  - `/srv/releases/bff/20260416102334-trading-im-round-a-bff-fix/apps/bff`
- `exhibition-server`: `active`
- `exhibition-bff`: `active`
- `nginx`: `active`

## 7. Residual Risk

`flutter analyze` still exits non-zero with 42 existing issues in the mobile
workspace. The reported issues are existing lint / unused-code / protected-member
items outside the new Trading IM files after the Round A deprecated
`DropdownButtonFormField.value` usage was corrected.

This is not accepted as a repo-wide clean-analyze claim. It is accepted only as
a non-veto residual for the bounded Round A verification because targeted
Trading IM consumption tests pass and the remaining analyzer output does not
identify the new Trading IM source files.

The local worktree contains broad pre-existing unrelated changes. This filing
does not claim repo-wide cleanliness. It claims only the scoped Round A chain
above and the independently passed Stage 8 / Stage 9 checks.

## 8. Closure Decision

Result verification:

- `Passed by independent result verification thread`

Integration release:

- `Passed by independent integration release thread`

Round A closure:

- `Accepted closed within the frozen Round A boundary`

Still No-Go:

- general chat
- forum private messages
- stranger private messages
- group chat
- realtime transport
- read receipts / typing / online / push
- full order / contract / dispute conversation expansion
- any new scope not explicitly frozen by a later SSOT and gate
