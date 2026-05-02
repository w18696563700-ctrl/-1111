---
owner: Codex 总控
status: receipt
purpose: Record Day 2 Server implementation receipt for project communication unread aggregation.
layer: L0 SSOT
---

# Project Communication Unread And Read Day2 Server Execution Receipt

## 1. 总裁决

`Conditional Pass`.

Day 2 Server 本地实现和 targeted verification 已完成；未部署云端，未改 BFF，未改 Flutter，未改 OpenAPI 源文件。

## 2. 本轮目标

把项目沟通未读从旧的 thread 级 `0 | 1` 最小闭环升级为 Server 派生的“未读消息条数”，并把聚合字段扩展到：

- shell unread summary
- counterpart conversation card
- project relation tab
- project group card

## 3. 本轮范围

| Layer | Scope | Result |
| --- | --- | --- |
| Server | unread query/projection/types/tests | Done |
| BFF | not in Day 2 | Not touched |
| Flutter | not in Day 2 | Not touched |
| Contracts | Day 1 field table only | Not touched |
| Cloud runtime | not in Day 2 | Not touched |

## 4. Server 改动口径

### 4.1 Unread Query

`ProjectCommunicationUnreadQueryService` now:

- keeps `buildUnreadMapForCounterpartProjects()` as compatibility wrapper.
- adds `buildUnreadStatsForCounterpartProjects()`.
- counts unread counterpart messages, not unread threads.
- excludes current organization sender messages.
- derives `latestUnreadMessageAt`.
- keeps shell unread summary as the sum of unread message counts.

### 4.2 Counterpart Conversation Projection

`CounterpartConversationProjectionService` now exposes:

- `conversationUnreadCount`
- `hasUnread`
- `latestUnreadMessageAt`
- `myPublishedUnreadCount`
- `myBidUnreadCount`
- project group `latestUnreadMessageAt`

### 4.3 Read Cursor Guard

Existing `markRead()` validation remains active:

- thread must match `projectId`.
- `lastReadMessageId`, when supplied, must belong to the same `projectId + threadId`.
- invalid cross-thread/cross-project message id is rejected before cursor save.

Compatibility note:

- Existing clients without `lastReadMessageId` are still tolerated as compatibility fallback.
- New Flutter/BFF implementation should send `lastReadMessageId`.

## 5. 验收证据

Commands:

```bash
cd apps/server && npm run build
cd apps/server && node --test test/message-interaction-bid-carry.test.cjs
cd apps/server && node --test test/project-communication-album.test.cjs
git diff --check -- apps/server/src/modules/project_communication/project-communication-unread.query.service.ts apps/server/src/modules/message_interaction/counterpart-conversation.types.ts apps/server/src/modules/message_interaction/counterpart-conversation.projection.service.ts apps/server/test/message-interaction-bid-carry.test.cjs
```

Results:

| Check | Result |
| --- | --- |
| Server build | Pass |
| `message-interaction-bid-carry.test.cjs` | Pass, 13/13 |
| `project-communication-album.test.cjs` | Pass, 9/9 |
| diff whitespace check | Pass |

## 6. 验收口径

Verified:

- same thread with 3 unread counterpart messages counts as `3`, not `1`.
- current organization's own messages do not increase its unread count.
- shell unread sum reflects unread message count.
- project group exposes `projectUnreadCount`, `hasProjectUnread`, `latestUnreadMessageAt`.
- conversation detail exposes relation counts and conversation unread summary.
- cross-thread `lastReadMessageId` is rejected.

Not verified in Day 2:

- BFF app-facing DTO parsing.
- Flutter red badge rendering.
- cloud runtime endpoint behavior.
- double-account Computer Use UAT.
- APNs/FCM/震动.

## 7. 风险与边界

- Current query is bounded by actor-visible project communication threads; if message volume grows, add DB-level aggregate query or index review in a later performance hardening pass.
- `lastReadMessageId` is preferred for target implementation; `lastReadAt` remains compatibility fallback only.
- Day 2 cannot be used to claim phone notification, vibration, or cloud runtime completion.

## 8. 下一步建议

Proceed to Day 3 BFF only after accepting this receipt:

- extend BFF counterpart conversation read-model.
- expose `conversationUnreadCount/hasUnread/latestUnreadMessageAt`.
- expose relation unread fields.
- expose project group `latestUnreadMessageAt`.
- keep BFF pass-through only, no unread truth.
