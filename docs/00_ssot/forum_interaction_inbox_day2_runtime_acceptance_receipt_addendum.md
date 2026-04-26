---
owner: Codex 总控
status: frozen
purpose: Record Day2 runtime alignment, 8080 smoke, Flutter empty-state closure, and Computer Use acceptance for the forum-derived interaction inbox repair.
layer: L0 SSOT
acceptance_date_local: 2026-04-27
---

# Forum Interaction Inbox Day2 Runtime Acceptance Receipt

## Scope

- Object:
  - `GET /api/app/forum/interaction/inbox?tab=replies|likes|follows`
- This receipt covers:
  - Aliyun BFF / Server active runtime alignment
  - 8080 tunnel smoke
  - Flutter empty-state copy closure
  - Computer Use visual acceptance for the red-box message area
- This receipt does not authorize:
  - a generic message center
  - a second forum homepage inside `messages`
  - read-state persistence
  - CI/CD or production sign-off

## Runtime Alignment

| Item | Result |
|---|---|
| Server current | `/srv/releases/server/20260427005045-forum-inbox-runtime-rebaseline` |
| BFF current | `/srv/releases/bff/20260427005045-forum-inbox-runtime-rebaseline/apps/bff` |
| Rollback record | `/srv/shared/20260427005045-forum-inbox-runtime-rebaseline.rollback` |
| Previous Server target | `/srv/releases/server/20260427004218-both-org-project-create-eligibility` |
| Previous BFF target | `/srv/releases/bff/20260427004218-both-org-project-create-eligibility/apps/bff` |
| `exhibition-server` | `active` |
| `exhibition-bff` | `active` |
| `nginx` | `active` |
| Port owner | `3000` and `3001` are served by `node` under systemd |
| PM2 drift | Historical PM2 app names remain registered but are `stopped`; they are not serving ports |

Runtime note:

- The route was first aligned through `20260427001500-forum-interaction-inbox`.
- A later active release, `20260427004218-both-org-project-create-eligibility`, became current during final verification and already contained the inbox route.
- Because that later active release had no matching rollback record, the final accepted runtime is a no-code rebaseline copy, `20260427005045-forum-inbox-runtime-rebaseline`, with the later active release recorded as the rollback target.
- This preserves the later active code while restoring the formal `current + rollback target + health smoke` procedure baseline.

## 8080 Tunnel Smoke

Base:

```bash
http://127.0.0.1:8080
```

| Route | Result |
|---|---|
| `GET /health/bff/live` | `200`, `status=ok`, `service=exhibition-bff` |
| `GET /health/bff/ready` | `200`, `status=ready`, `service=exhibition-bff` |
| `GET /health/server/live` | `200`, `status=ok`, `service=exhibition-server` |
| `GET /health/server/ready` | `200`, `status=ready`, `service=exhibition-server` |
| `GET /api/app/forum/interaction/inbox?tab=replies` without auth | `401 AUTH_SESSION_INVALID`, controlled by BFF; not `404` |
| `GET /api/app/forum/interaction/inbox?tab=replies` with a short-lived UAT bearer | `200`, `items=0`, `hasMore=false` |
| `GET /api/app/forum/interaction/inbox?tab=likes` with a short-lived UAT bearer | `200`, `items=0`, `hasMore=false` |
| `GET /api/app/forum/interaction/inbox?tab=follows` with a short-lived UAT bearer | `200`, `items=1`, `hasMore=false` |

The authenticated smoke used a short-lived access carrier generated from existing valid cloud session truth. The carrier was not persisted in formal truth and was deleted from local temporary launch files after Computer Use acceptance.

## Flutter Empty-State Closure

| File | Closure |
|---|---|
| `apps/mobile/lib/features/messages/presentation/messages_page_support.dart` | `notFound` in the interaction panel maps to `互动通知暂不可用`, while empty data remains normal empty state |
| `apps/mobile/lib/features/exhibition/data/forum_visible_copy.dart` | `/forum/interaction/` read-not-found fallback maps to `互动通知暂不可用` instead of generic forum content not-found copy |
| `apps/mobile/test/messages_instance_todo_test.dart` | Covers replies empty state, 503 failure state, 404 not-found copy, and blocks `没有找到对应的论坛内容` from appearing in the messages interaction panel |

Targeted test:

```bash
flutter test test/messages_instance_todo_test.dart
```

Result:

```text
8 tests passed.
```

## Computer Use Acceptance

Run shape:

```bash
flutter run -d macos --dart-define-from-file=/tmp/mobile-bootstrap.<temporary>
```

