---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day 2 persistence and migration companion truth for the current
  platform pricing rebaseline, clarifying what physical storage may be reused,
  what additive columns are required, what legacy columns become
  compatibility-only, and what migration boundary is allowed before any
  implementation dispatch.
layer: L3 Backend Truth
freeze_date_local: 2026-04-29
version: V1
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_companion_patch_v1.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - apps/server/src/modules/p0_pay/entities/inquiry-quote-deposit.entity.ts
  - apps/server/src/modules/p0_pay/entities/platform-service-fee-authorization.entity.ts
  - apps/server/src/modules/p0_pay/entities/platform-service-fee-charge.entity.ts
  - apps/server/src/modules/p0_pay/entities/contract-confirmation.entity.ts
  - apps/server/src/modules/p0_pay/entities/payment-order.entity.ts
  - apps/server/src/modules/p0_pay/entities/payment-transaction.entity.ts
  - apps/server/src/modules/p0_pay/entities/payment-idempotency-record.entity.ts
  - apps/server/src/modules/p0_pay/entities/payment-callback-event.entity.ts
---

# 《平台收费规则 Persistence / Migration Companion Truth V1》

## 0. 总结论

Day 2 的 persistence / migration companion truth 已冻结。

本轮正式选择：

1. 复用现有 `p0_pay` 支付基础设施，但不继续承认其旧业务语义
2. 第一个实现轮次只允许 `additive migration`
3. 不做物理删表、不做物理改表名、不做 destructive rename
4. 当前收费 owner 继续以新母文件逻辑名为准，旧物理表名只当第一轮兼容载体

当前更稳的方案：

- 逻辑重基线，物理兼容复用；先把新收费真相写死到 companion truth，再决定后续代码切换

当前更省成本的方案：

- 沿用 `payment_orders / payment_transactions / payment_callback_events / payment_idempotency_records / audit_logs`，只对业务 owner 表做最小增量列补丁

当前阶段最适合的方案：

- 保留旧 `p0_pay` 表结构作为第一轮物理载体，但明确哪些旧列退居 compatibility-only

风险更大的方案：

- 继续让 `inquiry_deposit / estimated_fee_amount / 3% fee_rate` 直接充当当前收费业务真相

## 1. 当前最小闭环

当前 persistence 最小闭环只覆盖：

1. `ProjectAuthenticitySincerityOrder`
2. `BidServiceFeeAuthorization`
3. `DealConfirmation`
4. `PlatformServiceFeeCharge`
5. `PaymentOrder`
6. `PaymentTransaction`
7. `PaymentCallbackEvent`
8. `PaymentIdempotencyRecord`

当前明确不新增独立持久化聚合：

1. `ProjectPublishPricingGate`
2. `BidSubmitPricingGate`
3. `PricingSummary`

当前明确不作为 runtime owner 的只读家族：

1. `payment_billing`

这三者继续是 `Server-derived truth`，不入库为新主表。

## 2. 需要保留但暂不开通

当前 companion truth 必须保留但暂不开通：

1. 新物理表重命名或整表迁移
2. 云端历史数据全量 backfill
3. 清理旧 `p0_pay` 表或旧列
4. wallet / balance / billing center / settlement ledger
5. 通用 finance-admin schema

## 3. 后续扩展位

后续扩展位正式保留：

1. 第二轮再决定是否把旧 `p0_pay` 物理表改名为新收费领域表名
2. 第二轮再决定是否把 compatibility-only 列彻底清退
3. 第二轮再决定是否补结构化 pricing ledger / finance projection

## 4. 物理复用决策矩阵

