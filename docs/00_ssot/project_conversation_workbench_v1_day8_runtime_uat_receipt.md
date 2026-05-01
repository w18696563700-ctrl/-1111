---
owner: Codex 总控
status: draft
purpose: Record Day 8 runtime alignment, tunnel smoke, dual-account UAT, and visual acceptance for Project Conversation Workbench V1.
layer: L0 SSOT
---

# Project Conversation Workbench V1 Day 8 Runtime And UAT Receipt

## Scope

This receipt closes the bounded Project Conversation Workbench V1 execution round.

The accepted scope is:

- Project communication remains project work communication, not generic IM.
- Every message remains bound to `projectId + threadId`.
- Supported message kinds are `text`, `image`, `file`, and `confirmation_card`.
- Image and file messages use confirmed `fileAssetId` references. `objectKey` is not business truth.
- Confirmation cards are limited to `quote`, `material_process`, and `schedule`.
- Contact-risk handling is App-local soft prompting only. It does not block, punish, or create a Server-side governance action.

The retained exclusions are:

- Generic private message, group chat, stranger DM, or social chat expansion.
- System push, sound, vibration, lock-screen notification, or cross-building notification settings.
- Order, contract, settlement, fulfillment, or audit-state mutation from confirmation cards.
- BFF-owned message truth, BFF-owned status machine, or BFF-side business reconstruction from copy.

## Local Verification

| Layer | Command | Result |
| --- | --- | --- |
| Server build | `npm --prefix apps/server run build` | Passed |
| Server targeted test | `node --test apps/server/test/project-communication-album.test.cjs` | Passed, 9 tests |
| BFF build | `npm --prefix apps/bff run build` | Passed |
| BFF targeted test | `node --test apps/bff/test/message-interaction-transport.test.cjs` | Passed, 10 tests |
| Flutter analyze | `flutter analyze` on the touched project-communication files | Passed, no issues |
| Flutter targeted test | `flutter test test/counterpart_conversation_chat_test.dart` | Passed, 19 tests |

## Cloud Runtime Alignment

| Item | Result |
| --- | --- |
| Release id | `20260501013500-project-conversation-workbench-v1` |
| Previous Server rollback target | `/srv/releases/server/20260430234500-counterpart-readability` |
| Previous BFF rollback target | `/srv/releases/bff/20260430234500-counterpart-readability/apps/bff` |
| Active Server current | `/srv/releases/server/20260501013500-project-conversation-workbench-v1` |
| Active BFF current | `/srv/releases/bff/20260501013500-project-conversation-workbench-v1/apps/bff` |
| Rollback evidence | `/srv/shared/20260501013500-project-conversation-workbench-v1.rollback` |
| Server service | `exhibition-server`, active |
| BFF service | `exhibition-bff`, active |
| Nginx service | active |

The release was prepared by copying the previous active release and overlaying only the Project Conversation Workbench V1 related Server and BFF files. This avoided carrying unrelated local worktree changes into the Aliyun runtime.

## Migration Evidence

| Item | Result |
| --- | --- |
| Migration key | `20260501_project_conversation_workbench_v1_messages` |
| Purpose | Add project-communication message payload support and message-kind compatibility for `text`, `image`, `file`, and `confirmation_card` |
| Boot evidence | `applied migration 20260501_project_conversation_workbench_v1_messages` |
| Reconciliation evidence | `migration reconciliation complete; appliedThisBoot=20260501_project_conversation_workbench_v1_messages` |

## 8080 Tunnel Smoke

Tunnel:

```bash
ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198
```

| Route | Result |
| --- | --- |
| `GET /health/bff/live` | `200`, `status=ok`, `service=exhibition-bff` |
| `GET /health/bff/ready` | `200`, `status=ready`, `service=exhibition-bff` |
| `GET /health/server/live` | `200`, `status=ok`, `service=exhibition-server` |
| `GET /health/server/ready` | `200`, `status=ready`, `service=exhibition-server` |
| `GET /api/app/message/project-communication/messages?...` without auth | `401 AUTH_SESSION_INVALID`, controlled and not `404` |
| `POST /api/app/file/upload/init` with `project_communication_attachment` without auth | `401 AUTH_SESSION_INVALID`, controlled and not `404` |

