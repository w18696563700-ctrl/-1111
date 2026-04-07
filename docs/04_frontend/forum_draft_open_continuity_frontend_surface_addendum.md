---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side surface boundary for forum draft-open continuity so the publish page restores authoritative draft content rather than relying on local cache or a draftId-only handoff.
layer: L3 Frontend
---

# Forum Draft-open Continuity Frontend Surface Addendum

## Scope
- This addendum applies only to the current frontend truth refinement for:
  - `forum draft-open continuity`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the frontend behavior when tapping a draft in draft list
  - how the publish page restores authoritative draft content
  - attachment restore surface
  - explicit non-goals
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure

## Draft-open User Flow
- When a user taps a draft in draft list:
  - frontend must call the formal draft-open path
  - frontend must not treat `draftId` alone as sufficient content restore
- Publish page must restore:
  - title
  - body
  - topic
  - attachments
  - edit-draft target markers when present

## Attachment Restore Surface
- The publish page must restore attachments as:
  - confirmed file assets bound to the draft
- The publish page must not:
  - show attachments as confirmed if the draft-open payload does not include
    them
  - invent attachment success locally
  - treat `objectKey` as business truth

## Unified Draft-open Behavior
- Normal drafts and edit re-entry drafts must use the same draft-open
  continuity.
- The frontend must not:
  - add a second draft-open flow for edit drafts

## Relationship to Existing Mainline
- Draft-open continuity remains part of:
  - `draft/save -> publish`
- Draft-open does not:
  - create a second publish path
  - change the publish AI gate boundary

## Explicit Non-goals
- No second draft system
- No profile-owned draft truth
- No local fake restore
- No rich media protocol changes
- No AI gate expansion
- No own-post continuity expansion

## Formal Conclusion
- Draft-open continuity must restore authoritative draft content through the
  formal draft-open read chain.
- Frontend must not treat `draftId` alone as completion of draft restore.

## Next Unique Action
- After backend and `BFF` surfaces are ready, dispatch frontend Agent third to
  wire draft-open restore into the publish page.
