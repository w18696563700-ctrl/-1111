---
owner: Codex 总控
status: frozen
purpose: Record that the remaining preview case-media alignment repair is contract-compatible and stays within existing app-facing fields and routes.
layer: L1 Contracts
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/01_contracts/enterprise_display_factory_case_alignment_and_album_dedup_contract_compatibility_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
---

# 《enterprise display factory preview case media alignment contract compatibility addendum》

## 1. No New Path Family

- 当前不新增：
  - public detail 新 path
  - published-change preview 新 path
  - case media 新 payload family

## 2. Existing Field Reuse

- preview case media correction：
  - 继续只消费 existing `cases[*].caseCoverFileAssetId`
  - 继续只消费 existing `cases[*].caseImageUrlMap`

## 3. Compatibility Conclusion

- 本轮属于：
  - `existing-field projection correction`
- 本轮不属于：
  - contract widening
  - payload mutation
  - live/public truth rewrite
