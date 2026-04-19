---
owner: Codex 总控
status: active
purpose: Freeze the bounded dispatch bundle for the project-showcase filter and project-create-form refactor object, limiting the next round to truth, contract, and compatibility authoring instead of premature implementation.
layer: L0 SSOT
based_on:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/00_ssot/project_publish_round_a_consumption_truth_and_ui_boundary_freeze_addendum.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/project_business_closure_strategy_freeze_addendum.md
freeze_date_local: 2026-04-11
---

# 《项目展示筛选与创建表单重构 bounded dispatch bundle》

## 1. Scope

- 本派工包只适用于：
  - `项目展示筛选与创建表单重构`
- 本派工包只冻结：
  - truth/contract authoring 范围
  - 兼容策略 authoring 范围
  - 当前不允许做的事项
- 本派工包不代表：
  - 实现派工
  - release-prep
  - production release

## 2. Current Goal

- 当前目标固定为：
  - 把“更专业的项目展示与创建体验”收敛成一个可实现的单一对象
- 当前必须一起冻结的 5 件事：
  1. 默认城市上下文与城市筛选语义
  2. 面积档位筛选 taxonomy
  3. 金额档位筛选 taxonomy
  4. `项目名称 -> 展会 + 品牌` 双字段承接与历史兼容
  5. 过期项目退出展示的真实规则

## 3. Included Scope

### 3.1 Truth Authoring Included Scope

- 只允许冻结：
  - 当前展示列表默认城市上下文优先级
    - `手动城市`
    - `定位/当前城市`
    - `全国兜底`
  - 城市筛选主真义是否直接依赖：
    - `provinceCode`
    - `cityCode`
  - 面积筛选是否正式依赖：
    - `areaSqm`
    - 以及哪一套分档 taxonomy
  - 金额筛选是否正式依赖：
    - `budgetAmount`
    - 以及哪一套分档 taxonomy
  - `展会 + 品牌` 是否进入正式真源
  - 过期项目退出展示到底依赖：
    - 现有时间字段 read-time 过滤
    - 还是未来独立 visibility/downshelf carrier

### 3.2 Contract Authoring Included Scope

- 只允许 author：
  - `project/list` 查询参数是否新增：
    - `provinceCode`
    - `cityCode`
    - `areaBucket`
    - `budgetBucket`
  - `ProjectShowcaseListItemReadModel` 是否需要新增：
    - `exhibitionName`
    - `brandName`
    - 或继续由兼容层派生展示标题
  - `ProjectCreateRequest` 是否从单一 `title` 调整为：
    - `exhibitionName`
    - `brandName`
    - 或保留 `title` 作为兼容 carrier
  - 历史 `title` 项目如何兼容展示与筛选

### 3.3 Frontend Consumption Authoring Included Scope

- 只允许冻结消费边界：
  - 列表卡片最突出的字段顺序
  - 筛选条与列表结果的关系
  - 空态 / 无命中 / 过期过滤后的受控状态
- 当前建议冻结的卡片核心字段顺序为：
  - 展会
  - 品牌
  - 金额
  - 面积
  - 地点
  - 时间

## 4. Explicit Non-goals

- 不直接改代码
- 不直接改数据库
- 不直接改 openapi 生成产物
- 不扩到附件公开
- 不扩到独立审核状态机
- 不扩到交易后链
- 不在 BFF 或 Flutter 先做伪下架状态
- 不在当前轮直接把 enterprise_hub 或其他板块混进来

## 5. Execution Order

1. `总控`
   - 先出 `truth boundary freeze`
2. `总控`
   - 再出 `contract freeze / compatibility ruling`
3. `总控`
   - 再决定是否允许进入 backend/BFF/frontend bounded implementation prompt

## 6. Formal Conclusion

- 当前正式结论如下：
  - `Go for 项目展示筛选与创建表单重构 bounded truth/contract authoring`
  - `No-Go for direct implementation dispatch`
  - `No-Go for release-prep`
  - `No-Go for production release`

## 7. Next Unique Action

- 下一步唯一动作：
  - 输出《项目展示筛选与创建表单重构 truth boundary freeze》
