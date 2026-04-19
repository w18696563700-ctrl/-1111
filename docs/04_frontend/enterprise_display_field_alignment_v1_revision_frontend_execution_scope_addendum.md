---
owner: Codex 总控
status: frozen
purpose: Freeze the frontend implementation scope for Gate 2 of the V1.0 revised enterprise display field-alignment package.
layer: L3 Frontend
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/04_frontend/enterprise_display_field_alignment_v1_revision_frontend_consumption_addendum.md
---

# Enterprise Display Field Alignment V1 Revision Frontend Implementation Scope

## Required

- detail hero/gallery de-duplication
- list/detail slot alignment to the frozen field table
- preview layout reuse against change-carrying data
- keep process fields in workbench only

## Preferred Write Set

- `apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_*`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_*`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_*`
- related tests

## Not In Scope

- redesign of unrelated mobile modules
- heavy map UX
- credit-score feature expansion
