---
owner: Codex 总控
status: draft
purpose: Record the formal closure conclusion for the exhibition-home public board, state what is closed, what remains outside the board, and freeze that the closure is development-stage only under the currently approved host and tunnel basis.
layer: L0 SSOT
---

# 展览首页公域板块封板结论单

## 1. Scope
- This addendum records the formal closure conclusion for the current
  `展览首页公域` board only.
- It applies to:
  - Flutter App
  - BFF
  - Server
  - result verification
  - release integration
  - current development-stage closure evidence
- It does not by itself:
  - approve production launch
  - rewrite the existing board boundary
  - rewrite the current development-stage host and tunnel into a permanent
    production topology
  - designate the next active board by assumption

## 2. Current Board Name
- Current board:
  - `展览首页公域板块`

## 3. Current Closure Basis
- Current control-document basis:
  - `docs/00_ssot/exhibition_home_public_board_stage_gate_checklist_addendum.md`
  - `docs/00_ssot/exhibition_home_public_board_verification_conclusion_addendum.md`
  - `docs/00_ssot/exhibition_home_public_board_release_gate_addendum.md`
- Current standard-receipt basis:
  - `.tmp/exhibition_home_public_board_closure_pack/20260328/frontend_exhibition_home_public_receipt.md`
  - `.tmp/exhibition_home_public_board_closure_pack/20260328/bff_exhibition_home_public_receipt.md`
  - `.tmp/exhibition_home_public_board_closure_pack/20260328/backend_exhibition_home_public_receipt.md`
- Current runtime and release-integration evidence basis:
  - `.tmp/exhibition_home_public_release_integration/20260328/**`
  - `.tmp/exhibition_home_public_integration/20260328_release_gate/**`
- Current already-passed stage conclusions:
  - `结果校验通过`
  - `联调发布通过`
- Current development-stage closure basis is frozen against:
  - host `47.108.180.198`
  - local tunnel `8080 -> 80`
  - local address `http://127.0.0.1:8080`
- This host and tunnel basis is the current board development-stage closure
  basis only.
- It must not be miswritten as a permanent production-topology ruling.

## 4. Stage Gate Checklist

### 4.1 Passed gates
- 真源门禁：
  - the current board stage gate, verification conclusion, release gate, and
    closure conclusion are all frozen under `docs/00_ssot`
- 契约门禁：
  - `GET /api/app/exhibition/home`
  - `POST /api/app/exhibition/home/refresh`
  - `POST /api/app/exhibition/home/location/select`
  remain within the already frozen canonical path family
- 架构边界门禁：
  - `Flutter App -> BFF -> Server` remained intact
  - no `/api/app/weather/*` path family was introduced
  - `Server` was not expanded into a weather or location truth owner
- 运行态门禁：
  - the current development-stage live runtime on
    `47.108.180.198 / 8080 -> 80` produced verification and release
    integration evidence
  - current release-gate probe shows active `BFF`, `Server`, and `Nginx`
- 结果校验门禁：
  - current board verification has returned `通过`
- 联调发布门禁：
  - current board release integration has returned `通过`
- 当前板块风险门禁：
  - no `P0`
  - no `P1`
  - only one retained `P2` wording-coverage residual remains

### 4.2 Failed gates
- 无当前板块封板阻断失败项

### 4.3 Veto gates
- Launch-stage veto remains:
  - this closure is for the current approved host and tunnel under the current
    development-stage board only
  - it does not equal production launch approval

### 4.4 Stage go / no-go
- Stage decision:
  - `Go` for closing the current exhibition-home public board
  - `Go` for waiting on total-control designation of the next active board
  - `No-Go` for rewriting this closure into a permanent production-topology
    statement
  - `No-Go` for treating release-integration pass as launch completion

## 5. Current Passed Main Chains
- Unauthenticated `GET /api/app/exhibition/home = 200`
- Unauthenticated `POST /api/app/exhibition/home/refresh = 401 AUTH_SESSION_INVALID`
- Unauthenticated `POST /api/app/exhibition/home/location/select = 401 AUTH_SESSION_INVALID`
- Authenticated `POST /api/app/exhibition/home/location/select = 200`
- Authenticated `GET /api/app/exhibition/home = 200`
- Authenticated `POST /api/app/exhibition/home/refresh = 200`
- Current `selectionScope`, `selectionNotice`, and
  `currentLocation.persisted = false` remain aligned with the already frozen
  non-persistent truth.
- Current release-integration soak evidence also confirms:
  - same-session `location/select -> refresh` keeps the manual-selection
    province carrier stable
  - the current board preserves session-scoped location retention without
    promoting it into `Server` truth

## 6. What Is Closed By This Board
- `GET /api/app/exhibition/home`
- `POST /api/app/exhibition/home/refresh`
- `POST /api/app/exhibition/home/location/select`
- public exhibition home visibility
- private-action controlled gating on the current public home
- current session-scoped location-selection retention
- ordered-home location, weather, module, and recommendation consumption under
  the frozen current board boundary
- current full-home refresh semantics under the frozen current board boundary

## 7. What Remains Outside This Board
- permanent production-topology rewrite
- weather or location persisted truth on `Server`
- `/api/app/weather/*`
- reinterpretation of release-integration pass into launch completion
- any other board that has not been explicitly opened by total control

## 8. Current Development-stage Notes
- The current board is now formally considered closed at the development-stage
  evidence level.
- The current closure does not certify production readiness.
- Current board boundary keeps standing:
  - no new `/api/app/weather/*`
  - `Flutter App -> BFF -> Server` boundary remains intact
  - `Server` does not own weather or location persisted truth for this board
- Current known non-blocking residual remains:
  - `location/select` current `400` variant wording in `openapi.yaml` still
    does not fully cover `LOCATION_PERMISSION_UNAVAILABLE`

## 9. Next Active Board
- Next active board:
  - `待总控指定`

## 10. Next-board Opening Rule
- No next board may start implementation by this file alone.
- Before any new board becomes execution-active, Codex 总控 must issue:
  - a new 《阶段门禁核查表》
  - the next board's formal boundary freeze
  - the next board's formal dispatch bundle

## 11. Formal Conclusion
- Current board status:
  - `展览首页公域板块 = 已封板`
- Current closure type:
  - `当前批准 host/tunnel 下的开发阶段封板`
- Next active board:
  - `待总控指定`
