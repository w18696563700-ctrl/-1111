---
owner: Codex 总控
status: draft
purpose: Freeze the minimum boundary for forum rich-publish file and PDF attachment support by reusing the shared upload chain and confirmed FileAsset handoff without mislabeling document preview, OCR, malware scanning, or a second upload family as already approved.
layer: L0 SSOT
---

# 论坛富发布文件与 PDF 附件边界冻结单

## 1. Scope
- This addendum applies only to the current `论坛模块`.
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- This addendum freezes only:
  - the minimum future support boundary for forum file / PDF attachments
  - the continued reuse of the shared upload three-step flow
  - the current user-visible attachment surface boundary
  - the current explicit non-goals
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure
  - approve document preview system
  - approve OCR
  - approve malware scanning
  - approve a second upload family

## 2. Current Formal Scope Conclusion
- `PDF / 文件附件` now belongs to the current minimum future formal support
  scope for forum rich publish.
- But the support scope is bounded to:
  - PDF
  - bounded document-like files
- It does not mean:
  - arbitrary binary files are approved
  - archives, executables, installers, or opaque packages are approved
  - preview, OCR, or document-analysis capability is approved

## 3. Shared Upload Reuse Rule
- The current forum file / PDF attachment capability must reuse the same shared
  upload chain already frozen for forum media:
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- Forum must still consume only:
  - confirmed `FileAsset`
- Forum must still hand off only through:
  - `attachmentFileAssetIds[]`
- Forum must still keep the publish mainline as:
  - `draft/save -> publish`
- Therefore the current round does not approve:
  - a second forum-only upload protocol
  - a second OSS path family
  - a second publish path

## 4. Truth Boundary
- `FileAsset` remains the formal file truth carrier.
- `objectKey` remains:
  - storage location only
  - not business truth
- The forum-side truth only concerns:
  - whether a confirmed `FileAsset` is attached to the current draft
  - whether the confirmed `FileAsset` is materialized into the final
    post-attachment binding at publish time

## 5. Current Supported File Family Boundary
- The current minimum formal support family is:
  - `application/pdf`
  - `text/plain`
  - `application/msword`
  - `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
  - `application/vnd.ms-excel`
  - `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
  - `application/vnd.ms-powerpoint`
  - `application/vnd.openxmlformats-officedocument.presentationml.presentation`
- This means:
  - PDF is first-class in the current minimum package
  - generic “文件” means bounded document-like file types only
- This current package does not approve:
  - archives
  - executables
  - APK / IPA / package files
  - arbitrary unknown MIME families

## 6. Current Minimum Size Governance
- The current minimum package does require:
  - a bounded MIME allow-list
  - a bounded per-file size ceiling
- The minimum per-file size ceiling is frozen as:
  - `20 MiB`
- This current round does not freeze:
  - large-file transfer capability
  - resumable large-attachment strategy
  - file-preview cache strategy

## 7. Current User-visible Attachment Shape
- The current minimum user-visible forum attachment shape may include only:
  - file name
  - bounded file-type label
  - upload-in-progress state
  - confirmed state
  - bound-to-draft state
  - failed state
  - remove action
- This current round does not approve:
  - embedded document preview
  - PDF reader subsystem
  - office-document renderer
  - download-center workflow

## 8. Current Error-code Conclusion
- The current minimum package does not require:
  - a new forum-only error-code family
- The current truth position is:
  - shared-upload validity and confirmation still stay inside the existing
    shared-upload corridor
  - forum draft / publish invalidity still stays inside existing forum
    invalid-state semantics
  - the frontend may use controlled local validation and Simplified Chinese
    prompts for unsupported MIME or oversize input

## 9. Explicitly Outside This Freeze
- Document preview system
- OCR
- Malware scanning
- Rich file editing
- Second upload family
- Second publish path
- Automatic location
- AI review gate

## 10. Formal Conclusion
- Current formal conclusion:
  - PDF / bounded document-like file attachments are now within the future
    minimum formal support scope for forum rich publish
  - the capability must reuse the shared upload three-step flow
  - the capability must consume only confirmed `FileAsset`
  - the capability must still hand off only through `attachmentFileAssetIds[]`
  - `objectKey` remains outside business truth
  - MIME allow-list and per-file size ceiling are required truth in this
    package
  - preview / OCR / malware scanning / second upload family remain outside the
    current package

## 11. Next Unique Action
- Freeze the L2/L3 truth package for:
  - file / PDF attachment contract semantics
  - backend attachment binding truth
  - BFF shaping surface
  - frontend upload-state and bound-file surface
