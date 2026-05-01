---
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-04-30
purpose: Freeze the first controlled finance execution boundary for real payment-success callback and contract final charge without widening into wallet, generic refund, payout settlement, invoice, or finance-admin.
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - apps/server/src/modules/p0_pay/p0-pay-callback.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts
---

# 资金主线 L0 规则冻结单

## 0. 总裁决

- 当前是否允许直接全量开通真实支付 / 扣款 / 退款 / 结算：No-Go
- 当前是否允许进入受控支付成功 callback 与合同最终扣费最小闭环：Go
- 当前是否允许 Flutter / BFF 判断支付成功：No-Go
- 当前是否允许新增钱包、余额、清分结算、发票、财务后台：No-Go

核心原因：

1. 当前平台收费母文件已经冻结 `200 元项目真实性诚意金`、`4000 元竞标服务费预授权额度` 和成交后服务费扣取。
2. Server 已有 payment order、callback event、transaction、charge 骨架。
3. 真实资金状态必须由 Server 根据验签 callback、通道查询或受控 Server capture 推进。
4. BFF 只能透传和整形，Flutter 只能回读展示。

## 1. 当前最小闭环

本期只做以下闭环：

1. `PaymentOrder` 已创建并处于 `pending_user_confirm`。
2. 支付通道 callback 进入 Server 专用 callback endpoint。
3. Server 验签成功后，幂等推进 payment order。
4. 项目真实性诚意金订单支付成功后，只把诚意金状态推进为 `paid`，不自动发布项目。
5. 合同双向确认后，Server 按 locked authorization snapshot 生成最终平台服务费 charge。
6. 最终扣费必须复用授权时锁定的 fee rate / tier / rule snapshot。
7. 所有资金动作必须写 audit / transaction / callback event。

## 2. 本期不做

本期明确不做：

1. 通用支付中心。
2. 钱包、余额、金币、资金池。
3. 通用退款工作台。
4. 清分结算、提现、平台分账、发票、税务、财务后台。
5. Flutter 本地判断支付成功。
6. BFF 本地判断支付成功。
7. 前端传入最终资金状态。
8. 结算账户、商户入网、支付渠道商户资质的永久真相冻结。

## 3. 资金真相边界

| 层 | 允许做 | 禁止做 |
|---|---|---|
| Server | 支付订单、callback、幂等、交易、审计、最终扣费真相 | 把通道未验签 payload 当真相 |
| BFF | auth 转发、payload shaping、read model 整形、中文错误 | 计算资金状态、伪造 paid、伪造 charged |
| Flutter | 展示状态、拉起 pay-init、回读 order-status | 判断支付成功、改写状态、绕过 BFF |

## 4. 退款与结算边界

本期只冻结字段和后续门禁，不实现完整退款 / 结算：

1. `refund_pending / refunded` 可以作为状态字段存在。
2. `released` 可以表示预授权额度释放的 Server 内部结果。
3. 真正 provider refund / provider settlement / clearing payout 必须另开包。
4. 不得把 `server_capture` 或 `released` 误写成真实外部清分结算已完成。

## 5. 阶段门禁

| 门禁 | 当前裁决 |
|---|---|
| L2 contracts | Go |
| L3 Server truth | Go |
| Persistence / migration design | Go |
| Callback implementation | Conditional Go, 仅限受控 callback endpoint |
| Paid readback | Go |
| Cloud controlled callback sample | Conditional Go, 仅限 test-channel / controlled sample |
| Final charge implementation | Conditional Go, 必须复用 locked snapshot |
| Refund implementation | No-Go, 另开包 |
| Settlement implementation | No-Go, 另开包 |

## 6. 四类判断

| 判断 | 结论 | 原因 |
|---|---|---|
| 哪个更稳 | 先开受控 payment callback + final charge，退款/结算后置 | 资金链路可分段验证 |
| 哪个更省成本 | 复用现有 P0-Pay 基础设施 | 已有 order / callback / transaction / charge 骨架 |
| 哪个更适合当前阶段 | 只做项目发布与合同扣费闭环 | 已有业务锚点明确 |
| 哪个风险更大 | 直接做钱包、退款、结算全家桶 | 范围过大且需要法务、财务、渠道准入 |

## 7. 下一轮唯一动作

进入 L2 Contracts 冻结，补齐 payment order、callback result、charge、refund、settlement summary 的字段 owner 与错误码边界。
