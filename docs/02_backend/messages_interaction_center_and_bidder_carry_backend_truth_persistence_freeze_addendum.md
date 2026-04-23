---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L3 Server truth and persistence boundary for `消息楼互动中心` plus
  `我的竞标承接 / 竞标摘要`, defining the `BidSubmitted -> thread resolve/create
  -> system seed message -> interaction projection` truth chain while keeping
  `MyBidsList` and `BidSubmissionSnapshot` as bounded read surfaces and
  explicitly forbidding any second chat state machine.
layer: L3 Backend
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/messages_interaction_center_truth_freeze_addendum.md
  - docs/00_ssot/my_bids_and_bid_submission_snapshot_truth_freeze_addendum.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_contract_freeze_addendum.md
  - docs/02_backend/trading_im_round_a_backend_truth_persistence_freeze_addendum.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - apps/server/src/modules/trading_im/trading-im.service.ts
  - apps/server/src/modules/trading_im/entities/bid-private-thread.entity.ts
  - apps/server/src/modules/trading_im/entities/bid-thread-message.entity.ts
  - apps/server/src/modules/bid/entities/bid.entity.ts
---

# 《消息楼互动中心与我的竞标承接 backend truth freeze》

## 1. Scope

- 本冻结单只覆盖 Server-owned truth：
  - `消息楼互动中心`
  - `我的竞标承接 / 竞标摘要`
- 本冻结单只服务于：
  - `BidSubmitted` 种子事件真值链
  - `message interactions` 读投影真值边界
  - `my bids` 私域读面真值边界
  - `bid submission snapshot` 只读摘要真值边界
- 本冻结单不授权：
  - implementation unlock
  - dispatch send
  - integration
  - release-prep

## 2. Server Truth Owner

当前 Server truth owner 继续固定为既有 canonical carrier：

- `Bid`
- `BidPrivateThread`
- `BidThreadMessage`
- `BidThreadConfirmationCard`

当前新增对象中，以下都不是新的业务真相 owner：

- `MessagesInteractionList`
- `MyBidsList`
- `BidSubmissionSnapshot`

它们在本轮只允许是：

- bounded read projection
- bounded read model
- bounded query output

## 3. `BidSubmitted` Truth Chain

当前正式冻结的唯一种子真值链为：

1. `BidSubmitted`
2. `BidThreadResolved`
3. `BidSubmittedSystemSeedCreated`
4. `MessagesInteractionProjectionUpserted`

### 3.1 `BidSubmitted`

- canonical anchor：
  - `projectId + bidId`
- upstream truth owner：
  - existing `Bid` truth
- 本轮不新造：
  - second bid carrier
  - second submission state machine

### 3.2 `BidThreadResolved`

- Server must resolve or create the admitted private thread under：
  - `projectId + bidId`
- thread truth 继续复用：
  - existing `BidPrivateThread`
- 当前明确不新造：
  - second conversation owner
  - generic DM thread family

### 3.3 `BidSubmittedSystemSeedCreated`

- 当前系统首条消息必须落在既有：
  - `BidThreadMessage`
- 它当前只能作为 `BidThreadMessage` 的 bounded subtype：
  - `messageKind = system_seed`
- 当前最小语义只允许：
  - 谁提交了竞标
  - 何时提交
  - 允许 `bid_submission_snapshot.open`

当前明确不新造：

- second seed table
- station notice truth
- unread receipt truth

### 3.4 `MessagesInteractionProjectionUpserted`

- interaction list 当前只允许由 Server 从既有 truth 投影得出：
  - `Bid`
  - `BidPrivateThread`
  - latest `BidThreadMessage`
  - bounded counterpart summary
- 它的正式语义只有：
  - 当前是否存在一个 admitted project-communication interaction
  - handoff 应跳往哪个 `bid thread`
  - last summary / seed summary / counterpart summary

## 4. No Second Chat State Machine

当前必须正式写死：

- `MessagesInteractionProjection` 不是第二聊天状态机。
- `MessagesInteractionProjection` 不是第二 thread truth。
- `MessagesInteractionProjection` 不拥有独立 lifecycle。

当前明确禁止：

- 新建 `message_interaction` truth family 并为其设计独立状态机
- 新建独立 conversation status：
  - unread / read
  - typing
  - online
  - archived-by-user
  - muted
- 把 `message interactions` 写成凌驾于 `BidThread` 之上的主真相

如果未来为了读性能引入 read-optimized projection carrier，它也必须满足：

- not authoritative
- no write command
- no independent lifecycle
- no independent permission truth
- no second chat state machine

## 5. `MyBidsList` Truth Boundary

`MyBidsList` 当前只允许从以下既有真值读时派生：

- `Bid`
- project summary truth
- admitted bid result / outcome truth

当前最小 read meaning 固定为：

- 当前 actor 作为 bidder 提交过哪些 bid
- 每条 bid 是否可继续打开：
  - `bid thread`
  - `bid result`
  - `bid submission snapshot`

当前明确禁止：

- new `my_bids` shadow table
- bidder workspace state machine
- compare matrix persistence
- loser board persistence

## 6. `BidSubmissionSnapshot` Truth Boundary

`BidSubmissionSnapshot` 当前只允许从以下 truth 读时派生：

- canonical `Bid` submission truth
- bounded bidder display summary
- confirmed attachment summary

当前最小 read meaning 固定为：

- 当次 bid 提交时的只读摘要
- 供 bidder 或 current project owner 查看

当前明确禁止：

- editable bid form takeover
- resubmit command truth
- withdraw command truth
- compare / award / order bridge takeover

## 7. Server Read Family

当前为后续 implementation authoring 预冻结的 Server read family 只有：

- `GET /server/message/interactions`
- `GET /server/my/bids`
- `GET /server/bid/submission/snapshot`

当前继续复用的 thread truth read family：

- `GET /server/trading-im/bid/thread/detail`

它们都必须继续从既有 Server truth 派生，不得由 BFF 或 Flutter own。

## 8. Permission Truth

### 8.1 `message interactions`

当前最小 permission checks：

- current session valid
- current organization scope valid
- current actor admitted in the targeted project-bid relation

### 8.2 `my bids`

当前最小 permission checks：

- current session valid
- current actor is the bidder-side actor
- current organization scope matches bidder organization scope

### 8.3 `bid submission snapshot`

当前只允许以下两类 actor 读取：

- current bidder participant
- current project owner participant

非相关 viewer / unrelated bidder / forum actor 一律 fail-close。

## 9. Persistence Boundary

当前明确禁止：

- new generic chat table
- new `message_interactions` truth table with lifecycle
- new `my_bids` shadow table
- new `bid_submission_snapshot` table
- new message-index truth family
- `objectKey` business truth

当前继续允许复用：

- `Bid`
- `BidPrivateThread`
- `BidThreadMessage`
- confirmed `FileAsset`

## 10. Formal Conclusion

- `消息楼互动中心与我的竞标承接` 的 L3 backend truth boundary 现正式冻结。
- 日验收正式写死：
  - 已明确不新建聊天第二状态机
- 下一步只允许：
  - `Go for L4 BFF surface freeze authoring`
  - `Go for L5 frontend consumption freeze authoring`
- 当前仍：
  - `No-Go for implementation`
