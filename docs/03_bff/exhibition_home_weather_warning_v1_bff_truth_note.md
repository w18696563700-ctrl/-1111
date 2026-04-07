---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side shaping truth for exhibition-home weather warning V1 without creating a new weather domain, persisted truth, or second state machine.
layer: L3 BFF
---

# Exhibition Home Weather Warning V1 BFF Truth Note

## Scope
- This note applies only to the current V1 semantic upgrade for the exhibition
  home weather card.
- It serves only:
  - `GET /api/app/exhibition/home`
  - `POST /api/app/exhibition/home/refresh`
  - `POST /api/app/exhibition/home/location/select`
- It freezes only:
  - `BFF` fixed-rule shaping truth
  - field-level output responsibility
  - optional-signal handling
  - current non-goals
- It does not by itself:
  - create a new app-facing path family
  - create persisted weather truth
  - create persisted location truth
  - turn `Server` into weather owner

## Current Upstream Relation
- `BFF` continues to aggregate the current home response only.
- `BFF` may consume current upstream weather-provider or reverse-geocode
  carriers only through normalized adapters.
- `BFF` must not expose provider-native payloads directly.
- `BFF` must not reinterpret provider cache keys, temporary tokens, or adapter
  transport fields as business truth.

## Fixed-rule Semantic Responsibility
- `BFF` is the only current owner of the V1 construction warning semantic
  shaping layer.
- The V1 core must use a fixed-rule engine only.
- The V1 core must not use `LLM` as the semantic decision owner.
- The canonical current rule-tag set is:
  - `rain`
  - `night_rain`
  - `high_temp`
  - `low_temp`
  - `strong_wind`
  - `lightning`
  - `official_alert`

## Canonical Output Shaping
- `constructionRiskLevel` must be derived from the highest active fixed rule.
- Current severity priority is frozen as:
  1. `lightning`
  2. `official_alert`
  3. `strong_wind`
  4. `high_temp`
  5. `low_temp`
  6. `rain`
  7. `night_rain`
- Current level mapping is frozen as:
  - `critical`:
    - `lightning`
    - or `official_alert`
  - `high`:
    - `strong_wind`
    - `high_temp`
    - `low_temp`
  - `medium`:
    - `rain`
    - `night_rain`
  - `low`:
    - no active rule
- `constructionRiskSummary` must be a fixed-template summary string derived
  from the highest active rule and the current normalized weather snapshot.
- `riskTags` must contain only the active canonical rule tags.
- `riskTimeLabel` must point only to the highest-priority active rule time
  window when that window is stably available; otherwise it must be `null`.
- `nightRainExpected` must be `true` only when the `night_rain` rule triggers.
- `nightRainTimeLabel` must reflect the current normalized night-rain time
  label when available; otherwise it must be `null`.
- `officialAlerts` must be a controlled user-facing string array and may be
  empty.
- `constructionSuggestions` must be:
  - fixed-template only
  - deduplicated
  - deterministically ordered
  - always `3-5` items

## Optional-signal Handling
- `strong_wind`, `lightning`, and `official_alert` may trigger only when the
  current upstream adapter can provide those signals stably.
- If those signals are not stably available:
  - the corresponding rule must stay inactive
  - `riskTags` must not fabricate the corresponding tag
  - `officialAlerts` may remain an empty array
  - `constructionRiskLevel` must be computed from the remaining active rules

## Template-output Discipline
- `constructionRiskSummary` must stay one short controlled sentence only.
- `constructionSuggestions` must come from the current fixed template bank
  only.
- When no active rule exists, `BFF` must still return low-risk generic
  construction suggestions.
- `BFF` must not inject:
  - advertisements
  - nearby resources
  - emergency-service promotions
  - long prose explanation

## Current Non-goals
- No `/api/app/weather/*`
- No persisted weather truth
- No persisted location truth
- No `Server` migration
- No second weather state machine
- No provider-native payload passthrough
- No `LLM`-core decisioning

## Formal Conclusion
- Current `BFF` truth conclusion:
  - exhibition-home weather warning `V1` is a fixed-rule semantic shaping layer
    inside the existing home aggregation only
- Current `BFF` owner boundary:
  - semantic judgment and template output only
- Current `BFF` non-owner boundary:
  - no weather truth ownership
  - no location truth ownership
  - no new path family
