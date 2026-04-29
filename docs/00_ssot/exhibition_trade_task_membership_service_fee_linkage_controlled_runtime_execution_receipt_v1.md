---
title: exhibition_trade_task_membership_service_fee_linkage_controlled_runtime_execution_receipt_v1
owner: Codex 总控
status: receipt
layer: L0 Controlled Runtime Execution Receipt
updated_at: 2026-04-29
purpose: Record controlled runtime evidence for P0-Pay membership-tier service-fee authorize-init, signed callback, duplicate callback, failure callback, and final charge without opening real external payment.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_controlled_runtime_execution_plan_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_server_gate_test_supplement_receipt_v1.md
---

# P0-Pay 会员费率受控 Runtime 样本执行回执 V1

## 0. 总裁决

- 本轮受控 runtime 样本：`Pass`
- 是否触发真实外部支付：`No`
- 是否允许据此直接全量放开真实支付：`No-Go`
- 当前允许进入下一步：`Go for 合同确认最终扣费 + 支付初始化/回调门禁收口报告`
- 核心结论：云端 runtime 已验证 `standard -> 2.5%` 的 authorize-init、success callback、duplicate callback、final charge 均复用 locked authorization snapshot；`professional -> 2.0%` 的 failure callback 不改写 locked snapshot。

## 1. 执行边界

| 项目 | 本轮执行 |
|---|---|
| 执行通道 | `other` controlled channel |
| 真实外部支付 | 未触发 |
| Alipay / WeChat | 未调用 |
| 新增会员购买 / 续费 / 账单 | 未做 |
| Server / BFF 代码修改 | 未做 |
| Flutter 修改 | 未做 |
| 数据写入 | 仅限受控样本的 authorize-init、callback、award、contract confirmation、charge |

## 2. 云端只读前置核查

| 核查项 | 结果 |
|---|---|
| Server active release | `/srv/releases/server/20260429013340-membership-fee-runtime-alignment` |
| BFF active release | `/srv/releases/bff/20260429013340-membership-fee-runtime-alignment/apps/bff` |
| callback secret | present，长度已核验，未打印原文 |
| migration 字段 | authorization / charge 均已有 `fee_rate_source`、`membership_tier_snapshot`、`fee_rate_rule_version`、`fee_rate_snapshot_hash`、`fee_calculated_at` |
| 样本策略 | 复用已有 pending authorization，避免重造样本 |

## 3. 受控样本

| 用途 | tier | taskId | bidId | authorizationId | 初始状态 |
|---|---|---|---|---|---|
| success + duplicate + final charge | `standard` | `4faacb53-2431-4eac-9635-4177ca2c6a1c` | `4a6c2ba8-86ca-4c80-bb7c-ac84f572bc01` | `f6f6c17a-e307-4365-8c90-128f0f9d611b` | `pending_authorization` |
| failure callback | `professional` | `5beb03bf-9489-4892-a641-23ec60f395ff` | `d5ea6087-ad39-47a0-9547-aafbc07dac65` | `4d937b2d-9c3d-4bdc-bfe5-2c631a22b917` | `pending_authorization` |

## 4. Callback 取证

| 场景 | callbackEventId | channel | eventType | eventStatus | verification | applyStatus | 结果 |
|---|---|---|---|---|---|---|---|
| success | `c73b51d8-4d14-456f-b6c9-210c738e6a32` | `other` | `payment_succeeded` | `succeeded` | `verified` | `applied` | authorization 进入 `authorized` |
| duplicate | `c73b51d8-4d14-456f-b6c9-210c738e6a32` | `other` | `payment_succeeded` | `succeeded` | `verified` | `duplicate` | 不新增业务交易，不改写 snapshot |
| failure | `ffd3b6da-f1e1-4952-a1e3-0b2879802680` | `other` | `authorization_failed` | `failed` | `verified` | `applied` | authorization 进入 `failed` |

## 5. Locked Snapshot 核对

| authorizationId | 最终状态 | feeRate | label | source | tier | ruleVersion | snapshotHash |
|---|---|---:|---|---|---|---|---|
| `f6f6c17a-e307-4365-8c90-128f0f9d611b` | `charged` | `0.025000` | `标准会员 2.5%` | `paid_membership_tier` | `standard` | `p0_pay_membership_service_fee_v1` | `43ed2d30c0edc68b8bf8acfed38dcf674eb99ece725901fd27c902c94b8be6bf` |
| `4d937b2d-9c3d-4bdc-bfe5-2c631a22b917` | `failed` | `0.020000` | `专业会员 2.0%` | `paid_membership_tier` | `professional` | `p0_pay_membership_service_fee_v1` | `b246b7fa3f1323cdfbf24b4136f81aa9d6e1d09e16142e7c07206cefb0b58fcc` |

结论：

- success callback 未改写 `standard` locked fee snapshot。
- duplicate callback 未生成第二条 callback event，返回 duplicate，不改写 locked fee snapshot。
- failure callback 未改写 `professional` locked fee snapshot。

## 6. Final Charge 取证

| 项目 | 值 |
|---|---|
| chargeId | `f1abae3f-9f7c-44a9-894a-76c210c85577` |
| contractConfirmationId | `a591e3db-3961-4d14-8c94-e05cecd988a3` |
| finalConfirmedAmount | `120000.00` |
| locked feeRate | `0.025000` |
| expected finalFeeAmount | `3000.00` |
| actual finalFeeAmount | `3000.00` |
| chargeStatus | `charged` |
| charge payment channel | `other` |
| charge payment order status | `succeeded` |
| charge transaction action | `server_capture` |

结论：

- final charge 使用 locked authorization feeRate。
- charge 侧 `feeRate / feeRateLabel / feeRateSource / membershipTierSnapshot / feeRateRuleVersion / feeRateSnapshotHash` 与 authorization 侧一致。
- finalFeeAmount = `120000.00 * 0.025000 = 3000.00`。

## 7. Payment Safety

| 核查项 | 结果 |
|---|---|
| authorization success payment order | `other / succeeded / 2500.00` |
| authorization failure payment order | `other / failed / 2000.00` |
| final charge payment order | `other / succeeded / 3000.00` |
| external `alipay` / `wechat` order count | `0` |

## 8. Stop Rule 核查

| Stop 条件 | 本轮结果 |
|---|---|
| active runtime 不是会员费率对齐 release | 未触发 |
| migration 字段缺失 | 未触发 |
| callback secret 不可取证 | 未触发 |
| `other` 通道不可用或会触发真实支付 | 未触发 |
| authorization snapshot 不是会员分层字段 | 未触发 |
| callback 后 feeRate / tier / rule hash 被改写 | 未触发 |
| charge 金额不等于 finalConfirmedAmount x locked feeRate | 未触发 |
| 出现真实外部渠道扣款证据 | 未触发 |

## 9. 已知非阻塞事项

- 本轮执行脚本末尾曾用不存在的 `payment_callback_events.created_at` 字段做回读排序，导致第一次回读命令失败；后续已按实体真实字段 `received_at` 重新只读核查，业务执行和门禁结果不受影响。
- 本轮只做受控样本，不代表真实外部支付通道已经允许全量放开。

## 10. 下一轮唯一动作

输出《合同确认最终扣费 + 支付初始化/回调门禁收口报告》，裁决是否允许进入真实支付灰度；在该收口报告前，仍保持 `No-Go for 全量真实支付`。
