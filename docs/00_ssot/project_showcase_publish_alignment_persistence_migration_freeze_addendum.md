---
owner: Codex 总控
status: frozen
purpose: Freeze the additive-migration boundary for project-showcase alignment only, clarifying that no new showcase-only migration family is introduced.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/project_showcase_publish_alignment_truth_freeze_addendum.md
  - docs/00_ssot/project_showcase_publish_alignment_contract_freeze_addendum.md
  - docs/02_backend/project_showcase_publish_alignment_persistence_truth_addendum.md
freeze_date_local: 2026-04-04
---

# 项目展示与项目发布对齐 persistence migration 边界冻结单

## 1. Scope

- 本冻结单只覆盖 `project showcase publish alignment persistence freeze` 中的 additive migration 边界。
- 本冻结单只处理 `project` 聚合。
- 本冻结单不 author 实际 migration 文件。
- 本冻结单不扩到其他板块。

## 2. Migration Freeze Conclusion

- showcase 对齐本轮不新增 showcase-only 列。
- showcase 对齐本轮不新增 showcase-only additive migration。
- 若后续 runtime 要完整承接当前 showcase list/detail contract，唯一允许依赖的 migration 范围仍然只限于已冻结的 `public.project` additive columns。

## 3. Allowed Existing Migration Scope

- address-range 既有冻结范围：
  - `province_name`
  - `city_name`
  - `district_name`
  - `detail_address`
  - `scope_summary`
  - `planned_start_at`
  - `planned_end_at`
- Round B richer field 既有冻结范围：
  - `area_sqm`
  - `building_type_remark`
  - `schedule_detail`
- standardized location 既有冻结范围：
  - `province_code`
  - `city_code`
  - `district_code`

## 4. Explicitly Forbidden In This Freeze

- 不新增：
  - showcase list-only projection table
  - showcase detail-only read table
  - `tags` 列
  - tag 表
  - attachment snapshot 列
  - attachment list 表
- 不把以下内容带入本轮 migration 边界：
  - 正式附件列表
  - 奖励金额
  - 单位平方面积金额
  - 搜索 index
  - 地域分类 projection

## 5. Stage Conclusion

- 当前结论：
  - `Go` for entering the `showcase alignment backend-BFF implementation freeze` stage
  - `No-Go` for by this file itself entering implementation

