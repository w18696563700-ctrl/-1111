---
owner: Codex 总控
status: frozen
layer: L2 Contracts
created_at: 2026-05-01
scope: membership direct purchase, admin membership minimum query, and P0-Pay membership discount snapshot contracts
purpose: Freeze Day 3 contracts after the L0 implementation ruling. This addendum unlocks Day 4 Server data-model and state-machine design only; it does not unlock Server/BFF/Flutter/Admin implementation, DB migration, cloud deployment, payment execution, or launch.
inputs_canonical:
  - docs/00_ssot/membership_purchase_admin_p0pay_day1_boundary_register_v1.md
  - docs/00_ssot/membership_purchase_admin_p0pay_implementation_ruling_v1.md
  - docs/00_ssot/membership_direct_purchase_sku_price_and_channel_precondition_freeze_v1.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
---

# 会员直购 / Admin 查询 / P0-Pay 联动 Contracts Addendum V1

## 0. 总裁决

- 是否允许进入 Day 4 Server 数据模型与状态机设计：`Go`
- 是否允许直接进入 Server 实现：`No-Go`
- 是否允许直接进入 BFF 实现：`No-Go`
- 是否允许直接进入 Flutter 实现：`No-Go`
- 是否允许直接进入 Admin 实现：`No-Go`
- 是否允许新增 DB migration：`No-Go until Day 4 design passes`
- 是否允许动云端、支付通道或真实支付：`No-Go`

本文件只冻结 contracts。所有业务真相仍必须由 Server 承担；BFF 只聚合/整形；Flutter 只展示；Admin 只读查询。

## 1. Membership Purchase Contracts

| 能力 | Canonical path | 主要 schema | 结论 |
|---|---|---|---|
| 购买 offer | `GET /api/app/profile/membership/purchase-offers` | `MembershipPurchaseOffersResponse` | 冻结 |
| 会员订单创建 | `POST /api/app/profile/membership/orders` | `MembershipOrderCreateRequest / MembershipOrderCreateResponse` | 冻结 |
| 支付初始化 | `POST /api/app/profile/membership/orders/{membershipOrderId}/pay-init` | `MembershipPayInitRequest / MembershipPayInitResponse` | 冻结 |
| 订单结果只读 | `GET /api/app/profile/membership/orders/{membershipOrderId}` | `MembershipOrderResultResponse` | 冻结 |

当前正式 SKU 与通道前置：

| skuCode | membershipTier | durationMonths | priceAmount | currency | status |
|---|---|---:|---:|---|---|
| `membership_standard_year_v1` | `standard` | 12 | 2599 | `CNY` | `available` |
| `membership_professional_year_v1` | `professional` | 12 | 4599 | `CNY` | `available` |

| payChannel | 当前语义 |
|---|---|
| `alipay_candidate` | 首轮优先通道，允许进入 Day 5 Server 最小 pay-init/callback 施工，但生产可用仍受 runtime gate 约束 |
| `wechat_candidate` | 保留 / 灰度通道，不作为首轮默认展示或默认支付通道 |

旧 `2999 / 6999` 只保留为 superseded planning parameter，不得作为当前正式价格。证据：[membership_direct_purchase_sku_price_and_channel_precondition_freeze_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/membership_direct_purchase_sku_price_and_channel_precondition_freeze_v1.md:37)

状态分离规则：

1. `MembershipOrderStatus.paid` 只表示 payment success。
2. `MembershipOrderStatus.active` 才表示 entitlement 已写入并生效。
3. `MembershipPaymentStatus.succeeded` 不得被 Flutter 或 BFF 解释为权益已生效。
4. `MembershipEntitlementStatus.active` 只能由 Server membership 写入后返回。

证据：

- [openapi.yaml membership purchase paths](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml:472)
- [openapi.yaml membership schemas](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml:6080)

## 2. Admin Membership Minimum Query Contracts

| 能力 | Canonical path | 主要 schema | 写能力 |
|---|---|---|---|
| 会员订单列表 | `GET /server/admin/membership/orders` | `AdminMembershipOrderListResponse` | 无 |
| 会员订单详情 | `GET /server/admin/membership/orders/{membershipOrderId}` | `AdminMembershipOrderDetailResponse` | 无 |
| 组织会员状态 | `GET /server/admin/membership/organizations/{organizationId}/status` | `AdminMembershipOrganizationStatusResponse` | 无 |

