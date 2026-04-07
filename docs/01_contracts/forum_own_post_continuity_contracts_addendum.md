---
owner: Codex 总控
status: draft
purpose: Freeze the minimum app-facing contract package for forum own-post continuity, including edit and delete of already-published posts, while keeping the capability inside the existing forum path family and the existing draft/save -> publish corridor.
layer: L2 Contracts
---

# Forum Own-post Continuity Contracts Addendum

## Scope
- This addendum applies only to the current L2 contract refinement for:
  - `forum own-post continuity`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the minimum canonical path set for own-post continuity
  - the contract relationship among post detail, my posts, edit entry, delete
    entry, and the existing draft corridor
  - the minimum malformed / invalid-state / permission-denied family
- It does not by itself:
  - approve implementation
  - approve integration release
  - approve closure
  - create a second forum path family

## Stage Gate Reminder
- Current allowed entry:
  - `own-post continuity` L0/L2/L3 truth refinement
- Current forbidden entry:
  - implementation
  - integration release
  - closure
- Current veto:
  - do not mix in comment edit/delete
  - do not mix in avatar edit / follow / DM
  - do not mix in AI gate / location / direct publish

## Canonical Path-family Rule
- Current own-post continuity remains inside:
  - `/api/app/forum/*`
- The current package does not approve:
  - a second forum path family
  - a `profile`-owned post-truth family
  - a `messages`-owned continuity family
- `profile / 我的楼` remains:
  - a bounded consumer of forum paths
  - not a separate post-truth corridor

## Minimum Path Set
- The minimum app-facing path set for this package is frozen as:
  - existing `GET /api/app/forum/me/posts`
  - existing `GET /api/app/forum/post/detail`
  - new `POST /api/app/forum/post/edit`
  - new `POST /api/app/forum/post/delete`
  - existing `POST /api/app/forum/draft/save`
  - existing `POST /api/app/forum/publish`
- Current path-family meaning:
  - `me/posts` is the bounded private management entry
  - `post/detail` is the public content context
  - `post/edit` enters the edit continuity corridor
  - `post/delete` enters the delete continuity corridor
  - `draft/save -> publish` remains the only edit-commit mainline

## Edit-entry Contract Boundary
- `POST /api/app/forum/post/edit` is the minimum own-post edit-entry command.
- Its minimum request meaning is:
  - `postId` only
- Its minimum response meaning is:
  - a controlled handoff into an edit draft
  - `draftId`
  - `postId`
  - bounded draft state or bounded continuation status
- Current contract meaning:
  - it does not directly mutate the published post
  - it creates or resumes a `Server`-owned edit draft corridor
  - later content changes continue through existing `draft/save -> publish`

## Delete-entry Contract Boundary
- `POST /api/app/forum/post/delete` is the minimum own-post delete-entry
  command.
- Its minimum request meaning is:
  - `postId` only
- Its minimum response meaning is:
  - controlled delete acceptance
  - target `postId`
  - materialized removal/archive-style result
- Current contract meaning:
  - delete is not a local frontend hide
  - delete is not physical hard delete by default
  - delete is a `Server`-controlled materialized result

## `我的楼` Consumption Boundary
- `GET /api/app/forum/me/posts` remains:
  - the only current bounded my-posts management entry in `profile`
- Current contract meaning:
  - it may surface continuity entry points for edit/delete
  - it does not become a second public forum homepage
  - it does not become the truth owner of posts

## Existing Draft Corridor Continuity
- The current package freezes:
  - edited published posts must return into the existing `draft/save -> publish`
    corridor
- The current package does not approve:
  - direct publish without draft
  - a second edit-only publish path
  - a `profile`-local post-edit path family

## Minimum Error Family
- The minimum malformed / invalid-state / permission-denied family is frozen
  as:
  - `FORUM_POST_EDIT_INVALID`
  - `FORUM_POST_EDIT_INVALID_STATE`
  - `FORUM_POST_DELETE_INVALID`
  - `FORUM_POST_DELETE_INVALID_STATE`
  - `FORUM_POST_PERMISSION_DENIED`
- Current meaning:
  - malformed = request shape or required anchor is invalid
  - invalid state = current post state or governance boundary does not permit
    the action
  - permission denied = current actor is not the final allowed owner for the
    continuity action

## Current Explicit Non-goals
- No comment edit/delete contract
- No comment attachment contract
- No author follow or DM contract
- No avatar edit contract
- No moderation-console contract
- No report-history contract
- No automatic-location contract
- No AI-gate expansion contract
- No second forum path family

## Formal Conclusion
- Current formal conclusion:
  - own-post continuity stays under the existing `/api/app/forum/*` family
  - `GET /api/app/forum/me/posts` remains the bounded private management entry
  - `POST /api/app/forum/post/edit` and `POST /api/app/forum/post/delete` are
    the minimum new continuity commands
  - edited posts must re-enter the existing draft corridor rather than create a
    second publish corridor
  - malformed / invalid-state / permission-denied remain distinct minimum
    contract families

## Next Unique Action
- After the L2/L3 package is frozen, dispatch backend Agent first to land the
  Server-owned continuity corridor behind these minimum paths.
