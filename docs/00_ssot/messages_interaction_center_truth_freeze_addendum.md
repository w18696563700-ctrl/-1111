---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimum L0 truth boundary for `消息楼互动中心`, defining it as the
  trading interaction list and thread-entry surface seeded by bid submit while
  keeping forum interaction in a separate lane and excluding generic message
  center expansion.
layer: L0 SSOT
freeze_date_local: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_bounded_object_ruling_addendum.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_cloud_baseline_evidence_receipt_addendum.md
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/01_contracts/trading_im_round_a_contracts_addendum.md
  - docs/04_frontend/trading_im_round_a_frontend_consumption_freeze_addendum.md
---

# 《消息楼互动中心 truth freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `消息楼互动中心`
- 它当前唯一定位固定为：
  - 交易互动列表
  - 以 `bid submit` 为种子事件的会话入口
  - 直接 handoff 到 `bid thread` 聊天框
- 本冻结单不覆盖：
  - forum lane
  - participant-card
  - generic DM center

## 2. Object Definition

当前对象正式定义为：

- `messages interaction center`

它不是：

- `message/index placeholder`
- generic message center
- station inbox
- unread center
- push center

## 3. Event Anchor

当前唯一 admitted 种子事件固定为：

- `BidSubmitted`

衍生事件链固定为：

1. `BidSubmitted`
2. `BidThreadResolved`
3. `BidSubmittedSystemSeedCreated`
4. `MessagesInteractionProjectionUpserted`

## 4. Interaction Lane Boundary

`MessagesPage` 当前必须分成两个 lane：

1. `项目沟通`
   - 真实交易互动列表
2. `论坛互动`
   - 保持独立 lane

当前禁止：

- 把两条 lane 混成单对象
- 把 forum interaction 当成交易聊天列表

## 5. Data Family

当前允许使用的数据族只有：

- `Bid`
- `BidThread`
- `BidThreadMessage`
- `BidThreadConfirmationCard`
- bounded counterpart summary projection

当前 interaction list item 的最小语义只有：

- 这是不是一个当前交易会话
- 当前会话对应哪个 `projectId + bidId`
- 对方是谁
- 最近一条可展示摘要是什么
- 进入后该跳到哪个 `bid thread`

## 6. System Seed Rule

当前正式写死：

- 每当 `bid submit` 成功成立一条新竞标
- 若对应 `bid thread` 尚不存在，则必须先 resolve/create
- 聊天框第一条必须是系统种子消息

当前系统种子消息的最小语义固定为：

- 谁提交了竞标
- 何时提交
- 提供 `点击查看` 的摘要动作

## 7. Excluded Scope

当前明确排除：

- unread/read lifecycle
- typing / online / push
- stranger / group chat
- conversation search
- station inbox governance
- participant-card display
- external enterprise risk lookup

## 8. Formal Conclusion

- `消息楼互动中心` 的 L0 truth boundary 现正式冻结。
- 当前状态只允许：
  - `Go for contracts freeze`
- 当前仍明确：
  - `No-Go for implementation`
