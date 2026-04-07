---
owner: Codex 总控
status: draft
purpose: Freeze the minimum boundary for forum own-post continuity, including edit and delete of already-published posts, while keeping forum as the public truth owner and profile as the bounded private management entry only.
layer: L0 SSOT
---

# Forum Own-post Continuity Boundary Addendum

## 1. Scope
- This addendum applies only to the current `论坛模块`.
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- This addendum freezes only:
  - the minimum continuity boundary for the current actor's own published posts
  - the minimum action set of edit and delete
  - the boundary between forum public truth and `profile / 我的楼` private
    management entry
  - the relation to the existing `draft/save -> publish` mainline
- It does not by itself:
  - approve implementation
  - approve integration release
  - approve closure
  - approve a second forum homepage

## 2. Current Package Scope
- The current `forum own-post continuity` package covers only:
  - editing my own published forum post
  - deleting my own published forum post
  - the bounded continuity relation among:
    - `forum` public post truth
    - `profile / 我的楼` private management entry
    - post detail
    - public author profile
- This package does not automatically include:
  - comment edit or delete
  - author follow or DM
  - avatar edit
  - moderation console
  - report history center

## 3. Building Ownership Boundary
- Own-post continuity still belongs to:
  - forum public content truth
  - bounded private management consumption under `profile`
- The frozen split is:
  - `forum` owns post truth
  - `profile / 我的楼` owns the current actor's private management entry for
    that truth
- Therefore:
  - `profile` must not become a second forum truth owner
  - `forum` must not become a second private asset center
  - `messages` remains outside this capability package

## 4. Relationship To `我的楼`
- `我的楼` is the current actor's private continuity entry for:
  - `我的帖子`
  - later edit / delete entry points for those posts
- `我的楼` is not:
  - a second public forum home
  - a second public author page
  - the owner of post state, permission, or delete truth
- Current meaning:
  - `我的楼` consumes bounded forum truth
  - `forum` continues to own public post materialization

## 5. Edit Continuity Boundary
- The current minimum frozen direction is:
  - editing an already published post must re-enter the existing draft
    corridor
  - not directly mutate the published post from frontend or `BFF`
  - not create a second edit state machine
- The minimum continuity rule is:
  - the current actor selects edit on an owned published post
  - `Server` materializes or resumes a Server-owned edit draft anchored to the
    existing post
  - later editing continues through the existing `draft/save -> publish`
    corridor
- The current round therefore does not approve:
  - direct in-place published-post mutation by client-side action only
  - a second publish path
  - a second edit-only workflow outside the existing draft corridor

## 6. Published-post Re-edit Materialization Boundary
- The current minimum edit package may discuss only:
  - reuse of the existing draft corridor
  - a bounded edit-draft anchor to the existing post
  - replacement/update of the same published post after controlled republish
- The current minimum package does not approve:
  - full historical version timeline
  - visible version comparison UI
  - multi-branch edit workflow
- Current minimum truth direction:
  - edited publish replaces or updates the original post truth under controlled
    `Server` materialization
  - the round does not require a new public duplicate post to be created

## 7. Delete Continuity Boundary
- The current minimum delete direction is:
  - `Server` materialized state transition
  - not physical hard deletion by default
- The current preferred minimum semantic is:
  - archive-style or hidden-from-public materialization under `Server` control
  - not frontend-only local disappearance
- Therefore the current round does not approve:
  - hard delete as default meaning
  - local fake delete success
  - direct removal of governance carriers

## 8. Public-surface After Delete
- After a controlled delete transition:
  - the post must leave the public browse chain
  - the public feed must not continue to treat it as a visible active post
  - public author profile must not continue to treat it as a visible active
    public post
  - post detail may return controlled unavailable or controlled removed-state
    semantics in a later downstream layer
- The current minimum package does not require:
  - recycle bin UI
  - restore flow
  - public tombstone page

## 9. Governance And Attachment Boundary
- Own-post continuity must not break the already frozen boundaries for:
  - `draft/save -> publish`
  - rich media attachments
  - file / PDF attachments
  - text AI review gate inside publish
  - report / governance carriers
- This means:
  - edit re-entry may later consume the existing attachment truth packages only
  - delete does not imply physical file-truth deletion
  - delete does not erase governance truth such as reports, risk flags, or
    moderation cases

## 10. Explicitly Outside This Freeze
- Comment edit/delete
- Comment attachment
- Author follow
- DM
- Avatar edit
- Automatic location
- AI review gate expansion
- Moderation console
- Report history center
- Second forum homepage
- Direct publish without draft

## 11. Formal Conclusion
- Current formal conclusion:
  - own-post continuity belongs to forum public truth plus bounded private
    management consumption under `profile / 我的楼`
  - editing my own published post must reuse the existing draft corridor rather
    than creating a second edit state machine
  - deleting my own published post must use a `Server` materialized state
    transition and must not default to hard delete
  - `profile` remains a private management entry only and does not become a
    second forum truth owner
  - comment edit/delete, author follow, DM, avatar edit, AI gate expansion,
    location, and a second forum home remain outside this package

## 12. Next Unique Action
- Freeze the matching L2/L3 truth package for:
  - own-post continuity contracts
  - backend ownership and state-transition truth
  - `BFF` shaping surface
  - frontend continuity surface
