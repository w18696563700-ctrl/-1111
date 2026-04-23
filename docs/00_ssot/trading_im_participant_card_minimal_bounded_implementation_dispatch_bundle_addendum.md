---
owner: Codex 总控
status: active
purpose: >
  Freeze the bounded implementation dispatch bundle for `Trading IM participant-card minimum`
  so execution starts only within the admitted Server query / BFF transport /
  Flutter thread-sheet consumption corridor.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/trading_im_participant_card_minimal_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/trading_im_participant_card_minimal_implementation_unlock_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
  - docs/02_backend/trading_im_participant_card_minimal_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/trading_im_participant_card_minimal_bff_surface_freeze_addendum.md
---

# 《Trading IM participant-card minimum bounded implementation dispatch bundle》

## 1. 当前唯一对象

- `Trading IM participant-card minimum`

## 2. 当前唯一执行范围

- Server：
  - `GET /server/trading-im/bid/thread/participant-card`
  - admitted thread participant judgment
  - target participant enterprise summary / review summary / bounded formal summary projection
- BFF：
  - `GET /api/app/exhibition/trading/participant-card`
  - controlled error mapping
  - bounded shaping only
- Flutter：
  - `BidThreadPage` participant row click
  - read-only participant-card sheet / page
  - static copy `合作前建议查看对方企查查信息`
- Verification：
  - build
  - targeted tests
  - ali-cloud tunnel smoke

## 3. 明确禁止

- 不得扩到 generic chat profile center
- 不得新增 `participant_card` persistence
- 不得扩到 `formal-info` full-page takeover
- 不得扩到 compare / award / contract / dispute
- 不得扩到 public enterprise detail route family replacement

## 4. 交付顺序

1. Server implementation + local test
2. BFF implementation + local test
3. Flutter implementation + local test
4. cloud deployment + tunnel smoke
5. execution receipts + result verification

## 5. Formal Conclusion

- 当前 bundle 冻结为唯一 admitted execution order。
- 任何越出以上范围的实现都视为 drift。
