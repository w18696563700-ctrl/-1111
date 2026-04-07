---
owner: Codex 总控
status: draft
purpose: Freeze the formal truth, allowed directories, and non-truth boundaries for Flutter App.
layer: L3 Frontend
---

# Flutter App SSOT

## Formal truth files for Flutter App
- `docs/04_frontend/frontend_ssot.md`
- `docs/04_frontend/flutter_screen_map.md`
- `docs/04_frontend/ui_state_contract.md`
- relevant contract truth from `docs/01_contracts/*.yaml`
- relevant domain truth from `docs/00_ssot/*.md`

## Implementation but not truth
- `apps/mobile/lib/**`
- future Flutter tests under `apps/mobile/test/**`
- future app-local generated projections under explicit `generated/` directories

## Directory allow-list
- `apps/mobile/lib/shell`: shell boot, guards, navigation, context consumption
- `apps/mobile/lib/features/**`: feature implementations
- `apps/mobile/lib/core`: networking, auth client, upload client, config consumption
- `apps/mobile/lib/shared`: presentation-level shared widgets and non-domain helpers

## Directory deny-list
- no upstream doc copies under `lib/**`
- no prompt notes under `lib/**`
- no screenshots, exports, or meeting notes under app directories
- no provider SDK spike code outside approved integration boundaries

## Generated artifacts
- allowed only in explicit `generated/` folders if introduced later
- generated files are projections from contracts, not source truth

## Temp files
- temp analysis, screenshots, and local exports must stay in ignored temp space only

## Cross-layer change order
1. `docs/00_ssot`
2. `docs/01_contracts`
3. `docs/04_frontend`
4. `apps/mobile/lib/**`
