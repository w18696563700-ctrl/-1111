---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the bounded Server-side visual identity projection rule for trading
  interaction surfaces, requiring readable avatar projection and enterprise-logo
  first fallback logic without creating a second avatar truth owner.
layer: L3 Backend
freeze_date_local: 2026-04-24
inputs_canonical:
  - docs/00_ssot/trading_im_visual_identity_projection_refinement_addendum.md
  - docs/01_contracts/trading_im_visual_identity_projection_contract_refinement_addendum.md
  - apps/server/src/modules/message_interaction/message-interaction.query.service.ts
  - apps/server/src/modules/my_bid/my-bid.query.service.ts
  - apps/server/src/modules/trading_im/trading-im-participant-card.query.service.ts
---

# 《Trading IM visual identity projection backend refinement》

## 1. Scope

- 本 refinement 只覆盖 Server 当前三条已批准读面：
  - `message interactions`
  - `bid submission snapshot`
  - `participant-card minimum`

## 2. Readable Avatar Projection

- 若读面消费 `users.avatar_url`：
  - Server 必须先将其转换为 readable access URL projection
  - 不得直接返回私有 OSS object URL

## 3. participant-card Minimum Fallback Rule

- `participant-card minimum` 必须按以下优先级输出头像显示位：
  1. published / visible enterprise listing logo
  2. admitted counterpart user readable avatar projection
  3. `null`
- 该 fallback 只影响 display carrier，不改变任何底层真相归属。

## 4. Snapshot / Interaction Avatar Rule

- `bid submission snapshot.bidder.avatarUrl` 允许输出 submitted bidder actor 的 readable avatar projection。
- `message interactions.counterpart.avatarUrl` 允许输出 counterpart actor 的 readable avatar projection。

## 5. Formal Conclusion

- 当前 refinement 只允许 bounded query projection 调整。
- 当前明确禁止：
  - new avatar table
  - avatar backfill job
  - profile truth rewrite
  - enterprise listing rewrite
