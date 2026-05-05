---
owner: Codex 总控
status: receipt
purpose: Record the bounded Flutter execution receipt for clearing stale messages-tab unread badges through project-communication unread projection.
layer: L0 SSOT
---

# 《项目沟通未读角标 Flutter 执行回执》

## 1. 总裁决

`Conditional Pass`.

本轮只处理 Flutter 端 `消息` 底栏角标残留，不改 BFF、Server、OpenAPI、数据库、云端部署或消息中心边界。

## 2. 当前最小闭环

- Server `project_communication_read_cursors` 仍是项目沟通未读真相。
- BFF 只透传和校验 `shell/context`、`message/interactions`、`project-communication/read-cursor`。
- Flutter 底栏角标默认消费 `/api/app/shell/context.unreadSummary.messages`。
- 当消息页成功读取 `/api/app/message/interactions` 后，Flutter 允许用当前项目沟通列表中的 `conversationUnreadCount` 聚合修正本页底栏展示，避免 shell 旧快照残留 `2`。

## 3. 需要保留但暂不开通

- APNs / FCM / 系统通知横幅。
- 震动、声音、锁屏通知。
- 论坛互动 read cursor。
- 全局消息中心治理。
- BFF 或 Flutter 自建未读真相。

## 4. 后续扩展位

- Server/BFF 可后续补只读诊断字段，例如 `messagesUpdatedAt` 或 `messagesUnreadBreakdown`。
- 若项目沟通列表不完整，需要 Server 扩展 `message/interactions` 的 card source，而不是 Flutter 自行猜测 thread。
- 真实双账号 UAT 应验证：发送方发 2 条、接收方进入消息页、进入具体项目沟通、底栏角标清除。

## 5. 稳定性与成本判断

- 更稳：继续以 Server read cursor 为真相，Flutter 只做展示投影纠偏。
- 更省成本：只改 Flutter shell snapshot 展示，不动云端。
- 更适合当前阶段：解决“底栏有 2，但消息页找不到对应消息”的体验残留。
- 风险更大：仅等待 `/api/app/shell/context`，因为旧 shell 快照可能继续返回 `messages: 2`。

## 6. 本轮改动口径

- `AppShellContextData` 增加 `copyWith()`，用于保留 shell context 其它字段并替换 `unreadSummary`。
- `AppBootstrapController` 增加 `applyMessagesUnreadProjection()`，仅更新 `unreadSummary.messages` 的前端展示快照。
- `MessagesPage` 在 `message/interactions` 成功返回后聚合 `conversationUnreadCount`，并在 shell reload 前后各应用一次投影，覆盖旧 shell 值回写。
- `CounterpartConversationPage` 在 read cursor 成功后等待 shell context reload，再刷新会话详情。
- 测试新增 shell 仍返回 `messages: 2` 但项目沟通列表为空时，底栏角标消失的回归用例。

## 7. 验收证据

Commands:

```bash
cd apps/mobile && flutter test test/shell_app_test.dart --plain-name "messages page clears stale shell unread badge from project communication projection"
cd apps/mobile && flutter test test/shell_app_test.dart --plain-name "messages page reloads shell unread badge after project communication refresh"
cd apps/mobile && flutter test test/counterpart_conversation_chat_test.dart --plain-name "counterpart total frame switches between two projects without mixing messages"
cd apps/mobile && flutter analyze lib/core/boot/app_shell_context.dart lib/core/boot/app_bootstrap_controller.dart lib/features/messages/presentation/messages_page.dart lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart test/shell_app_test.dart
git diff --check -- apps/mobile/lib/core/boot/app_shell_context.dart apps/mobile/lib/core/boot/app_bootstrap_controller.dart apps/mobile/lib/features/messages/presentation/messages_page.dart apps/mobile/lib/features/exhibition/presentation/pages/counterpart_conversation_page.dart apps/mobile/test/shell_app_test.dart
```

Results:

| Check | Result |
| --- | --- |
| stale shell badge projection test | Pass |
| shell unread reload test | Pass |
| counterpart two-project read-cursor test | Pass |
| scoped Flutter analyze | Pass |
| diff whitespace check | Pass |

Computer Use:

- Old running macOS app window reproduced the user issue: bottom messages tab showed `2`; project communication list did not present a matching unread target.
- Current source rebuild launched, but did not reuse the old logged-in session, so logged-in UAT could not be completed by Codex.
- `flutter run -d macos` reported `Can't load Kernel binary: Invalid SDK hash` from native assets while the debug app still launched; this remains local toolchain/cache risk.

## 8. 风险与边界

- This receipt does not claim cloud deployment.
- This receipt does not claim dual-account UAT completion.
- This receipt does not change Server unread truth or BFF ownership.
- Existing unrelated dirty worktree files remain outside this receipt.

## 9. 下一步唯一动作

Restart the local mobile app from current source, log in with the affected account, open `消息`, and verify that the bottom `消息 2` clears when project communication projection has no unread items.
