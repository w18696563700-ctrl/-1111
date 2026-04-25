---
owner: Codex 总控
status: frozen
purpose: >
  Refine the current bounded trading exception so that message interactions,
  bid submission snapshot, and participant-card minimum all expose one readable
  visual-identity projection, with enterprise logo preferred and admitted
  personal avatar allowed only as a bounded fallback display source.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/messages_interaction_center_bid_trigger_chat_blueprint_addendum.md
  - docs/00_ssot/trading_im_participant_card_and_snapshot_compatibility_refinement_addendum.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
  - docs/01_contracts/my_bids_and_bid_submission_snapshot_contract_freeze_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
---

# 《Trading IM visual identity projection refinement》

## 1. Scope

- 本 refinement 只覆盖当前 bounded trading exception 内的视觉身份显示位：
  - `message interactions`
  - `bid submission snapshot`
  - `participant-card minimum`
- 本 refinement 不新开任何 route、不新增 persistence object、不引入第二头像真相。

## 2. Visual Identity Projection Rule

- 当前唯一 admitted 视觉身份规则固定为：
  - enterprise logo 优先
  - 缺失时可回落到 admitted counterpart user avatar
- 该回落当前只允许用于：
  - 线程参与方列表头像
  - 互动中心项目沟通会话头像
  - 竞标摘要中的竞标方头像
  - participant-card minimum 头像位

## 3. Truth Ownership

- 企业 logo 真相仍归既有 enterprise listing / media projection 家族。
- 个人头像真相仍归既有 profile identity truth：
  - `users.avatar_url`
  - `users.avatar_file_asset_id`
- 当前 refinement 明确禁止：
  - 为 Trading IM 新建 avatar truth
  - 回写 enterprise listing
  - 回写 user profile
  - 将 personal avatar 提升为 enterprise truth

## 4. Readability Rule

- 若 personal avatar 被用作 fallback display source：
  - Server 必须输出可读 access URL projection
  - 不得把私有 OSS object URL 直接原样泄露给 app-facing surface
- 若 enterprise logo 与 personal avatar 均缺失：
  - Flutter 允许继续显示首字母占位

## 5. Unchanged Boundaries

- 本 refinement 不改变：
  - `participant-card minimum` 的读权限门槛
  - `bid submission snapshot` 的只读性质
  - `message interactions` 的会话列表边界
  - `formal-info` full-page takeover No-Go

## 6. Formal Conclusion

- 本 refinement 作为当前 bounded trading exception 的同链视觉身份补充正式冻结。
- 当前状态：
  - `Go for contract refinement authoring`
  - `Go for bounded backend/frontend refinement`
  - `No new route family`
