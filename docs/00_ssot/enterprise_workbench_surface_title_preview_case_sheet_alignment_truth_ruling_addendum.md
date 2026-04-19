# Enterprise Workbench Surface Title Preview Case Sheet Alignment Truth Ruling Addendum

## Bound
- Scope is limited to `apps/mobile` enterprise workbench and preview surface.
- Public exhibition list/detail truth, BFF contracts, and Server published/live truth stay unchanged.

## Frozen Truth
- Top app bar title for the enterprise workbench route must reflect the board type:
  - `公司展示工作台`
  - `工厂展示工作台`
  - `供应商展示工作台`
- Published-change mode may keep a separate in-page change-workbench title, but the app-bar title must no longer remain the generic `企业展示工作台`.
- Published-change information and preview remain available, but large preview content should not occupy the top of the workbench by default.
- In published-change preview, tapping a case card must prefer the current preview/context image truth instead of silently switching back to public live case media.
- Factory preview hero should prefer showcase images, then album images, then logo fallback.

## Non-goals
- Do not change public factory/company/supplier detail truth.
- Do not merge current-change cases into public live detail.
- Do not alter Server or BFF case approval semantics.
