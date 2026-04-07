---
owner: Codex 总控
status: draft
purpose: Identify reusable assets, real gaps, repair targets, and forbidden duplicate work for the current forum implementation round.
layer: L0 SSOT
---

# 论坛模块实现轮现状资产识别单

## 1. Scope
- This addendum identifies the current asset baseline for the `论坛模块`
  implementation round only.
- It exists to prevent duplicate construction, fake completion, and blocker
  drift.

## 2. Existing Frontend Assets
- Existing forum IA and ownership truth already exist:
  - `docs/00_ssot/forum_navigation_building_ownership_boundary_addendum.md`
  - `docs/00_ssot/forum_navigation_boundary_revision_addendum.md`
- Existing frontend consumption and implementation-facing truth already exist:
  - `docs/04_frontend/forum_frontend_consumption_truth_addendum.md`
  - `docs/04_frontend/forum_frontend_implementation_surface_addendum.md`
- Existing frozen frontend mainline remains:
  - `exhibition/forum` main browse chain
  - `广场 / 本地 / 关注`
  - search as top-right tool
  - publish as bottom-right `+`
  - `messages` as interaction center only
  - `profile` as forum personal-assets entry only

## 3. Existing BFF Assets
- Existing `BFF` route-group and implementation-facing truth already exist:
  - `docs/03_bff/forum_bff_route_group_truth_addendum.md`
  - `docs/03_bff/forum_bff_implementation_surface_addendum.md`
- Existing latest `BFF` alignment evidence already exists:
  - `.tmp/agent_reports/forum_bff_alignment/20260329/bff_forum_alignment.md`
- Current `BFF` live baseline from the receipt is:
  - connected app-facing paths: `8`
  - unconnected app-facing paths: `13`
  - `GET /api/app/forum/feed` query drift for `scope/topicId` has been fixed

## 4. Existing Backend Assets
- Existing backend implementation-facing truth already exists:
  - `docs/02_backend/forum_server_implementation_truth_addendum.md`
- Existing server-side blocker truth already exists:
  - `docs/00_ssot/forum_server_implementation_blocker_addendum.md`
- Existing backend domain baseline already exists:
  - `docs/00_ssot/forum_domain_truth_baseline_addendum.md`
- Current backend implementation truth already freezes:
  - feed/detail/interaction/draft/publish/me-assets/inbox command-query
    families
  - `Server` as the only forum truth owner

## 5. Existing Contract / L3 / Implementation Truth
- Existing contract truth already exists:
  - `docs/01_contracts/forum_app_facing_contracts_addendum.md`
  - `docs/01_contracts/openapi.yaml`
- Existing frontend `L3` truth already exists:
  - `docs/04_frontend/forum_frontend_consumption_truth_addendum.md`
  - `docs/04_frontend/forum_frontend_implementation_surface_addendum.md`
- Existing `BFF` `L3` truth already exists:
  - `docs/03_bff/forum_bff_route_group_truth_addendum.md`
  - `docs/03_bff/forum_bff_implementation_surface_addendum.md`
- Existing implementation unlock truth already exists:
  - `docs/00_ssot/forum_implementation_unlock_addendum.md`

## 6. Current Directly Reusable Assets
- The frozen five-building shell and forum ownership split
- The frozen forum canonical path family under `/api/app/forum/*`
- The frozen post-centric main browse chain under `exhibition/forum`
- The already connected `BFF` live path set:
  - `/api/app/forum/feed`
  - `/api/app/forum/topic/list`
  - `/api/app/forum/topic/detail`
  - `/api/app/forum/post/detail`
  - `/api/app/forum/draft/list`
  - `/api/app/forum/publish`
  - `/api/app/forum/search`
  - `/api/app/forum/me/index`
- The already corrected `feed` query passthrough for:
  - `scope`
  - `topicId`

## 7. Current Work Still Needed
- `BFF` route gaps still need to be connected for the current canonical family:
  - `topic/metadata`
  - `post/comments`
  - `post/comment`
  - `post/like`
  - `post/bookmark`
  - `topic/follow`
  - `draft/save`
  - `draft/delete`
  - `me/posts`
  - `me/comments`
  - `me/bookmarks`
  - `me/follows`
  - `interaction/inbox`
- Current server-side cloud verification still needs:
  - migration verification
  - code implementation verification
  - build/test verification
  - audit landing verification
- Current feed still needs later scope-specific verification because:
  - `square / local / following` query passthrough is fixed
  - but current live runtime still shows no differentiated result evidence

## 8. Current Repair Targets
- Keep implementation work incremental and aligned to the frozen canonical path
  set only
- Repair live route coverage from `8/21` to full contract coverage progressively
- Keep current forum browse chain post-centric
- Keep `messages` and `profile` as bounded consumers only

## 9. Current Forbidden Duplicate Work
- No duplicate forum activation document
- No duplicate forum boundary document
- No duplicate forum implementation unlock document
- No second forum path family
- No second forum truth owner
- No second forum browse tree under `messages` or `profile`
- No fake content fallback to hide `404 / 501 / missing route`
- No silent overwrite of the existing server blocker truth

## 10. Current Known Blocker
- Current known blocker must follow only:
  - `docs/00_ssot/forum_server_implementation_blocker_addendum.md`
- This round may cite that blocker but must not rewrite or supersede it without
  a new total-control ruling.

## 11. Next Unique Action
- Use this asset baseline to drive only incremental forum implementation
  dispatch, not verification, release, or closure.

