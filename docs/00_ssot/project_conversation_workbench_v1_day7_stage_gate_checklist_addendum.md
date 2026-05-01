---
owner: Codex 总控
status: draft
purpose: Record Day 7 targeted regression gate for Project Conversation Workbench V1 before cloud runtime alignment.
layer: L0 SSOT
---

# Project Conversation Workbench V1 Day 7 Stage Gate Checklist

## Gate Scope

This gate checks whether the bounded implementation may enter Day 8 cloud runtime alignment and dual-account UAT.

The checked scope is limited to:

- `text`, `image`, `file`, and `confirmation_card` project-communication messages.
- Attachment truth through confirmed `fileAssetId`.
- Confirmation-card payload types `quote`, `material_process`, and `schedule`.
- App-local contact soft prompt.
- Workbench UI for the existing project communication page.

This gate does not open:

- Generic IM.
- System push, sound, vibration, lock-screen notification, or complex notification settings.
- Confirmation-card connection to order, contract, fulfillment, payment, or settlement state machines.
- BFF-owned business truth.

## Verification Matrix

| Gate | Evidence | Result |
| --- | --- | --- |
| Server build | `npm --prefix apps/server run build` | Pass |
| Server targeted tests | `node --test apps/server/test/project-communication-album.test.cjs` | Pass, 9 tests |
| BFF build | `npm --prefix apps/bff run build` | Pass |
| BFF targeted tests | `node --test apps/bff/test/message-interaction-transport.test.cjs` | Pass, 10 tests |
| Flutter static check | `flutter analyze` on touched project-communication files | Pass, no issues |
| Flutter targeted tests | `flutter test test/counterpart_conversation_chat_test.dart` | Pass, 19 tests |
| Contract drift check | Implementation uses frozen `messageKind`, `payload.attachment`, and `payload.confirmation` shapes | Pass |
| Boundary check | Message storage and reads remain bound to `projectId + threadId` | Pass |

## Passed Gates

- Message kinds are limited to the frozen set.
- Existing text messages remain compatible.
- Image and file messages require attachment payloads that reference confirmed `fileAssetId`.
- Confirmation cards use the frozen type whitelist.
- Server rejects invalid message kinds, invalid attachment references, and cross-project attachment use in targeted coverage.
- BFF validates and forwards payload shape without creating business truth.
- Flutter renders the workbench page, message bubbles, attachment cards, confirmation cards, composer actions, and soft contact prompt in targeted coverage.

## Failed Gates

None for the bounded targeted regression scope.

## Veto Gates

None triggered.

## Remaining Risks

- Full-suite failures from unrelated dirty-worktree changes remain outside this gate unless they touch the bounded project-communication surface.
- Device-matrix validation is deferred to Day 8 and later release judgment.
- System notification behavior remains explicitly unopened.

## Next Stage Decision

`Go` for Day 8 cloud runtime alignment and dual-account UAT.
