---
owner: Codex 总控
status: draft
purpose: Freeze the incremental dispatch boundary for the exhibition-home public board so execution and verification remain board-scoped and non-duplicative.
layer: L0 SSOT
---

# 展览首页公域板块增量派工单

## 1. Scope
- This addendum freezes the current incremental dispatch boundary for the
  `展览首页公域` board only.
- It applies to:
  - frontend consumption
  - `BFF` aggregation
  - `Server` no-op or minimum support judgement
  - result verification
- It does not by itself:
  - close the board
  - approve release

## 2. Board Objective
- The current board objective is limited to:
  - making the exhibition public home stable and truthful under the current
    live validation chain
  - preserving public visibility for unauthenticated access
  - preserving private gating for write or session-dependent actions
  - keeping weather and manual location as `BFF`-owned read aggregation only

## 3. Included Scope
- `GET /api/app/exhibition/home`
- `POST /api/app/exhibition/home/refresh`
- `POST /api/app/exhibition/home/location/select`
- public weather-card rendering and public-home minimal content
- six modules and recommendation minimal blocks
- request-only or session-only location semantics
- controlled failures for unauthenticated or invalid selection paths

## 4. Explicit Non-goals
- No `/api/app/weather/*`
- No `Server` weather truth
- No `Server` manual-location truth
- No second public-home protocol
- No reopening of workbench-private, account-identity, or publish boards
- No conversion of `session_only` manual selection into persisted truth

## 5. Frontend Dispatch Boundary
- Frontend may:
  - consume the three frozen home paths
  - render public weather card, six modules, and recommendation blocks
  - keep unauthenticated public-home visibility
  - keep private-action login redirect
  - show controlled failures truthfully
- Frontend must not:
  - invent new path semantics
  - bypass `BFF`
  - replace real cloud responses with local mock completion

## 6. BFF Dispatch Boundary
- `BFF` may:
  - aggregate public-home weather, location, module, and recommendation data
  - use provider inputs and Redis session-only selection storage
  - normalize public-home errors into the app-facing envelope
- `BFF` must not:
  - create a second truth owner
  - expose provider raw payloads
  - create `/api/app/weather/*`
  - persist manual location into `Server` truth by default

## 7. Server Dispatch Boundary
- `Server` may:
  - continue supplying project, forum, auth, and organization truth inputs
  - remain `no-op` for weather and manual-location persistence
- `Server` must not:
  - become a weather or location truth owner for this board
  - create a second ordered-home truth model

## 8. Current Increment Result
- Frontend current result:
  - `8080` validation path consumed
  - no board-level rework required
- `BFF` current result:
  - public home unauthenticated `GET` returns `200`
  - authenticated selection persists at session scope
  - refresh is whole-page, not weather-only
- `Server` current result:
  - current board remains `no-op`

## 9. Exit Condition For This Dispatch Round
- This dispatch round is considered complete only when:
  - frontend receipt exists
  - `BFF` receipt exists
  - backend receipt exists
  - result verification either returns `通过` or a bounded fix list

## 10. Next Unique Action
- Submit the current board to independent verification against the live `8080`
  evidence and the archived closure-pack receipts.
