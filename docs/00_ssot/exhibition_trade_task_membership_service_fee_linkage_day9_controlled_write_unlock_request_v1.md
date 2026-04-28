---
title: exhibition_trade_task_membership_service_fee_linkage_day9_controlled_write_unlock_request_v1
owner: Codex 总控
status: frozen
layer: L0 Controlled Runtime Unlock Request
updated_at: 2026-04-29
purpose: Freeze the exact Day 9 controlled cloud-write package required to verify P0-Pay membership-tier service-fee authorization snapshots without triggering payment.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_final_verification_receipt_v1.md
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md
  - docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md
  - docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md
---

# P0-Pay 会员分层服务费率 Day 9 受控写入解锁申请 V1

## 0. 总裁决

- 当前是否允许直接执行云端写入：`No-Go until user action-time confirmation`
- 当前是否允许准备 Day 9 最小受控写入包：`Go`
- 当前是否允许触发真实支付 / authorize-init / callback / 扣款：`No-Go`
- 当前是否允许正式启用会员分层费率：`No-Go`
- 下一步唯一动作：等待总控对本文件第 4 节的具体云端写动作作 action-time 确认。

## 1. Day 8 缺口复核

| 缺口 | 当前证据 | 影响 |
|---|---|---|
| 两个测试账号无会员等级 | `paidMembershipTier = null` | 无法只读验证 2.5% / 2.0% / 1.5% |
| 当前 P0-Pay summary 无授权快照 | `platformServiceFee.status = not_required` | 无 feeRate / tier / snapshot runtime 样本 |
| 云端无 app-facing 会员等级设置接口 | 只发现 `GET /profile/membership/*` | 需要受控 DB seed 或后端测试工具 |
| 不能触发支付 | Day 9 明确禁止真实支付扣款 | 必须停在 authorization snapshot，不调用 authorize-init |

## 2. 可用测试主体

| 用途 | 账号 | 当前组织 | 当前只读结果 |
|---|---|---|---|
| Publisher candidate | `18696563700` | `e6bf4567-016e-45f9-9420-9c950237690e` | `organizationType=both`，`roleKeys=["buyer_admin"]`，可登录 |
| Factory candidate | `18676681020` | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` | `organizationType=both`，`roleKeys=["supplier_admin"]`，可登录 |

## 3. 推荐最小闭环

本轮只验证 `standard -> 2.5%` 一档。

原因：

1. 当前两个测试账号都没有 paid membership tier。
2. 只需要证明 P0-Pay Server 是否会读取 factory organization membership，并写入 authorization snapshot。
3. 三档全测属于后续扩展位，不适合在首次云端写入门禁里一次性放大。

## 4. 需要 action-time 确认的云端写动作

确认后才允许执行以下动作：

1. 在云端 `organization_paid_memberships` 为工厂组织 `bdfb4523-aeb7-4b56-89a1-992170fb5d98` 写入一条临时测试会员记录：
   - `tier_code = standard`
   - `source_type = controlled_runtime_test`
   - `source_ref = p0-pay-membership-rate-day9-20260429`
   - `effective_at <= now`
   - `expires_at > now`
2. 用发布方账号 `18696563700` 通过 BFF 创建一个固定价测试任务：
   - `taskType = fixed_price_bid`
   - 项目名称带 `P0Pay会员费率受控测试`
   - 不上传文件，不触发支付
3. 用工厂账号 `18676681020` 对该测试任务提交一个固定价测试竞标：
   - `quoteAmount = 100000`
   - `attachmentFileAssetIds = []`
   - 只用于读取 `platformServiceFeeRequirement`
4. 若竞标响应返回：
   - `feeRate = 0.025`
   - `feeRateSource = paid_membership_tier`
   - `membershipTierSnapshot = standard`
   - `estimatedFeeAmount = 2500.00`
   则创建一条 service-fee authorization 记录，用于验证 authorization snapshot。
5. 只做 GET 回读：
   - `GET service-fee-authorization`
   - `GET p0-pay-summary`

## 5. 明确禁止

本轮即使获得授权，也禁止：

1. 调用 `authorize-init`。
2. 调用支付 callback。
3. 触发真实预授权通道。
4. 触发真实扣款。
5. 做合同确认扣费。
6. 做正式启用。
7. 删除云端数据。清理需要单独确认。

## 6. 中止条件

任一条件发生即停止，不继续创建 authorization：

1. 创建测试任务失败。
2. 竞标提交失败。
3. 竞标响应仍返回固定 `0.03`。
4. 竞标响应缺少 `feeRateSource / membershipTierSnapshot / feeRateRuleVersion / feeRateSnapshotHash`。
5. BFF 返回 route drift / 4xx / 5xx。
6. 任一接口提示会进入支付通道。

## 7. 验收标准

| 验收项 | 通过标准 |
|---|---|
| membership seed | `GET /api/app/profile/membership/current` 对工厂账号返回 `paidMembershipTier=standard` |
| bid requirement | fixed-price bid 响应返回 `feeRate=0.025` |
| fee source | 返回 `feeRateSource=paid_membership_tier` |
| tier snapshot | 返回 `membershipTierSnapshot=standard` |
| authorization snapshot | authorization 回读与 bid requirement 一致 |
| summary projection | p0-pay-summary 透出 fee snapshot |
| payment safety | 未调用 authorize-init，未生成支付通道动作 |

## 8. 后续扩展位

本轮不覆盖：

- `professional -> 2.0%`
- `ka / flagship -> 1.5%`
- 会员过期后回退
- 预授权后升级不影响本单
- 合同确认按锁定费率重算最终金额
- 数据清理

这些必须在 Day 9 首个受控闭环通过后再分轮执行。
