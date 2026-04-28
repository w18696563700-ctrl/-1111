---
title: exhibition_trade_task_membership_service_fee_linkage_runtime_alignment_execution_receipt_v1
owner: Codex 总控
status: frozen
layer: L0 Runtime Alignment Execution Receipt
updated_at: 2026-04-29
purpose: Record the Aliyun Server/BFF runtime alignment deployment and the Day 9 rerun evidence for P0-Pay membership-tier service-fee snapshots.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_runtime_alignment_gate_checklist_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day9_controlled_write_receipt_v1.md
---

# P0-Pay 会员分层服务费率云端 Runtime Alignment 执行回执 V1

## 0. 总裁决

- 云端 Server runtime alignment：`Pass`
- 云端 BFF runtime alignment：`Pass`
- 云端 migration：`Pass`
- Day 9 受控重跑：`Pass for standard tier snapshot`
- 当前是否触发支付初始化：`No`
- 当前是否触发真实支付 / callback / 扣款 / 合同确认扣费：`No`
- 当前是否允许直接正式启用全部会员分层费率：`No-Go until Day 10 formal enablement gate`
- 下一轮唯一动作：进入 Day 10 正式启用门禁核查，裁决是否需要补 `professional / ka / flagship` 受控样本，或将其作为后续扩展位。

## 1. Release 记录

| 项 | 值 |
|---|---|
| Release ID | `20260429013340-membership-fee-runtime-alignment` |
| Server new current | `/srv/releases/server/20260429013340-membership-fee-runtime-alignment` |
| BFF new current | `/srv/releases/bff/20260429013340-membership-fee-runtime-alignment/apps/bff` |
| Server previous current | `/srv/releases/server/20260427205352-quote-basis-material-v1` |
| BFF previous current | `/srv/releases/bff/20260427205352-quote-basis-material-v1/apps/bff` |
| Server rollback record | `/srv/shared/rollback-server-before-20260429013340-membership-fee-runtime-alignment.txt` |
| BFF rollback record | `/srv/shared/rollback-bff-before-20260429013340-membership-fee-runtime-alignment.txt` |

## 2. 本地发布前验证

| 层 | 命令 | 结果 |
|---|---|---|
| Server | `node --test apps/server/test/p0-pay-calculator-idempotency.test.cjs apps/server/test/p0-pay-server-mainline.test.cjs` | Pass，12/12 |
| BFF | `node --test apps/bff/test/exhibition-p0-pay-transport.test.cjs` | Pass，8/8 |
| Server build | `npm run build` in `apps/server` | Pass |
| BFF build | `npm run build` in `apps/bff` | Pass |

## 3. 云端部署核验

| 项 | 结果 |
|---|---|
| `systemctl is-active exhibition-server` | `active` |
| `systemctl is-active exhibition-bff` | `active` |
| Server active policy file | `dist/modules/p0_pay/p0-pay-service-fee-rate.policy.js` present |
| BFF active projection | `membershipTierSnapshot` present in `exhibition-p0-pay.read-model.js` |
| `GET /api/app/project/list` via `127.0.0.1:8080` | 200 |

## 4. Migration 核验

| 项 | 结果 |
|---|---|
| migration key | `20260505_p0_pay_membership_fee_snapshot_truth` |
| `platform_service_fee_authorizations` snapshot columns | `fee_rate_label / fee_rate_source / membership_tier_snapshot / fee_rate_rule_version / fee_rate_snapshot_hash / fee_calculated_at` present |
| `platform_service_fee_charges` snapshot columns | `fee_rate_label / fee_rate_source / membership_tier_snapshot / fee_rate_rule_version / fee_rate_snapshot_hash / fee_calculated_at` present |
| Server log | `applied migration 20260505_p0_pay_membership_fee_snapshot_truth` |

## 5. Day 9 重跑证据

| 项 | 结果 |
|---|---|
| runId | `day9-rerun-1777397945510` |
| 工厂会员回读 | `paidMembershipTier = standard` |
| 测试任务 | `4faacb53-2431-4eac-9635-4177ca2c6a1c` |
| 测试竞标 | `4a6c2ba8-86ca-4c80-bb7c-ac84f572bc01` |
| bid requirement feeRate | `0.025000` |
| bid requirement label | `标准会员 2.5%` |
| bid requirement source | `paid_membership_tier` |
| bid requirement tier | `standard` |
| bid requirement estimatedFeeAmount | `2500.00` |
| bid requirement snapshot hash | present |
| authorization id | `f6f6c17a-e307-4365-8c90-128f0f9d611b` |
| authorization status | `pending_authorization` |
| authorization feeRate | `0.025000` |
| p0-pay-summary publisher/factory | `pending_authorization` with `feeRate = 0.025000`, `membershipTierSnapshot = standard` |

## 6. 支付安全核验

| 禁止项 | 结果 |
|---|---|
| `authorize-init` | 未调用 |
| payment order | 未创建，authorization `payment_order_id` 为空 |
| payment transaction | 未创建 |
| platform service fee charge | 未创建 |
| payment callback | 未触发 |
| contract confirmation charge | 未触发 |

## 7. 当前最小闭环

本轮已经证明：

1. 云端 Server 可以读取工厂组织 `paidMembershipTier = standard`。
2. 云端 Server 可以按 `standard -> 2.5%` 生成 fee requirement。
3. 云端 Server 可以保存 authorization snapshot。
4. 云端 BFF 可以只读投影 fee snapshot。
5. P0-Pay summary 可以向发布方和工厂方展示同一 fee snapshot。

## 8. 需要保留但暂不开通

- `professional -> 2.0%` runtime 样本尚未受控验证。
- `ka / flagship -> 1.5%` runtime 样本尚未受控验证。
- 合同确认最终扣费按锁定费率重算尚未在云端受控验证。
- 正式支付通道仍未触发，仍保持关闭。

## 9. 后续扩展位

- 补 `professional` 和 `ka / flagship` 测试组织样本。
- 补会员过期回退 `3.0%` 样本。
- 补预授权后升级不影响本单样本。
- 补合同确认按锁定费率乘最终成交金额样本。

## 10. 下一轮唯一动作

进入 Day 10 正式启用门禁核查：

- 若目标是只先启用 `standard -> 2.5%` 最小闭环，可进入 Conditional Go 裁决。
- 若目标是一次性正式启用 `2.5% / 2.0% / 1.5%` 全部分层，必须先补 `professional` 与 `ka / flagship` 受控 runtime 样本。
