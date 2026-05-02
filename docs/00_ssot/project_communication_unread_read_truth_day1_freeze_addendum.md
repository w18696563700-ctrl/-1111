---
owner: Codex 总控
status: frozen
purpose: Freeze Day 1 truth for project communication unread/read semantics and message delivery/read display boundaries.
layer: L0 SSOT
---

# Project Communication Unread And Read Truth Day1 Freeze Addendum

## 1. 总裁决

`Conditional Pass` for Day 1 truth freeze.

本轮正式冻结站内多层未读闭环，不开通真实 APNs / FCM / 系统震动，不修改项目沟通业务状态机，不创建新的统一消息状态机。

允许进入下一天的前提是：产品确认本文件定义的字段、计数口径和边界；如果要求本轮同时完成真实手机系统通知和震动，则 Day 2 Server 实现不得开始，需要另开系统通知二阶段冻结。

## 2. 本轮目标

冻结以下真相，防止后续做成 Flutter 假红点或 BFF 二次状态机：

- `ProjectCommunicationMessage` 是项目沟通消息真值。
- `ProjectCommunicationReadCursor` 是项目沟通已读真值。
- 未读只从 Server 真值派生，Flutter 只展示，BFF 只转发和 shaping。
- 未读层级必须自上而下可解释，且进入具体项目沟通后自下而上同步清除。

## 3. 当前最小闭环

本轮最小闭环是 App 站内未读提醒：

1. 对方组织发出项目沟通消息。
2. Server 根据当前组织的 read cursor 派生未读消息条数。
3. BFF 透出 app-facing read-model。
4. Flutter 展示五层提醒：
   - shell messages badge
   - counterpart conversation card
   - project relation tab
   - project group card
   - message timeline status
5. 用户进入具体项目沟通框后，Flutter 调用既有 read cursor 写入口。
6. Server 更新 read cursor 后，所有上层未读同步减少或归零。

## 4. 真值对象冻结

| Object | Truth owner | Frozen role | Required anchors |
| --- | --- | --- | --- |
| `ProjectCommunicationMessage` | Server | 消息事实和消息顺序真值 | `messageId`, `projectId`, `threadId`, `senderOrganizationId`, `senderUserId`, `createdAt` |
| `ProjectCommunicationReadCursor` | Server | 当前组织在指定项目沟通 thread 的已读真值 | `organizationId`, `projectId`, `threadId`, `lastReadMessageId`, `lastReadAt` |
| `CounterpartConversationProjection` | Server derived read model | 对方主体聚合展示，不拥有业务状态 | `counterpartOrganizationId`, grouped `projectId` |
| `AppShellUnreadSummary` | Server derived read model | App shell badge 摘要 | current `organizationId` |

硬规则：

- `ProjectCommunicationReadCursor` 不得脱离 `organizationId + projectId + threadId` 单独存在。
- `lastReadMessageId` 是本轮推荐的主要边界；`lastReadAt` 只作为兼容和展示辅助，不能单独承担精确计数。
- `app_notifications.readAt` 只表示通知中心 item 已读，不等于项目沟通 read cursor。
- 主会话聚合只展示，不创建新的统一业务状态机。

## 5. 未读派生层级

未读必须按以下层级派生，任何上层 badge 都不得自行计算或本地造数：

| Level | Surface | Field | Source |
| --- | --- | --- | --- |
| L1 | Shell bottom tab | `shellContext.unreadSummary.messages` | Server 从 project communication messages + read cursors 派生 |
| L2 | 互动中心主会话卡 | `conversationUnreadCount`, `hasUnread` | Server 汇总该 counterpart 下所有项目未读消息数 |
| L3 | 项目关系 tab | `myPublishedUnreadCount`, `myBidUnreadCount` | Server 按当前组织与项目关系分桶汇总 |
| L4 | 项目组卡 | `projectUnreadCount`, `hasProjectUnread`, `latestUnreadMessageAt` | Server 按 `projectId + threadId` 汇总 |
| L5 | 消息时间线 | `deliveryState`, `readState`, `readByCounterpartAt` | Server/BFF 从消息和对方 read cursor 派生 |

清除规则：

- 打开互动中心主会话页不应清除具体项目未读。
- 只有进入具体项目沟通框并成功写入 read cursor 后，才清除该项目对应未读。
- 清除必须反向刷新 L4 -> L3 -> L2 -> L1。

## 6. 未读计数口径

