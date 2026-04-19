---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded Flutter surface repair for published-change preview case cover alignment.
layer: L4 Frontend
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/00_ssot/enterprise_display_factory_post_submit_preview_case_media_alignment_truth_ruling_addendum.md
  - docs/01_contracts/enterprise_display_factory_post_submit_preview_case_media_alignment_contract_compatibility_addendum.md
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_page_load.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_preview_projection.dart
---

# 《enterprise display factory preview case media alignment frontend surface》

## 1. Scope

- 当前只补：
  - published-change preview case cover 投影
  - 对应定点回归

## 2. Preview Case Media

- `enterpriseHubBuildPublishedChangePreviewDetailData`
  - case card `coverImageUrl` 必须优先读取 current-change case cover
  - 读取顺序：
    - `caseCoverFileAssetId -> caseImageUrlMap`
    - `caseMediaFileAssetIds -> caseImageUrlMap`
    - `caseImageUrlMap.values`

## 3. Required Tests

- published-change preview detail data 能投影出 draft case cover url
