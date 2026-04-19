---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Flutter consumption boundary for the project showcase filter and
  project create form refactor object, limited to the public list page, public
  detail page, and create page only.
layer: L5 Frontend
decision_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_contract_freeze_compatibility_ruling_addendum.md
  - docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_showcase_filter_and_project_create_form_refactor_bff_aggregation_app_facing_surface_freeze_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/current_publish_experience_optimization_truth_freeze_addendum.md
  - docs/00_ssot/current_publish_experience_optimization_contract_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 项目展示筛选与创建表单重构 frontend consumption freeze

## 1. Scope

- 本冻结单只服务于：
  - 项目展示列表页
  - 项目展示详情页
  - 项目创建页
- 本冻结单不进入：
  - `workbench`
  - `my/projects` 新信息架构
  - 附件公开
  - 审核状态机
  - 交易后链

## 2. 列表页消费冻结

- 列表页必须正式冻结：
  - 默认先按当前城市上下文承接
  - 用户可手动切城市
  - 可按面积档位筛选
  - 可按金额档位筛选
- 当前城市上下文优先级必须保持：
  1. 手动选择城市
  2. 当前定位 / 当前城市上下文
  3. 全国兜底
- 列表页必须区分：
  - real content-state
  - real empty-state
  - blocker / failure state
- 当前不得把 empty-state 伪装成“已接通成功”。

## 3. 列表卡片信息结构冻结

- 卡片压缩后的主展示顺序必须冻结为：
  1. 展会
  2. 品牌
  3. 金额
  4. 面积
  5. 地点
  6. 时间
- `title` 只作 fallback。
- 当前不得继续让单张卡片占据过大纵向空间。
- 但这轮只冻结消费结构，不做视觉实现稿扩面。

## 4. 详情页消费冻结

- 当 `exhibitionName / brandName` 存在时：
  - 详情页必须优先消费双字段
- `title` 只作 fallback。
- 公域详情遇到过期项目时：
  - 只允许受控 unavailable
- 当前不得自行把过期项目继续当正常公开项目展示。

## 5. 创建页消费冻结

- 原“项目名称”当前升级为两格：
  - 第一格：展会
  - 第二格：品牌
- 旧 `title` 兼容继续保留在 contract 层。
- 前端新表单必须优先消费：
  - `dual-field mode`
- 当前不得：
  - 自行删除 legacy compatibility
  - 借机扩到更多新字段

## 6. 文案与状态边界

- 前端文案必须明确：
  - 公域展示是只读展示
  - 筛选结果是当前条件下结果
  - 过期退出展示不等于项目不存在
- 当前不得把公域退出展示误写成：
  - owner 私域也不可见
  - 项目已经不存在
  - 项目已经正式完结

## 7. Explicit Non-goals

- 不重做全站 UI
- 不扩到“公司所在地”筛选
- 不扩到新的地图 / 行政区联动
- 不扩到 `my/projects` 主结构重构

## 8. Stage Conclusion

- `Go for docs-only freeze review / implementation dispatch authoring`
- `No-Go for direct implementation`
- `No-Go for release-prep`
- `No-Go for production release`
