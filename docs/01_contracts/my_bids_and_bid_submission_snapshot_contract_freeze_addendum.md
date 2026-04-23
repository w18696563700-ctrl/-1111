---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimum L2 app-facing contract family for `我的竞标承接 / 竞标摘要`,
  introducing a bounded supplier-side `my bids` list and a read-only bid
  submission snapshot without reopening full bid governance or post-award
  bridge scope.
layer: L2 Contracts
freeze_date_local: 2026-04-23
inputs_canonical:
  - docs/00_ssot/my_bids_and_bid_submission_snapshot_truth_freeze_addendum.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_stage_gate_checklist_addendum.md
  - docs/01_contracts/bid_award_bridge_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《我的竞标承接 / 竞标摘要 contract freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `GET /api/app/my/bids`
  - `GET /api/app/bid/submission/snapshot`
- 本冻结单不覆盖：
  - award
  - result full workspace
  - compare board
  - loser board

## 2. Canonical Path Family

### 2.1 My Bids

- 当前建议 app-facing path：
  - `GET /api/app/my/bids`

### 2.2 Bid Submission Snapshot

- 当前建议 app-facing path：
  - `GET /api/app/bid/submission/snapshot`

## 3. `GET /api/app/my/bids`

### 3.1 Minimum Query

- 当前最小 query 只允许：
  - `state`

`state` 可选值：

- `active`
- `historical`

### 3.2 Minimum Response

最小 list item 字段固定为：

- `bidId`
- `projectId`
- `projectTitle`
- `submittedAt`
- `quoteAmount`
- `outcomeState`
- `canOpenBidThread`
- `canOpenBidResult`
- `snapshotReadable`

## 4. `GET /api/app/bid/submission/snapshot`

### 4.1 Minimum Query

- `projectId`
- `bidId`

该读面当前只允许由以下两类 handoff 进入：

- `我的竞标` list item
- `bid/thread/detail` 内的 `system_seed_action = bid_submission_snapshot.open`

### 4.2 Minimum Response

最小字段固定为：

- `projectId`
- `bidId`
- `bidder`
- `submittedAt`
- `quoteAmount`
- `proposalSummary`
- `attachmentSummary`
- `availability`

### 4.3 BidderSummary

- `organizationId`
- `displayName`
- `avatarUrl`

## 5. Hard Boundary

当前 contract 明确禁止混入：

- editable fields
- resubmit command hints
- compare score matrix
- loser/winner board
- order conversion ids
- contract seed ids
- post-award workflow state machine

## 6. Error Boundary

当前最小错误族固定为：

- `MY_BIDS_UNAVAILABLE`
- `MY_BIDS_FORBIDDEN`
- `BID_SUBMISSION_SNAPSHOT_UNAVAILABLE`
- `BID_SUBMISSION_SNAPSHOT_FORBIDDEN`
- `AUTH_SESSION_INVALID`

## 7. Stage Conclusion

- 当前 contract freeze 正式完成。
- 下一步只允许：
  - `Go for backend truth freeze authoring`
- 当前仍：
  - `No-Go for implementation`
