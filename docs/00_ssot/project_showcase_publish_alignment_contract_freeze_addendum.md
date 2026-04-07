---
owner: Codex 总控
status: frozen
purpose: Freeze the contract boundary for aligning project showcase with project publish, limited to showcase list/detail read models, classification and lightweight tag carrier rules, and the attachment-read split decision.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-04
---

# 项目展示与项目发布对齐 contract 冻结单

## 1. Scope

- 本冻结单只覆盖 `project showcase publish alignment contract freeze`。
- 本冻结单只服务于：
  - showcase 列表卡片 read model
  - showcase 详情 read model
  - 地域分类 / 类型分类 / 轻标签的 contract 承载边界
  - 正式附件列表是否独立进入下一条 read contract 议题
- 本冻结单不进入：
  - persistence freeze
  - migration freeze
  - backend / BFF / Flutter 实现
- 本冻结单不扩到：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议
  - 搜索界面实现
  - 地域分类页面实现
  - 地图 / 经纬度

## 2. Contract Freeze Conclusion

- showcase 列表卡片 contract 正式独立为 `ProjectShowcaseListItemReadModel`。
- showcase 详情 contract 继续由 `ProjectReadModel` 承担，但其语义正式限定为 detail read model，而不再与 list card 共用同一字段面。
- 地域分类 contract 只依赖 `provinceCode / cityCode / districtCode`。
- 类型分类 contract 只依赖 `buildingType`。
- 轻标签当前只冻结为“可派生但不进入 shared contract 的显式 `tags` 数组”。
- 正式附件列表不进入当前 shared showcase detail contract，必须独立进入下一阶段：
  - `project showcase detail attachment read contract freeze`

## 3. Showcase 列表卡片 Read Model Contract

### 3.1 正式进入列表卡片 contract 的字段

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

### 3.2 不进入列表卡片 read model 的字段

- `districtCode`
- `districtName`
- `detailAddress`
- `scopeSummary`
- `plannedStartAt`
- `plannedEndAt`
- `scheduleDetail`
- `buildingTypeRemark`
- `description`
- 正式附件列表

### 3.3 轻标签 contract 结论

- 当前不新增显式 `tags` 数组。
- 轻标签只冻结为：
  - 可由列表卡片已返回真字段派生
  - 但不进入 shared list contract 的独立 carrier
- 当前允许的派生来源只有：
  - 地域标签：`provinceCode + provinceName`、`cityCode + cityName`
  - 类型标签：`buildingType`
  - 状态标签：`state`
  - 面积展示标签：`areaSqm`

## 4. Showcase 详情 Read Model Contract

### 4.1 正式进入详情 contract 的字段

- `projectId`
- `projectNo`
- `title`
- `buildingType`
- `buildingTypeRemark`
- `budgetAmount`
- `areaSqm`
- `provinceCode`
- `provinceName`
- `cityCode`
- `cityName`
- `districtCode`
- `districtName`
- `detailAddress`
- `scopeSummary`
- `plannedStartAt`
- `plannedEndAt`
- `scheduleDetail`
- `state`
- `summary`
- `description`

### 4.2 create/detail 同名同义复用字段

- 以下字段继续与 publish create/detail 共享同名同义：
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `areaSqm`
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
  - `districtCode`
  - `districtName`
  - `detailAddress`
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
  - `scheduleDetail`
  - `description`

### 4.3 展示消费但不扩真义的字段

- `buildingTypeRemark`
  - 只承担展示补充说明
  - 不升格为类型分类真相
- `detailAddress`
  - 只承担自由文本地址补充
  - 不升格为地域分类真相

## 5. 分类与标签 Contract Boundary

### 5.1 地域分类

- 地域分类 contract 只依赖：
  - `provinceCode`
  - `cityCode`
  - `districtCode`
- 当前正式禁止：
  - 把 `provinceName / cityName / districtName` 当作长期唯一分类真相

### 5.2 类型分类

- 类型分类 contract 当前只依赖：
  - `buildingType`
- 当前正式禁止：
  - 把 `buildingTypeRemark` 升格为分类真相
  - 假装已有 finer type truth

### 5.3 当前不得进入 contract 的标签

- 奖励标签
- 单位平方面积金额标签
- 附件类型标签
- 细类型标签
- 面积分档标签

## 6. 正式附件列表 Contract Conclusion

- 正式附件列表不进入当前 shared showcase detail contract。
- 当前 shared `ProjectReadModel` 继续不承载附件列表。
- 后续若推进，必须独立进入：
  - `project showcase detail attachment read contract freeze`
- 当前正式禁止：
  - 直接把附件列表塞进 `ProjectReadModel`
  - 直接把附件类型标签塞进 list/detail shared contract

## 7. OpenAPI Update Scope

- 本轮已更新：
  - `ProjectShowcaseListItemReadModel`
  - `ProjectListResponse`
  - `ProjectReadModel`
  - `GET /api/app/project/list`
  - `GET /api/app/project/detail`
  - `GET /server/projects/{projectId}`
- 本轮明确不更新：
  - `POST /api/app/project/create`
  - `POST /server/projects`
  - `project/list` 之外的其他展示 path
  - 任何搜索、地域分类页面、地图 / 经纬度相关 contract
  - 其他板块任何 schema / path

## 8. Stage Conclusion

- 当前结论：
  - `Go` for entering the `showcase alignment persistence freeze` stage
  - `No-Go` for直接进入实现
- 本冻结单的真实含义是：
  - showcase 列表/详情的 contract 边界已正式冻结
  - 分类、标签、附件的 contract 边界已写清
  - 下一步如继续推进，应先进入 persistence freeze

## 9. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `project showcase publish alignment` contract。
  - 正式拆分 showcase 列表卡片与详情 read model contract。
  - 正式确认轻标签不进入 shared contract 的显式 `tags` 数组。
  - 正式确认附件列表必须独立立项，不进入当前 shared detail contract。
