---
owner: Codex 总控
status: frozen
purpose: Freeze the minimum backend truth and persistence mapping for project-publish address-and-scope fields only, without widening the project aggregate or entering implementation.
layer: L3 Backend
decision_date_local: 2026-04-03
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/server/src/core/migrations/migrations.ts
---

# 项目发布地址与范围后端真值与持久化补丁单

## 1. Scope

- 本补丁单只冻结 `项目发布` 的 `地址与范围` backend truth / persistence spec。
- 本补丁单只服务于：
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - 对应 internal truth pair 的真实写入与真实回读
- 本补丁单不冻结：
  - forum
  - messages
  - profile
  - enterprise hub
  - order / contract / milestone / inspection / rating / dispute
  - `project/list` 字段扩面
  - workbench 字段扩面
  - geo / map truth
  - full `Project` aggregate refactor

## 2. Current Blocker Freeze

- 当前 app-facing contract 已冻结 7 个字段：
  - `provinceName`
  - `cityName`
  - `districtName`
  - `detailAddress`
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
- 但当前本地证据仍显示：
  - [project.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/entities/project.entity.ts) 不承载这 7 个字段
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) 当前 `project` table DDL 也不承载这 7 个字段
- 因此当前 formal blocker 不是 BFF 或 Flutter，而是：
  - `Server.project` 还没有合法 persistence carrier
  - 不做 persistence + migration，就无法完成 create 真写与 detail 真读
- 本补丁单同时冻结：
  - 不允许把这些字段塞进 `description`
  - 不允许把这些字段塞进 `summary`
  - `description` 与 `summary` 都不能充当 address-range persistence surrogate

## 3. Canonical Truth Ownership Freeze

- `Server.project` 仍是这些字段的唯一 business truth owner。
- `public.project` 是这些字段当前唯一允许新增的 relational truth carrier。
- `BFF` 只能转发和聚合，不得拥有地址与范围真值。
- `Flutter App` 只能提交与消费 app-facing 字段，不得拥有地址与范围真值。

## 4. Canonical Persistence Binding

### 4.1 字段总表

| app-facing field | persistence column | DB type | nullable | create rule | detail rule |
|---|---|---|---|---|---|
| `provinceName` | `province_name` | `text` | `NOT NULL` | create 必须显式写入非空文本 | detail 必须原样回读为 `provinceName` |
| `cityName` | `city_name` | `text` | `NOT NULL` | create 必须显式写入非空文本 | detail 必须原样回读为 `cityName` |
| `districtName` | `district_name` | `text` | `NULL` | create omitted / `null` 时写 `NULL` | detail 回读 `NULL` 时返回 `null` |
| `detailAddress` | `detail_address` | `text` | `NOT NULL` | create 必须显式写入非空文本 | detail 必须原样回读为 `detailAddress` |
| `scopeSummary` | `scope_summary` | `text` | `NOT NULL` | create 必须显式写入非空文本 | detail 必须原样回读为 `scopeSummary` |
| `plannedStartAt` | `planned_start_at` | `date` | `NULL` | create omitted / `null` 时写 `NULL`；有值时按 `YYYY-MM-DD` 写入 date | detail 回读时按 app-facing `plannedStartAt` 返回 `YYYY-MM-DD` 或 `null` |
| `plannedEndAt` | `planned_end_at` | `date` | `NULL` | create omitted / `null` 时写 `NULL`；有值时按 `YYYY-MM-DD` 写入 date | detail 回读时按 app-facing `plannedEndAt` 返回 `YYYY-MM-DD` 或 `null` |

### 4.2 默认行为冻结

- `province_name` / `city_name` / `detail_address` / `scope_summary`
  - 没有业务语义上的空默认值
  - 新 create truth 必须显式写入
- `district_name`
  - 默认行为是 `NULL`
  - 表示当前未单独提供区县层级
- `planned_start_at` / `planned_end_at`
  - 默认行为是 `NULL`
  - 表示当前计划时间窗尚未确认
- 本补丁单不把空字符串冻结为 address-range business default。

## 5. Create Write Rules

- `POST /server/projects` 必须把上面 7 个字段写入 `public.project` 对应列。
- create 写入必须遵守：
  - required text fields 直接入对应 column
  - optional district/time fields 按 `null` 语义入对应 column
  - `plannedStartAt` / `plannedEndAt` 必须从 app-facing `YYYY-MM-DD` 映射到 DB `date`
- create 不允许：
  - 把 `provinceName` / `cityName` / `districtName` 拼进 `description`
  - 把 `detailAddress` / `scopeSummary` 拼进 `summary`
  - 用 `summary` 或 `description` 冒充 persistence carrier

## 6. Detail Read Rules

- `GET /server/projects/{projectId}` -> `GET /api/app/project/detail`
  必须回读这 7 个字段。
- detail read 必须遵守：
  - DB column 与 app-facing field 一一映射
  - `planned_start_at` / `planned_end_at` 从 DB `date` 回转成 `YYYY-MM-DD`
  - DB `NULL` 回读为 app-facing `null`
- detail read 不允许：
  - 改名输出
  - 把字段重新塞回 `description`
  - 只在 detail 里发明 second read model

## 7. List And Workbench Boundary

- `project/list` 当前不要求承载这 7 个字段。
- workbench 当前不要求承载这 7 个字段。
- 这不改变这些字段在 `Project` canonical truth 中已经存在。
- 当前只冻结：
  - create 必须可写
  - detail 必须可读
- 若未来 `project/list` 或 workbench 需要承载这些字段，必须另行冻结消费面要求；本补丁单不自动扩面。

## 8. Explicit Non-goals

- 不引入 `lng` / `lat`
- 不引入 `venue_name`
- 不引入 payment / publishStatus / geo / map truth
- 不重构整个 `project` 聚合
- 不改变现有 `title` / `building_type` / `budget_amount` / `description` / `state` / `summary` 语义
- 不把 address-range unlock 扩成其他板块 persistence unlock

## 9. Migration Dependency Freeze

- 一轮 additive migration 是这些字段进入 runtime truth 的必要前置。
- 合法 migration 目标只允许是：
  - `public.project`
- 该 migration 的唯一职责是：
  - 增加本补丁单冻结的 7 个 column
- 本补丁单不 author migration 文件本体，但正式冻结：
  - 没有 migration，就不能合法完成 create 真写
  - 没有 migration，就不能合法完成 detail 真读
