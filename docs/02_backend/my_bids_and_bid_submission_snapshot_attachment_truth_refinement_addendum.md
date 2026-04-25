---
owner: Codex 总控
status: frozen
purpose: >
  Refine the Server truth for bid submission snapshot by freezing the three bid
  attachment slots onto `Bid` itself and requiring the snapshot to expose a
  bounded read-only attachment list derived from those canonical ids.
layer: L3 Backend
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_snapshot_attachment_and_participant_entry_refinement_addendum.md
  - docs/02_backend/messages_interaction_center_and_bidder_carry_backend_truth_persistence_freeze_addendum.md
  - docs/02_backend/exhibition_bid_submit_full_version_backend_truth_addendum.md
---

# 《我的竞标 / 竞标摘要 attachment truth refinement》

## 1. Canonical Carrier

当前三份竞标附件的 canonical carrier 正式固定在 `Bid`：

- `project_understanding_file_asset_id`
- `quote_sheet_file_asset_id`
- `schedule_plan_file_asset_id`

当前不得：

- 把三份附件只留在 upload corridor
- 用 `project + organization + fileKind` 回溯某次 bid 的“最新文件”

## 2. Validation Boundary

Server 在 `submitBid` 时必须验证：

- `FileAsset` 已确认存在
- `organization_id` 属于当前 bidder organization
- `business_type = project`
- `business_id = projectId`
- `file_kind` 与槽位匹配

## 3. Snapshot Projection Boundary

`BidSubmissionSnapshot` 当前必须从 `Bid` truth 派生：

- `attachmentSummary.count`
- `attachments[]`

`attachments[]` 当前只允许是 query projection：

- no second attachment table
- no shadow snapshot table
- no detached file truth family

## 4. Participant-card Handoff

当前 refinement 只允许 snapshot 暴露：

- `participantCardReadable`

它只作为 Flutter handoff hint，不得把 `participant-card` 直接并入 snapshot truth。
