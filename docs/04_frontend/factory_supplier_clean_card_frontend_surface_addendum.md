---
owner: Codex 总控
status: active
purpose: Frontend surface for the Flutter-only clean-card refinement of factory and supplier recommendation/list cards.
layer: L5 Frontend
based_on:
  - docs/00_ssot/factory_supplier_clean_card_truth_freeze_addendum.md
  - docs/00_ssot/factory_supplier_clean_card_stage_gate_checklist_addendum.md
freeze_date_local: 2026-05-05
---

# 《工厂 / 供应商清爽版推荐卡与列表卡 frontend surface》

## 1. Allowed File Boundary

Allowed:

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_enterprise_panels.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_channel_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_shared.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_list_pages.dart`
- `apps/mobile/test/exhibition_home_test.dart`
- `apps/mobile/test/enterprise_hub_routes_test.dart`

Forbidden:

- BFF, Server, contracts, generated contracts, database, cloud, deployment files.

## 2. Target Card Anatomy

Factory / supplier clean card:

```text
[头像/Logo]  名称                         >
           地区
           摘要：工艺/产品 或 品类/响应
```

Hidden from card surface:

- `优秀工厂`
- `优秀供应商`
- bottom chips
- `查看工厂详情`
- `查看供应商详情`

## 3. Home Recommendation Rules

- `factory` and `supplier` cards use clean mode.
- `company` card keeps existing completed behavior.
- `actionLabel` remains for accessibility semantics, but visible text CTA is hidden in clean mode.
- Tapping the card body still opens existing detail route.

## 4. List Card Rules

- Factory and supplier board list cards use clean mode through a targeted parameter / variant.
- Company list cards are not forced into this change.
- The shared `EnterpriseCard` must not globally remove chips for every board type.

## 5. Acceptance Criteria

- Home factory card does not show badge / chips / visible detail CTA.
- Home supplier card does not show badge / chips / visible detail CTA.
- Factory list card does not show bottom chips.
- Supplier list card does not show bottom chips.
- Existing card click-to-detail behavior remains.
- No model / parser / contract field deletion.
- Scoped `flutter analyze` and targeted tests pass.
