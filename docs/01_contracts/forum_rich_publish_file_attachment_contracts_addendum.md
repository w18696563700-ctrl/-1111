---
owner: Codex 总控
status: draft
purpose: Freeze the minimum app-facing contract package for forum file and PDF attachment support through the shared upload chain without opening a second upload family, a second publish path, or a new forum-only error-code family.
layer: L2 Contracts
---

# Forum Rich Publish File Attachment Contracts Addendum

## Scope
- This addendum applies only to the current L2 contract refinement for:
  - `forum rich publish file/pdf attachment minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the shared-upload reuse rule for file / PDF attachments
  - the current attachment handoff semantics
  - the current allow-list and size-limit contract boundary
  - the current explicit non-goals
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure
  - approve a second publish path

## Stage Gate Reminder
- Current active board:
  - `论坛模块`
- Current allowed entry:
  - `L2 / L3 truth refinement`
- Current forbidden entry:
  - implementation
  - integration release
  - closure
- Current veto:
  - do not mix in author profile
  - do not mix in avatar edit
  - do not mix in automatic location
  - do not mix in AI review gate
  - do not rewrite `draft/save -> publish` into direct publish

## Canonical Upload And Publish Rule
- Forum file / PDF attachments must reuse the existing shared upload flow only:
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- Forum must not create:
  - a second upload protocol
  - a second upload path family under `/api/app/forum/*`
  - a forum-only upload confirm corridor
- The current publish mainline remains:
  - `draft/save -> publish`

## Minimum Attachment Handoff Rule
- The only current forum draft-save attachment handoff field remains:
  - `attachmentFileAssetIds[]`
- This field still means:
  - confirmed `FileAsset` ids only
  - no raw `objectKey`
  - no unconfirmed upload placeholder
  - no forum-only storage pointer
- Without confirmed `FileAsset` ids, a file or PDF attachment must not be
  treated as bound to the current draft.

## Current Supported MIME Allow-list
- The current minimum contract allow-list is frozen as:
  - `application/pdf`
  - `text/plain`
  - `application/msword`
  - `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
  - `application/vnd.ms-excel`
  - `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
  - `application/vnd.ms-powerpoint`
  - `application/vnd.openxmlformats-officedocument.presentationml.presentation`
- This allow-list is:
  - forum attachment acceptance truth
  - not a second upload protocol
- This current round does not approve:
  - executables
  - archives
  - unknown generic binaries

## Current Size-limit Rule
- The minimum single-file size ceiling is frozen as:
  - `20 MiB`
- This package does not freeze:
  - large-file transport
  - resumable multi-part upload logic
  - a separate forum-only large-file path

## Current Read-model Consumption Boundary
- The current file / PDF attachment read surface may continue to reuse the
  existing confirmed attachment skeleton:
  - `ForumAttachmentRef`
- The minimum user-facing contract meaning remains:
  - `fileAssetId`
  - `fileName`
  - `mimeType`
- This package does not require:
  - a second file-attachment read object family
  - raw `objectKey`
  - inline preview payload

## Current Error-code Conclusion
- The current minimum package does not add:
  - a new forum-only error-code family
- The truth boundary is:
  - unsupported MIME or oversize input may be controlled by frontend local
    validation and/or existing shared-upload refusal
  - unconfirmed upload remains governed by:
    - `FILE_UPLOAD_CONFIRM_REQUIRED`
  - malformed draft / publish handoff remains governed by existing forum
    invalidity semantics
- Therefore this package freezes:
  - no new dedicated forum file-attachment error code in this round

## Current Explicit Non-goals
- No second upload family
- No second publish path
- No preview contract
- No OCR contract
- No malware-scan contract
- No rich file editing contract
- No automatic location field
- No AI review field

## Formal Conclusion
- Current formal conclusion:
  - PDF / bounded document-like files are inside the current minimum forum
    attachment support scope
  - forum still reuses the shared upload chain only
  - forum still consumes only confirmed `FileAsset` ids
  - forum still hands off only through `attachmentFileAssetIds[]`
  - current truth does require a MIME allow-list and `20 MiB` per-file ceiling
  - current truth does not require a new forum-only error-code family
  - `objectKey` remains outside forum business truth

## Next Unique Action
- After this L2/L3 package is frozen, dispatch backend Agent first to land the
  accepted file / PDF attachment binding truth under the existing draft-save
  and publish mainline.
