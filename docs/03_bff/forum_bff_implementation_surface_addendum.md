---
owner: Codex 总控
status: draft
purpose: Freeze the implementation-facing BFF shaping surface for the current forum round so the later backend prompts can implement one bounded route family without reopening forum truth ownership.
layer: L3 BFF
---

# Forum BFF Implementation Surface Addendum

## Scope
- This addendum applies only to the current forum implementation round.
- It freezes only:
  - the current BFF route-group surface
  - the current shaping responsibilities
  - the current cross-building consumption split
  - the current non-goals
- It does not by itself:
  - transfer forum truth ownership away from `Server`
  - approve a second forum state machine
  - approve implementation outside the current forum board

## Current Route-group Surface
- Current BFF forum route groups must cover at minimum:
  - feed read group
  - topic metadata and topic detail read group
  - post detail and post comment-chain read group
  - interaction command group:
    - post like
    - post bookmark
    - topic follow
    - post comment create
  - draft and publish group
  - search group
  - me-assets read group
  - interaction inbox read group

## Current Shaping Responsibilities
- `BFF` may do only:
  - auth consolidation
  - actor / visibility trimming
  - response shaping
  - route-family aggregation
  - light idempotency when needed
- `BFF` may shape:
  - feed scope request parameters
  - list-card projections
  - viewer-facing booleans such as current actor engagement flags
  - bounded interaction-inbox read models
  - bounded me-assets read models
- `BFF` must not own:
  - feed ranking truth
  - moderation truth
  - publish eligibility truth
  - comment truth
  - like / bookmark / follow truth

## Current Feed And Topic Rules
- `BFF` must expose `square / local / following` as peer feed scopes within the
  current forum family.
- `BFF` must not re-elevate topic into a first-level home route family.
- Topic remains internal taxonomy and may be shaped only for:
  - publish-time selection
  - post-title labeling
  - feed filtering

## Cross-building Output Rules
- `exhibition/forum` consumes:
  - feed
  - topic metadata
  - topic detail
  - post detail
  - comment chain
  - interaction command surfaces
  - publish / draft
  - search
- `messages` consumes only:
  - interaction inbox semantics
- `profile` consumes only:
  - me-assets semantics
- `messages` and `profile` must not receive a duplicated forum browse tree from
  `BFF`.

## Current Non-goals
- No second path family outside `/api/app/forum/*`
- No duplicated forum object tree under `messages`
- No profile-owned forum browsing chain
- No moderation console surfaces
- No ranking or recommendation surface

## Formal Conclusion
- Current BFF conclusion:
  - BFF implementation may proceed on the approved forum route groups above
  - forum remains the only app-facing path family
  - `messages` and `profile` consume bounded forum-derived projections only
- Current meaning:
  - implementation-facing BFF shaping truth for the current forum round
- Current non-approved meaning:
  - no forum truth ownership transfer
  - no second forum state machine
