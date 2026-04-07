---
owner: Codex 总控
status: draft
purpose: Freeze the pre-release-integration gate state for the exhibition-home public board and record that the board may enter release integration without implying launch approval.
layer: L0 SSOT
---

# 展览首页公域板块联调发布前门禁冻结单

## 1. Scope
- This addendum applies only to the current `展览首页公域` board.
- It freezes:
  - the current pre-release-integration gate state
  - the allowed integration scope
  - the still-required integration checks
  - the current stage go / no-go conclusion
- It does not by itself:
  - approve production launch
  - certify production readiness
  - rewrite the current board boundary

## 2. Current Gate Basis
- Current gate basis is frozen against:
  - the passed board stage gate
  - the archived closure-pack receipts
  - the current board verification conclusion
  - the current development-stage live verification chain:
    - host `47.108.180.198`
    - local tunnel `8080 -> 80`
    - local address `http://127.0.0.1:8080`
- This runtime basis is for current board development-stage verification and
  release integration only.
- It is not a permanent production-topology ruling.

## 3. Gates Already Satisfied Before Release Integration
- 真源门禁：
  - current public-home truth, contract, BFF route boundary, and Flutter
    surface map have already been frozen
- 架构边界门禁：
  - `Flutter App -> BFF -> Server` remains intact
  - no `/api/app/weather/*` path family has been introduced
  - `Server` has not been expanded into a weather or location truth owner
- 契约门禁：
  - `home`
  - `refresh`
  - `location/select`
  remain within the already frozen canonical path family
- 结果校验门禁：
  - current board verification result is already frozen as `通过`
- 当前板块风险门禁：
  - no `P0`
  - no `P1`
  - only one retained `P2` wording-coverage item remains

## 4. Current Release Integration Scope
- The current release integration scope is limited to:
  - `GET /api/app/exhibition/home`
  - `POST /api/app/exhibition/home/refresh`
  - `POST /api/app/exhibition/home/location/select`
  - public exhibition home visibility
  - private-action controlled gating
- The current integration scope also freezes the already confirmed behavior:
  - unauthenticated `GET /home = 200`
  - unauthenticated `refresh / location-select = 401 AUTH_SESSION_INVALID`
  - authenticated `location/select = 200`
  - authenticated `GET /home = 200`
  - authenticated `refresh = 200`
  - `selectionScope / selectionNotice / persisted=false` remain aligned with
    the non-persistent manual-selection truth
- Current integration scope does not include:
  - a new weather path family
  - `Server` weather or location truth persistence
  - production launch approval

## 5. Items Still Required In Release Integration
- tunnel stability
- frontend real-cloud connection verification
- release gate checks
- rollback plan

## 6. Stage Gate Checklist

### 6.1 Passed gates
- 真源门禁
- 架构边界门禁
- 契约门禁
- 结果校验门禁
- 当前板块阻断级别门禁

### 6.2 Failed gates
- 无当前进入联调发布的直接阻断失败项

### 6.3 Veto gates
- Launch-stage veto remains:
  - current board is allowed to enter release integration
  - but current board is not yet allowed to launch

### 6.4 Stage go / no-go
- Stage decision:
  - `Go` for release integration
  - `No-Go` for launch approval

## 7. Current Formal Decision
- Current board decision:
  - `允许进入联调发布`
  - `不等于允许上线`

## 8. Non-goals
- No production launch approval
- No permanent production-topology statement
- No boundary rewrite for the exhibition-home public board
