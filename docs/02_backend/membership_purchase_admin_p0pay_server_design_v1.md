---
owner: Codex 总控
status: frozen
layer: L3 Server Design
created_at: 2026-05-01
scope: membership direct purchase server data model, state machine, idempotency, audit, admin query projection, and P0-Pay discount snapshot migration design
purpose: Freeze Day 4 Server design before implementation. This file unlocks Day 5 bounded Server implementation only after review; it does not itself create migrations, modify code, deploy cloud, or execute payment.
inputs_canonical:
  - docs/00_ssot/membership_purchase_admin_p0pay_implementation_ruling_v1.md
  - docs/01_contracts/membership_purchase_admin_p0pay_contracts_addendum_v1.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/02_backend/payment_finance_mainline_server_truth_addendum.md
  - apps/server/src/modules/membership/entities/organization-paid-membership.entity.ts
  - apps/server/src/modules/p0_pay/entities/payment-order.entity.ts
  - apps/server/src/modules/p0_pay/entities/payment-transaction.entity.ts
  - apps/server/src/modules/p0_pay/entities/payment-callback-event.entity.ts
  - apps/server/src/modules/p0_pay/entities/payment-idempotency-record.entity.ts
---

# 会员直购 / Admin 查询 / P0-Pay 联动 Server 设计 V1

## 0. 总裁决

- 是否允许进入 Day 5 Server 会员直购最小闭环实现：`Go after review`
- 是否允许直接动云端：`No-Go`
- 是否允许直接执行 DB migration：`No-Go until implementation migration is reviewed`
- 是否允许实现 Admin 写操作：`No-Go`
- 是否允许实现退款 / 发票 / 自动续费 / 取消：`No-Go`
- 是否允许启用 KA / 旗舰：`No-Go`
- 是否允许 P0-Pay 继续用旧 `2.5% / 2.0% / 1.5%` 作为当前规则：`No-Go`

Day 4 只冻结 Server 设计。Day 5 只能实现会员直购最小闭环，不得提前实现 Admin UI、BFF、Flutter 或 P0-Pay 联动。

## 1. Server 模块边界

| 模块 | 责任 | 禁止 |
|---|---|---|
| `membership` | 会员 SKU、会员订单、权益写入、会员订单查询、Admin 会员只读 query | 不处理 P0-Pay 项目交易扣费，不处理发票/退款完整流 |
| `payment` / current payment tables | 支付订单、支付流水、callback event、幂等记录 | 不决定会员权益是否生效 |
| `p0_pay` | 项目交易服务费预授权、合同确认扣费、P0-Pay 折扣快照 | 不创建会员订单，不开通会员 |
| `admin` | 只读查询会员订单和组织会员状态 | 不手工开通、退款、改支付状态、改权益额度 |

证据：现有会员读态 truth 已固定 `organization_paid_memberships` 为付费会员周期 carrier。[membership_entitlement_v1_backend_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/membership_entitlement_v1_backend_truth_addendum.md:85)

## 2. 数据模型设计

### 2.1 新增表：`membership_orders`

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| `id` | varchar(64) | PK | membershipOrderId |
| `organization_id` | varchar(64) | index | 购买与权益生效组织 |
| `created_by_user_id` | varchar(64) | index | 发起用户 |
| `sku_code` | varchar(64) | not null | Server SKU truth |
| `sku_name` | varchar(128) | not null | SKU snapshot |
| `membership_tier` | varchar(32) | not null | `standard / professional`，KA/旗舰不得新建 |
| `duration_months` | integer | not null | 当前最小周期 |
| `payable_amount` | numeric(12,2) | not null | 会员订单应付金额 |
| `currency` | varchar(8) | default `CNY` | 币种 |
| `order_status` | varchar(32) | index | `created / pending_pay / paying / paid / granting / active / closed / failed` |
| `payment_status` | varchar(32) | index | `not_started / pending / succeeded / failed / closed / unknown` |
| `entitlement_status` | varchar(32) | index | `not_granted / granting / active / grant_failed / expired` |
| `payment_order_id` | varchar(64) | nullable index | 关联 `payment_orders.id` |
| `paid_membership_id` | varchar(64) | nullable index | 关联写入后的 `organization_paid_memberships.id` |
| `effective_at` | timestamptz | nullable | 权益生效时间 |
| `expires_at` | timestamptz | nullable | 权益到期时间 |
| `failure_reason_code` | varchar(96) | nullable | 失败原因 |
| `request_id` | varchar(64) | not null | 审计 |
| `trace_id` | varchar(64) | not null | 链路 |
| `created_at` | timestamptz | not null | 创建时间 |
| `updated_at` | timestamptz | not null | 更新时间 |

