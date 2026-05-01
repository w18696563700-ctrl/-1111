---
owner: Codex 总控
status: frozen
purpose: Freeze the minimum hotfix boundary for same-account phone and desktop concurrent login without changing Server session truth.
layer: L0 SSOT
---

# Mobile Multidevice Session Refresh Singleflight Hotfix Addendum

## 1. User Goal
- The same account must be able to stay logged in on phone and desktop at the
  same time.
- Message center and project communication requests must keep carrying the
  active app-facing auth carrier after either device refreshes its session.
- Phone login and desktop login must not invalidate each other by default.

## 2. Current Runtime Finding
- Cloud `sessions` truth already allows multiple valid sessions for the same
  user across `ios` and `macos`.
- The visible failure is not a Server-side "single device only" policy.
- The visible failure is an app request reaching BFF without `authorization`,
  which BFF correctly rejects fail-closed.

## 3. Frozen Boundary
- Server remains the only session truth owner.
- BFF remains an auth carrier forwarder and does not synthesize session truth.
- Flutter owns only local carrier continuity:
  - access token usage
  - refresh token storage
  - refresh retry sequencing
  - controlled retry after token refresh

## 4. Hotfix Rule
- Flutter must serialize refresh requests in one app process.
- If multiple protected reads discover an expired access token at the same time,
  only one `/api/app/auth/refresh` request may be sent.
- Other protected reads must await the same refresh result.
- If a stale refresh attempt returns unauthorized after another local refresh has
  already replaced the refresh token, Flutter must not clear the newer session.
- If a protected request receives 401 but the local access token has already
  changed since the request was sent, Flutter should retry once with the current
  token before starting another refresh.

## 5. Non-goals
- Do not change refresh token rotation semantics on Server.
- Do not add a "single account global session" state machine.
- Do not make BFF issue, verify, or persist session truth.
- Do not introduce cross-device token sharing.
- Do not hand-edit DB sessions to pass UAT.

## 6. Stage Gate
- Passed:
  - Runtime DB shows concurrent valid `ios` and `macos` sessions.
  - Failure text proves missing transport carrier, not business permission
    denial.
  - Flutter protected request path already centralizes refresh handling.
- Failed:
  - None for this bounded hotfix.
- Veto:
  - Any Server/BFF rewrite of auth truth is vetoed in this patch.
- Next stage:
  - Allowed: Flutter local refresh singleflight and stale-session guard.
