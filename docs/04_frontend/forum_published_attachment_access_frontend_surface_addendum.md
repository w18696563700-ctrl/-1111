---
owner: Codex 总控
status: draft
purpose: Freeze the Flutter-side surface boundary for forum published attachment access so post detail can preview images/videos and download files through shared file access without exposing objectKey or inventing a second attachment system.
layer: L3 Frontend
---

# Forum Published Attachment Access Frontend Surface Addendum

## Scope
- This addendum applies only to the current frontend truth refinement for:
  - `forum published attachment access minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - attachment access behavior on post detail
  - preview/download user actions
  - controlled Chinese error handling
  - explicit non-goals
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure

## Post-detail Attachment Consumption
- Post detail continues to display:
  - attachment list from `attachmentRefs`
- For access, frontend must:
  - call shared `GET /api/app/file/access`
  - use `fileAssetId` as the only anchor
- Frontend must not:
  - guess URLs
  - assemble OSS paths
  - expose `objectKey`

## Minimum User Actions
- Images:
  - preview in a bounded viewer
- Videos:
  - preview in a bounded player
- Files:
  - download as minimum
  - preview only if supported by client and access allows

## Error And Empty Handling
- If access fails, frontend must show:
  - controlled Simplified Chinese message
- Frontend must not:
  - show raw technical errors
  - fake preview success

## Explicit Non-goals
- No image insertion into body
- No rich-text editor
- No inline attachment anchors
- No second attachment system
- No upload-chain rewrite
- No forum-owned file truth

## Formal Conclusion
- Published attachment access is a post-detail surface that consumes shared
  file access only.
- Preview/download remains bounded to confirmed `FileAsset` ids.

## Next Unique Action
- After backend and BFF surfaces are ready, dispatch frontend Agent third to
  implement preview/download actions on post detail.