本轮正式口径从旧的 thread 级最小闭环升级为“未读消息条数”：

- 同一 thread 内对方发送 3 条未读消息，`projectUnreadCount = 3`。
- 本方发送的消息不计入本方未读。
- 已归档、不可见或无权限项目不得进入当前组织未读汇总。
- 对方组织范围内多人发送的消息，仍按组织维度计入当前组织未读。
- 当前组织没有 cursor 时，按该组织可见 thread 中对方消息总数计入未读。
- cursor 指向某条消息时，只统计该消息之后的对方消息。

兼容裁决：

- 旧文书曾允许 `projectUnreadCount` 按 thread 粒度 `0 | 1` 最小闭环；本 addendum 生效后，后续 Day 2+ 实现不得继续按 thread 数冒充消息条数。
- 若云上旧 runtime 暂时只返回 `0 | 1`，只能标记为兼容退化，不得写成新验收通过。

## 7. Read Cursor 口径

`ProjectCommunicationReadCursor` 最小字段：

| Field | Required | Rule |
| --- | --- | --- |
| `organizationId` | yes | 当前组织，不能用 userId 替代。 |
| `projectId` | yes | 必须和 thread 所属项目一致。 |
| `threadId` | yes | 必须和 projectId 匹配。 |
| `lastReadMessageId` | yes for new implementation | 指向当前组织已读到的最后一条消息。 |
| `lastReadAt` | yes | Server 接收 mark-read 时写入，用于兼容和排序。 |

安全规则：

- 跨 `projectId` mark read 必须拒绝。
- 跨 `threadId` mark read 必须拒绝。
- 非项目参与组织 mark read 必须拒绝。
- `lastReadMessageId` 不属于该 `projectId + threadId` 时必须拒绝。
- mark read 必须幂等，同一游标重复提交不应增加副作用。

## 8. 消息状态展示冻结

Flutter 时间右侧展示以下状态：

| Message owner | Persistence state | Display |
| --- | --- | --- |
| 本机 draft | sending | `发送中` |
| 本机 draft | failed | `发送失败` |
| 本方已落库消息 | not read by counterpart | `已发送` |
| 本方已落库消息 | counterpart cursor passed this message | `已读` |
| 对方消息 | any | 不显示本方发送状态 |

本轮“已读”表示对方组织 read cursor 已覆盖该消息，不表示某个具体自然人已读，也不做多人已读列表。

## 9. 系统通知边界

本轮不接入真实系统通知：

- 不接 APNs。
- 不接 FCM。
- 不请求系统通知权限。
- 不实现系统震动。
- 不验收锁屏通知。
- 不以 `provider_unavailable` 作为生产通过。

允许预留：

- push contract 字段名和 routeTarget 落点。
- 二阶段施工图。
- provider adapter 边界。
- token registry 边界。

## 10. 本轮非目标

- 不做 generic IM。
- 不做陌生人私信。
- 不做群聊。
- 不做论坛私信。
- 不做消息撤回。
- 不做输入中状态。
- 不做在线状态。
- 不做复杂通知设置页。
- 不合并 `app_notifications.readAt` 与 `ProjectCommunicationReadCursor`。
- 不新增 BFF 或 Flutter 本地业务状态机。

## 11. 需要保留但暂不开通

- APNs / FCM 系统推送。
- 手机震动与声音。
- App icon badge。
- 后台保活实时推送。
- 通知偏好设置。
- 多人已读列表。
- 通知点击后的跨楼层深链统计。

## 12. 后续扩展位

- 按业务类型分桶未读：聊天、订单、竞标、澄清、资料确认。
- 项目卡显示最后一条消息摘要。
- 未读消息定位到第一条未读。
- 已读状态实时回执。
- 组织内成员级 read cursor。
- APNs / FCM 真机验收。

## 13. 四类判断

| 判断项 | 裁决 |
| --- | --- |
| 哪个更稳 | 先冻结站内多层未读和 read cursor，再做 Server/BFF/Flutter；系统通知另开二阶段。 |
| 哪个更省成本 | 只做 Flutter 红点最低成本，但会变成假红点，不可作为生产闭环。 |
| 哪个更适合当前阶段 | 本轮采用站内未读消息条数闭环，APNs/FCM/震动只预留。 |
| 哪个风险更大 | 一次性把站内未读、系统推送、震动、多端实时、通知设置全做，会放大云端凭证和真机验收风险。 |
