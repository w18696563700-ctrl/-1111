---
owner: Codex 总控
status: draft
purpose: Freeze the Server-side truth boundary for forum draft-open continuity, including the authoritative draft detail read, unified open semantics for normal and edit drafts, attachment restoration, and continuity with draft/save -> publish.
layer: L3 Backend
---

# Forum Draft-open Continuity Truth Addendum

## Scope
- This addendum applies only to the current backend truth refinement for:
  - `forum draft-open continuity`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - `Server` ownership for draft-open truth
  - the minimum draft detail/open truth carrier
  - unified open semantics for normal and edit drafts
  - attachment restore boundary
  - continuity with `draft/save -> publish`
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure

## Server Ownership Stays Unchanged
- `Server` remains the only truth owner for:
  - forum draft truth
  - draft-open permission truth
  - draft-open materialization truth
  - publish eligibility truth
- `BFF` and frontend are non-owners of draft-open truth.

## Draft-open Truth Carrier
- The minimum truth carrier for draft-open is:
  - forum draft read model keyed by `draftId`
- The draft-open payload must materialize:
  - `draftId`
  - `topicId`
  - `title`
  - `body`
  - `attachmentFileAssetIds[]`
  - `targetPostId` when the draft is an edit re-entry draft
  - `draftType`
  - `state`
  - `updatedAt`

## Unified Open Semantics
- The same draft-open truth corridor must serve:
  - normal drafts
  - own-post edit re-entry drafts
- Edit drafts are anchored by:
  - `forum_drafts.target_post_id`
- No second draft-open path is approved for edit drafts.

## Attachment Restore Boundary
- Draft-open must restore only:
  - confirmed `FileAsset` ids bound to the draft
- Draft-open must not:
  - invent attachment confirmations
  - accept raw `objectKey` as business truth
  - drop bound attachments without authoritative response

## Relationship to Publish Mainline
- Draft-open continuity is part of the existing mainline:
  - `draft/save -> publish`
- Draft-open does not rewrite:
  - draft ownership
  - publish truth ownership
  - publish gate semantics

## Relationship to Own-post Continuity
- Own-post edit re-entry drafts must be opened through the same draft-open
  truth corridor.
- There is no separate edit-open truth path.

## Governance Boundary
- Draft-open continuity does not change:
  - AI gate decision rules
  - report/governance carriers
  - moderation flows

## Explicit Non-goals
- No second draft system
- No profile-owned draft truth
- No local fake restore
- No new publish path
- No AI gate expansion
- No rich media protocol changes

## Formal Conclusion
- `Server` is the only truth owner for draft-open continuity.
- `draft/detail` must be served by the authoritative draft read model.
- Normal drafts and edit drafts share one open corridor.
- Attachment restoration is limited to confirmed `FileAsset` ids bound to the
  draft.

## Next Unique Action
- After this truth package is frozen, dispatch backend Agent first to land
  the `draft/detail` read model and enforce unified open semantics.
