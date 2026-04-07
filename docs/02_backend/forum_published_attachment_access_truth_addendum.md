---
owner: Codex 总控
status: draft
purpose: Freeze the Server-side truth boundary for forum published attachment access, including access authorization, shared FileAsset ownership, and reuse for future project showcase without creating a second file truth system.
layer: L3 Backend
---

# Forum Published Attachment Access Truth Addendum

## Scope
- This addendum applies only to the current backend truth refinement for:
  - `forum published attachment access minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - Server ownership for attachment access truth
  - the boundary between forum attachment refs and shared FileAsset truth
  - minimum access authorization semantics
  - preview/download control boundary
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure

## Server Ownership Stays Unchanged
- `Server` remains the only truth owner for:
  - forum post visibility truth
  - attachment access authorization truth
  - publish-eligibility truth
- Shared file truth remains owned by:
  - `FileAsset` system
- Forum must not become:
  - file truth owner
  - upload truth owner

## Attachment Access Truth Boundary
- Forum attachment access is valid only when:
  - the `FileAsset` is bound to a published forum post
  - the post is visible to the current actor under forum visibility rules
- Access authorization must be decided by:
  - `Server`
- `BFF` and frontend must not:
  - self-authorize
  - guess access by storage location

## Minimum Access Semantics
- The minimum access behaviors are:
  - image preview
  - video preview
  - file download (and bounded preview if supported by client)
- Access must be issued as:
  - a time-bounded `accessUrl`
  - not an exposed `objectKey`

## Relationship to ForumAttachmentRef
- `ForumAttachmentRef` remains the minimal read model:
  - `fileAssetId`
  - `fileName`
  - `mimeType`
- Access uses `fileAssetId` as the only anchor.
- No inline binary payload is required in `post/detail`.

## Relationship to Shared File Truth
- Shared file-asset truth includes:
  - upload init
  - direct upload
  - upload confirm
  - confirmed `FileAsset`
- Forum owns only:
  - attachment binding to published posts
  - access authorization based on post visibility

## Future Project Showcase Reuse Boundary
- Access path must remain:
  - shared and reusable
- Forum must not hardcode:
  - forum-only attachment access protocols
- This preserves future `项目展示` reuse without being locked to forum-only
  access.

## Explicit Non-goals
- No rich-text editor
- No inline attachment anchors
- No second attachment system
- No upload-chain rewrite
- No forum-owned file truth
- No moderation console or report history expansion

## Formal Conclusion
- `Server` is the only owner for attachment access authorization.
- Shared `FileAsset` remains the only file truth carrier.
- Published attachments are accessed through shared file access paths using
  `fileAssetId` only.

## Next Unique Action
- After this truth package is frozen, dispatch backend Agent first to land:
  - access authorization
  - access URL materialization
  - bounded preview/download semantics
