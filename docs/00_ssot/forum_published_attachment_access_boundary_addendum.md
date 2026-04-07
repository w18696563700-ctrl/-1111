---
owner: Codex 总控
status: draft
purpose: Freeze the minimum boundary for forum published attachment access (preview/download) while keeping file truth in shared FileAsset and forum as the post-truth owner.
layer: L0 SSOT
---

# 论坛已发布附件读取 / 预览 / 下载最小能力包边界冻结单

## 1. Scope
- This addendum applies only to the current `论坛模块`.
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- This addendum freezes only:
  - minimum published attachment access for preview / download
  - the boundary between forum post truth and shared FileAsset truth
  - the minimum app-facing access surface direction
  - explicit non-goals
- It does not by itself:
  - approve implementation
  - approve integration release
  - approve closure
  - approve a second attachment system

## 2. Truth Ownership Boundary
- Published post truth remains owned by:
  - `forum`
- File binary truth remains owned by:
  - shared `FileAsset`
- Forum must not become:
  - a file-truth owner
  - a second upload or file-access system
- Forum only owns:
  - the reference relation between published post and confirmed file truth

## 3. Why ForumAttachmentRef Is Not Enough
- Current `ForumAttachmentRef(fileAssetId/fileName/mimeType)` supports only:
  - minimal attachment list display
- It does not support:
  - preview
  - download
- A formal access surface is required.
- Frontend must not:
  - guess URLs
  - assemble `objectKey` or OSS endpoints
  - fake preview using inferred storage location

## 4. Minimum Access Boundary
- Minimum access scope after publish:
  - image preview
  - video preview
  - file download (and bounded preview if supported)
- All access must be based on:
  - confirmed `FileAsset` truth
- `objectKey` must remain:
  - storage location only
  - not app-facing business truth

## 5. Access Path-family Direction
- `forum post/detail` still returns only:
  - `attachmentRefs`
- Preview / download must reuse:
  - shared file access path family under `/api/app/file/*`
- Forum must not create:
  - a second file-access family under `/api/app/forum/*`
- This direction keeps the access surface reusable for future
  `项目展示`.

## 6. Explicit Non-goals
- Image insertion into body
- Rich-text editor
- Inline attachment anchors
- Second attachment system
- Upload chain rewrite
- AI gate expansion
- own-post continuity expansion
- comment edit/delete
- follow / DM / avatar edit
- moderation console / report history

## 7. Formal Conclusion
- Forum published attachment access is frozen as:
  - preview/download only
  - based on confirmed `FileAsset`
  - accessed through shared `/api/app/file/*` access surface
- Forum remains the post-truth owner only and does not become file-truth owner.

## 8. Next Unique Action
- Freeze the matching L2/L3 truth package for:
  - access contracts
  - backend access truth
  - BFF shaping
  - frontend access surface
