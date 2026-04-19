---
owner: Codex 总控
status: active
purpose: Submit the stage gate checklist for the project-showcase filter and project-create-form refactor object, so the next round can author bounded truth and contract prompts without skipping scope control.
layer: L0 SSOT
based_on:
  - docs/00_ssot/post_enterprise_hub_v1_next_bounded_object_ruling_addendum.md
  - docs/00_ssot/three_board_mainline_maintenance_only_follow_up_judgment_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/00_ssot/project_publish_round_a_consumption_truth_and_ui_boundary_freeze_addendum.md
  - docs/00_ssot/project_permission_and_state_unified_ruling_addendum.md
  - docs/00_ssot/project_business_closure_strategy_freeze_addendum.md
  - docs/00_ssot/gate_register_v1.md
freeze_date_local: 2026-04-11
---

# 《项目展示筛选与创建表单重构 阶段门禁核查表》

## 1. Scope

- 当前对象：
  - `项目展示筛选与创建表单重构`
- 本门禁只服务于：
  - 判断当前是否允许进入 bounded truth/contract authoring
- 本门禁不代表：
  - 直接进入实现
  - `release-prep`
  - `production release`

## 2. Passed Gates

- 现有主链基础 gate：
  - passed
  - `project/create`、`project/list`、`project/detail` 已有真实运行基础
- 地点标准化 gate：
  - passed
  - `province/city/district code + name` 真源与 contract 已冻结
- 项目展示列表/详情基础字段 gate：
  - passed
  - 当前列表/详情真源边界已存在
- 架构边界 gate：
  - passed
  - `Flutter App -> BFF -> Server` 唯一主通道不变
  - 不需要新 building、不需要新壳
- 对象有界性 gate：
  - passed
  - 当前对象已收敛为：
    - 筛选语义
    - 双字段表单
    - 卡片密度
    - 过期退出展示
    - 历史兼容

## 3. Failed Gates

- 筛选 taxonomy freeze gate：
  - failed
  - 当前还没有正式冻结：
    - 面积档位 taxonomy
    - 金额档位 taxonomy
- `title` 双字段替代 gate：
  - failed
  - 当前还没有正式冻结：
    - `展会 + 品牌` 的字段真义
    - create / detail / list / 历史项目兼容策略
- 过期退出展示 gate：
  - failed
  - 当前还没有正式冻结：
    - 以哪个真实时间字段为准
    - 是 read-time 过滤，还是新的 visibility/downshelf 语义
- 直接实现 gate：
  - failed
- `release-prep` gate：
  - failed
- `production release` gate：
  - failed

## 4. Veto Gates

- 不得把这轮误写成纯前端 UI 优化
- 不得在 Flutter 或 BFF 私造筛选真义
- 不得在未冻结前把面积档位、金额档位当作正式真相
- 不得直接把 `title` 改没而不处理历史兼容
- 不得在未冻结 visibility 语义前，用前端本地规则伪造“过期下架”
- 不得扩到交易后链、附件公开、独立审核状态机

## 5. Stage Go / No-Go Decision

- `Go` for：
  - `项目展示筛选与创建表单重构` bounded truth/contract authoring
- `No-Go` for：
  - direct implementation dispatch
  - `release-prep`
  - `production release`
  - scope expansion beyond the current bounded object

## 6. Current Gate Meaning

- 当前允许的含义：
  - 可以开始写这轮对象的边界冻结、真源拆分、contract authoring 派工包
- 当前不允许的含义：
  - 不能直接改代码
  - 不能直接改 schema
  - 不能把“更专业”当作跳过门禁的理由

## 7. Next Unique Action

- 下一轮唯一动作：
  - 输出《项目展示筛选与创建表单重构 bounded dispatch bundle》
