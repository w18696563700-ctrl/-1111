---
title: 备份资产最终裁决登记
owner: Codex 总控执行 Agent
status: recorded; docs-only
date: 2026-05-12
scope: backup-assets-final-disposition
---

# 备份资产最终裁决登记

## 总裁决

本次桌面备份资产只做最终关闭登记与后置专项拆线，不恢复任何 patch，不修改业务代码，不修改 OpenAPI，不生成 contracts，不动云端。

登记前工作区为干净状态；登记后仅新增本草案文档，未产生任何业务代码、contracts、OpenAPI、generated、云端相关改动。当前分支为 `codex/admin-carrier-issuer-release-candidate`。

## 当前工作区状态回执

- 登记前 `git status --short --untracked-files=all`：无输出，工作区干净。
- 登记前暂存区：空。
- 登记前 HEAD：`f3bc26e7`
- 本轮允许变更：仅新增本登记文档。

## 4 组备份资产最终裁决表

| 备份资产 | 当前状态 | 最终裁决 | 裁决理由 | 后续动作 |
| --- | --- | --- | --- | --- |
| `/Users/wangweiwei/Desktop/audit_reports_deferred_20260510` | 桌面归档目录，15 个文件 | 可丢弃 | 过程性审计快照，不是当前主线真源，不进入功能 PR | 仅作为仓库外历史归档保留；不得提交 |
| `/Users/wangweiwei/Desktop/profile_reserve_billing_deferred_20260510.patch` | 单 patch，32664 bytes，9 个 diff | 需重新施工 | 旧 patch 已与当前 RC route guard / 页面口径不一致，且曾被裁为 No-Go | 不得 `git apply`；如后续重开，必须按 truthful unavailable / read-only 口径重新做 |
| `/Users/wangweiwei/Desktop/admin_p0_source_provenance_backup_20260511` | 历史备份目录，含 `tracked_dirty.patch` 和 untracked 归档 | 已吸收 | 后续 Admin P0 / Server audit / contracts / admin refine 提交已覆盖其目标 | 作为历史备份保留，不进入提交队列 |
| `/Users/wangweiwei/Desktop/deferred_dirty_20260512_200540` | 延后资产目录，含 49 个 diff 备份 | 后置专项 | 混合资产，不能整体回放 | 只允许按专项拆线后重开，不得整体恢复 |

## 各组资产后续动作

### 1. audit_reports_deferred_20260510

- 定位：仓库外历史审计快照。
- 动作：不提交、不回放、不纳入功能 PR。
- 处理口径：如无单独审计留档要求，可继续作为桌面归档；从代码主线视角可关闭。

### 2. profile_reserve_billing_deferred_20260510.patch

- 定位：旧的 Profile Reserve / Billing patch。
- 动作：不得直接回放。
- 处理口径：如后续重开，必须重新从干净基线施工，并遵守：
  - reserve / billing surface 只能 truthful unavailable 或 read-only
  - 不打开 RC route guard
  - 不伪装支付、会员购买、billing、reserve 已闭环

### 3. admin_p0_source_provenance_backup_20260511

- 定位：已被主线后续提交覆盖的历史备份。
- 动作：不进入提交队列。
- 吸收依据：
  - 据本轮只读核查，备份中的 untracked 文书和测试文件当前已在仓库内 tracked。
  - `tracked_dirty.patch` 的 28 个路径当前都存在于仓库
  - 对应目标已分散进入 Admin P0 / Server audit / contracts / admin refine 相关提交

### 4. deferred_dirty_20260512_200540

- 定位：49 个 dirty 的保护性隔离备份。
- 动作：不得整体回放。
- 处理口径：只能拆线后按专项门禁重开。

## deferred_dirty_20260512_200540 内部分线裁决

| 分线 | 裁决 | 原因 | 后续动作 |
| --- | --- | --- | --- |
| BFF RC / fail-closed 移除 | 后置专项 | 会扩大 App 侧写入口与预授权入口 | 单独做 BFF RC 边界专项 |
| Flutter bid authorization / route guard / profile 入口放开 | 后置专项 | 会打开前端入口与跳转能力 | 单独做 Flutter RC / route guard 专项 |
| Alipay / P0-Pay runtime | 后置专项 | 涉及原生桥、SDK payload、Server callback、资金授权 | 单独做支付专项，需云端与真机门禁 |
| content-safety PG concurrency | 后置专项 | 依赖 PostgreSQL 行锁并发验证 | 单独做 Server + DB 测试环境专项 |
| pubspec.lock 回退 | 后置专项 | 会污染 Flutter 依赖基线 | 单独做 lockfile drift 专项 |
| Profile pending-actions 混合切片 | 需重新施工 | 当前 patch 混入 Alipay import、入口解禁、route guard 影响 | 从干净基线按 read-only 口径重做 |

## 明确禁止直接回放的原因

以下备份资产不得直接 `git apply`、不得整体恢复：

1. `profile_reserve_billing_deferred_20260510.patch`
   原因：旧 patch 与当前 RC 路由边界和页面口径冲突。
2. `deferred_dirty_20260512_200540`
   原因：单个备份内混有多条高风险专项，包含 RC unlock、BFF fail-closed 移除、Alipay/P0-Pay runtime、lockfile drift、PG concurrency，整体恢复会破坏最小闭环。
3. `admin_p0_source_provenance_backup_20260511`
   原因：目标已被后续提交吸收，重放有重复提交与回滚现状的风险。

## 后续建议专项列表

建议仅保留以下专项作为后续候选：

1. `BFF RC / fail-closed` 专项：`P1`，先审计，不急于移除 fail-closed。
2. `Flutter bid authorization / route guard` 专项：`P1`，重点收敛入口，不急于放开。
3. `Profile pending-actions read-only 重施工` 专项：`P1`，按 truthful unavailable / read-only 先做。
4. `content-safety PG concurrency` 专项：`P2`，后端稳定性专项，单独验证。
5. `pubspec.lock drift` 专项：`P2`，只做依赖基线判断，不混业务。
6. `Alipay / P0-Pay runtime` 专项：`P3`，暂缓，支付合规和 ICP 前置未闭环前不要推进。

不建议再开的专项：

1. `audit_reports` 回灌专项
2. `admin_p0_source_provenance_backup_20260511` 回放专项

## 本轮声明

- 本轮未恢复任何 patch。
- 本轮未修改业务代码。
- 本轮未修改 OpenAPI。
- 本轮未生成 contracts。
- 本轮未改动云端、Nginx、env、database、release。
- 本轮未 stage 任何业务文件。
- 本轮仅提交本登记文档，不包含任何业务代码、contracts、OpenAPI、generated 或云端相关文件。
