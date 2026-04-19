---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L5 Flutter consumption boundary for Trading-scoped IM Round A,
  limiting local frontend implementation to project-detail entries, public
  clarification surface, project-bid private thread surface, minimum
  confirmation-card creation, upload reuse, and messages-building reminder
  jumpback without inventing business truth or contracts.
layer: L5 Frontend
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - apps/mobile/AGENTS.md
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/01_contracts/trading_im_round_a_contracts_addendum.md
  - docs/03_bff/trading_im_round_a_bff_surface_freeze_addendum.md
  - apps/mobile/lib/shell/navigation/app_building.dart
  - apps/mobile/lib/features/messages/presentation/messages_page.dart
  - apps/mobile/lib/features/exhibition/navigation/exhibition_routes.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_upload_service.dart
---

# 《交易场景 IM Round A Flutter consumption freeze》

## 1. Scope

- Flutter implementation is local-only.
- Flutter consumes BFF app-facing contracts only.
- Flutter does not own business truth, permission truth, thread state, or audit.
- This freeze does not authorize Server or BFF local code changes.

## 2. Project Detail Entries

Project detail may add two bounded entries:

- `项目澄清`
- `沟通与投标`

The entries must be guarded by BFF/Server projections and controlled failure
states. Flutter must not infer permission from local role strings alone.

## 3. Project Public Clarification Surface

Minimum Flutter capabilities:

- list clarifications
- create clarification
- show attachment links by `fileAssetId`
- show project ownership/context
- handle empty, loading, retryable, forbidden, and unavailable states

No forum UI or generic chat UI may be reused as truth semantics.

## 4. Project-Bid Private Thread Surface

Minimum Flutter capabilities:

- show thread ownership and participants
- show message list
- send text
- attach confirmed `FileAssetId`
- create minimum confirmation card
- handle empty, loading, retryable, forbidden, and unavailable states

No read receipt, typing, online status, or realtime UI may be added.

## 5. Confirmation Card Consumption

- Confirmation card creation is available only inside project-bid thread.
- Confirmation types:
  - quote
  - craft_material
  - schedule
- Flutter must not create revoke/void/edit states.
- Flutter must not convert confirmation cards into contract confirmation.

## 6. Upload Reuse

- Flutter must reuse existing upload flow:
  - upload init
  - direct upload
  - upload confirm
- Business requests may send only confirmed `fileAssetId`.
- Flutter must not expose or persist `objectKey` as business field.

## 7. Messages Building Reminder Handoff

- `messages` building may show Round A reminders only as bounded handoff items.
- Reminder tap must jump back to project clarification or bid thread context.
- `messages` building must not become:
  - chat home
  - thread list owner
  - conversation center
  - station inbox

## 8. Reusable Frontend Assets

Flutter may reuse:

- shell building and badge container
- `ExhibitionRoutes` project/bid context
- guarded navigation
- existing upload service
- `ProfileConsumerLayer` organization / role / visibleBuildings projection
- existing controlled state patterns

## 9. Frontend No-Go

- No direct Server calls.
- No invented DTOs, status semantics, or error codes.
- No local permission engine.
- No local thread state machine.
- No forum DM / stranger DM / group chat.
- No WebSocket / SSE / push.
- No read receipt / typing / online status.
- No fake-test-based upstream owner claims.

## 10. Formal Conclusion

- L5 Flutter consumption boundary is frozen.
- Flutter implementation remains blocked until:
  - Server implementation receipt passes
  - BFF implementation receipt passes
  - total control explicitly dispatches local frontend work
