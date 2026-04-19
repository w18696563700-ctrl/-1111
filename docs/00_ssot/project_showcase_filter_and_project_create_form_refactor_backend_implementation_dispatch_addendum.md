---
owner: Codex 总控
status: active
purpose: Freeze the backend implementation dispatch prompt for the project showcase filter and project create form refactor object so Server execution stays inside the frozen dual-field identity, list-filter truth, and public expiry-trimming boundary.
layer: L0 SSOT
freeze_date_local: 2026-04-11
based_on:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bounded_implementation_dispatch_bundle_addendum.md
  - docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_contract_freeze_compatibility_ruling_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 《项目展示筛选与创建表单重构 backend implementation dispatch》

## 当前阶段

- 主对象：
  - `项目展示筛选与创建表单重构`
- 子阶段：
  - `bounded implementation dispatch / backend`
- 当前只允许处理：
  - `Server.project` 的 dual-field persistence
  - `project/list` 的筛选真义落地
  - `project/list / project/detail` 的 public expiry trimming 落地

## 当前唯一动作

- 发给 `后端 Agent` 的唯一执行口令如下。

```text
你是后端 Agent（仅云端），本轮不是重构整个 project 聚合，而是只实现《项目展示筛选与创建表单重构》在 Server 侧已经冻结好的最小增量范围。

【一、唯一目标】
你这轮只完成 4 件事：
1. 给 `public.project` 增加双字段持久化 carrier：
   - `exhibition_name`
   - `brand_name`
2. 让 `POST /server/projects` / `POST /api/app/project/create` 支持：
   - `dual-field mode`
   - `legacy-title mode`
3. 让 `GET /server/projects` / `GET /api/app/project/list` 支持：
   - `provinceCode`
   - `cityCode`
   - `areaBucket`
   - `budgetBucket`
   的后端真义过滤
4. 让公域 `project/list` 与公域 continuation 下的 `project/detail` 支持：
   - 基于 `planned_end_at` 的 public expiry trimming

【二、强制阅读】
- docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
- docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_contract_freeze_compatibility_ruling_addendum.md
- docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
- docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_bounded_implementation_dispatch_bundle_addendum.md
- docs/01_contracts/openapi.yaml

【三、只允许处理的范围】
- apps/server/src/modules/project/**
- apps/server/src/core/migrations/migrations.ts
- 与 `project/list` / `project/detail` / `project/create` 直接相关的最小 supporting touch

【四、禁止事项】
- 不得改 `my_project` 聚合
- 不得改 workbench
- 不得新增新 path family
- 不得新增新状态机
- 不得新增：
  - `area_bucket`
  - `budget_bucket`
  - `expired`
  - `display_status`
- 不得删除 `title`
- 不得把 `plannedEndAt` 改写成：
  - `project.state`
  - `publishedAt`
  - `formalCompletionStatus`
- 不得扩到附件公开、审核状态机、交易后链

【五、必须落实的真义】
1. dual-field persistence
- dual-field mode 下：
  - `exhibitionName -> exhibition_name`
  - `brandName -> brand_name`
  - `title` 仍必须 materialize 为非空 compatibility carrier
- legacy-title mode 下：
  - `title` 正常写入
  - `exhibition_name = NULL`
  - `brand_name = NULL`

2. 城市筛选
- 只认：
  - `province_code`
  - `city_code`
- 不得把企业所在地当成项目落地城市
- 不得把：
  - `district_code`
  - `detail_address`
  引入本轮主筛选

3. 面积筛选
- 只认 `area_sqm`
- 只认以下 taxonomy：
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

4. 金额筛选
- 只认 `budget_amount`
- 只认以下 taxonomy：
  - `0_2w`
  - `2_4w`
  - `4_6w`
  - `6_8w`
  - `8_10w`
  - `10_15w`
  - `15_20w`
  - `20w_plus`

5. public expiry trimming
- `planned_end_at IS NULL`：
  - 继续可展示
- `planned_end_at >= CURRENT_DATE`：
  - 继续可展示
- `planned_end_at < CURRENT_DATE`：
  - 不进入公域 `project/list`
  - 当作为公域 continuation 使用时，`project/detail` 允许返回受控 unavailable
- 不得影响：
  - `my/projects`
  - owner 私域承接

【六、完成标准】
- migration 已补齐：
  - `exhibition_name`
  - `brand_name`
- create 已支持：
  - dual-field mode
  - legacy-title mode
- list 已支持：
  - `provinceCode / cityCode / areaBucket / budgetBucket`
- public list 已按 `planned_end_at` 做 trimming
- public detail continuation 已能对 expired project 返回受控 unavailable

【七、回执要求】
回执必须单独落盘，并给出云端绝对路径。回执至少包含：
1. 当前对象
2. 修改文件清单
3. migration 变更清单
4. create / list / detail 的最小 smoke 结果
5. dual-field mode 与 legacy-title mode 的样本说明
6. 过期 trimming 样本说明
7. 当前剩余阻断项
8. 是否可移交 `BFF Agent`

【八、输出禁令】
- 不要写“应该可以”
- 不要跳过 migration
- 不要把 `title` 兼容删除
- 不要把实现范围扩到 `my_project`
- 只给真实代码修改与真实 smoke 结果
```

