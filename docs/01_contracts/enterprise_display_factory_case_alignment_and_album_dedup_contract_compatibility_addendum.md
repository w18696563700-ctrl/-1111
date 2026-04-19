---
owner: Codex 总控
status: frozen
purpose: Record that the current factory case-alignment and album de-dup repair is a contract-compatible frontend correction with no new app-facing path family.
layer: L1 Contracts
freeze_date_local: 2026-04-19
inputs_canonical:
  - docs/01_contracts/enterprise_display_case_library_continuation_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - docs/01_contracts/factory_detail_optimization_remediation_contract_freeze_addendum_v1_1.md
  - docs/01_contracts/enterprise_display_album_and_target_enterprise_info_contract_freeze_addendum.md
---

# 《enterprise display factory case alignment and album dedup contract compatibility addendum》

## 1. No New Path Family

- 当前不新增：
  - case continuation 新 path
  - public detail 新 path
  - enterprise album 新 path

## 2. Existing Contract Reaffirmation

- direct case continuation:
  - `GET /api/app/exhibition/enterprise-hub/cases/{caseId}`
  - 继续只服务 `未发布 / draft-editable` 语义
- published-change corridor:
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/changes/current`
  - 继续是已发布后案例修改的唯一 app-facing current carrier
- detail visual gallery:
  - 继续只消费 `visualGallery.albumImageUrls`
  - 不因为 frontend fallback 而扩写 contract

## 3. Compatibility Conclusion

- 本轮修复属于：
  - `route-entry correction`
  - `surface de-dup correction`
- 本轮不属于：
  - contract widening
  - new payload family