推荐索引：

1. `idx_membership_orders_org_updated (organization_id, updated_at desc)`
2. `idx_membership_orders_status_updated (order_status, updated_at desc)`
3. `idx_membership_orders_payment_order (payment_order_id)`
4. `idx_membership_orders_paid_membership (paid_membership_id)`

### 2.2 复用表：`organization_paid_memberships`

权益写入必须继续落到 `organization_paid_memberships`，不能创建第二 paid membership truth。

当前已存在字段足以承载最小写入：

| 字段 | 用法 | 证据 |
|---|---|---|
| `organization_id` | 组织 scope | [organization-paid-membership.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/membership/entities/organization-paid-membership.entity.ts:8) |
| `tier_code` | 标准 / 专业 | [organization-paid-membership.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/membership/entities/organization-paid-membership.entity.ts:11) |
| `effective_at / expires_at` | 生效周期 | [organization-paid-membership.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/membership/entities/organization-paid-membership.entity.ts:14) |
| `source_type / source_ref` | `membership_direct_purchase / membershipOrderId` | [organization-paid-membership.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/membership/entities/organization-paid-membership.entity.ts:20) |

### 2.3 复用表：`payment_orders / payment_transactions / payment_callback_events / payment_idempotency_records`

会员直购支付不新建独立支付账本，优先复用现有支付表族：

| 表 | 用法 | 证据 |
|---|---|---|
| `payment_orders` | `business_type = membership_direct_purchase`，`business_id = membership_orders.id` | [payment-order.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/entities/payment-order.entity.ts:20) |
| `payment_transactions` | 记录 pay-init / callback / succeeded / failed | [payment-transaction.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/entities/payment-transaction.entity.ts:16) |
| `payment_callback_events` | callback event、验签、apply 状态 | [payment-callback-event.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/entities/payment-callback-event.entity.ts:8) |
| `payment_idempotency_records` | order-create / pay-init / callback apply 幂等 | [payment-idempotency-record.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/p0_pay/entities/payment-idempotency-record.entity.ts:3) |

迁移注意：

1. 若现有 DB check constraint 限制 `business_type`，Day 5 migration 必须新增 `membership_direct_purchase`。
2. 若 `paymentChannel` 类型枚举限制通道，Day 5 migration 必须确认 `wechat_candidate / alipay_candidate` 与实际 channel 字段映射。
3. 会员直购不得复用 `task_id / bid_id` 作为业务真相；这些字段可保持空字符串。

## 3. 状态机设计

### 3.1 会员订单主状态

```text
created -> pending_pay -> paying -> paid -> granting -> active
created -> closed
pending_pay/paying -> failed
paid/granting -> failed only if entitlement writeback fails and compensation is required
```

硬规则：

1. `paid` 不等于权益生效。
2. `active` 必须在 `organization_paid_memberships` 写入成功后设置。
3. `failed` 不得写入 paid membership。
4. 重复 callback 不得重复写入 paid membership。

### 3.2 支付状态

```text
not_started -> pending -> succeeded
not_started -> pending -> failed
pending -> closed
```

支付状态只由支付订单、支付流水、callback verification 或 provider query 结果推进。

### 3.3 权益状态

```text
not_granted -> granting -> active
not_granted -> granting -> grant_failed
active -> expired
```

权益状态只由 Server membership writeback 推进。

## 4. 幂等设计

