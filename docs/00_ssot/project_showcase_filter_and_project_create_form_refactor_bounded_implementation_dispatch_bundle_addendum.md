---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded implementation dispatch bundle for the project showcase filter and project create form refactor object so execution authoring stays inside the already-frozen truth, contract, backend, BFF, and frontend chain.
layer: L0 SSOT
freeze_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_docs_only_freeze_review_conclusion_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_implementation_dispatch_stage_gate_checklist_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_contract_freeze_compatibility_ruling_addendum.md
  - docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/project_showcase_filter_and_project_create_form_refactor_bff_aggregation_app_facing_surface_freeze_addendum.md
  - docs/04_frontend/project_showcase_filter_and_project_create_form_refactor_frontend_consumption_freeze_addendum.md
---

# 《项目展示筛选与创建表单重构 bounded implementation dispatch bundle》

## 1. Scope

- 本派工包只适用于：
  - `项目展示筛选与创建表单重构`
- 本派工包只冻结：
  - 当前实现轮的唯一目标
  - 当前允许的增量范围
  - 当前执行角色与顺序
  - 当前 retained veto 与非目标
- 本派工包不代表：
  - implementation execution 已开始
  - integration 通过
  - release-prep 通过
  - production release

## 2. Round Unique Goal

- 当前实现轮唯一目标是：
  - 只把“项目展示筛选 + 双字段创建 + 公域过期退出展示 + 历史兼容”做成有界可跑实现
- 当前主链仅包括：
  - `project/list` 的城市 / 面积 / 金额筛选
  - `project/list` 卡片主信息收口
  - `project/detail` 的双字段消费与公域过期 unavailable
  - `project/create` 的 `exhibitionName + brandName` 双字段优先输入
- 当前轮不允许：
  - 扩到 `my/projects`
  - 扩到 workbench
  - 扩到附件公开
  - 扩到审核状态机
  - 扩到交易后链

## 3. Included Scope

### 3.1 Backend Included Scope

- `apps/server` 当前只允许实现：
  - `project` 聚合新增：
    - `exhibition_name`
    - `brand_name`
  - `project/create` 的 dual-field / legacy-title 双模式承接
  - `project/list` 的 `provinceCode / cityCode / areaBucket / budgetBucket` 过滤
  - `planned_end_at` 驱动的公域 read trimming
- `apps/server` 当前不允许实现：
  - `my_project` richer 状态改造
  - 新状态机
  - 新 path family

### 3.2 BFF Included Scope

- `apps/bff` 当前只允许实现：
  - `project/list` query handoff 与当前城市上下文承接
  - `project/create` dual-field / legacy-title app-facing surface
  - `project/detail` 双字段与过期 unavailable 承接
- `apps/bff` 当前不允许实现：
  - 第二套筛选真义
  - 第二套过期状态机
  - 新 app-facing path

### 3.3 Frontend Included Scope

- `apps/mobile` 当前只允许实现：
  - 项目展示列表页筛选与压缩卡片消费
  - 项目展示详情页双字段优先消费与过期 unavailable
  - 项目创建页双字段表单
- `apps/mobile` 当前不允许实现：
  - `my/projects` 新结构
  - workbench 改造
  - 全站 UI 重做
  - 直连 `Server`

## 4. Execution Environment Boundary

- 前端只在本地执行：
  - `apps/mobile`
- `BFF` 只在云端执行：
  - `apps/bff`
- backend 只在云端执行：
  - `apps/server`
- 本地联调访问统一通过：
  - `http://127.0.0.1:8080`

## 5. Execution Order

1. `后端 Agent`
   - 先补齐 dual-field persistence carrier、list filter、expiry trimming
2. `BFF Agent`
   - 再补齐 app-facing query / create / detail shaping
3. `前端 Agent`
   - 再做列表、详情、创建页 bounded consumption closure
4. `结果校验 Agent`
   - 独立复核：
     - create
     - list filter
     - public detail unavailable
     - legacy-title compatibility
5. `联调发布 Agent`
   - 仅在前四步都通过后，重新给出当前对象的 integration judgment

## 6. Mandatory Receipt Rule

- 当前实现轮继续强制遵守：
  - backend / BFF / frontend 三份回执缺任一项，不启动结果校验
- 含义不变：
  - 后端 / BFF 回执允许先落云端
  - 前端回执先落本仓库 `docs/**`

## 7. Explicit Non-goals

- 不做 `my/projects` 新信息架构
- 不做 workbench 新信息架构
- 不做附件公开
- 不做审核状态机
- 不做交易闭环
- 不做地图 / 行政区联动
- 不做企业所在地筛选
- 不删 `title` legacy compatibility

## 8. Formal Conclusion

- 当前正式结论如下：
  - `项目展示筛选与创建表单重构 = 当前可进入 bounded implementation dispatch authoring`
  - `direct implementation / integration / release-prep / production release = 仍然 No-Go`

## 9. Next Unique Action

- 下一步唯一动作：
  - 先向 `后端 Agent` 发出《项目展示筛选与创建表单重构 backend implementation dispatch》口令

