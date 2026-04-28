---
owner: Codex 总控
status: frozen
purpose: >
  Refine the `GET /api/app/my/bids` app-facing contract so the project number
  and proposal preview already used by Server and Flutter are formal fields.
layer: L2 Contracts
freeze_date_local: 2026-04-29
based_on:
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_contract_freeze_addendum.md
  - docs/00_ssot/my_bids_list_project_no_preview_runtime_gap_truth_freeze_addendum.md
---

# 《我的竞标列表 projectNo / proposalSummaryPreview Contract Refinement》

## 1. Scope

本 refinement 只覆盖：

- `GET /api/app/my/bids`

本 refinement 不覆盖：

- `GET /api/app/bid/submission/snapshot`
- bid submit command
- bid award
- compare / loser board
- order conversion
- post-award workflow

## 2. Response Contract

`GET /api/app/my/bids` 成功响应：

```json
{
  "items": [
    {
      "bidId": "string",
      "projectId": "string",
      "projectNo": "string",
      "projectTitle": "string",
      "quoteAmount": 0,
      "proposalSummaryPreview": "string",
      "submittedAt": "string",
      "outcomeState": "string",
      "canOpenBidThread": true,
      "canOpenBidResult": false,
      "snapshotReadable": true
    }
  ]
}
```

## 3. Field Rules

- `projectNo`：
  - required string
  - Server-owned project number projection
  - must not be synthesized by Flutter
  - must not be recomputed by BFF
- `proposalSummaryPreview`：
  - required string
  - Server-owned bid proposal preview projection
  - must be safe for list display
  - must not expose attachments or full bid form state
- `snapshotReadable`：
  - required boolean
  - reserved as a controlled handoff flag
  - this refinement does not require Flutter to add a new CTA

## 4. Current Minimum Loop

1. Flutter requests `/api/app/my/bids`.
2. BFF requests `/server/my/bids`.
3. Server returns the frozen item fields.
4. BFF validates and preserves the item fields.
5. Flutter renders my bids without local fallback.

## 5. Contract No-Go

- Do not make `projectNo` optional.
- Do not replace `proposalSummaryPreview` with full `proposalSummary`.
- Do not add editable bid fields.
- Do not add award or order-conversion identifiers.
- Do not reopen snapshot attachment rules in this refinement.

## 6. Strategy Judgment

- More stable: formalize the fields already owned by Server and consumed by Flutter.
- Lower cost: no route change and no Server schema change.
- Best fit now: repair the list contract drift before opening any new CTA.
- Highest risk: weakening Flutter validation to hide BFF contract drift.
