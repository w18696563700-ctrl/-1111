---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side publish-surface boundary for forum file and PDF attachment support through the shared upload chain without mislabeling preview, OCR, malware scanning, or a second publish path as already approved.
layer: L3 Frontend
---

# Forum Rich Publish File Attachment Frontend Surface Addendum

## Scope
- This addendum applies only to the current frontend truth refinement for:
  - `forum rich publish file/pdf attachment minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - how file / PDF entry formally connects to the publish surface
  - the minimum upload-state UI boundary
  - the minimum draft-save handoff boundary
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve preview system
  - approve OCR
  - approve malware scanning
  - approve direct publish without draft

## Publish-surface Integration Rule
- File / PDF entry belongs to:
  - the forum publish surface
- But upload truth does not belong to:
  - forum
- The current frontend must therefore follow this order only:
  1. shared upload init
  2. direct upload
  3. shared upload confirm
  4. receive confirmed `FileAsset` ids
  5. send `attachmentFileAssetIds[]` through `draft/save`
  6. publish later from draft

## Minimum File-entry UI Boundary
- The minimum publish-page file / PDF UI may include only:
  - a bounded file / PDF picker entry
  - file name
  - bounded file-type label
  - upload progress
  - confirm-in-progress state
  - confirmed state
  - bound-to-draft state
  - failed state
  - remove-file action before publish
- This surface must not imply:
  - preview is already available
  - OCR is already available
  - malware scanning is already available
  - direct publish bypassing draft
  - forum-owned upload truth

## File-type Presentation Rule
- The user-visible minimum attachment identity must stay bounded to:
  - file name
  - bounded file-type label
- The file-type label may be derived from the frozen MIME family as controlled
  Chinese presentation such as:
  - `PDF`
  - `文本`
  - `Word`
  - `Excel`
  - `PPT`
- Frontend must not expose:
  - raw `objectKey`
  - raw storage path
  - raw upload session id
  - raw technical MIME strings as the primary user-facing label

## Upload-state Consumption Discipline
- Frontend must reuse the existing upload-state family from
  [ui_state_contract.md](/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/ui_state_contract.md):
  - `uploading`
  - `upload_confirming`
  - `upload_failed_retryable`
  - `upload_confirm_failed`
  - `upload_bound`
- The current user-visible meanings are frozen as:
  - `上传中` = current file is in `uploading` or `upload_confirming`
  - `已确认` = shared upload confirm succeeded and the current item now has a
    confirmed `FileAsset` id
  - `已承接` = the confirmed `FileAsset` has been accepted into the current
    forum draft surface and maps to the bound state
  - `失败` = current item is in retryable upload or confirm failure
  - `移除` = a local authoring action that removes the current file from the
    draft-side surface and is not a second upload-domain state machine
- Frontend must not consume:
  - raw `objectKey` as business identifier
  - unfinished upload as if already successful
  - fake bound-attachment success before confirm

## Current MIME / Size Validation Surface
- Frontend may perform controlled local validation against the frozen minimum
  policy:
  - supported MIME family only
  - single-file `20 MiB` ceiling only
- This current package does not require:
  - a new forum-only error-code family for local validation
- The current frontend output should remain:
  - controlled Simplified Chinese prompts
  - not raw technical upload diagnostics

## Current Explicit Non-goals
- No document preview UI
- No OCR UI
- No malware-scan UI
- No rich file editing workflow
- No second upload family
- No second publish path
- No automatic location field
- No AI review gate

## Formal Conclusion
- Current formal conclusion:
  - forum publish surface may later accept PDF / bounded document-file entry
    through the shared upload chain only
  - frontend must wait for confirmed `FileAsset` ids before draft-save binding
  - frontend may show only the bounded user-visible file identity and upload
    states frozen above
  - `objectKey` must never be used as forum business truth
  - preview / OCR / malware scanning / second publish path remain outside the
    approved package

## Next Unique Action
- After backend and `BFF` surfaces are ready, dispatch frontend Agent third to
  implement the frozen file-entry, upload-state, and draft-save handoff
  surface above.
