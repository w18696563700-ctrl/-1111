---
owner: Codex 总控
status: frozen
layer: L0 SSOT
created_at: 2026-05-01
scope: membership direct purchase minimum loop, membership order/Admin minimum query, and P0-Pay 9/8 discount linkage execution ruling
purpose: Freeze the Day 2 SSOT ruling after the Day 1 boundary register. This file unlocks Day 3 contracts authoring only; it does not unlock Server, BFF, Flutter, Admin, DB migration, cloud deployment, payment execution, or launch.
inputs_canonical:
  - docs/00_ssot/membership_purchase_admin_p0pay_day1_boundary_register_v1.md
  - docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md
  - docs/00_ssot/membership_read_surface_alignment_stage_gate_checklist_v2.md
  - docs/00_ssot/membership_direct_purchase_rules_v1.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/01_contracts/membership_entitlement_v1_contracts_addendum.md
  - docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md
  - docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md
---

# 会员直购与服务费联动实施裁决 V1

## 0. 总裁决

- 当前是否允许进入 Day 3 contracts 冻结：`Go`
- 当前是否允许直接改 Server：`No-Go`
- 当前是否允许直接改 BFF：`No-Go`
- 当前是否允许直接改 Flutter：`No-Go`
- 当前是否允许直接改 Admin：`No-Go`
- 当前是否允许新增 DB migration：`No-Go`
- 当前是否允许动云端 / 支付通道 / 真实支付：`No-Go`

本裁决只冻结三条后续施工线的 SSOT：

1. 会员直购最小闭环。
2. 会员订单状态与 Admin 最小查询。
3. P0-Pay `baseFeeAmount × 0.9 / 0.8` 服务费联动。

Day 3 必须先冻结 contracts / OpenAPI，才允许进入后续 Server 设计。

## 1. 正式会员与费率规则

| 对象 | 当前正式规则 | 不允许写法 | 证据 |
|---|---|---|---|
| 免费认证版 | 无会员折扣，按平台定价母规则计算 | 免费认证版享受付费会员折扣 | [membership_entitlement_and_fee_unified_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md:109) |
| 标准会员 | `baseFeeAmount × 0.9`，单项目封顶 `3600` | 固定 `2.5%` | [platform_pricing_rules_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:251) |
| 专业会员 | `baseFeeAmount × 0.8`，单项目封顶 `3200` | 固定 `2.0%` | [platform_pricing_rules_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/platform_pricing_rules_master_v1.md:253) |
| KA / 旗舰 | 仅预留，不启用 | 固定 `1.5%` 当前启用 | [membership_entitlement_and_fee_unified_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md:95) |

折扣作用对象固定为 platform pricing 规则计算出的 `baseFeeAmount`，不是成交金额固定百分比。

## 2. 会员直购最小闭环裁决

### 2.1 当前最小闭环

会员直购最小闭环只包含：

1. `purchase-offers`：读取可售标准 / 专业会员 SKU。
2. `order-create`：按组织 scope 创建会员订单。
3. `pay-init`：初始化会员订单支付。
4. `order-result`：只读查询会员订单、支付状态、权益状态。
5. `payment callback`：Server 验签、幂等、推进支付状态。
6. `entitlement writeback`：支付成功并完成订单状态推进后，Server 写入组织 paid membership。
7. `membership current refresh`：App 重新读取会员当前态。

### 2.2 状态语义

| 状态对象 | 允许状态 | 语义 |
|---|---|---|
| 会员订单 | `created / pending_pay / paying / paid / granting / active / closed / failed` | `active` 才表示权益已写入并生效 |
| 支付状态 | `not_started / pending / succeeded / failed / closed / unknown` | `succeeded` 只表示支付成功，不等于会员权益已生效 |
| 权益状态 | `not_granted / granting / active / grant_failed / expired` | 只由 Server membership 写入，不由 BFF/Flutter 推断 |

已有 L0/L2 证据说明 `paid` 不等于 entitlement 生效，`active` 才表示 entitlement 写入完成。[membership_direct_purchase_rules_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_direct_purchase_rules_v1.md:124), [membership_direct_purchase_v1_contracts_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/membership_direct_purchase_v1_contracts_addendum.md:148)

### 2.3 异常状态裁决

| 场景 | 当前裁决 | 用户展示边界 | Server 真相要求 |
|---|---|---|---|
| 购买失败 | 不开通会员 | 可展示失败原因和重试入口 | 订单进入 `failed` 或保持可关闭状态 |
| 支付未完成 | 不开通会员 | 展示待支付 / 支付中 / 已关闭 | 不得写入 paid membership |
| 回调未到 | 不开通会员 | 展示支付结果确认中 | 只能通过回调或 provider 查询后推进 |
| 支付成功但权益未写入 | 不得向用户展示已生效 | 展示权益开通处理中或异常待处理 | 必须有补偿任务或人工查询入口 |
| 权益写入失败 | 不得伪造成功 | 展示异常处理入口 | 必须保留审计和可重试证据 |

## 3. 会员订单状态与 Admin 最小查询裁决

### 3.1 当前最小闭环

