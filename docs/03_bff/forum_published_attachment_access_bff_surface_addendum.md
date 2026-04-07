---
owner: Codex 总控
status: draft
purpose: Freeze the BFF-side shaping boundary for forum published attachment access, ensuring BFF only shapes shared file-access results without owning file truth or inventing a second attachment system.
layer: L3 BFF
---

# Forum Published Attachment Access BFF Surface Addendum

## Scope
- This addendum applies only to the current BFF truth refinement for:
  - `forum published attachment access minimum package`
- Current board:
  - `论坛模块`
- Current stage:
  - `implementation governance + increment dispatch`
- It freezes only:
  - BFF shaping for shared file access
  - the relation to forum post detail attachmentRefs
  - explicit non-goals
- It does not by itself:
  - approve implementation
  - approve release
  - approve closure

## BFF Responsibility Boundary
- `BFF` may do only:
  - app-facing shaping for `GET /api/app/file/access`
  - auth consolidation
  - Chinese controlled error normalization
  - visibility trimming
- `BFF` must not own:
  - file truth
  - attachment truth
  - access authorization truth

## Minimum Surface Set
- `BFF` may shape only:
  - `GET /api/app/forum/post/detail` (attachmentRefs)
  - `GET /api/app/file/access` (preview/download access)
- `BFF` must not create:
  - a second attachment access path under `/api/app/forum/*`
  - a second attachment system

## Shaping Boundary
- `BFF` may shape only:
  - `accessUrl` response normalization
  - controlled errors for invalid/not-found/permission/unavailable
- `BFF` must not:
  - expose `objectKey`
  - invent access for unconfirmed attachments
  - bypass `Server` authorization

## Explicit Non-goals
- No rich-text editor
- No inline attachment anchors
- No second attachment system
- No upload-chain rewrite
- No forum-owned file truth

## Formal Conclusion
- `BFF` only shapes shared file access results and does not own file truth.
- Forum post detail remains attachmentRef-only.

## Next Unique Action
- After backend truth lands, dispatch `BFF` Agent second to wire shared access
  shaping and controlled error mapping.
