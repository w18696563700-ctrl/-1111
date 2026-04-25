---
owner: Codex 总控
status: frozen
purpose: >
  Refine the bounded trading exception so that participant-card minimum remains
  readable under partial public projection loss and so that legacy bid
  submission snapshots may use a bounded read-only attachment compatibility
  resolution without mutating Bid truth.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/trading_im_participant_card_minimal_truth_freeze_addendum.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_snapshot_attachment_and_participant_entry_refinement_addendum.md
  - docs/02_backend/trading_im_participant_card_minimal_backend_truth_persistence_freeze_addendum.md
  - docs/02_backend/my_bids_and_bid_submission_snapshot_attachment_truth_refinement_addendum.md
---

# 《Trading IM participant-card / snapshot compatibility refinement》

## 1. Scope

- 本 refinement 只覆盖两处兼容边界：
  - `participant-card minimum`
  - `bid submission snapshot`
- 本 refinement 不新开任何新 route、不新增 truth owner、不新增 persistence object。

## 2. participant-card minimum Compatibility

- `participant-card minimum` 的唯一硬门槛仍然是：
  - 当前查看者是 admitted thread participant
  - 目标 `participantOrganizationId` 是同一 thread 的 admitted participant
  - 目标组织存在当前 `approved` organization certification truth
- 下列 public projection 源从本 refinement 起改为 **bounded optional source**：
  - enterprise listing summary
  - enterprise review summary
- 若 listing 缺失：
  - 不再整张名片 fail-close
  - Server 必须退化为最小可信公司摘要
  - display name 优先取 listing name，其次 organization name，再次 legal name
  - logo 允许为 `null`
  - province/city/board-type 允许回落到 bounded placeholder text
- 若 review summary 缺失：
  - 不再整张名片 fail-close
  - 必须返回：
    - `avgScore = null`
    - `reviewCount = 0`
    - `keywordTags = []`
- 仍然禁止：
  - contact info expansion
  - raw credit score
  - raw review rows
  - formal-info full-page takeover

## 3. bid submission snapshot Legacy Attachment Compatibility

- 新竞标的 canonical truth 不变：
  - 三个 attachment `FileAssetId` 仍然必须写入 `Bid`
- 仅对历史 legacy bid 且同时满足以下条件时，允许 Server 在读侧做 bounded compatibility resolution：
  - `Bid` 上三个 canonical attachment slot 全部为空
  - 当前 bid 仍有明确 `projectId`
  - 当前 bid 仍有明确 bidder organization scope
- bounded compatibility resolution 只允许按以下约束推断：
  - same bidder organization
  - same project id
  - same required `fileKind`
  - `file_asset.created_at <= bid.submitted_at`
  - 每个 slot 只取满足条件的最新一份 confirmed `FileAsset`
- 本 refinement 明确禁止：
  - 回写 `Bid`
  - 新建 backfill table
  - 将读侧兼容结果提升成新的 canonical truth
- 若任一 slot 无法受控解析：
  - snapshot 必须继续返回空 attachment list
  - 不得伪造附件存在

## 4. Unchanged Surfaces

- 当前 refinement 不改：
  - `participant-card minimum` app-facing path
  - `bid submission snapshot` app-facing path
  - Flutter 已冻结的 CTA 入口

## 5. Formal Conclusion

- 本 refinement 作为当前 bounded trading exception 的同链兼容补充正式冻结。
- 当前状态：
  - `Go for bounded backend refinement`
  - `No new contract family`
