---
title: exhibition_trade_task_membership_service_fee_linkage_day10a_controlled_sample_receipt_v1
owner: Codex 总控
status: frozen
layer: L0 Controlled Runtime Sample Receipt
updated_at: 2026-04-29
purpose: Record Day 10A controlled runtime samples for professional, ka, and flagship P0-Pay membership service-fee snapshots.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day10a_controlled_sample_gate_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day10_formal_enablement_gate_receipt_v1.md
---

# P0-Pay 会员分层服务费率 Day 10A 受控样本回执 V1

## 0. 总裁决

- Day 10A 受控样本补证：`Pass`
- `professional -> 2.0%`：`Pass`
- `ka -> 1.5%`：`Pass`
- `flagship -> 1.5%`：`Pass`
- 支付初始化 / callback / 扣款 / 合同确认扣费：`Not executed`
- 临时高阶会员样本是否保留 active：`No`，已全部置为过期
- 当前是否允许进入全量正式启用门禁复核：`Go`

## 1. Professional 样本

| 项 | 结果 |
|---|---|
| seed id | `day10a-professional-bdfb4523-20260429` |
| taskId | `5beb03bf-9489-4892-a641-23ec60f395ff` |
| bidId | `d5ea6087-ad39-47a0-9547-aafbc07dac65` |
| authorizationId | `4d937b2d-9c3d-4bdc-bfe5-2c631a22b917` |
| feeRate | `0.020000` |
| estimatedFeeAmount | `2000.00` |
| feeRateSource | `paid_membership_tier` |
| membershipTierSnapshot | `professional` |
| feeRateRuleVersion | `p0_pay_membership_service_fee_v1` |
| feeRateSnapshotHash | present |
| authorizationStatus | `pending_authorization` |

## 2. KA 样本

| 项 | 结果 |
|---|---|
| seed id | `day10a-ka-bdfb4523-20260429` |
| taskId | `a541e9ac-1c0f-4224-a399-25c6b8a7f310` |
| bidId | `12d92afa-fdce-40ec-8dcb-e4b2e599c3d0` |
| authorizationId | `7741424d-fd33-4abb-aa7b-9fc86b662739` |
| feeRate | `0.015000` |
| estimatedFeeAmount | `1500.00` |
| feeRateSource | `paid_membership_tier` |
| membershipTierSnapshot | `ka` |
| feeRateRuleVersion | `p0_pay_membership_service_fee_v1` |
| feeRateSnapshotHash | present |
| authorizationStatus | `pending_authorization` |

## 3. Flagship 样本

| 项 | 结果 |
|---|---|
| seed id | `day10a-flagship-bdfb4523-20260429` |
| taskId | `c057f243-5a88-446e-afae-6fe383eb5782` |
| bidId | `9fda33a4-e680-4d7f-8fc8-96c4872e6a28` |
| authorizationId | `66bc7f72-d869-4f8e-84e5-f67fc671e41f` |
| feeRate | `0.015000` |
| estimatedFeeAmount | `1500.00` |
| feeRateSource | `paid_membership_tier` |
| membershipTierSnapshot | `flagship` |
| feeRateRuleVersion | `p0_pay_membership_service_fee_v1` |
| feeRateSnapshotHash | present |
| authorizationStatus | `pending_authorization` |

## 4. 支付安全回读

| 项 | 结果 |
|---|---|
| payment order | `0` |
| payment transaction | `0` |
| platform service fee charge | `0` |
| authorization order id | empty |
| payment order id | empty |

## 5. 临时会员样本收口

| seed | tier | 是否已过期 |
|---|---|---:|
| `day10a-professional-bdfb4523-20260429` | `professional` | 是 |
| `day10a-ka-bdfb4523-20260429` | `ka` | 是 |
| `day10a-flagship-bdfb4523-20260429` | `flagship` | 是 |

当前云端有效 paid membership tier：

| tier | 有效记录数 |
|---|---:|
| standard | 1 |

## 6. 当前最小闭环

Day 10A 已补齐全量会员分层 runtime 样本：

- `standard -> 2.5%`
- `professional -> 2.0%`
- `ka -> 1.5%`
- `flagship -> 1.5%`

这些样本均停在 authorization snapshot，不涉及支付初始化和扣款。

## 7. 需要保留但暂不开通

- 真实支付通道授权。
- 合同确认后最终扣费。
- 会员过期回退样本。
- 预授权后升级不影响本单样本。

## 8. 下一轮唯一动作

进入全量正式启用门禁复核：

- 裁决是否正式启用全量会员分层服务费率的 `authorization snapshot` 链路。
- 支付初始化、真实扣款和合同确认扣费仍需单独门禁。
