---
owner: Codex 总控
status: draft
purpose: Freeze the anti-regression release guard for exhibition-home live weather so compiled runtimes and release smoke can veto any rollback to placeholder or minimum-truth weather output.
layer: L0 SSOT
---

# 展览首页真实天气发布防回退守卫补充冻结单

## 1. Scope
- This addendum applies only to the already-admitted `展览首页真实天气` release chain.
- It freezes only:
  - the anti-regression release guard for compiled `Server` runtime
  - the mandatory post-release smoke assertions for the app-facing weather chain
- It does not:
  - reopen provider selection
  - add any new route family
  - move weather truth ownership away from `Server`

## 2. Incident Basis
- On `2026-04-24`, production weather regressed from live weather back to the old placeholder/minimum-truth chain after a later release overlaid the current production symlink with artifacts that no longer carried the admitted weather slice.
- The regression symptoms were frozen as:
  - `currentWeather = 待同步`
  - `hourlyForecast = []`
  - `dailyForecast = []`
  - `sourceLabel` returning the old `最小真值` wording
- This proves that the current release process must not trust successful process restart or generic health checks as sufficient evidence for weather-release integrity.

## 3. Formal Guard Decision
- When `QWEATHER_ENABLED=true`, compiled or production `Server` runtime must refuse startup if the compiled artifact set no longer carries the admitted weather slice.
- The startup veto must at minimum reject either of the following:
  - required weather aggregation artifacts are missing from the compiled runtime
  - the compiled exhibition-home presenter still contains placeholder/minimum-truth markers such as `待同步` or `最小真值`
- Release smoke for the live-weather chain must assert the app-facing route family instead of relying only on generic liveness:
  - `GET /api/app/exhibition/home`
  - `POST /api/app/exhibition/home/refresh`
  - `POST /api/app/exhibition/home/location/select`
- The smoke result is `Fail` if any of the following appears on the current home response:
  - placeholder weather wording such as `待同步`
  - fallback weather wording such as `天气暂不可用`
  - old `最小真值` source label
  - empty hourly forecast array
  - empty daily forecast array
- The smoke result is also `Fail` if unauthenticated `refresh` or `location/select` no longer return `401 AUTH_SESSION_INVALID`, because this indicates BFF transport drift even when the public `GET` path still looks healthy.

## 4. Retained Boundary
- `BFF` remains app-facing transport only and does not become weather truth owner because of this guard.
- `Flutter` remains a consumer only and does not become release truth evidence because of this guard.
- The guard is release-integrity infrastructure only; it does not widen the admitted weather scope.
