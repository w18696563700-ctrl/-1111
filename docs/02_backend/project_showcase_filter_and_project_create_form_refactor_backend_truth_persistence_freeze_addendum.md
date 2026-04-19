---
owner: Codex 总控
status: frozen
purpose: Freeze the backend truth and persistence boundary for the project-showcase filter and project-create-form refactor, limited to dual-field project identity, list-filter truth binding, public expiry trimming, and historical compatibility.
layer: L3 Backend
decision_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_contract_freeze_compatibility_ruling_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/02_backend/project_publish_address_range_persistence_truth_addendum.md
  - docs/02_backend/project_publish_round_b_persistence_truth_addendum.md
  - docs/02_backend/project_location_standardization_persistence_truth_addendum.md
  - docs/02_backend/project_showcase_publish_alignment_persistence_truth_addendum.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/server/src/core/migrations/migrations.ts
---

# 项目展示筛选与创建表单重构后端真值与持久化冻结单

## 1. Scope

- 本冻结单只覆盖：
  - `项目展示筛选与创建表单重构 backend truth / persistence freeze`
- 本冻结单只服务于：
  - `POST /api/app/project/create`
  - `GET /api/app/project/list`
  - `GET /api/app/project/detail`
  - 对应 internal `Server.project` truth 的真实写入、真实筛选、真实回读
- 本冻结单只处理 `project` 聚合。
- 本冻结单不进入：
  - backend / BFF / Flutter 实现
  - 新 path family
  - 独立 `visibility/displayStatus`
  - 项目审核状态机
  - 附件公开
  - 交易后链
  - `my/projects` richer 状态重构

## 2. Persistence Freeze Conclusion

- `Server.project` 继续是本轮唯一 business truth owner。
- `public.project` 继续是本轮唯一允许承载新增项目展示身份字段的 relational truth carrier。
- 本轮新增的持久化真值只限于：
  - `exhibitionName`
  - `brandName`
- 本轮列表筛选真义继续依赖既有 `public.project` 真字段：
  - standardized location `code + name`
  - `area_sqm`
  - `budget_amount`
  - `planned_end_at`
- 本轮正式禁止新增：
  - `area_bucket`
  - `budget_bucket`
  - `expired`
  - `display_status`
  - `showcase_city_context`
  - 任何 list-only projection table
  - 任何 detail-only shadow aggregate
- `plannedEndAt` 在本轮只承担公域展示 read eligibility trimming 输入，不得被改写成：
  - persisted visibility state
  - formal completion truth
  - owner 历史归档 truth

## 3. Canonical Truth Ownership Freeze

- `Server.project` 仍是以下字段与规则的唯一 business truth owner：
  - `title`
  - `exhibitionName`
  - `brandName`
  - `provinceCode / provinceName`
  - `cityCode / cityName`
  - `areaSqm`
  - `budgetAmount`
  - `plannedStartAt`
  - `plannedEndAt`
- `BFF` 只能做 app-facing 聚合、上下文解析、可见性裁剪，不得拥有第二套项目展示筛选真值。
- `Flutter App` 只能提交与消费 app-facing contract，不得本地持有：
  - 面积档位真值
  - 金额档位真值
  - 过期展示真值
- `my/projects` 的 `formalCompletionStatus / evaluationStatus` 继续由既有冻结单承载，本轮不得被 `plannedEndAt` 反向覆盖。

## 4. Canonical Persistence Carrier Freeze

### 4.1 `public.project` 仍是唯一 carrier

- 以下字段当前继续只允许由 `public.project` 承载：
  - `title`
  - `exhibition_name`
  - `brand_name`
  - `province_code`
  - `province_name`
  - `city_code`
  - `city_name`
  - `area_sqm`
  - `budget_amount`
  - `planned_start_at`
  - `planned_end_at`
- 本轮不允许新增：
  - showcase list table
  - showcase detail table
  - filter snapshot table
  - expired-project table

### 4.2 字段总表