Admin 最小查询只包含：

1. 会员订单列表只读。
2. 会员订单详情只读。
3. 组织当前 paid membership 状态只读。
4. 订单状态、支付状态、权益状态的异常可视化。
5. 审计/trace 信息只读。

### 3.2 明确禁止

- Admin 手工开通会员。
- Admin 手工修改会员等级。
- Admin 手工改支付状态。
- Admin 手工退款。
- Admin 修改权益额度。
- Admin 绕过 payment callback 写入权益。

当前 Admin 代码未发现会员查询 client 或页面，后续 Day 8 必须新增 dedicated 最小查询，不得复用其他 Admin 审核台承载会员治理。[admin-api-client.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/admin/src/core/server/admin-api-client.ts:1)

## 4. P0-Pay 9 折 / 8 折服务费联动裁决

### 4.1 当前正式公式

P0-Pay 会员折扣联动必须使用：

```text
baseFeeAmount = platform pricing master rule(finalConfirmedAmount)
membershipDiscountRate = 1.0 | 0.9 | 0.8
discountedFeeAmount = baseFeeAmount × membershipDiscountRate
finalFeeAmount = min(discountedFeeAmount, capAmount)
```

正式 mapping：

| membershipTierSnapshot | membershipDiscountRate | capAmount | 是否当前启用 |
|---|---:|---:|---:|
| `none` | `1.0000` | `4000.00` | 是 |
| `free_certified` | `1.0000` | `4000.00` | 是 |
| `standard` | `0.9000` | `3600.00` | 是 |
| `professional` | `0.8000` | `3200.00` | 是 |
| `ka` | `1.0000` | `4000.00` | 否，仅预留 |
| `flagship` | `1.0000` | `4000.00` | 否，仅预留 |

### 4.2 旧 P0-Pay feeRate 处理

旧 P0-Pay `feeRate` 链路统一降级：

| 旧口径 | 当前处理 | 证据 |
|---|---|---|
| 默认 `3.0%` | historical / compatibility only | [p0-pay-service-fee-rate.policy.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts:52) |
| 标准 `2.5%` | superseded / deprecated | [membership_entitlement_and_fee_unified_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md:145) |
| 专业 `2.0%` | superseded / deprecated | [membership_entitlement_and_fee_unified_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md:145) |
| KA / 旗舰 `1.5%` | superseded / deprecated，不启用 | [membership_entitlement_and_fee_unified_ruling_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md:145) |

后续 contracts 必须以 `baseFeeAmount / membershipDiscountRate / capAmount / finalFeeAmount` 为当前正式字段族。旧 `feeRate` 若保留，只能作为历史兼容读字段，不能作为新建计算 owner。

### 4.3 快照规则

P0-Pay 折扣快照必须至少包含：

1. `membershipTierSnapshot`
2. `baseFeeAmount`
3. `membershipDiscountRate`
4. `capAmount`
5. `discountedFeeAmount`
6. `finalFeeAmount`
7. `pricingRuleVersion`
8. `pricingSnapshotHash`
9. `feeCalculatedAt`

快照 owner 是 Server。BFF / Flutter 不得生成 `pricingSnapshotHash`，不得自算 `finalFeeAmount`。

## 5. 支付通道前置裁决

会员直购可以继续保留：

1. `wechat_candidate`
2. `alipay_candidate`

但它们当前仍只是 channel candidate。进入 Day 5/Day 13 前必须重新核验：

1. 当前商户主体准入。
2. App/H5/小程序承载路径。
3. 回调域名与验签。
4. 退款与对账路径。
5. 沙箱或受控测试能力。

证据：支付通道文书明确会员直购双 channel 仍为 candidate，实际接入前必须复核准入。[payment_channel_constraints_assumptions_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/payment_channel_constraints_assumptions_v1.md:78)

## 6. 阶段门禁

| 门禁 | 当前结果 | 是否一票否决 | 说明 |
|---|---|---:|---|
| Day 1 边界表存在 | Pass | 是 | [membership_purchase_admin_p0pay_day1_boundary_register_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_purchase_admin_p0pay_day1_boundary_register_v1.md:24) |
| 旧费率禁止当前化 | Pass | 是 | 本文第 4.2 节 |
| 会员直购状态语义清晰 | Pass | 是 | 本文第 2 节 |
| Admin 查询未扩大为写后台 | Pass | 是 | 本文第 3 节 |
| P0-Pay 使用 `baseFeeAmount` 折扣公式 | Pass | 是 | 本文第 4.1 节 |
| contracts / OpenAPI 已对齐本裁决 | Pending | 是 | Day 3 执行 |
| Server/BFF/Flutter/Admin 代码可改 | No-Go | 是 | 等 Day 3/Day 4 通过 |
| 云端 runtime 可动 | No-Go | 是 | 等 Day 12/Day 13 |

## 7. Day 3 唯一动作

冻结 contracts / OpenAPI：

1. `membership purchase contracts`
2. `admin membership query contracts`
3. `p0-pay membership discount snapshot contracts`

Day 3 未通过前，不得进入 Server、BFF、Flutter、Admin 或云端施工。