| 当前逻辑真相 | 当前物理载体 | 本轮裁决 | 第一轮迁移动作 |
|---|---|---|---|
| `ProjectAuthenticitySincerityOrder` | `inquiry_quote_deposits` | 复用物理表，不复用旧名称语义 | 保留表名；增量补 `withheld_at`、`withhold_reason_code`；切换逻辑名 |
| `BidServiceFeeAuthorization` | `platform_service_fee_authorizations` | 复用物理表，不复用旧 `estimated fee / 3%` 语义 | 保留表名；增量补 quota 与 gate 所需列；旧 fee-rate 列退居兼容位 |
| `DealConfirmation` | `contract_confirmations` | 复用物理表 | 保留表名；`task_id -> projectId` 逻辑映射；`contract_status -> dealStatus` 逻辑映射 |
| `PlatformServiceFeeCharge` | `platform_service_fee_charges` | 复用物理表，不复用旧 fee-rate authority | 保留表名；增量补阶梯计费结果列；旧 fee-rate 列退居兼容位 |
| `PaymentOrder` | `payment_orders` | 原样复用 | 只扩 `business_type` 取值，不改表结构 |
| `PaymentTransaction` | `payment_transactions` | 原样复用 | 只扩业务解释，不改表结构 |
| `PaymentCallbackEvent` | `payment_callback_events` | 原样复用 | 只扩业务解释，不改表结构 |
| `PaymentIdempotencyRecord` | `payment_idempotency_records` | 原样复用 | 只扩 `operation_key / resource_type` 值域，不改表结构 |

## 5. 强制新增列与索引

### 5.1 `inquiry_quote_deposits`

当前逻辑承接 `ProjectAuthenticitySincerityOrder` 时，第一轮必须增量补：

1. `withheld_at timestamptz null`
2. `withhold_reason_code varchar(96) default ''`

当前不要求新增 `project_id`，因为现有 `task_id` 在第一轮直接逻辑映射为 `projectId`。

### 5.2 `platform_service_fee_authorizations`

当前逻辑承接 `BidServiceFeeAuthorization` 时，第一轮必须增量补：

1. `bid_participation_request_id varchar(64) null`
2. `bidder_organization_id varchar(64) null`
3. `authorization_quota_amount numeric(12,2) null`
4. `charged_amount_used numeric(12,2) default 0`
5. `released_amount numeric(12,2) default 0`
6. `frozen_at timestamptz null`

第一轮必须增量补的索引：

1. `idx_platform_service_fee_auth_bid_participation_request` on `bid_participation_request_id`
2. `idx_platform_service_fee_auth_project_bidder` on `task_id, bidder_organization_id`
3. 唯一活跃授权约束：
   - 当前建议用 `partial unique index`
   - 逻辑键：`task_id + bidder_organization_id`
   - 活跃状态最小集合：`pending_freeze | frozen | release_pending | charge_pending`

### 5.3 `platform_service_fee_charges`

当前逻辑承接 `PlatformServiceFeeCharge` 时，第一轮必须增量补：

1. `base_fee_amount numeric(12,2) null`
2. `membership_discount_rate numeric(8,4) null`
3. `cap_amount numeric(12,2) null`
4. `released_remainder_amount numeric(12,2) null`

当前不强制新增 `project_id`，因为现有 `task_id` 在第一轮直接逻辑映射为 `projectId`。

### 5.4 `contract_confirmations`

当前逻辑承接 `DealConfirmation` 时，第一轮不强制新增列。

但第一轮必须明确：

1. `task_id` 当前就是 `projectId` 的物理承载列
2. `contract_status` 当前就是 `dealStatus` 的物理承载列
3. `selected_quotation_id` 退居 legacy-only，不再作为当前收费主线 authority

### 5.5 `payment_orders`

第一轮不改表结构，但 `business_type` 必须正式扩为只允许承接：

1. `project_authenticity_sincerity_payment`
2. `bid_service_fee_authorization_freeze`
3. `bid_service_fee_authorization_release`
4. `platform_service_fee_charge`
5. `project_authenticity_sincerity_refund`

第一轮不得再把当前新收费主线的正式 `business_type` 写回旧 `inquiry_deposit`。

### 5.6 `payment_idempotency_records`

第一轮不改表结构，但 `operation_key / resource_type` 必须扩为当前主线值域。

最小 `operation_key` 集合冻结为：

1. `projectAuthenticitySincerityOrder.create`
2. `projectAuthenticitySincerityOrder.payInit`
3. `projectAuthenticitySincerityOrder.refund`
4. `bidServiceFeeAuthorization.create`
5. `bidServiceFeeAuthorization.freezeInit`
6. `bidServiceFeeAuthorization.release`
7. `dealConfirmation.upsert`
8. `platformServiceFeeCharge.create`

最小 `resource_type` 集合冻结为：

1. `project_authenticity_sincerity_order`
2. `bid_service_fee_authorization`
3. `deal_confirmation`
4. `platform_service_fee_charge`

