---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side shaping boundary for forum rich-publish media reuse through the shared upload chain without creating a second upload state machine or a forum-owned media truth layer.
layer: L3 BFF
---

# Forum Rich Publish Media BFF Surface Addendum

## Scope
- This addendum applies only to the current BFF truth refinement for:
  - `论坛富发布媒体上传复用共享上传链`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the allowed BFF responsibilities for upload reuse
  - the draft-save media handoff shaping boundary
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - transfer file truth ownership to BFF
  - approve AI review or automatic location

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
  - media review truth
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
- `BFF` must not treat media as forum-bound when:
  - upload is not yet confirmed
  - only raw `objectKey` is available
  - only upload-session state is available

## Current Explicit Non-goals
- No image or video automatic review gate
- No automatic location shaping
- No rich-publish instant-publish state machine
- No avatar upload truth
- No author-profile package reuse in this round
- No media editing semantics

## Current Truth Meaning
- This addendum is:
  - L3 BFF truth for forum rich-publish media reuse only
- It is not:
  - implementation completion
  - file-truth ownership approval
  - AI review approval
  - automatic location approval

## Formal Conclusion
- Current formal conclusion:
  - `BFF` may only reuse shared upload handoff and shape confirmed file-asset
    results into forum `draft/save`
  - `BFF` cannot create a second upload state machine
  - `BFF` cannot treat `objectKey` as forum business truth
  - AI review and automatic location remain outside this package

## Next Unique Action
- After backend truth lands, dispatch `BFF` Agent second to wire:
  - shared upload handoff reuse
  - confirmed result shaping
  - `attachmentFileAssetIds[]` draft-save shaping
