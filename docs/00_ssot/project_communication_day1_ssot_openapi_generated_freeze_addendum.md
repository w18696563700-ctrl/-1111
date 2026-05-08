---
owner: Codex 总控
status: frozen
purpose: Freeze Day 1 SSOT decisions for counterpart conversation, project communication thread/read-cursor, notification mark-read, unread separation, and generated contract projection.
layer: L0 SSOT
freeze_date_local: 2026-05-08
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/counterpart_conversation_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_unread_read_day2_server_execution_receipt_addendum.md
  - docs/00_ssot/message_notification_guidance_v1_truth_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
---

# Project Communication Day 1 SSOT / OpenAPI / Generated Freeze Addendum

## 1. 总裁决

本冻结单确认 Day 1 最小闭环：

- `counterpart_conversation` 是消息楼主线入口。
- 旧 `bid_thread.open` 降级为原业务 detail carrier，不再承担消息楼主线入口。
- `projectGroups[].threadId` 是必填字段；项目沟通读、写、已读游标均必须绑定 `projectId + threadId`。
- `GET /api/app/message/project-communication/thread` 是 get-or-create 读模型入口；可通过 `projectId + counterpartOrganizationId` 获取或创建线程，也可通过 `projectId + threadId` 校验并读取既有线程。
- 新 read-cursor 写入请求必须提交 `lastReadMessageId`；历史 response / read model 中的 `lastReadMessageId = null` 继续作为兼容读取。
- `routeTargetAvailability.state != available` 的通知禁止普通 mark-read；fallback 打开不等于业务处理完成。
- 普通 unread 与 business todo 必须拆分：普通 unread 表示消息/通知是否已读，business todo 只读 Server 下发的 `businessTodoSummary` 与工作台 `entries[].badgeCount`。

## 2. 当前最小闭环

1. 消息楼列表进入 `counterpart_conversation.open`。
2. 对方主体详情按 `projectGroups[]` 切项目，每个项目分组必须带 `projectId` 和 `threadId`。
3. 项目沟通线程通过 `/api/app/message/project-communication/thread` get-or-create。
4. 消息列表读取 `/api/app/message/project-communication/messages`。
5. 已读游标写入 `/api/app/message/project-communication/read-cursor`，请求体必须包含 `projectId`、`threadId`、`lastReadMessageId`。
6. 通知已读写入 `/api/app/notifications/read` 只允许在原始 route target 当前可用且客户端已经完成安全定位后触发。

## 3. 需要保留但暂不开通

- `bid_thread.open` 仅保留为旧竞标 detail carrier。
- business todo lane 保留为通知分组与兼容展示，不替代项目沟通业务待办真值。
- 历史 `lastReadMessageId = null` 只允许出现在读取响应或旧存量游标中，不允许新请求继续提交空游标。

## 4. 后续扩展位

- 新 carrier family 必须单独冻结 actionKey、canonicalPath、requiredParams 和 error code。
- 通知 read context 可在后续扩展为更强的 Server-issued navigation token；Day 1 只冻结可用目标定位后的最小 read context。
- read-cursor 可在后续补充幂等键或消息窗口版本，但不得改变 `projectId + threadId + lastReadMessageId` 主锚。

## 5. 稳定性 / 成本 / 阶段 / 风险裁决

- 更稳：以 `counterpart_conversation.open` 做消息楼主线，旧 `bid_thread.open` 只做 carrier。
- 更省成本：保留旧 carrier 的 canonical path 和 required params，只改 registry state 与生成投影，不迁移旧业务真值。
- 更适合当前阶段：先冻结 SSOT / OpenAPI / generated，再交给 BFF / Server / Flutter 分层实现。
- 风险更大：继续让 `bid_thread.open` 同时承担主线入口和 carrier，或允许 unavailable 通知被普通 mark-read 清掉。

## 6. 非目标

- 不新增泛 IM、群聊、私聊主线。
- 不新增支付、钱包、服务费、结算、发票、保证金语义。
- 不把 BFF、Flutter 或 Admin 变成 unread、business todo、route availability 或业务状态真值 owner。
- 不用本地 generated types 证明云端 runtime 已对齐。
