---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side consumption boundary for the minimum forum interaction loop, including comments, like, bookmark, my-comments, and my-bookmarks without creating a second interaction state machine or turning profile/messages into a second forum home.
layer: L3 Frontend
---

# Forum Interaction-loop Frontend Surface Addendum

## Scope
- This addendum applies only to the current frontend truth refinement for:
  - `forum interaction-loop minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the minimum interaction surface under `exhibition/forum`
  - the bounded `profile` forum-asset surface for `我的评论 / 我的收藏`
  - the current frontend truth-consumption discipline
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve release
  - approve closure
  - approve a second interaction state machine

## Main Interaction Surface
- The current main interaction surface remains:
  - `exhibition/forum`
- The current minimum interaction UI loop under `exhibition/forum` may cover
  only:
  - post comment list
  - text-only comment submit
  - post like
  - post bookmark
- This surface must not move into:
  - `messages`
  - `profile`

## Comment-loop Frontend Boundary
- Comment list and comment submit remain:
  - part of the forum post-detail surface
  - part of the same discussion context
- Frontend must not present comment submit as:
  - a second discussion product
  - a private chat
  - a second draft lifecycle
- Current minimum comment-submit UI may include only:
  - text input
  - optional reply-to context
  - controlled Chinese success/failure prompts

## Like And Bookmark Consumption Discipline
- Like and bookmark remain:
  - forum interaction truth consumed from `BFF`
  - not frontend-owned fake local truth
- Frontend may use transient pending/loading UI only.
- But frontend must not:
  - invent final like truth locally
  - invent final bookmark truth locally
  - keep a second interaction state machine outside authoritative responses

## `Profile` Bounded Asset Surface
- `profile` may consume only:
  - `我的评论`
  - `我的收藏`
- Current minimum frontend meaning:
  - `我的评论` is an actor-scoped comment asset list
  - `我的收藏` is an actor-scoped saved-post list
- These surfaces must not become:
  - a second forum homepage
  - a public feed
  - a second discussion owner

## `Messages` Non-owner Rule
- `messages` remains outside the current minimum interaction loop.
- Frontend must not use `messages` as:
  - the primary place to read post comments
  - the primary place to submit comments
  - the primary place to like or bookmark posts

## Current Explicit Non-goals
- No comment image/file upload UI
- No comment moderation expansion UI
- No comment edit/delete UI
- No post edit/delete UI
- No report-center UI expansion
- No author follow or DM UI
- No second interaction state machine

## Formal Conclusion
- Current formal conclusion:
  - the minimum interaction loop stays under `exhibition/forum`
  - frontend consumes authoritative comment / like / bookmark results through
    `BFF`
  - `我的评论 / 我的收藏` remain bounded `profile` forum assets only
  - frontend must not create a second discussion tree, second forum homepage,
    or second interaction state machine

## Next Unique Action
- After backend and `BFF` truth land, dispatch frontend Agent third to wire the
  frozen comment, like, bookmark, my-comments, and my-bookmarks surfaces above.
