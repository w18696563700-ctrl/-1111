---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side shaping boundary for forum public author profile and its linkage to the current profile building without creating a second personal center or a second author truth owner.
layer: L3 BFF
---

# Forum Author Profile BFF Surface Addendum

## Scope
- This addendum applies only to the current BFF truth refinement for:
  - `论坛作者主页与我的楼联动`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the BFF aggregation role for public author profile
  - the minimum route-group surface for public author profile
  - the bounded self-vs-other shaping allowance
  - the current non-owner boundary
- It does not by itself:
  - approve implementation completion
  - approve author-follow truth
  - approve DM truth
  - rewrite Server truth ownership

## BFF Aggregation Role Stays Unchanged
- `BFF` remains the only app-facing forum aggregation layer.
- For public author profile, `BFF` may do only:
  - auth consolidation
  - response shaping
  - visibility trimming
  - route-group aggregation
  - light self-vs-other handoff shaping when needed
- `BFF` must not own:
  - author truth
  - profile truth
  - avatar truth

## Minimum Author-profile Route-group Surface
- The current minimum BFF route-group surface for this capability covers only:
  - author profile summary read
  - author public posts read
- The corresponding app-facing paths remain inside the current forum family:
  - `GET /api/app/forum/author/profile`
  - `GET /api/app/forum/author/posts`
- `BFF` must not create:
  - `/api/app/social/*`
  - a second forum path family
  - a duplicated author-home subtree under `messages` or `profile`

## Allowed Shaping Boundary
- `BFF` may shape only:
  - public author summary projection
  - public author posts projection
  - bounded list-card shaping for author posts
  - self-vs-other handoff cues when the current actor opens a public author
    page
- `BFF` may not shape or invent:
  - author-follow state truth
  - DM handoff truth
  - avatar upload truth
  - author-private profile truth
  - a second personal center

## Cross-building Output Rule
- `exhibition/forum` consumes:
  - public author profile summary
  - public author posts
- `profile` consumes only:
  - current-user asset and identity semantics
- `messages` consumes only:
  - interaction inbox semantics
- Therefore BFF must not let:
  - `profile` become the public-author truth owner
  - `messages` become the author-home carrier

## Current Explicit Non-goals
- No author-follow state machine
- No author DM handoff truth
- No avatar upload or avatar edit truth
- No rich-publish media reuse in this package
- No automatic post-location truth in this package
- No AI review gate in this package
- No own-post edit or delete truth in this package
- No second forum-owned personal center

## Current Truth Meaning
- This addendum belongs only to:
  - public author-profile BFF surface truth
- It is:
  - BFF truth
- It is not:
  - implementation completion
  - Server truth rewrite
  - author-follow approval
  - DM approval

## Formal Conclusion
- Current formal conclusion:
  - `BFF` remains an aggregation and shaping layer only
  - `BFF` may aggregate only public author summary, public author posts, and
    bounded self-vs-other handoff shaping
  - `BFF` does not own author truth, profile truth, or avatar truth
- Current meaning:
  - L3 BFF truth for public author profile only

## Next Unique Action
- After backend truth lands, dispatch `BFF` Agent second to expose the two
  author-profile paths and keep shaping inside the frozen boundary above.
