---
owner: Codex 总控
status: draft
purpose: Freeze the incremental dispatch boundary, execution order, and role split for the current forum implementation round without mislabeling the board as verified, released, or closed.
layer: L0 SSOT
---

# 论坛模块实现轮增量派工单

## 1. Scope
- This addendum freezes the current incremental dispatch boundary for the
  `论坛模块` implementation round only.
- It applies to:
  - frontend local execution
  - `BFF` cloud execution
  - backend cloud execution
  - later result verification handoff
- It does not by itself:
  - approve result verification
  - approve release
  - close the board

## 2. Round Unique Goal
- The only current round goal is:
  - align forum canonical paths
  - fill the currently identified route gaps
  - connect the real mainline chain truthfully
- This means:
  - no parallel product expansion
  - no fake completion wrapping
  - no detour into ranking, moderation, or ads/resource scope

## 3. Current Increment Priority Order
1. Read-chain basics first
2. Interaction loop second
3. Draft / publish support third
4. Me-assets / interaction inbox last

## 4. Priority Breakdown

### 4.1 Read-chain Basics First
- Current first priority covers:
  - `GET /api/app/forum/topic/metadata`
  - `GET /api/app/forum/post/comments`
  - scope-specific verification of `GET /api/app/forum/feed`
  - `topicId` filter verification on `GET /api/app/forum/feed`
- The purpose is:
  - make the browse chain truthful before deeper command closure is attempted

### 4.2 Interaction Loop Second
- Current second priority covers:
  - `POST /api/app/forum/post/comment`
  - `POST /api/app/forum/post/like`
  - `POST /api/app/forum/post/bookmark`
  - `POST /api/app/forum/topic/follow`
- The purpose is:
  - close the minimum post-detail interaction chain

### 4.3 Draft / Publish Support Third
- Current third priority covers:
  - `POST /api/app/forum/draft/save`
  - `POST /api/app/forum/draft/delete`
  - keep `GET /api/app/forum/draft/list`
  - keep `POST /api/app/forum/publish`
- The purpose is:
  - complete the draft lifecycle around the already visible publish handoff

### 4.4 Me-assets / Inbox Last
- Current fourth priority covers:
  - `GET /api/app/forum/me/posts`
  - `GET /api/app/forum/me/comments`
  - `GET /api/app/forum/me/bookmarks`
  - `GET /api/app/forum/me/follows`
  - `GET /api/app/forum/interaction/inbox`
- The purpose is:
  - complete the bounded `profile` and `messages` consume surfaces only after
    the main forum chain is stable

## 5. Current Explicit Non-goals
- No recommendation or ranking
- No moderation console
- No ads or resource slot
- No sixth building
- No new bottom tab
- No fake content fallback
- No reinterpretation of `404 / 501` as completed implementation
- No reinterpretation of current implementation round as verified or releasable

## 6. Execution-role Boundary
- Frontend executes locally only
- `BFF` executes in the cloud only
- backend executes in the cloud only
- Flutter App must not call `Server` directly
- `BFF` must not invent a second forum truth owner
- `messages` and `profile` must not be rebuilt into second forum mainlines

## 7. Truthful Runtime Handling Rule
- Current execution must report:
  - real `200`
  - real `401`
  - real `404`
  - real `409`
  - real `501`
- Current execution must not:
  - fabricate content
  - hide a missing route with mock completion
  - wrap unimplemented behavior as if the chain were already complete

## 8. Current Dispatch Baseline
- Current connected baseline is:
  - `8` connected paths
- Current unconnected baseline is:
  - `13` unconnected paths
- Current known `BFF` repair already landed:
  - `GET /api/app/forum/feed` `scope/topicId` passthrough drift is corrected
- Current server-side blocker remains governed by:
  - `docs/00_ssot/forum_server_implementation_blocker_addendum.md`

## 9. Exit Condition For This Dispatch Round
- This dispatch round may continue incrementally only when:
  - execution stays inside the canonical path family
  - blocker truth is not misreported
  - receipts continue to distinguish connected vs unconnected paths honestly
- This dispatch round is not yet allowed to claim:
  - result verification passed
  - integration release passed
  - board closure passed

## 10. Next Unique Action
- Continue with forum canonical-path gap filling in the frozen priority order
  above, while keeping frontend local and `BFF` / backend cloud-only.

