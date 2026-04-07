---
owner: Codex 总控
status: draft
purpose: Freeze the Server-side truth boundary for forum file and PDF attachment support through the shared upload chain, including confirmed FileAsset acceptance, draft binding, and published post binding without treating objectKey as business truth.
layer: L3 Backend
---

# Forum Rich Publish File Attachment Truth Addendum

## Scope
- This addendum applies only to the current backend truth refinement for:
  - `forum rich publish file/pdf attachment minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the Server-side ownership split for file / PDF attachments
  - the current attachment acceptance policy
  - the relation between draft binding and final published binding
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - rewrite the forum domain baseline
  - approve preview, OCR, or malware scanning

## Server Ownership Stays Unchanged
- `Server` remains the only truth owner for:
  - forum draft truth
  - forum post truth
  - forum draft attachment binding truth
  - forum published post attachment binding truth
  - forum publish transition truth
- Shared upload truth owner still does not belong to forum.
- Shared file-asset truth remains upstream truth only.

## Shared File Truth vs Forum Attachment Truth
- Shared file-asset truth includes only:
  - upload init
  - direct upload
  - upload confirm
  - confirmed `FileAsset`
- Forum attachment truth includes only:
  - which confirmed `FileAsset` ids are attached to a forum draft
  - which confirmed `FileAsset` ids are materialized into the final
    `forum_post_attachments` binding
- Therefore:
  - `FileAsset` truth belongs to the shared file-asset system
  - forum attachment association truth belongs to the forum draft / post layer
  - `objectKey` remains outside forum business truth

## Current Attachment Acceptance Policy
- The current backend acceptance boundary for forum file / PDF attachments is:
  - confirmed `FileAsset` only
  - MIME type inside the bounded forum allow-list only
  - single-file size at or below `20 MiB` only
- Supported MIME family:
  - `application/pdf`
  - `text/plain`
  - `application/msword`
  - `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
  - `application/vnd.ms-excel`
  - `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
  - `application/vnd.ms-powerpoint`
  - `application/vnd.openxmlformats-officedocument.presentationml.presentation`
- This backend truth does not approve:
  - executables
  - archives
  - arbitrary binary payloads

## Draft-stage Binding Boundary
- Draft-stage file / PDF binding may consume only:
  - confirmed `FileAsset` ids
- Draft-stage binding must not consume:
  - raw `objectKey`
  - unfinished upload session state
  - inferred OSS object existence
- The current order remains frozen as:
  1. shared upload init
  2. direct upload
  3. shared upload confirm
  4. obtain confirmed `FileAsset` ids
  5. pass `attachmentFileAssetIds[]` into `forum_draft_save`
  6. later publish from draft

## Published-post Binding Boundary
- The final published attachment carrier remains:
  - `forum_post_attachments`
- Final binding must still point only to:
  - confirmed `FileAsset`
- This means:
  - draft-stage binding is the authoring-stage association
  - `forum_post_attachments` is the final materialized post association
- The two are related by publish handoff, but they remain distinct truth
  layers.

## Current Attachment-type Meaning
- File / PDF attachments in this package mean:
  - downloadable or referential forum attachments
  - not inline preview truth
  - not OCR truth
  - not malware-scan truth
- The current backend truth therefore does not approve:
  - preview rendering materialization
  - extracted text truth
  - security-verdict truth

## Current Error And Validation Boundary
- The current backend truth does require:
  - MIME allow-list validation
  - size-ceiling validation
- The current backend truth does not require:
  - a new forum-only file-attachment error-code namespace
- The current meaning is:
  - forum-specific acceptance policy is Server-owned truth
  - transport/upload confirmation errors remain in the existing shared-upload
    corridor
  - forum draft/publish invalidity remains in the existing forum invalidity
    corridor

## Current Explicit Non-goals
- No preview truth
- No OCR truth
- No malware-scan workflow
- No rich file editing
- No second upload family
- No second publish path
- No automatic location truth
- No AI review gate

## Formal Conclusion
- Current formal conclusion:
  - `Server` remains the only truth owner for forum file / PDF attachment
    association
  - forum consumes only confirmed `FileAsset`
  - supported forum file attachments are bounded by the current MIME allow-list
    plus `20 MiB` per-file ceiling
  - draft-stage binding and final `forum_post_attachments` binding are related
    but distinct truth layers
  - `objectKey` remains outside business truth
  - preview / OCR / malware scanning remain outside the current package

## Next Unique Action
- After this truth package is frozen, dispatch backend Agent first to land:
  - confirmed file / PDF `FileAsset` acceptance
  - draft binding semantics
  - publish-time final attachment materialization
