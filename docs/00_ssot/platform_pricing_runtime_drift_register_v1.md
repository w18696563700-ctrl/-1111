---
owner: Codex 总控
status: frozen
purpose: >
  Register the Day 3 runtime drift inventory for the current platform pricing
  rebaseline, splitting the legacy P0-Pay runtime into must-change blockers,
  later cleanup items, and retained non-runtime surfaces before any
  implementation dispatch is allowed.
layer: L0 SSOT
freeze_date_local: 2026-04-29
version: V1
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/03_bff/platform_pricing_bff_surface_master_v1.md
  - docs/04_frontend/platform_pricing_frontend_consumption_master_v1.md
  - apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart
  - apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart
  - apps/mobile/lib/features/exhibition/data/p0_pay_read_only_summary.dart
  - apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_support.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart
  - apps/bff/src/routes/exhibition_p0_pay/app-exhibition-p0-pay.controller.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.service.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay-error.service.ts
  - apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model.ts
  - apps/bff/src/routes/message_interaction/message-interaction.read-model.ts
  - apps/server/src/modules/p0_pay/p0-pay.controller.ts
  - apps/server/src/modules/p0_pay/p0-pay.state.ts
  - apps/server/src/modules/p0_pay/p0-pay.types.ts
  - apps/server/src/modules/p0_pay/p0-pay.errors.ts
  - apps/server/src/modules/p0_pay/p0-pay-service-fee.factory.ts
  - apps/server/src/modules/p0_pay/p0-pay-callback.service.ts
  - apps/server/src/modules/project/project-exit-governance.service.ts
  - apps/server/src/modules/message_interaction/counterpart-conversation.bid-thread-source.ts
  - apps/server/src/modules/payment_billing/payment-billing.query.service.ts
---

# 《平台收费规则 Runtime Drift Register V1》

## 0. 总结论

当前三端 runtime drift 的结论很明确：

1. `Server` 是最关键 blocker
2. `BFF` 紧随其后
3. `Flutter` 目前旧路径、旧文案、旧 summary 绑定最明显
4. `payment_billing` 仍然只是只读状态壳，不属于当前收费 runtime owner

当前更稳的方案：

- 先切 `must-change` blocker，再处理 `later cleanup`

当前更省成本的方案：

- 不重炸整个 exhibition，只切收费相关文件簇

当前阶段最适合的方案：

- 用 drift register 直接给 implementation dispatch bundle 提供分片依据

风险更大的方案：

- 不区分 blocker 与 cleanup，直接让多个实现代理同时在三端大面积改名和改路径

## 1. 当前最小闭环

当前 drift register 只覆盖当前收费主线最短链路：

1. `200` publish gate
2. `4000` bid gate
3. `deal confirmation`
4. `message interaction pricing carry`

## 2. 需要保留但暂不开通

当前 register 明确保留但暂不开通：

1. `payment_billing`
2. `credit_constraints`
3. 通用 finance / settlement / invoice 家族

## 3. 后续扩展位

后续扩展位正式保留：

1. pricing summary 独立展示页
2. billing reference 与 pricing runtime 的统一 handoff
3. 结构化 pricing message card

## 4. Must-change Blockers

