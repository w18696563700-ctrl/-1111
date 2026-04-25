---
owner: Codex 总控
status: frozen
purpose: >
  Refine the BFF shaping surface for `bid submission snapshot` so the bounded
  attachment list survives transport and the participant-card handoff hint is
  preserved for Flutter consumption.
layer: L4 BFF
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_attachment_and_participant_entry_contract_refinement_addendum.md
  - docs/02_backend/my_bids_and_bid_submission_snapshot_attachment_truth_refinement_addendum.md
---

# 《我的竞标 / 竞标摘要 attachment surface refinement》

## 1. BFF Responsibility

BFF 当前只允许：

- forward `GET /server/bid/submission/snapshot`
- preserve bounded `attachments[]`
- preserve bounded `participantCardReadable`
- normalize controlled errors

## 2. Explicit No-Go

当前 BFF 明确不得：

- 重写附件真值
- 猜测文件名
- 把 `participant-card` payload 偷并进 snapshot
- 新造第二 snapshot state machine
