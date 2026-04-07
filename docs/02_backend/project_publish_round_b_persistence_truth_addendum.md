---
owner: Codex 总控
status: frozen
purpose: Freeze the Round B backend truth and persistence mapping for the three admitted richer project-publish fields only, without widening any other aggregate or entering implementation.
layer: L3 Backend
decision_date_local: 2026-04-04
inputs_canonical:
  - docs/00_ssot/project_publish_round_b_truth_freeze_addendum.md
  - docs/00_ssot/project_publish_round_b_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/server/src/core/migrations/migrations.ts
---

# 项目发布 Round B 后端真值与持久化冻结单

## 1. Scope

- 本冻结单只覆盖 `项目发布 Round B` 已准入的 3 个 richer fields：
  - `areaSqm`
  - `buildingTypeRemark`
  - `scheduleDetail`
- 本冻结单只服务于：
  - `POST /api/app/project/create`
  - `GET /api/app/project/detail`
  - 对应 internal truth pair 的真实写入与真实回读
- 本冻结单不冻结：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议
  - `project/list` richer projection
  - workbench richer projection
  - upload binding truth change
  - full `project` aggregate refactor

## 2. Current Blocker Freeze

- 当前 Round B 真源与 contract 已正式准入：
  - `areaSqm`
  - `buildingTypeRemark`
  - `scheduleDetail`
- 但当前本地证据仍显示：
  - [project.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/entities/project.entity.ts) 尚未承载这 3 个字段
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) 当前 `project` schema 也尚未承载这 3 个字段
- 因此当前 blocker 已正式认定为：
  - truth 已冻结
  - contract 已冻结
  - 但 `Server.project` 与 `public.project` 尚未具备合法 persistence carrier
- 本冻结单同时重申：
  - 不允许把 `areaSqm` / `buildingTypeRemark` / `scheduleDetail` 塞回 `description`
  - 不允许把它们塞进 `summary`
  - 不允许借 Round B richer fields 偷带：
    - `预算区间`
    - `奖励金额`
    - `创建前附件主表单化`

## 3. Canonical Truth Ownership Freeze

- `Server.project` 仍是这 3 个字段的唯一 business truth owner。
- `public.project` 是这 3 个字段当前唯一允许新增的 relational truth carrier。
- `BFF` 只能转发和聚合，不得拥有这 3 个字段的 business truth。
- `Flutter App` 只能提交与消费 app-facing 字段，不得拥有这 3 个字段的 business truth。

## 4. Canonical Persistence Binding

### 4.1 字段总表

| app-facing field | persistence column | DB type | nullable | create rule | detail rule |
|---|---|---|---|---|---|
| `areaSqm` | `area_sqm` | `numeric(10,2)` | `NULL` | omitted / `null` 时写 `NULL`；有值时按 canonical `sqm` 数值写入，最多两位小数 | `project/detail` 回读为 `areaSqm` 数值或 `null` |
| `buildingTypeRemark` | `building_type_remark` | `varchar(100)` | `NULL` | omitted / `null` 时写 `NULL`；空字符串必须在写入前归一为 `NULL` | `project/detail` 回读为 `buildingTypeRemark` 文本或 `null` |
| `scheduleDetail` | `schedule_detail` | `varchar(200)` | `NULL` | omitted / `null` 时写 `NULL`；空字符串必须在写入前归一为 `NULL` | `project/detail` 回读为 `scheduleDetail` 文本或 `null` |

### 4.2 默认行为冻结

- `area_sqm`
  - 默认行为是 `NULL`
  - 表示当前未单独提供面积真值
- `building_type_remark`
  - 默认行为是 `NULL`
  - 表示当前没有额外类型备注
- `schedule_detail`
  - 默认行为是 `NULL`
  - 表示当前没有额外详细时间补充说明
- 本冻结单不把空字符串冻结为 richer-field business default。

## 5. Create Write Rules

