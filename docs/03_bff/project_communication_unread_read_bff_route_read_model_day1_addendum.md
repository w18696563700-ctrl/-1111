---
owner: Codex 总控
status: frozen
purpose: Freeze Day 1 BFF route and read-model shaping rules for project communication unread/read semantics.
layer: L3 BFF
---

# Project Communication Unread And Read BFF Route Read-Model Day1 Addendum

## 1. 总裁决

`Conditional Pass` for BFF read-model freeze.

BFF 可以在 Day 3 接入字段 shaping，但不得拥有未读真值、不得落库、不得创建第二套状态机。

## 2. BFF Route Table

| Route | Method | Day 1 decision | BFF role |
| --- | --- | --- | --- |
| `/api/app/shell/context` | GET | keep existing | Validate and expose `unreadSummary.messages`. |
| `/api/app/message/interactions` | GET | keep existing | Expose counterpart conversation unread fields if Server returns them. |
| `/api/app/message/counterpart-conversation/detail` | GET | keep existing | Expose relation/project unread summaries. |
| `/api/app/message/project-communication/messages` | GET | keep existing | Expose message delivery/read display fields. |
| `/api/app/message/project-communication/read-cursor` | POST | keep existing | Forward validated payload to Server. |

No new BFF route is admitted in this phase.

## 3. Read-Model Ownership

| Concern | Server | BFF | Flutter |
| --- | --- | --- | --- |
| unread count | truth owner | pass through / type validation | render only |
| read cursor | truth owner | forward command | call command |
| message delivery/read state | derived truth owner | shape fields | render state |
| APNs / FCM push | future provider owner | future pass through | future device token/permission |

## 4. Required BFF Field Handling

### 4.1 Shell

`unreadSummary.messages`:

- Must be a non-negative number.
- Missing value may default to `0` only under old-runtime compatibility.
- BFF must not query messages directly to calculate it.

### 4.2 Message interaction card

For `counterpart_conversation` item:

- `conversationUnreadCount`: non-negative number.
- `hasUnread`: boolean.
- `latestUnreadMessageAt`: ISO string or null.

If Server does not return these fields in old runtime:

- BFF may default `conversationUnreadCount = 0`, `hasUnread = false`, `latestUnreadMessageAt = null`.
- BFF must emit a compatibility note in test/receipt; this is not Day 3 target pass.

### 4.3 Counterpart conversation detail

Required app-facing shape:

- relation summary:
  - `myPublishedUnreadCount`
  - `myBidUnreadCount`
  - or normalized `relationSummaries[]`
- project group:
  - `projectUnreadCount`
  - `hasProjectUnread`
  - `latestUnreadMessageAt`
  - `projectId`
  - `threadId`

BFF must not infer relation from display text such as `我的发布` or `我的竞标`.

### 4.4 Project communication messages

BFF must expose:

- `deliveryState`
- `readState`
- `readByCounterpartAt`

BFF may map old persisted messages to:

- `deliveryState = "persisted"`
- `readState = "not_applicable"` only if Server has no cursor-derived value.

Target pass requires Server-provided read state for current user's own persisted messages.

## 5. Read Cursor Forwarding

BFF must forward:

- `projectId`
- `threadId`
- `lastReadMessageId`

BFF must not accept client-controlled `organizationId`.

BFF may normalize old Flutter calls without `lastReadMessageId` only as compatibility fallback. New Flutter implementation must send `lastReadMessageId`.

## 6. Test Requirements

Day 3 BFF tests should cover:

- old response compatibility default.
- strict type rejection for invalid unread fields.
- no BFF-side unread calculation.
- read cursor payload forwards `projectId + threadId + lastReadMessageId`.
- routeTarget/actionKey remain unchanged.

## 7. Explicit Non-Goals

- No BFF persistence.
- No Redis unread truth in BFF.
- No APNs/FCM delivery in BFF.
- No generic chat route.
- No relation merge across projects.

## 8. 风险点

- BFF strict parser may reject cloud Server before Server is upgraded. Mitigation: additive compatible parser first, then tighten after cloud Server/BFF align.
- If BFF derives unread from project group arrays, shell and detail may drift. Mitigation: consume Server-provided summary fields only.
