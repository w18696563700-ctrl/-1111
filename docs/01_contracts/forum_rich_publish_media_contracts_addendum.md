---
owner: Codex 总控
status: draft
purpose: Freeze the minimum app-facing contract package for forum rich-publish media reuse through the shared three-step upload chain without opening a second upload family or mislabeling media publish as already implemented.
layer: L2 Contracts
---

# Forum Rich Publish Media Contracts Addendum

## Scope
- This addendum applies only to the current L2 contract refinement for:
  - `论坛富发布媒体上传复用共享上传链`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the shared-upload reuse rule
  - the draft-save attachment handoff rule
  - the minimum app-facing media semantics
  - the current non-approved meanings
- It does not by itself:
  - approve implementation
  - approve release
  - approve direct publish without draft
  - create a second upload path family

## Stage Gate Reminder
- Current stage gate conclusion for this package is:
  - current active board: `论坛模块`
  - current stage: `implementation governance + increment dispatch`
  - current allowed entry: `L2 / L3 truth refinement`
  - current forbidden entry:
    - implementation
    - integration release
    - closure
  - current veto:
    - do not mix in author profile
    - do not mix in avatar edit
    - do not mix in automatic location truth
    - do not mix in AI review gate
    - do not rewrite `draft/save -> publish` into direct publish

## Shared Upload Reuse Rule
- Forum rich-publish media must reuse the existing shared upload three-step
  flow only:
  - `POST /api/app/file/upload/init`
  - direct upload
  - `POST /api/app/file/upload/confirm`
- Forum must not create:
  - a second upload protocol
  - a second OSS path family
  - a forum-only media init truth owner
  - a forum-only media confirm truth owner
- The current forum publish mainline remains:
  - `draft/save -> publish`

## Minimum Attachment Handoff Rule
- The only current draft-save attachment handoff field is:
  - `attachmentFileAssetIds[]`
- This field means:
  - confirmed `FileAsset` ids only
  - no raw storage location
  - no unfinished upload placeholder
- Without confirmed `FileAsset` ids, media must not be treated as bound to the
  forum draft.

## File Truth Boundary
- Images and videos in this package both belong to:
  - the shared `FileAsset` family
- `objectKey` remains:
  - storage location only
  - not business truth
- Therefore current contract truth does not approve:
  - forum-exclusive `objectKey` direct-upload semantics
  - using `objectKey` in place of `FileAsset` ids
  - unconfirmed upload results as forum business truth

## Minimum App-facing Consumption Boundary
- The current minimum app-facing discussion is limited to:
  - reuse the existing shared upload paths
  - consume confirmed upload results only
  - pass confirmed `attachmentFileAssetIds[]` into `draft/save`
- This package does not introduce:
  - forum-only upload endpoints
  - forum-only upload session ids
  - direct post publish with media but without draft

## Current Explicit Non-goals
- No automatic location fields
- No AI review fields
- No direct post publish with media but without draft
- No avatar upload or avatar edit
- No author-profile capability
- No media-editing workflow
- No transcoding workflow expansion
- No automatic cover-selection workflow

## Current Contract Meaning
- This addendum is:
  - L2 contract truth for forum rich-publish media reuse only
- It is not:
  - implementation approval
  - upload completion approval
  - automatic location approval
  - AI review gate approval

## Formal Conclusion
- Current formal conclusion:
  - forum rich-publish media must reuse the shared upload chain
  - forum must consume only confirmed `FileAsset` ids
  - `attachmentFileAssetIds[]` is the only current draft-save media handoff
  - `objectKey` remains outside forum business truth
  - direct publish without draft remains unapproved

## Next Unique Action
- After this L2/L3 package is frozen, the natural execution order is:
  1. backend Agent
  2. `BFF` Agent
  3. frontend Agent
