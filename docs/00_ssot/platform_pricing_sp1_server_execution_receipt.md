---
owner: Codex 总控
status: completed
purpose: >
  Record the SP-1 Server pricing kernel and persistence normalization execution
  result before deciding whether SP-2 Server publish gate implementation may
  start.
layer: L0 SSOT
freeze_date_local: 2026-04-29
version: V1
based_on:
  - docs/00_ssot/platform_pricing_sp1_server_implementation_dispatch_addendum.md
  - docs/02_backend/platform_pricing_persistence_migration_truth_addendum_v1.md
  - docs/02_backend/platform_pricing_audit_truth_addendum_v1.md
---

# 《平台收费规则 SP-1 Server Execution Receipt》

## 0. 结论

SP-1 已完成。

本轮只完成 Server `p0_pay` 收费内核与持久化归一，不进入 SP-2 project publish gate，不进入 SP-3 bid gate，不进入 BFF / Flutter / cloud。

当前结论：

- `Go for SP-2 send gate`

原因：

1. Server build 通过
2. p0_pay 定向测试通过
3. callback 已移除“200 支付成功后自动 publish project”的隐式副作用
4. additive migration 已补齐 SP-1 必要列、状态、business type 与索引
5. 新错误族、audit action、idempotency key 与 resource type 已进入 Server 内核

## 1. 修改文件清单

代码文件：

1. `apps/server/src/modules/p0_pay/p0-pay.state.ts`
2. `apps/server/src/modules/p0_pay/p0-pay.types.ts`
3. `apps/server/src/modules/p0_pay/p0-pay.errors.ts`
4. `apps/server/src/modules/p0_pay/p0-pay.commands.ts`
5. `apps/server/src/modules/p0_pay/p0-pay-command.parser.ts`
6. `apps/server/src/modules/p0_pay/p0-pay-idempotency-record.service.ts`
7. `apps/server/src/modules/p0_pay/p0-pay-callback.service.ts`
8. `apps/server/src/modules/p0_pay/p0-pay-inquiry-deposit.service.ts`
9. `apps/server/src/modules/p0_pay/p0-pay-service-fee.factory.ts`
10. `apps/server/src/modules/p0_pay/p0-pay-service-fee-authorization.service.ts`
11. `apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts`
12. `apps/server/src/modules/p0_pay/p0-pay-state-action.service.ts`
13. `apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts`
14. `apps/server/src/modules/p0_pay/p0-pay.presenter.ts`
15. `apps/server/src/modules/p0_pay/entities/inquiry-quote-deposit.entity.ts`
16. `apps/server/src/modules/p0_pay/entities/platform-service-fee-authorization.entity.ts`
17. `apps/server/src/modules/p0_pay/entities/platform-service-fee-charge.entity.ts`
18. `apps/server/src/core/migrations/migrations.ts`

测试文件：

1. `apps/server/test/p0-pay-server-mainline.test.cjs`
2. `apps/server/test/p0-pay-calculator-idempotency.test.cjs`

新增文件：

1. `docs/00_ssot/platform_pricing_sp1_server_execution_receipt.md`

## 2. 关键改动说明

SP-1 已完成以下归一：

1. `P0_PAY_RULE_VERSION` 切到 `platform_pricing_rules_master_v1`
2. 新增 `PROJECT_AUTHENTICITY_SINCERITY_AMOUNT = 200.00`
3. 新增 `BID_SERVICE_FEE_AUTHORIZATION_QUOTA_AMOUNT = 4000.00`
4. 新增当前收费主线 business type：
   - `project_authenticity_sincerity_payment`
   - `project_authenticity_sincerity_refund`
   - `bid_service_fee_authorization_freeze`
   - `bid_service_fee_authorization_release`
   - `platform_service_fee_charge`
5. 新增当前收费主线状态兼容映射：
   - `pending_authorization -> pending_freeze`
   - `authorized -> frozen`
   - `authorization_released -> released`
   - `pending_contract_confirm -> charge_pending`
   - `confirmed -> confirmed_deal`
   - `deducted / dispute_hold -> withheld`
6. 新增对象级错误族：
   - `PROJECT_AUTHENTICITY_SINCERITY_*`
   - `BID_SERVICE_FEE_AUTHORIZATION_*`
   - `DEAL_CONFIRMATION_*`
   - `PRICING_RULE_VERSION_MISMATCH`
7. 新增 canonical audit action set 与 idempotency operation/resource constants
8. `payment callback` 成功后只推进 pricing object 状态，不再修改 `ProjectEntity.state / publishedAt`

## 3. Migration / Entity

新增 migration：

- `20260604_platform_pricing_sp1_kernel_normalization`

新增列：

1. `inquiry_quote_deposits.withheld_at`
2. `inquiry_quote_deposits.withhold_reason_code`
3. `platform_service_fee_authorizations.bid_participation_request_id`
4. `platform_service_fee_authorizations.bidder_organization_id`
5. `platform_service_fee_authorizations.authorization_quota_amount`
6. `platform_service_fee_authorizations.charged_amount_used`
7. `platform_service_fee_authorizations.released_amount`
8. `platform_service_fee_authorizations.frozen_at`
9. `platform_service_fee_charges.base_fee_amount`
10. `platform_service_fee_charges.membership_discount_rate`
11. `platform_service_fee_charges.cap_amount`
12. `platform_service_fee_charges.released_remainder_amount`

新增索引：

1. `idx_platform_service_fee_auth_bid_participation_request`
2. `idx_platform_service_fee_auth_project_bidder`
3. `idx_platform_service_fee_auth_one_active_project_bidder`

本轮未做：

1. 未 drop table
2. 未 drop legacy column
3. 未 rename table / column
4. 未做云端历史数据 full backfill

## 4. 边界确认

本轮未触达：

1. `apps/server/src/modules/project/project-write.service.ts`
2. `apps/server/src/modules/bid/**`
3. `apps/server/src/modules/bid_participation_request/**`
4. `apps/bff/**`
5. `apps/mobile/**`
6. 阿里云环境
7. deploy / restart / rollback
8. 隧道联调

说明：

- 本轮仅在 `p0_pay` 内部改动涉及旧 contract confirmation / release helper 的收费词表归一
- `project publish 200 gate` 尚未接入，属于 SP-2
- `bid submit 4000 gate` 尚未接入，属于 SP-3
- 阶梯费率与成交后扣费治理尚未完整替换，属于 SP-4
- BFF / Flutter surface 尚未进入本轮

## 5. 验证结果

已执行：

```bash
cd apps/server
npm run build
```

结果：

- passed

已执行：

```bash
cd apps/server
node --test test/p0-pay-server-mainline.test.cjs test/p0-pay-calculator-idempotency.test.cjs
```

结果：

- tests: 14
- pass: 14
- fail: 0

## 6. SP-2 放行判断

SP-1 当前满足进入 SP-2 send gate 的最小条件。

允许进入：

- `SP-2 Server 发布 200 gate` 的阶段门禁核查与派工

不允许直接跳过：

1. SP-2 targeted gate checklist
2. SP-2 execution receipt
3. SP-3 bid gate
4. BFF / Flutter / cloud 阶段
