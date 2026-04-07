---
owner: Codex 总控
status: frozen
purpose: Pre-freeze the field-admission, classification, tag, and detail-attachment boundary for aligning project showcase with project publish, without entering truth, contract, persistence, or implementation.
layer: L0 SSOT
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_showcase_detail_bid_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_round_b_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_persistence_migration_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_backend_bff_implementation_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_frontend_consumption_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/bff/src/routes/project/project.service.ts
  - apps/server/src/modules/project/project.presenter.ts
  - apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart
  - apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart
freeze_date_local: 2026-04-04
---

# 项目展示与项目发布对齐预冻结单

## 1. Scope

- 本预冻结单只覆盖 `项目展示与项目发布对齐`。
- 本预冻结单只服务于以下主线：
  - 项目展示列表卡片
  - 项目展示详情
  - 地域分类
  - 类型分类
  - 标签体系
- 本预冻结单不进入：
  - truth freeze
  - contract freeze
  - persistence freeze
  - backend / BFF / Flutter 实现
- 本预冻结单不扩到：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议

## 2. Current Baseline

- 当前 `project/list` / showcase 卡片仍主要依赖最小投影：
  - `projectId`
  - `projectNo`
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `state`
  - `summary`
- 当前 `project/detail` 已承接的正式 richer fields 证据来自共享 read carrier 与本地 presenter / BFF shaping：
  - `areaSqm`
  - `buildingTypeRemark`
  - standardized location:
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
- 当前 `description` 的状态正式认定为：
  - detail UI 本地已有承接槽位
  - 但共享 `ProjectReadModel`、当前 BFF detail shaping、当前 Server presenter 尚未把它冻结为正式 showcase detail shared truth
  - 因此 `description` 当前应被视为下一轮 truth freeze candidate，而不是已经稳定进入展示主线的正式共享字段
- 当前详情页附件承接 UI 已有本地证据：
  - [project_detail_page.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart)
  - [project_attachment_widgets.dart](/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/widgets/project_attachment_widgets.dart)
- 但共享 `ProjectReadModel` 与当前 `project/list` / `project/detail` contract 中仍没有正式附件列表 carrier。

## 3. 项目展示列表卡片候选正式字段

### 3.1 应继续保留的当前正式字段

- `title`
- `buildingType`
- `budgetAmount`
- `state`
- `summary`

### 3.2 应进入下一轮 truth freeze 评估的候选字段

- `areaSqm`
- `provinceCode + provinceName`
- `cityCode + cityName`
- 轻标签候选：
  - 地域标签
  - 类型标签
  - 状态标签
  - 原始面积展示标签

### 3.3 当前不建议进入列表卡片主字段面的项

- `districtCode + districtName`
- `detailAddress`
- `scopeSummary`
- `plannedStartAt`
- `plannedEndAt`
- `scheduleDetail`
- `buildingTypeRemark`
- `description`
- 正式附件列表

### 3.4 列表卡片预冻结结论

- 下一轮 showcase alignment truth freeze 可优先评估的列表卡片正式字段集合为：
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `areaSqm`
  - `provinceCode + provinceName`
  - `cityCode + cityName`
  - `state`
  - `summary`
- 当前 district / detailAddress / 详细排期 / 描述 / 正式附件列表不进入列表卡片主字段面。

## 4. 项目展示详情候选正式字段

### 4.1 可直接进入下一轮 truth freeze 的 detail 候选字段

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

### 4.2 应作为 detail 扩面候选但需单独说明状态的项

- `description`
  - 当前应作为“下一轮 truth freeze candidate”
  - 原因是本地 UI 有承接槽位，但共享 read truth 尚未稳定冻结
- 正式附件列表
  - 当前应作为“下一轮独立 truth freeze candidate”
  - 但不应直接混进 shared `ProjectReadModel`

### 4.3 详情预冻结结论

- 下一轮 showcase alignment truth freeze 的详情正式字段候选，应以已存在 publish/detail richer truths 为主。
- `description` 可进入下一轮 truth freeze 评估，但必须先补齐 shared read truth 边界。
- 正式附件列表应进入下一轮 truth freeze，但必须拆为独立的附件 read truth 议题。

## 5. 地域分类与类型分类真源边界

### 5.1 地域分类

- 地域分类主真相后续必须直接依赖：
  - `provinceCode`
  - `cityCode`
  - `districtCode`
