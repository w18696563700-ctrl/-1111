---
owner: Codex 总控
status: frozen
purpose: Formally freeze the truth boundary for aligning project showcase with project publish, limited to showcase list, showcase detail, regional classification, type classification, tag derivation, and the attachment-read decision.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_showcase_publish_alignment_pre_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
freeze_date_local: 2026-04-04
---

# 项目展示与项目发布对齐真源冻结单

## 1. Scope

- 本冻结单只覆盖 `project showcase publish alignment truth freeze`。
- 本冻结单只服务于：
  - 项目展示列表卡片
  - 项目展示详情
  - 地域分类
  - 类型分类
  - 标签派生
  - 正式附件列表是否独立立项
- 本冻结单不进入：
  - contract freeze
  - persistence freeze
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

## 2. Truth Freeze Conclusion

- showcase 列表卡片与 showcase 详情的候选字段边界现已正式冻结。
- 地域分类正式依赖 standardized location code truth。
- 类型分类当前只依赖 `buildingType`，不承认更细类型真相已存在。
- 标签派生 truth 只允许基于已冻结真字段派生。
- 正式附件列表正式进入下一阶段 truth freeze，但必须拆成独立议题，不得直接混入当前 shared showcase detail truth。

## 3. 列表卡片 Truth Freeze

### 3.1 正式进入列表卡片 truth 的字段

- `title`
- `buildingType`
- `budgetAmount`
- `state`
- `summary`
- `areaSqm`
- `provinceCode + provinceName`
- `cityCode + cityName`

### 3.2 列表卡片可进入的轻标签 truth

- 地域标签
  - 只允许由 `provinceCode + provinceName`、`cityCode + cityName` 派生
- 类型标签
  - 只允许由 `buildingType` 派生
- 状态标签
  - 只允许由 `state` 派生
- 面积展示标签
  - 只允许由 `areaSqm` 派生
  - 当前只承认原始面积展示，不承认面积分档 taxonomy

### 3.3 继续留在详情 truth、不进入列表卡片的字段

- `districtCode + districtName`
- `detailAddress`
- `scopeSummary`
- `plannedStartAt`
- `plannedEndAt`
- `scheduleDetail`
- `buildingTypeRemark`
- `description`
- 正式附件列表

### 3.4 暂不进入列表卡片 truth 的项

- `奖励金额`
- `单位平方面积金额`
- 细类型标签
- 附件类型标签

## 4. 展示详情 Truth Freeze

### 4.1 正式进入 showcase detail truth 的字段

- `title`
- `buildingType`
- `buildingTypeRemark`
- `budgetAmount`
- `areaSqm`
- `provinceCode + provinceName`
- `cityCode + cityName`
- `districtCode + districtName`
- `detailAddress`
- `scopeSummary`
- `plannedStartAt`
- `plannedEndAt`
- `scheduleDetail`
- `description`

### 4.2 展示详情 truth 解释边界

- `buildingTypeRemark`
  - 只承担说明补充
  - 不升格为类型分类真相
- standardized location
  - 继续按 `code + name` 承担
  - `code` 为分类真相
  - `name` 为展示值
- `detailAddress`
  - 继续承担自由文本补充
  - 不承担分类真相
- `description`
  - 现正式进入 showcase detail truth
  - 但后续 contract freeze 必须明确其 read carrier，不得让 list 被动扩面成 description owner

### 4.3 暂缓进入 showcase detail truth 的项

- 正式附件列表
  - 不在当前 shared showcase detail truth 内直接准入
  - 必须拆为独立 truth 议题

## 5. 地域分类与类型分类 Truth Freeze

### 5.1 地域分类 truth

- 地域分类正式依赖：
  - `provinceCode`
  - `cityCode`
  - `districtCode`
- 当前正式禁止：
  - 把 `provinceName / cityName / districtName` 当作长期唯一分类真相
- `provinceName / cityName / districtName` 继续只承担展示值。

### 5.2 类型分类 truth

- 当前类型分类正式只依赖：
  - `buildingType`
- 当前正式冻结限制：
  - `buildingType` 仍是 coarse type truth
  - `buildingTypeRemark` 不是分类真相
  - 当前还没有 finer type truth
  - 不得假装已有 `projectSubtype` / `sceneType` / `activityType`

## 6. 标签派生 Truth Freeze

### 6.1 允许直接进入 truth 的派生标签

- 地域标签
  - 来自 standardized location：
    - `provinceCode + provinceName`
    - `cityCode + cityName`
    - 若区县层存在，可来自 `districtCode + districtName`
- 类型标签
  - 来自 `buildingType`
- 状态标签
  - 来自 `state`
- 面积展示标签
  - 来自 `areaSqm`
  - 当前仅指原始面积值展示或带单位展示

### 6.2 当前不得进入 truth 的标签

- 奖励标签
  - 缺少 `rewardAmount` 真源
- 单位平方面积金额标签
  - 当前不得从 `budgetAmount / areaSqm` 派生正式展示真相
  - 原因是预算不是稳定单价真相，且 `areaSqm` 可能为空
- 附件类型标签
  - 需先冻结附件 read truth 与附件类型语义
- 细类型标签
  - 不得从 `buildingTypeRemark` 升格派生
- 面积分档标签
  - 需先冻结面积分档 taxonomy

## 7. 正式附件列表 Truth Freeze Conclusion

- 正式附件列表进入下一阶段 truth freeze。
- 但其准入方式已正式冻结为：
  - 必须拆成独立议题：
    - `project showcase detail attachment read truth`
- 当前正式禁止：
  - 直接把附件列表塞进 shared `ProjectReadModel`
  - 直接把附件列表塞进当前 shared showcase detail truth
  - 直接把附件类型标签当作已可实施 truth

## 8. Explicit Non-goals

- 不进入搜索界面实现
- 不进入地域分类页面实现
- 不进入地图 / 经纬度
- 不进入其他板块
- 不把 `奖励金额` 带入展示 truth
- 不把 `单位平方面积金额` 带入展示 truth

## 9. Stage Conclusion

- 当前结论：
  - `Go` for entering the `showcase alignment contract freeze` stage
  - `No-Go` for直接进入 persistence freeze
  - `No-Go` for直接进入实现
- 本冻结单的真实含义是：
  - showcase 列表 / 详情的 truth 边界已正式冻结
  - 地域分类、类型分类、标签派生边界已写死
  - 正式附件列表是否独立立项已写清
  - 下一步应先进入 contract freeze

## 10. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `project showcase publish alignment truth`。
  - 正式确认列表卡片与详情的 truth 边界。
  - 正式确认地域分类、类型分类与标签派生边界。
  - 正式确认正式附件列表进入下一阶段 truth freeze，但必须独立立项。
