---
owner: Codex 总控
status: draft
purpose: Freeze the Server-side truth boundary for forum rich-publish media reuse, draft attachment binding, and published attachment binding without transferring shared upload ownership into forum.
layer: L3 Backend
---

# Forum Rich Publish Media Truth Addendum

## Scope
- This addendum applies only to the current backend truth refinement for:
  - `论坛富发布媒体上传复用共享上传链`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the Server-side truth ownership split
  - the boundary between shared file truth and forum attachment linkage truth
  - the relation between draft-stage attachment binding and final
    post-attachment binding
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - rewrite the forum domain baseline
  - approve direct publish without draft

## Server Ownership Stays Unchanged
- `Server` remains the only truth owner for:
  - forum draft truth
  - forum post truth
  - forum draft-to-publish transition truth
  - forum draft attachment binding truth
  - forum published post attachment binding truth
- Shared upload truth owner does not belong to forum.
- Shared upload truth remains outside forum domain ownership and is reused only
  as upstream file truth.

## Shared File Truth vs Forum Attachment Truth
- Shared file-asset truth includes only:
  - upload init
  - direct upload
  - upload confirm
  - confirmed `FileAsset`
- Forum attachment linkage truth includes only:
  - which confirmed `FileAsset` ids are attached to a forum draft
  - which confirmed `FileAsset` ids are finally bound to a materialized
    `ForumPost`
- Therefore:
  - `FileAsset` truth belongs to the shared file-asset system
  - forum attachment association truth belongs to forum draft / post linkage
    only

## Draft-stage Binding Boundary
- Draft-stage media binding may consume only:
  - confirmed `FileAsset` ids
- Draft-stage media binding must not consume:
  - raw `objectKey`
  - unfinished upload session state
  - inferred OSS object existence
- The current order stays frozen as:
  1. shared upload init
  2. direct upload
  3. shared upload confirm
  4. obtain confirmed `FileAsset` ids
  5. pass `attachmentFileAssetIds[]` into `forum_draft_save`
  6. later publish from draft

## Published-post Attachment Boundary
- The published post attachment binding remains the existing forum truth
  carrier:
  - `forum_post_attachments`
- Final published binding must still point only to:
  - confirmed `FileAsset`
- This means:
  - draft-stage binding is the authoring-stage association
  - `forum_post_attachments` is the final materialized post association
- The two are related by publish handoff, but they are not the same truth row.

## Current Explicit Non-goals
- No forum-owned upload storage truth
- No `objectKey` business truth
- No forum-owned avatar upload truth
- No media editing workflow
- No video transcoding workflow expansion
- No automatic cover-selection strategy
- No automatic post-location truth
- No AI review gate
- No direct publish without draft

## Current Truth Meaning
- This addendum is:
  - L3 backend truth for forum rich-publish media reuse only
- It is not:
  - implementation completion
  - forum-owned upload-truth approval
  - automatic location approval
  - AI review gate approval

## Formal Conclusion
- Current formal conclusion:
  - `Server` remains the only truth owner for forum draft/post attachment
    association
  - shared upload truth owner remains outside forum
  - forum consumes only confirmed `FileAsset`
  - `objectKey` remains outside business truth
  - draft-stage binding and final `forum_post_attachments` binding are related
    but distinct truth layers

## Next Unique Action
- After this truth package is frozen, dispatch backend Agent first to land:
  - confirmed `FileAsset`-to-draft binding semantics
  - publish-time draft-to-post attachment materialization
  - no new upload family
