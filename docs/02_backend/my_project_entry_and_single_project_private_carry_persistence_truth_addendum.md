---
owner: Codex 总控
status: frozen
purpose: Freeze the persistence-truth boundary for my-project entry and single-project private carry, limited to organization-scope ownership, public-vs-private read-source ownership, status derivation ownership, and no-new-shadow-carrier rules.
layer: L3 Backend
decision_date_local: 2026-04-04
inputs_canonical:
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_persistence_migration_freeze_addendum.md
  - docs/02_backend/project_showcase_publish_alignment_persistence_truth_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 我的项目入口与单项目私域承接持久化真值冻结单

## 1. Scope

- 本冻结单只覆盖 `我的项目入口与单项目私域承接 persistence freeze`。
- 本冻结单只服务于：
  - `我的项目` 的组织归属 / 私域归属 persistence truth
  - `MyProjectListItemReadModel.publicProject`
  - `MyProjectListItemReadModel.privateSummary`
  - `MyProjectDetailReadModel.publicProject`
  - `MyProjectDetailReadModel.privateProgress`
  - `formalCompletionStatus`
  - `evaluationStatus`
  - `ongoingProjects / historicalProjects` 的读时分层依据
- 本冻结单不进入：
  - backend / BFF / Flutter 实现
  - 搜索 index
  - 地域分类 projection
  - 地图 / 经纬度
  - 其他板块
- 正式附件列表继续排除在本主线外。

## 2. Persistence Freeze Conclusion

- `我的项目` 的私域归属当前正式依赖 `public.project.organization_id`。
- `publicProject` 继续完全复用已冻结的 showcase list/detail persistence truth，不复制第二套项目基础真相。
- `privateSummary` 与 `privateProgress` 当前都冻结为：
  - 只读既有业务真相
  - 读时聚合
  - 不新建 my-project-only summary table
  - 不新建 my-project-only projection table
  - 不新建 materialized view
  - 不新建 shadow aggregate
- `formalCompletionStatus` 与 `evaluationStatus` 当前都冻结为：
  - 读时 derived carrier
  - 不作为 my-project-only persistence 列单独落库
- `ongoingProjects / historicalProjects` 当前冻结为：
  - 读时分层
  - 由 `formalCompletionStatus` 决定
  - 严禁由 `plannedEndAt` 直接判定

## 3. 私域归属 Persistence Truth

### 3.1 当前组织 scope 下的项目资产

- “当前组织 scope 下的项目资产”当前正式依赖：
  - `public.project.organization_id`
- 该字段当前已经存在于 `public.project` 既有真相中。
- 因此：
  - `我的项目` 的私域归属不需要新建 my-project ownership table
  - 不需要新建 my-project membership bridge
  - 不需要新建 my-project scope snapshot

### 3.2 读时约束原则

- `我的项目` 的私域识别当前正式冻结为：
  - 先由 current actor 获取当前组织 scope
  - 再以 `project.organization_id = current organization scope id` 做读时约束
- 当前正式禁止：
  - 把 `recentProjectId` 当作“我的项目”持久化主真相
  - 把 workbench 摘要 carrier 当作组织私域项目资产 owner

## 4. `publicProject` Persistence Truth

### 4.1 列表 `publicProject`

- `MyProjectListItemReadModel.publicProject` 继续完全复用：
  - `ProjectShowcaseListItemReadModel` 的 persistence truth
