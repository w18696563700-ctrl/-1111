---
owner: Codex 总控
status: active
purpose: Freeze the next unique bounded object after enterprise_hub V1 reaches a no-new-sub-object state, so the project can reopen a professionalization-focused project-display object without silently drifting or pretending the work is frontend-only.
layer: L0 SSOT
based_on:
  - docs/00_ssot/enterprise_hub_v1_current_active_sub_object_ruling_addendum.md
  - docs/00_ssot/three_board_mainline_maintenance_only_follow_up_judgment_addendum.md
  - docs/00_ssot/three_board_mainline_integration_release_review_conclusion_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/project_business_closure_strategy_freeze_addendum.md
  - docs/00_ssot/gate_register_v1.md
freeze_date_local: 2026-04-11
---

# 《enterprise_hub V1 后续唯一 bounded object 裁决单》

## 1. Scope

- 本裁决单只回答两件事：
  - `enterprise_hub V1` 当前没有新的 active sub-object 之后，后续唯一 bounded object 是什么
  - 当前是否需要新的《阶段门禁核查表》
- 本裁决单不代表：
  - 直接进入实现
  - `release-prep`
  - `production release`

## 2. Current Situation

- 当前正式状态已经冻结为：
  - `enterprise_hub V1` 仍是最近一轮 active board 的收口对象
  - 但当前 `没有新的 active sub-object`
  - `EXH-006A + EXH-006` 已转入 `maintenance-only`
- 因此当前不能继续假装：
  - `enterprise_hub V1` 里还有一个默认下一对象在自动推进
  - 或者用户提出的新方向只是前端样式微调，不需要重新开对象

## 3. Candidate Inventory Conclusion

- 基于当前用户明确指定的新方向，当前唯一 next bounded object candidate 正式裁定为：
  - `项目展示筛选与创建表单重构`
- 该对象当前只包含以下 6 个子问题：
  1. 项目展示列表默认按当前城市上下文优先承接
  2. 城市筛选
  3. 面积档位筛选
  4. 金额档位筛选
  5. 项目卡片信息密度重排
  6. 创建项目从单一 `项目名称/title` 改为 `展会 + 品牌` 双字段承接
- 当前同时强制绑定两条补充约束：
  - 过期项目必须按真实时间规则退出公域展示
  - 历史项目必须保留受控兼容策略

## 4. Why This Is Not A Frontend-only Polish Round

- 当前正式判断如下：
  - 这不是单纯前端改版
  - 也不是“为了更专业”就能直接跳过冻结的 UI 重绘
- 原因固定为：
  - 城市筛选会直接触及：
    - `provinceCode / cityCode` 查询语义
    - 默认城市上下文语义
  - 面积筛选会直接触及：
    - `areaSqm` 分档 taxonomy
  - 金额筛选会直接触及：
    - `budgetAmount` 分档 taxonomy
  - `展会 + 品牌` 会直接触及：
    - create request 字段边界
    - detail / list 回读字段边界
    - 历史 `title` 兼容
  - 过期下架会直接触及：
    - 当前项目展示准入规则
    - 时间字段 owner
    - `visibility / 下架` 语义边界
- 因此这轮正确动作不是拒绝推进，而是：
  - 把它作为正式 bounded object 打开

## 5. Whether A New Stage Gate Checklist Is Required

- 结论：
  - `需要`
- 原因固定为：
  - 当前三板块主线已处于 `maintenance-only`
  - 当前新对象不属于“已验证主链的小修小补”
  - 当前新对象会改动：
    - truth boundary
    - contract boundary
    - compatibility strategy
    - query semantics
  - 因此不得直接沿用旧门禁结果发实现派工

## 6. Formal Conclusion

- 当前唯一 next bounded object candidate：
  - `项目展示筛选与创建表单重构`
- 当前正式意义：
  - 这是一个真实的跨层专业化对象
  - 不是前端孤立样式 round
- 当前下一步必须先做：
  - 新的《阶段门禁核查表》
- 当前仍然：
  - `No-Go for direct implementation dispatch`
  - `No-Go for release-prep`
  - `No-Go for production release`

## 7. Next Unique Action

- 下一轮唯一动作：
  - 提交《项目展示筛选与创建表单重构 阶段门禁核查表》
