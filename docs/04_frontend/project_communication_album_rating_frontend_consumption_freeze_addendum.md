---
owner: Codex 总控
status: frozen
purpose: Freeze L5 Flutter consumption for project communication, project album, and counterparty rating.
layer: L5 Frontend
freeze_date_local: 2026-04-24
based_on:
  - docs/01_contracts/project_communication_album_rating_contract_freeze_addendum.md
  - docs/00_ssot/project_communication_realtime_ws_truth_freeze_addendum.md
---

# 《项目沟通 / 相册 / 互评 frontend consumption freeze》

## 1. Counterpart Conversation Page

- 页面标题仍为：
  - `项目沟通`
- 头像显示在标题下方。
- 隐藏：
  - `对方主体`
  - `1 个项目`
  - `项目名称申请`
- 显示：
  - 对方昵称
  - 当前项目轻量说明
- 业务卡统一全宽：
  - `查看申请`
  - `进入竞标沟通`
  - `项目相册`

## 2. Chat UI

- 当前首版只支持文字输入。
- 支持：
  - 发送中
  - 发送失败
  - 重试
  - 刷新
- 不支持：
  - 语音
  - 表情
  - 图片消息
  - 通用实时推送

### 2.1 Bounded Realtime Clarification

- The previous `实时推送` no-go means generic IM push, offline push,
  presence, typing, global unread fan-out, and cross-device delivery sync.
- For `ProjectCommunicationThread` only, Flutter may use receive-side
  WebSocket after a valid `projectId` and `threadId` exist.
- Text message sending remains HTTP command:
  `POST /api/app/message/project-communication/messages`.
- WebSocket unavailability must fall back to quiet HTTP polling.
- BFF and Flutter must not create a second message truth, second thread model,
  or generic DM entry.

## 3. Project Album UI

- 展示四类：
  - 合同照片
  - 进度照片
  - 最终呈现照片
  - 项目瑕疵照片
- 最多展示和上传：
  - `50` 张
- Flutter 必须提示 50 张上限，但最终以后端为准。

## 4. Rating UI

- 点击对方头像可打开主体卡。
- 只有项目结束或订单完成后显示：
  - `评价对方`
- 不满足条件时显示不可评价原因。
- 提交评价后可显示信用联动提示，但不得本地计算信用分。

## 5. No-Go

- Flutter 不得直连 Server。
- Flutter 不得本地伪造 canRate。
- Flutter 不得把相册照片作为聊天消息上传。
- Flutter 不得在没有 `projectId` 的上下文发送消息。
