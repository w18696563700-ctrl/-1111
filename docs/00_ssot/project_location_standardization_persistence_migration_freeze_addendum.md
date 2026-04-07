---
owner: Codex 总控
status: frozen
purpose: Freeze the additive migration boundary for project-location standardization only, limited to public.project and without widening any other aggregate, board, or implementation scope.
layer: L0 SSOT
gate_basis:
  - docs/00_ssot/project_location_standardization_truth_freeze_addendum.md
  - docs/00_ssot/project_location_standardization_contract_freeze_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/02_backend/project_location_standardization_persistence_truth_addendum.md
freeze_date_local: 2026-04-04
---

# 项目地点标准化持久化与迁移冻结单

## 1. Scope

- 本冻结单只裁定 `项目地点标准化 persistence freeze` 的 migration 边界。
- 本冻结单只服务于：
  - `project` 聚合中的 standardized location truth
  - `project/create`
  - `project/detail`
  - 后续 `地域分类 / 搜索` 所需的 canonical classification truth 来源
- 本冻结单不裁定：
  - forum
  - 消息
  - Profile
  - 企业库
  - 订单 / 合同 / 履约 / 验收 / 评分 / 争议
  - 实际 migration 文件 authoring
  - backend / BFF / Flutter 实现
  - 搜索索引实现

## 2. Canonical Persistence Carrier Freeze

- `public.project` 是 standardized location 当前唯一允许的 persistence carrier。
- 本轮 standardized location 字段正式冻结为：
  - `province_code`
  - `province_name`
  - `city_code`
  - `city_name`
  - `district_code`
  - `district_name`
  - `detail_address`
- 其中：
  - `province_name / city_name / district_name / detail_address` 继续作为既有 display / text carrier
  - `province_code / city_code / district_code` 新承担 standardized classification truth

## 3. Additive Migration Freeze

- 一轮 additive migration 已被正式认定为本事项的必要前置。
- 当前正式冻结的 migration 范围仅限：
  - 一轮 additive migration
  - 作用对象仅限 `public.project`
  - 唯一新增列仅限：
    - `province_code`
    - `city_code`
    - `district_code`
- 当前正式禁止：
  - 修改任何其他表
  - 删除、改名、重写既有 `project` 列
  - 改变 `province_name / city_name / district_name / detail_address` 的既有语义
  - 引入地图、经纬度、行政区联动实现
  - 借本轮扩到其他板块
  - 借本轮 author 搜索索引或地域分类 projection

## 4. Nullability And Legacy Boundary

- `province_code`：`text`, `NULL`
- `city_code`：`text`, `NULL`
- `district_code`：`text`, `NULL`
- 这些 code 列当前冻结为 `NULL`-tolerant migration shape，仅服务旧数据兼容。
- 对新标准化 create truth 的要求不变：
  - `provinceCode` 必填
  - `cityCode` 必填
  - `districtCode` 按 district paired rule 选填
- `district_code` 与 `district_name` 的 paired-nullability 语义继续生效：
  - 要么同时 `NULL`
  - 要么同时非 `NULL`

## 5. Old-data Compatibility Freeze

- 历史 `project` rows 在本轮允许：
  - `province_code = NULL`
  - `city_code = NULL`
  - `district_code = NULL`
- 这不影响：
  - `province_name / city_name / district_name / detail_address` 继续作为旧数据 display carrier
  - `project/detail` 对旧项目返回已有 name/text 值
- 本轮不要求：
  - 历史 code 回填
  - 历史标准化修复任务
  - 本轮即刻把 code 列改成 `NOT NULL`

## 6. Projection And Search Non-impact Boundary

- `project/list` 当前不要求承载 standardized location 字段。
- workbench 当前不要求承载 standardized location 字段。
- 后续地域分类 / 搜索若需要 projection 或 index：
  - 唯一允许上游真源是 `province_code / city_code / district_code`
- 但本轮明确不 author：
  - 这些 projection
  - 这些 index
  - 这些实现

## 7. Gate Conclusion

- 当前结论：
  - `Go` for one additive migration freeze for project location standardization only
  - `No-Go` for any other aggregate or board persistence unlock
  - `No-Go` for backend / BFF / Flutter implementation by this file itself
- 本冻结单的真实含义是：
  - standardized location 的 persistence truth 已正式冻结
  - additive migration 边界已正式明确
  - 后续可以进入受控 backend/BFF implementation freeze，但不能绕过该边界

