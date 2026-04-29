---
owner: Codex 总控
status: completed
purpose: >
  Record the SP-2 Server project publish 200-gate implementation result before
  deciding whether SP-3 Server bid 4000-gate implementation may start.
layer: L0 SSOT
freeze_date_local: 2026-04-29
version: V1
based_on:
  - docs/00_ssot/platform_pricing_sp1_server_execution_receipt.md
  - docs/02_backend/platform_pricing_backend_truth_master_v1.md
  - docs/02_backend/platform_pricing_audit_truth_addendum_v1.md
---

# 《平台收费规则 SP-2 Server Publish Gate Execution Receipt》

## 0. 结论

SP-2 已完成。

当前结论：

- `Go for SP-3 send gate`

原因：

1. `project publish` 已接入 `200 元项目真实性诚意金` paid gate
2. publish 缺少 `paid` 订单时 fail-closed
3. fail-closed 会写 `project_publish_blocked_by_pricing_gate` 审计
4. publish 成功审计 payload 已带 pricing gate 字段
5. 本轮没有隐式创建 200 订单，没有代扣，没有绕过 callback

## 1. 修改文件清单

代码文件：

1. `apps/server/src/modules/project/project-write.service.ts`
2. `apps/server/src/modules/project/project.module.ts`

测试文件：

1. `apps/server/test/project-lifecycle.test.cjs`

新增文件：

1. `docs/00_ssot/platform_pricing_sp2_server_publish_gate_execution_receipt.md`

## 2. 关键改动说明

`ProjectWriteService.publishProject` 在进入 `published` 前新增 `requirePaidPricingGate`：

1. 读取 `InquiryQuoteDepositEntity`
2. 只接受：
   - `taskId = project.id`
   - `publisherOrganizationId = project.organizationId`
   - `status = paid`
3. 找不到 paid 订单时：
   - 不修改 project state
   - 不写 publishedAt
   - 写 `project_publish_blocked_by_pricing_gate`
   - 抛出 `PROJECT_AUTHENTICITY_SINCERITY_REQUIRED`
4. 找到 paid 订单后才允许发布
5. 发布成功 audit payload 带：
   - `pricingGateApplied`
   - `authenticitySincerityRequired`
   - `authenticitySincerityStatus`

## 3. 边界确认

本轮未触达：

1. `apps/server/src/modules/bid/**`
2. `apps/server/src/modules/bid_participation_request/**`
3. `apps/bff/**`
4. `apps/mobile/**`
5. 阿里云环境
6. deploy / restart / rollback
7. 隧道联调

本轮未做：

1. 未创建 200 订单
2. 未代扣 200
3. 未修改 callback
4. 未实现 4000 bid gate
5. 未实现成交扣费

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
node --test test/project-lifecycle.test.cjs test/project-publish-eligibility.test.cjs test/p0-pay-server-mainline.test.cjs test/p0-pay-calculator-idempotency.test.cjs
```

结果：

- tests: 42
- pass: 42
- fail: 0

## 5. SP-3 放行判断

SP-2 当前满足进入 SP-3 send gate 的最小条件。

允许进入：

- `SP-3 Server 4000 bid gate` 的阶段门禁核查与派工

不允许直接跳过：

1. SP-3 execution receipt
2. SP-4 成交扣费治理
3. BFF / Flutter / cloud 阶段
