---
owner: Codex 总控
status: draft
purpose: Freeze the formal discussion boundary for exhibition-home weather warning richer-stage official-alert-presentation-boundary-only planning, limited to presentation hierarchy and information density, without unlocking contracts, L3 truth, alert history surfaces, or implementation.
layer: L0 SSOT
---

# 施工天气预警 richer-stage official-alert presentation boundary 冻结单

## Scope
- This addendum applies only to:
  - `施工天气预警 richer-stage official-alert presentation boundary only`
- It freezes only:
  - what the current official-alert presentation discussion may cover
  - how `officialAlerts` may be expressed in collapsed and expanded states
  - when the module may show only `有预警 / 无预警`
  - when the module may show alert count or alert title
  - what must remain outside the current official-alert presentation boundary
- It does not by itself:
  - approve implementation
  - approve contracts
  - approve data-source expansion
  - approve an independent official-alert product line

## Current Object Name
- Current object:
  - `施工天气预警 richer-stage official-alert presentation boundary only`

## Current Discussion Coverage
- The current discussion covers only:
  - the presentation boundary of `officialAlerts` in collapsed state
  - the presentation boundary of `officialAlerts` in expanded state
  - when the module should show only `有预警 / 无预警`
  - when the module may show alert count
  - when the module may show alert title
  - when the module must hide or fold alert information
- The current discussion is:
  - a presentation-hierarchy discussion only
  - an information-density discussion only
  - not an implementation approval
  - not a data-source expansion approval
  - not an independent official-alert product-line approval

## Current Minimum Presentation Boundary
- The current official-alert presentation discussion may freeze at minimum:
  - collapsed state shows at most one compact cue
  - expanded state may contain one dedicated official-alert information block
  - when `officialAlerts` is an empty array, the module must not fabricate an
    alert
- The current discussion may refine:
  - whether the collapsed cue should prefer
    `有预警`
    over alert count or alert title
  - whether alert count belongs only in expanded state
  - whether alert title may appear only when the current information density
    stays controlled
  - how the module should fold or suppress alert detail when the signal is too
    noisy for the current layer

## Collapsed-state Presentation Boundary
- The collapsed state may discuss only:
  - whether official alert presence should appear beside or under the main
    construction conclusion
  - whether the collapsed state should show only
    `有预警 / 无预警`
  - whether one compact count cue is ever appropriate
  - when alert title must remain hidden to keep the collapsed card compact
- The collapsed state may not discuss:
  - multi-alert browsing
  - alert history browsing
  - external-link navigation
  - a second detail surface

## Expanded-state Presentation Boundary
- The expanded state may discuss only:
  - whether a dedicated official-alert information block should exist
  - when alert count may be shown
  - when alert title may be shown
  - when the alert block should be folded or visually suppressed
  - how expanded state may stay professional without becoming an alert browser
- The expanded state may not discuss:
  - an alert details page
  - an alert history page
  - a multi-level alert browser
  - an external jump page
  - a new page or new tab

## Explicit Outside-of-boundary Items
- The following remain outside the current official-alert presentation boundary:
  - resource-slot discussion
  - `LLM-expression` discussion
  - implementation approval
- The following also remain outside the current board boundary:
  - alert details page
  - alert history page
  - alert archive
  - multi-level alert browser
  - external-link jump page
  - new page
  - new tab
  - second detail page
  - new path family
  - persisted official-alert truth
  - persisted weather truth
  - persisted location truth

## Formal Conclusion
- Current formal conclusion:
  - `施工天气预警 richer-stage official-alert presentation boundary only`
    discusses only the expression hierarchy and information density of
    `officialAlerts` in collapsed and expanded states
- Current approved inside-boundary minimum:
  - collapsed state shows at most one compact cue
  - expanded state may contain one dedicated official-alert information block
  - empty arrays must never be turned into fake alerts
- Current not-approved-by-this-file:
  - implementation
  - contracts
  - data-source expansion
  - alert history or detail surfaces
  - external navigation or independent alert productization

## Next Unique Action
- Continue only with the explicit non-goals freeze for
  `施工天气预警 richer-stage official-alert presentation boundary only`.
