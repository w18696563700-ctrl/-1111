---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the BFF aggregation and app-facing surface boundary for the project
  showcase filter and project create form refactor object, limited to the
  existing public project list/detail and create paths only.
layer: L4 BFF
decision_date_local: 2026-04-11
inputs_canonical:
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_truth_boundary_freeze_addendum.md
  - docs/00_ssot/project_showcase_filter_and_project_create_form_refactor_contract_freeze_compatibility_ruling_addendum.md
  - docs/02_backend/project_showcase_filter_and_project_create_form_refactor_backend_truth_persistence_freeze_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/02_backend/project_showcase_publish_alignment_persistence_truth_addendum.md
  - docs/00_ssot/current_publish_experience_optimization_truth_freeze_addendum.md
  - docs/00_ssot/current_publish_experience_optimization_contract_freeze_addendum.md
  - docs/00_ssot/my_project_entry_and_single_project_private_carry_contract_freeze_addendum.md
  - docs/02_backend/my_project_entry_and_single_project_private_carry_persistence_truth_addendum.md
  - docs/01_contracts/openapi.yaml
---

# 项目展示筛选与创建表单重构 BFF aggregation / app-facing surface freeze

## 1. Scope

- 本冻结单只服务于：
  - `GET /api/app/project/list`
  - `GET /api/app/project/detail`
  - `POST /api/app/project/create`
- 本冻结单不进入：
  - 新 path family
  - 新 preview-only schema
  - 新 visibility schema
  - 项目审核状态机
  - 附件公开
  - `my/projects` richer 状态改造

## 2. BFF Truth Boundary

- `BFF` 当前只允许：
  - 转发 query
  - 做当前城市上下文承接
  - 做 app-facing 字段整形
  - 做 public expiry trimming 的受控承接
- `BFF` 当前不得：
  - 拥有第二套城市筛选真义
  - 拥有第二套面积档位真义
  - 拥有第二套金额档位真义
  - 拥有第二套过期状态机
  - 在本地伪造 `exhibitionName / brandName`
  - 把企业所在地改写成项目展示落地城市

## 3. `GET /api/app/project/list`

### 3.1 Allowed Query Handoff

- `BFF` 必须承接：
  - `provinceCode`
  - `cityCode`
  - `areaBucket`
  - `budgetBucket`

### 3.2 Default City Context

- 当调用方未显式给出城市 query 时，`BFF` 允许承接既有当前城市上下文。
- 当前默认优先级必须保持：
  1. 手动选择城市
  2. 当前定位 / 当前城市上下文
  3. 全国兜底
- `BFF` 当前不得新增：
  - `cityContextSource`
  - `nationalMode`
  - 任何新的 app-facing location meta schema

### 3.3 Filter Meaning Guardrail

- `BFF` 只能转发和整形既有冻结真义：
  - 城市筛选只认 `provinceCode / cityCode`
  - 面积筛选只认 `areaSqm` 对应既有 taxonomy
  - 金额筛选只认 `budgetAmount` 对应既有 taxonomy
- `BFF` 不得：
  - 接入 `districtCode` 作为本轮主筛选
  - 接入 `detailAddress` 作为本轮主筛选
  - 接入企业所在地筛选

## 4. `POST /api/app/project/create`

### 4.1 App-facing Create Surface

- `BFF` 必须承接：
  - `exhibitionName`
  - `brandName`
  - `title`

### 4.2 Compatibility Mode

- 当前正式允许两种 app-facing create mode：
  - `dual-field mode`
  - `legacy-title mode`
- `BFF` 必须明确：
  - `dual-field mode` 可走
  - `legacy-title mode` 可走
- `BFF` 当前不得：
  - 只放行单独 `exhibitionName`
  - 只放行单独 `brandName`
  - 把双字段退化成只传 `title`

### 4.3 Non-goal On Create

- `BFF` 不得借本轮 create 扩到：
  - 新字段族
  - 新 preview-only create schema
  - 审核相关字段
  - 交易后链字段

## 5. `GET /api/app/project/detail`

### 5.1 Detail Surface

- `BFF` 必须承接：
  - `exhibitionName`
  - `brandName`
  - `plannedStartAt`
  - `plannedEndAt`
  - `title` fallback

### 5.2 Public Expiry Trimming

- 当 detail 作为公域 continuation 使用且项目已过期时：
  - `BFF` 允许承接受控 unavailable 语义
- 这里的过期只按：
  - `plannedEndAt`
  做 public read trimming

### 5.3 Hard Boundary

- `BFF` 不得：
  - 影响 owner 私域读取
  - 改写 `my/projects`
  - 把公域 unavailable 写成 persisted visibility 变更

## 6. Card Field Priority Support

- `BFF` 输出语义必须支持前端按以下顺序消费：
  1. 展会
  2. 品牌
  3. 金额
  4. 面积
  5. 地点
  6. 时间
- `title` 当前只允许作为 fallback。
- `BFF` 不得继续把旧 `title` 强行当唯一第一展示位。

## 7. Explicit Non-goals

- 不扩到 `workbench`
- 不扩到附件
- 不扩到 review state machine
- 不扩到交易后链
- 不扩到企业所在地筛选

## 8. Stage Conclusion

- `Go for frontend consumption freeze`
- `No-Go for direct implementation`
- `No-Go for release-prep`
- `No-Go for production release`
