---
owner: Codex 总控
status: active
purpose: >
  Freeze and issue the active SP-1 Server implementation dispatch for the
  current platform pricing rebaseline, limited to pricing kernel and additive
  persistence normalization before any publish, bid, deal, BFF, Flutter, cloud,
  or release work may proceed.
layer: L0 SSOT
freeze_date_local: 2026-04-29
version: V1
based_on:
  - docs/00_ssot/platform_pricing_implementation_dispatch_send_stage_gate_checklist_addendum.md
  - docs/00_ssot/platform_pricing_server_implementation_dispatch_draft_addendum.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/02_backend/platform_pricing_persistence_migration_truth_addendum_v1.md
  - docs/02_backend/platform_pricing_audit_truth_addendum_v1.md
---

# 《平台收费规则 SP-1 Server implementation dispatch》

```text
你是后端 Agent（Server）。本轮只执行 SP-1：Server Pricing Kernel & Persistence Normalization。

【唯一目标】
1. 切掉旧收费 runtime authority 的内核入口：
   - trade-task
   - inquiry-deposit
   - 3%
   - estimatedFeeAmount
   - legacy P0-Pay action vocabulary
2. 建立新收费主线的 Server 内核基础：
   - ProjectAuthenticitySincerityOrder
   - BidServiceFeeAuthorization
   - DealConfirmation
   - PlatformServiceFeeCharge
   - pricing audit actions
   - pricing idempotency resource boundary
3. 只做 additive persistence / migration normalization。
4. 确保 callback 不再自动“付完 200 就发布项目”。

【强制阅读】
- docs/00_ssot/platform_pricing_rules_master_v1.md
- docs/00_ssot/platform_pricing_implementation_dispatch_send_stage_gate_checklist_addendum.md
- docs/02_backend/platform_pricing_backend_truth_master_v1.md
- docs/02_backend/platform_pricing_persistence_migration_truth_addendum_v1.md
- docs/02_backend/platform_pricing_audit_truth_addendum_v1.md
- docs/00_ssot/platform_pricing_runtime_drift_register_v1.md

【只允许处理的范围】
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
- tests directly covering the files above

【禁止事项】
- 不得触达 apps/server/src/modules/project/project-write.service.ts
- 不得触达 apps/server/src/modules/bid/**
- 不得触达 apps/server/src/modules/bid_participation_request/**
- 不得触达 apps/server/src/modules/message_interaction/**
- 不得触达 apps/server/src/modules/payment_billing/**
- 不得触达 apps/server/src/modules/credit_constraints/**
- 不得触达 apps/bff/**
- 不得触达 apps/mobile/**
- 不得做 physical rename
- 不得 drop legacy column
- 不得 full backfill
- 不得发起 cloud write / deploy / restart
- 不得把 SP-1 扩成 SP-2 publish gate 或 SP-3 bid gate

【完成标准】
1. 新写入不再以旧 `inquiry_deposit / authorized / confirmed / TradeTaskCreated` 词表作为当前 authority。
2. 新错误族能够承接：
   - PROJECT_AUTHENTICITY_SINCERITY_*
   - BID_SERVICE_FEE_AUTHORIZATION_*
   - DEAL_CONFIRMATION_*
   - PRICING_RULE_VERSION_MISMATCH
3. 新 audit action 与 docs/02_backend/platform_pricing_audit_truth_addendum_v1.md 对齐。
4. 新 persistence / migration 只做 additive change。
5. callback 成功只更新对应 pricing object 状态，不隐式 publish project。
6. local build 或可用的 targeted tests 通过。

【回执要求】
Backend Agent 完成后必须提交 SP-1 execution receipt，至少包含：
1. 新增文件清单
2. 修改文件清单
3. migration / entity / enum / error / audit / idempotency 改动说明
4. 明确说明未触达 SP-2 / SP-3 / SP-4 / SP-5 / BFF / Flutter / cloud
5. 执行过的 build / test 命令和结果
6. 未完成项与阻塞项

【当前派工结论】
SP-1 正式发出。
SP-2 及后续包仍需等待 SP-1 execution receipt 后另行重提 send gate。
```
