---
owner: Codex 总控
status: frozen
purpose: Freeze the contract posture for the V1.0 revised enterprise display field-alignment package without inventing unsupported preview endpoints.
layer: L1 Contracts
freeze_date_local: 2026-04-18
inputs_canonical:
  - docs/01_contracts/enterprise_display_workbench_v1_contract_freeze_addendum.md
  - docs/01_contracts/enterprise_display_published_change_corridor_contract_freeze_addendum.md
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-truth.controller.ts
---

# Enterprise Display Field Alignment V1 Revision Projection Contract

## 1. Contract Conclusion

- This round does not freeze a new standalone preview API.
- This round freezes a projection rule:
  - public detail contract remains the layout contract
  - preview may be carried by current `draft/change` read data
  - preview and detail must align on field slots and media semantics

## 2. Existing Canonical Families Confirmed

- `GET /api/app/exhibition/enterprise-hub/workbench`
- `GET /api/app/exhibition/enterprise-hub/enterprises`
- `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}`
- published-change current family:
  - `GET /enterprises/{enterpriseId}/changes/current`
  - `PUT /.../changes/current/basic`
  - `PUT /.../changes/current/profiles/*`
  - `POST /.../changes/current/cases`
  - `PUT /.../changes/current/cases/{caseId}`
  - `DELETE /.../changes/current/cases/{caseId}`
  - `POST /.../changes/current/submit`
  - `GET /.../changes/current/status`

## 3. Preview Contract Rule

- If preview remains frontend-carried in this round:
  - no new app-facing endpoint is required
- If preview is later promoted to an explicit BFF surface:
  - that route must still project the same field alignment frozen here

## 4. Anti-drift Rule

- No new endpoint may be introduced merely to hide unresolved owner drift.
- No preview contract may leak internal review/readiness fields into a public-looking payload.
