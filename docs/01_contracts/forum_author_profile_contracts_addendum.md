---
owner: Codex 总控
status: draft
purpose: Freeze the minimum app-facing contract package for forum public author profile and its linkage to the existing profile building without creating a second forum path family or mislabeling the capability as already implemented.
layer: L2 Contracts
---

# Forum Author Profile Contracts Addendum

## Scope
- This addendum applies only to the current L2 contract refinement for:
  - `论坛作者主页与我的楼联动`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the canonical app-facing author-profile path family boundary
  - the minimum public author anchor and summary semantics
  - the boundary between public author posts and private me-assets
  - the current non-approved meanings
- It does not by itself:
  - approve implementation
  - approve final release output
  - approve result verification
  - create a second forum path family

## Canonical Path-family Rule
- Current public author-profile capability must remain inside the existing
  forum canonical family:
  - `/api/app/forum/*`
- Current contract truth must not create:
  - `/api/app/social/*`
  - a second forum path family
  - a `messages`-local author-profile path family
  - a `profile`-local public-author path family

## Minimum App-facing Path Pair
- The minimum app-facing public-author paths are:
  - `GET /api/app/forum/author/profile`
  - `GET /api/app/forum/author/posts`
- Current minimum query semantics:
  - `authorId` is the only public-author anchor
  - `authorId` is required for both paths
- `GET /api/app/forum/author/posts` may later add only bounded list queries:
  - `cursor`
  - `pageSize`
- Current contract truth does not approve:
  - `authorSlug`
  - `nickname` as a routing anchor
  - `mobile`
  - organization-private ids

## Minimum Public Author Summary Boundary
- The current minimum public author-profile summary discusses only:
  - `authorId`
  - `displayName`
  - read-only avatar projection
  - optional `organizationName` projection
  - bounded public counts projection
- Current bounded public counts projection may include only:
  - `publicPostCount`
  - `publicCommentCount`
- Current bounded public counts projection must not include:
  - draft count
  - bookmark count
  - follow count
  - private asset count
  - private identity fields
- Avatar in this package is:
  - projection only
  - not upload truth
  - not edit truth

## Author Public-posts Boundary
- `GET /api/app/forum/author/posts` may return only:
  - public visible forum posts for the specified `authorId`
- It must not become:
  - a private asset interface
  - a draft list
  - a hidden-post list
  - a moderation queue
  - a replacement for `GET /api/app/forum/me/*`
- The author-posts list may reuse only:
  - the current public post-card or post-feed projection family
  - the current cursor-page carrier family

## Cross-building Consumption Boundary
- Public author profile belongs to:
  - the public forum surface
  - the existing `exhibition/forum` browsing family
- `profile` remains:
  - the current actor's asset and identity center
- `messages` remains:
  - interaction-center only
- Therefore this package freezes:
  - public author profile is not a `profile`-owned contract subtree
  - public author posts are not private me-assets contracts

## Current Explicit Non-goals
- No author follow contract
- No DM contract
- No author private-profile contract
- No public author homepage editing contract
- No avatar upload or avatar edit contract
- No own-post edit or delete contract
- No rich-publish media-upload contract
- No automatic post-location contract
- No AI review gate contract

## Current Contract Meaning
- This addendum belongs only to:
  - forum public-author L2 contract truth
- It is:
  - contract truth
- It is not:
  - implementation approval
  - returned-field final projection output
  - author-follow approval
  - DM approval
  - avatar-edit approval

## Formal Conclusion
- Current formal conclusion:
  - public author profile remains under `/api/app/forum/*`
  - the minimum path pair is
    `GET /api/app/forum/author/profile` and
    `GET /api/app/forum/author/posts`
  - `authorId` is the only current public-author anchor
  - public author posts carry public visible posts only
  - `profile` does not become the truth owner of public author profile
- Current meaning:
  - forum author-profile L2 contract refinement only

## Next Unique Action
- After this L2/L3 truth package is frozen, execution may be dispatched in the
  following order only:
  1. backend Agent
  2. `BFF` Agent
  3. frontend Agent