| app-facing field | persistence column | DB type | nullable | create rule | read rule |
|---|---|---|---|---|---|
| `title` | `title` | `text` | `NOT NULL` | dual-field mode 下必须落一个非空 compatibility title；legacy-title mode 继续按既有规则写入 | `project/list` / `project/detail` / `my/projects.publicProject` 继续可回读 |
| `exhibitionName` | `exhibition_name` | `text` | `NULL` | dual-field mode 必写；legacy-title mode 写 `NULL` | DB `NULL` 回读为 `null` |
| `brandName` | `brand_name` | `text` | `NULL` | dual-field mode 必写；legacy-title mode 写 `NULL` | DB `NULL` 回读为 `null` |
| `plannedStartAt` | `planned_start_at` | `date` | `NULL` | 继续沿用既有 address-range 规则 | 继续沿用既有 detail/list 回读规则 |
| `plannedEndAt` | `planned_end_at` | `date` | `NULL` | 继续沿用既有 address-range 规则 | 继续沿用既有 detail/list 回读规则，并额外参与公域 read trimming |

## 5. Project Create Write Truth Freeze

### 5.1 双字段优先写入

- `POST /server/projects` 在本轮正式允许两种 create truth：
  - `dual-field mode`
  - `legacy-title mode`

### 5.2 `dual-field mode`

- 当 request 提交：
  - `exhibitionName`
  - `brandName`
  时，backend truth 必须：
  - 把 `exhibitionName` 写入 `project.exhibition_name`
  - 把 `brandName` 写入 `project.brand_name`
  - 在入库前 materialize 一个非空 `project.title` 作为 compatibility carrier
- 当前正式冻结为：
  - `title` 在 dual-field mode 下仍必须入库
  - 但它不再是新项目的 primary display identity truth
- 当前不冻结：
  - `title` 的最终展示拼接样式文案
- 当前正式禁止：
  - dual-field mode 只写 `title` 不写 `exhibition_name / brand_name`
  - dual-field mode 把 `exhibitionName / brandName` 塞回 `summary`
  - dual-field mode 只写其中一个字段

### 5.3 `legacy-title mode`

- 旧 client 继续允许只提交：
  - `title`
- backend truth 在 legacy-title mode 下正式冻结为：
  - `project.title` 继续真实写入
  - `project.exhibition_name` 写 `NULL`
  - `project.brand_name` 写 `NULL`
- 当前正式不允许：
  - 因双字段升级直接拒绝合法 legacy-title create

## 6. List Filter Backend Truth Freeze

### 6.1 城市筛选真义

- `project/list` 的城市筛选当前只允许依赖：
  - `project.province_code`
  - `project.city_code`
- 后端过滤规则正式冻结为：
  - 仅传 `provinceCode`：
    - 按 `project.province_code = provinceCode` 过滤
  - 仅传 `cityCode`：
    - 按 `project.city_code = cityCode` 过滤
  - 两者都传：
    - 同时按 `province_code + city_code` 过滤
- 当前正式禁止：
  - `district_code` 进入本轮主筛选真义
  - `detail_address` 进入本轮主筛选真义
  - 企业发布方所在地进入本轮主筛选真义

### 6.2 面积档位真义

- `areaBucket` 只是 query 语义，不是 persisted column。
- 后端必须按 `project.area_sqm` 做 bucket 判断：
  - `9_sqm` = `area_sqm = 9`
  - `18_sqm` = `area_sqm = 18`
  - `27_sqm` = `area_sqm = 27`
  - `36_sqm` = `area_sqm = 36`
  - `54_sqm` = `area_sqm = 54`
  - `72_sqm` = `area_sqm = 72`
  - `81_sqm` = `area_sqm = 81`
  - `90_sqm` = `area_sqm = 90`
  - `108_sqm` = `area_sqm = 108`
  - `gt_108_sqm` = `area_sqm > 108`
  - `custom_sqm` = `area_sqm > 0 AND area_sqm <= 108` 且不命中上述标准档位
- 当前正式冻结为：
  - `area_sqm IS NULL` 的项目不命中任何面积档位
- 当前正式禁止：
  - 新增 `area_bucket` 列
  - 用展示标签文本代替数值判断

### 6.3 金额档位真义

- `budgetBucket` 只是 query 语义，不是 persisted column。
- 后端必须按 `project.budget_amount` 做 bucket 判断：
  - `0_2w` = `0 <= budget_amount < 20000`
  - `2_4w` = `20000 <= budget_amount < 40000`
  - `4_6w` = `40000 <= budget_amount < 60000`
  - `6_8w` = `60000 <= budget_amount < 80000`
  - `8_10w` = `80000 <= budget_amount < 100000`
  - `10_15w` = `100000 <= budget_amount < 150000`
  - `15_20w` = `150000 <= budget_amount < 200000`
  - `20w_plus` = `budget_amount >= 200000`
