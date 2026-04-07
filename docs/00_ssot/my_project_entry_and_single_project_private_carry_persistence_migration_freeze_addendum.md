---
owner: Codex 总控
status: frozen
purpose: Freeze the additive-migration boundary for my-project entry and single-project private carry, limited to no-new-my-project carrier rules and dependency on already frozen project truth plus existing domain truths.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-04
---

# 我的项目入口与单项目私域承接 persistence migration 冻结单

## 1. Scope

- 本冻结单只覆盖 `我的项目入口与单项目私域承接 persistence migration freeze`。
- 本冻结单只服务于：
  - additive migration 是否需要
  - 若不需要，当前正式依赖哪些既有 persistence truth
  - my-project-only persistence carrier 的禁止边界
- 本冻结单不进入：
  - backend / BFF / Flutter 实现
  - 正式附件列表 persistence
  - 搜索 / 地域分类页面 / 地图 / 经纬度 persistence
  - 其他板块

## 2. Migration Freeze Conclusion

- 本主线当前不需要新增一条 my-project-only additive migration。
- 当前正式继续复用：
  - `public.project` 已存在 / 已冻结列
  - 以及既有订单 / 合同 / 履约 / 验收 / 争议 / 评价 canonical truth
- 当前正式禁止新增：
  - my-project-only table
  - my-project-only summary snapshot 列
  - my-project-only detail snapshot 列
  - my-project-only materialized view
  - my-project-only tag persistence
  - my-project-only attachment snapshot

## 3. 依赖的既有 Persistence 范围

### 3.1 `publicProject`

- `publicProject` 继续复用已冻结的 `public.project` 真相范围，包括：
  - 基础公域字段
  - address / range 字段
  - standardized location 字段
  - Round B richer fields
  - `description`

### 3.2 私域归属

- `我的项目` 的私域归属继续依赖：
  - `public.project.organization_id`
- 因此当前不新增：
  - private project ownership table
  - organization-to-project snapshot table

### 3.3 私域进度

- `privateSummary / privateProgress` 当前继续依赖：
  - 订单 canonical truth
  - 合同 canonical truth
  - 履约 canonical truth
  - 验收 canonical truth
  - 争议 / 售后 canonical truth
  - 评价 canonical truth
- 这些字段当前都只允许读时聚合，不通过本主线新增专用列。

## 4. `formalCompletionStatus` 与 `evaluationStatus`

- `formalCompletionStatus`
  - 当前正式冻结为由既有业务真相组合读时派生
  - 不新增 completion 列
  - 不得由 `plannedEndAt` 直接推导
- `evaluationStatus`
  - 当前正式冻结为由正式完结真相与评价实例真相读时派生
  - 不新增 evaluation 列
  - `submitted` 必须对应真实评价动作完成

## 5. `historicalProjects` 分组边界

- `historicalProjects` 当前正式冻结为：
  - 读时分组
  - 不新增 history bucket 列
  - 由 `formalCompletionStatus` 决定
- 当前正式禁止：
  - 以 `plannedEndAt < now` 直接入历史

## 6. 继续排除的范围

- 正式附件列表
- 搜索界面
- 地域分类页面
- 地图 / 经纬度
- `奖励金额`
- `单位平方面积金额`
- forum / 消息 / 其他无关板块字段

## 7. Stage Conclusion

- 当前结论：
  - `Go` for entering the `我的项目入口与单项目私域承接 backend-BFF implementation freeze` stage
  - `No-Go` for直接进入实现
- 本冻结单的真实含义是：
  - `我的项目` 主线的 additive migration 边界已写清
  - 当前不新增 my-project-only migration
  - 下一步如继续推进，应先进入 backend-BFF implementation freeze