- 当前正式不接受：
  - `provinceName`
  - `cityName`
  - `districtName`
  作为长期唯一分类真相。
- `name` 继续只承担展示值。

### 5.2 类型分类

- 当前类型分类主真相只依赖：
  - `buildingType`
- 当前必须明确限制：
  - `buildingType` 仍是 coarse type truth
  - `buildingTypeRemark` 只是补充说明，不是分类真相
  - 当前不存在已冻结的更细 `projectSubtype` / `sceneType` / `activityType` 真相
- 因此下一轮类型分类 truth freeze 只能先围绕 `buildingType`，不得假装已有细分类。

## 6. 标签体系边界

### 6.1 可直接由现有真字段派生的标签

- 地域标签
  - 来自 `provinceCode + provinceName`
  - 来自 `cityCode + cityName`
  - 若区县层存在，可来自 `districtCode + districtName`
- 类型粗分类标签
  - 来自 `buildingType`
- 状态标签
  - 来自 `state`
- 原始面积展示标签
  - 来自 `areaSqm`
  - 仅限原始面积值或带单位展示，不等于面积分档体系

### 6.2 不能直接当作已可实施标签的项

- 奖励标签
  - 缺少 `rewardAmount` 真源
- 单位平方面积金额标签
  - 当前不应从 `budgetAmount / areaSqm` 直接派生为正式展示真相
  - 原因是：
    - `budgetAmount` 是预算，不是稳定单价真相
    - `areaSqm` 可能为空
    - 比值会制造“准确单平米价格”错觉
- 细类型标签
  - 不能从 `buildingTypeRemark` 直接升级为分类标签
- 正式附件类型标签
  - 例如“效果图 / 施工图 / 展商手册”
  - 需要先冻结附件 read truth 与附件分类语义
- 面积分档标签
  - 例如“小型 / 中型 / 大型”或固定区间标签
  - 需要先冻结面积分档 taxonomy

## 7. 正式附件列表边界

- 当前正式结论：
  - 正式附件列表应进入下一阶段 truth freeze
  - 但必须拆为单独的 `project showcase detail attachment read truth` 议题
- 当前不应直接做的事：
  - 直接把附件列表混入 shared `ProjectReadModel`
  - 直接让列表卡片承担附件列表
  - 直接把附件类型标签当作已可实施标签体系
- 下一阶段 truth freeze 需要单独回答：
  - attachment read carrier 是否独立于 shared `ProjectReadModel`
  - `FileAsset / Evidence` 如何映射为项目详情附件列表
  - “效果图 / 施工图 / 展商手册”等分类是否已有足够真源支撑

## 8. 可进入下一轮 truth freeze 与必须暂缓的项

### 8.1 可进入下一轮 truth freeze 的项

- showcase 列表卡片正式字段：
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `areaSqm`
  - `provinceCode + provinceName`
  - `cityCode + cityName`
  - `state`
  - `summary`
- showcase 详情正式字段：
  - `buildingTypeRemark`
  - standardized location
  - `detailAddress`
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
  - `scheduleDetail`
  - `description` 作为条件性候选
- 分类边界：
  - 地域分类依赖 standardized location code
  - 类型分类先依赖 `buildingType`
- 标签边界：
  - 地域 / 类型粗分类 / 状态 / 原始面积展示标签
- 附件：
  - 正式附件列表作为独立 detail read truth 子议题

### 8.2 必须暂缓的项

- `奖励金额`
- `单位平方面积金额`
- 细类型 taxonomy
- 面积分档 taxonomy
- 附件类型标签体系
- 搜索实现
- 地域分类实现
- list/workbench 扩面

## 9. Stage Conclusion

- 当前结论：
  - `Go` for entering the `项目展示与项目发布对齐 truth freeze` stage
  - `No-Go` for直接进入 contract / persistence / implementation
- 本预冻结单的真实含义是：
  - showcase 主线的候选承接字段已被预冻结
  - 地域分类、类型分类、标签边界已被分清
  - 正式附件列表是否进入下一阶段已被写清
  - 但下一步仍必须先进入独立 truth freeze

## 10. 修订记录

- `v1.0` `2026-04-04`
  - 首版冻结 `项目展示与项目发布对齐` 预冻结边界。
  - 明确列表卡片与详情的候选正式字段。
  - 明确地域分类、类型分类与标签派生边界。
  - 明确正式附件列表应进入下一阶段，但需拆为独立附件 read truth 议题。
