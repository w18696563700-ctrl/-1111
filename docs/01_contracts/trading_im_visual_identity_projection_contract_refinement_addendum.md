---
owner: Codex 总控
status: frozen
purpose: >
  Refine the existing app-facing contracts for message interactions, bid
  submission snapshot, and participant-card minimum so that current avatar/logo
  carriers are explicitly admitted as readable visual-display projections.
layer: L2 Contracts
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/trading_im_visual_identity_projection_refinement_addendum.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_contract_freeze_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
---

# 《Trading IM visual identity projection contract refinement》

## 1. Scope

- 本 refinement 只收紧既有字段语义：
  - `counterpart.avatarUrl`
  - `bidder.avatarUrl`
  - `enterpriseSummary.logoUrl`
- 本 refinement 不新增字段，不改 path，不改 query。

## 2. `message interactions`

- `counterpart.avatarUrl` 当前正式写死为：
  - readable visual projection only
  - may be `null`
  - may project an admitted counterpart user avatar
- `counterpart.avatarUrl` 不得被解释为：
  - raw file truth
  - profile edit truth
  - enterprise certification truth

## 3. `bid submission snapshot`

- `bidder.avatarUrl` 当前正式写死为：
  - readable visual projection only
  - may be `null`
  - may project the submitted bidder actor's current avatar

## 4. `participant-card minimum`

- `enterpriseSummary.logoUrl` 当前正式写死为：
  - readable visual-display projection only
  - enterprise logo preferred
  - admitted counterpart user avatar allowed as bounded fallback
  - may be `null`
- 即使回落到 personal avatar：
  - `enterpriseSummary.logoUrl` 仍不得被提升成企业 logo truth

## 5. Formal Conclusion

- 当前 app-facing contract family schema 不变。
- 仅视觉投影语义经本 refinement 正式冻结。
