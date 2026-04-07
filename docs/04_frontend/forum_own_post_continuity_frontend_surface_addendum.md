---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side surface boundary for forum own-post continuity, including edit and delete entry points for my own published posts, while preserving the split between forum public surfaces and profile private management surfaces.
layer: L3 Frontend
---

# Forum Own-post Continuity Frontend Surface Addendum

## Scope
- This addendum applies only to the current frontend truth refinement for:
  - `forum own-post continuity`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - how the public forum surface and `我的楼` private surface jointly consume
    own-post continuity
  - where edit/delete entry points may appear
  - the minimum controlled Chinese user-visible result family
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve release
  - approve closure
  - approve a second post-management back office

## Public Surface vs My-building Surface
- Public forum surface means:
  - forum feed
  - post detail
  - public author profile
- `我的楼` means:
  - my private or semi-private asset and management center
- The frozen relationship is:
  - public post truth remains in forum
  - private continuity management entry remains in `profile / 我的楼`
- Frontend must not merge them into:
  - one page
  - one truth surface
  - one second forum homepage

## Edit/Delete Entry Placement Rule
- The preferred private management entry remains:
  - `profile / 我的帖子`
- The current public-context convenience entry may also appear in:
  - post detail only when the current actor is the owner
- The minimum placement rule is therefore:
  - `我的楼` is the default continuity hub
  - post detail may expose bounded owner-only quick actions
- Current package does not require:
  - owner actions on public author profile
  - bulk back-office post management

## Edit-entry Frontend Meaning
- Frontend edit entry means only:
  - hand off into a `Server`-owned draft corridor
  - then continue through the existing publish surface
- Frontend must not present edit as:
  - direct in-place post mutation without `Server` confirmation
  - a second edit-only state machine
  - a direct publish bypassing draft

## Delete-entry Frontend Meaning
- Frontend delete entry means only:
  - request a `Server`-controlled continuity action
  - then consume the authoritative result
- Frontend must not present delete as:
  - local fake hide only
  - local fake success before `Server` confirmation
  - hard delete by assumption

## User-visible Result Family
- The current minimum user-visible result family may be frozen only as:
  - entered edit draft successfully
  - current post cannot enter edit right now
  - no permission to edit or delete this post
  - delete succeeded and the post is no longer publicly active
  - current post cannot be deleted right now
- Current result output must remain:
  - controlled Simplified Chinese
  - not raw technical state names
  - not raw governance internals

## Continuity With Existing Packages
- Frontend own-post continuity must stay compatible with:
  - existing `draft/save -> publish`
  - existing author profile package
  - existing rich media and file attachment packages
  - existing interaction loop
  - existing publish AI gate
  - existing governance/report package
- This package does not reopen:
  - comment edit/delete
  - comment attachment
  - avatar edit
  - author follow or DM
  - location
  - AI gate expansion

## Current Explicit Non-goals
- No local fake delete
- No local fake edit success
- No second post-management back office
- No comment edit/delete UI
- No author follow or DM UI
- No avatar edit UI
- No moderation-console UI
- No report-history UI
- No second forum homepage

## Formal Conclusion
- Current formal conclusion:
  - own-post continuity is consumed jointly as forum public truth plus
    `我的楼` private management entry
  - `我的楼 / 我的帖子` is the default private continuity hub
  - post detail may expose bounded owner-only quick actions
  - frontend must wait for authoritative `BFF` / `Server` results for edit and
    delete continuity
  - frontend must not create local fake delete, local fake edit success, or a
    second management state machine

## Next Unique Action
- After backend and `BFF` truth land, dispatch frontend Agent third to wire the
  bounded continuity entry points and controlled Chinese result surface above.
