---
owner: Codex 总控
status: active
purpose: Audit completion evidence for the 2026-04-27 to 2026-05-08 project communication text-chat schedule.
layer: L0 SSOT
audit_date_local: 2026-04-25
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_server_day2_day3_execution_receipt_addendum.md
  - docs/00_ssot/project_communication_album_rating_bff_server_day4_execution_receipt_addendum.md
  - docs/04_frontend/project_communication_chat_day5_day6_frontend_execution_receipt.md
  - docs/04_frontend/counterpart_conversation_day6_day8_acceptance_report.md
  - docs/00_ssot/counterpart_conversation_day8_release_cutover_addendum.md
  - docs/00_ssot/project_communication_album_rating_day14_day15_acceptance_release_addendum.md
---

# 《项目沟通文字聊天 2026-04-27 至 2026-05-08 完成度审计》

## 1. Audit Ruling

- Completion state:
  - `engineering acceptance + UAT candidate`
- Not accepted as:
  - production primary-entry hard cutover
  - user-signed UAT pass
  - deletion of legacy `bid_thread` / `project_name_access_thread` carriers
- Date caveat:
  - 当前环境日期为 `2026-04-25`。
  - 下表里的 `2026-04-27` 至 `2026-05-08` 是计划日期。
  - 当前只能判定“代码/文书/回执证据已提前形成”，不能判定“这些日期当天真实发生完成”。

## 2. Daily Completion Table

| Date | Result | Evidence |
|---|---|---|
| 2026-04-27 | passed for document freeze | L0-L5 addendum、字段表、路由表、门禁表已冻结；明确 project chat is not generic DM |
| 2026-04-28 | passed for Server skeleton | `ProjectCommunicationThread` / `ProjectCommunicationMessage` / `ProjectCommunicationReadCursor` entities and migration exist |
| 2026-04-29 | passed for Server read/write | text send/list/thread/read cursor services and tests exist; messages carry `projectId/threadId/senderOrganizationId` |
| 2026-04-30 | passed for BFF + cloud release | BFF routes exist; Server/BFF current release and tunnel probes recorded |
| 2026-05-01 | buffer only | no structural delivery expected; no independent day receipt |
| 2026-05-02 | buffer only | no structural delivery expected; no independent day receipt |
| 2026-05-03 | buffer only | no structural delivery expected; no independent day receipt |
| 2026-05-04 | passed for Flutter visual rewrite | avatar/nickname under header, hidden header pills, full-width business cards, same-width CTA covered by Flutter implementation and targeted widget test |
| 2026-05-05 | passed for Flutter chat composer | timeline, bottom text input, sending state, failed draft, retry path, success refresh, realtime receive, quiet polling fallback covered by targeted tests |
| 2026-05-06 | conditional pass for full-chain integration | local Flutter through `127.0.0.1:8080` can reach cloud BFF; route probes pass |
| 2026-05-07 | conditional pass for Computer Use UAT | actual click opened message center and project communication; previous report records send/readback for `ua` |
| 2026-05-08 | passed for release/cutover docs | release note and rollback/cutover ruling exist; hard cutover remains blocked |

## 3. Evidence Summary

- Docs freeze:
  - `project_communication_album_rating_truth_freeze_addendum.md`
  - `project_communication_album_rating_field_table_addendum.md`
  - `project_communication_album_rating_route_table_addendum.md`
  - `project_communication_album_rating_stage_gate_checklist_addendum.md`
- Server:
  - `apps/server/src/modules/project_communication/**`
  - `apps/server/test/project-communication-album.test.cjs`
- BFF:
  - `apps/bff/src/routes/message_interaction/project-communication.read-model.ts`
  - `apps/bff/src/routes/message_interaction/message-interaction.controller.ts`
  - `apps/bff/src/routes/message_interaction/message-interaction.service.ts`
  - `apps/bff/test/message-interaction-transport.test.cjs`
- Flutter:
  - `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart`
  - `apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart`
  - `apps/mobile/lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart`
  - `apps/mobile/test/counterpart_conversation_chat_test.dart`
- Frontend realtime alignment:
  - `project_communication_album_rating_frontend_consumption_freeze_addendum.md`
  - `project_communication_realtime_ws_truth_freeze_addendum.md`
  - The L5 no-go now treats `实时推送` as generic/offline push and IM fan-out.
  - Bounded receive-side WebSocket plus quiet HTTP polling is allowed only for
    `ProjectCommunicationThread` after valid `projectId/threadId`.
- Computer Use / screenshots:
  - `artifacts/uat/2026-05-07-01-messages-entry.png`
  - `artifacts/uat/2026-05-07-02-project-communication.png`
  - `artifacts/uat/2026-05-07-03-name-access-thread.png`
  - `artifacts/uat/2026-05-07-04-bid-thread.png`

## 4. Current Cloud State

- Current Server/BFF patch release:
  - `20260425001009-project-counterparty-rating-r1-minimal`
- Health:
  - Server `3001` live passed.
  - BFF `3000` live passed.
  - Local tunnel `127.0.0.1:8080` reaches cloud BFF.
- Route materialization:
  - `GET /api/app/message/project-communication/thread` returns controlled `401 AUTH_SESSION_INVALID`, not router `404`.
  - `GET /api/app/message/project-communication/messages` with probe ids returns feature `PROJECT_COMMUNICATION_UNAVAILABLE`, not router `404`.
  - `POST /api/app/message/project-communication/messages` with probe ids returns feature `PROJECT_COMMUNICATION_UNAVAILABLE`, not router `404`.
  - old `bid_thread/detail` fallback returns controlled auth failure, not router `404`.

## 5. 2026-04-25 Flutter Verification

- Added missing retry proof:
  - `project communication failed draft can be retried and then refreshed`
- Fixed local Flutter compile blocker:
  - added missing P0-Pay payload helper readers used by `project_create_page.dart`
  - scope is frontend compile/readback only; it does not change P0-Pay truth, BFF routes, or Server behavior
- Commands passed:
  - `dart format test/counterpart_conversation_chat_test.dart`
  - `dart format lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart`
  - `flutter test test/counterpart_conversation_chat_test.dart`
  - `flutter test test/messages_instance_todo_test.dart test/project_name_access_day45_test.dart test/counterpart_conversation_chat_test.dart`
  - `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/messages/data/counterpart_conversation_consumer_layer.dart lib/features/messages/data/project_communication_realtime_client.dart lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart test/counterpart_conversation_chat_test.dart`

## 6. Remaining Gates

- User confirmation is required before sending a real chat message.
- Real UAT sign-off is still required before primary-entry hard cutover.
- File responsibility gate remains open:
  - `counterpart_conversation_page.dart` currently exceeds the default
    handwritten `450` line limit.
  - `messages_page_support.dart` currently exceeds the default handwritten
    `450` line limit.
  - Production hard cutover requires either a focused split or an explicit
    formal exemption.
- Do not remove old carrier routes before UAT and rollback window close.
- Do not expand this into generic DM, read receipt, typing, online status, push, or multimedia chat without a new freeze chain.