## 6. legacy-only 列冻结

以下旧列第一轮允许保留，但不得继续作为当前收费主线 authority：

### 6.1 `inquiry_quote_deposits`

1. `deducted_at`
2. `deduction_reason`

当前替代真相：

1. `withheld_at`
2. `withhold_reason_code`

### 6.2 `platform_service_fee_authorizations`

1. `quoted_amount`
2. `fee_rate`
3. `estimated_fee_amount`
4. `fee_rate_label`
5. `fee_rate_source`
6. `membership_tier_snapshot`
7. `fee_rate_rule_version`
8. `fee_rate_snapshot_hash`
9. `fee_calculated_at`

当前替代规则：

1. `authorization_quota_amount` 才是 `4000` quota 真相
2. `rule_version + rule_snapshot_hash` 才是当前授权主线快照真相
3. 旧 `fee_rate*` 只允许作为历史兼容列或回放字段保留

### 6.3 `platform_service_fee_charges`

1. `fee_rate`
2. `fee_rate_label`
3. `fee_rate_source`
4. `fee_rate_rule_version`
5. `fee_rate_snapshot_hash`
6. `fee_calculated_at`

当前替代规则：

1. `base_fee_amount`
2. `membership_discount_rate`
3. `cap_amount`
4. `final_fee_amount`

才是当前阶梯计费真相。

### 6.4 `contract_confirmations`

1. `selected_quotation_id`

该列第一轮保留，但不再作为当前收费主线的成交 authority。

## 7. 状态词表归一化边界

第一轮实现必须采用 `逻辑新词表 + 物理兼容读写边界`。

### 7.1 `ProjectAuthenticitySincerityOrder`

当前逻辑词表：

1. `pending_payment`
2. `paid`
3. `refund_pending`
4. `refunded`
5. `withheld`
6. `cancelled`
7. `failed`

当前兼容读取：

1. 旧 `deducted` 统一映射为逻辑 `withheld`
2. 旧 `dispute_hold` 不再新写；第一轮只允许兼容读成 `withheld`

### 7.2 `BidServiceFeeAuthorization`

当前逻辑词表：

1. `pending_freeze`
2. `frozen`
3. `release_pending`
4. `released`
5. `charge_pending`
6. `charged`
7. `breach_hold`
8. `cancelled`
9. `failed`

当前兼容读取：

1. 旧 `pending_authorization` 映射为 `pending_freeze`
2. 旧 `authorized` 映射为 `frozen`
3. 旧 `authorization_released` 映射为 `released`
4. 旧 `refund_pending` 与 `refunded` 第一轮只允许兼容读成 `released`
5. 旧 `pending_contract_confirm` 映射为 `charge_pending`
6. 旧 `expired` 第一轮只允许兼容读成 `failed`

第一轮新写入不得再落旧词表。

### 7.3 `DealConfirmation`

当前逻辑词表：

1. `pending_counterparty_confirm`
2. `confirmed_deal`
3. `cancelled`
4. `failed`

当前兼容读取：

1. 旧 `pending_counterparty` 映射为 `pending_counterparty_confirm`
2. 旧 `confirmed` 映射为 `confirmed_deal`

第一轮新写入不得再落旧 `confirmed`。

## 8. 迁移边界

第一轮迁移边界正式冻结如下：

1. 只允许 additive migration
2. 不允许 drop table
3. 不允许 rename table
4. 不允许 drop legacy column
5. 不要求在本轮完成历史数据 backfill
6. 不要求在本轮清理旧 `p0_pay` 代码

第一轮写流切换边界：

1. Writer 切到新逻辑名后，不得继续把旧列当 authority
2. Reader 在 cutover 初期允许双读 legacy 值
3. 双读期结束条件不在本文件放行，必须等后续门禁单独批准

## 9. Day 2 验收结论

当前验收结果：

1. `200 / 4000 / deal confirmation / charge` 的持久化边界已说清楚
2. 复用旧支付基础设施与新业务真相的关系已说清楚
3. migration boundary 已写死为 additive-only
4. 当前没有跳进实现

当前结论：

- `允许进入第 3 天`

原因：

1. persistence 边界已经冻结
2. 当前剩余 blocker 已收缩为 implementation unlock 与 runtime drift
3. 本轮没有新的 L3 persistence veto 悬空
