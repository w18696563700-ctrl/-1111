---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the narrow implementation unlock that adds `participant-card minimum`
  into the current bounded trading exception without widening the approved
  trading surface beyond read-only company-card consumption inside the existing
  bid thread chain.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_implementation_unlock_addendum.md
  - docs/00_ssot/trading_im_participant_card_minimal_bounded_trading_exception_refresh_review_conclusion_addendum.md
  - docs/00_ssot/trading_im_participant_card_minimal_truth_freeze_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
  - docs/02_backend/trading_im_participant_card_minimal_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/trading_im_participant_card_minimal_bff_surface_freeze_addendum.md
---

# 《Trading IM participant-card minimum implementation unlock addendum》

## Scope

- This addendum applies only to:
  - `Trading IM participant-card minimum`
- It unlocks only:
  - `GET /api/app/exhibition/trading/participant-card`
  - matching `Server`, `BFF`, and Flutter implementation needed to support
    bounded `BidThreadPage` avatar/company-name click

## Passed Gates

- refreshed reentry basis is frozen
- bounded trading exception refresh review chain is frozen
- L0/L2/L3/L4 docs chain is frozen
- object remains query-only and same-chain

## Retained Veto

- no new building
- no `participant_card` table
- no generic org-card center
- no generic DM / group chat
- no `formal-info` full-page takeover
- no credit score surface
- no compare / award / post-award bridge
- no payment / billing / settlement

## Approved Implementation Scope

- Server:
  - `GET /server/trading-im/bid/thread/participant-card`
- BFF:
  - `GET /api/app/exhibition/trading/participant-card`
- Flutter:
  - `BidThreadPage` avatar/company-name click
  - read-only participant-card sheet / page
- Continuity only:
  - bounded `formalInfoSummary`
  - no full-page `formal-info`

## Formal Conclusion

- `participant-card minimum` is now added into the current bounded trading
  exception scope
- matching `Server`, `BFF`, and Flutter implementation is now allowed inside
  the frozen current boundary
- all retained veto items above remain active
