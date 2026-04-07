---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side shaping boundary for forum file and PDF attachment support through the shared upload chain without creating a second upload state machine, a second publish path, or a forum-owned file truth layer.
layer: L3 BFF
---

# Forum Rich Publish File Attachment BFF Surface Addendum

## Scope
- This addendum applies only to the current BFF truth refinement for:
  - `forum rich publish file/pdf attachment minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the allowed BFF responsibilities for file / PDF upload reuse
  - the draft-save handoff shaping boundary
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve preview system
  - approve OCR
  - approve malware scanning

## BFF Responsibility Boundary
- For this package, `BFF` may do only:
  - upload signing handoff
  - upload confirm handoff shaping
  - forum `draft/save` app-facing shaping
  - error normalization
  - auth consolidation and visibility trimming as already frozen
- `BFF` must not own:
  - file-asset truth
  - forum attachment truth
  - preview truth
  - OCR truth
  - malware-scan truth
  - upload storage truth

## Shared Upload Reuse Rule
- `BFF` must reuse the existing shared upload app-facing surface only.
- `BFF` must not invent:
  - a second upload state machine
  - a forum-only OSS truth
  - forum-specific raw `objectKey` business semantics
  - a second upload path family under `/api/app/forum/*`

## Current Allowed Handoff
- `BFF` may hand off only:
  - the confirmed file-asset result from shared upload confirm
  - `attachmentFileAssetIds[]` into forum `draft/save`
- `BFF` may surface only the minimum file attachment display carriers needed by
  ordinary forum consumption:
  - `fileName`
  - `mimeType`
  - confirmed `fileAssetId`
- `BFF` must not treat a file as forum-bound when:
  - upload is not yet confirmed
  - only raw `objectKey` is available
  - only upload-session state is available

## Current MIME / Size Policy Consumption
- `BFF` may consume the frozen forum acceptance policy for shaping and prompt
  normalization:
  - bounded MIME allow-list
  - single-file `20 MiB` ceiling
- But `BFF` must not become:
  - the policy truth owner
  - a second validation-truth owner
- The final attachment acceptance truth still belongs to `Server` and the
  shared-upload corridor.

## Current Error-code Conclusion
- This package does not add:
  - a new forum-only error-code family
- `BFF` may normalize only:
  - existing shared-upload refusal
  - existing upload-confirm-required semantics
  - existing draft/publish invalidity semantics
  - controlled Chinese prompts for unsupported MIME or oversize input

## Current Explicit Non-goals
- No preview rendering semantics
- No OCR shaping
- No malware-scan shaping
- No second upload family
- No second publish path
- No AI review gate
- No automatic location
- No author-profile package reuse in this round

## Formal Conclusion
- Current formal conclusion:
  - `BFF` may only reuse shared upload handoff and shape confirmed file-asset
    results into forum `draft/save`
  - `BFF` may normalize supported file / PDF prompts under the frozen MIME and
    size boundary
  - `BFF` cannot create a second upload state machine
  - `BFF` cannot treat `objectKey` as forum business truth
  - preview / OCR / malware scanning remain outside this package

## Next Unique Action
- After backend truth lands, dispatch `BFF` Agent second to wire:
  - shared upload handoff reuse
  - confirmed file result shaping
  - `attachmentFileAssetIds[]` draft-save shaping
