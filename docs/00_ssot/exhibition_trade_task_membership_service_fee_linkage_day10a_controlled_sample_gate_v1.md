---
title: exhibition_trade_task_membership_service_fee_linkage_day10a_controlled_sample_gate_v1
owner: Codex 总控
status: frozen
layer: L0 Controlled Runtime Sample Gate
updated_at: 2026-04-29
purpose: Freeze the Day 10A controlled runtime sample gate for professional and ka/flagship P0-Pay membership service-fee rates.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day10_formal_enablement_gate_receipt_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_runtime_alignment_execution_receipt_v1.md
---

# P0-Pay 会员分层服务费率 Day 10A 受控样本门禁 V1

## 0. 总裁决

- 当前是否允许执行 Day 10A 受控样本补证：`Go`
- 当前是否允许正式启用全量会员分层：`No-Go until Day 10A receipt`
- 当前是否允许支付初始化 / callback / 扣款 / 合同确认扣费：`No-Go`
- 本轮样本范围：`professional -> 2.0%` 与 `ka / flagship -> 1.5%`

## 1. 允许动作

1. 为测试工厂组织 `bdfb4523-aeb7-4b56-89a1-992170fb5d98` 写入短有效期 `professional` 测试会员记录。
2. 创建固定价测试任务、固定价测试竞标、service-fee authorization snapshot。
3. 为同一测试工厂组织写入短有效期 `ka` 或 `flagship` 测试会员记录。
4. 再创建固定价测试任务、固定价测试竞标、service-fee authorization snapshot。
5. 只做 GET / DB 回读验证。

## 2. 禁止动作

1. 禁止调用 `authorize-init`。
2. 禁止触发支付 callback。
3. 禁止创建 payment order。
4. 禁止创建 payment transaction。
5. 禁止创建 platform service fee charge。
6. 禁止合同确认扣费。
7. 禁止正式启用全量会员分层。

## 3. 验收标准

| 样本 | 预期 feeRate | 预期 source | 预期 tier | 预期状态 |
|---|---:|---|---|---|
| professional | `0.020000` | `paid_membership_tier` | `professional` | authorization `pending_authorization` |
| ka / flagship | `0.015000` | `paid_membership_tier` | `ka` 或 `flagship` | authorization `pending_authorization` |

## 4. 停止规则

任一情况发生立即停止，不进入下一步：

1. membership current 未按预期返回测试 tier。
2. bid requirement 未返回预期 feeRate。
3. bid requirement 缺 `feeRateSource / membershipTierSnapshot / feeRateRuleVersion / feeRateSnapshotHash`。
4. authorization 创建后 snapshot 与 bid requirement 不一致。
5. 任一接口提示进入支付通道。

## 5. 下一步

执行 Day 10A 受控样本补证并冻结回执。
