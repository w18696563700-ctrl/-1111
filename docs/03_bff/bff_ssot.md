---
owner: Codex 总控
status: draft
purpose: Freeze the formal truth, allowed directories, and non-truth boundaries for BFF.
layer: L3 BFF
---

# BFF SSOT

## Formal truth files for BFF
- `docs/03_bff/bff_ssot.md`
- `docs/03_bff/bff_routes.md`
- relevant contract truth from `docs/01_contracts/*.yaml`
- relevant domain and boundary truth from `docs/00_ssot/*.md` and `docs/02_backend/service_boundaries.md`

## Implementation but not truth
- `apps/bff/src/**`
- future tests under `apps/bff/test/**`
- generated route or schema projections under explicit `generated/` directories only

## Directory allow-list
- `apps/bff/src/routes/**`: aggregation endpoints
- `apps/bff/src/core/**`: auth consolidation, error mapping, config consumption, idempotency helpers
- `apps/bff/src/shared/**`: narrow BFF-local utilities

## Directory deny-list
- no business state machines
- no persistent business truth
- no Admin-only APIs
- no provider-specific map logic outside normalized platform capability responses

## Generated artifacts
- allowed only when derived from frozen contracts or route specs
- must not become the authored truth

## Temp files
- logs, request dumps, spike responses, and debug payloads must not live under `apps/bff/src/**`

## Cross-layer change order
1. `docs/00_ssot`
2. `docs/01_contracts`
3. `docs/02_backend` if Server-facing boundary changes
4. `docs/03_bff`
5. `apps/bff/src/**`
