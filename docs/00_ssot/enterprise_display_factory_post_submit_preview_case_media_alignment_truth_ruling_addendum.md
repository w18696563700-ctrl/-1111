---
owner: Codex 总控
status: frozen
purpose: Freeze the truth ruling for the remaining bounded repair that aligns published-change preview case media with the current-change carrier while keeping public detail on live truth.
layer: L0 SSOT
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_factory_case_alignment_and_album_dedup_truth_ruling_addendum.md
  - docs/01_contracts/enterprise_display_factory_case_alignment_and_album_dedup_contract_compatibility_addendum.md
  - docs/04_frontend/enterprise_display_factory_case_alignment_and_album_dedup_frontend_surface_addendum.md
---

# 《enterprise display factory preview case media alignment truth ruling》

## 1. Published-change Preview Case Media Rule

- `已发布展示变更 -> 预览展示页`
  - 案例卡图片必须优先使用 current-change case 自带的 `caseImageUrlMap`
  - `caseCoverFileAssetId` 是第一优先锚点
- 不允许继续出现：
  - preview case card 不带图
  - preview case card 继续误导成 formal live image 语义

## 2. Non-goals

- 不把 public detail 改成 current-change preview
- 不把线上公开 `approved/live` 案例图改成 draft 图
- 不新增任何新的 published-change read contract
