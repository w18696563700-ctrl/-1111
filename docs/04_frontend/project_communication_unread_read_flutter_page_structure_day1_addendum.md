---
owner: Codex 总控
status: frozen
purpose: Freeze Day 1 Flutter page structure and UI consumption rules for project communication unread/read semantics.
layer: L4 Frontend
---

# Project Communication Unread And Read Flutter Page Structure Day1 Addendum

## 1. 总裁决

`Conditional Pass` for Flutter page structure freeze.

Flutter 只做展示和调用 read cursor，不拥有未读真值，不通过本地缓存制造红点，不把系统通知/震动写成已完成能力。

## 2. Page Structure

| Surface | Page/module | Required UI |
| --- | --- | --- |
| Bottom shell | `AppShellScaffold` | 消息 tab 显示 `unreadSummary.messages` badge。 |
| Interaction center | `MessagesPage` / support widgets | counterpart conversation 主卡显示右上角未读 badge。 |
| Counterpart conversation | `CounterpartConversationPage` | `我的发布` / `我的竞标` tab 显示未读数量。 |
| Project group card | `CounterpartConversationProjectGroupCard` | 具体项目卡显示 `未读 X` 或红点。 |
| Message timeline | chat widgets | 本方消息时间右侧显示 `发送中` / `发送失败` / `已发送` / `已读`。 |

## 3. Display Rules

### 3.1 Shell badge

- Source: `shellContext.unreadSummary.messages`.
- `0` 不显示 badge。
- 大于 `99` 可显示 `99+`。
- Flutter 不得扫描消息列表自行计算 shell badge。

### 3.2 Counterpart conversation card

- Source: `MessageInteractionItemView.conversationUnreadCount`.
- 主会话卡右上角显示未读 badge。
- 点击主会话卡只进入聚合容器，不清除具体项目未读。

### 3.3 Relation tabs

- Source: `myPublishedUnreadCount`, `myBidUnreadCount` or `relationSummaries[]`.
- 文案建议：
  - `我的发布 · 6` 后附 `未读 2`
  - `我的竞标 · 2` 后附 `未读 1`
- 如果没有未读，只显示项目数量。

### 3.4 Project group card

- Source: `projectUnreadCount`, `hasProjectUnread`.
- 有未读时显示 `未读 X`。
- 点击进入具体项目沟通框后才触发 mark read。

### 3.5 Message timeline status

本方消息：

- draft sending: `发送中`
- draft failed: `发送失败`
- persisted and not read by counterpart: `已发送`
- counterpart read cursor covered message: `已读`

对方消息：

- 不显示 `已发送`。
- 可继续显示时间。

## 4. Read Clearing Flow

Flutter 必须遵循：

1. 用户进入具体项目沟通框。
2. 消息列表加载成功，取得最新可见 `messageId`。
3. 调用 `POST /api/app/message/project-communication/read-cursor`，携带 `projectId + threadId + lastReadMessageId`。
4. 成功后刷新：
   - 当前 project messages
   - counterpart conversation detail
   - interactions list
   - shell context
5. 失败时不本地清除红点，只显示可控错误或保留未读。

## 5. Local State Boundary

Flutter 允许本地状态：

- 正在发送的 draft。
- 发送失败的 draft。
- UI loading/error/empty state。
- 发送后临时 optimistic 展示。

Flutter 不允许本地状态：

- 永久 unread truth。
- 本地 read cursor truth。
- 主会话统一状态机。
- 系统通知送达真值。

## 6. Widget Test Requirements

Day 4/Day 5 tests should cover:

- bottom message badge rendering.
- counterpart card unread badge rendering.
- relation tab unread count rendering.
- project group unread badge rendering.
- mark read success clears all visible layers after refresh.
- mark read failure does not clear local badge.
- sending / failed / sent / read message status display.

## 7. Explicit Non-Goals

- No APNs / FCM permission prompt.
- No vibration plugin.
- No local notification plugin.
- No App icon badge.
- No background push handler.
- No generic message inbox redesign.

## 8. 风险点

- 当前多端登录会影响 read cursor 观测：另一个端打开项目沟通可能先清掉未读。验收时必须控制账号窗口。
- WebSocket 如果不稳定，本轮允许通过手动刷新/轮询完成已读状态更新。
- 若云上旧 BFF 不返回新字段，Flutter 只能显示兼容空态，不能作为生产验收通过。