| ID | Layer | File / Module | 当前 drift | 处理级别 | 下一步要求 |
|---|---|---|---|---|---|
| `S1` | Server | `apps/server/src/modules/p0_pay/p0-pay.state.ts` | 规则版本仍是 `exhibition_trade_task_payment_mainline_p0_pay_v1_3`，默认费率仍是 `0.03`，`200` 仍是旧 inquiry deposit 常量 | `veto blocker` | 必须先改状态常量与规则快照入口 |
| `S2` | Server | `apps/server/src/modules/p0_pay/p0-pay.controller.ts` | 整套 server path 仍挂在 `server/exhibition/trade-tasks/**` | `veto blocker` | 必须先切到新 pricing route family，或至少建立 canonical compatibility layer |
| `S3` | Server | `apps/server/src/modules/p0_pay/p0-pay.types.ts` | `businessType / status / object vocabulary` 仍是 `inquiry_deposit / authorized / confirmed` 旧词表 | `veto blocker` | 必须先改当前词表或建立强制 normalization layer |
| `S4` | Server | `apps/server/src/modules/p0_pay/p0-pay.errors.ts` | 仍只暴露总括式 `P0_PAY_*` | `veto blocker` | 必须先切到对象级错误族映射 |
| `S5` | Server | `apps/server/src/modules/p0_pay/p0-pay-service-fee.factory.ts` | `4000` 仍被 `quotedAmount * feeRate = estimatedFeeAmount` 逻辑绑死 | `veto blocker` | 必须先切断 `estimatedFeeAmount` authority |
| `S6` | Server | `apps/server/src/modules/p0_pay/p0-pay-callback.service.ts` | 仍保留“询价诚意金成功后自动 publish inquiry task”副作用 | `veto blocker` | 必须先删除或替换为新 publish gate 结果流 |
| `S7` | Server | `apps/server/src/modules/project/project-exit-governance.service.ts` | 仍要求项目退出先走旧 `P0-Pay release chain` | `veto blocker` | 必须先改成新 `200 / 4000` 退出语义 |
| `S8` | Server | `apps/server/src/modules/message_interaction/counterpart-conversation.bid-thread-source.ts` | 消息楼仍输出 `p0PaySummary`、`trade_task` routeTarget、`estimatedFeeAmount`、`inquiryDeposit` | `veto blocker` | 必须先换成新 pricing summary carry |
| `B1` | BFF | `apps/bff/src/routes/exhibition_p0_pay/app-exhibition-p0-pay.controller.ts` | app-facing controller 根路径仍是 `api/app/exhibition/trade-tasks` | `veto blocker` | 必须先切新 route family 或建立唯一 canonical alias 策略 |
| `B2` | BFF | `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.service.ts` | 上游 server path 与 operation family 仍是 `trade-task / inquiry-deposit / fixed-price-bids / p0-pay-summary` | `veto blocker` | 必须先改 service path 和 operation 命名 |
| `B3` | BFF | `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay-error.service.ts` | fallback code 与 message 仍绑旧 `TRADE_TASK_* / INQUIRY_DEPOSIT_* / P0_PAY_SUMMARY_*` | `veto blocker` | 必须先切到新错误族 |
| `B3a` | BFF | `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay-payload.service.ts` | payload 输入仍要求 `TASK_TYPES=fixed_price_bid/inquiry_quote`、`expectedQuotedAmount / expectedFeeRate / expectedAuthorizationAmount` | `veto blocker` | 必须先切 payload 语义到 `200 publish gate + 4000 fixed quota` |
| `B3b` | BFF | `apps/bff/src/routes/bid_participation_request/bid-participation-request.read-model.ts` | thread / action handoff 仍只认 `bid_submit.open`，没有 `pricingGateRequired / pricingGateType / detailRouteTarget` | `veto blocker` | 必须先补 pricing gate handoff 字段 |
| `B3c` | BFF | `apps/bff/src/routes/bid/bid.read-model.ts` | bid submit 成功 handoff 仍绑 `bid_thread.open + bid_submission_snapshot.open` | `veto blocker` | 必须先改 submit success handoff 语义 |
| `B3d` | BFF | `apps/bff/src/routes/project/project-lifecycle.service.ts` | withdraw-published 错误仍显式依赖旧 authorization release chain | `veto blocker` | 必须先切到新退出规则错误语义 |
| `B4` | BFF | `apps/bff/src/routes/exhibition_p0_pay/exhibition-p0-pay.read-model.ts` | read model 仍直接回传 `feeRate / estimatedFeeAmount / inquiryDeposit` | `veto blocker` | 必须先改成新 summary/object shape |
| `B5` | BFF | `apps/bff/src/routes/message_interaction/message-interaction.read-model.ts` | 仍读 `p0PaySummary`，并把它当 read-only message carry | `veto blocker` | 必须先换成 `pricingSummary` 或同等新 carrier |
| `M1` | Mobile | `apps/mobile/lib/features/exhibition/data/services/exhibition_canonical_paths.dart` | canonical path 仍全套 `trade-tasks / inquiry-deposit / service-fee-authorizations / p0-pay-summary` | `veto blocker` | 必须先切新 canonical paths |
| `M2` | Mobile | `apps/mobile/lib/features/exhibition/data/commands/p0_pay_commands.dart` | command model 仍是 `P0PayInquiryDepositOrderCommand / P0PayServiceFeeAuthorizationCommand / expectedQuotedAmount / expectedFeeRate` | `veto blocker` | 必须先切 command object 语义 |
| `M3` | Mobile | `apps/mobile/lib/features/exhibition/data/services/p0_pay_consumer_service.dart` | consumer service 仍全套 `createTradeTask / inquiryDeposit / fixedPriceBid / serviceFeeAuthorization / p0PaySummary` | `veto blocker` | 必须先切 consumer API family |
| `M4` | Mobile | `apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart` | create 页仍是“先建 trade task，再在 inquiry 分支拉起发单诚意金”，并直接露出 `P0-Pay 交易任务` 文案 | `veto blocker` | 必须先切 `200 publish gate` 页面主线 |
| `M5` | Mobile | `apps/mobile/lib/features/exhibition/data/p0_pay_read_only_summary.dart` | 仍直接展示 `预计服务费 / 发单诚意金 / 合同确认 / p0PayStatusTextKey` | `veto blocker` | 必须先改 summary parser 与文案 |
| `M6` | Mobile | `apps/mobile/lib/features/exhibition/presentation/presentation_support/p0_pay_bid_authorization_support.dart` | 仍直接展示 `费率 / 会员等级 / 预计服务费 / 已预授权` 旧心智，并本地使用 `3.0%` 估算 | `veto blocker` | 必须先切为 `4000 quota + deal-only final fee` 心智 |
| `M7` | Mobile | `apps/mobile/lib/features/exhibition/data/services/exhibition_contract_mapper.dart` | 稳定错误码白名单仍吃旧 `TRADE_TASK_* / INQUIRY_DEPOSIT_* / P0_PAY_SUMMARY_*` | `veto blocker` | 必须先切合同错误码映射 |

