---
owner: Codex 总控
status: frozen
purpose: >
  Refine the bounded `messages interaction center and bidder carry` exception by
  restoring canonical bid attachment truth into `bid submission snapshot` and
  moving the admitted `participant-card minimum` handoff onto the user's actual
  message-driven action path.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_implementation_unlock_addendum.md
  - docs/00_ssot/trading_im_participant_card_minimal_implementation_unlock_addendum.md
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_contract_freeze_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
  - docs/02_backend/exhibition_bid_submit_full_version_backend_truth_addendum.md
---

# 《消息楼互动中心 / 竞标摘要附件真值与名片入口 refinement》

## 1. Scope

- 本 refinement 只覆盖：
  - `Bid` 上三份竞标附件槽位的 canonical truth
  - `bid submission snapshot` 的只读附件列表
  - `system_seed -> snapshot -> participant-card` 的最小 handoff
- 本 refinement 不覆盖：
  - compare / award / post-award
  - generic DM / group chat
  - `formal-info` full-page takeover
  - 重新开放可编辑投标表单

## 2. Canonical Truth Correction

- `projectUnderstandingFileAssetId`
- `quoteSheetFileAssetId`
- `schedulePlanFileAssetId`

以上三项继续是当前 bounded bid submit truth 的正式组成部分。

- Flutter submit command 不得丢弃这三项
- Server `Bid` truth 必须持久化这三项
- `bid submission snapshot` 必须从 `Bid` truth 读取这三项
- 不得用“project 下最新上传文件”反推某次 bid 的附件

## 3. Snapshot Refinement

`bid submission snapshot` 当前正式补充两个层级：

1. `attachmentSummary`
2. `attachments[]`

其中：

- `attachmentSummary` 继续只承担数量摘要
- `attachments[]` 承担最小只读文件列表

`attachments[]` 当前最小字段只允许：

- `slotKey`
- `slotLabel`
- `fileAssetId`
- `fileKind`
- `mimeType`

当前明确禁止：

- 原始 `objectKey`
- 编辑 / 删除 / 替换入口
- 伪造文件名真值

## 4. Participant-card Entry Refinement

当前正式补充：

- `system_seed` 卡允许一个额外 bounded CTA：
  - `查看竞标方`
- `bid submission snapshot` 允许一个 bounded CTA：
  - `查看竞标方名片`

这两个 CTA 都只允许 handoff 到：

- `participant-card minimum`

当前明确禁止：

- 直接 takeover `formal-info` full page
- 从 snapshot 直接跳 compare / award

## 5. Formal Conclusion

- 当前 refinement 只修正已放行 bounded package 内的 truth drift 和 handoff gap。
- 当前 refinement 不新增第二状态机，不新增第二文件真值，不新增新的 trading exception family。
