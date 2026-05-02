# Project Communication Unread / Read Day 4 Flutter Execution Receipt Addendum

## Verdict

Conditional Pass.

Day 4 is closed for local Flutter implementation and scoped verification. This receipt does not claim cloud BFF/Server runtime availability and does not claim APNs/FCM or vibration delivery.

## Scope

- Consume app-facing unread/read fields produced by Server and shaped by BFF.
- Render station-internal unread indicators through:
  - bottom shell messages badge, via existing shell context refresh;
  - message interaction counterpart conversation card;
  - counterpart conversation relation tabs;
  - project group card;
  - project communication message timeline status.
- Refresh shell context and counterpart conversation detail after a successful project communication read cursor write.
- Show own persisted messages as `已发送` or `已读` according to read cursor-derived fields.

## Non-Goals

- No APNs.
- No FCM.
- No vibration.
- No new Flutter business truth.
- No new BFF route.
- No Server write-model change.
- No unified IM state machine.

## Field Consumption

### Message Interaction Card

- `conversationUnreadCount`
- `hasUnread`
- `latestUnreadMessageAt`

### Counterpart Conversation Detail

- `conversationUnreadCount`
- `hasUnread`
- `latestUnreadMessageAt`
- `myPublishedUnreadCount`
- `myBidUnreadCount`

### Project Group

- `projectUnreadCount`
- `hasProjectUnread`
- `latestUnreadMessageAt`

### Message Timeline

- `deliveryState`
- `readState`
- `readByCounterpartAt`

## Verification

- `cd apps/mobile && flutter test test/project_communication_unread_read_day4_test.dart`
  - Pass: 4/4.
- `cd apps/mobile && flutter test test/counterpart_conversation_chat_test.dart`
  - Pass: 19/19.
- `cd apps/mobile && flutter analyze lib/features/messages lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart lib/features/exhibition/presentation/pages/counterpart_conversation_chat_widgets.dart`
  - Pass: no issues found.
- `git diff --check -- <Day4 touched files>`
  - Pass.

## Runtime Boundary

Cloud runtime remains unverified in Day 4. Day 4 only proves local Flutter consumption and display behavior against shaped payload fixtures and existing project communication widget tests.

## Residual Risks

- Real read-clear behavior still depends on Day 6 cloud Server/BFF deploy and Day 7 double-account runtime validation.
- `flutter test` resolved dependencies and reported lockfile dependency changes in the existing mobile workspace state; this receipt does not attribute unrelated lockfile drift to Day 4.
- System push and vibration require a separate second-stage freeze.
