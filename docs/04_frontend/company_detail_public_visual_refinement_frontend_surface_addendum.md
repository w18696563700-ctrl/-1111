---
owner: Codex 总控
status: active
purpose: Frontend surface for the Flutter-only public company detail and home recommendation visual refinement.
layer: L5 Frontend
based_on:
  - docs/00_ssot/company_detail_public_visual_refinement_truth_freeze_addendum.md
  - docs/00_ssot/company_detail_public_visual_refinement_stage_gate_checklist_addendum.md
freeze_date_local: 2026-05-05
---

# 《公司详情页公开展示与首页公司推荐卡视觉精修 frontend surface》

## 1. Allowed File Boundary

Allowed Flutter presentation files:

- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_recommendation_section.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_enterprise_panels.dart`
- `apps/mobile/lib/features/exhibition/presentation/exhibition_home_channel_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_company_sections.dart`
- `apps/mobile/lib/features/exhibition/presentation/enterprise_hub_detail_company_support_widgets.dart`
- New `enterprise_hub_detail_company_*` files only when needed to avoid file-length growth.
- Targeted tests under `apps/mobile/test/`.

Forbidden:

- `apps/bff/**`
- `apps/server/**`
- `docs/01_contracts/**`
- `packages/contracts/**`
- cloud / runtime / migration files.

## 2. Home Company Recommendation Card

Target behavior:

- Company recommendation card becomes a compact avatar card.
- Avatar source is `EnterpriseHubListItem.logoUrl`.
- Title source is `EnterpriseHubListItem.name`.
- Location source is `provinceName / cityName`.
- Summary source is `enterpriseBoardCardSummaryText(item)` or existing short intro fallback.
- Chips source is `enterpriseBoardCardSummaryChips(item)`.
- Card remains whole-card clickable.
- `优秀公司` remains hidden for company cards.

Non-regression:

- Factory / supplier recommendation cards must retain their visible detail CTA semantics unless separately changed.
- Company list route and company detail route semantics must not change.

## 3. Public Company Detail

Target section order:

1. Hero with gradient overlay, title,真实标签, image counter when applicable.
2. Trust metric strip using real public detail fields.
3. Full-width company intro card with expand support.
4. Compact address and service area map card.
5. Core advantage cards from real `boardProfile` fields.
6. Horizontal public case thumbnails, at most 6.
7. Qualifications and reputation with real `certifications / reviewSummary`.
8. Compact basic information rows.
9. Contact section or bottom contact bar obeying existing contact visibility.

## 4. Missing Data Rules

- Do not hardcode `98%`, `56`, `5 年`, or any target-image sample number.
- Do not backfill missing case images with fake images.
- Do not invent a second review or certification summary.
- Do not expose hidden contact fields.
- Use controlled empty / hidden state when public live detail lacks a field.

## 5. Visual Rules

- Use existing warm-white / card / brand-gold visual language.
- Reduce oversized vertical gaps.
- Prefer full-width cards for public detail sections.
- Keep Hero legible even when source image quality is weak by using gradient overlay, not fake image replacement.
- Avoid expanding `enterprise_hub_detail_surface_widgets.dart`; split company-only widgets into company-specific files.

## 6. Acceptance Criteria

- 首页公司推荐卡 has visible avatar / logo / fallback.
- 首页公司推荐卡 does not show `优秀公司`.
- Company card whole-card click still enters company detail.
- Company detail first screen is closer to the target public-display hierarchy.
- No fake score, fake review count, fake cases, fake qualifications, fake contacts, or fake experience.
- `flutter analyze` passes for changed scope.
- Target widget tests pass or failures are reported as pre-existing / out-of-scope.
- Computer Use screenshots captured after user login.
