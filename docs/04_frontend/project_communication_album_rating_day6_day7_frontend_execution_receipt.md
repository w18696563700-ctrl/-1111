---
owner: Codex 总控
status: active
purpose: Record Flutter execution receipt for 2026-05-06 project album and 2026-05-07 project counterparty rating consumption.
layer: L5 Frontend
execution_date_local: 2026-04-25
schedule_dates_local:
  - 2026-05-06
  - 2026-05-07
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_route_table_addendum.md
  - docs/04_frontend/project_communication_album_rating_frontend_consumption_freeze_addendum.md
---

# 《项目相册 / 双方互评 Day-6/Day-7 Flutter 执行回执》

## 1. Current Ruling

- 当前环境日期为 `2026-04-25`。
- `2026-05-06` 和 `2026-05-07` 是计划日期。
- 当前只能判定：
  - Flutter engineering implementation completed ahead of schedule.
  - Local targeted regression passed.
  - Tunnel route materialization reached auth boundary.
- 当前不能判定：
  - real-account read/write UAT passed.
  - production primary-entry cutover passed.

## 2. 2026-05-06 Project Album Flutter

- Completion:
  - `100% engineering complete`
- Implemented:
  - `ProjectAlbumPhotoView`
  - `ProjectAlbumPhotoListView`
  - album list parser
  - album bind parser
  - album delete parser
  - BFF-only consumer methods:
    - `GET /api/app/project/:projectId/album/photos`
    - `POST /api/app/project/:projectId/album/photos`
    - `DELETE /api/app/project/:projectId/album/photos/:photoId`
  - `_ProjectAlbumSection`
  - `CounterpartConversationPage` integration
  - four fixed categories:
    - `contract`
    - `progress`
    - `final`
    - `defect`
  - `50` active photo limit提示和 Flutter-side precheck
  - image-only upload selection
  - upload flow:
    - `init`
    - direct upload
    - `confirm`
    - album `bind`
  - photo preview sheet based on FileAsset truth fields
  - soft-delete action through BFF app-facing route
- Explicit boundaries:
  - Album photo is not a chat message.
  - Flutter does not use `objectKey` as business truth.
  - Signed image URL preview remains an extension slot.

## 3. 2026-05-07 Project Counterparty Rating

- Completion:
  - `100% engineering complete for Flutter consumption`
  - `Server/BFF truth route present in current workspace and targeted tests passed`
- Implemented / corrected:
  - Flutter subject sheet no longer submits to old `/api/app/rating/submit`.
  - Flutter now submits to:
    - `POST /api/app/project-counterparty-rating/submit`
  - Submit payload now carries the frozen truth anchors:
    - `orderId`
    - `projectId`
    - `rateeOrganizationId`
    - `scoreLabel`
    - `commentText`
  - Rating UI continues to show only when:
    - project ended
    - `ratingEntry.canRate == true`
  - Flutter still does not compute credit score.
- Explicit boundary:
  - Old `/api/app/rating/*` remains historical/minimum rating carrier only.
  - It is not the new双方互评 truth route.

## 4. Verification

- Flutter:
  - `flutter test test/counterpart_conversation_chat_test.dart`
  - result: `9 passed`
  - `flutter test test/messages_instance_todo_test.dart test/project_name_access_day45_test.dart test/counterpart_conversation_chat_test.dart`
  - result: `20 passed`
  - `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_subject_sheet.dart lib/features/exhibition/presentation/pages/project_album_section.dart lib/features/messages/data/counterpart_conversation_consumer_layer.dart lib/features/messages/data/counterpart_conversation_models.dart lib/features/messages/data/counterpart_conversation_parser.dart lib/features/messages/data/messages_interaction_models.dart test/counterpart_conversation_chat_test.dart`
  - result: passed
- BFF:
  - `npm run build`
  - result: passed
  - `node --test test/project-album-transport.test.cjs test/project-counterparty-rating-transport.test.cjs`
  - result: `7 passed`
- Server:
  - `npm run build`
  - result: passed
  - `node --test test/project-communication-album.test.cjs test/project-counterparty-rating.test.cjs`
  - result: `12 passed`
- Tunnel probe through `127.0.0.1:8080`:
  - `GET /api/app/project/project-probe/album/photos`
  - result: `401 AUTH_SESSION_INVALID`, not route `404`
  - `GET /api/app/project-counterparty-rating/entry?orderId=order-probe&projectId=project-probe&rateeOrganizationId=org-probe`
  - result: `401 AUTH_SESSION_INVALID`, not route `404`
  - `POST /api/app/project-counterparty-rating/submit`
  - result: `401 AUTH_SESSION_INVALID`, not route `404`

## 5. Stage Gate

- Passed:
  - Flutter consumes BFF only.
  - Album commands carry `projectId`.
  - Rating submit carries `orderId/projectId/rateeOrganizationId`.
  - Project album does not reuse owner-private project attachments as truth.
  - Project album does not become chat image messaging.
  - Counterparty rating no longer uses old single-direction `/rating/submit`.
  - BFF build and targeted route tests passed.
  - Server build and targeted truth tests passed.
- Still blocked:
  - real logged-in account album upload/delete验收。
  - real completed-order counterparty rating submit验收。
  - credit shadow recompute / ledger trigger验收。
  - production cutover.
  - deleting legacy business carriers.

## 6. Next Stage

- Allowed:
  - run local Flutter through the existing 8080 tunnel with real login.
  - perform Computer Use click UAT for album upload/delete.
  - perform dual-account completed-order rating UAT.
- No-Go:
  - claim real-account read/write pass from unauthenticated `401` probe.
  - expand album into gallery governance, watermark, audit review, or chat media.
  - expand rating into rating list/detail/review/moderation.