| 操作 | 幂等 scope | 成功重复 | 冲突重复 |
|---|---|---|---|
| order-create | `membership-order:create:{organizationId}:{skuCode}` | 返回同一可支付订单 | 请求 hash 不一致则拒绝 |
| pay-init | `membership-order:pay-init:{membershipOrderId}` | 返回同一 payment order / channel payload | 金额、通道、订单状态不一致则拒绝 |
| callback apply | `membership-order:callback:{merchantOrderNo}` | no-op 返回已处理结果 | 验签失败或金额不一致则拒绝推进 |
| entitlement writeback | `membership-order:grant:{membershipOrderId}` | 返回已有 paid membership | 不重复生成 membership cycle |

## 5. 审计设计

最小 audit actions：

1. `membership_order_created`
2. `membership_pay_init_created`
3. `membership_payment_callback_verified`
4. `membership_payment_callback_rejected`
5. `membership_payment_succeeded`
6. `membership_entitlement_grant_started`
7. `membership_entitlement_granted`
8. `membership_entitlement_grant_failed`
9. `admin_membership_order_read`
10. `admin_membership_status_read`

审计必须包含：

1. `membershipOrderId`
2. `organizationId`
3. `actorId / userId`
4. `requestId`
5. `traceId`
6. 状态变更前后值

## 6. Admin 最小查询设计

Admin 查询只读取：

1. `membership_orders`
2. `organization_paid_memberships`
3. payment summary fields from `payment_orders`
4. audit summary

Admin 查询不得执行：

1. update membership order
2. update payment order
3. write organization paid membership
4. call refund provider API
5. replay callback

## 7. P0-Pay 会员折扣快照迁移设计

当前 P0-Pay 存在新旧双轨：

1. 旧 authorization requirement 仍有 `feeRate / feeRateLabel`。
2. final charge 已出现 `baseFeeAmount / membershipDiscountRate / capAmount / finalFeeAmount`。

Day 9/10 前必须完成迁移：

| 对象 | 处理 |
|---|---|
| `feeRate` | 历史兼容字段，新建 snapshot 不以它作为折扣 owner |
| `feeRateLabel` | 历史展示字段，新建 snapshot 不输出 `2.5% / 2.0% / 1.5%` |
| `membershipTierSnapshot` | 继续保留，但 KA/旗舰不得触发折扣 |
| `baseFeeAmount` | 新建正式 owner 字段 |
| `membershipDiscountRate` | 新建正式折扣字段 |
| `capAmount` | 新建正式封顶字段 |
| `discountedFeeAmount` | 需要补齐 |
| `pricingSnapshotHash` | 需要补齐 |

正式 discount mapping 以 platform pricing backend truth 为准。[platform_pricing_backend_truth_master_v1.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/platform_pricing_backend_truth_master_v1.md:416)

## 8. Migration 计划

### 8.1 Day 5 必需 migration 候选

1. 新增 `membership_orders`。
2. 扩展 payment business type 支持 `membership_direct_purchase`。
3. 视当前 DB constraint 情况补齐 payment channel / order role check。

### 8.2 Day 10 必需 migration 候选

1. 在 P0-Pay authorization / charge 表补齐 `discounted_fee_amount`。
2. 补齐 `pricing_snapshot_hash` 或确认复用现有 hash 字段是否满足新语义。
3. 将新建 P0-Pay 记录的当前折扣 owner 固定到 platform-pricing snapshot 字段族。

### 8.3 本文件不执行 migration

本文件只允许作为 Day 5/Day 10 migration implementation 的设计输入，不得被当成已经落库。

## 9. Day 4 验收

| 验收项 | 结果 |
|---|---|
| 订单状态、支付状态、权益状态分离 | Pass |
| 支付成功不等于权益生效 | Pass |
| 会员权益写入唯一落到 `organization_paid_memberships` | Pass |
| 会员订单有 dedicated table 设计 | Pass |
| 支付表族复用边界清楚 | Pass |
| Admin 只读边界清楚 | Pass |
| P0-Pay 旧 feeRate 清理路径清楚 | Pass |
| 未执行代码、migration、云端动作 | Pass |

## 10. Day 5 唯一动作

实现 Server 会员直购最小闭环：

1. `purchase-offers`
2. `order-create`
3. `pay-init`
4. `order-result`
5. payment callback membership branch
6. entitlement writeback

仍不得实现续费、取消、退款、发票、Admin 写操作、KA/旗舰或 P0-Pay 9 折/8 折联动。
