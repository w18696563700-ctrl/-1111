---
owner: Codex 总控
status: draft
purpose: Freeze the board-by-board closure plan for the account login, identity, organization, certification, permission, and session module so the team can close this board end to end before moving on.
layer: L0 SSOT
---

# 账号登录与身份权限板块封板计划单

## 1. Scope
- This addendum freezes the board-closure plan for the current
  `account / identity / organization / session / certification / permission`
  board only.
- It applies to:
  - frontend
  - BFF
  - Server
  - result verification
  - later integration for this board
- It does not by itself:
  - declare the board completed
  - open the next product board
  - approve release

## 2. Board-closure Principle
- The project now follows board-by-board closure.
- One board must be closed end to end before the next board becomes the main
  execution target.
- “Closed” means all of the following exist together:
  - frozen boundary
  - frozen contracts
  - implemented code
  - focused test evidence
  - independent verification result
  - change-closure record

## 3. Current Board Definition
- Current board name:
  - `账号登录与身份权限`
- Current board includes only:
  - OTP send
  - OTP login
  - refresh and logout
  - shell context
  - create organization
  - join organization by invite code
  - switch organization
  - read current certification
  - submit or resubmit certification
  - read device list
  - revoke one device
  - unauthenticated public-exhibition visibility
  - private-action login redirect
  - minimum role and object-permission enforcement
- Current board does not include:
  - password login
  - WeChat login
  - SSO
  - advanced multi-organization collaboration
  - full security center
  - complete admin UI family

## 4. Current Stage Gate Checklist

### 4.1 Passed gates
- 真源门禁：
  - minimum identity truth is frozen in `docs/00_ssot`, `docs/01_contracts`,
    and `docs/02_backend`
- 契约门禁：
  - minimum app-facing identity route set is frozen
- 架构边界门禁：
  - Flutter App -> BFF -> Server boundary remains intact
- 阶段控制门禁：
  - one current board and one current objective are now explicit

### 4.2 Failed gates
- 契约实链门禁：
  - not all current identity happy paths are independently re-verified through
    the current development runtime yet
- 审计实链门禁：
  - all frozen identity audit actions are not yet independently sampled through
    one board-complete happy path
- 结果校验门禁：
  - no final independent verification sheet yet for this board

### 4.3 Veto gates
- Release-stage gate remains vetoed:
  - this board is not release-ready yet
- Integration closeout remains vetoed:
  - until focused independent verification passes

### 4.4 Stage go / no-go
- Stage decision:
  - `Go` for continued implementation and verification on this board
  - `No-Go` for release or next-board handoff

## 5. Board Boundary Freeze

### 5.1 Frontend boundary
- Frontend must close:
  - unauthenticated exhibition public-home visibility
  - login entry page
  - OTP send and login UI consumption
  - shell context consumption
  - session refresh and logout consumption
  - organization create and join entry pages
  - organization switch handoff
  - certification current consumption
  - device list and revoke consumption
  - private-action redirect to login
- Frontend must not close:
  - password login
  - WeChat login
  - fake happy path without real server content

### 5.2 BFF boundary
- BFF must close:
  - `/api/app/auth/*`
  - `/api/app/shell/context`
  - `/api/app/profile/index`
  - `/api/app/profile/organization/*`
  - `/api/app/profile/certification/*`
  - `/api/app/profile/security/*`
  - app-facing error normalization
  - shell context shaping
- BFF must not close:
  - identity truth persistence
  - session truth
  - organization truth
  - certification truth
  - admin review APIs

### 5.3 Server boundary
- Server must close:
  - `/server/auth/*`
  - `/server/shell/context`
  - `/server/profile/index`
  - `/server/profile/organization/*`
  - `/server/profile/certification/*`
  - `/server/profile/security/*`
  - identity persistence
  - session persistence
  - organization membership truth
  - certification truth
  - device truth
  - security-event truth
  - minimum identity audit actions
- Server must not close:
  - password login
  - WeChat login
  - SSO
  - full security-center feature family

## 6. Contract Freeze For Board Completion
- The following contract files remain mandatory truth inputs:
  - `docs/01_contracts/auth_contracts.yaml`
  - `docs/01_contracts/identity_permission_minimum_contracts.yaml`
- The board may not claim closure if any implemented path drifts from those
  files.
- No new front-end-facing path family may be introduced during this board.

## 7. Required Test Bundle For Board Closure

### 7.1 Frontend required tests
- unauthenticated users can view exhibition public home
- unauthenticated private actions route to login
- OTP send consumption
- OTP login consumption
- shell context bootstrap
- session refresh handling
- logout handling
- organization create/join/switch consumption
- certification current consumption
- security devices consumption

### 7.2 BFF required tests
- canonical `/api/app/auth/*` route hit
- canonical `/api/app/profile/*` route hit
- shell context shaping
- controlled error-envelope mapping
- session-invalid mapping
- path exposure through Nginx on current development runtime

### 7.3 Server required tests
- OTP send persistence
- OTP login creates or binds user identity
- refresh rotates session
- logout revokes session
- organization create materializes admin membership
- join-by-code materializes organization membership
- certification current read
- certification submit or resubmit write
- device list read
- device revoke write
- audit log emission on frozen actions
- security-event emission on minimum risk trigger

## 8. Independent Verification Target
- Result-verification agent must verify at least:
  - no remaining `404` on frozen current-board identity routes
  - protected routes return `401` when unauthenticated, not fake success
  - unauthenticated exhibition public home remains visible
  - private actions still require login
  - shell context changes after login and organization switch
  - certification state participates in action gating
  - device revoke changes current device/session surface as frozen

## 9. Change-close Record Required Before Board Completion
- The board may not be declared closed until the following exist together:
  - frontend receipt
  - BFF receipt
  - backend receipt
  - result-verification receipt
  - board closure note from Codex 总控
- The closure note must state:
  - what is closed
  - what remains outside this board
  - which next board becomes active

## 10. Current Board Exit Criteria
- This board is considered closed only when all of the following are true:
  - OTP send returns success on current development runtime
  - OTP login happy path is independently re-verified
  - shell context is reloaded from real session, not placeholder fallback
  - organization create or join and switch are re-verified
  - certification current and submit are re-verified
  - device list and revoke are re-verified
  - unauthenticated exhibition public-home access remains correct
  - private-action login redirect remains correct
  - result verification returns `通过` or `有条件通过且条件已全部补齐`

## 11. Next-board Lock Rule
- Until this board is closed:
  - `项目发布`
  - `项目展示/详情/继续竞标`
  - `工作台私域`
  may continue only as maintenance or bug-fix work
- None of them becomes the new main execution target before this board closes.

## 12. Dispatch Conclusion
- The active current board is:
  - `账号登录与身份权限`
- The current team order is:
  1. close this board
  2. verify this board independently
  3. issue a board closure note
  4. then open the next board
