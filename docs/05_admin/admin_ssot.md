---
owner: Codex 总控
status: draft
purpose: Freeze the formal truth, allowed directories, and non-truth boundaries for Admin.
layer: L3 Admin
---

# Admin SSOT

## Formal truth files for Admin
- `docs/05_admin/admin_ssot.md`
- `docs/05_admin/admin_governance_surface_matrix.md`
- relevant contract truth from `docs/01_contracts/*.yaml`
- relevant governance and backend truth from `docs/02_backend/*.md`
- relevant domain truth from `docs/00_ssot/*.md`

## Implementation but not truth
- `apps/admin/src/**`
- future tests
- generated client projections under explicit `generated/` directories only

## Directory allow-list
- `apps/admin/src/modules/review`
- `apps/admin/src/modules/project_review`
- `apps/admin/src/modules/template_config`
- `apps/admin/src/modules/audit`
- `apps/admin/src/modules/ticketing`
- `apps/admin/src/core`
- `apps/admin/src/shared`

## Directory deny-list
- no direct database scripts in source tree
- no copied backend docs
- no raw exports or screenshots under source
- no bypass of controlled Server Admin APIs

## Generated artifacts
- allowed only for API clients and schema projections
- must remain projections, not truth

## Temp files
- review exports, CSV dumps, and screenshots belong in ignored temp locations only

## Cross-layer change order
1. `docs/00_ssot`
2. `docs/01_contracts`
3. `docs/02_backend` if Admin-governed truth changes
4. `docs/05_admin`
5. `apps/admin/src/**`
