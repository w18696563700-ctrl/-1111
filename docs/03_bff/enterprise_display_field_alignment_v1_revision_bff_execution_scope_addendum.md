---
owner: Codex 总控
status: frozen
purpose: Freeze the BFF implementation scope for Gate 2 of the V1.0 revised enterprise display field-alignment package.
layer: L2.5 BFF
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/03_bff/enterprise_display_field_alignment_v1_revision_bff_surface_addendum.md
---

# Enterprise Display Field Alignment V1 Revision BFF Implementation Scope

## Required

- public read-model trimming where public/process boundaries drift
- change carrying/read-model trimming for preview alignment

## Preferred Write Set

- `apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub-published-change.read-model.ts`
- only if necessary: `enterprise-hub.service.ts` and `enterprise-hub-published-change.service.ts`

## Not In Scope

- new standalone preview endpoint unless current carrying model proves insufficient
- unrelated auth/profile/forum changes
