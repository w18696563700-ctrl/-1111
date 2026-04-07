---
owner: Codex 总控
status: frozen
purpose: Freeze the Round B additive migration boundary for project-publish richer persistence only, limited to three admitted fields on public.project and without widening any other board or aggregate.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_round_b_truth_freeze_addendum.md
  - docs/00_ssot/project_publish_round_b_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/project_publish_round_b_persistence_truth_addendum.md
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/server/src/core/migrations/migrations.ts
freeze_date_local: 2026-04-04
---

# 项目发布 Round B 持久化与迁移冻结单

## 1. Scope

- 本冻结单只裁定 `项目发布 Round B persistence freeze`。
- 本冻结单只服务于：
  - `areaSqm`
  - `buildingTypeRemark`
  - `scheduleDetail`
  进入 `public.project` 的合法 persistence carrier 与 additive migration 边界。
- 本冻结单不裁定：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议
  - upload binding truth 变更
  - 实际 migration file authoring
  - backend / BFF / Flutter 实现

## 2. Current Blocker Freeze

- 当前 Round B truth 与 contract 已正式冻结允许进入 persistence freeze 的 richer fields 仅有：
  - `areaSqm`
  - `buildingTypeRemark`
  - `scheduleDetail`
- 当前本地证据仍显示：
  - [project.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/entities/project.entity.ts) 尚未承载这 3 个字段
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) 当前 `public.project` schema 也尚未承载这 3 个字段
- 因此当前 blocker 已正式认定为：
  - contract 已够
  - persistence carrier 还不够
  - 若没有 additive migration，则无法把这 3 个字段变成合法 runtime truth

## 3. Canonical Persistence Carrier Freeze

- `Server.project` 仍是这 3 个字段的唯一 business truth owner。
- `public.project` 是这 3 个字段当前唯一允许新增的 relational persistence carrier。
- 本轮不得新增任何第二 persistence family。
- 本轮 richer fields 的 persistence 规格以
  [project_publish_round_b_persistence_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/project_publish_round_b_persistence_truth_addendum.md)
  为准：
  - `area_sqm` `numeric(10,2)` `NULL`
  - `building_type_remark` `varchar(100)` `NULL`
  - `schedule_detail` `varchar(200)` `NULL`

## 4. Additive Migration Freeze

- 一轮 additive migration 已被正式认定为本事项的必要前置。
- 当前正式冻结的 migration 范围仅限：
  - 一轮 additive migration
  - 作用对象仅限 `public.project`
  - 唯一职责仅限增加以下 3 个新列：
    - `area_sqm`
    - `building_type_remark`
    - `schedule_detail`
- 当前正式禁止：
  - 修改任何其他表
  - 删除、改名、重写既有 `project` 列
  - 改变现有 `title` / `building_type` / `budget_amount` / `description` / `state` / `summary` 语义
  - 改变已冻结地址与范围 7 字段语义
  - 借本轮带入：
    - `预算区间`
    - `奖励金额`
    - `创建前附件主表单化`
  - 借本轮改写 upload binding truth
  - 借本轮把 `project/list` / workbench 一并扩面

## 5. Old Data Compatibility Freeze

- 历史 `project` rows 当前没有这 3 个字段值。
- additive migration 后的兼容规则正式冻结为：
  - 旧数据保持 `NULL`
  - 不要求一次性回填历史 richer 数据
  - `project/detail` 对旧项目回读时返回 `null`
- 该兼容规则不构成数据损坏，也不要求同步调整 `project/list` / workbench。

## 6. Projection Boundary Freeze

- `project/create` 必须按已冻结映射真实写入这 3 个字段。
- `project/detail` 必须按已冻结映射真实回读这 3 个字段。
- `project/list` 当前不要求承载这 3 个 richer fields。
- workbench 当前不要求承载这 3 个 richer fields。
- 这意味着：
  - list/workbench 不需要因本轮 migration 被动改 contract 或 projection 语义
  - 本轮 persistence freeze 只服务于 create/detail richer-field 闭环

## 7. Upload Non-impact Freeze

- 本冻结单正式确认：
  - `areaSqm` 不改变 upload 语义
  - `buildingTypeRemark` 不改变 upload 语义
  - `scheduleDetail` 不改变 upload 语义
- 当前 upload canonical truth 继续保持：
  - `businessType=project`
  - `fileKind=evidence`
  - `businessId=projectId`
  - `init -> direct upload -> confirm`
- 本轮 persistence freeze 不是 upload-binding-change freeze。

## 8. Gate Conclusion

- 当前结论：
  - `Go` for one additive migration freeze for project publish Round B richer persistence only
  - `No-Go` for any other aggregate or board persistence unlock
  - `No-Go` for `project/list` and workbench richer projection expansion
  - `No-Go` for upload binding truth change
  - `No-Go` for business-code implementation by this file itself
- 本冻结单的真实含义是：
  - Round B admitted fields 的 persistence truth 已足够清楚
  - 一轮最小 additive migration 现在具备合法 authoring 边界
  - 但本文件本身不 author migration 文件，不执行 migration，也不代表实现已开始

## 9. Next Unique Action

- 下一唯一动作应为：
  - 在后续受控 implementation-freeze / dispatch round 中，只为 `public.project` author 一轮 additive migration，并同步补齐对应 entity / mapper / create-detail persistence binding
- 在该后续 round 之前，仍然禁止：
  - 其他板块 schema 扩面
  - 其他聚合 migration
  - upload binding truth 重开
  - 借本轮做 `project` 全量 richer refactor
