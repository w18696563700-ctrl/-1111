---
owner: Codex 总控
status: frozen
purpose: Freeze the V1.0 revised field-alignment truth for enterprise display across workbench, public list, public detail, and preview projection.
layer: L0 SSOT
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-workbench.presenter.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-published-change.presenter.ts
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_consumer_layer.dart
  - apps/mobile/lib/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart
---

# Enterprise Display Field Alignment V1 Revision Freeze

## 1. Final Ruling

- This round is not a page-polish task.
- This round freezes:
  - public truth ownership
  - field destination alignment
  - media semantics
  - live/change dual-snapshot boundary
  - preview projection rule

## 2. Public Truth Model

### 2.1 Public Truth Owner

- Public list and public detail must share one public truth owner.
- Current runtime owner remains the published listing projection family rooted in:
  - `EnterpriseHubQueryService`
  - `EnterpriseHubPresenter`
- List and detail may differ only by projection density, not by independent field semantics.

### 2.2 Workbench Edit View

- Enterprise workbench remains the enterprise-side only editing entrance.
- Workbench truth includes:
  - editable public fields
  - readiness
  - latest application / latest review result
  - unpublished draft state
  - published change in-progress state
- Workbench is not the public live view.

### 2.3 Published-Change Dual Snapshot

- For published enterprises the system formally recognizes:
  - `live published snapshot`
  - `current change snapshot`
- Public list/detail keep serving live.
- Workbench keeps serving current change.
- Apply/merge is the only path from change to live.

### 2.4 Preview Rule

- Preview is a controlled projection, not a new truth root.
- Preview must reuse detail layout and detail field-projection rules.
- Preview does not need a brand-new dedicated endpoint in this round.
- The carrying model may be either:
  - an explicit BFF preview surface
  - or a controlled projection of `current change / draft` read-model
- Regardless of carrier, preview must not drift from detail slot rules.

## 3. Global Alignment Rules

1. One public truth, multiple projections.
2. List is a subset of detail.
3. Any enterprise-side editable public field must have an explicit destination:
   - list + detail
   - detail only
   - reserved but not enabled
   - internal only
4. Internal process truth may stay in workbench only.
5. Board applicability must be frozen explicitly for:
   - `company`
   - `factory`
   - `supplier`

## 4. Media Semantics Ruling

- `Logo`:
  - enterprise identity mark only
- `Cover`:
  - hero image only
- `Gallery`:
  - detail gallery only
- `Case cover`:
  - case identity only

### 4.1 Current Drift

Current runtime still contains drift:

- detail hero may take `coverImageUrl`
- detail gallery may still include that same cover image again
- some display fallbacks still let `logo` or `case cover` participate in enterprise visual projection

### 4.2 Target Rule

- Hero and gallery must be de-duplicated.
- Logo must not backfill enterprise gallery semantics.
- Case cover must not backfill enterprise gallery semantics.

## 5. Minimum Required Public Field Families

- identity/media:
  - board identity
  - logo
  - cover
  - gallery
  - enterprise name
  - region
  - certification state
- summary/capability:
  - short intro
  - board-specific summary tags
  - service area/city
  - max project scale where applicable
- detail/contact:
  - full intro
  - address
  - public contact
- cases:
  - at least one public case for `company/factory`

## 6. No-Go Rules

- No new public field without owner + destination + board applicability.
- No list/detail independent wording or field growth.
- No treating workbench as live public detail.
- No pretending preview is live public data.
- No continued media mixing between logo, cover, gallery, and case cover.

## 7. Implementation Unlock Rule

Implementation unlock requires:

- owner appendix landed
- board applicability appendix landed
- contract/backend/bff/frontend layer addenda landed
- Gate 1 checklist updated to `Go for implementation`
