---
title: exhibition_trade_task_membership_service_fee_linkage_controlled_runtime_execution_plan_v1
owner: Codex 总控
status: frozen
layer: L0 Controlled Runtime Execution Plan
updated_at: 2026-04-29
purpose: Freeze the controlled runtime sample plan and stop rules for P0-Pay membership-tier service-fee payment init, callback, and final charge verification without opening real external payment.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_contract_charge_payment_gate_package_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_contract_charge_payment_readonly_gap_receipt_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_server_gate_test_supplement_receipt_v1.md
---

# P0-Pay 会员费率受控 Runtime 样本执行单 V1

## 0. 总裁决

- 当前是否允许执行受控 runtime 样本：`Go`
- 当前是否允许真实外部支付：`No-Go`
- 当前是否允许公开生产流量：`No-Go`
- 当前是否允许新增会员购买 / 续费 / 账单：`No-Go`
- 当前样本目标：验证 payment init、signed callback、contract final charge 是否复用 locked authorization snapshot。
- 执行通道：`other / controlled path only`

## 1. 当前最小闭环

- Server 本地门禁测试已经证明 callback 成功、重复、失败路径不改写 fee snapshot。
- Server 本地门禁测试已经证明 `standard / professional / ka / flagship` final charge 使用 locked feeRate。
- 云端 Day 9 / Day 10A 已证明 authorization snapshot 可生成四档费率。

## 2. 本轮只做什么

1. 云端只读核查 active Server / BFF release。
2. 云端只读核查 migration 字段。
3. 云端只读核查 callback secret 是否可用于签名验证。
4. 选择或新建受控样本 task / bid / authorization。
5. 用 `other` 通道执行 `authorize-init`。
6. 用 signed callback 验证 success / duplicate / failure 的受控路径。
7. 进入 contract final charge 受控验证。
8. 查 DB 证明 fee snapshot 未变、金额正确、无真实外部扣款。

## 3. 本轮不做什么

1. 不调用真实 Alipay / WeChat。
2. 不放开公开生产流量。
3. 不新增会员购买、续费、账单、发票、结算。
4. 不改 BFF / Flutter。
5. 不改 Server 业务逻辑。
6. 不绕过 P0-Pay 状态机；如果状态不满足，直接标记 Evidence Missing。

## 4. Stop Rule

任一条件触发即停止：

| Stop 条件 | 处理 |
|---|---|
| active runtime 不是会员费率对齐 release | 停止，不写样本 |
| migration 字段缺失 | 停止，不写样本 |
| callback secret 不可取证 | 停止，不发 callback |
| `other` 通道不可用或会触发真实支付 | 停止，不调用 init |
| authorization snapshot 不是会员分层字段 | 停止，不发 callback |
| callback 后 feeRate / tier / rule hash 被改写 | 停止并标 P0 blocker |
| charge 金额不等于 finalConfirmedAmount x locked feeRate | 停止并标 P0 blocker |
| payment_orders / transactions 出现真实外部渠道扣款证据 | 停止并标 P0 blocker |

## 5. 验收标准

| 验收项 | 标准 |
|---|---|
| payment init | payment order amount = locked authorization estimatedFeeAmount |
| callback success | authorization status 可进入 authorized，fee snapshot 不变 |
| callback duplicate | 不重复交易，不改写 fee snapshot |
| callback failure | 失败路径不改写 fee snapshot |
| final charge | finalFeeAmount = finalConfirmedAmount x locked feeRate |
| charge snapshot | fee source / tier / ruleVersion / snapshotHash 与 authorization 一致 |
| payment safety | 不触发真实外部扣款 |
| auditability | payment order / transaction / charge 可回溯 authorization snapshot |

## 6. 四类判断

| 判断 | 结论 | 原因 |
|---|---|---|
| 哪个更稳 | `other` 受控通道样本 | 不触发真实外部支付 |
| 哪个更省成本 | 复用现有云端 release 与 DB 样本能力 | 不重写支付主线 |
| 哪个更适合当前阶段 | 受控 runtime 取证 | 本地测试已补齐，缺运行时证据 |
| 哪个风险更大 | 直接放开真实支付和合同扣费 | 资金链路缺灰度证据 |

## 7. 下一步

执行云端只读核查：

- active Server / BFF release。
- migration 字段。
- callback secret。
- 样本数据可用性。
