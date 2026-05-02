# Project Communication Unread / Read Day 5 Message Status Execution Receipt Addendum

## Verdict

Conditional Pass.

Day 5 is closed for local Server read-model implementation and cross-layer scoped verification. This receipt does not claim cloud runtime deployment, APNs, FCM, or vibration completion.

## Scope

- Server message list read-model derives own-message status from counterpart read cursor.
- BFF remains pass-through and read-model shaping only.
- Flutter keeps Day 4 display behavior for `已发送 / 已读`.
- No new business state machine.
- No read cursor schema change.

## Server Truth

`ProjectCommunicationMessage` remains message truth.

`ProjectCommunicationReadCursor` remains read truth.

For `GET /api/app/message/project-communication/messages`, Server now projects:

- `deliveryState = persisted` for persisted messages.
- `readState = not_applicable` for messages not sent by the current viewer organization.
- `readState = unread_by_counterpart` for current viewer organization's own messages not covered by the counterpart organization's read cursor.
- `readState = read_by_counterpart` for current viewer organization's own messages covered by the counterpart organization's read cursor.
- `readByCounterpartAt = counterpartReadCursor.lastReadAt` only when `readState = read_by_counterpart`.

## Implementation Boundary

- Sender-side local draft states remain Flutter-local: `发送中 / 发送失败`.
- Persisted message delivery state is Server-projected as `persisted`.
- Read state is organization-level, not individual-user-level.
- BFF must not calculate read state.
- No cloud deploy was performed in Day 5.

## Verification

- `cd apps/server && npm run build`
  - Pass.
- `cd apps/server && node --test test/project-communication-message-read-state.test.cjs`
  - Pass: 1/1.
- `cd apps/server && node --test test/project-communication-album.test.cjs`
  - Pass: 9/9.
- `cd apps/bff && npm run build`
  - Pass.
- `cd apps/bff && node --test test/message-interaction-transport.test.cjs`
  - Pass: 10/10.
- `cd apps/mobile && flutter test test/project_communication_unread_read_day4_test.dart`
  - Pass: 4/4.
- `cd apps/mobile && flutter test test/counterpart_conversation_chat_test.dart`
  - Pass: 19/19.

## Residual Risks

- Cloud Server/BFF still need Day 6 deploy and tunnel probe before runtime pass.
- Real double-account read-state proof still belongs to Day 7 Computer Use.
- Multi-device simultaneous login may clear read cursor earlier than expected; Day 7 must control test windows and record which client opened the specific project communication frame.