- `POST /server/projects` 在 Round B 范围内必须把这 3 个字段写入 `public.project` 对应列。
- create 写入必须遵守：
  - `areaSqm`
    - 若未提供则写 `NULL`
    - 若提供则必须是正数
    - 最多两位小数
    - 单位固定为 `sqm`
  - `buildingTypeRemark`
    - 若未提供或为空字符串则写 `NULL`
    - 若提供则最大长度与 contract 一致，不得超过 `100`
  - `scheduleDetail`
    - 若未提供或为空字符串则写 `NULL`
    - 若提供则最大长度与 contract 一致，不得超过 `200`
- create 不允许：
  - 用 `description` 冒充 `buildingTypeRemark`
  - 用 `description` 或 `summary` 冒充 `scheduleDetail`
  - 用展示单位文本冒充 `areaSqm`

## 6. Detail Read Rules

- `GET /server/projects/{projectId}` -> `GET /api/app/project/detail`
  必须在字段已存储时回读这 3 个字段。
- detail read 必须遵守：
  - DB column 与 app-facing field 一一映射
  - DB `NULL` 回读为 app-facing `null`
  - `area_sqm` 回读为 `areaSqm` 数值
  - `building_type_remark` 回读为 `buildingTypeRemark`
  - `schedule_detail` 回读为 `scheduleDetail`
- detail read 不允许：
  - 改名输出
  - 只在 detail 发明 second richer read model
  - 把 `scheduleDetail` 重新解释成 schedule object

## 7. 旧数据兼容冻结

- 当前已存在旧项目行没有这 3 个字段值。
- 旧数据兼容规则正式冻结为：
  - additive migration 后，历史行默认保持 `NULL`
  - `project/detail` 对旧项目回读这 3 个字段时返回 `null`
  - 前端不得因为旧数据 `null` 就本地补默认 richer 值
- 这意味着：
  - 历史 project rows 不需要被一次性回填
  - richer fields 的缺失不构成旧数据损坏

## 8. List / Workbench Boundary

- `project/list` 当前不要求承载：
  - `areaSqm`
  - `buildingTypeRemark`
  - `scheduleDetail`
- workbench 当前不要求承载：
  - `areaSqm`
  - `buildingTypeRemark`
  - `scheduleDetail`
- 这不改变这 3 个字段已进入 `Project` canonical truth 的结论。
- 当前只冻结：
  - create 必须可写
  - detail 必须可读
- 若未来 `project/list` 或 workbench 需要承载这些 richer fields，必须另行冻结消费面与 projection 边界。

## 9. Upload Non-impact Freeze

- 本冻结单正式确认：
  - `areaSqm` 不牵动 upload truth
  - `buildingTypeRemark` 不牵动 upload truth
  - `scheduleDetail` 不牵动 upload truth
- 当前 upload canonical truth 继续保持：
  - `businessType=project`
  - `fileKind=evidence`
  - `businessId=projectId`
  - `init -> direct upload -> confirm`
- 本冻结单不允许把 `创建前附件主表单化` 混入 persistence freeze。

## 10. Migration Dependency Freeze

- 一轮 additive migration 是这 3 个字段进入 runtime truth 的必要前置。
- 合法 migration 目标只允许是：
  - `public.project`
- 该 migration 的唯一职责是：
  - 增加本冻结单冻结的 3 个 columns：
    - `area_sqm`
    - `building_type_remark`
    - `schedule_detail`
- 本冻结单不 author migration 文件本体，但正式冻结：
  - 没有 migration，就不能合法完成 Round B create 真写
  - 没有 migration，就不能合法完成 Round B detail 真读

## 11. Explicit Non-goals

- 不引入：
  - `预算区间`
  - `奖励金额`
  - pre-create attachment truth
- 不改变：
  - 现有 `title` / `building_type` / `budget_amount` / `description` / `state` / `summary`
  - 地址与范围 7 字段已冻结语义
  - upload binding truth
- 不把 Round B richer persistence unlock 扩成其他板块 persistence unlock
