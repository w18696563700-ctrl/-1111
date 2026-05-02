# Project Communication Unread/Read Day 7 Frontend Fix Receipt Addendum

## Verdict

Conditional Pass for the Day 7 frontend blocking defects.

This fix closes the known Flutter-side drift where project communication cards could show unread while the bottom shell `消息` tab still consumed stale `shellContext.unreadSummary.messages`.

## Scope

Frontend only.

No BFF route, Server query, contract, migration, cloud runtime, APNs, FCM, sound, or vibration change was made in this fix.

## Fixed Defects

- `D7-FE-001`: Bottom shell `消息` tab was not refreshed after project communication list refresh.
- `D7-FE-002`: Target project-card unread indicator was visible but not prominent enough.

## Implementation

- `MessagesPage._loadProjectCommunication()` now triggers `AppShellScope.reloadShellContext()` after a successful content/empty project communication refresh.
- The shell tab still reads only `shellContext.unreadSummary.messages`; Flutter does not compute shell unread locally from interaction cards.
- Project-card unread marker now uses a stronger red unread pill with an icon, stronger card background, and stronger border.

## Verification

Commands:

- `flutter test test/shell_app_test.dart --plain-name "messages page reloads shell unread badge after project communication refresh"`
- `flutter test test/counterpart_conversation_chat_test.dart --plain-name "counterpart conversation header uses nickname and business cards are full-flow actions"`
- `flutter test test/project_communication_unread_read_day4_test.dart`
- `flutter analyze lib/features/messages/presentation/messages_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_widgets.dart test/shell_app_test.dart test/counterpart_conversation_chat_test.dart test/project_communication_unread_read_day4_test.dart`

Results:

- All targeted Flutter tests passed.
- Scoped Flutter analyze reported no issues.

## Remaining Boundary

This receipt does not prove phone-side visual acceptance after reinstall/reload. A short manual recheck is still required:

- A counterpart sends a project communication message.
- Owner phone sees bottom `消息` tab badge.
- Owner phone sees counterpart conversation badge.
- Owner phone sees target project-card unread marker.
- Owner opens the concrete project communication page.
- The project, conversation, and bottom tab unread markers clear after refresh.

APNs/FCM/vibration remains phase 2 and is not part of this closure.
