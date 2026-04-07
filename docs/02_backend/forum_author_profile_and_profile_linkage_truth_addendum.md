---
owner: Codex 总控
status: draft
purpose: Freeze the Server-side truth boundary for forum public author profile and its bounded linkage to the existing profile building without transferring avatar or profile ownership into forum.
layer: L3 Backend
---

# Forum Author Profile And Profile Linkage Truth Addendum

## Scope
- This addendum applies only to the current backend truth refinement for:
  - `论坛作者主页与我的楼联动`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the current Server-side truth ownership
  - the minimum truth sources for public author profile reads
  - the boundary between public author profile and `profile`
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - rewrite the existing forum domain baseline
  - approve avatar upload or avatar edit
  - approve own-post edit or delete

## Server Ownership Stays Unchanged
- `Server` remains the only truth owner for:
  - forum public author-profile read truth
  - forum public author-posts read truth
  - visibility trimming of public forum content
- `Server` also remains the only owner of:
  - forum post visibility truth
  - forum publish and moderation truth
- This package does not transfer any truth ownership to:
  - `BFF`
  - Flutter App
  - `profile` as a separate public-author truth owner

## Minimum Truth-source Boundary
- Current public author profile may consume only the following truth sources:
  - public author identity projection
  - public forum posts projection
  - bounded public counts projection derived from visible forum truth
- The current minimum truth-source split is:
  - `authorId` anchor:
    - forum public author reference carried by forum post truth
  - `displayName` and avatar projection:
    - user / identity / profile truth projection
  - optional `organizationName` projection:
    - bounded public organization projection only
  - public posts list:
    - visible `ForumPost` projection only
  - bounded counts:
    - visible public forum counts only

## Public Author Profile Query Boundary
- The current minimum backend query families for this capability are:
  - `forum_author_profile_query`
  - `forum_author_posts_query`
- `forum_author_profile_query` may project only:
  - `authorId`
  - `displayName`
  - avatar projection
  - optional `organizationName`
  - bounded public counts
- `forum_author_posts_query` may project only:
  - public visible posts by `authorId`
- `forum_author_posts_query` must not become:
  - a draft query
  - a private me-assets query
  - a moderation query
  - a hidden-post query

## Boundary With Profile Building
- Public author profile belongs to:
  - forum public browsing truth
- `profile` building belongs to:
  - current-user private or semi-private asset and identity truth
- Therefore the current truth split is:
  - public author profile = look at public forum image
  - `profile` = current actor asset and identity center
- Current backend truth must not:
  - push profile-private identity truth into forum public reads
  - treat `profile` as the owner of public author pages
  - merge public author page reads with private me-assets reads

## Avatar Truth Boundary
- Avatar truth remains owned by:
  - user / profile identity truth
- Forum may consume only:
  - avatar projection
- Forum must not own:
  - avatar upload truth
  - avatar edit truth
  - avatar file-management truth
- Current backend truth therefore must not reinterpret:
  - `users.avatar_url`
  - identity/profile avatar carriers
  as forum-owned truth

## Current Explicit Non-goals
- No author-follow truth
- No author DM truth
- No avatar upload truth implementation
- No avatar edit truth implementation
- No public/private profile mixed-table shortcut
- No rich-publish media reuse truth in this package
- No automatic post-location truth in this package
- No AI review gate in this package
- No own-post edit or delete truth in this package

## Current Truth Meaning
- This addendum belongs only to:
  - forum public-author backend truth refinement
- It is:
  - backend truth
- It is not:
  - implementation completion
  - profile-truth ownership transfer
  - avatar-edit approval
  - author-follow approval

## Formal Conclusion
- Current formal conclusion:
  - `Server` remains the only truth owner
  - public author profile consumes only bounded public identity and forum-post
    projections
  - `profile` remains the current-user asset and identity center
  - forum consumes avatar projection only and cannot own avatar truth
- Current meaning:
  - L3 backend truth for public author profile and profile linkage only

## Next Unique Action
- After this truth package is frozen, dispatch backend Agent first to land:
  - `forum_author_profile_query`
  - `forum_author_posts_query`
  - the bounded projection split above