- 其字段继续由 `public.project` 直出，包括：
  - `projectId`
  - `projectNo`
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `state`
  - `summary`
  - `areaSqm`
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`

### 4.2 详情 `publicProject`

- `MyProjectDetailReadModel.publicProject` 继续完全复用：
  - shared `ProjectReadModel` 的 persistence truth
- 其字段继续由 `public.project` 直出，包括已冻结的：
  - Round B richer fields
  - standardized location
  - address / range / schedule
  - `description`

### 4.3 `publicProject` persistence 结论

- `publicProject` 当前正式不新增：
  - list-only projection table
  - detail-only projection table
  - second project base table
  - my-project-only project snapshot

## 5. `privateSummary` / `privateProgress` Persistence Truth

### 5.1 总原则

- `privateSummary` 与 `privateProgress` 当前都正式冻结为：
  - 只读既有业务真相
  - 读时聚合
  - 不新建专用进度表
  - 不新建项目级第二状态机快照

### 5.2 字段来源边界

- `hasAcceptedOrder`
  - 来自项目下是否存在已接单 / 已承接的真实订单实例
  - 当前冻结为由订单 canonical truth 读时派生
- `orderStatus`
  - 来自订单 canonical truth
  - 当前只承接投影状态值，不新建第二订单状态机
- `contractStatus`
  - 来自合同 canonical truth
  - 当前只承接投影状态值，不新建第二合同状态机
- `fulfillmentStatus`
  - 来自履约 / milestone canonical truth
  - 当前只承接项目级最小推进摘要，不新建第二履约状态机
- `acceptanceStatus`
  - 来自验收 canonical truth
  - 当前只承接项目级最小验收摘要，不新建第二验收状态机
- `afterSalesOrDisputeStatus`
  - 来自争议 / 售后 canonical truth
  - 当前只承接项目级最小摘要，不新建治理后台 carrier
- `formalCompletionStatus`
  - 当前冻结为由既有业务真相读时派生
  - 不单独持久化为 my-project-only 列
- `evaluationStatus`
  - 当前冻结为由正式完结真相与评价实例真相读时派生
  - 不单独持久化为 my-project-only 列

### 5.3 列表与详情的同源规则

- `privateSummary` 与 `privateProgress` 当前正式同源：
  - 都来自订单 / 合同 / 履约 / 验收 / 争议 / 评价 canonical truth
- 当前正式允许：
  - detail 在未来 contract round 承接更细解释字段
- 但本轮正式禁止：
  - 因 detail richer 需要而新建专用进度表
  - 正式附件列表混入 `privateProgress`
  - 平台治理字段混入 `privateProgress`
  - `奖励金额` 混入 `privateProgress`
  - `单位平方面积金额` 混入 `privateProgress`

## 6. `formalCompletionStatus` Persistence Truth

- `formalCompletionStatus` 当前不依赖 `plannedEndAt`。
- 当前正式写死：
  - 不得由 `plannedEndAt` 直接推导
- 在本轮 persistence freeze 中，`formalCompletionStatus` 正式冻结为：
  - 由既有业务真相组合读时派生
  - 不单独新增 my-project completion 列
- 其上游组合真相至少包括：
  - 项目继续处理链的业务完结条件
  - 订单 / 合同 / 履约 / 验收 / 争议关闭等 canonical truth
- 如果后续业务链正式冻结出独立 completion carrier，也必须在其所属真相家族中解冻，不在本主线私造 carrier。

## 7. `evaluationStatus` Persistence Truth

- `evaluationStatus` 当前不自动执行任何动作。
- 当前正式写死：
  - `eligible` 不是自动评价
  - `submitted` 必须对应真实评价动作完成
- 在本轮 persistence freeze 中，`evaluationStatus` 正式冻结为：
  - 由正式完结真相与真实评价实例真相读时派生
  - 不单独新增 my-project evaluation 列
- 最小读时派生规则冻结为：
  - `not_eligible`
    - 尚未达到正式完结条件
  - `eligible`
    - 已达到正式完结条件，且尚无已提交评价实例
  - `submitted`
    - 已存在真实评价动作完成的实例真相

## 8. `ongoingProjects` / `historicalProjects` Persistence Truth

- 列表分层当前正式不新增分组持久化字段。
- `ongoingProjects / historicalProjects` 当前冻结为：
  - 读时分组
  - 由 `formalCompletionStatus` 派生结果决定
- 当前正式禁止：
  - `plannedEndAt < now` 就直接进入 `historicalProjects`
- 若 `formalCompletionStatus` 为读时派生，则：
  - `historicalProjects` 同样随该派生结果决定
  - 不新增 history bucket 列

## 9. 显式非目标

- 不新增：
  - my-project-only table
  - my-project-only snapshot 列
  - my-project-only materialized view
  - `tags` persistence
  - 正式附件列表 persistence
  - 搜索 / 地域分类页面 / 地图 / 经纬度 persistence
- 不影响：
  - forum
  - 消息
  - 订单平台化后台
  - 合同后台
  - 履约治理后台

## 10. Stage Conclusion

- 当前结论：
  - `Go` for entering the `我的项目入口与单项目私域承接 backend-BFF implementation freeze` stage
  - `No-Go` for直接进入实现
- 本冻结单的真实含义是：
  - `我的项目` 的组织归属、public/private 两区、状态分层 persistence truth 已正式冻结
  - 本主线不新增 my-project-only persistence carrier
  - 下一步若继续推进，应先进入 backend-BFF implementation freeze

