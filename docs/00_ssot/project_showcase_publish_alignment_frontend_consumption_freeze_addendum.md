---
owner: Codex 总控
status: frozen
purpose: Freeze the Flutter App consumption boundary for aligning project showcase with project publish, limited to showcase list/detail read models, lightweight labels, and non-owner boundaries.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_contract_freeze_addendum.md
  - docs/02_backend/project_showcase_publish_alignment_persistence_truth_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_persistence_migration_freeze_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_backend_bff_implementation_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
freeze_date_local: 2026-04-04
---

# 项目展示与项目发布对齐前端消费冻结单

## 1. Scope

- 本冻结单只覆盖 `project showcase publish alignment frontend consumption freeze`。
- 本冻结单只围绕以下两类 read model 冻结 Flutter 消费边界：
  - `ProjectShowcaseListItemReadModel`
  - shared showcase detail `ProjectReadModel`
- 本冻结单只冻结 Flutter 的：
  - 列表卡片字段消费
  - 详情字段消费
  - 轻标签展示边界
  - 非承载边界
- 本冻结单不进入：
  - Flutter 实现代码
  - backend / BFF 实现代码
  - 搜索界面
  - 地域分类界面
  - 地图 / 经纬度
  - 其他板块

## 2. Frontend Consumption Conclusion

- Flutter 列表卡片只消费 `ProjectShowcaseListItemReadModel`。
- Flutter 展示详情只消费 shared showcase detail `ProjectReadModel`。
- 轻标签当前允许展示，但只能从现有真字段派生，不新增显式 `tags` contract carrier。
- `project/list` 与 `project/detail` 的消费边界现已正式分开：
  - list 只承接最小 card 字段
  - detail 承接 richer showcase detail 字段
- 正式附件列表继续不进入当前 shared showcase detail Flutter 消费，必须等待独立子议题。

## 3. 列表卡片 Flutter Consumption Freeze

### 3.1 列表卡片必须消费的字段

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

### 3.2 直接展示与内部承接边界

- Flutter 列表卡片当前允许直接展示：
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `state`
  - `summary`
  - `areaSqm`（当值存在时）
  - `provinceName`
  - `cityName`
- Flutter 列表卡片当前只作内部承接、不要求直接展示：
  - `provinceCode`
  - `cityCode`
- `provinceCode / cityCode` 的当前前端职责正式冻结为：
  - 保持 standardized region carrier 完整
  - 为后续地域分类 / 搜索消费预留标准化输入
  - 不要求直接显示给终端用户

### 3.3 列表卡片轻标签边界

- Flutter 列表卡片允许展示轻标签。
- 轻标签只允许从当前 list read model 已返回字段派生：
  - 地域标签 <- `provinceCode + provinceName`、`cityCode + cityName`
  - 类型标签 <- `buildingType`
  - 状态标签 <- `state`
  - 面积展示标签 <- `areaSqm`
- Flutter 不得：
  - 自创 `tags` 真相
  - 要求新的 `tags` 数组 contract
  - 以轻标签反推第二套 business truth

## 4. 展示详情 Flutter Consumption Freeze

### 4.1 展示详情必须消费的字段

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

### 4.2 主展示与内部承接边界

- Flutter 详情页当前允许主展示给用户：
  - `title`
  - `buildingType`
  - `buildingTypeRemark`
  - `budgetAmount`
  - `areaSqm`
  - `provinceName`
  - `cityName`
  - `districtName`
  - `detailAddress`
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
  - `scheduleDetail`
  - `state`
  - `summary`
  - `description`
- Flutter 详情页当前只作内部承接、不要求直接展示：
  - `provinceCode`
  - `cityCode`
  - `districtCode`
- `province / city / district` 的当前展示原则正式冻结为：
  - 以 `name` 为主展示
  - 以 `code` 为内部 standardized carrier
- `detailAddress` 继续以自由文本展示。

### 4.3 详情字段释义边界

- `buildingTypeRemark`
  - 只作说明补充展示
  - 不得被 Flutter 升格为分类真相
- `detailAddress`
  - 只作自由文本地址展示
  - 不得被 Flutter 升格为地域分类真相
- `description`
  - 只作 detail supplementary text 消费
  - 不得让 list 卡片被动扩面成 description owner

## 5. Lightweight Tags Flutter Consumption Freeze

- Flutter 当前允许在列表卡片展示轻标签。
- 允许的轻标签来源只限：
  - 地域标签
  - 类型标签
  - 状态标签
  - 面积展示标签
- Flutter 当前明确不允许展示：
  - 奖励标签
  - 单位平方面积金额标签
  - 附件类型标签
  - 细类型标签
  - 面积分档标签
- Flutter 当前明确不允许：
  - 展示 `rewardAmount`
  - 展示“单位平方面积金额”
  - 用 `budgetAmount / areaSqm` 自算并包装成正式前端真相

## 6. Non-owner Boundary

- `project/list` 当前继续不消费：
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
- `project/workbench` 当前继续不承接本轮 richer showcase 字段。
- 正式附件列表当前继续不进入 shared showcase detail Flutter 消费。
- 若后续推进，必须等待独立子议题：
  - `project showcase detail attachment read truth`
  - 及其对应 contract / persistence freeze

## 7. Explicit Non-goals

- Flutter 不得自创 `tags` 真相
- Flutter 不得把 `buildingTypeRemark` 升格为分类真相
- Flutter 不得把 `provinceName / cityName / districtName` 当长期唯一分类真相
- Flutter 不得展示 `rewardAmount`
- Flutter 不得展示“单位平方面积金额”
- Flutter 不得提前 author 正式附件列表 UI 真相
- Flutter 不得扩到：
  - 搜索界面
  - 地域分类界面
  - 地图 / 经纬度
  - 其他板块

## 8. Stage Conclusion

- 当前结论：
  - `Go` for entering the `showcase alignment implementation` stage
  - `No-Go` for把正式附件列表混入当前 shared showcase detail 实现
- 本冻结单的真实含义是：
  - showcase list/detail 的 Flutter 消费边界已正式冻结
  - 轻标签与非承载边界已写清
  - 后续可以进入受控实现，但不得越过附件独立议题与其他板块边界

## 9. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `project showcase publish alignment` Flutter 消费边界。
  - 正式确认列表卡片与详情只围绕两类 read model 消费。
  - 正式确认轻标签只作派生展示，不进入 shared contract carrier。
  - 正式确认正式附件列表继续独立立项。
