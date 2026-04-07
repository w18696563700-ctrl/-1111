---
owner: Codex 总控
status: draft
purpose: Freeze the minimum app-facing contract for forum published attachment access through shared file-access paths without opening a second attachment system.
layer: L2 Contracts
---

# Forum Published Attachment Access Contracts Addendum

## Scope
- This addendum applies only to the current L2 contract refinement for:
  - `forum published attachment access minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - the minimum app-facing access paths for preview / download
  - the relation to `post/detail` and `ForumAttachmentRef`
  - the minimum error family for access
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure
  - create a second attachment system

## Stage Gate Reminder
- Current allowed entry:
  - `published attachment access` L0/L2/L3 truth refinement
- Current forbidden entry:
  - implementation
  - integration release
  - closure
- Current veto:
  - no image insertion into body
  - no rich-text editor
  - no second attachment system
  - no forum-owned file truth

## Canonical Path-family Rule
- Published attachment access must reuse:
  - shared `/api/app/file/*` access path family
- Forum must not create:
  - a second file-access family under `/api/app/forum/*`
- `post/detail` remains:
  - the canonical forum read for attachmentRefs only

## Minimum Access Path
- The minimum app-facing access path is frozen as:
  - `GET /api/app/file/access`
- Minimum query parameters:
  - `fileAssetId` (required)
  - `mode` (required): `preview | download`
- Minimum response meaning:
  - `accessUrl`
  - `expiresAt`
  - `fileName`
  - `mimeType`
  - optional `contentLengthBytes`
- This path must not expose:
  - `objectKey` as business truth

## Relationship to ForumAttachmentRef
- `ForumAttachmentRef` remains:
  - `fileAssetId`
  - `fileName`
  - `mimeType`
- `fileAssetId` is the only allowed anchor into access.
- `post/detail` does not expand into:
  - inline preview payloads
  - embedded binary content

## Minimum Error Family
- The minimum error family for published attachment access is frozen as:
  - `FILE_ACCESS_INVALID`
  - `FILE_ACCESS_NOT_FOUND`
  - `FILE_ACCESS_PERMISSION_DENIED`
  - `FILE_ACCESS_UNAVAILABLE`
- Meaning:
  - invalid = malformed request or missing anchor
  - not found = file asset not found
  - permission denied = actor lacks access to the post attachment
  - unavailable = access temporarily blocked or expired

## Explicit Non-goals
- No rich-text editor
- No inline attachment anchors
- No second attachment system
- No upload-chain rewrite
- No forum-owned file truth
- No image insertion into body

## Formal Conclusion
- The minimum published attachment access contract is:
  - `GET /api/app/file/access` with `fileAssetId` and `mode`
  - `post/detail` remains attachmentRef-only
  - shared file access must be reused for future `项目展示`

## Next Unique Action
- After L2/L3 are frozen, dispatch backend Agent first to land access truth
  behind `file/access`.
