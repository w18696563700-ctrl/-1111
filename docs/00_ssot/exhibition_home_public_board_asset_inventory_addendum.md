---
owner: Codex 总控
status: draft
purpose: Identify reusable assets, forbidden rework, and genuine gaps for the exhibition-home public board.
layer: L0 SSOT
---

# 展览首页公域板块现状资产识别单

## 1. Scope
- This addendum identifies the current asset baseline for the
  `展览首页公域` board only.
- It exists to prevent duplicate construction and to force incremental work.

## 2. Existing Frontend Assets
- Existing public-home page shell and weather card:
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_page.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_weather_card.dart`
  - `apps/mobile/lib/features/exhibition/presentation/exhibition_home_weather_panels.dart`
- Existing location access:
  - `apps/mobile/lib/core/location/device_location_service.dart`
- Existing home aggregation client:
  - `apps/mobile/lib/features/exhibition/data/exhibition_home_aggregation_client.dart`
- Existing public / private gate behavior:
  - unauthenticated exhibition remains visible
  - private actions still redirect to login
- Existing refresh and auto-refresh behaviors are already present.

## 3. Existing BFF Assets
- Existing canonical path family:
  - `GET /api/app/exhibition/home`
  - `POST /api/app/exhibition/home/refresh`
  - `POST /api/app/exhibition/home/location/select`
- Existing public-home aggregation responsibilities:
  - location normalization
  - weather aggregation
  - six-module minimal blocks
  - recommendation minimal blocks
  - public-home error normalization
- Existing upstream reuse already exists through:
  - project recommendation inputs
  - forum feed inputs
  - weather provider and reverse-geocode provider
  - Redis session-scoped manual selection storage

## 4. Existing Server Assets
- `Server` already owns reusable truth inputs for:
  - project recommendation source
  - forum source
  - auth / organization / shell gating
- `Server` does not own:
  - weather truth
  - location preference truth
  - an ordered-home truth aggregate
- Current board therefore does not require a new `Server` weather or location
  persistence domain.

## 5. Existing Deployment and Validation Assets
- Current board validation host and tunnel:
  - host `47.108.180.198`
  - local tunnel `8080 -> 80`
  - local address `http://127.0.0.1:8080`
- Current board closure-pack folder:
  - `.tmp/exhibition_home_public_board_closure_pack/20260328/`

## 6. Directly Reusable Assets
- Existing exhibition-home truth documents and contracts
- Existing frontend public-home shell and weather card
- Existing `BFF` exhibition-home route family
- Existing `Server` project / forum / auth truth inputs
- Existing public-home unauthenticated visibility behavior

## 7. Genuine Gaps Or Repair Targets
- Formal stage-gate, asset-inventory, and increment-dispatch documents for this
  board were missing before this round and are now being frozen.
- Current board still needs independent verification and a later release
  integration decision.
- Current contract wording may need a small wording correction for
  `LOCATION_PERMISSION_UNAVAILABLE` under `location/select`.

## 8. Explicit No-op Areas
- No `Server` weather persistence
- No `Server` location persistence
- No `/api/app/weather/*`
- No second home protocol
- No second truth owner for location or weather

## 9. Forbidden Duplicate Work
- No rewrite of the weather card
- No rewrite of the exhibition public-home layout
- No second aggregation route family
- No second BFF home module with overlapping semantics
- No new `Server` truth tables for weather or manual location in this board

## 10. Next Unique Action
- Use this asset baseline to evaluate only incremental work in the current
  result-verification round.
