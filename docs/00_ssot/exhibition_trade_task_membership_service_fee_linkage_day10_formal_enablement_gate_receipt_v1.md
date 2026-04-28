---
title: exhibition_trade_task_membership_service_fee_linkage_day10_formal_enablement_gate_receipt_v1
owner: Codex 总控
status: frozen
layer: L0 Formal Enablement Gate
updated_at: 2026-04-29
purpose: Freeze the Day 10 formal enablement gate judgment for P0-Pay membership-tier service-fee rates after Server/BFF runtime alignment and Day 9 rerun.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md
  - docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md
  - docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md
  - docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_persistence_migration_unlock_addendum_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_runtime_alignment_execution_receipt_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_day10a_controlled_sample_receipt_v1.md
---

# P0-Pay 会员分层服务费率 Day 10 正式启用门禁回执 V1

## 0. 总裁决

- 当前是否允许正式启用 `standard -> 2.5%` 最小闭环：`Go for authorization snapshot`
- 当前是否允许正式启用 `2.5% / 2.0% / 1.5%` 全量会员分层：`Go for authorization snapshot`
- 当前推荐执行路径：`进入全量正式启用门禁复核，支付初始化与扣款仍单独门禁`
- 当前是否需要回滚云端 runtime alignment：`No`
- 当前是否允许 authorize-init / payment callback / 真实扣款 / 合同确认扣费：`No-Go unless separately unlocked`
- 下一轮唯一动作：进入全量正式启用门禁复核，裁决是否正式启用会员分层服务费率的 authorization snapshot 链路；支付初始化、真实扣款和合同确认扣费仍不得自动放行。

核心原因：

1. `standard -> 2.5%` 已完成云端 runtime 证据闭环。
2. Day 10A 已补齐 `professional / ka / flagship` runtime 样本。
3. 当前 active paid membership tier 只有 1 条 `standard` 测试记录，Day 10A 高阶测试记录均已置为过期。
4. authorization snapshot 链路已经具备全量分层证据；真实支付和合同扣费仍需单独门禁。

## 1. Day 10 门禁证据

| 门禁项 | 结果 | 证据 |
|---|---|---|
| Server active runtime | Pass | `/srv/releases/server/20260429013340-membership-fee-runtime-alignment` |
| BFF active runtime | Pass | `/srv/releases/bff/20260429013340-membership-fee-runtime-alignment/apps/bff` |
| systemd active | Pass | `exhibition-server = active`，`exhibition-bff = active` |
| migration | Pass | `20260505_p0_pay_membership_fee_snapshot_truth` 已落库 |
| Server tests | Pass | 12/12 |
| BFF tests | Pass | 8/8 |
| Flutter analyze | Pass | P0-Pay 相关 4 项无问题 |
| Flutter widget tests | Pass | `p0_pay_flutter_consumption_test.dart` 7/7 |
| Flutter fixed 3% 文案 | Pass | P0-Pay 提交页目标路径未发现用户可见 `成交金额的 3%` |
| `standard -> 2.5%` runtime | Pass | authorization `f6f6c17a-e307-4365-8c90-128f0f9d611b` |
| `professional -> 2.0%` runtime | Pass | authorization `4d937b2d-9c3d-4bdc-bfe5-2c631a22b917` |
| `ka -> 1.5%` runtime | Pass | authorization `7741424d-fd33-4abb-aa7b-9fc86b662739` |
| `flagship -> 1.5%` runtime | Pass | authorization `66bc7f72-d869-4f8e-84e5-f67fc671e41f` |
| 支付安全 | Pass | payment order / transaction / charge 均为 0 |

## 2. Runtime 费率样本覆盖

| tier | 目标费率 | runtime 样本 | 当前结论 |
|---|---:|---:|---|
| none / free_certified | `3.0%` | legacy / fallback 规则存在，但本轮未新增样本 | 保留，非本轮启用重点 |
| standard | `2.5%` | 有 | Pass |
| professional | `2.0%` | 有 | Pass |
| ka | `1.5%` | 有 | Pass |
| flagship | `1.5%` | 有 | Pass |

## 3. 当前云端会员暴露面

云端当前有效 paid membership tier 分布：

| tier | 有效记录数 | 说明 |
|---|---:|---|
| standard | 1 | Day 9 受控测试记录 |
| professional | 0 | Day 10A 临时样本已过期 |
| ka | 0 | Day 10A 临时样本已过期 |
| flagship | 0 | Day 10A 临时样本已过期 |

当前 Day 9 测试记录：

| 字段 | 值 |
|---|---|
| id | `day9-standard-bdfb4523-20260429` |
| organization_id | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |
| tier_code | `standard` |
| source_type | `controlled_runtime_test` |
| source_ref | `p0-pay-membership-rate-day9-20260429` |
| expires_at | `2026-05-06 01:15:54.530411+08` |

## 4. 两条路径裁决

| 路径 | 裁决 | 原因 |
|---|---|---|
| A. 先启用 `standard -> 2.5%` 最小闭环 | `Go` | 已有 runtime 证据，但已不再是推荐路径 |
| B. 启用全量 `2.5% / 2.0% / 1.5%` authorization snapshot | `Recommended / Go` | Day 10A 已补齐样本；支付初始化与扣款仍单独门禁 |

### B 路径限制

全量启用仅指：

1. 竞标提交时的 fee requirement。
2. service-fee authorization snapshot 创建。
3. BFF / Flutter 只读展示。

不自动包含：

1. `authorize-init`。
2. payment callback。
3. 真实扣款。
4. 合同确认最终服务费扣取。

## 5. 四类判断

| 判断 | 结论 | 说明 |
|---|---|---|
| 哪个更稳 | B 路径 | Day 10A 已补齐每档 runtime 样本，证据链完整 |
| 哪个更省成本 | B 路径 | 现在样本已完成，再拆 standard-only 反而增加运营门禁 |
| 哪个更适合当前阶段 | B 路径 | 只启用 authorization snapshot 链路，不放开支付扣款 |
| 哪个风险更大 | 同时放开支付扣款 | 支付初始化与合同扣费尚未按全量会员分层做受控验证 |

## 6. 当前最小闭环

- Server 读取工厂组织 paid membership tier。
- Server 生成 `standard -> 2.5%` fee requirement。
- Server 保存 authorization fee snapshot。
- BFF 只读投影 fee snapshot。
- Flutter 消费 BFF 返回值，不本地计算正式费率。
- 支付初始化仍未触发。

## 7. 需要保留但暂不开通

- 支付初始化。
- 合同确认扣费云端受控验证。
- 支付通道动态费率正式扣款验证。

## 8. 后续扩展位

- 会员升级后不影响已锁定订单。
- 会员过期回退 `3.0%`。
- 合同确认按锁定费率乘最终成交金额。
- 费率后台配置。
- 单笔封顶和活动费率。

## 9. 下一轮唯一动作

进入全量正式启用门禁复核：

- 可正式启用 `2.5% / 2.0% / 1.5%` 的 authorization snapshot 链路。
- 支付初始化、真实扣款、合同确认扣费仍需单独门禁。
