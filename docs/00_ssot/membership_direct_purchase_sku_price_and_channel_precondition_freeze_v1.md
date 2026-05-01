---
owner: Codex 总控
status: frozen
layer: L0 SSOT
created_at: 2026-05-01
scope: membership direct-purchase formal SKU price and payment-channel precondition freeze
purpose: Freeze the formal direct-purchase SKU price and channel priority that unblock Day 5 Server implementation re-entry. This file does not itself implement Server, BFF, Flutter, Admin, DB migration, cloud deployment, production payment, refund, invoice, renewal, cancellation, KA, or flagship.
inputs_canonical:
  - docs/00_ssot/membership_purchase_admin_p0pay_day5_nogo_receipt_v1.md
  - docs/00_ssot/membership_purchase_admin_p0pay_implementation_ruling_v1.md
  - docs/00_ssot/membership_direct_purchase_rules_v1.md
  - docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/01_contracts/membership_purchase_admin_p0pay_contracts_addendum_v1.md
  - docs/01_contracts/openapi.yaml
---

# 会员直购 SKU 价格与支付通道前置冻结 V1

## 0. 总裁决

- 是否冻结会员直购正式 SKU 价格：`Yes`
- 是否允许继续 Day 5 Server 会员直购最小闭环实现：`Go after contracts alignment`
- 是否允许直接进入 BFF / Flutter / Admin / P0-Pay 后续实现：`No-Go until Day 5 Server passes`
- 是否允许动云端 / 真实生产支付：`No-Go`
- 是否允许启用退款 / 发票 / 续费 / 取消 / 自动续费：`No-Go`
- 是否允许启用 KA / 旗舰：`No-Go`
- 是否允许复活 `2.5% / 2.0% / 1.5%` 固定费率：`No-Go`

本文件只解除 Day 5 No-Go 中的两个前置阻塞：

1. `priceAmount` 正式价格缺失。
2. 支付通道首轮优先级缺失。

本文件不代表支付商户资质、回调域名、沙箱、生产支付或云端部署已经通过 runtime 验证。

## 1. 正式 SKU 价格表

| skuCode | skuName | membershipTier | durationMonths | priceAmount | currency | status | 当前结论 |
|---|---|---|---:|---:|---|---|---|
| `membership_standard_year_v1` | 标准会员年付版 | `standard` | 12 | 2599 | `CNY` | `available` | 当前首轮正式可售 SKU |
| `membership_professional_year_v1` | 专业会员年付版 | `professional` | 12 | 4599 | `CNY` | `available` | 当前首轮正式可售 SKU |

硬规则：

1. 首轮只开放年付 SKU。
2. `priceAmount` 由 Server.membership / payment 作为唯一真相。
3. Flutter 不得硬编码价格真相。
4. BFF 不得维护第二 SKU 价格表。
5. order-create 必须校验 `expectedAmount / expectedCurrency` 与 Server SKU truth 一致。
6. `membership_standard_year_v1` 与 `membership_professional_year_v1` 以外的 SKU 一律按 unavailable / reserved 处理。

## 2. 旧候选价格处理

| 旧候选参数 | 当前处理 |
|---|---|
| 标准会员年费 `2999` | superseded planning parameter，不得作为当前正式展示或计算依据 |
| 专业会员年费 `6999` | superseded planning parameter，不得作为当前正式展示或计算依据 |
| 标准会员固定费率 `2.5%` | deprecated planning parameter，不得作为当前正式展示或计算依据 |
| 专业会员固定费率 `2.0%` | deprecated planning parameter，不得作为当前正式展示或计算依据 |
| KA / 旗舰 `1.5%` | deprecated / reserved，不启用 |

证据：旧 `2999 / 6999 / 2.5% / 2.0% / 1.5%` 原本只属于候选商业参数，且不得写成当前正式上线价格或 launch 参数。[my_building_v20_membership_entitlement_and_quota_rules_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md:346)

本文件以用户总控确认将当前正式价格改为：

1. 标准会员年费：`2599`
2. 专业会员年费：`4599`

## 3. 支付通道前置冻结

| payChannel | 当前优先级 | 是否首轮默认展示 | 是否允许 Day 5 实现 | runtime 前置 |
|---|---|---:|---:|---|
| `alipay_candidate` | 首轮优先通道 | 是 | 是，允许进入 Server 最小 pay-init/callback 施工 | Day 12/13 必须验证沙箱或受控支付、回调验签、订单查询、失败/关闭态 |
| `wechat_candidate` | 保留 / 灰度通道 | 否，除非显式灰度 | 可保留枚举与兼容分支；默认不得作为首轮主通道 | 必须另行验证商户主体、App 拉起、回调、退款/对账与组织签约方式 |

硬规则：

1. 首轮默认通道顺序固定为 `alipay_candidate` 优先，`wechat_candidate` 保留。
2. `wechat_candidate` 不得因保留枚举而被解释为已正式首发。
3. Server 可以实现 channel branch，但生产可用性必须由 runtime gate 决定。
4. 不得保存支付宝账号、微信账号、银行卡号、支付密码、短信验证码或长期自动扣款授权。
5. 不得触发真实生产支付，除非后续 Day 13 runtime gate 另行批准。

证据：会员直购支付通道原先只能写作微信 / 支付宝 candidate，且进入后续链路前必须核验商户主体、承载形态、回调、退款、对账与组织签约方式。[payment_channel_constraints_assumptions_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/payment_channel_constraints_assumptions_v1.md:78)

## 4. Day 5 重新进入条件

Day 5 Server 会员直购最小闭环可以重新进入，但仅限以下对象：

1. `purchase-offers`
2. `order-create`
3. `pay-init`
4. `order-result`
5. payment callback 最小验签 / 幂等 / 状态推进
6. entitlement writeback 到 `organization_paid_memberships`

Day 5 仍不得实现：

1. BFF App 侧购买投影。
2. Flutter 购买页面流。
3. Admin 查询页面。
4. P0-Pay 会员折扣联动。
5. 云端部署。
6. 真实生产支付。

## 5. 保留但暂不开通

| 能力 | 当前状态 |
|---|---|
| 续费 | 暂不开通 |
| 取消 | 暂不开通 |
| 退款完整流 | 暂不开通 |
| 发票 | 暂不开通 |
| 自动续费 | 暂不开通 |
| KA / 旗舰 | 仅预留 |
| Admin 手工开通 | 禁止 |
| Admin 手工修改会员等级 | 禁止 |
| Admin 手工退款 | 禁止 |
| 复杂 quota rich workflow | 后置 |

## 6. 下一轮唯一动作

对齐 contracts / OpenAPI 中的 SKU 与通道描述，然后重新进入 Day 5 Server 会员直购最小闭环实现。

若 contracts 对齐失败，则不得进入 Server 实现。
