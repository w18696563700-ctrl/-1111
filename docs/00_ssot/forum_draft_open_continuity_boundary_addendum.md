---
owner: Codex 总控
status: draft
purpose: Freeze the minimum boundary for forum draft-open continuity so a draft selected from draft list can be reopened with authoritative content via the existing draft/save -> publish mainline.
layer: L0 SSOT
---

# 论坛草稿打开 continuity 边界冻结单

## 1. Scope
- This addendum applies only to the current `论坛模块`.
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- This addendum freezes only:
  - draft-open continuity within the existing forum draft mainline
  - the minimum open boundary between `draft/list` and a formal draft detail
  - the minimum payload needed to restore a draft into the publish surface
  - the continuity tie to own-post edit drafts
- It does not by itself:
  - approve implementation
  - approve integration release
  - approve closure
  - create a second draft system

## 2. Boundary Position
- `draft-open continuity` belongs to the existing forum mainline:
  - `draft/save -> publish`
- It is not:
  - a second draft system
  - a profile-owned truth corridor
  - a local cache patch that pretends to be real draft recovery

## 3. Draft List vs Draft Open
- `draft/list` is bounded to minimal card summaries only.
- Restoring draft title/body/topic/attachments requires a formal draft-open
  read chain.
- Frontend must not treat `draftId` alone as a substitute for real draft
  content.

## 4. Minimum Draft-open Payload
- The minimum draft-open payload must include:
  - `draftId`
  - `topicId`
  - `title`
  - `body`
  - `attachmentFileAssetIds[]` (or an equivalent attachment ref list that
    resolves back to confirmed `FileAsset` ids)
  - `targetPostId` when the draft is an edit re-entry draft
  - `draftType`
  - `state`
  - `updatedAt`
- This package does not approve:
  - a second attachment truth owner
  - `objectKey` as business truth

## 5. Own-post Edit Draft Unification
- Own-post edit re-entry must reuse the same draft-open continuity.
- The draft-open corridor is shared by:
  - normal drafts
  - edit re-entry drafts
- No second open logic is approved for edit drafts.

## 6. Attachment Continuity Boundary
- Draft-open must restore any already bound attachments into the publish
  surface.
- Forum consumes only confirmed attachment truth.
- Draft-open must not:
  - fake an attachment as uploaded
  - drop a bound attachment without authoritative response

## 7. Governance Boundary
- Draft-open continuity does not:
  - change the publish AI gate
  - rewrite publish decision rules
  - introduce report or moderation semantics

## 8. Explicit Non-goals
- New publish mainline
- Own-post continuity expansion beyond this package
- Rich media upload protocol changes
- AI gate expansion
- Comment edit/delete
- Follow / DM / avatar edit
- Automatic location
- Moderation console or report history
- Second draft system
- Local fake restore

## 9. Formal Conclusion
- Draft-open continuity is a formal part of the existing forum
  `draft/save -> publish` mainline.
- `draft/list` cannot substitute for a formal draft-open read chain.
- A minimum draft-open payload must restore title/body/topic/attachments and
  edit-target anchors into the publish surface.
- Edit drafts and normal drafts must share one draft-open continuity.

## 10. Next Unique Action
- Freeze the matching L2/L3 truth package for:
  - draft-open contract
  - backend draft-open truth
  - BFF shaping
  - frontend draft-open surface
