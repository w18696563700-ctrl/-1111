---
owner: Codex 总控
status: draft
purpose: Freeze the formal truth, allowed directories, and non-truth boundaries for Server.
layer: L3 Backend
---

# Server SSOT

## Formal truth files for Server
- `docs/02_backend/backend_ssot.md`
- `docs/02_backend/service_boundaries.md`
- `docs/02_backend/db_schema.md`
- `docs/02_backend/audit_log_spec.md`
- `docs/02_backend/identity_permission_persistence_minimum_addendum.md`
- `docs/02_backend/identity_permission_db_schema_increment_addendum.md`
- `docs/02_backend/identity_permission_audit_log_increment_addendum.md`
- relevant domain truth from `docs/00_ssot/*.md`
- relevant contract truth from `docs/01_contracts/*.yaml`

## Implementation but not truth
- `apps/server/src/**`
- future migrations
- future tests
- generated code under explicit `generated/` directories only

## Directory allow-list
- `apps/server/src/modules/**`: domain modules
- `apps/server/src/core/**`: framework bootstrap, infra adapters, config wiring
- `apps/server/src/shared/**`: non-domain internal helpers with owner

## Directory deny-list
- no copied specs under `src/**`
- no manual schema backups in source directories
- no provider-specific map implementation outside `platform_map`
- no raw prompt files or meeting notes

## Generated artifacts
- allowed only for projections such as schema clients or typed validation helpers
- must not be treated as source truth

## Temp files
- SQL scratchpads, exported data, and debug logs must stay outside tracked source

## Cross-layer change order
1. `docs/00_ssot`
2. `docs/01_contracts`
3. `docs/02_backend`
4. `apps/server/src/**`
5. migrations and generated outputs
