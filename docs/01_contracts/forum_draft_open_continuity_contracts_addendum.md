---
owner: Codex 总控
status: draft
purpose: Freeze the minimum app-facing contract for forum draft-open continuity, including the formal draft detail/open read chain and its relationship to draft list and draft/save -> publish.
layer: L2 Contracts
---

# Forum Draft-open Continuity Contracts Addendum

## Scope
- This addendum applies only to the current L2 contract refinement for:
  - `forum draft-open continuity`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the minimum app-facing draft-open path
  - the relation to `draft/list`, `draft/save`, and `publish`
  - the minimum error family for draft open
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure
  - create a second draft family

## Stage Gate Reminder
- Current allowed entry:
  - `draft-open continuity` L0/L2/L3 truth refinement
- Current forbidden entry:
  - implementation
  - integration release
  - closure
- Current veto:
  - no second draft system
  - no profile-owned draft truth
  - no local fake restore

## Canonical Path-family Rule
- Draft-open continuity remains inside:
  - `/api/app/forum/*`
- The current package does not approve:
  - a second forum path family
  - a profile-owned draft-truth family

## Minimum Path Set
- The minimum app-facing path set for this package is frozen as:
  - existing `GET /api/app/forum/draft/list`
  - new `GET /api/app/forum/draft/detail`
  - existing `POST /api/app/forum/draft/save`
  - existing `POST /api/app/forum/publish`
- Current path-family meaning:
  - `draft/list` remains a minimal card list
  - `draft/detail` (draft-open) is the authoritative content restore read
  - `draft/save -> publish` remains the only publish mainline

## Draft-open Contract Boundary
- `GET /api/app/forum/draft/detail` is the minimum formal draft-open read.
- Minimum request meaning:
  - `draftId`
- Minimum response payload must include:
  - `draftId`
  - `topicId`
  - `title`
  - `body`
  - `attachmentFileAssetIds[]`
  - `targetPostId` when the draft is an edit re-entry draft
  - `draftType`
  - `state`
  - `updatedAt`
- Current contract meaning:
  - `draft/list` cannot replace `draft/detail`
  - `draftId` alone is insufficient for restore

## Relationship to Own-post Edit Drafts
- The same `draft/detail` path must be used for:
  - normal drafts
  - own-post edit re-entry drafts
- No second edit-only draft open path is approved.

## Minimum Error Family
- The minimum error family for draft-open continuity is frozen as:
  - `FORUM_DRAFT_OPEN_INVALID`
  - `FORUM_DRAFT_OPEN_NOT_FOUND`
  - `FORUM_DRAFT_OPEN_PERMISSION_DENIED`
  - `FORUM_DRAFT_OPEN_UNAVAILABLE`
- Meaning:
  - invalid = malformed request or missing anchor
  - not found = no draft exists for the id
  - permission denied = current actor is not the draft owner
  - unavailable = draft state is not eligible for open

## Explicit Non-goals
- No second draft system
- No profile-owned draft truth
- No local fake restore
- No direct publish without draft
- No AI gate expansion
- No rich media protocol changes

## Formal Conclusion
- Current formal conclusion:
  - `GET /api/app/forum/draft/detail` is the minimum draft-open read path
  - `draft/list` stays as minimal list only
  - the draft-open payload must restore title/body/topic/attachments
  - the same path must open both normal drafts and edit re-entry drafts

## Next Unique Action
- After L2/L3 are frozen, dispatch backend Agent first to land draft-open
  truth behind `draft/detail`.
