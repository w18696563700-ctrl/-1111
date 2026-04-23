---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L4 BFF app-facing surface for `消息楼互动中心` plus `我的竞标承接 /
  竞标摘要`, defining the new interaction-list, my-bids, and bid-submission-
  snapshot route families, their mapping to Server truth, and the bounded
  shaping rules for dual-lane messages and system-seed thread consumption.
layer: L4 BFF
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_contract_freeze_addendum.md
  - docs/02_backend/messages_interaction_center_and_bidder_carry_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/trading_im_round_a_bff_surface_freeze_addendum.md
  - apps/bff/src/routes/trading_im/trading-im.service.ts
  - apps/bff/src/routes/my_project/my-project.service.ts
---

# 《消息楼互动中心与我的竞标承接 BFF surface freeze》

## 1. Scope

- 本冻结单只覆盖 BFF app-facing surface：
  - `消息楼互动中心`
  - `我的竞标承接 / 竞标摘要`
- BFF 当前只允许承担：
  - transport
  - auth carrier forwarding
  - bounded response shaping
  - visibility trimming
  - controlled error mapping
- BFF 当前不得承担：
  - interaction truth
  - bid truth
  - thread truth
  - snapshot truth
  - second state machine

## 2. App-facing Path Family

当前正式冻结的 app-facing path family 只有：

- `GET /api/app/message/interactions`
- `GET /api/app/my/bids`
- `GET /api/app/bid/submission/snapshot`

当前继续复用的 canonical handoff read family：

- `GET /api/app/bid/thread/detail`

当前明确不把以下 path 视为同一 active object：

- `GET /api/app/message/index`

## 3. Server Mapping Boundary

BFF 必须转发到以下 Server-owned read family：

- `GET /server/message/interactions`
- `GET /server/my/bids`
- `GET /server/bid/submission/snapshot`
- `GET /server/trading-im/bid/thread/detail`

BFF 必须继续保留：

- auth carrier
- organization scope headers
- request id / trace headers where available

## 4. `MessagesPage` Dual-Lane Surface

`MessagesPage` 当前只允许呈现双 lane：

1. `项目沟通`
   - consume `GET /api/app/message/interactions`
2. `论坛互动`
   - continue consuming its existing forum inbox family

当前明确禁止：

- 把 forum lane 混入 `message/interactions`
- 把 `message/interactions` 伪装成 generic message center
- 把 `message/index` 沉默升级成互动中心 carrier

## 5. Interaction List Shaping

BFF 对 `GET /api/app/message/interactions` 只允许输出冻结字段：

- `interactionId`
- `interactionType`
- `threadId`
- `projectId`
- `bidId`
- `counterpart`
- `seedSummary`
- `lastMessageSummary`
- `updatedAt`
- `routeTarget`

其中 `routeTarget` 当前只允许：

- `bid_thread.open`

`seedSummary.seedType` 当前只允许：

- `bid_submitted`

## 6. Thread Detail Continuity Shaping

`GET /api/app/bid/thread/detail` 仍是 thread detail 的唯一 admitted carrier。

在当前 package 下，BFF 只允许透传和整形成以下 bounded supplement：

- `messageKind`
- `systemSeedType`
- `systemSeedAction`

当前明确写死：

- `messageKind` 只允许：
  - `actor_message`
  - `system_seed`
- `systemSeedType` 只允许：
  - `bid_submitted`
- `systemSeedAction.actionKey` 只允许：
  - `bid_submission_snapshot.open`

## 7. `MyBids` and Snapshot Shaping

### 7.1 `GET /api/app/my/bids`

BFF 只允许输出冻结字段：

- `bidId`
- `projectId`
- `projectTitle`
- `submittedAt`
- `quoteAmount`
- `outcomeState`
- `canOpenBidThread`
- `canOpenBidResult`
- `snapshotReadable`

### 7.2 `GET /api/app/bid/submission/snapshot`

BFF 只允许输出冻结字段：

- `projectId`
- `bidId`
- `bidder`
- `submittedAt`
- `quoteAmount`
- `proposalSummary`
- `attachmentSummary`
- `availability`

## 8. Error Mapping

当前最小 app-facing error family 固定为：

- `MESSAGE_INTERACTION_UNAVAILABLE`
- `MESSAGE_INTERACTION_FORBIDDEN`
- `MY_BIDS_UNAVAILABLE`
- `MY_BIDS_FORBIDDEN`
- `BID_SUBMISSION_SNAPSHOT_UNAVAILABLE`
- `BID_SUBMISSION_SNAPSHOT_FORBIDDEN`
- `AUTH_SESSION_INVALID`

BFF 当前必须正式写死：

- upstream `404 / transport gap` 不得被伪装成成功空列表
- unknown upstream failure 不得被伪装成成功 snapshot

## 9. BFF No-Go

当前明确禁止：

- BFF persistence
- BFF-owned message truth
- BFF-owned my-bids truth
- BFF-owned snapshot truth
- `message/index` active-object reuse
- forum interaction truth takeover
- participant-card mixed-in expansion

## 10. Formal Conclusion

- `消息楼互动中心与我的竞标承接` 的 L4 BFF surface boundary 现正式冻结。
- 当前日验收正式写死：
  - `消息楼双 lane` 的消费对象已定义
  - `聊天首条系统消息` 的 BFF read supplement 已定义
  - `竞标摘要只读页` 的 app-facing carrier 已定义
- 当前已形成：
  - `L0 -> L4` 完整文书链
- 下一步只允许：
  - `Go for L5 frontend consumption freeze authoring`
  - `Go for Core V1 gate judgment authoring`
- 当前仍：
  - `No-Go for implementation`
