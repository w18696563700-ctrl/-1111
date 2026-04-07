---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side publish-surface boundary for forum rich-publish media reuse through the shared upload chain without mislabeling media publish as already completed or approved beyond the current boundary.
layer: L3 Frontend
---

# Forum Rich Publish Media Frontend Surface Addendum

## Scope
- This addendum applies only to the current frontend truth refinement for:
  - `论坛富发布媒体上传复用共享上传链`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - how image and video entry points formally connect to the publish surface
  - the minimum upload-state UI boundary
  - the minimum draft-save handoff boundary
  - the current explicit non-goals
- It does not by itself:
  - approve implementation completion
  - approve direct publish without draft
  - approve automatic location
  - approve AI review gate

## Publish-surface Integration Rule
- Image and video entry points belong to:
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

## Minimum Media-entry UI Boundary
- The minimum publish-page media UI may include only:
  - image picker entry
  - video picker entry
  - upload progress
  - upload failed state
  - remove-media action before draft save
- This surface must not imply:
  - media already bound before confirm
  - direct publish bypassing draft
  - forum-owned upload truth

## Upload-state Consumption Discipline
- Frontend must consume:
  - shared upload three-step flow
  - confirmed `FileAsset` ids only
- Frontend must not consume:
  - raw `objectKey` as business identifier
  - unfinished upload as if already successful
  - fake bound-attachment success before confirm

## Current Explicit Non-goals
- No automatic location field
- No AI review gate
- No direct publish bypassing draft
- No avatar upload or avatar edit
- No author-profile package
- No media-editing workflow
- No moderation console semantics

## Frontend Consumption Meaning
- The media entry belongs to:
  - forum publish surface
- The upload truth belongs to:
  - shared upload truth only
- Forum consumes only:
  - confirmed `FileAsset`
- Therefore the current formal boundary is:
  - publish page owns media entry UI
  - upload truth stays outside forum

## Current Truth Meaning
- This addendum is:
  - L3 frontend truth for forum rich-publish media surface only
- It is not:
  - implementation completion
  - upload completion approval
  - automatic location approval
  - AI review approval

## Formal Conclusion
- Current formal conclusion:
  - forum publish surface may later accept image and video entry through the
    shared upload chain only
  - frontend must wait for confirmed `FileAsset` ids before draft-save binding
  - `objectKey` must never be used as forum business truth
  - automatic location, AI review gate, and direct publish remain outside the
    approved package

## Next Unique Action
- After backend and `BFF` surfaces are ready, dispatch frontend Agent third to
  implement the frozen media-entry, upload-state, and draft-save handoff
  surface above.
