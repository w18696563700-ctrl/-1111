---
owner: Codex 总控
status: draft
purpose: >
  Freeze the non-effective Server implementation dispatch draft for the current
  platform pricing rebaseline.
layer: L0 SSOT
freeze_date_local: 2026-04-29
based_on:
  - docs/00_ssot/platform_pricing_bounded_implementation_dispatch_draft_addendum.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/02_backend/platform_pricing_persistence_migration_truth_addendum_v1.md
  - docs/02_backend/platform_pricing_audit_truth_addendum_v1.md
---

# 《平台收费规则 Server implementation dispatch draft》

```text
你是后端 Agent（Server），本轮不是重开 payment 平台，也不是重写整个 exhibition 交易。你只允许在当前收费重基线的有界范围内，按既定顺序切 `200 publish gate / 4000 bid gate / deal confirmation / message carry`。

【唯一目标】
1. 保留 `p0_pay` 作为首轮物理壳，不做一把梭重命名
2. 先切断旧 `trade-task / inquiry-deposit / 3% / estimatedFeeAmount` authority
3. 再把新收费真相挂到：
   - `project publish`
   - `bid participation -> bid/submit`
   - `deal confirmation / charge / exit governance`
   - bounded `message interaction pricing carry`

【强制阅读】
- docs/00_ssot/platform_pricing_implementation_unlock_addendum.md
- docs/00_ssot/platform_pricing_bounded_implementation_dispatch_draft_addendum.md
- docs/02_backend/platform_pricing_backend_truth_master_v1.md
- docs/02_backend/platform_pricing_persistence_migration_truth_addendum_v1.md
- docs/02_backend/platform_pricing_audit_truth_addendum_v1.md
- docs/00_ssot/platform_pricing_runtime_drift_register_v1.md

【执行顺序】
SP-1. Server Pricing Kernel & Persistence Normalization
- 允许触达：
  - apps/server/src/modules/p0_pay/p0-pay.state.ts
  - apps/server/src/modules/p0_pay/p0-pay.types.ts
  - apps/server/src/modules/p0_pay/p0-pay.errors.ts
  - apps/server/src/modules/p0_pay/p0-pay.commands.ts
  - apps/server/src/modules/p0_pay/p0-pay-command.parser.ts
  - apps/server/src/modules/p0_pay/p0-pay-audit.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-idempotency-record.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-callback.service.ts
  - apps/server/src/modules/p0_pay/entities/**
  - apps/server/src/modules/p0_pay/p0-pay.module.ts
  - apps/server/src/core/migrations/migrations.ts
- 目标：
  - 切新词表、业务类型、错误族、审计动作、幂等边界
  - callback 不再自动“付完 200 就发布项目”
  - migration 只允许 additive

SP-2. Project Publish Gate / 200 Corridor
- 允许触达：
  - apps/server/src/modules/project/project-write.service.ts
  - 必要时 apps/server/src/modules/project/project.module.ts
  - apps/server/src/modules/p0_pay/p0-pay-inquiry-deposit.service.ts
  - 必要时 project publish audit supporting touch
- 目标：
  - `publishProject` fail-close 于 `200` gate
  - 不得隐式创建收费订单，不得隐式代扣 `200`

SP-3. 4000 Gate / Bid Corridor
- 允许触达：
  - apps/server/src/modules/p0_pay/p0-pay-service-fee-authorization.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-service-fee.factory.ts
  - 必要时 apps/server/src/modules/p0_pay/p0-pay.module.ts
  - apps/server/src/modules/bid/bid-write.service.ts
  - 必要时 apps/server/src/modules/bid/bid.module.ts
  - apps/server/src/modules/bid_participation_request/bid-participation-request-access.service.ts
- 目标：
  - `4000` 改为固定 quota 真相
  - `bid/submit` 改成 `approved + frozen` 双门禁

SP-4. Deal / Charge / Exit Governance
- 允许触达：
  - apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts 或同职责文件
  - apps/server/src/modules/p0_pay/p0-pay-state-action.service.ts
  - apps/server/src/modules/project/project-exit-governance.service.ts
  - 必要时 supporting touch
- 目标：
  - 只有 `confirmed_deal` 才能创建 charge
  - 成交后进入“剩余额度释放 + 200 退款”语义
  - 退出治理不再引用旧 `P0-Pay release chain`

SP-5. Server Surface / Message Carry Cutover
- 允许触达：
  - apps/server/src/modules/p0_pay/p0-pay.controller.ts
  - apps/server/src/modules/p0_pay/p0-pay.presenter.ts
  - apps/server/src/modules/bid_participation_request/bid-participation-request.support.ts
  - apps/server/src/modules/bid_participation_request/bid-participation-request.presenter.ts
  - 必要时 query.service 最小 supporting touch
  - apps/server/src/modules/message_interaction/counterpart-conversation.bid-thread-source.ts
  - bounded message_interaction carry files
- 目标：
  - Server 不再输出 `p0PaySummary / trade_task / estimatedFeeAmount`
  - message carry 只带新 `pricing summary / nextAction / statusTextKey / reasonCode`

【禁止事项】
- 不得触达 apps/server/src/modules/payment_billing/**
- 不得触达 apps/server/src/modules/credit_constraints/**
- 不得扩到 wallet / settlement / invoice / finance-admin
- 不得继续往 p0-pay-trade-task.service.ts 里塞新真相
- 不得做 physical rename / drop legacy column / full backfill
- 不得先改 message carry 再倒逼 pricing kernel

【完成标准】
- 每个 package 各自有 build / targeted tests / receipt
- 旧 `trade-task / inquiry-deposit / 3%` 不再作为当前 authority
- 当前 draft 仍不等于已获准开工；未通过后续 dispatch-send gate 前，不得执行
```
