---
owner: Codex 总控
status: active
purpose: Freeze the truth boundary for the project-showcase filter and project-create-form refactor object, so the next contract round can proceed on a single meaning for default city context, filter taxonomies, display identity, expiry trimming, and historical compatibility.
layer: L0 SSOT
based_on:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bounded_dispatch_bundle_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/00_ssot/project_publish_round_a_consumption_truth_and_ui_boundary_freeze_addendum.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/project_visibility_and_trade_state_map_freeze_addendum.md
freeze_date_local: 2026-04-11
---

# 《项目展示筛选与创建表单重构 truth boundary freeze》

## 1. Scope

- 本冻结单只覆盖：
  - `项目展示筛选与创建表单重构`
- 本冻结单只服务于：
  - 项目展示列表默认城市上下文
  - 城市筛选
  - 面积档位筛选
  - 金额档位筛选
  - `展会 + 品牌` 双字段展示身份
  - 过期项目退出公域展示
  - 历史项目兼容
- 本冻结单不进入：
  - contract 最终字段清单
  - persistence / migration
  - backend / BFF / Flutter 实现

## 2. Truth Freeze Conclusion

- 当前对象正式冻结以下 6 条真义：
  1. 项目展示默认只优先展示“当前城市上下文”下的项目，且以项目落地城市 truth 为准，不以发布公司所在城市为准。
  2. 城市筛选正式只依赖：
     - `provinceCode`
     - `cityCode`
     不依赖 `detailAddress`。
  3. 面积筛选正式只依赖：
     - `areaSqm`
     以及当前冻结的面积档位 taxonomy。
  4. 金额筛选正式只依赖：
     - `budgetAmount`
     以及当前冻结的金额档位 taxonomy。
  5. 新项目的展示身份正式改为：
     - `展会`
     - `品牌`
     双字段承接；
     旧 `title` 不再作为新项目唯一输入真相，而降为兼容 carrier。
  6. 过期项目退出展示当前只允许作为：
     - 公域 showcase read eligibility trimming
     不得偷写成新的 persisted visibility state。

## 3. 默认城市上下文 Truth Freeze

### 3.1 默认城市上下文优先级

- 项目展示默认城市上下文正式冻结为：
  1. `手动选择城市`
  2. `当前定位/当前城市上下文`
  3. `全国兜底`

### 3.2 城市命中真义

- “显示在本地执行的项目”正式定义为：
  - 以项目自身 standardized location truth 命中当前城市上下文
- 即只允许依赖：
  - `provinceCode + provinceName`
  - `cityCode + cityName`
- 当前正式禁止：
  - 用发布企业所在地代替项目落地城市
  - 用 `detailAddress` 文本做主筛选真相

## 4. 面积档位 Truth Freeze

### 4.1 面积主真相

- 面积筛选主真相正式冻结为：
  - `areaSqm`
- 当前正式禁止：
  - 在前端/BFF 私造第二套面积真相

### 4.2 面积档位 taxonomy

- 当前面积档位正式冻结为：
  - `9_sqm`
  - `18_sqm`
  - `27_sqm`
  - `36_sqm`
  - `54_sqm`
  - `72_sqm`
  - `81_sqm`
  - `90_sqm`
  - `108_sqm`
  - `gt_108_sqm`
  - `custom_sqm`

### 4.3 面积档位判定规则

- 当前判定规则正式冻结为：
  - `9_sqm` = `areaSqm = 9`
  - `18_sqm` = `areaSqm = 18`
  - `27_sqm` = `areaSqm = 27`
  - `36_sqm` = `areaSqm = 36`
  - `54_sqm` = `areaSqm = 54`
  - `72_sqm` = `areaSqm = 72`
  - `81_sqm` = `areaSqm = 81`
  - `90_sqm` = `areaSqm = 90`
  - `108_sqm` = `areaSqm = 108`
  - `gt_108_sqm` = `areaSqm > 108`
  - `custom_sqm` = `areaSqm > 0` 且不落入上述标准档，且 `areaSqm <= 108`

