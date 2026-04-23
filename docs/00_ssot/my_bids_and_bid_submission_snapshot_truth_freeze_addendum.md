---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimum L0 truth boundary for `我的竞标承接 / 竞标摘要`, defining
  the supplier-side private bid carry as a bounded list plus a read-only bid
  submission snapshot, without reopening full bid workspace, compare, award,
  or post-award bridge semantics.
layer: L0 SSOT
freeze_date_local: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_bounded_object_ruling_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/04_frontend/my_project_publish_bid_split_frontend_truth_note.md
  - docs/01_contracts/bid_award_bridge_contract_freeze_addendum.md
---

# 《我的竞标承接 / 竞标摘要 truth freeze》

## 1. Scope

- 本冻结单只覆盖：
  - supplier `我的竞标` 私域承接
  - `竞标提交摘要` 只读对象
- 本冻结单不覆盖：
  - full bid workspace
  - compare
  - bid award bridge
  - order conversion

## 2. Object Definition

当前对象固定为两个 child objects：

1. `MyBidsList`
   - supplier 私域竞标列表
2. `BidSubmissionSnapshot`
   - 当前竞标提交的只读摘要

## 3. Visibility Boundary

`MyBidsList` 只对当前 bidder actor 成立。

`BidSubmissionSnapshot` 当前只允许对以下两类可见：

- current bidder participant
- current project owner participant

当前明确不可见：

- unrelated viewer
- unrelated bidder
- forum actor

## 4. Business Meaning

`MyBidsList` 的唯一作用固定为：

- 沉淀我提交过的竞标记录
- 作为进入 `沟通与投标` 的私域列表入口

`BidSubmissionSnapshot` 的唯一作用固定为：

- 从聊天首条系统消息 `点击查看`
- 或从 `我的竞标` 中查看
- 只读查看当次竞标提交摘要

## 5. Data Family

当前只允许包含的最小数据族：

- `bidId`
- `projectId`
- `project summary`
- `submittedAt`
- `quoteAmount`
- `proposalSummary`
- confirmed attachment summary
- `outcomeState`
- `canOpenBidThread`
- `canOpenBidResult`

## 6. Excluded Scope

当前明确排除：

- edit / resubmit / withdraw bid
- compare board
- loser board
- award action
- order conversion
- contract seed
- post-award detail center

## 7. Snapshot Rule

`BidSubmissionSnapshot` 当前必须固定为：

- read-only
- anchored by `projectId + bidId`
- reflecting the admitted bid submission truth
- not a second editable bid form

## 8. Formal Conclusion

- `我的竞标承接 / 竞标摘要` 的 L0 truth boundary 现正式冻结。
- 当前状态只允许：
  - `Go for contracts freeze`
- 当前仍明确：
  - `No-Go for implementation`
