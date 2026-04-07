---
owner: Codex 总控
status: frozen
purpose: Freeze the contract boundary for my-project entry and single-project private carry, limited to the private path family, my-project list response, single-project read response, private progress carrier, and evaluation-entry boundary.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_truth_freeze_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_contract_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-04
---

# 我的项目入口与单项目私域承接 contract 冻结单

## 1. Scope

- 本冻结单只覆盖 `我的项目入口与单项目私域承接 contract freeze`。
- 本冻结单只服务于：
  - `我的项目` 私域入口 path family
  - `我的项目` 列表 read contract
  - 单项目详情 read contract
  - 私域进度区 contract
  - 完结 / 历史项目 / 待评价 / 已评价的 contract 承载边界
- 本冻结单不进入：
  - persistence freeze
  - migration freeze
  - backend / BFF / Flutter 实现
- 本冻结单不扩到：
  - forum
  - 消息
  - 地图
  - 搜索界面
  - 地域分类页面
  - 企业库
  - 订单平台化后台
  - 合同后台
  - 履约治理后台
- 正式附件列表继续排除在本主线外。

## 2. Contract Freeze Conclusion

- `我的项目` 现正式采用独立私域 path family：
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
  - `GET /server/my/projects`
  - `GET /server/my/projects/{projectId}`
- 当前正式禁止复用：
  - 公域 `GET /api/app/project/list`
  - 公域 `GET /api/app/project/detail`
  - 摘要 / 导流 `GET /api/app/exhibition/workbench`
- `我的项目` 列表现正式冻结为双数组承接：
  - `ongoingProjects`
  - `historicalProjects`
- 单项目详情现正式冻结为双区结构：
  - `publicProject`
  - `privateProgress`
- `plannedEndAt` 继续只存在于 `publicProject`。
- `formalCompletionStatus` 与 `evaluationStatus` 现正式进入私域进度 contract。
- 正式附件列表继续独立立项，不进入本轮 contract。

## 3. Path Family Contract Freeze

### 3.1 正式 path family

- app-facing：
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
- server-facing：
  - `GET /server/my/projects`
  - `GET /server/my/projects/{projectId}`

### 3.2 不复用现有 path 的原因

- `GET /api/app/project/list`
  - 继续只服务公域 showcase list
  - 不承接私域项目阶段摘要
- `GET /api/app/project/detail`
  - 继续只服务公域 showcase detail
  - 不承接私域继续处理真相
- `GET /api/app/exhibition/workbench`
  - 继续只服务摘要 / 导流
  - `recentProjectId` 不是“我的项目列表”真相

## 4. 列表 Contract Freeze

### 4.1 列表响应结构

- `我的项目` 列表正式冻结为：
  - `MyProjectListResponse`
- 结构正式冻结为：
  - `ongoingProjects: MyProjectListItemReadModel[]`
  - `historicalProjects: MyProjectListItemReadModel[]`

### 4.2 列表 item 双层结构

- `MyProjectListItemReadModel` 现正式冻结为：
  - `publicProject: ProjectShowcaseListItemReadModel`
  - `privateSummary: MyProjectPrivateProgressSummaryReadModel`
- 这样冻结的原因是：
  - 保持公域摘要与私域摘要边界清晰
  - 禁止把公域展示 contract 与私域继续处理 contract 混成一个 carrier

### 4.3 列表 item 的公域摘要层

- `publicProject` 继续承接：
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

### 4.4 列表 item 的私域摘要层

- `privateSummary` 至少承接：
  - `hasAcceptedOrder`
  - `orderStatus`
  - `contractStatus`
  - `fulfillmentStatus`
  - `acceptanceStatus`
  - `afterSalesOrDisputeStatus`
  - `formalCompletionStatus`
  - `evaluationStatus`
- 当前正式写死：
  - 列表 item 只承接最小私域摘要
  - 不承接完整订单详情
  - 不承接完整合同详情
  - 不承接完整履约详情
  - 不承接完整验收详情
  - 不承接正式附件列表
  - 不承接平台治理信息

## 5. 单项目详情 Contract Freeze

### 5.1 详情响应结构

- 单项目详情正式冻结为：
  - `MyProjectDetailReadModel`
- 结构正式冻结为：
  - `publicProject: ProjectReadModel`
  - `privateProgress: MyProjectPrivateProgressReadModel`

### 5.2 `publicProject`