- 当前正式冻结为：
  - `budget_amount IS NULL` 的项目不命中任何金额档位
- 当前正式禁止：
  - 新增 `budget_bucket` 列
  - 把金额区间写成新的 persisted business truth

## 7. Public Expiry Read Trimming Freeze

### 7.1 列表裁剪

- `project/list` 当前正式冻结为：
  - 只返回仍具备公域展示资格的项目
- 公域展示资格的唯一时间裁剪规则是：
  - `planned_end_at IS NULL`
    - 继续可展示
  - `planned_end_at >= CURRENT_DATE`
    - 继续可展示
  - `planned_end_at < CURRENT_DATE`
    - 不进入公域 `project/list`

### 7.2 详情裁剪

- shared `GET /server/projects/{projectId}` -> `GET /api/app/project/detail`
  当前正式冻结为：
  - 当被公域 showcase continuation 使用时，
    `planned_end_at < CURRENT_DATE` 的项目允许返回受控 unavailable 语义
- 当前正式不影响：
  - `my/projects`
  - owner private continuation

### 7.3 非状态机裁剪

- 本轮正式重申：
  - 过期退出展示只是 public read trimming
  - 不是 persisted state transition
- 当前正式禁止把 `plannedEndAt` 直接改写成：
  - `project.state`
  - `publishedAt`
  - `formalCompletionStatus`
  - `visibility`
  - `displayStatus`

## 8. Historical Compatibility Freeze

### 8.1 历史项目行

- 历史 `project` rows 可能只具备：
  - `title`
  而没有：
  - `exhibition_name`
  - `brand_name`
- 旧数据兼容规则正式冻结为：
  - additive migration 后，历史行允许 `exhibition_name / brand_name` 保持 `NULL`
  - `project/list` / `project/detail` / `my/projects.publicProject` 对旧项目继续回读：
    - `title`
    - `exhibitionName = null`
    - `brandName = null`
- 当前不要求：
  - 一次性回填旧项目的展会/品牌字段

### 8.2 历史项目筛选兼容

- 历史项目是否可进入筛选，只取决于现有真字段是否存在：
  - `province_code / city_code`
  - `area_sqm`
  - `budget_amount`
  - `planned_end_at`
- 当前正式冻结为：
  - 不得因旧项目缺 `exhibition_name / brand_name` 就失去筛选资格

## 9. Migration Dependency Freeze

- 一轮 additive migration 是本轮 dual-field persistence 进入 runtime truth 的必要前置。
- 合法 migration 目标只允许是：
  - `public.project`
- 该 migration 的唯一新增列只允许是：
  - `exhibition_name`
  - `brand_name`
- 本轮正式冻结为：
  - 城市筛选真义继续依赖既有 standardized location columns
  - 面积与金额档位继续依赖既有 `area_sqm / budget_amount`
  - 过期裁剪继续依赖既有 `planned_end_at`
- 因此本轮正式不 author：
  - `area_bucket`
  - `budget_bucket`
  - `expired`
  - `display_status`
  - `public_visible_until`

## 10. Explicit Non-goals

- 不重构整个 `project` 聚合
- 不新增 list-only / detail-only projection table
- 不扩到 `my/projects` richer 状态结构
- 不扩到 workbench richer 状态结构
- 不扩到附件公开
- 不扩到审核状态机
- 不扩到交易后链
- 不把“发布公司在上海、项目落地在重庆”误写成企业城市筛选

## 11. Stage Conclusion

- 当前结论：
  - `Go` for entering the `项目展示筛选与创建表单重构 BFF aggregation / app-facing surface freeze` stage
  - `No-Go` for direct implementation
  - `No-Go` for release-prep
  - `No-Go` for production release
- 本冻结单的真实含义是：
  - `project` 聚合的新增持久化 carrier 已经写清
  - 列表筛选、过期裁剪、双字段兼容都已经落到 backend truth 层
  - 下一步应先冻结 BFF 的 app-facing 聚合与上下文承接边界

## 12. Next Unique Action

- 下一步唯一动作：
  - 输出《项目展示筛选与创建表单重构 BFF aggregation / app-facing surface freeze》
