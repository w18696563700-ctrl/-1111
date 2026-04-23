---
owner: Codex 总控
status: active
purpose: Freeze the BFF implementation dispatch for `Trading IM participant-card minimum`.
layer: L0 SSOT
freeze_date_local: 2026-04-24
based_on:
  - docs/00_ssot/trading_im_participant_card_minimal_bounded_implementation_dispatch_bundle_addendum.md
  - docs/03_bff/trading_im_participant_card_minimal_bff_surface_freeze_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
---

# 《Trading IM participant-card minimum BFF implementation dispatch》

```text
你是 BFF Agent，本轮只闭合 `participant-card minimum` 的 app-facing transport，不重开 trading surface 设计。

【唯一目标】
1. materialize `GET /api/app/exhibition/trading/participant-card`
2. forward 到 `GET /server/trading-im/bid/thread/participant-card`
3. 只做 bounded shaping 和 controlled error mapping

【强制阅读】
- docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
- docs/03_bff/trading_im_participant_card_minimal_bff_surface_freeze_addendum.md
- apps/bff/src/routes/trading_im/**

【禁止事项】
- 不得 invent success fallback
- 不得 invent second profile card route family
- 不得把 `formal-info` 旧 path 改名

【完成标准】
- local BFF route 不再 `404`
- controlled errors:
  - THREAD_PARTICIPANT_CARD_INVALID
  - THREAD_PARTICIPANT_CARD_FORBIDDEN
  - THREAD_PARTICIPANT_CARD_UNAVAILABLE
  - AUTH_SESSION_INVALID
```
