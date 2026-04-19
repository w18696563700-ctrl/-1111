---
owner: Codex 总控
status: frozen
purpose: Freeze the backend implementation scope for Gate 2 of the V1.0 revised enterprise display field-alignment package.
layer: L2 Backend
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/02_backend/enterprise_display_field_alignment_v1_revision_backend_truth_addendum.md
---

# Enterprise Display Field Alignment V1 Revision Backend Implementation Scope

## Required

- public presenter/media projection tightening
- published-change to live merge safety for media semantics
- helper-level projection cleanup where needed

## Preferred Write Set

- `apps/server/src/modules/enterprise_hub/enterprise-hub.presenter.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-query.service.ts`
- `apps/server/src/modules/enterprise_hub/enterprise-hub-published-change-*.ts`
- supporting projection/media helper files in the same module

## Not In Scope

- new migrations
- new Admin governance surface
- unrelated application-state-machine changes
