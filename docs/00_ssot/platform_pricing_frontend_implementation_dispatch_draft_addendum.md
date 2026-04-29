---
owner: Codex 总控
status: draft
purpose: >
  Freeze the non-effective Flutter implementation dispatch draft for the
  current platform pricing rebaseline.
layer: L0 SSOT
freeze_date_local: 2026-04-29
based_on:
  - docs/00_ssot/platform_pricing_bounded_implementation_dispatch_draft_addendum.md
  - docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
---

# 《平台收费规则 Flutter implementation dispatch draft》

```text
你是前端 Agent（仅本地 Flutter）。本轮只做当前收费重基线的消费面切换，不重起 payment center，不接 Server 直连，不把旧 p0_pay 页面壳偷渡成现行真相。

【唯一目标】
1. 先切 Flutter pricing 消费底座
2. 再切 `200 publish gate`
3. 再切 `4000 bid gate`
4. 最后替换项目详情里的旧只读收费摘要

【强制阅读】
- docs/00_ssot/platform_pricing_implementation_unlock_addendum.md
- docs/00_ssot/platform_pricing_bounded_implementation_dispatch_draft_addendum.md
- docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md
- docs/00_ssot/platform_pricing_runtime_drift_register_v1.md

【执行顺序】
FP1. 收费消费底座切换包
- 允许触达：
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/data/commands/p0_pay_commands.dart
  - apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart
  - apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/exhibition_payload_support.dart
- 目标：
  - Flutter 不再把 `/api/app/exhibition/trade-tasks/**` 当现行 authority
  - 共享错误、轮询、文案底座切到新对象语义

FP2. 发布 200 Gate 承接包
- 允许触达：
  - apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart
- 目标：
  - `project create/save/submit -> pricing-summary -> 200 -> publish`
  - 文案固定为 `项目真实性诚意金`
  - 发布成功只能发生在 `200` 已完成且 `publish` 成功之后

FP3. 4000 Gate 与竞标提交承接包
- 允许触达：
  - apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_support.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_actions.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_name_access_thread_page.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_actions_support.dart
- 目标：
  - `approved` 不再直跳 `bid_submit.open`
  - `pricingGateRequired=true` 时先去 `4000` gate
  - 只有 `authorizationStatus=frozen` 才开放最终提交

FP4. 只读收费摘要承接包
- 允许触达：
  - apps/mobile/lib/features/exhibition/data/p0_pay_read_only_summary.dart
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
- 目标：
  - 项目详情只读卡从旧 `p0PaySummary` 切成新 `pricing summary`
  - 旧 summary 只能兼容降级，不能继续反向成为现行真相

【禁止事项】
- 不得触达 apps/bff/** 或 apps/server/**
- 不得新开 `/exhibition/trade-task/*`
- 不得新开 `/exhibition/payment-center/*`、`/exhibition/wallet/*`
- 不得触达 `apps/mobile/lib/features/profile/**payment_billing**`
- 不得先改 message/workbench/payment-center 再回来补 pricing base

【完成标准】
- analyze + widget/consumer tests 能覆盖每个 package
- Flutter 不再本地使用 `3.0%` 估算或 `expectedQuotedAmount / expectedFeeRate / expectedAuthorizationAmount`
- 当前 draft 未通过后续 dispatch-send gate 前，不得执行
```
