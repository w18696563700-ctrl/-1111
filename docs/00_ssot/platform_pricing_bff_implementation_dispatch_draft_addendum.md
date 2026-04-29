---
owner: Codex 总控
status: draft
purpose: >
  Freeze the non-effective BFF implementation dispatch draft for the current
  platform pricing rebaseline.
layer: L0 SSOT
freeze_date_local: 2026-04-29
based_on:
  - docs/00_ssot/platform_pricing_bounded_implementation_dispatch_draft_addendum.md
  - docs/03_bff/platform_pricing_bff_surface_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
---

# 《平台收费规则 BFF implementation dispatch draft》

```text
你是 BFF Agent。本轮只闭合当前收费重基线的 app-facing transport，不重开 payment center，也不发明第二收费状态机。

【唯一目标】
1. 切 `pricing-summary / authenticity-sincerity / bid-service-fee-authorizations / deal-confirmations`
2. 对齐 `project publish` 与 `bid/submit` 的收费 gate handoff
3. 最后再切 bounded `message interaction pricing carry`

【强制阅读】
- docs/00_ssot/platform_pricing_implementation_unlock_addendum.md
- docs/00_ssot/platform_pricing_bounded_implementation_dispatch_draft_addendum.md
- docs/03_bff/platform_pricing_bff_surface_master_v1.md
- docs/00_ssot/platform_pricing_runtime_drift_register_v1.md

【执行顺序】
P1. pricing route family core
- 允许触达：
  - apps/bff/src/routes/exhibition_p0_pay/app-exhibition-p0-pay.controller.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.service.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay-payload.service.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay-error.service.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.module.ts
- 目标：
  - 旧 `api/app/exhibition/trade-tasks` 不再是当前 authority
  - 输出 object shape 对齐新 `200 / 4000 / deal confirmation`

P2. publish / withdraw-published gate alignment
- 允许触达：
  - apps/bff/src/routes/project/project.service.ts
  - apps/bff/src/routes/project/project-lifecycle.service.ts
- 目标：
  - publish fail-close 于 `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED`
  - withdraw-published 错误语义不再引用旧 release chain

P3. bid participation + bid submit handoff alignment
- 允许触达：
  - apps/bff/src/routes/bid_participation_request/bid-participation-request.read-model.ts
  - 必要时 service 最小 supporting touch
  - apps/bff/src/routes/bid/bid.read-model.ts
  - 必要时 apps/bff/src/routes/bid/bid.service.ts
- 目标：
  - `approved` 不再自动直达 `bid_submit.open`
  - 缺 `frozen` 时必须先转 `4000` gate

P4. message interaction pricing carry
- 允许触达：
  - apps/bff/src/routes/message_interaction/message-interaction.read-model.ts
  - 必要时 service 最小 supporting touch
- 目标：
  - 旧 `p0PaySummary` 退场
  - 新 carry 只允许 read-only `pricingSummary / nextAction / reasonCode`

【禁止事项】
- 不得触达 apps/bff/src/routes/routes.module.ts 做 cosmetic rename
- 不得 invent bare `payment / wallet / billing / settlement / invoice` routes
- 不得把 `trade task detail / inquiry quotation / inquiry result / p0-pay-actions`
  继续包装成当前收费主线
- 不得本地计算 fee / membership discount / authorization quota

【完成标准】
- local BFF route 不再把旧 `trade-task` family 当现行 authority
- controlled error family 对齐新 contracts
- 当前 draft 未通过后续 dispatch-send gate 前，不得执行
```
