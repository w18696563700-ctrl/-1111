---
owner: Codex 总控
status: draft
purpose: Freeze the current boundary for a future public forum author-profile surface, its linkage from forum post detail, and its relationship to the existing `profile` building without mislabeling the capability as already contracted or implemented.
layer: L0 SSOT
---

# 论坛作者主页与我的楼联动边界冻结单

## 1. Scope
- This addendum applies only to the current `论坛模块`.
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- This addendum freezes only:
  - the current scan conclusion for author-profile capability
  - the ownership boundary between public forum author profile and the
    existing `profile` building
  - the approved linkage direction from forum post detail into a future public
    author profile
  - the current non-goals and re-entry conditions
- It does not by itself:
  - approve app-facing contracts
  - approve backend or BFF implementation
  - approve frontend implementation
  - approve result verification, release, or closure

## 2. Current Scan Conclusion
- The current forum implementation surface already includes:
  - forum feed
  - topic metadata
  - post detail
  - comment interaction
  - draft / publish handoff
  - forum me-assets under `profile`
- The current user-visible post detail already carries only a minimum
  `ForumAuthorSummary`:
  - `authorId`
  - `displayName`
  - optional `organizationName`
- The current formal truth does **not** yet freeze:
  - a public author-profile canonical path
  - a public author-profile read model
  - author-profile tabs and counts
  - author-follow truth
  - author-private edit settings
- Therefore the current state is:
  - clicking author avatar or author name is not merely a frontend omission
  - it is a not-yet-frozen public-surface capability that must first re-enter
    formal truth

## 3. Ownership Boundary
- Future public author profile belongs to:
  - the public forum browsing chain
  - inside the existing `exhibition/forum` family
- Future public author profile does **not** belong to:
  - the root `profile` building as a truth owner
  - `messages`
  - a new shell building
- The existing `profile` building remains:
  - the current actor's private / semi-private identity and forum-asset center
  - the place for:
    - my posts
    - my comments
    - my bookmarks
    - my follows
    - drafts
    - session / organization / certification entry
- Therefore the boundary is:
  - public author profile = public forum consumption surface
  - `profile` building = current-user-owned asset and identity surface

## 4. Current Approved Linkage Direction
- The future approved linkage direction is:
  - forum feed item -> post detail -> author avatar / author name ->
    public author profile
- The current `profile` linkage direction is:
  - `profile` -> my forum assets -> my posts / my comments / my bookmarks /
    my follows / drafts
- Future self-linkage may later allow:
  - current actor opening their own public forum author profile
  - then handing off into the existing `profile` forum asset center
- But the current round does not yet approve:
  - treating public author profile as a second private personal center
  - rebuilding `profile` into a public author homepage
  - moving forum public browse responsibility into `profile`

## 5. Current Future Surface Boundary
- When the capability is formally reopened later, the minimum public author
  profile may discuss only:
  - author avatar projection
  - author display name
  - optional public signature / intro projection
  - bounded public forum content lists owned by forum truth
  - bounded handoff back into forum post detail
- It must not automatically approve:
  - direct message entry
  - author-private profile editing
  - organization governance actions
  - a second forum browse tree outside `exhibition/forum`
  - a sixth shell building

## 6. Avatar Truth Boundary
- User avatar truth remains part of:
  - user / identity / profile truth
- Forum may later consume only:
  - avatar projection in public forum surfaces
- Forum must not become:
  - avatar truth owner
  - avatar upload owner
- Therefore any future author-profile implementation must respect:
  - avatar edit belongs to profile / identity truth
  - forum consumes avatar display only

## 7. Current Explicit Non-goals
- No author-follow truth by this addendum
- No public author-profile implementation by this addendum
- No new bottom tab
- No new shell building
- No message-owned author homepage
- No direct mix of public author profile and current-user private profile truth

## 8. Required Re-entry Path
- Before implementation may begin, the following formal truth must be added in
  order:
  1. app-facing contract freeze for public author profile
  2. backend truth freeze for author-profile read model and linkage ownership
  3. BFF truth freeze for app-facing aggregation and visibility trimming
  4. frontend truth freeze for route / page / linkage surface
- Until those freezes exist, the current capability remains:
  - scanned
  - acknowledged
  - not yet approved for implementation

## 9. Formal Conclusion
- Current formal conclusion:
  - the forum board does need a future public author-profile capability
  - that capability belongs to the public forum surface, not to `profile` as a
    truth owner
  - `profile` remains the current-user asset and identity building
  - avatar truth remains outside forum truth ownership
  - the capability must re-enter through L2/L3 truth before any execution
- Current freeze type:
  - forum author-profile and profile-linkage boundary freeze only

## 10. Next Unique Action
- Freeze the L2/L3 truth package for:
  - public author-profile route and read model
  - its linkage from forum post detail
  - its bounded relationship to the current `profile` building
