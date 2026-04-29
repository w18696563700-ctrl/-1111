---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day 2 audit companion truth for the current platform pricing
  rebaseline, clarifying which audit sink is authoritative for which pricing
  action, which high-risk actions are must-audit, and which legacy P0-Pay
  action names must be retired during implementation.
layer: L3 Backend Truth
freeze_date_local: 2026-04-29
version: V1
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/platform_pricing_rules_master_v1.md
  - docs/01_contracts/platform_pricing_contracts_master_v1.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - apps/server/src/modules/audit/identity-audit-log.entity.ts
  - apps/server/src/modules/audit/project-publish-audit-log.entity.ts
  - apps/server/src/modules/audit/project-publish-audit.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-audit.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-service-fee-authorization.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-inquiry-deposit.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-state-action.service.ts
  - apps/server/src/modules/p0_pay/p0-pay-callback.service.ts
---

# 《平台收费规则 Audit Companion Truth V1》

## 0. 总结论

Day 2 的 audit companion truth 已冻结。

本轮正式选择：

1. 收费主线继续复用现有 `audit_logs` 与 `project_publish_audit_log`
2. 不新建第三套 pricing audit 表
3. 先冻结 canonical action set，再进入实现派工
4. 旧 `P0-Pay` action 名称可以保留在历史数据里，但不得继续作为当前主线对外真相

当前更稳的方案：

- `project` 生命周期继续走 `project_publish_audit_log`，收费 owner 聚合继续走 `audit_logs`

当前更省成本的方案：

- 沿用既有 `P0PayAuditService + ProjectPublishAuditService` 落点，不重开审计基础设施

当前阶段最适合的方案：

- 先把 must-audit 动作、最小字段和旧 action 退场规则写死，再进入 implementation unlock

风险更大的方案：

- 一边改收费主线，一边继续让 `TradeTaskCreated / InquiryDepositOrderCreated / 3%` action 名称漏到新实现里

## 1. 当前最小闭环

当前 audit 最小闭环只覆盖：

1. `ProjectAuthenticitySincerityOrder`
2. `BidServiceFeeAuthorization`
3. `DealConfirmation`
4. `PlatformServiceFeeCharge`
5. `PaymentOrder / PaymentCallbackEvent`
6. `project publish / bid submit` 的收费 gate 拦截

## 2. 需要保留但暂不开通

当前 audit companion truth 必须保留但暂不开通：

1. pricing 专属审计后台
2. finance / settlement / tax 审计视图
3. 单独的 pricing ledger 查询台
4. 云端历史审计数据回补任务

## 3. 后续扩展位

后续扩展位正式保留：

1. 如后续需要结构化 payload，可再讨论给 `audit_logs` 增量补 `payload jsonb`
2. 如后续需要 finance audit 视图，可再派生独立 read model
3. 如后续需要跨业务统一 money-action taxonomy，可在第二轮统一

## 4. 审计落点归属矩阵

| 动作家族 | 当前 canonical sink | 原因 |
|---|---|---|
| `project create/save/submit/publish/withdraw/archive/close` | `project_publish_audit_log` | 当前项目生命周期已有稳定落点 |
| `project publish` 被收费 gate 拦截 | `project_publish_audit_log` | 仍属于项目生命周期拦截事件 |
| `ProjectAuthenticitySincerityOrder` create/pay/refund/withhold | `audit_logs` | 属于收费 owner 聚合 |
| `BidServiceFeeAuthorization` create/freeze/release/hold | `audit_logs` | 属于收费 owner 聚合 |
| `DealConfirmation` submit/confirm | `audit_logs` | 属于收费 owner 聚合 |
| `PlatformServiceFeeCharge` create/charge | `audit_logs` | 属于收费 owner 聚合 |
| `PaymentOrder / PaymentCallbackEvent` 的收费动作 | `audit_logs` | 属于统一支付基础设施的收费链动作 |
| `bid submit` 被收费 gate 拦截 | `audit_logs` | 属于收费 gate 拦截事件 |

## 5. canonical action set

第一轮实现必须采用以下 canonical action 名称。

### 5.1 `project_publish_audit_log`

1. `project_publish_blocked_by_pricing_gate`
2. `project_published`

规则：

1. `project_published` 继续沿用既有项目事件名
2. 若发布成功前经过 `200` gate，`payload` 必须带：
   - `pricingGateApplied`
   - `authenticitySincerityRequired`
   - `authenticitySincerityStatus`
3. 若发布被拦截，`payload` 必须带：
   - `pricingGateApplied`
   - `requiredOrderStatus`
   - `actualOrderStatus`
   - `pricingErrorCode`

### 5.2 `audit_logs`

当前收费主线 canonical action 名称冻结为：

