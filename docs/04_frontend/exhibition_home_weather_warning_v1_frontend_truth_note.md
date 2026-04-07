---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side consumption truth for exhibition-home weather warning V1 without introducing a new page, a second client rule engine, or resource-slot expansion.
layer: L3 Frontend
---

# Exhibition Home Weather Warning V1 Frontend Truth Note

## Scope
- This note applies only to the current Flutter-side consumption upgrade for
  the exhibition-home weather card.
- It serves only:
  - route `/exhibition`
  - the existing collapsed weather card
  - the existing expanded weather card
- It freezes only:
  - V1 display priority
  - field-to-surface consumption boundary
  - optional-content handling
  - current non-goals
- It does not by itself:
  - create a new page
  - create a second client rule engine
  - create a second weather module

## Current Route Relation
- Current route remains:
  - `/exhibition`
- The current weather-warning upgrade must stay inside the existing ordered home
  first screen.
- Frontend must not create:
  - `/exhibition/weather`
  - a second details page
  - a resource page
  - an advertising page

## Collapsed-state Consumption Priority
- The collapsed card must prioritize:
  - today's construction focus from `constructionRiskSummary`
  - current risk level from `constructionRiskLevel`
  - current night-rain or alert cue from:
    - `nightRainExpected`
    - `nightRainTimeLabel`
    - `officialAlerts`
- The collapsed state may render at most one compact alert cue.
- The collapsed state must not become:
  - a long recommendation list
  - a resource wall
  - a second dashboard

## Expanded-state Consumption Boundary
- The expanded state must show at minimum:
  - today's construction weather overview
  - construction risk card
  - today's construction suggestions
  - official alerts when present
- The expanded state should consume:
  - existing baseline weather fields for overview
  - `constructionRiskLevel`
  - `constructionRiskSummary`
  - `riskTags`
  - `riskTimeLabel`
  - `nightRainExpected`
  - `nightRainTimeLabel`
  - `constructionSuggestions`
  - `officialAlerts`

## Optional-content Handling
- `officialAlerts` may be an empty array.
- When `officialAlerts` is empty:
  - the official-alert block must stay hidden or collapsed
  - the UI must not fabricate an alert badge
- When `riskTimeLabel` is `null`:
  - the UI must not fabricate a precise time window
- When `nightRainExpected = false`:
  - the UI must not fabricate a night-rain label
- Frontend must consume `riskTags` read-only.
- Frontend must not invent:
  - its own risk level
  - its own warning tags
  - its own official alert summary

## Current Explicit Non-goals
- No new page
- No new tab
- No advertisement slot
- No nearby resource slot
- No emergency-resource slot
- No client-side `LLM` or second rule engine
- No reinterpretation of optional-empty values as missing backend support

## Formal Conclusion
- Current frontend conclusion:
  - exhibition-home weather warning `V1` is an in-place consumption upgrade on
    the existing home card only
- Current frontend owner boundary:
  - display priority
  - collapsed and expanded rendering
  - controlled empty handling
- Current frontend non-owner boundary:
  - no semantic rule invention
  - no new page family
  - no resource-slot or ad-slot expansion
