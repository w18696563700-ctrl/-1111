---
owner: Codex 总控
status: active
purpose: Record R2 cloud route release and Flutter album/rating controlled-entry execution for project communication, album, and rating.
layer: L0 SSOT
schedule_window:
  - 2026-05-09
  - 2026-05-13
execution_date_local: 2026-04-24
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_route_table_addendum.md
  - docs/04_frontend/project_communication_album_rating_day6_day7_frontend_execution_receipt.md
---

# 《项目沟通 / 相册 / 互评 R2 执行回执》

## 1. Cloud R2

- R2 release id:
  - `20260424173000-project-communication-r2`
- Server:
  - current Server 已含 `project_communication`、`project album`、`rating` truth routes。
  - 本次未重启 Server，避免无意义扰动。
- BFF:
  - 已补齐 app-facing project album routes。
  - 已发版到 current。

## 2. R2 Routes

- Chat:
  - `GET /api/app/message/project-communication/messages`
  - `POST /api/app/message/project-communication/messages`
  - `POST /api/app/message/project-communication/read-cursor`
- Album:
  - `GET /api/app/project/:projectId/album/photos`
  - `POST /api/app/project/:projectId/album/photos`
  - `DELETE /api/app/project/:projectId/album/photos/:photoId`
- Rating:
  - `GET /api/app/project-counterparty-rating/entry`
  - `POST /api/app/project-counterparty-rating/submit`

## 3. Tunnel Probe

- `GET /health/bff/live`:
  - returned `200`
- `GET /api/app/message/project-communication/messages?threadId=thread-probe&projectId=project-probe`:
  - returned `401 AUTH_SESSION_INVALID`, not `404`
- `GET /api/app/project/project-probe/album/photos`:
  - returned `401 AUTH_SESSION_INVALID`, not `404`
- `POST /api/app/project/project-probe/album/photos`:
  - returned `401 AUTH_SESSION_INVALID`, not `404`
- `DELETE /api/app/project/project-probe/album/photos/photo-probe`:
  - returned `401 AUTH_SESSION_INVALID`, not `404`
- `GET /api/app/project-counterparty-rating/entry?orderId=order-probe&projectId=project-probe&rateeOrganizationId=org-probe`:
  - returned `401 AUTH_SESSION_INVALID`, not `404`
- `POST /api/app/project-counterparty-rating/submit`:
  - returned `401 AUTH_SESSION_INVALID`, not `404`

## 4. Flutter Album And Rating Entry

- 项目沟通页对方头像已可点击。
- 点击头像弹出对方主体卡。
- 项目沟通页已接入项目相册 section。
- 项目相册已支持：
  - 四类分类 `contract/progress/final/defect`
  - `50` 张上限提示
  - image-only 选择
  - `init -> direct upload -> confirm -> bind`
  - list / preview / delete
- 项目相册仍遵守：
  - FileAsset 为真值
  - `objectKey` 不作为业务真值
  - 相册照片不是聊天消息
- 主体卡显示:
  - 对方主体名称
  - 组织 ID
  - 当前项目
  - 项目状态
- 项目未结束时显示不可评价原因:
  - `当前项目尚未结束，评价入口不会开放。`
- 评价 UI 已具备:
  - 星级评分
  - 标签选择
  - 文字备注
  - 信用提示
- 真实提交已改为新 truth route:
  - `POST /api/app/project-counterparty-rating/submit`
  - payload includes `orderId/projectId/rateeOrganizationId/scoreLabel/commentText`
- 真实提交仍被 UAT gate 住:
  - 需要真实 completed order 和双账号登录态验收。
  - Flutter 不伪造评价真值，不计算信用分。

## 5. Tests

- BFF:
  - `npm run build` passed.
  - `node --test test/project-album-transport.test.cjs test/project-counterparty-rating-transport.test.cjs` passed.
- Server:
  - `npm run build` passed.
  - `node --test test/project-communication-album.test.cjs test/project-counterparty-rating.test.cjs` passed.
- Flutter:
  - `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_subject_sheet.dart lib/features/exhibition/presentation/pages/project_album_section.dart lib/features/messages/data/counterpart_conversation_consumer_layer.dart lib/features/messages/data/counterpart_conversation_models.dart lib/features/messages/data/counterpart_conversation_parser.dart lib/features/messages/data/messages_interaction_models.dart test/counterpart_conversation_chat_test.dart` passed.
  - `flutter test test/counterpart_conversation_chat_test.dart` passed.
  - `flutter test test/messages_instance_todo_test.dart test/project_name_access_day45_test.dart test/counterpart_conversation_chat_test.dart` passed.

## 6. Gate Result

- Passed:
  - R2 cloud BFF route availability.
  - Chat route availability.
  - Album route availability.
  - Project counterparty rating route availability.
  - Flutter album list/bind/delete consumption.
  - Flutter rating submit uses `project-counterparty-rating`, not old `/rating/submit`.
  - Avatar subject-card entry.
  - Rating unavailable reason when project is not ended.
  - Controlled rating UI shell.
  - Credit hint does not compute score.
- Conditional / not passed:
  - Real account album upload/delete UAT is not complete.
  - Real completed-order counterparty rating submit UAT is not complete.
  - Credit shadow recompute / ledger trigger is not verified.

## 7. No-Go

- 不允许把当前受控评价 UI 宣称为真实互评提交闭环。
- 不允许把未登录 `401` route probe 冒充真实互评读写验收。
- 不允许把旧 `/api/app/rating/submit` 冒充新的 `project-counterparty-rating`。
- 不允许 Flutter 计算信用分。
- 不允许删除旧 `bid_thread` 或 `project_name_access_thread` carrier。
