---
owner: Codex 总控
status: draft
purpose: Freeze the Server-side truth boundary for the minimum forum interaction loop, including comment creation, comment-list reads, post likes, post bookmarks, and actor-scoped my-comments/my-bookmarks projections without creating a second discussion tree or a second interaction state machine.
layer: L3 Backend
---

# Forum Interaction-loop Truth Addendum

## Scope
- This addendum applies only to the current backend truth refinement for:
  - `forum interaction-loop minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the Server-side ownership split for minimum interaction truth
  - the current comment-loop truth boundary
  - the current like/bookmark truth boundary
  - the current me-comments / me-bookmarks query boundary
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve release
  - approve closure
  - rewrite the forum domain baseline

## Server Ownership Stays Unchanged
- `Server` remains the only truth owner for:
  - `ForumComment`
  - `ForumBookmark`
  - forum post engagement write truth
  - forum visibility truth
  - forum actor-scoped me-assets query truth
- Current meaning:
  - comment truth is still post-bound forum discussion truth
  - bookmark truth is still actor-bound saved-post truth
  - like truth is still Server-owned post-interaction truth, not frontend-owned
    fake local state

## Comment-loop Truth Boundary
- Current comment submit may create only:
  - a visible reply on an existing post
  - a visible reply on an existing parent comment
- Current comment submit must not create:
  - a second comment draft tree
  - a private message thread
  - a messages-owned discussion tree
- Current comment-list read must project only:
  - visible forum comment context under a post
  - bounded parent/child reply semantics already allowed by the current
    `postId + optional parentCommentId` contract
- Current comment-list read must not become:
  - moderation truth
  - operator tooling
  - a second interaction state machine

## Like And Bookmark Truth Boundary
- Current post like action remains:
  - actor-scoped post engagement truth owned by `Server`
  - materialized into forum read projections only after `Server` acceptance
- Current post bookmark action remains:
  - `ForumBookmark` truth owned by `Server`
  - actor-scoped saved-post preference truth
- Neither action may be treated as:
  - frontend-owned truth
  - `BFF`-owned truth
  - `messages`-owned interaction truth

## `Profile` Me-assets Query Boundary
- Current `GET /api/app/forum/me/comments` may project only:
  - actor-scoped `ForumComment` asset cards
  - their bounded post-context anchors
- Current `GET /api/app/forum/me/bookmarks` may project only:
  - actor-scoped saved-post cards
- These query families remain:
  - bounded `profile` forum assets
  - not a second forum browse tree
  - not public feed truth

## Building Ownership Boundary
- `exhibition/forum` remains the only main browsing consumer of:
  - post detail
  - post comments
  - post comment creation
  - like
  - bookmark
- `profile` may consume only:
  - `我的评论`
  - `我的收藏`
- `messages` must not own:
  - comment submit truth
  - comment tree truth
  - like/bookmark write truth

## Current Audit And Visibility Meaning
- Current interaction writes remain inside the existing forum truth corridor for:
  - visibility checks
  - state checks
  - audit attribution
- This package does not require:
  - a second review-state machine
  - a second moderation-state machine
  - a second interaction write tree

## Current Explicit Non-goals
- No comment image/file upload truth
- No comment moderation expansion
- No comment edit truth
- No comment delete truth
- No post edit/delete truth
- No report-center expansion
- No author follow truth
- No DM truth
- No second interaction state machine

## Formal Conclusion
- Current formal conclusion:
  - `Server` remains the only owner of the minimum forum interaction-loop truth
  - comment submit remains inside the same post-bound forum discussion tree
  - like and bookmark remain Server-owned interaction truth, not frontend fake
    state
  - `我的评论 / 我的收藏` remain bounded actor-scoped projections for
    `profile`
  - this package does not approve comment attachments, comment edit/delete,
    post edit/delete, report-center expansion, or a second interaction state
    machine

## Next Unique Action
- After this truth package is frozen, dispatch backend Agent first to land:
  - comment-list read truth
  - comment-submit truth
  - post like/bookmark truth
  - my-comments / my-bookmarks query truth
