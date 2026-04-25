---
owner: Codex 总控
status: active
purpose: Record Flutter execution receipt for counterpart conversation visual refinement and project communication text chat.
layer: L5 Frontend
schedule_dates_local:
  - 2026-05-04
  - 2026-05-05
  - 2026-05-06
execution_date_local: 2026-04-24
updated_at_local: 2026-04-25
based_on:
  - docs/04_frontend/project_communication_album_rating_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_route_table_addendum.md
---

# 《项目沟通 Flutter Day-5/Day-6 执行回执》

## 1. Completed

- `CounterpartConversationPage` 视觉改版：
  - 头像移动到项目沟通标题下方。
  - 显示对方昵称。
  - 隐藏 header 层的 `对方主体 / 1 个项目 / 项目名称申请` 三个 pill。
  - 业务卡改为全宽。
  - `查看申请` 与 `进入竞标沟通` CTA 宽度统一跟随业务卡宽度。
- 项目沟通文字聊天：
  - 接入 `GET /api/app/message/project-communication/thread`。
  - 接入 `GET /api/app/message/project-communication/messages`。
  - 接入 `POST /api/app/message/project-communication/messages`。
  - 接入 `POST /api/app/message/project-communication/read-cursor`。
  - 支持发送中气泡。
  - 支持发送失败保留气泡与重试。
  - 发送成功后刷新消息列表。
  - 支持 WebSocket 收消息；WebSocket 不可用时进入安静轮询兜底。
  - 底部输入框当前仅支持文字。

## 2. Verification

- `flutter analyze` target files passed.
- `flutter test test/counterpart_conversation_chat_test.dart` passed.
- Related regression passed:
  - `test/messages_instance_todo_test.dart`
  - `test/project_name_access_day45_test.dart`
  - `test/counterpart_conversation_chat_test.dart`

## 3. 2026-04-25 Completion Update

- 2026-05-02 至 2026-05-03：
  - buffer only
  - no extensibility delivery item added
- 2026-05-04 Flutter visual：
  - completion：`100% engineering complete`
  - evidence：header avatar/nickname, hidden header pills, full-width business cards, same-width CTAs are covered by widget test and implementation
- 2026-05-05 text chat：
  - completion：`100% engineering complete`
  - added evidence：`project communication failed draft can be retried and then refreshed`
  - covered states：message list, composer, sending bubble, failed bubble, retry, success refresh, realtime event, quiet polling fallback, lifecycle close/reconnect
- L5 realtime wording aligned：
  - `实时推送` remains blocked for generic IM push, offline push, presence, typing, unread fan-out, and cross-device delivery sync
  - bounded receive-side WebSocket is allowed only for `ProjectCommunicationThread` after valid `projectId/threadId`
  - HTTP history and send command remain the truth path and fallback path
- Local Flutter verification unblock：
  - fixed missing P0-Pay response payload helper readers in `exhibition_payload_support.dart`
  - this is a compile-scope frontend fix only and does not alter payment truth, BFF routes, or Server state machines
- 2026-04-25 commands：
  - `dart format test/counterpart_conversation_chat_test.dart`
  - `dart format lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart`
  - `flutter test test/counterpart_conversation_chat_test.dart`
  - `flutter test test/messages_instance_todo_test.dart test/project_name_access_day45_test.dart test/counterpart_conversation_chat_test.dart`
  - `flutter analyze lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/messages/data/counterpart_conversation_consumer_layer.dart lib/features/messages/data/project_communication_realtime_client.dart lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart test/counterpart_conversation_chat_test.dart`
- 2026-04-25 result：
  - all commands passed

## 4. Remaining Integration Gate

- CLI 已完成 widget/transport 级验证。
- 真实登录态下通过本地 Flutter + 云上 BFF 隧道读取和发送消息，仍需在可用登录态环境中做一轮点击联调。
- Day-6 UAT 前仍需核验：
  - 一个对方主体一个页。
  - 项目边界不合并。
  - 申请卡、竞标卡、聊天消息同页呈现。
  - CTA 能打开旧真值详情。
  - 键盘不遮挡底部输入框。
