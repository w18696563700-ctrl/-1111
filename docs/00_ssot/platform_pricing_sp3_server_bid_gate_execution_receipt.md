---
owner: Codex 总控
status: completed
purpose: >
  Record the SP-3 Server bid 4000-gate implementation result before deciding
  whether SP-4 deal confirmation, charging, and exit governance implementation
  may start.
layer: L0 SSOT
freeze_date_local: 2026-04-29
version: V1
based_on:
  - docs/00_ssot/platform_pricing_sp2_server_publish_gate_execution_receipt.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/02_backend/platform_pricing_audit_truth_addendum_v1.md
---

# 《平台收费规则 SP-3 Server Bid Gate Execution Receipt》

## 0. 结论

SP-3 已完成。

当前结论：

- `Go for SP-4 send gate`

原因：

1. `bid submit` 已接入 `4000 元竞标服务费预授权额度` frozen gate
2. 缺少 approved participation 仍由既有准入 gate fail-closed
3. 缺少 `frozen + 4000.00` 授权时，bid submit fail-closed
4. fail-closed 会写 `bid_submit_blocked_by_pricing_gate` 审计
5. 缺 4000 时不会校验附件、不会写 bid、不会创建消息 seed
6. 本轮没有隐式创建授权，没有隐式冻结，没有调用 BFF / Flutter / cloud

## 1. 修改文件清单

代码文件：

1. `apps/server/src/modules/bid/bid-write.service.ts`
2. `apps/server/src/modules/bid/bid.module.ts`

测试文件：

1. `apps/server/test/bid-submit.test.cjs`

新增文件：

1. `docs/00_ssot/platform_pricing_sp3_server_bid_gate_execution_receipt.md`

## 2. 关键改动说明

`BidWriteService.submitBid` 在通过参与竞标申请后新增 `requireFrozenPricingGate`：

1. 读取 `PlatformServiceFeeAuthorizationEntity`
2. 只接受：
   - `taskId = project.id`
   - `bidderOrganizationId` 或兼容 `factoryOrganizationId = current organization`
   - `status = frozen`
   - `authorizationQuotaAmount = 4000.00`
3. 找不到合格授权时：
   - 不校验附件
   - 不写 bid
   - 不创建 message seed
   - 写 `bid_submit_blocked_by_pricing_gate`
   - 抛出 `BID_SERVICE_FEE_AUTHORIZATION_REQUIRED`
4. 找到合格授权后才允许继续提交 bid
5. `BidSubmitted` audit reason 带：
   - `authorizationId`
   - `quotaAmount`

## 3. 边界确认

本轮未触达：

1. `apps/server/src/modules/bff/**`
2. `apps/bff/**`
3. `apps/mobile/**`
4. 阿里云环境
5. deploy / restart / rollback
6. 隧道联调

本轮未做：

1. 未实现成交确认的阶梯计费
2. 未实现成交后扣费与剩余额度释放
3. 未改 BFF route
4. 未改 Flutter 消费
5. 未做云端验真

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
node --test test/bid-submit.test.cjs test/bid-participation-request-phase1.test.cjs test/p0-pay-server-mainline.test.cjs test/p0-pay-calculator-idempotency.test.cjs
```

结果：

- tests: 27
- pass: 27
- fail: 0

## 5. SP-4 放行判断

SP-3 当前满足进入 SP-4 send gate 的最小条件。

允许进入：

- `SP-4 Server 成交、扣费、退出治理` 的阶段门禁核查与派工

不允许直接跳过：

1. SP-4 execution receipt
2. SP-5 Server surface / message carry
3. BFF / Flutter / cloud 阶段
