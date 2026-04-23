---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the non-effective bounded implementation dispatch draft for `Core V1`
  of `消息楼互动中心` plus `我的竞标承接 / 竞标摘要`, so the eventual execution
  write scope, role split, and verification order are explicit even though the
  current gate judgment is `No-Pass` and the dispatch may not yet be sent.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/02_backend/messages_interaction_center_and_bidder_carry_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/messages_interaction_center_and_bidder_carry_bff_surface_freeze_addendum.md
  - docs/04_frontend/messages_interaction_center_and_bidder_carry_frontend_consumption_freeze_addendum.md
  - docs/00_ssot/messages_interaction_center_and_bidder_carry_core_v1_implementation_gate_judgment_addendum.md
---

# 《消息楼互动中心与我的竞标承接 Core V1 bounded implementation dispatch draft》

## 1. Nature

本 dispatch 当前正式固定为：

- non-effective draft

它当前不是：

- sent dispatch
- implementation approval
- code-start approval

## 2. Execution Role Split

若未来 gate 从 `No-Pass` 翻为 `Pass`，执行角色当前预冻结为：

- `Server / Backend Agent`
  - own Server truth implementation
- `BFF Agent`
  - own app-facing transport and shaping
- `Frontend Agent`
  - own Flutter consumption
- `Codex 总控`
  - own docs, receipts, and verification routing

## 3. Allowed Server Surface

未来若允许开工，Server 当前只允许触达：

- `apps/server/src/modules/trading_im/**`
- `apps/server/src/modules/bid/**`
- `apps/server/src/modules/my_project/**`
- bounded module wiring required by:
  - `message interactions`
  - `my bids`
  - `bid submission snapshot`

当前明确不允许扩到：

- generic message center
- participant-card
- compare / award / post-award bridge
- forum truth family

## 4. Allowed BFF Surface

未来若允许开工，BFF 当前只允许触达：

- `apps/bff/src/routes/trading_im/**`
- a bounded app-facing route family for:
  - `GET /api/app/message/interactions`
  - `GET /api/app/my/bids`
  - `GET /api/app/bid/submission/snapshot`
- minimum route/module wiring required by the paths above

当前明确不允许扩到：

- `message/index` active-object takeover
- forum inbox truth takeover
- participant-card

## 5. Allowed Frontend Surface

未来若允许开工，Flutter 当前只允许触达：

- `apps/mobile/lib/features/messages/**`
- `apps/mobile/lib/features/exhibition/presentation/pages/my_project_list_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/trading_im_bid_thread_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart`
- `apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
- a new bounded `BidSubmissionSnapshot` page or bottom sheet

当前明确不允许扩到：

- participant-card
- formal-info full-page takeover
- generic DM center
- compare / award workspace

## 6. Verification Order

若未来 dispatch 生效，验证顺序当前预冻结为：

1. local docs and contract sync
2. Server build / targeted tests
3. BFF build / targeted tests
4. Flutter targeted tests
5. ali-cloud deployment
6. tunnel smoke verification

## 7. Current Non-Effectiveness

当前必须正式写死：

- 因 `Core V1 gate = No-Pass`
- 本 dispatch draft 不得发送
- 本 dispatch draft 不得被任何 agent 解释为可直接开工口令

## 8. Formal Conclusion

- `Core V1 bounded implementation dispatch draft` 现正式冻结。
- 当前 formal meaning 只有：
  - future-ready write scope is documented
- 当前 formal meaning 不包括：
  - dispatch send
  - implementation start
