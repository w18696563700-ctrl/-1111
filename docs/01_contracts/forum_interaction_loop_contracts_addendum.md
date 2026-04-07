---
owner: Codex 总控
status: draft
purpose: Freeze the minimum forum interaction-loop contract package for comment submit, comment-list reads, like, bookmark, my-comments, and my-bookmarks without creating a second discussion path or a second interaction state machine.
layer: L2 Contracts
---

# Forum Interaction-loop Contracts Addendum

## Scope
- This addendum applies only to the current L2 contract refinement for:
  - `forum interaction-loop minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the minimum canonical interaction paths
  - the current request/response semantics
  - the current building-specific consumption boundary
  - the current explicit non-goals
- It does not by itself:
  - approve implementation
  - approve integration release
  - approve closure
  - approve a second interaction path family

## Stage Gate Reminder
- Current allowed entry:
  - `L2 / L3 truth refinement`
- Current forbidden entry:
  - implementation
  - integration release
  - closure
- Current veto:
  - do not mix in own-post edit/delete
  - do not mix in report-center expansion
  - do not mix in author follow or DM
  - do not mix in automatic location
  - do not mix in AI review gate expansion

## Canonical Path Set
- The current minimum interaction-loop package freezes only:
  - `GET /api/app/forum/post/comments`
  - `POST /api/app/forum/post/comment`
  - `POST /api/app/forum/post/like`
  - `POST /api/app/forum/post/bookmark`
  - `GET /api/app/forum/me/comments`
  - `GET /api/app/forum/me/bookmarks`
- This package does not approve:
  - a second `/api/app/forum/interaction/*` write family
  - a `messages`-local discussion path family
  - a `profile`-local main-browse path family

## Comment-list Contract Boundary
- `GET /api/app/forum/post/comments` remains:
  - the visible post-comment chain read projection
  - a post-detail companion read only
- Minimum request semantics:
  - `postId`
  - optional `cursor`
  - optional `pageSize`
- Minimum response carrier remains:
  - `ForumCommentListResponse`
- Contract meaning:
  - visible discussion context only
  - not moderation truth
  - not a second discussion state machine

## Comment-submit Contract Boundary
- `POST /api/app/forum/post/comment` remains:
  - the only current app-facing comment-submit command in this package
- Minimum request carrier remains:
  - `ForumCommentCreateRequest`
- Minimum request meaning remains:
  - `postId`
  - optional `parentCommentId`
  - `body`
- Minimum response carrier remains:
  - `ForumCommentAcceptedResponse`
- Contract meaning:
  - create visible reply truth against an existing post or parent comment
  - no second comment draft lifecycle
  - no comment attachment binding in this round

## Like And Bookmark Contract Boundary
- `POST /api/app/forum/post/like` remains:
  - the only current post-like toggle command in this package
- `POST /api/app/forum/post/bookmark` remains:
  - the only current post-bookmark toggle command in this package
- Minimum accepted response carrier for both remains:
  - `ForumToggleAcceptedResponse`
- Current contract meaning:
  - actor action is handed off to Server-owned forum interaction truth
  - frontend does not own the final state
  - no second interaction protocol is approved

## `Profile` Me-assets Contract Boundary
- `GET /api/app/forum/me/comments` remains:
  - bounded `我的评论` projection for the `profile` forum-assets surface
- `GET /api/app/forum/me/bookmarks` remains:
  - bounded `我的收藏` projection for the `profile` forum-assets surface
- Minimum response carriers remain:
  - `ForumMyCommentsResponse`
  - `ForumMyBookmarksResponse`
- Contract meaning:
  - actor-scoped read projections only
  - not a second forum homepage
  - not public feed semantics

## Current Error Boundary
- The current package does not require:
  - a new interaction-only error-code family
- Current meaning remains:
  - malformed comment requests continue to use the existing forum invalidity
    corridor
  - invalid comment state continues to use the existing forum invalid-state
    corridor
  - like and bookmark continue to stay inside existing forum command-acceptance
    semantics

## Current Explicit Non-goals
- No comment image upload contract
- No comment file upload contract
- No comment edit/delete contract
- No post edit/delete contract
- No report-center contract expansion
- No author follow contract
- No DM contract
- No second interaction state machine

## Formal Conclusion
- Current formal conclusion:
  - the minimum interaction-loop contract package is frozen to the six
    canonical paths above only
  - comment submit remains inside the same forum discussion tree
  - like and bookmark remain Server-owned interaction actions rather than
    frontend-owned truth
  - `我的评论 / 我的收藏` remain bounded `profile` forum assets only
  - no second interaction path family is approved in this package

## Next Unique Action
- After the L2/L3 package is frozen, dispatch backend Agent first to land the
  canonical interaction truth behind these six paths.
