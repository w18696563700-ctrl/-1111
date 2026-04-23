---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L5 Flutter consumption boundary for `消息楼互动中心` plus `我的竞标
  承接 / 竞标摘要`, defining the dual-lane messages building, the thread-first
  system seed consumption, the read-only bid submission snapshot page/sheet,
  and the bounded handoff among Messages, My Project, Project Detail, and Bid
  Submit result posture.
layer: L5 Frontend
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_contract_freeze_addendum.md
  - docs/02_backend/messages_interaction_center_and_bidder_carry_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/messages_interaction_center_and_bidder_carry_bff_surface_freeze_addendum.md
  - apps/mobile/lib/features/messages/presentation/messages_page.dart
  - apps/mobile/lib/features/messages/data/messages_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/trading_im_bid_thread_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
---

# 《消息楼互动中心与我的竞标承接 frontend consumption freeze》

## 1. Scope

- Flutter implementation remains local-only.
- Flutter consumes BFF app-facing contracts only.
- 本冻结单只覆盖：
  - `MessagesPage`
  - `MyProjectListPage`
  - `BidThreadPage`
  - `BidSubmitPage` result posture
  - a new `BidSubmissionSnapshot` page or bottom sheet
- 本冻结单不覆盖：
  - participant-card
  - formal-info full-page takeover
  - generic DM center
  - compare / award / post-award workspace

## 2. Messages Building Dual Lane

`MessagesPage` 当前正式固定为双 lane：

1. `项目沟通`
   - consume `GET /api/app/message/interactions`
2. `论坛互动`
   - continue consuming the existing forum inbox family

当前明确禁止：

- 把 `项目沟通` 与 `论坛互动` 混成单对象
- 把 `项目沟通` 做成 generic message center
- 把 `message/index` 当成当前互动中心 truth

## 3. `我的竞标` Consumption

`MyProjectListPage` 当前继续固定为：

- `我的发布`
- `我的竞标`

其中 `我的竞标` 当前只允许承担：

- bidder 私域竞标记录列表
- 打开：
  - `沟通与投标`
  - `竞标摘要`

当前明确禁止：

- full bidder workspace
- compare board
- loser management console

## 4. Thread-First Consumption

`BidThreadPage` 当前正式固定为：

- 互动中心列表的唯一 admitted thread handoff target
- 聊天首条系统消息的消费面

当前 thread detail 消费只允许承接：

- `messageKind`
- `systemSeedType`
- `systemSeedAction`

当前正式写死：

- 当 `messageKind = system_seed`
- 且 `systemSeedType = bid_submitted`
- Flutter must render a bounded system seed card
- 系统 seed card 只允许一个 CTA：
  - `点击查看`

该 CTA 的唯一 admitted action 为：

- `bid_submission_snapshot.open`

## 5. Read-only Snapshot Consumption

当前允许新开一个最小只读消费载体：

- `BidSubmissionSnapshot` page
  - or bottom sheet

它当前只允许展示：

- bidder summary
- submittedAt
- quoteAmount
- proposalSummary
- attachmentSummary
- availability

它当前不得膨胀成：

- editable bid form
- resubmit center
- withdraw center
- compare console

## 6. Bid Submit Result Posture

`BidSubmitPage` 当前只允许在成功结果姿态下承担：

- `沟通与投标`
- `查看我的竞标`
- bounded handoff to `BidSubmissionSnapshot`

当前正式不新开：

- standalone result workspace
- bidder governance center

## 7. Project Detail Boundary

`ProjectDetailPage` 当前只允许承担：

- first-entry explanation
- single bid CTA
- bounded jump into:
  - `项目澄清`
  - `沟通与投标`

当前不得扩成：

- long-term interaction center
- bidder result truth page

## 8. Frontend No-Go

当前明确禁止：

- direct Server calls
- local permission engine
- local chat truth
- read receipt / typing / online status
- participant-card entry
- formal-info full takeover
- stranger DM / group chat

## 9. Formal Conclusion

- `消息楼互动中心与我的竞标承接` 的 L5 frontend consumption boundary 现正式冻结。
- 当前日验收正式写死：
  - `消息楼双 lane` 的 Flutter 消费定义已冻结
  - `聊天首条系统消息` 的 Flutter 消费定义已冻结
  - `竞标摘要只读页` 的 Flutter 消费定义已冻结
- 当前已形成：
  - `L0 -> L5` 完整文书链
- 下一步只允许：
  - `Go for Core V1 gate judgment authoring`
- 当前仍：
  - `No-Go for implementation`
