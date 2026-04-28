---
title: exhibition_trade_task_membership_service_fee_linkage_persistence_migration_unlock_addendum_v1
owner: Codex 总控
status: frozen
layer: L3 Persistence / Migration Unlock
updated_at: 2026-04-28
purpose: Freeze the persistence and migration plan for P0-Pay membership-tier service-fee snapshots, and unlock bounded local Server/BFF implementation without cloud runtime enablement.
inputs_canonical:
  - docs/00_ssot/exhibition_trade_task_membership_service_fee_linkage_freeze_v1.md
  - docs/01_contracts/exhibition_trade_task_membership_service_fee_linkage_contracts_addendum_v1.md
  - docs/02_backend/exhibition_trade_task_membership_service_fee_linkage_server_truth_addendum_v1.md
  - apps/server/src/modules/p0_pay/entities/platform-service-fee-authorization.entity.ts
  - apps/server/src/modules/p0_pay/entities/platform-service-fee-charge.entity.ts
  - apps/server/src/core/migrations/migrations.ts
---

# P0-Pay 会员分层服务费率联动 L3 Persistence / Migration Unlock Addendum V1

## 0. 总裁决

- 当前是否允许正式启用会员分层服务费率：`No-Go`
- 当前是否允许云端写入、预授权、扣费或 runtime enablement：`No-Go`
- 当前是否允许进入本地 Server bounded implementation：`Go`
- 当前是否允许进入本地 BFF read-model bounded implementation：`Go after Server fields exist`
- 当前是否允许 Flutter implementation：`No-Go in this round`

核心原因：

- L0 已冻结业务规则。
- L2 已冻结 app-facing fee snapshot 字段。
- L3 Server truth 已冻结 Server 作为唯一 fee calculation owner。
- 本文件只解锁本地仓库的最小实现，不代表阿里云运行态已启用。

## 1. 最小持久化字段

### 1.1 Authorization 表

`platform_service_fee_authorizations` 最小新增字段：

| 字段 | 类型 | 默认/兼容 | 说明 |
|---|---|---|---|
| `fee_rate_label` | `varchar(64)` | `默认费率 3.0%` | 展示文案快照，不参与计费 |
| `fee_rate_source` | `varchar(32)` | `legacy_fixed_default` | 新建由 Server 写 `fixed_default` 或 `paid_membership_tier` |
| `membership_tier_snapshot` | `varchar(32)` | `none` | authorization 创建时锁定的组织会员等级 |
| `fee_rate_rule_version` | `varchar(64)` | 旧 P0 rule version | 费率规则版本 |
| `fee_rate_snapshot_hash` | `varchar(128)` | 旧 `rule_snapshot_hash` 回填 | fee snapshot hash |
| `fee_calculated_at` | `timestamptz` | `agreed_at` 或 `created_at` 回填 | 费率计算锁定时间 |

### 1.2 Charge 表

`platform_service_fee_charges` 最小新增字段：

| 字段 | 类型 | 默认/兼容 | 说明 |
|---|---|---|---|
| `fee_rate_label` | `varchar(64)` | `默认费率 3.0%` | 从 authorization 快照复制 |
| `fee_rate_source` | `varchar(32)` | `legacy_fixed_default` | 从 authorization 快照复制 |
| `membership_tier_snapshot` | `varchar(32)` | `none` | 从 authorization 快照复制 |
| `fee_rate_rule_version` | `varchar(64)` | 旧 P0 rule version | 从 authorization 快照复制 |
| `fee_rate_snapshot_hash` | `varchar(128)` | authorization hash 回填 | 从 authorization 快照复制 |
| `fee_calculated_at` | `timestamptz` | authorization `fee_calculated_at` 回填 | 从 authorization 快照复制 |

## 2. Migration Plan

迁移位置：

- `apps/server/src/core/migrations/migrations.ts`
- 注册在 `p0PayMigrations` 内，新增独立 key。

迁移原则：

- 只使用 `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`。
- 旧数据不改费率、不改金额、不改会员等级。
- 旧 `3%` 数据读回为 `legacy_fixed_default / none / 0.030000`。
- 新建 authorization 必须由 Server 写完整 fee snapshot。
- charge 必须复制 authorization 已锁定快照。

## 3. Rollback Plan

低风险回滚路径：

1. 代码回滚到固定 `3%` 逻辑。
2. 保留新增列不删除，避免破坏已写入记录。
3. BFF 可继续忽略新增字段。
4. Flutter 若未进入 L5，不受影响。

需要数据库回滚时，必须单独冻结 destructive migration；本轮不允许 `DROP COLUMN`。

## 4. 旧数据兼容

| 旧数据类型 | 兼容策略 |
|---|---|
| 旧 authorization | `fee_rate_source = legacy_fixed_default`，`membership_tier_snapshot = none` |
| 旧 charge | 通过 authorization 回填 fee snapshot，缺失时仍展示 `legacy_fixed_default` |
| 旧 BFF/Flutter 消费 | 继续读旧 `feeRate / estimatedFeeAmount / finalFeeAmount` |
| 旧合同确认 | 不重新计算历史金额 |

## 5. 实现解锁范围

允许本地实现：

- 新增 `P0PayServiceFeeRatePolicy`。
- `P0PayModule` 导入 `MembershipModule`。
- `MembershipQueryService` 增加组织维度只读 tier snapshot 方法。
- authorization 创建时保存 fee snapshot。
- contract confirmation 创建 charge 时复制 authorization snapshot。
- Server presenter 输出新增 fee fields。
- BFF read-model 只读透传新增 fields。
- 补 Server/BFF 本地测试。

仍然禁止：

- 云端部署。
- 云端写入。
- 真实预授权、扣费、支付通道联调。
- Flutter 改造。
- BFF 计算 feeRate。
- Flutter 计算 feeRate。

## 6. 阶段门禁核查表

| 门禁项 | 结论 | 是否通过 | 说明 |
|---|---|---:|---|
| L0 Rule Freeze | 已完成 | 是 | 当前仍 No-Go for runtime enablement |
| L2 Contracts | 已完成 | 是 | 字段 owner 明确为 Server |
| L3 Server Truth | 已完成 | 是 | 合同确认复用 authorization 锁定费率 |
| Persistence Fields | 本文件完成 | 是 | 字段最小化且旧数据兼容 |
| Rollback | 本文件完成 | 是 | 保留新增列，代码可回滚 |
| Implementation Unlock | 本文件完成 | 是 | 仅本地 Server/BFF bounded patch |
| Cloud Runtime | 未解锁 | 是 | 不碰阿里云运行态 |

## 7. Go / No-Go

- `Go` for 第 5 天本地 Server implementation。
- `Go` for 第 6 天本地 BFF read-model implementation after Server fields exist。
- `No-Go` for Flutter implementation。
- `No-Go` for cloud write / runtime enablement。
- `No-Go` for production release。

## 8. 下一轮唯一动作

执行第 5 天 Server implementation：

- 新增 fee policy。
- 接入 membership 组织会员读模型。
- authorization 保存快照。
- charge 复制 authorization 锁定快照。
- 补最小 Server tests。
