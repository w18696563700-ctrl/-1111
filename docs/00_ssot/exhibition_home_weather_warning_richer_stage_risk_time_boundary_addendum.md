---
owner: Codex 总控
status: draft
purpose: Freeze the formal discussion boundary for exhibition-home weather warning richer-stage risk-time boundary only, limited to information boundary and presentation hierarchy, without unlocking contracts, L3 truth, scheduling engines, or implementation.
layer: L0 SSOT
---

# 施工天气预警 richer-stage risk-time boundary 冻结单

## Scope
- This addendum applies only to:
  - `施工天气预警 richer-stage risk-time boundary only`
- It freezes only:
  - what the current risk-time discussion may cover
  - how `riskTimeLabel` and `nightRainTimeLabel` may be discussed across
    collapsed and expanded states
  - the minimum current expression boundary for
    `何时最危险`
  - what remains outside the current risk-time boundary
- It does not by itself:
  - approve implementation
  - approve contracts
  - approve a scheduling engine
  - approve a new page family

## Current Object Name
- Current object:
  - `施工天气预警 richer-stage risk-time boundary only`

## Current Discussion Coverage
- The current discussion covers only:
  - the information hierarchy of risk time windows
  - the expression boundary of `riskTimeLabel` in collapsed and expanded state
  - the expression boundary of `nightRainTimeLabel` in collapsed and expanded
    state
  - the detail-level expression boundary of
    `何时最危险`
- The current discussion is:
  - an information-boundary discussion only
  - a presentation-hierarchy discussion only
  - not an implementation approval
  - not a contract approval
  - not a scheduling-system approval

## Current Minimum Risk-time Expression
- The current risk-time discussion may freeze at minimum:
  - one current primary risk window
  - one night-rain window
  - one controlled empty-state expression for
    `待确认 / 当前未返回时段`
- The current discussion may refine:
  - which risk-time carrier should be primary
  - how the main risk window should differ from the night-rain window
  - how the collapsed state should stay compact while still answering
    `哪个时间段最危险`
  - how the expanded state may provide supporting time-window detail without
    becoming a scheduling surface

## Collapsed-state Expression Boundary
- The collapsed state may discuss only:
  - whether the primary risk-time window should appear beside or under the main
    construction conclusion
  - how `riskTimeLabel` should remain compact
  - how `nightRainTimeLabel` may surface only as a supporting cue
  - how to express controlled empty time labels when current time windows are
    not returned
- The collapsed state may not discuss:
  - a full timeline strip
  - an hourly scheduler
  - a reminder control
  - a second detail surface

## Expanded-state Expression Boundary
- The expanded state may discuss only:
  - how `riskTimeLabel` appears inside weather overview or risk-card context
  - how `nightRainTimeLabel` appears as supporting detail
  - how the detail view may answer
    `何时最危险`
    without turning into a scheduling module
  - how controlled empty states should appear when a time window is absent
- The expanded state may not discuss:
  - a full-day hourly timeline page
  - a construction shift planner
  - automatic process ordering
  - calendar or reminder integration
  - push-notification strategy

## Explicit Outside-of-boundary Items
- The following remain outside the current risk-time boundary:
  - suggestion taxonomy discussion
  - official-alert presentation discussion
  - resource-slot discussion
  - `LLM-expression` discussion
  - implementation approval
- The following also remain outside the current board boundary:
  - full timeline page
  - hourly construction scheduler
  - automatic task reordering engine
  - calendar integration
  - reminder integration
  - push notification
  - new page
  - new tab
  - second detail page
  - new path family
  - persisted weather truth
  - persisted location truth

## Formal Conclusion
- Current formal conclusion:
  - `施工天气预警 richer-stage risk-time boundary only` discusses only the
    information boundary and presentation hierarchy of primary risk windows and
    night-rain windows
- Current approved inside-boundary minimum:
  - one current primary risk window
  - one night-rain window
  - one controlled empty expression when the current time label is absent
- Current not-approved-by-this-file:
  - implementation
  - contracts
  - scheduling systems
  - timeline modules
  - push / calendar / reminder integrations

## Next Unique Action
- Continue only with the explicit non-goals freeze for
  `施工天气预警 richer-stage risk-time boundary only`.
