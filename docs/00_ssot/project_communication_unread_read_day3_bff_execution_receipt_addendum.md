---
owner: Codex 总控
status: receipt
purpose: Record Day 3 BFF implementation receipt for project communication unread/read app-facing shaping.
layer: L0 SSOT
---

# Project Communication Unread And Read Day3 BFF Execution Receipt

## 1. 总裁决

`Conditional Pass`.

Day 3 BFF 本地实现和 targeted verification 已完成；未部署云端，未改 Flutter，未改 Server，未改 OpenAPI 源文件。

## 2. 本轮目标

在 BFF app-facing read-model 中接入 Day 2 Server 派生字段：

- 主会话卡 unread fields
- counterpart conversation detail relation unread fields
- project group unread timestamp
- project communication message delivery/read display fields

BFF 只做透传、类型校验和兼容 shaping，不拥有 unread truth，不计算未读，不落库。

## 3. 本轮范围

| Layer | Scope | Result |
| --- | --- | --- |
| BFF | message interaction read-models and tests | Done |
| Server | not in Day 3 | Not touched |
| Flutter | not in Day 3 | Not touched |
| Contracts | Day 1 field table only | Not touched |
| Cloud runtime | not in Day 3 | Not touched |

## 4. BFF 改动口径

### 4.1 Message interactions

`GET /api/app/message/interactions` read-model now exposes for `counterpart_conversation`:

- `conversationUnreadCount`
- `hasUnread`
- `latestUnreadMessageAt`

Compatibility:

- missing fields default to `0 / false / null` for old runtime only.
- present invalid types still fail read-model validation.

### 4.2 Counterpart conversation detail

`GET /api/app/message/counterpart-conversation/detail` read-model now exposes:

- `conversationUnreadCount`
- `hasUnread`
- `latestUnreadMessageAt`
- `myPublishedUnreadCount`
- `myBidUnreadCount`
- project group `latestUnreadMessageAt`

BFF does not infer relation counts from display labels or locally sum project groups.

### 4.3 Project communication messages

`GET /api/app/message/project-communication/messages` read-model now exposes:

- `deliveryState`
- `readState`
- `readByCounterpartAt`

Compatibility:

- old persisted messages without `deliveryState` default to `persisted`.
- old responses without `readState` default to `not_applicable`.
- BFF does not compute counterpart read state.

### 4.4 Read cursor forwarding

Existing `POST /api/app/message/project-communication/read-cursor` keeps forwarding:

- `projectId`
- `threadId`
- `lastReadMessageId`

BFF still does not accept client-controlled `organizationId`.

## 5. 验收证据

Commands:

```bash
cd apps/bff && npm run build
cd apps/bff && node --test test/message-interaction-transport.test.cjs
git diff --check -- apps/bff/src/routes/message_interaction/message-interaction.read-model.ts apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts apps/bff/src/routes/message_interaction/project-communication.read-model.ts apps/bff/test/message-interaction-transport.test.cjs
```

Results:

| Check | Result |
| --- | --- |
| BFF build | Pass |
| `message-interaction-transport.test.cjs` | Pass, 10/10 |
| diff whitespace check | Pass |

## 6. 验收口径

Verified:

- BFF forwards `/server/message/interactions`.
- BFF preserves server-owned counterpart identity.
- BFF passes through `conversationUnreadCount / hasUnread / latestUnreadMessageAt`.
- BFF exposes detail-level relation unread fields.
- BFF exposes project group `latestUnreadMessageAt`.
- BFF exposes message `deliveryState / readState / readByCounterpartAt`.
- BFF keeps old-runtime compatibility defaults without calculating unread truth.

Not verified in Day 3:

- Flutter UI rendering.
- cloud runtime endpoint behavior.
- double-account Computer Use UAT.
- APNs/FCM/震动.

## 7. 风险与边界

- Compatibility defaults are not production success evidence; cloud Server/BFF must both return target fields before runtime acceptance.
- BFF must not later replace missing fields by summing arrays locally; that would create truth drift.
- Message `readState = not_applicable` is only old-runtime fallback until Server provides read cursor-derived state.

## 8. 下一步建议

Proceed to Day 4 Flutter only after accepting this receipt:

- parse and display `conversationUnreadCount / hasUnread`.
- display relation unread counts.
- keep project card unread badge.
- refresh shell/interactions/detail after mark-read.
- do not implement APNs/FCM/震动 in Day 4.
