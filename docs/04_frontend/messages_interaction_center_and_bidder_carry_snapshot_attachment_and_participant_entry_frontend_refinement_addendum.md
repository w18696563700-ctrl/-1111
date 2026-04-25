---
owner: Codex 总控
status: frozen
purpose: >
  Refine Flutter consumption for the message-driven bid handoff by surfacing the
  participant-card CTA on the system-seed/snapshot path and by rendering the
  bounded snapshot attachment list with shared file access reuse.
layer: L5 Frontend
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_attachment_and_participant_entry_contract_refinement_addendum.md
  - docs/03_bff/my_bids_and_bid_submission_snapshot_attachment_surface_refinement_addendum.md
  - docs/04_frontend/messages_interaction_center_and_bidder_carry_frontend_consumption_freeze_addendum.md
---

# 《消息楼互动中心 / 竞标摘要 attachment + participant entry frontend refinement》

## 1. Scope

- 本 refinement 只覆盖：
  - `BidThreadPage` 内的 bounded `system_seed` 卡
  - `BidSubmissionSnapshot` bottom sheet/page

## 2. System-seed CTA

当前 system-seed 卡正式允许两个 bounded CTA：

- `点击查看`
- `查看竞标方`

其中：

- `点击查看` -> `bid submission snapshot`
- `查看竞标方` -> `participant-card minimum`

## 3. Snapshot Consumption

Snapshot 当前必须展示：

- `attachmentSummary`
- `attachments[]`

并允许对每个 attachment 使用 shared `GET /api/app/file/access` 下载或预览。

当前不得：

- 伪造原始文件名
- 扩成编辑器
- 从 snapshot takeover `formal-info` full page
