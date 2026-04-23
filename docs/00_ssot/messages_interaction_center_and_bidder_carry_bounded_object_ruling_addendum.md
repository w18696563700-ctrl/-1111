---
owner: Codex 总控
status: active
purpose: >
  Formally bound the current cross-package object for `消息楼互动中心` and
  `我的竞标承接 / 竞标摘要`, so the next round may author docs-only gate,
  truth, and contract freezes without mixing reminder projection, generic
  chat-center ambition, or participant-card expansion.
layer: L0 SSOT
updated_at: 2026-04-23
based_on:
  - AGENTS.md
  - docs/00_ssot/messages_interaction_center_bid_trigger_chat_blueprint_addendum.md
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/00_ssot/project_transaction_skeleton_freeze_addendum.md
  - docs/04_frontend/my_project_publish_bid_split_frontend_truth_note.md
  - docs/00_ssot/trading_im_participant_card_minimal_stop_line_reentry_gate_path_independent_review_addendum.md
  - docs/00_ssot/s1_c01_message_index_minimal_closure_execution_dispatch_receipt_addendum.md
---

# 《消息楼互动中心与我的竞标承接 bounded-object ruling》

## 1. Scope

当前对象只覆盖两包：

- `Package A`：
  - `消息楼互动中心`
- `Package B`：
  - `我的竞标承接 / 竞标摘要`

当前对象只服务于：

- docs-only bounded object locking
- docs-only stage gate authoring
- docs-only truth freeze authoring
- docs-only contracts freeze authoring

当前对象不代表：

- implementation unlock
- dispatch send
- integration
- release-prep
- launch approval

## 2. Business Goal

当前对象唯一业务目标冻结为：

- 让 `提交竞标` 成为平台内互动的种子事件
- 让 `消息楼` 成为交易互动中心而不是弱提醒占位
- 让 `我的竞标` 成为 supplier 私域承接入口
- 让平台优先保留关键沟通与关键确认痕迹

## 3. Package A Boundary

`Package A = 消息楼互动中心`

它当前只允许包含：

- 交易互动列表
- 由 `bid submit` 触发的会话种子建立
- 进入 `bid thread` 的聊天框 handoff
- 首条系统消息语义
- 项目沟通 lane 与论坛互动 lane 的并行分层

它当前不得扩到：

- generic message center
- stranger DM
- group chat
- realtime / websocket / push
- unread/read lifecycle governance
- typing / online / station inbox
- participant-card
- full profile center

## 4. Package B Boundary

`Package B = 我的竞标承接 / 竞标摘要`

它当前只允许包含：

- `我的竞标` 私域列表
- `bid submit` 成功后的只读摘要
- 从聊天首条系统消息 `点击查看` 进入的竞标提交摘要
- `我的竞标 -> 沟通与投标` handoff

它当前不得扩到：

- full bid workspace
- compare board
- loser board
- bid award bridge
- resubmit / edit / withdraw bid
- order conversion
- contract seed takeover

## 5. Page Boundary

当前允许触达的页面固定为：

- `MessagesPage`
- `BidThreadPage`
- `MyProjectListPage`
- `BidSubmitPage` result posture only
- a new `BidSubmissionSnapshot` page or bottom sheet

当前明确排除：

- participant-card page
- formal-info full page takeover
- buyer compare console
- seller bid-governance workbench

## 6. Object Boundary

当前 admitted object cluster 只允许包含：

1. `Bid`
2. `BidThread`
3. `BidThreadMessage`
4. `BidThreadConfirmationCard`
5. `MessagesInteractionListItem`
6. `BidSubmittedSystemSeed`
7. `BidSubmissionSnapshot`
8. `MyBidsListItem`

当前明确排除：

- `participant-card minimum`
- `formal-info full read`
- `credit scoring`
- `cooperation history center`
- payment / billing / guarantee

## 7. Reuse Rule

当前对象必须复用既有真值，不得新造第二对象族：

- 私密聊天复用：
  - `bid_thread`
  - `bid_thread_messages`
  - `bid_thread_confirmation_cards`
- 个人头像 / 昵称继续复用：
  - `profile personal edit`
- 企业认证摘要继续复用：
  - 既有 `formal-info` truth family

## 8. Cloud/Local Topology Boundary

当前对象必须遵守以下运行拓扑：

- 本地只有 Flutter 可直接本机消费与测试
- `apps/server` 和 `apps/bff` 源码在仓里
- 真实运行态在阿里云
- 当前云端核查入口只认：
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`

## 9. Adjacent Object Exclusion

当前必须显式排除相邻对象，避免 scope 漂移：

- `message/index placeholder / reminder projection` 旧口径
- `participant-card minimum`
- `project clarification full expansion`
- `bid award bridge`

## 10. Formal Conclusion

- 当前正式新开 bounded object：
  - `消息楼互动中心与我的竞标承接`
- 当前下一步唯一允许动作：
  - author `stage gate checklist`
  - author `truth freeze`
  - author `contracts freeze`
- 当前正式 `No-Go`：
  - direct implementation
  - runtime completion claim
  - participant-card mixed-in expansion
