---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side shaping boundary for the minimum forum interaction loop, including comment reads and writes, like, bookmark, my-comments, and my-bookmarks without creating a second interaction state machine or transferring forum interaction truth out of Server.
layer: L3 BFF
---

# Forum Interaction-loop BFF Surface Addendum

## Scope
- This addendum applies only to the current BFF truth refinement for:
  - `forum interaction-loop minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the allowed `BFF` shaping responsibilities for the six canonical
    interaction paths
  - the current building-specific shaping split
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve release
  - approve closure
  - approve a second interaction state machine

## BFF Responsibility Boundary
- For this package, `BFF` may do only:
  - auth consolidation
  - response shaping
  - visibility trimming
  - route-group handoff for the six canonical interaction paths
  - light idempotency when needed
  - controlled Chinese error normalization
- `BFF` must not own:
  - `ForumComment` truth
  - `ForumBookmark` truth
  - post like truth
  - profile truth
  - messages truth
  - a second interaction state machine

## Current Allowed Interaction Surface
- `BFF` may shape only:
  - `GET /api/app/forum/post/comments`
  - `POST /api/app/forum/post/comment`
  - `POST /api/app/forum/post/like`
  - `POST /api/app/forum/post/bookmark`
  - `GET /api/app/forum/me/comments`
  - `GET /api/app/forum/me/bookmarks`
- `BFF` must not create:
  - a second interaction route tree
  - a `messages`-local discussion route family
  - a `profile`-local main browse route family

## Comment-loop Shaping Boundary
- `BFF` may shape only:
  - visible post comment list output
  - visible comment-create acceptance output
  - controlled invalid / invalid-state messages
- `BFF` must not turn comment submit into:
  - a second draft lifecycle
  - a moderation console preview
  - a second discussion owner outside forum

## Like And Bookmark Shaping Boundary
- `BFF` may shape only:
  - accepted like toggle output
  - accepted bookmark toggle output
  - the latest actor-visible state returned from `Server`
- `BFF` must not:
  - invent fake local truth
  - persist shadow interaction state
  - create a second preference graph

## `Messages` And `Profile` Boundary
- `messages` is not a consumer of the current six-path interaction package as a
  browsing chain.
- `profile` may consume only:
  - `我的评论`
  - `我的收藏`
- `BFF` must therefore keep the shaping split frozen as:
  - main interaction loop under `exhibition/forum`
  - bounded me-assets under `profile`

## Current Explicit Non-goals
- No comment image/file upload shaping
- No comment moderation expansion
- No comment edit/delete shaping
- No post edit/delete shaping
- No report-center shaping
- No author follow or DM shaping
- No second interaction state machine

## Formal Conclusion
- Current formal conclusion:
  - `BFF` may shape only the six canonical minimum interaction-loop paths
  - `BFF` does not own comment, like, or bookmark truth
  - `BFF` must not create a second discussion tree or second interaction state
    machine
  - `profile` may consume only bounded `我的评论 / 我的收藏` surfaces while
    `messages` stays outside the main interaction chain

## Next Unique Action
- After backend truth lands, dispatch `BFF` Agent second to wire the six
  canonical interaction paths under the existing forum aggregation boundary.
