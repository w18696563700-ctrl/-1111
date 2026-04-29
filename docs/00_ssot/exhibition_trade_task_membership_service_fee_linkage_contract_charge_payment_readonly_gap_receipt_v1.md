---
title: exhibition_trade_task_membership_service_fee_linkage_contract_charge_payment_readonly_gap_receipt_v1
owner: Codex 总控
status: frozen
layer: L0 Readonly Gap Receipt
updated_at: 2026-04-29
purpose: Record the read-only gate check for authorize-init, payment callback, contract final charge, and the related My Membership entry sync gap after membership-tier service-fee authorization snapshots passed.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_contract_charge_payment_gate_package_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_final_verification_receipt_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day10_formal_enablement_gate_receipt_v1.md
  - apps/server/src/modules/p0_pay/p0-pay-service-fee-authorization.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-service-fee.factory.ts
  - apps/server/src/modules/p0_pay/p0-pay-callback.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts
  - apps/server/src/modules/membership/membership.catalog.ts
  - apps/mobile/lib/features/profile/presentation/profile_membership_pages.dart
---

# P0-Pay 会员费率合同扣费与支付门禁只读核查回执 V1

## 0. 总裁决

- `authorize-init` 是否复用 locked authorization snapshot：`Pass by code read`
- `payment callback` 是否覆盖 fee snapshot：`Pass by code read / Evidence Missing for behavior test`
- `contract final charge` 是否按 locked feeRate 计算并保存 snapshot：`Pass by code read and existing test`
- 是否允许直接放开支付初始化：`No-Go`
- 是否允许直接放开 payment callback runtime：`No-Go`
- 是否允许直接放开合同确认最终扣费 runtime：`No-Go`
- 是否需要同步“我的会员”入口：`Yes, bounded sync needed`
- 下一轮唯一动作：先补 Server 门禁测试，覆盖 callback 不改写 fee snapshot，以及 `standard / professional / ka / flagship` 四档最终扣费快照行为。

核心原因：

1. 代码路径没有发现重新计算会员等级或覆盖 locked fee snapshot 的行为。
2. 正式门禁要求不能只靠静态阅读放开支付和扣费。
3. 当前测试缺少 callback 不改写快照的行为证据。
4. `我的会员` 入口仍停留在 V2.0 读模型口径，只覆盖 `free_certified / standard / professional`，没有对齐 P0-Pay 已验证的 `ka / flagship` 费率档。

## 1. P0-Pay 只读核查

| 项 | 当前实现 | 结论 | 证据 |
|---|---|---|---|
| authorize-init | 读取既有 authorization，再用 `authorization.estimatedFeeAmount` 创建 payment order | Pass | `p0-pay-service-fee-authorization.service.ts:99`，`p0-pay-service-fee.factory.ts:95` |
| authorize-init feeRate | 未调用 `P0PayServiceFeeRatePolicy.buildRequirement()` | Pass | `buildPaymentOrder()` 只读 authorization |
| callback success | 更新 order status / channelOrderId / transaction / business status | Pass by code read | `p0-pay-callback.service.ts:109` |
| callback fee snapshot | 未写 `feeRate / feeRateSource / membershipTierSnapshot / ruleVersion / snapshotHash` | Pass by code read | `p0-pay-callback.service.ts:192`，`:247` |
| contract final charge | `lockedFeeRate = ownership.authorization.feeRate` | Pass | `p0-pay-contract-confirmation.service.ts:166` |
| final amount | `calculatePlatformServiceFeeAmount(finalConfirmedAmount, lockedFeeRate)` | Pass | `p0-pay-contract-confirmation.service.ts:167` |
| charge snapshot | 从 authorization 拷贝 `feeRateSource / membershipTierSnapshot / feeRateRuleVersion / feeRateSnapshotHash` | Pass | `p0-pay-contract-confirmation.service.ts:176-184` |
| payment order for charge | 当前为 `server_capture` / `succeeded` 行为 | Risk | 需要受控 runtime 证明不误触真实外部扣款 |

## 2. 测试证据

