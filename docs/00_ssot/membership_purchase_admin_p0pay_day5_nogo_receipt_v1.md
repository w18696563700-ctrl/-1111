---
owner: Codex 总控
status: frozen
layer: L0 Day 5 No-Go Receipt
created_at: 2026-05-01
scope: membership direct purchase Day 5 implementation gate
purpose: Record why Day 5 Server membership direct-purchase implementation is blocked before code changes. This file does not unlock Server, BFF, Flutter, Admin, DB migration, cloud deployment, payment execution, or launch.
inputs_canonical:
  - docs/00_ssot/membership_purchase_admin_p0pay_day1_boundary_register_v1.md
  - docs/00_ssot/membership_purchase_admin_p0pay_implementation_ruling_v1.md
  - docs/01_contracts/membership_purchase_admin_p0pay_contracts_addendum_v1.md
  - docs/02_backend/membership_purchase_admin_p0pay_server_design_v1.md
  - docs/00_ssot/membership_direct_purchase_rules_v1.md
  - docs/00_ssot/my_building_v20_membership_entitlement_and_quota_rules_addendum.md
  - docs/00_ssot/payment_channel_constraints_assumptions_v1.md
  - docs/01_contracts/openapi.yaml
---

# 会员直购 / Admin 查询 / P0-Pay 联动 Day 5 No-Go 回执 V1

## 0. 总裁决

- Day 1 边界冻结：`Done`
- Day 2 SSOT 主裁决：`Done`
- Day 3 contracts / OpenAPI：`Done`
- Day 4 Server 设计：`Done`
- Day 5 Server 会员直购最小闭环实现：`No-Go`
- 是否允许继续写 Server 直购代码：`No`
- 是否允许新增 DB migration：`No`
- 是否允许进入 BFF / Flutter / Admin / P0-Pay 后续实现：`No`
- 是否允许动云端 / 支付通道 / 真实支付：`No`

Day 5 不通过的原因不是代码能力不足，而是正式商业与支付前置 truth 缺失。当前不得用候选年费或候选支付通道硬编码成正式直购实现。

## 1. 已完成项

| 阶段 | 产出物 | 当前状态 |
|---|---|---|
| Day 1 | 《会员直购 / Admin 查询 / P0-Pay 联动 Day 1 边界冻结台账 V1》 | 已冻结 |
| Day 2 | 《会员直购与服务费联动实施裁决 V1》 | 已冻结 |
| Day 3 | 《membership purchase / admin query / p0-pay discount contracts addendum v1》与 OpenAPI schema | 已冻结，`contracts:generate` / `contracts:check` 已通过 |
| Day 4 | 《会员直购 / Admin 查询 / P0-Pay 联动 Server 设计 V1》 | 已冻结 |

## 2. Day 5 阻塞点

| 阻塞点 | 当前证据 | 影响 | 是否一票否决 |
|---|---|---|---:|
| 会员 SKU 正式价格未冻结 | `membership_direct_purchase_rules_v1.md` 要求 SKU truth 包含 `priceAmount`；但 `my_building_v20_membership_entitlement_and_quota_rules_addendum.md` 明确 `2999 / 6999` 仍是候选商业参数，不得写成正式上线价格 | 无法合法实现 `purchase-offers`、`order-create` 的正式应付金额 | 是 |
| 可售 SKU 状态缺正式 owner | direct-purchase 预校验要求 `SKU 当前可售`，但当前只冻结了标准/专业两档会员规则，未冻结可售 SKU、价格、生效周期与上下架状态 | 无法判断 order-create 是否应放行 | 是 |
| 支付通道仍为 candidate | `payment_channel_constraints_assumptions_v1.md` 写明会员直购可保留微信/支付宝 candidate，但进入 contracts/backend/BFF/frontend 前必须再次核验商户主体、拉起路径、回调、退款、对账、组织签约方式 | 不能实现真实 `pay-init` / callback 生产链路 | 是 |
| Day 2 自身要求 Day 5 前复核通道 | 《会员直购与服务费联动实施裁决 V1》第 5 节要求进入 Day 5 / Day 13 前重新核验商户主体准入、App/H5/小程序路径、回调验签、退款对账、沙箱能力 | 支付初始化与回调实现不得直接落地 | 是 |

## 3. 不允许做的变通

| 变通做法 | 当前裁决 |
|---|---|
| 把 `2999 / 6999` 直接写进 Server SKU catalog | 禁止。它们仍是 candidate commercial parameter。 |
| 让 BFF 或 Flutter 自己维护 SKU 价格 | 禁止。SKU truth owner 是 Server.membership / payment。 |
| 用 `priceAmount = 0` 或 mock price 先跑通订单 | 禁止。会污染订单与支付真相。 |
| 先做真实支付初始化，后补商户/回调资质 | 禁止。支付通道前置未通过。 |
| 跳过 Day 5 直接做 BFF / Flutter 页面 | 禁止。会让展示早于 Server truth。 |
| 跳到 P0-Pay 联动 | 禁止。P0-Pay 依赖有效会员 entitlement truth。 |

## 4. 当前可保留成果

| 成果 | 是否保留 | 说明 |
|---|---:|---|
| 9 折 / 8 折服务费规则 | 是 | 仍是当前正式费率口径，不受 Day 5 阻塞影响。 |
| 会员直购状态机设计 | 是 | 订单状态、支付状态、权益状态三者分离仍成立。 |
| Admin 最小查询设计 | 是 | 仍可作为后续 Day 8 输入，但必须等待订单 truth 落地。 |
| P0-Pay 折扣快照设计 | 是 | 仍可作为后续 Day 9 输入，但必须等待会员生效 truth。 |
| 旧 `2.5% / 2.0% / 1.5%` deprecated 裁决 | 是 | 不得回流。 |

## 5. 下一轮唯一动作

输出《会员直购 SKU 价格与支付通道前置冻结方案》，只出方案，不执行。

该方案必须一次性冻结：

1. 标准会员 / 专业会员的正式 `skuCode / skuName / durationMonths / priceAmount / currency / status`。
2. `2999 / 6999` 是否从候选参数升级为正式价格；若不升级，必须给出新的正式价格或继续 No-Go。
3. 微信 / 支付宝在当前 App 形态下的可用范围、沙箱能力、回调域名、验签、退款/对账边界。
4. order-create 与 pay-init 的放行条件。
5. 仍不开放的能力：续费、取消、退款完整流、发票、KA / 旗舰、Admin 写操作。

在该方案冻结前，不得继续 Day 5 Server 会员直购实现。