1. `project_authenticity_sincerity_order_created`
2. `project_authenticity_sincerity_pay_init_issued`
3. `project_authenticity_sincerity_paid`
4. `project_authenticity_sincerity_refund_requested`
5. `project_authenticity_sincerity_refunded`
6. `project_authenticity_sincerity_withheld`
7. `bid_service_fee_authorization_created`
8. `bid_service_fee_authorization_freeze_init_issued`
9. `bid_service_fee_authorization_frozen`
10. `bid_service_fee_authorization_release_requested`
11. `bid_service_fee_authorization_released`
12. `bid_submit_blocked_by_pricing_gate`
13. `deal_confirmation_submitted`
14. `deal_confirmation_confirmed`
15. `platform_service_fee_charge_created`
16. `platform_service_fee_charged`
17. `payment_callback_received`
18. `payment_callback_verified`
19. `payment_callback_rejected`

## 6. must-audit 动作与最小字段

### 6.1 `project_publish_audit_log`

以下字段继续强制：

1. `aggregateType`
2. `aggregateId`
3. `eventType`
4. `actorId`
5. `userId`
6. `organizationId`
7. `requestId`
8. `traceId`
9. `payload`
10. `createdAt`

### 6.2 `audit_logs`

以下字段继续强制：

1. `objectType`
2. `objectId`
3. `objectNo`
4. `action`
5. `beforeState`
6. `afterState`
7. `actorId`
8. `actorRole`
9. `reason`
10. `requestId`
11. `traceId`
12. `occurredAt`

当前第一轮因为 `audit_logs` 尚无结构化 `payload` 列，所以 `reason` 至少必须承载当前最小 key set：

1. `projectId`
2. `businessType`
3. `amount` 或 `quotaAmount` 或 `finalFeeAmount`
4. `organizationScope`
5. 相关上游对象 id

严禁把 `reason` 写成纯自然语言废话。

## 7. 高风险动作强制审计

以下动作属于 high-risk action，缺任一审计记录即视为不合格实现：

1. `project_publish_blocked_by_pricing_gate`
2. `project_authenticity_sincerity_paid`
3. `project_authenticity_sincerity_withheld`
4. `bid_service_fee_authorization_frozen`
5. `bid_service_fee_authorization_released`
6. `bid_submit_blocked_by_pricing_gate`
7. `deal_confirmation_confirmed`
8. `platform_service_fee_charged`
9. `payment_callback_verified`
10. `payment_callback_rejected`

## 8. 旧 action 名称退场映射

以下旧 action 名称可保留在历史审计数据里，但第一轮新写入不得继续使用：

| 旧 action | 当前替代 action |
|---|---|
| `InquiryDepositOrderCreated` | `project_authenticity_sincerity_order_created` |
| `PaymentChannelInitIssued`（旧 inquiry deposit 语义） | `project_authenticity_sincerity_pay_init_issued` |
| `PlatformServiceFeePreauthorizationCreated` | `bid_service_fee_authorization_created` |
| `PlatformServiceFeePreauthorizationInit` | `bid_service_fee_authorization_freeze_init_issued` |
| `PlatformServiceFeePreauthorizationReleased` | `bid_service_fee_authorization_released` |
| `PlatformServiceFeeAuthorizationMovedToContractPending` | `deal_confirmation_submitted` 或 `platform_service_fee_charge_created` |
| `ContractConfirmationSubmitted` | `deal_confirmation_submitted` |
| `PlatformServiceFeeCharged` | `platform_service_fee_charged` |
| `TradeTaskCreated` | 直接退场，不得映射回当前主线 |
| `InquiryTaskPublishedAfterDepositPaid` | 直接退场；项目发布应回到 `project_published` + pricing payload |

## 9. objectType 归一化

第一轮实现必须使用以下 canonical `objectType`：

1. `project_authenticity_sincerity_order`
2. `bid_service_fee_authorization`
3. `deal_confirmation`
4. `platform_service_fee_charge`
5. `payment_order`
6. `payment_callback_event`
7. `project`

第一轮新写入不得继续写：

1. `trade_task`
2. `inquiry_quote_deposit`
3. 裸 `platform_service_fee_authorization` 旧业务语义名

说明：

- 物理表名可以暂时保留旧名
- 审计 objectType 不再保留旧业务语义名

## 10. Day 2 验收结论

当前验收结果：

1. audit 落点归属已经说清楚
2. must-audit 动作已经列清楚
3. high-risk action 清单已经列清楚
4. 旧 action 名称退场规则已经写死
5. 当前没有跳进实现

当前结论：

- `允许进入第 3 天`

原因：

1. audit 边界已经冻结
2. 当前剩余 blocker 已收缩为 implementation unlock 与 runtime drift
3. 本轮没有新的 L3 audit veto 悬空