## 5. Can-change-later Items

| ID | Layer | File / Module | 当前 drift | 处理级别 | 下一步要求 |
|---|---|---|---|---|---|
| `M8` | Mobile | `apps/mobile/lib/features/exhibition/presentation/widgets/project_create_round_a_widgets.dart` | 仍保留 `selectedP0PayTaskType` 与 `inquiry_quote / fixed_price_bid` 选择心智 | `later` | 在 publish / pricing mainline 切完后再改创建页 copy 与意图命名 |
| `M9` | Mobile | `apps/mobile/lib/features/exhibition/data/models/p0_pay_payment_polling.dart` | 轮询枚举仍是 `inquiryDeposit / serviceFeeAuthorization / deducted / held` | `later` | 当前 API family 稳定后再统一枚举名 |
| `B6` | BFF | `apps/bff/src/routes/routes.module.ts` | 模块名仍是 `ExhibitionP0PayModule` | `later` | 代码切稳定后再决定模块重命名 |
| `S9` | Server | `apps/server/src/modules/p0_pay/p0-pay.presenter.ts` | 仍向外提供 `feeRateLabel / feeRateSource / estimatedFeeAmount / inquiryDeposit` 旧读取口径 | `later` | 主 route / object 改完后再统一 presenter 输出 |
| `S10` | Server | `apps/server/src/modules/p0_pay/p0-pay-idempotency-record.service.ts` | 仍按 `InquiryDeposit / PlatformServiceFeeAuthorization` 旧 resource type 读写 | `later` | 主 objectType 方案定稿后再统一 resource type 命名 |
| `S10a` | Server | `apps/server/src/modules/bid_participation_request/**` | `approved` 之后仍直接导向旧 `bid_submit` continuation，没有 `4000` gate | `later` | 当前 path/对象切完后再统一 access/query/support handoff |
| `S10b` | Server | `apps/server/src/modules/bid/bid-write.service.ts` | bid submit 当前只校验准入审批，不校验新收费 gate | `later` | 当前 authorization truth 切完后再补 gate enforcement |

## 6. Retained Non-runtime Surfaces

| ID | Layer | File / Module | 当前状态 | 处理级别 | 结论 |
|---|---|---|---|---|---|
| `R1` | Mobile | `apps/mobile/lib/features/profile/**payment_billing**` | 只读状态壳 | `retain` | 当前不动，不纳入收费 runtime 改造 |
| `R2` | BFF | `apps/bff/src/routes/profile/**payment-billing-status**` | 只读状态壳 | `retain` | 当前不动，不纳入收费 runtime 改造 |
| `R3` | Server | `apps/server/src/modules/payment_billing/**` | 只读 query family | `retain` | 当前不动，不纳入收费 runtime 改造 |
| `R4` | Server | `apps/server/src/modules/credit_constraints/**` | dependency / posture family | `retain` | 当前不动，不纳入收费 runtime 改造 |

## 7. 推荐实现分片顺序

如果 Day 4 门禁允许进入 implementation dispatch bundle authoring，推荐分片顺序固定为：

1. `Package A - Server pricing domain cutover`
2. `Package B - BFF pricing route and error cutover`
3. `Package C - Flutter canonical path and consumer cutover`
4. `Package D - Message interaction pricing carry cutover`
5. `Package E - Verification and cloud validation pack`

当前严禁的分片方式：

1. 先改 Flutter 文案
2. 先改 BFF route 而不改 Server canonical truth
3. 把 message carry 当成独立主线先改

## 8. Day 3 结论

当前结论：

1. drift 已经足够细，可以进入 implementation dispatch bundle authoring
2. 但 blocker 仍然很多，不能直接进入 code implementation

当前推荐结论：

- `Day 4 可以争取 Go for implementation dispatch bundle authoring only`
- `Day 4 不应放行 direct implementation`
