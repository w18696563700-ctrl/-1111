---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded Server-side compatibility behavior for participant-card
  minimum degraded projection and legacy bid submission snapshot attachment
  resolution while preserving the existing canonical truth families.
layer: L3 Backend
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/trading_im_participant_card_and_snapshot_compatibility_refinement_addendum.md
  - docs/02_backend/trading_im_participant_card_minimal_backend_truth_persistence_freeze_addendum.md
  - docs/02_backend/my_bids_and_bid_submission_snapshot_attachment_truth_refinement_addendum.md
  - apps/server/src/modules/trading_im/trading-im-participant-card.query.service.ts
  - apps/server/src/modules/my_bid/my-bid.query.service.ts
---

# 《Trading IM participant-card / snapshot compatibility backend refinement》

## 1. Scope

- 本 refinement 只覆盖：
  - `TradingImParticipantCardQueryService`
  - `MyBidQueryService.getSubmissionSnapshot`
- 不新增 table、不新增 write command、不新增 state machine。

## 2. participant-card minimum Degraded Read Rule

- Canonical hard gate 保持不变：
  - admitted thread participant judgment
  - target participant admitted judgment
  - target organization current `approved` certification truth
- `EnterpriseListingEntity` 从本 refinement 起降为 optional bounded source。
- `EnterpriseReviewSummaryEntity` 从本 refinement 起降为 optional bounded source。
- Server output must still preserve the frozen response shape:
  - `enterpriseSummary`
  - `reviewSummary`
  - `formalInfoSummary`
- Required degraded output behavior:
  - listing missing -> use bounded fallback values
  - review missing -> return empty aggregate defaults
- Only these conditions still fail closed:
  - thread missing
  - viewer not admitted
  - target participant not admitted
  - target organization certification missing or not approved

## 3. bid submission snapshot Legacy Attachment Read Compatibility

- New bid snapshot continues to read canonical attachment ids from `Bid`.
- Legacy compatibility resolution is read-only and admitted only when all three canonical attachment slots on `Bid` are empty.
- Resolution source is bounded to:
  - `FileAsset.organizationId = bidderOrganizationId`
  - `FileAsset.businessType = project`
  - `FileAsset.businessId = bid.projectId`
  - `FileAsset.fileKind` matches the frozen bid submission slot family
  - `FileAsset.createdAt <= bid.submittedAt`
- Resolution rule:
  - choose the latest matching `FileAsset` for each required slot
  - only if all three slots are resolved may snapshot expose `attachments[]`
- If any slot is missing:
  - snapshot returns empty `attachments[]`
  - no fake attachment count is admitted

## 4. Formal Conclusion

- Current bounded backend refinement is frozen.
- Current status:
  - `Go for same-chain implementation`
  - `No persistence expansion`
