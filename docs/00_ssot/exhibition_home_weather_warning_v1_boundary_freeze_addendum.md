---
owner: Codex 总控
status: draft
purpose: Freeze the V1 semantic upgrade that turns the existing exhibition-home weather card into a construction weather warning module without creating a new weather domain, new page family, or persisted weather truth.
layer: L0 SSOT
---

# 展览首页天气预警语义升级 V1 冻结单

## Scope
- This addendum applies only to the current semantic-upgrade round for the
  existing exhibition-home weather card.
- It freezes only:
  - the V1 semantic-upgrade boundary
  - the current path-family boundary
  - the required `ExhibitionHomeResponse` contract increment
  - the fixed-rule semantic boundary for construction weather warning
  - the Frontend / `BFF` / `Server` responsibility split
  - the explicit current non-goals
- It does not by itself:
  - rebuild the exhibition home
  - create a new weather domain
  - create a new page family
  - approve any `LLM`-driven weather judgment
  - create persisted weather truth or persisted location truth

## Current Board And Canonical Path Family
- This round is not a homepage rewrite.
- This round upgrades only the existing home weather-card semantics.
- The current canonical path family remains:
  - `GET /api/app/exhibition/home`
  - `POST /api/app/exhibition/home/refresh`
  - `POST /api/app/exhibition/home/location/select`
- This round must not introduce:
  - `/api/app/weather/*`
  - weather-only refresh paths
  - any second home-page path family

## V1 Semantic Upgrade Boundary
- The existing weather card is upgraded into:
  - a construction weather warning module `V1`
- `V1` means:
  - the current weather block keeps serving first-screen home consumption
  - the semantic layer is upgraded from generic weather summary to
    construction-risk-oriented guidance
  - the result remains one normalized home read model only
- `V1` does not mean:
  - a new weather business domain
  - persisted weather or location truth on `Server`
  - a new home module family
  - a new page or subpage

## Required Contract Increment On ExhibitionHomeResponse
- The current `ExhibitionHomeResponse` must add:
  - `constructionRiskLevel: low | medium | high | critical`
  - `constructionRiskSummary: string`
  - `riskTags: string[]`
  - `riskTimeLabel: string|null`
  - `nightRainExpected: boolean`
  - `nightRainTimeLabel: string|null`
  - `officialAlerts: string[]`
  - `constructionSuggestions: string[]`
- These fields are semantic upgrade fields only.
- They do not create a second weather truth owner.

## V1 Fixed-rule Boundary
- Core judgment must use:
  - fixed-rule evaluation only
- Core judgment must not use:
  - `LLM` as the semantic decision core
- Current V1 rule families are frozen as:
  - `rain`
  - `night_rain`
  - `high_temp`
  - `low_temp`
  - `strong_wind`
  - `lightning`
  - `official_alert`
- `strong_wind`, `lightning`, and `official_alert` may be enabled only when
  the current upstream adapter can provide those inputs stably.
- If the current upstream adapter cannot provide those inputs stably:
  - the rule must stay untriggered
  - `officialAlerts` may remain an empty array
  - `riskTags` must not fabricate unsupported tags
  - the response must not pretend upstream evidence exists
- `constructionRiskLevel` must come from the highest active fixed-rule family.
- `constructionRiskSummary` must be a fixed-template user-facing summary, not a
  generated paragraph.
- `riskTags` must carry only the currently frozen rule tags.
- `riskTimeLabel` may be `null` when the highest active rule has no stable
  current time-window label.
- `nightRainExpected` is the explicit boolean carrier for the `night_rain`
  semantic.
- `nightRainTimeLabel` may be `null` when current night-rain timing is not
  stably available.
- `officialAlerts` is allowed to be an empty array.
- `constructionSuggestions` must be fixed-template output only, with:
  - `3-5` items
  - deterministic ordering
  - no ad slot
  - no emergency resource slot

## Responsibility Split
- Frontend is responsible only for:
  - consuming the upgraded home weather-warning carrier
  - upgrading the current card's collapsed and expanded presentation
  - controlled empty-state presentation when optional warning inputs are absent
- `BFF` is responsible only for:
  - fixed-rule evaluation
  - normalized semantic shaping
  - fixed-template summary and suggestion output
  - controlled fallback when optional upstream warning signals are unavailable
- `Server` is responsible only for:
  - staying `no-op` in this round
  - not becoming weather truth owner
  - not adding migration or persisted weather/location truth

## Frontend Consumption Boundary
- Frontend must not add a new page.
- Frontend must continue using the current:
  - collapsed weather card
  - expanded weather card
- In collapsed state, the card must prioritize:
  - today's construction focus
  - risk level
  - whether there is night rain or an official alert
- In expanded state, `V1` must show at minimum:
  - today's construction weather overview
  - construction risk card
  - today's construction suggestions
  - official alerts when present
- `V1` must not add:
  - resource slots
  - advertisement slots
  - a second weather panel
  - a second rule engine on the client

## Current Explicit Non-goals
- No `/api/app/weather/*`
- No persisted weather truth
- No persisted location truth
- No `Server` migration
- No `LLM`-core weather judgment
- No advertisement slot
- No emergency resource slot
- No new page
- No reinterpretation of this round as a new weather domain launch

## Formal Conclusion
- Current formal conclusion:
  - the existing exhibition-home weather card may be upgraded to
    `施工天气预警模块 V1`
- Current closure type:
  - semantic-upgrade freeze only
- Current approved implementation-facing split remains:
  - `Server = no-op`
  - `BFF = fixed-rule semantic owner`
  - `Frontend = existing-card consumer upgrade`

## Next Unique Action
- Continue only with:
  - contract increment
  - `BFF` truth note
  - frontend consumption truth note
  under the frozen current V1 boundary.
