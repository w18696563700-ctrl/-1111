---
owner: Codex 总控
status: frozen
purpose: Freeze frontend consumption obligations for the V1.0 revised enterprise display field-alignment execution package.
layer: L3 Frontend
freeze_date_local: 2026-04-18
inputs_canonical:
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart
  - apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_pages.dart
---

# Enterprise Display Field Alignment V1 Revision Frontend Consumption

## 1. Frontend Objective

- Align workbench, list, detail, and preview around the frozen field table without inventing new truth.

## 2. Frontend Rules Frozen In This Round

1. Workbench remains an edit view, not a public detail page.
2. List remains a summary view only.
3. Detail remains the complete public projection.
4. Preview must reuse detail layout and field slots, but read from current change/draft carrying data.
5. Media display must honor:
   - logo as identity only
   - cover as hero only
   - gallery as non-cover visual gallery only
   - case cover as case-only media

## 3. Current Drift Recorded

- Detail hero/gallery duplication risk is real in current runtime.
- List summary and workbench editable fields are not yet fully aligned under one frozen field table.
- Existing fallback behavior may still surface logo/case-cover semantics too broadly.

## 4. Required Frontend Outcomes For Gate 2

- workbench field slots match the frozen public-destination table
- list fields are all detail-recognizable
- detail hero/gallery are de-duplicated
- preview respects detail slot rules
- internal process fields stay in workbench only

## 5. Allowed Frontend Write Set For Gate 2

- `apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_pages.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_*`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_workbench_*`
- related tests under `apps/mobile/test/**`

## 6. Anti-revert

- Do not use frontend fallback to fabricate missing owner truth.
- Do not let list grow into detail.
- Do not let workbench process fields leak into public detail/list.
