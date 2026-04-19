---
owner: Codex 总控
status: frozen
purpose: Freeze BFF surface obligations for the V1.0 revised enterprise display field-alignment execution package.
layer: L2.5 BFF
freeze_date_local: 2026-04-18
inputs_canonical:
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.controller.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub-workbench.service.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub-published-change.service.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub-published-change.read-model.ts
---

# Enterprise Display Field Alignment V1 Revision BFF Surface

## 1. BFF Surface Objective

- Keep app-facing surfaces aligned without creating a second truth model.

## 2. Surfaces Frozen In This Round

- workbench edit surface
- public list surface
- public detail surface
- change-preview carrying surface

## 3. Change-Preview Carrying Rule

- Current runtime does not require a standalone preview endpoint.
- For this round, BFF may satisfy preview carrying by exposing current change data through the existing published-change current family.
- If a later explicit preview route is added, it must remain a projection carrier only.

## 4. BFF Responsibilities

- Keep list/detail rooted in the same public truth family.
- Keep workbench and published-change edit surfaces separate from public detail.
- Keep internal review/readiness fields out of public list/detail.
- Keep live and change payload families distinct.

## 5. Current Drift Recorded

- Some read-model fallback behavior still smooths over backend projection gaps.
- That smoothing is temporary drift, not authorized semantics.

## 6. Allowed BFF Write Set For Gate 2

- `apps/bff/src/routes/enterprise_hub/enterprise-hub.service.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub.read-model.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub-published-change.service.ts`
- `apps/bff/src/routes/enterprise_hub/enterprise-hub-published-change.read-model.ts`
- only if needed: controller surface additions under the same module

## 7. Anti-revert

- Do not invent field meaning in BFF.
- Do not mix public detail payloads with workbench-only process fields.
- Do not create a fake preview contract that hides unresolved backend drift.
