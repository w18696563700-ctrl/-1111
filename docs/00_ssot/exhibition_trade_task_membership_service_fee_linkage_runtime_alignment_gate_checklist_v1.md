---
title: exhibition_trade_task_membership_service_fee_linkage_runtime_alignment_gate_checklist_v1
owner: Codex 总控
status: frozen
layer: L0 Runtime Alignment Gate
updated_at: 2026-04-29
purpose: Freeze the gate checklist for deploying the P0-Pay membership service-fee Server/BFF runtime alignment package to the active Aliyun runtime before rerunning Day 9.
inputs_canonical:
  - docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day9_controlled_write_receipt_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_final_verification_receipt_v1.md
---

# P0-Pay 会员分层服务费率云端 Runtime Alignment 门禁核查表 V1

## 0. 总裁决

- 当前是否允许直接正式启用会员分层费率：`No-Go`
- 当前是否允许进入云端 Server/BFF runtime alignment：`Go`
- 当前是否允许执行必要 migration：`Go`
- 当前是否允许重跑 Day 9 受控联调：`Go after runtime alignment`
- 当前是否允许 authorize-init / 支付 callback / 真实扣款 / 合同确认扣费：`No-Go`

## 1. 已通过门禁

| 门禁 | 结果 | 证据 |
|---|---|---|
| L0 规则冻结 | Pass | `exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md` |
| L2 Contracts 字段冻结 | Pass | `exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md` |
| L3 Server truth 冻结 | Pass | `exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md` |
| Persistence / migration 解锁 | Pass | `exhibition_trade_task_membership_service_fee_linkage_persistence_migration_unlock_addendum_v1.md` |
| 本地 Server 测试 | Pass | `node --test apps/server/test/p0-pay-calculator-idempotency.test.cjs apps/server/test/p0-pay-server-mainline.test.cjs`，12/12 |
| 本地 BFF 测试 | Pass | `node --test apps/bff/test/exhibition-p0-pay-transport.test.cjs`，8/8 |
| 云端 rollback baseline | Pass | `current_cloud_deploy_rollback_procedure_baseline_addendum.md` |
| Day 9 停止规则 | Pass | 已停止在 bid requirement 固定 3% 和缺 snapshot 字段处，未触发支付 |

## 2. 当前阻塞

| blocker | 当前证据 | 处理方式 |
|---|---|---|
| 云端 active Server 未包含 `P0PayServiceFeeRatePolicy` | Day 9 回执记录 active runtime 仍返回 `0.030000` | 部署 Server Day 5 实现 |
| 云端 active BFF 未投影会员费率 snapshot 字段 | Day 9 回执记录 BFF 响应缺 `feeRateSource / membershipTierSnapshot / ruleVersion / snapshotHash` | 部署 BFF Day 6 实现 |
| 云端 DB 缺 snapshot 字段或 migration 未应用 | Day 8-10 回执标记云端 migration 未验证 | Server 启动 migration runner 自动应用，并回读 `server_schema_migration` |

## 3. 本轮允许动作

1. 制备新的 Server release artifact。
2. 制备新的 BFF release artifact。
3. 记录部署前 Server/BFF `current` 指针作为 rollback target。
4. 切换 Server/BFF `current` 指针。
5. 重启 `exhibition-server` 和 `exhibition-bff`。
6. 验证 systemd active、migration key、接口路由和 Day 9 fee snapshot。

## 4. 本轮禁止动作

1. 禁止正式启用会员分层费率。
2. 禁止调用 `authorize-init`。
3. 禁止触发支付 callback。
4. 禁止真实扣款。
5. 禁止合同确认扣费。
6. 禁止清理 Day 9 测试数据，除非单独获得确认。

## 5. 下一步

按 `current_cloud_deploy_rollback_procedure_baseline_addendum.md` 执行云端 release artifact 部署，然后重跑 Day 9 受控联调。
