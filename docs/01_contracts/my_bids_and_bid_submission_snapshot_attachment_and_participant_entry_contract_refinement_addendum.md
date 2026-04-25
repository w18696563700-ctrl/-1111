---
owner: Codex 总控
status: frozen
purpose: >
  Refine the app-facing contracts for `my bids / bid submission snapshot` by
  adding a bounded read-only attachment list and by admitting the participant
  card handoff from the snapshot and the system-seed message path.
layer: L2 Contracts
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_snapshot_attachment_and_participant_entry_refinement_addendum.md
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_contract_freeze_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
---

# 《我的竞标 / 竞标摘要 attachment + participant entry contract refinement》

## 1. Scope

- 本 contract refinement 只覆盖：
  - `GET /api/app/bid/submission/snapshot`
- 本 refinement 不改：
  - `GET /api/app/my/bids` path
  - `GET /api/app/exhibition/trading/participant-card` path

## 2. `GET /api/app/bid/submission/snapshot`

### 2.1 Existing Fields Retained

- `projectId`
- `bidId`
- `bidder`
- `submittedAt`
- `quoteAmount`
- `proposalSummary`
- `attachmentSummary`
- `availability`

### 2.2 New Bounded Field

新增：

- `attachments`

`attachments` 必须是数组，最小 item 字段固定为：

- `slotKey`
- `slotLabel`
- `fileAssetId`
- `fileKind`
- `mimeType`

### 2.3 Bidder Handoff

当前 snapshot contract 允许一个 bounded CTA handoff：

- `participantCardReadable = true | false`

当前 handoff target 继续固定为：

- `GET /api/app/exhibition/trading/participant-card`

当前不得在 snapshot contract 内直接内嵌：

- full participant-card payload
- full formal-info payload

## 3. Error Boundary

当前 refinement 不新增新的错误族；继续复用：

- `BID_SUBMISSION_SNAPSHOT_UNAVAILABLE`
- `BID_SUBMISSION_SNAPSHOT_FORBIDDEN`
- `AUTH_SESSION_INVALID`
