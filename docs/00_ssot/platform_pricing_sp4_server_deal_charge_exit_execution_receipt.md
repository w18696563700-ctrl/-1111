---
owner: Codex 总控
status: completed
purpose: >
  Record the SP-4 Server deal confirmation, service fee charge, and exit
  governance implementation result before deciding whether SP-5 Server surface
  and message carry implementation may start.
layer: L0 SSOT
freeze_date_local: 2026-04-29
version: V1
based_on:
  - docs/00_ssot/platform_pricing_sp3_server_bid_gate_execution_receipt.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
---

# 《平台收费规则 SP-4 Server Deal / Charge / Exit Execution Receipt》

## 0. 结论

SP-4 已完成。

当前结论：

- `Go for SP-5 send gate`

原因：

1. 成交扣费已从旧 `quoteAmount * feeRate` 切到成交金额阶梯计费
2. 会员折扣只作用于最终平台服务费
3. `finalFeeAmount` 被 cap 限制，且不超过 `4000`
4. `confirmed_deal` 前不会创建平台服务费 charge
5. charge 会记录 base fee、discount、cap、final fee、released remainder
6. 项目退出治理已兼容新授权状态 `pending_freeze / released`

## 1. 修改文件清单

代码文件：

1. `apps/server/src/modules/p0_pay/p0-pay-service-fee-rate.policy.ts`
2. `apps/server/src/modules/p0_pay/p0-pay-contract-confirmation.service.ts`
3. `apps/server/src/modules/project/project-exit-governance.service.ts`
4. `apps/server/src/modules/project/project-exit-governance.support.ts`

测试文件：

1. `apps/server/test/p0-pay-server-mainline.test.cjs`
2. `apps/server/test/p0-pay-calculator-idempotency.test.cjs`

新增文件：

1. `docs/00_ssot/platform_pricing_sp4_server_deal_charge_exit_execution_receipt.md`

## 2. 关键改动说明

新增 `calculateDealServiceFee`：

1. `10000` 以下固定 `200`
2. `10000 - 30000` 超出部分 `2%`
3. `30000 - 100000` 超出部分 `1.5%`
4. `100000` 以上超出部分 `1%`
5. base fee cap `4000`
6. standard 会员 `0.9` 折，cap `3600`
7. professional 会员 `0.8` 折，cap `3200`
8. 其他当前按 `1.0`，cap `4000`

`P0PayContractConfirmationService.ensureCharge`：

1. 只允许 `confirmed_deal / confirmed` 后 charge
2. charge 写入：
   - `baseFeeAmount`
   - `membershipDiscountRate`
   - `capAmount`
   - `finalFeeAmount`
   - `releasedRemainderAmount`
3. authorization 写入：
   - `chargedAmountUsed`
   - `releasedAmount`
   - `status = charged`

退出治理：

1. `TERMINAL_AUTHORIZATION_STATES` 增加 `released / refunded`
2. 未初始化授权可取消状态增加 `pending_freeze`
3. 旧错误文案中的 `P0-Pay release chain` 已改为新授权释放语义

## 3. 边界确认

本轮未触达：

1. `apps/bff/**`
2. `apps/mobile/**`
3. 阿里云环境
4. deploy / restart / rollback
5. 隧道联调

本轮未做：

1. 未改 BFF route / presenter
2. 未改 Flutter consumer
3. 未做 message carry surface 切换
4. 未做云端验真

## 4. 验证结果

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
node --test test/p0-pay-server-mainline.test.cjs test/p0-pay-calculator-idempotency.test.cjs test/project-lifecycle-correction.test.cjs
```

结果：

- tests: 26
- pass: 26
- fail: 0

## 5. SP-5 放行判断

SP-4 当前满足进入 SP-5 send gate 的最小条件。

允许进入：

- `SP-5 Server surface 与 message carry` 的阶段门禁核查与派工

不允许直接跳过：

1. SP-5 execution receipt
2. BFF route implementation
3. Flutter implementation
4. cloud validation
