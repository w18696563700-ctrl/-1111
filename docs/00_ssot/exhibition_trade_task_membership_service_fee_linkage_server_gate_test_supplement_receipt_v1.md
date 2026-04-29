---
title: exhibition_trade_task_membership_service_fee_linkage_server_gate_test_supplement_receipt_v1
owner: Codex 总控
status: frozen
layer: L3 Server Gate Test Receipt
updated_at: 2026-04-29
purpose: Record the Server-only gate test supplement for P0-Pay membership-tier service-fee payment callback and final charge locked snapshot behavior.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_contract_charge_payment_gate_package_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_contract_charge_payment_readonly_gap_receipt_v1.md
  - apps/server/test/p0-pay-calculator-idempotency.test.cjs
  - apps/server/test/p0-pay-server-mainline.test.cjs
---

# P0-Pay 会员费率 Server 门禁测试补证回执 V1

## 0. 总裁决

- 本轮是否修改业务实现：`No`
- 本轮是否触发真实支付：`No`
- 本轮是否新增会员购买 / 续费 / 账单：`No`
- callback 成功 / 重复 / 失败路径不改写 fee snapshot：`Pass by behavior test`
- `standard / professional / ka / flagship` final charge 使用 locked feeRate：`Pass by behavior test`
- Server targeted tests：`Pass, 13/13`
- 下一轮唯一动作：进入只读门禁复核，裁决是否允许受控 runtime 验证 payment callback / final charge；真实外部扣款仍不得自动放行。

## 1. 补证范围

| 项 | 是否完成 | 证据 |
|---|---:|---|
| callback success 不改写 fee snapshot | 是 | `p0-pay-server-mainline.test.cjs` |
| callback duplicate 不改写 fee snapshot | 是 | `p0-pay-server-mainline.test.cjs` |
| callback failure 不改写 fee snapshot | 是 | `p0-pay-server-mainline.test.cjs` |
| final charge standard 2.5% | 是 | `p0-pay-server-mainline.test.cjs` |
| final charge professional 2.0% | 是 | `p0-pay-server-mainline.test.cjs` |
| final charge ka 1.5% | 是 | `p0-pay-server-mainline.test.cjs` |
| final charge flagship 1.5% | 是 | `p0-pay-server-mainline.test.cjs` |
| policy tier mapping ka / flagship | 是 | `p0-pay-calculator-idempotency.test.cjs` |

## 2. 验证命令

```bash
node --test apps/server/test/p0-pay-calculator-idempotency.test.cjs apps/server/test/p0-pay-server-mainline.test.cjs
```

结果：

```text
tests 13
pass 13
fail 0
```

## 3. 当前最小闭环

- Server fee policy 已覆盖 `free_certified / standard / professional / ka / flagship / none`。
- callback 行为测试已证明成功、重复、失败路径不改写 locked authorization fee snapshot。
- contract final charge 行为测试已证明四档会员费率均按 `finalConfirmedAmount * locked feeRate` 计算并复制 snapshot。

## 4. 需要保留但暂不开通

- 真实支付初始化。
- 真实 payment callback runtime。
- 真实合同确认最终扣费 runtime。
- 会员购买、续费、下单、支付和账单闭环。

## 5. 后续扩展位

- 受控 runtime callback 样本。
- 受控 final charge 样本。
- BFF / Flutter 最终扣费展示回归。
- 真实支付沙箱。
- 会员入口 `ka / flagship` 只读说明同步。

## 6. 四类判断

| 判断 | 结论 | 原因 |
|---|---|---|
| 哪个更稳 | 先只读复核再 runtime | 测试补证已经完成，下一步仍需运行时证据 |
| 哪个更省成本 | 不改业务逻辑，只补测试 | 当前逻辑已满足 locked snapshot 口径 |
| 哪个更适合当前阶段 | 受控 runtime 验证 | 不能直接进入真实外部支付 |
| 哪个风险更大 | 直接放开真实 callback / final charge | 资金链路缺运行时样本 |

## 7. 下一轮唯一动作

进入只读门禁复核：

- 汇总本测试补证。
- 判断是否允许在 test-channel / controlled path 下做 payment callback 与 final charge runtime 样本。
- 不触发真实外部扣款。
