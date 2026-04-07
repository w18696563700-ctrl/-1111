---
owner: Codex 总控
status: draft
purpose: Freeze the current boundary for future forum rich-publish media support by reusing the shared upload chain and forum draft attachment references, without mislabeling the capability as already approved or implemented.
layer: L0 SSOT
---

# 论坛富发布附件与媒体边界冻结单

## 1. Scope
- This addendum applies only to the current `论坛模块`.
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- This addendum freezes only:
  - the current scan conclusion for forum media attachment support
  - the reuse boundary of the shared upload chain
  - the current relation between forum draft save and confirmed file truth
  - the explicit non-goals and re-entry conditions
- It does not by itself:
  - approve rich-publish implementation completion
  - approve image or video upload as already available
  - approve location truth
  - approve AI review gate

## 2. Current Scan Conclusion
- The current forum publish mainline is already frozen as:
  - `draft/save -> publish`
- The current app-facing draft-save request already reserves:
  - `attachmentFileAssetIds[]`
- The current platform already has a frozen shared upload chain:
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- The current forum domain truth already has:
  - `FileAsset` as file truth carrier
  - `forum_post_attachments` as post-attachment binding table
- But the current visible-layer governance also explicitly states:
  - draft-stage image / video direct upload and formal draft binding are still
    not yet approved

## 3. Current Boundary Meaning
- Future forum rich publish may reopen only by reusing:
  - the shared upload chain above
  - confirmed `FileAsset` truth references
  - the existing `attachmentFileAssetIds[]` handoff field
- Future forum rich publish must not:
  - create a second forum-only upload path family
  - create a second file truth owner
  - bypass upload confirm
  - treat `objectKey` as business truth
  - invent direct OSS completion outside the frozen upload corridor

## 4. Draft-stage Attachment Boundary
- The future rich-publish minimum may later include:
  - selecting image or video files
  - calling the shared upload init path
  - direct uploading to OSS
  - confirming upload into `FileAsset`
  - passing confirmed `FileAsset` ids into `draft/save`
- But the current round still does not approve claiming that:
  - draft attachment upload is already complete
  - image and video upload are already available to ordinary users
  - forum draft-binding semantics are already fully reopened

## 5. Publish-page Surface Meaning
- Current publish-page visual slots for image or video may exist only as:
  - hidden
  - disabled
  - controlled Simplified Chinese prompted entries
- They must not appear as:
  - fake upload success
  - fake bound attachments
  - fake publish-ready media support

## 6. Explicitly Outside This Freeze
- Automatic post location truth
- AI review as publish gate
- Direct post publish without draft
- A second upload family under `/api/app/forum/*`
- Rewriting avatar upload as a forum-owned flow

## 7. Required Re-entry Path
- Before implementation may begin, the following formal truth must be added in
  order:
  1. app-facing contract freeze for forum media upload reuse and draft binding
  2. backend truth freeze for draft attachment binding semantics
  3. BFF truth freeze for upload-signing reuse and handoff shaping
  4. frontend truth freeze for publish-page upload-state consumption
- Until then, the current capability remains:
  - scanned
  - structurally reusable
  - not yet approved for implementation

## 8. Formal Conclusion
- Current formal conclusion:
  - forum rich publish is not a greenfield upload capability
  - it must reuse the existing upload init -> direct upload -> confirm chain
  - confirmed `FileAsset` ids remain the only allowed attachment truth handoff
  - draft-stage media binding still needs a separate formal re-entry freeze
  - location truth and AI review gate remain outside the current approval
- Current freeze type:
  - forum rich-publish attachment and media boundary freeze only

## 9. Next Unique Action
- Freeze the L2/L3 truth package for:
  - forum draft attachment binding by confirmed `FileAsset` ids
  - shared-upload-chain reuse in the forum publish surface