Admin 当前只冻结 read-only minimum query，不冻结：

1. 手工开通会员。
2. 手工改会员等级。
3. 手工退款。
4. 手工改支付状态。
5. 手工改权益额度。

证据：

- [openapi.yaml admin membership paths](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml:5212)
- [openapi.yaml admin membership schemas](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml:7794)

## 3. P0-Pay Membership Discount Snapshot Contracts

P0-Pay 新建会员折扣快照必须使用：

```text
baseFeeAmount × membershipDiscountRate
```

不得使用：

```text
成交金额 × 2.5% / 2.0% / 1.5%
```

当前冻结字段族：

| 字段 | Owner | 说明 |
|---|---|---|
| `calculationBasis` | Server | `estimated_authorization` 或 `final_charge` |
| `calculationAmount` | Server | 当前估算/最终计算对象金额 |
| `ruleVersion` | Server | platform-pricing 规则版本 |
| `membershipTierSnapshot` | Server | 有效会员档位快照，KA/旗舰仅预留 |
| `baseFeeAmount` | Server | 平台定价母规则结果 |
| `membershipDiscountRate` | Server | `1.0 / 0.9 / 0.8` |
| `capAmount` | Server | `4000 / 3600 / 3200` |
| `discountedFeeAmount` | Server | 折扣后、封顶前金额 |
| `finalFeeAmount` | Server | 最终服务费金额 |
| `pricingSnapshotHash` | Server | 规则与快照 hash |
| `feeCalculatedAt` | Server | 计算时间 |

该字段族已冻结为：

- `P0PayMembershipDiscountSnapshot`
- `BidServiceFeeAuthorizationCreateResponse.platformServiceFeeDiscountSnapshot`
- `BidServiceFeeAuthorizationStatusResponse.platformServiceFeeDiscountSnapshot`
- `PricingServiceFeeCalculation` 的当前正式计算字段补强

证据：

- [openapi.yaml P0-Pay discount snapshot](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml:9300)
- [openapi.yaml bid service-fee authorization response](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/openapi.yaml:10190)

## 4. Error Codes

新增 membership purchase / admin / pricing snapshot error codes：

1. `MEMBERSHIP_PURCHASE_OFFERS_UNAVAILABLE`
2. `MEMBERSHIP_ORDER_CREATE_REJECTED`
3. `MEMBERSHIP_ORDER_NOT_FOUND`
4. `MEMBERSHIP_PAY_INIT_REJECTED`
5. `MEMBERSHIP_ORDER_RESULT_UNAVAILABLE`
6. `MEMBERSHIP_ADMIN_QUERY_UNAVAILABLE`
7. `MEMBERSHIP_ADMIN_ORDER_NOT_FOUND`
8. `MEMBERSHIP_PRICING_SNAPSHOT_MISMATCH`

证据：[error_codes.yaml membership codes](/Users/wangweiwei/Desktop/展览装修之家总控/docs/01_contracts/error_codes.yaml:181)

## 5. Veto Gates

| Gate | 结果 | 说明 |
|---|---|---|
| App 不直连 Server | Pass | App-facing 仍为 `/api/app/profile/membership/*` |
| Admin 不经 BFF | Pass | Admin paths 固定为 `/server/admin/membership/*` |
| BFF 不拥有业务真相 | Pass | Contracts 只允许 BFF 聚合/整形 |
| P0-Pay 不复活旧 fixed feeRate | Pass | 新 snapshot 使用 `baseFeeAmount / membershipDiscountRate / capAmount / finalFeeAmount` |
| `membershipStatus` 不混成 paid membership | Pass | 新 contracts 使用 `paidMembershipTier / membershipTierSnapshot / entitlementStatus` |
| 自动续费 / 取消 / 退款 / 发票 | Pass | 未在本 Day 3 contracts 中解锁 |

## 6. Day 4 唯一动作

进入 Server 数据模型与状态机设计：

1. 会员订单表。
2. 支付流水 / 回调 / 幂等关联。
3. entitlement writeback 记录。
4. Admin read-only query projection。
5. P0-Pay discount snapshot migration plan。

Day 4 仍不得直接写 Server 实现或 DB migration，除非 Day 4 设计门禁通过。