## 5. 金额档位 Truth Freeze

### 5.1 金额主真相

- 金额筛选主真相正式冻结为：
  - `budgetAmount`
- 当前正式禁止：
  - 让“预算文案”或“币种展示串”成为筛选真相

### 5.2 金额档位 taxonomy

- 当前金额档位正式冻结为：
  - `0_2w`
  - `2_4w`
  - `4_6w`
  - `6_8w`
  - `8_10w`
  - `10_15w`
  - `15_20w`
  - `20w_plus`

### 5.3 金额档位判定规则

- 当前判定规则正式冻结为：
  - `0_2w` = `0 <= budgetAmount < 20000`
  - `2_4w` = `20000 <= budgetAmount < 40000`
  - `4_6w` = `40000 <= budgetAmount < 60000`
  - `6_8w` = `60000 <= budgetAmount < 80000`
  - `8_10w` = `80000 <= budgetAmount < 100000`
  - `10_15w` = `100000 <= budgetAmount < 150000`
  - `15_20w` = `150000 <= budgetAmount < 200000`
  - `20w_plus` = `budgetAmount >= 200000`

## 6. 展会 + 品牌 双字段 Truth Freeze

### 6.1 新项目展示身份

- 新项目的展示身份正式冻结为双字段：
  - `展会`
  - `品牌`
- 当前正式结论：
  - 新项目不再以单一“项目名称”作为唯一输入主真相
  - `title` 不再继续作为新项目的用户主输入字段

### 6.2 历史兼容 carrier

- 当前历史兼容正式冻结为：
  - 历史项目若只有 `title`，继续允许：
    - 列表展示
    - 详情展示
  - 历史项目在双字段缺失时：
    - `title` 继续承担兼容展示 carrier
- 当前正式禁止：
  - 直接让历史项目因为缺少新字段而不可展示

### 6.3 列表卡片主信息顺序

- 当前列表卡片最值得突出的字段顺序正式冻结为：
  1. 展会
  2. 品牌
  3. 金额
  4. 面积
  5. 地点
  6. 时间

## 7. 过期退出展示 Truth Freeze

### 7.1 当前过期真义

- 当前“过期项目直接下架不予展示”正式冻结为：
  - 只作用于公域 showcase read family
  - 不作用于：
    - `my/projects`
    - owner 私域承接

### 7.2 当前过期 carrier

- 当前对象中，过期判断的唯一结束时间 carrier 正式冻结为：
  - `plannedEndAt`
- 原因固定为：
  - 在当前项目时间字段 family 中，只有它已作为现有项目时间真相 carrier 存在
  - 当前不得凭空发明第二个“实际结束时间” persisted truth

### 7.3 当前过期规则

- 当前公域过期规则正式冻结为：
  - 当 `plannedEndAt` 非空，且 `plannedEndAt < 当前日期` 时，
    项目不再进入：
    - `project/list`
    - 面向公域的 `project/detail`
- 当前正式禁止：
  - 把这条规则偷写成新的 `project.state`
  - 把这条规则偷写成新的 persisted `visibility/displayStatus`
  - 在 Flutter/BFF 本地先伪造“已下架”状态

## 8. Explicit Non-goals

- 不直接 author `openapi.yaml`
- 不直接 author DB schema
- 不直接 author migration
- 不扩到附件公开
- 不扩到项目审核状态机
- 不扩到交易后链
- 不把过期规则误写成企业展示、论坛或其他板块通用规则

## 9. Stage Conclusion

- 当前结论：
  - `Go` for entering the `项目展示筛选与创建表单重构 contract freeze / compatibility ruling` stage
  - `No-Go` for direct implementation
  - `No-Go` for release-prep
  - `No-Go` for production release

## 10. Next Unique Action

- 下一步唯一动作：
  - 输出《项目展示筛选与创建表单重构 contract freeze / compatibility ruling》
