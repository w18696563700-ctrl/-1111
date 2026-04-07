---
owner: Codex 总控
status: draft
purpose: Freeze the minimum forum interaction-loop package boundary for comments, likes, bookmarks, my-comments, and my-bookmarks without creating a second discussion tree, a second interaction state machine, or a second forum home.
layer: L0 SSOT
---

# Forum Interaction-loop Minimum Package Boundary Addendum

## 1. Scope
- This addendum applies only to the current `论坛模块`.
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- This addendum freezes only:
  - the minimum comment submit and comment-list loop
  - the minimum post like loop
  - the minimum post bookmark loop
  - the bounded `我的评论` surface
  - the bounded `我的收藏` surface
- It does not by itself:
  - approve implementation
  - approve integration release
  - approve closure
  - approve a second forum interaction state machine

## 2. Current Package Scope
- The current minimum interaction-loop package covers only:
  - `GET /api/app/forum/post/comments`
  - `POST /api/app/forum/post/comment`
  - `POST /api/app/forum/post/like`
  - `POST /api/app/forum/post/bookmark`
  - `GET /api/app/forum/me/comments`
  - `GET /api/app/forum/me/bookmarks`
- The current package does not automatically include:
  - topic follow
  - interaction inbox expansion
  - own-post edit or delete
  - report-center expansion

## 3. Main-chain Ownership Rule
- The current interaction main chain remains inside:
  - `exhibition/forum`
- The following actions remain forum-mainline behavior:
  - viewing a post comment list
  - submitting a comment
  - liking a post
  - bookmarking a post
- Therefore the current package does not approve:
  - moving the discussion loop into `messages`
  - moving the discussion loop into `profile`
  - building a second interaction homepage outside `exhibition/forum`

## 4. Comment-loop Boundary
- Current comment submit must remain:
  - post-bound reply truth
  - optional parent-comment reply truth
  - part of the same forum discussion tree
- Current comment list must remain:
  - the visible comment/context loop under a forum post
  - not a moderation tree
  - not a messages-owned thread tree
- Current comment loop must not become:
  - a second draft lifecycle
  - a private message thread
  - a separate discussion family outside forum

## 5. Like And Bookmark Boundary
- Post like and post bookmark remain:
  - forum interaction truth
  - Server-owned write truth
  - app-facing actions consumed through `BFF`
- They must not be treated as:
  - frontend-only fake local truth
  - second preference truth outside forum
  - messages-owned interaction truth

## 6. `Profile` Bounded Asset Rule
- `我的评论` and `我的收藏` remain:
  - bounded forum assets under `profile`
  - actor-scoped read projections only
- They do not become:
  - a second forum homepage
  - a second public browse tree
  - `profile` truth ownership of forum interaction

## 7. `Messages` Non-owner Rule
- `messages` remains only the bounded interaction-inbox building.
- The current minimum interaction-loop package does not approve:
  - a messages-owned discussion tree
  - a messages-owned comment submit path
  - a messages-owned like or bookmark truth tree

## 8. Explicitly Outside This Freeze
- Comment image upload
- Comment file upload
- Comment moderation expansion
- Comment edit
- Comment delete
- Post edit
- Post delete
- Report center
- Author follow
- DM
- Automatic location
- AI review gate expansion
- Second interaction state machine

## 9. Formal Conclusion
- Current formal conclusion:
  - forum minimum interaction-loop scope is now formally bounded to comments,
    likes, bookmarks, my-comments, and my-bookmarks only
  - the interaction main chain remains under `exhibition/forum`
  - `messages` does not become a second discussion owner
  - `profile` consumes only bounded `我的评论 / 我的收藏` assets
  - comment submit remains inside the same forum discussion truth and does not
    create a second discussion tree
  - like and bookmark remain forum interaction truth rather than frontend local
    fake state

## 10. Next Unique Action
- Freeze the matching L2/L3 truth package for:
  - interaction-loop contracts
  - backend interaction ownership
  - `BFF` interaction shaping
  - frontend interaction consumption
