---
owner: Codex 总控
status: draft
purpose: Record the stage gate checklist for the exhibition-home public board before independent verification and release integration.
layer: L0 SSOT
---

# 展览首页公域板块阶段门禁核查表

## 1. Scope
- This addendum applies only to the current `展览首页公域` board.
- It records the gate state for:
  - current truth inputs
  - current implementation receipts
  - current runtime evidence
  - whether the board may proceed to independent verification
- It does not by itself:
  - close the board
  - approve release
  - reopen already closed boards

## 2. Current Validation Topology
- Current board validation evidence is frozen against:
  - host `47.108.180.198`
  - local tunnel `8080 -> 80`
  - local address `http://127.0.0.1:8080`
- This is the current board validation chain only.
- It must not be miswritten as a permanent production topology statement.

## 3. Passed Gates
- 真源门禁：
  - public-home product truth already exists in
    `docs/00_ssot/exhibition_home_ordered_marketplace_unified_addendum.md`
  - app-facing contract already exists in `docs/01_contracts/openapi.yaml`
  - `BFF` route truth already exists in `docs/03_bff/bff_routes.md`
  - Flutter surface mapping already exists in
    `docs/04_frontend/flutter_screen_map.md`
- 架构边界门禁：
  - `Flutter App -> BFF -> Server` boundary remains intact
  - no `/api/app/weather/*` path family has been introduced
  - `Server` has not been expanded into a weather or location truth owner
- 运行态门禁：
  - `GET /health/bff/live` returns `200`
  - `GET /health/server/live` returns `200`
  - unauthenticated `GET /api/app/exhibition/home` returns `200`
  - authenticated `location/select -> GET /home -> refresh` evidence exists
- 资料归档门禁：
  - current frontend / BFF / backend execution receipts are archived in the
    current board closure pack under `.tmp/`

## 4. Failed Gates
- 结果校验门禁：
  - no final independent verification sheet has yet been issued for this board
- 联调发布门禁：
  - no release-integration conclusion exists yet

## 5. Veto Gates
- Release-stage veto remains active:
  - until independent verification passes and a rollback-ready integration
    conclusion exists

## 6. Stage Go / No-Go
- Stage decision:
  - `Go` for independent verification
  - `No-Go` for release integration

## 7. Current Board Risks
- Current contract wording for
  `POST /api/app/exhibition/home/location/select`
  may not yet list every runtime `400` variant, including
  `LOCATION_PERMISSION_UNAVAILABLE`.
- Current manual location selection remains `session_only` / non-persistent by
  design and must not be misread as a `Server` truth commitment.

## 8. Next Unique Action
- Run the current board through the result-verification round using the
  archived receipts and the live `8080` evidence.
