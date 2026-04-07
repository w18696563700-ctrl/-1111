---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side forum route-group shaping truth before implementation, preserving BFF as the only app-facing forum aggregation layer without transferring forum truth ownership out of Server.
layer: L3 BFF
---

# Forum BFF Route-group Truth Addendum

## Scope
- This addendum applies only to the current pre-implementation `BFF` truth
  refinement for forum route groups.
- It freezes only:
  - the `BFF` forum aggregation role
  - the allowed shaping responsibilities
  - the current non-owner boundaries
  - the minimum forum route-group families
- It does not by itself:
  - approve implementation
  - approve `Server` domain-truth rewrite
  - approve a second forum truth owner

## Current Aggregation Role
- `BFF` remains the only app-facing forum aggregation layer.
- `BFF` may do only:
  - auth consolidation
  - response shaping
  - visibility trimming
  - route-group aggregation
  - light idempotency when needed

## Current Non-owner Boundary
- `BFF` must not own:
  - forum business truth
  - review state machine
  - moderation state machine
  - follow truth ownership
  - like truth ownership
  - comment truth ownership
- `BFF` must not create:
  - a second forum ranking engine
  - a second moderation truth tree
  - a second follow graph

## Minimum Route-group Families
- Current forum `BFF` truth must cover at minimum:
  - feed family:
    - square
    - local
    - following
  - detail family:
    - post detail
    - post comments
    - topic metadata for classify, select, and filter
  - interaction family:
    - like
    - comment
    - follow
  - publish and draft family:
    - publish
    - draft save
    - draft list
    - draft delete
  - me-assets family:
    - my posts
    - my comments
    - my bookmarks
    - my follows
  - interaction inbox family for the `messages` building

## Cross-building Consumption Rule
- `messages` interaction center may consume forum-related reminders only
  through forum-originated interaction-inbox semantics.
- `messages` must not consume a duplicated forum object tree.
- `profile` forum assets may consume only the me-assets family semantics.
- `profile` must not consume the forum main browsing route groups as its own
  home chain.

## Current Non-goals
- No `BFF` forum business truth ownership
- No `BFF` moderation ownership
- No `BFF` review-state ownership
- No direct `Server` bypass for Flutter App
- No second forum route tree outside the current app-facing family
- No implementation approval in this addendum

## Formal Conclusion
- Current `BFF` truth conclusion:
  - `BFF` remains the only app-facing forum aggregation layer
  - `BFF` shapes and aggregates route groups only
  - forum truth remains owned by `Server`
  - `messages` may consume interaction inbox semantics only
  - `profile` may consume me-assets semantics only
- Current truth meaning:
  - L3 `BFF` route-group shaping truth only
- Current non-approved meaning:
  - no implementation approval
  - no `Server` truth rewrite
  - no second forum truth owner