Temporary launch defines:

- `APP_BFF_BASE_URL=http://127.0.0.1:8080/api/app`
- `APP_RUNTIME_ENTRY_MODE=ssh_tunnel`
- short-lived bootstrap access carrier
- dummy local bootstrap refresh carrier for UI session hydration only

Visual observation:

| Area | Observation |
|---|---|
| `互动中心` | Page opens successfully through the local Flutter macOS client |
| `项目沟通` | Project communication card remains visible |
| `论坛互动 / 回复我的` | Shows normal empty state: `回复我的当前为空` and `暂无新的回复我的提醒。` |
| Blocked regression copy | `没有找到对应的论坛内容` does not appear |

Supplemental screenshot evidence:

| Artifact | Observation |
|---|---|
| `docs/00_ssot/evidence/forum_interaction_inbox_day2_computer_use_20260427_0059.png` | A later Computer Use rerun opened `互动中心` through the same 8080 tunnel and captured the `论坛互动` panel with real forum notification rows. The old fallback copy `没有找到对应的论坛内容` is absent. Empty-state behavior remains covered by the targeted Flutter test above. |

Cleanup:

```bash
q
osascript -e 'tell application "mobile" to quit'
pkill -f 'flutter run -d macos'
find /tmp -maxdepth 1 -name 'mobile-bootstrap.*' -delete
```

Post-cleanup check found no lingering `flutter run -d macos`, `mobile.app/Contents/MacOS/mobile`, or `/tmp/mobile-bootstrap.*` artifact.

## Commands Recorded

Runtime checks:

```bash
ssh root@47.108.180.198 'readlink -f /srv/apps/server/current; readlink -f /srv/apps/bff/current'
ssh root@47.108.180.198 'systemctl is-active exhibition-server; systemctl is-active exhibition-bff; systemctl is-active nginx'
ssh root@47.108.180.198 'ss -ltnp | grep -E ":(3000|3001)"'
ssh root@47.108.180.198 'pm2 list'
```

Tunnel checks:

```bash
curl -i http://127.0.0.1:8080/health/bff/live
curl -i http://127.0.0.1:8080/health/bff/ready
curl -i http://127.0.0.1:8080/health/server/live
curl -i http://127.0.0.1:8080/health/server/ready
curl -i 'http://127.0.0.1:8080/api/app/forum/interaction/inbox?tab=replies'
```

Flutter test:

```bash
cd apps/mobile
flutter test test/messages_instance_todo_test.dart
```

## Gate Checklist

| Gate | Result | Notes |
|---|---|---|
| BFF / Server runtime contains inbox route | PASS | Active current pointers aligned to `20260427005045-forum-inbox-runtime-rebaseline` |
| Health through tunnel | PASS | BFF and Server live/ready all `200` |
| Unauthenticated route no longer `404` | PASS | Controlled `401 AUTH_SESSION_INVALID` |
| Authenticated route returns data envelope | PASS | `replies` and `likes` return `200/empty`; `follows` returns `200` with one real notification |
| Flutter normal empty state | PASS | Empty data displays `暂无新的回复我的提醒。` |
| Flutter failure state | PASS | Interface failure remains `互动通知暂不可用`; real errors are not hidden as empty data |
| Computer Use red-box observation | PASS | The old generic forum not-found copy is absent |
| Temporary UAT artifacts cleanup | PASS | No lingering mobile process or bootstrap temp file found |

## Residual Risks

- PM2 still has stopped historical app registrations. They are not serving ports, but a later runtime-hardening pass should remove or disable obsolete PM2 startup if formal systemd-only operation must be enforced across reboot.
- The authenticated smoke used an existing valid cloud session and a short-lived generated carrier. It proves route behavior, not a permanent login-fixture strategy.
- This receipt is runtime acceptance for the forum-derived interaction inbox repair only. It is not production sign-off for unrelated messages-building, project-communication, trading, or forum-feed surfaces.

## Formal Conclusion

- Current minimum closed loop: PASS.
- More stable path: keep the current `systemd + current symlink + rollback target + 8080 tunnel smoke` procedure baseline.
- Lower-cost path: keep this as a bounded route-materialization and Flutter copy repair, with no new tables, migrations, or message-center expansion.
- Most suitable current-stage path: accept this Day2 runtime closure and keep later release judgment gated by separate production sign-off.
- Higher-risk path: reintroducing PM2 as a parallel runtime owner, expanding `messages` into a forum homepage, or treating frontend empty state as a replacement for real route errors.