| 测试 | 当前结果 | 结论 |
|---|---|---|
| `node --test apps/server/test/p0-pay-calculator-idempotency.test.cjs apps/server/test/p0-pay-server-mainline.test.cjs` | 12/12 passed | Pass |
| contract charge uses locked snapshot | 已有测试 | Pass |
| authorization factory writes snapshot | 已有测试 | Pass |
| callback 不覆盖 snapshot | 缺专门行为测试 | Blocker |
| final charge 四档 tier 覆盖 | 缺 `ka / flagship` 行为断言 | Blocker |

## 3. 会员入口扫描

| 层 | 当前状态 | 结论 |
|---|---|---|
| Docs | V2.0 paid membership bounded implementation 已成立；购买、续费、账单仍不在当前包内 | Pass |
| Server | `/server/profile/membership/current/explanation/quota/upgrade-guide` 已存在 | Pass |
| BFF | `/api/app/profile/membership/*` 只读转发并整形 | Pass |
| Flutter | “我的会员”当前页、权益说明、配额说明、升级引导页已接入 | Pass |
| Runtime route | 未带登录态访问返回受控 `401 AUTH_SESSION_INVALID`，不是 404 | Pass for route presence |
| Tier catalog | 只定义 `free_certified / standard / professional` | Sync Gap |
| Flutter tier display | `standard / professional` 有中文映射，`ka / flagship` 会落 raw code | Sync Gap |
| Purchase / renew / order / pay / billing | 当前不承接 | Correct No-Go |

## 4. 会员入口同步判断

需要同步，但必须小范围：

1. 将 `ka / flagship` 作为 P0-Pay 已验证费率档的只读说明同步到 membership catalog。
2. Flutter 展示函数补中文显示，避免 `ka / flagship` 裸露 code。
3. “升级引导页”仍不得变成购买页，不得新增下单、支付、续费入口。
4. “我的会员”页可以说明费率权益，但必须保留“交易实际费率以 P0-Pay 授权快照为准”口径。

## 5. 当前最小闭环

- P0-Pay authorization snapshot 已支持会员分层。
- Payment init / callback / final charge 实现路径看起来复用 locked snapshot。
- “我的会员”入口具备读模型展示基础。

## 6. 需要保留但暂不开通

- 支付初始化真实 runtime。
- payment callback runtime。
- 合同确认最终扣费 runtime。
- 会员购买、续费、下单、支付和账单闭环。

## 7. 后续扩展位

- `ka / flagship` 会员说明。
- 会员购买直达。
- 会员续费。
- 会员订单和发票。
- 费率封顶、活动费率、后台配置费率。

## 8. 风险分级

### P0 Blocker

1. 缺 callback 不覆盖 fee snapshot 的行为测试。
2. 缺 `standard / professional / ka / flagship` 四档 final charge 行为测试。
3. 真实 payment callback / final charge runtime 尚未验证，不得放开。

### P1 Risk

1. charge payment order 当前是 `server_capture / succeeded`，需要确认这只是受控 capture 语义，不误触真实外部扣款。
2. “我的会员”入口未同步 `ka / flagship`，用户侧说明和 P0-Pay 费率规则存在口径差。
3. OpenAPI / generated types 仍需在正式发布前同步。

### P2 Improvement

1. payment order / transaction 可通过 business id 回溯 snapshot，但未冗余保存 fee snapshot。
2. 会员页日期展示仍是 ISO 字符串，后续可改为中文日期格式。
3. 会员页信息密度偏高，后续可做分组折叠。

## 9. 四类判断

| 判断 | 结论 | 原因 |
|---|---|---|
| 哪个更稳 | 先补测试证据，再做 runtime | 支付和扣费不能靠代码阅读直接放行 |
| 哪个更省成本 | 不改资金链路，只补门禁测试和会员入口只读同步 | 当前实现大体正确，缺口主要是证据与口径 |
| 哪个更适合当前阶段 | Server tests + membership catalog sync freeze | 最小闭环，不扩大到购买支付 |
| 哪个风险更大 | 直接放开 callback / final charge runtime | 可能进入真实资金状态且缺幂等快照证据 |

## 10. 下一轮唯一动作

进入“Server 门禁测试补证包”：

- 补 callback 成功、重复、失败路径不改写 fee snapshot 的行为测试。
- 补 `standard / professional / ka / flagship` final charge 使用 locked feeRate 的行为测试。
- 不触发真实支付。
- 不新增会员购买、续费、账单功能。
