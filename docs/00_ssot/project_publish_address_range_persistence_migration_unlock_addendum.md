---
owner: Codex 总控
status: frozen
purpose: Freeze the minimum migration-unlock ruling for project-publish address-and-scope persistence only, limited to one additive migration on public.project and without widening any other board or aggregate.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_publish_board_boundary_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_internal_truth_contracts_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/project_publish_address_range_persistence_truth_addendum.md
  - apps/server/src/modules/project/entities/project.entity.ts
  - apps/server/src/core/migrations/migrations.ts
freeze_date_local: 2026-04-03
---

# 项目发布地址与范围持久化与迁移解冻补丁单

## 1. Scope

- 本补丁单只裁定 `项目发布` 的 `地址与范围` 最小 persistence unlock。
- 本补丁单只服务于：
  - `POST /api/app/project/create` 的真实写入
  - `GET /api/app/project/detail` 的真实回读
  - 对应 `Server.project` truth 与 `public.project` persistence carrier 的合法补齐
- 本补丁单不裁定：
  - forum
  - messages
  - profile
  - enterprise hub
  - order / contract / milestone / inspection / rating / dispute
  - `project/list` 字段扩面
  - workbench 字段扩面
  - geo / map / payment / publishStatus
  - 整个 `project` 聚合重构

## 2. Current Blocker Freeze

- 当前 app-facing contract 已解冻以下 7 个字段：
  - `provinceName`
  - `cityName`
  - `districtName`
  - `detailAddress`
  - `scopeSummary`
  - `plannedStartAt`
  - `plannedEndAt`
- 当前 backend truth / persistence 证据仍显示：
  - [project.entity.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/modules/project/entities/project.entity.ts) 尚未承载上述 7 个字段
  - [migrations.ts](/Users/wangweiwei/Desktop/展览装修之家总控/apps/server/src/core/migrations/migrations.ts) 当前 `public.project` DDL 也尚未承载上述 7 个字段
- 因此当前 blocker 已正式认定为：
  - 合同面已解冻
  - 但 `Server.project` 与 `public.project` 尚未具备合法 persistence carrier
  - 若没有 additive migration，则无法合法完成 create 真写与 detail 真读
- 本补丁单同时重申：
  - 不允许把地址与范围塞进 `description`
  - 不允许把地址与范围塞进 `summary`
  - `description` / `summary` 均不得充当 persistence surrogate

## 3. Canonical Persistence Truth Freeze

- `Server.project` 是这 7 个字段的唯一 canonical truth owner。
- `public.project` 是这 7 个字段当前唯一允许新增的 relational persistence carrier。
- 这 7 个字段的冻结 persistence 规格以
  [project_publish_address_range_persistence_truth_addendum.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/02_backend/project_publish_address_range_persistence_truth_addendum.md)
  为准：
  - `province_name` `text` `NOT NULL`
  - `city_name` `text` `NOT NULL`
  - `district_name` `text` `NULL`
  - `detail_address` `text` `NOT NULL`
  - `scope_summary` `text` `NOT NULL`
  - `planned_start_at` `date` `NULL`
  - `planned_end_at` `date` `NULL`
- app-facing `plannedStartAt` / `plannedEndAt` 与 DB `date` 的映射规则也已冻结为：
  - create 侧使用 `YYYY-MM-DD` -> DB `date`
  - detail 侧使用 DB `date` -> `YYYY-MM-DD`
  - omitted / `null` -> DB `NULL` / app-facing `null`

## 4. Additive Migration Unlock Ruling

- 一轮 migration 已被正式认定为本事项的必要前置，不允许再口头绕过。
- 当前正式解冻的 migration 范围仅限：
  - 一轮 additive migration
  - 作用对象仅限 `public.project`
  - 唯一职责仅限增加本补丁单冻结的 7 个新列
- 本轮明确禁止：
  - 修改任何其他表
  - 删除、改名、重写既有 `project` 列
  - 改变现有 `title` / `building_type` / `budget_amount` / `description` / `state` / `summary` 语义
  - 借本轮顺手引入 `lng` / `lat` / `venue_name` / payment / publishStatus / geo / map truth
  - 借本轮把 `project/list` / workbench 一并扩面

## 5. Create / Detail Persistence Boundary

- `project create` 必须按冻结映射真实写入 7 个字段。
- `project detail` 必须按冻结映射真实回读 7 个字段。
- `project/list` 当前不要求承载这 7 个字段。
- workbench 当前不要求承载这 7 个字段。
- 这意味着：
  - list/workbench 不需要因本轮 migration 被动改 contract 或改 read model 语义
  - 本轮 persistence unlock 只服务于 create/detail 最小闭环

## 6. Gate Conclusion

- 当前结论：
  - `Go` for one additive migration unlock for `project publish address-range persistence` only
  - `No-Go` for any other aggregate or board persistence unlock
  - `No-Go` for `project/list` and workbench field expansion
  - `No-Go` for business-code implementation by this file itself
- 本补丁单的真实含义是：
  - backend truth / persistence spec 已经足够清楚
  - 一轮最小 additive migration 现在具备合法 authoring 前提
  - 但本文件本身不 author migration 文件，不执行 migration，也不代表业务代码已经实现

## 7. Next Unique Action

- 下一唯一动作应为：
  - 在后续受控 backend implementation round 中，只为 `public.project` author 一轮 additive migration，并同步补齐对应 entity / mapper / create-detail persistence binding
- 在该后续 round 之前，仍然禁止：
  - 其他板块 schema 扩面
  - 其他聚合 migration
  - 借本轮做 `project` 全量模型重构