- `publicProject` 现正式直接复用当前已冻结的 shared showcase detail `ProjectReadModel`。
- 当前正式写死的复用原则是：
  - 只复用已冻结的公域展示 truth
  - 不重造第二套项目基础 read model
  - `plannedEndAt` 继续只承担计划时间
  - `buildingTypeRemark` 继续只承担说明补充

### 5.3 `privateProgress`

- `privateProgress` 现正式冻结为独立对象：
  - `MyProjectPrivateProgressReadModel`
- 其最小承接字段为：
  - `hasAcceptedOrder`
  - `orderStatus`
  - `contractStatus`
  - `fulfillmentStatus`
  - `acceptanceStatus`
  - `afterSalesOrDisputeStatus`
  - `formalCompletionStatus`
  - `evaluationStatus`
- 当前正式写死：
  - 私域进度区只承接项目级继续处理真相
  - 不变成平台治理后台 contract
  - 不承接正式附件列表
  - 不承接 `奖励金额`
  - 不承接 `单位平方面积金额`

## 6. 状态 Contract Freeze

### 6.1 列表分层

- `ongoingProjects`
  - 是 contract 级分层承载
- `historicalProjects`
  - 是 contract 级归档分层承载
  - 不是“已评价”同义词
  - 不是“正式完结”同义词

### 6.2 `plannedEndAt`

- `plannedEndAt` 继续只存在于：
  - `publicProject`
- 当前正式禁止：
  - 在 contract 层把 `plannedEndAt` 直接映射成“已完成”

### 6.3 `formalCompletionStatus`

- `formalCompletionStatus` 现正式进入私域 contract。
- 当前最小枚举边界冻结为：
  - `not_formally_completed`
  - `formally_completed`
- 当前正式写死：
  - 它是项目级业务完结 carrier
  - 不是计划时间 carrier

### 6.4 `evaluationStatus`

- `evaluationStatus` 现正式进入私域 contract。
- 当前最小枚举边界冻结为：
  - `not_eligible`
  - `eligible`
  - `submitted`
- 当前正式写死：
  - `eligible` 表示 `待评价`
  - `submitted` 表示 `已评价`
  - 不存在“自动评价”语义

## 7. 与现有 Contract 的关系

- 公域 `GET /api/app/project/list`
  - 继续只服务公域展示
- 公域 `GET /api/app/project/detail`
  - 继续只服务公域展示详情
- `GET /api/app/exhibition/workbench`
  - 继续只服务摘要 / 导流
- `POST /api/app/project/create`
  - 继续只服务创建
- `我的项目` read contract
  - 必须独立存在
  - 不替代上述任何现有 contract

## 8. 继续排除的范围

- 正式附件列表
- 显式 `tags` 真相数组
- 搜索 contract
- 地域分类页面 contract
- 地图 / 经纬度
- `奖励金额`
- `单位平方面积金额`
- forum / 消息 / 其他无关板块字段

## 9. OpenAPI Update Scope

- 本轮已更新：
  - `GET /api/app/my/projects`
  - `GET /api/app/my/projects/{projectId}`
  - `GET /server/my/projects`
  - `GET /server/my/projects/{projectId}`
  - `MyProjectListResponse`
  - `MyProjectListItemReadModel`
  - `MyProjectPrivateProgressSummaryReadModel`
  - `MyProjectDetailReadModel`
  - `MyProjectPrivateProgressReadModel`
  - `MyProjectFormalCompletionStatus`
  - `MyProjectEvaluationStatus`
- 本轮明确不更新：
  - 公域 `project/list`
  - 公域 `project/detail`
  - `project/create`
  - `exhibition/workbench`
  - 搜索、地域分类页面、地图 / 经纬度相关 contract
  - 其他板块任何 schema / path

## 10. Stage Conclusion

- 当前结论：
  - `Go` for entering the `我的项目入口与单项目私域承接 persistence freeze` stage
  - `No-Go` for直接进入实现
- 本冻结单的真实含义是：
  - `我的项目` path family 与列表 / 单项目 contract 已正式冻结
  - 公域信息区 / 私域进度区 contract 边界已正式冻结
  - 完结 / 历史项目 / 待评价 / 已评价的 contract 承载方式已写清
  - 正式附件列表继续被明确排除在本主线外

## 11. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `我的项目入口与单项目私域承接` contract。
  - 正式拆分私域 `my/projects` path family 与公域 showcase / workbench path。
  - 正式确认列表双数组分层与列表 item 的公域 / 私域双层结构。
  - 正式确认单项目详情使用 `publicProject + privateProgress` 双区 contract。
  - 正式确认 `formalCompletionStatus` 与 `evaluationStatus` 的最小 contract 承载边界。
