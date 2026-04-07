---
owner: Codex 总控
status: frozen
purpose: Freeze the persistence-truth boundary for aligning project showcase with project publish, limited to showcase list/detail read-source ownership, derived-tag non-persistence, and the attachment-read split decision.
layer: L3 Backend
decision_date_local: 2026-04-04
inputs_canonical:
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/project_publish_address_range_persistence_truth_addendum.md
  - docs/02_backend/project_publish_round_b_persistence_truth_addendum.md
  - docs/02_backend/project_location_standardization_persistence_truth_addendum.md
---

# 项目展示与项目发布对齐持久化真值冻结单

## 1. Scope

- 本冻结单只覆盖 `project showcase publish alignment persistence freeze`。
- 本冻结单只服务于：
  - `ProjectShowcaseListItemReadModel` 的持久化来源边界
  - shared `ProjectReadModel` 中展示详情字段的持久化来源边界
  - 轻标签是否保持派生而不持久化
  - 正式附件列表继续不进入当前 persistence freeze
- 本冻结单只处理 `project` 聚合。
- 本冻结单不进入：
  - backend / BFF / Flutter 实现
  - 搜索 index
  - 地域分类 projection
  - 地图 / 经纬度
  - 其他板块

## 2. Persistence Freeze Conclusion

- showcase 列表卡片与 showcase 详情当前都继续由 `Server.project` 单一聚合直出。
- `ProjectShowcaseListItemReadModel` 不引入新的 list-only 物化 projection。
- shared `ProjectReadModel` 中 showcase detail 准入字段不引入新的 showcase-only relational carrier。
- 轻标签继续保持“派生而不持久化”。
- 正式附件列表继续不进入当前 persistence freeze，后续若推进必须拆为独立议题：
  - `project showcase detail attachment read persistence freeze`

## 3. Showcase 列表卡片 Persistence Truth

### 3.1 来自 `public.project` 的列表字段

以下列表卡片字段当前都继续来自 `public.project`：

- `projectId`
  - carrier: `project.id`
- `projectNo`
  - carrier: `project.project_no`
- `title`
  - carrier: `project.title`
- `buildingType`
  - carrier: `project.building_type`
- `budgetAmount`
  - carrier: `project.budget_amount`
- `state`
  - carrier: `project.state`
- `summary`
  - carrier: `project.summary`
- `areaSqm`
  - carrier: `project.area_sqm`
- `provinceCode`
  - carrier: `project.province_code`
- `provinceName`
  - carrier: `project.province_name`
- `cityCode`
  - carrier: `project.city_code`
- `cityName`
  - carrier: `project.city_name`

### 3.2 列表卡片 persistence 结论

- 上述字段当前全部继续由 `project` 聚合直出。
- 当前不要求也不允许新增：
  - list-only projection table
  - list-only summary shadow column
  - list-only materialized view
- `summary` 当前继续由 `project.summary` 承载，不要求改造 persistence 结构。
- `areaSqm`、`provinceCode`、`provinceName`、`cityCode`、`cityName` 已经分别落在上游已冻结的：
  - Round B richer field persistence truth
  - standardized location persistence truth
- showcase 对齐本轮不再新增任何列表专属 persistence 字段。

## 4. Showcase 详情 Persistence Truth

### 4.1 来自 `public.project` 的详情字段

以下 showcase detail 字段当前都继续来自 `public.project`：

- `buildingTypeRemark`
  - carrier: `project.building_type_remark`
- `districtCode`
  - carrier: `project.district_code`
- `districtName`
  - carrier: `project.district_name`
- `detailAddress`
  - carrier: `project.detail_address`
- `scopeSummary`
  - carrier: `project.scope_summary`
- `plannedStartAt`
  - carrier: `project.planned_start_at`
- `plannedEndAt`
  - carrier: `project.planned_end_at`
- `scheduleDetail`
  - carrier: `project.schedule_detail`
- `description`
  - carrier: `project.description`

### 4.2 详情 persistence 结论

- 这些字段当前全部继续由 `project` 聚合直出。
- 其中：
  - `buildingTypeRemark`
  - `scheduleDetail`
  - `areaSqm`
    继续依赖已冻结的 Round B persistence truth
  - `districtCode`
  - `districtName`
  - `detailAddress`
  - `provinceCode`
  - `provinceName`
  - `cityCode`
  - `cityName`
    继续依赖已冻结的 standardized location persistence truth
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
    继续依赖已冻结的 address-range persistence truth
  - `description`
    继续使用 `project.description` 既有 carrier，不新增 showcase-only 列
- 本轮不要求新增：
  - detail-only read table
  - detail-only document table
  - detail-only shadow aggregate

## 5. Lightweight Tags Persistence Freeze

- 以下轻标签继续保持“派生而不持久化”：
  - 地域标签
  - 类型标签
  - 状态标签
  - 面积展示标签
- 当前正式禁止新增：
  - `tags` 列
  - tag bridge 表
  - tag snapshot 表
  - 任何为了 showcase list/detail 新建的 tag persistence carrier
- 这些标签当前只允许从既有真字段派生：
  - 地域标签 <- standardized location
  - 类型标签 <- `buildingType`
  - 状态标签 <- `state`
  - 面积展示标签 <- `areaSqm`

## 6. Formal Attachment List Persistence Conclusion

- 正式附件列表当前仍不进入本轮 persistence freeze。
- 当前 shared showcase detail persistence 继续不承载附件列表。
- 当前正式禁止：
  - 为附件列表在本轮新建 `project` 聚合内的 attachment snapshot carrier
  - 把附件列表塞进 `project.summary`
  - 把附件类型标签塞进当前 showcase persistence freeze
- 后续若推进，必须拆为独立议题：
  - `project showcase detail attachment read persistence freeze`

## 7. Additive Migration Dependency Freeze

- 本轮 `showcase alignment persistence freeze` 不新增 showcase-only persistence 字段。
- 因此本轮不新增一条新的 showcase-only additive migration。
- 当前 showcase list/detail 所需字段若进入 runtime，继续只依赖上游已经冻结的 `public.project` additive migration 范围：
  - address-range：
    - `province_name`
    - `city_name`
    - `district_name`
    - `detail_address`
    - `scope_summary`
    - `planned_start_at`
    - `planned_end_at`
  - Round B richer fields：
    - `area_sqm`
    - `building_type_remark`
    - `schedule_detail`
  - standardized location：
    - `province_code`
    - `city_code`
    - `district_code`
- 这意味着：
  - 本轮不 author 新 migration 文件
  - 本轮也不 author 新列
  - 但 showcase alignment 的 runtime 落地仍以前述已冻结 migration 边界生效为前提

## 8. Explicit Non-goals

- 不扩到搜索 index
- 不扩到地域分类 projection
- 不扩到地图 / 经纬度
- 不扩到其他板块
- 不把轻标签做成持久化真相
- 不把附件列表塞进当前 shared detail persistence freeze
- 不把 `奖励金额` 与 `单位平方面积金额` 带入 persistence truth

## 9. Stage Conclusion

- 当前结论：
  - `Go` for entering the `showcase alignment backend-BFF implementation freeze` stage
  - `No-Go` for直接进入实现
- 本冻结单的真实含义是：
  - showcase 列表/详情的 persistence truth 已正式冻结
  - 轻标签与附件列表的 persistence 边界已写清
  - 下一步如继续推进，应先进入 backend-BFF implementation freeze