## Dual-Account API UAT

The UAT used the two user-provided test accounts. Tokens and passwords are intentionally not recorded in this receipt.

| Item | Account A | Account B |
| --- | --- | --- |
| Role observed | `buyer_admin` | `supplier_admin` |
| Organization observed | `e6bf4567-016e-45f9-9420-9c950237690e` | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |
| Shell unread summary | `unreadSummary.messages = 0` | `unreadSummary.messages = 0` |

UAT anchor:

| Item | Value |
| --- | --- |
| Project id | `6883586a-c8a3-47f4-aded-96450fe8c3fe` |
| Thread id | `8039f87b-e735-49fd-98d5-21b7c55c300b` |
| Run marker | `uat-1777570972305` |

Message verification:

| Message kind | Result |
| --- | --- |
| `text` | Account A sent and Account B read message `434e8a6f-6ba2-4927-be1b-7f3248477810`; the item stayed bound to the same `projectId + threadId`. |
| `image` | Account A sent and Account B read message `0aeed9cc-d14c-4c0f-8fe5-f648738a0371`; payload carried confirmed `fileAssetId` `3b1de985-4251-4e02-9921-b93b29b849ce`; the item stayed bound to the same `projectId + threadId`. |
| `confirmation_card` | Account A sent and Account B read message `a83f96c8-2a2b-4107-80c8-b4efdb337320`; payload carried confirmation data; the item stayed bound to the same `projectId + threadId`. |

## Computer Use Visual Acceptance

The local Flutter macOS app was restarted from the current worktree to avoid validating a stale running build.

Visual evidence:

- `docs/00_ssot/evidence/20260501013500-project-conversation-workbench-v1-project-list.png`
- `docs/00_ssot/evidence/20260501013500-project-conversation-workbench-v1-project-page.png`

Observed current visual state:

| Surface | Result |
| --- | --- |
| Messages building entry | Shows `项目沟通` as a bounded project communication entry, not generic chat. |
| Counterpart total frame | Shows `当前沟通对象`, organization identity, search, tabs, project cards, and project publish time. |
| Project list | Shows project entries with `发布时间`, `进入沟通`, and no chat box in the total frame. |
| Project page | Shows `当前项目沟通`, two-sided identity card, project title, `投标沟通中`, and project-bound context. |
| Work entries | Shows `进入审核`, `订单状态`, and `项目相册` in one work-entry block. |
| Platform guidance | Shows the warm guidance banner: `请尽量围绕当前项目在平台内沟通，便于留存关键记录，方便后续协同与核验。` |
| Message stream | Shows project communication timeline with avatars, party names, identity labels, and timestamps. |
| Composer | Shows `附件`, `图片`, `确认`, project-scoped input placeholder, and send button. |
| Bottom tabs | Existing `展览 / 消息 / 我的` shell structure is retained. |

## Cleanup

- Older stale Flutter macOS run processes were stopped before the visual acceptance run.
- The temporary Flutter macOS visual-acceptance and screenshot runs were stopped after validation, leaving no local `flutter run` / `frontend_server` / `mobile.app` process from this receipt.
- No local unrelated worktree changes were reverted.
- A manual one-off `node dist/main.js` attempt on the cloud Server release exited after failing its default-env database authentication retries. It was not the systemd service, did not switch `current`, and left no running process.

## Remaining Risks

- The visual acceptance was performed on the local Flutter macOS target, not a physical iOS or Android device.
- The UAT data created during this round remains in the test project/thread as evidence.
- File size, MIME variations, and real mobile file-picker behavior still need broader device-matrix testing before a public production announcement.
- Because a DB migration was applied, rollback should follow the recorded release target and be treated as runtime rollback. Destructive DB rollback is not authorized by this receipt.
- System-level push, sound, vibration, lock-screen notification, and cross-building notification settings remain explicitly unopened.

## Go / No-Go

Current bounded scope result: `Go for Project Conversation Workbench V1 runtime and dual-account UAT`.

This does not grant permission for generic IM expansion, system notification work, or confirmation-card connection to order/contract/settlement state machines.
