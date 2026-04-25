---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded Flutter-side avatar consumption for the approved trading
  interaction surfaces so that counterpart visual identity is visible on the
  real user path without opening a new identity center.
layer: L5 Frontend
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/trading_im_visual_identity_projection_refinement_addendum.md
  - docs/01_contracts/trading_im_visual_identity_projection_contract_refinement_addendum.md
  - apps/mobile/lib/features/messages/presentation/messages_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/trading_im_bid_thread_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/bid_submission_snapshot_sheet.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/trading_im_participant_card_sheet.dart
---

# 《Trading IM visual identity projection frontend refinement》

## 1. Scope

- 本 refinement 只覆盖当前已批准消费面：
  - `MessagesPage` 项目沟通卡
  - `BidThreadPage` 参与方列表
  - `BidSubmissionSnapshot` 头部
  - `participant-card minimum` sheet

## 2. Visual Consumption Rule

- Flutter 当前必须优先显示已有 visual URL：
  - `counterpart.avatarUrl`
  - `bidder.avatarUrl`
  - `enterpriseSummary.logoUrl`
- 若 visual URL 为空：
  - Flutter 可继续显示首字母占位

## 3. No-Go

- 当前明确禁止：
  - avatar edit
  - profile page takeover
  - second organization identity center
  - DM/chat roster expansion beyond approved surfaces

## 4. Formal Conclusion

- 当前 refinement 仅允许 bounded avatar display consumption。
- 不新增新的 Flutter route family。
