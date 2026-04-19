---
owner: Codex 总控
status: draft
purpose: Freeze the V1 enterprise-hub boundary so the module fits the existing exhibition App, identity truth, upload truth, and contract path families.
layer: L0 Constitution
---

# Enterprise Hub V1 App-aligned Freeze Addendum

## Current Validity Notice
- This document remains a historical V1 boundary note.
- But the following clauses no longer describe current runtime truth as of `2026-04-11`:
  - `enterprise_listing.organization_id is mandatory and unique`
  - `V1 must not allow one organization to occupy multiple public lists`
  - `V1 must not allow one organization to occupy multiple public top slots`
- These clauses are superseded by:
  - `docs/00_ssot/enterprise_display_chain_single_source_of_truth_freeze_addendum.md`

## Scope
- This addendum freezes the V1 boundary for `展链库`.
- It applies only to the exhibition building.
- It defines:
  - the App-aligned access pattern
  - truth ownership
  - board boundary
  - state responsibility split
  - file-truth rules
  - app-facing and admin-facing path rules
- It does not by itself:
  - approve implementation dispatch
  - modify `openapi.yaml`
  - generate package outputs
  - approve trading or payment features

## Module Identity
- Chinese product name remains:
  - `展链库`
- Internal English module name remains:
  - `enterprise_hub`
- Domain ownership remains:
  - `exhibition`
- V1 product position remains:
  - enterprise display and search baseline only

## Home Integration Rule
- The exhibition home must not introduce a seventh module container.
- `展链库` must attach only to the existing three fixed home containers:
  - `优秀公司`
  - `优秀工厂`
  - `优秀供应商`
- The home first-screen truth remains owned by:
  - `GET /api/app/exhibition/home`
- V1 must not reinterpret the home into:
  - a separate enterprise-hub home
  - a new mixed marketplace shell
  - a long-form application entry

## Current Home Card Meaning
- The three current cards act only as:
  - entry points
  - title and subtitle carriers
  - lightweight recommendation or count carriers
- Deep filter, sorting, and enterprise-detail truth belong only after entering
  the dedicated list or detail pages.
- The existing home recommendation order must not be silently reshuffled by
  this module.

## Identity Truth Ownership
- `organization` remains the only organization identity truth.
- `profile/certification` remains the only basic certification truth.
- `展链库` must not create:
  - a second legal-entity truth
  - a second organization membership system
  - a second certification truth
- The V1 display-side carrier is frozen as:
  - `enterprise_listing`
- `enterprise_listing.organization_id` is mandatory and unique.
- Any copied legal or certification fields inside `enterprise_listing` are
  display snapshots only.

## Board Model Rule
- The only public board types are:
  - `company`
  - `factory`
  - `supplier`
- Their visible labels remain:
  - `优秀公司`
  - `优秀工厂`
  - `优秀供应商`
- One organization may own multiple capability profiles.
- V1 public exposure may use only one `primary_board_type`.
- Additional capabilities may appear only as:
  - detail-page support labels
  - secondary capability tags
- V1 must not allow one organization to occupy:
  - multiple public lists
  - multiple public top slots
  - multiple public ranking systems

## File Truth Rule
- Upload remains the shared three-step flow:
  - `init`
  - direct upload
  - `confirm`
- `objectKey` is never business truth here.
- `FileAsset` remains the only file truth.
- `展链库` must not persist media truth as raw URL fields.
- V1 media references must use `file_asset_id` or `file_asset_ids`.

## State Responsibility Split
- `application_status` owns application review flow only.
- `enterprise_status` owns listing lifecycle only.
- `display_status` owns current frontend visibility only.
- Certification result shown in this module is snapshot-only and must not be
  reinterpreted as the application lifecycle.

## Frozen State Families
- `application_status`:
  - `draft`
  - `submitted`
  - `under_review`
  - `revision_required`
  - `approved`
  - `rejected`
- `enterprise_status`:
  - `unpublished`
  - `published`
  - `offline`
  - `frozen`
- `display_status`:
  - `hidden`
  - `visible`

## Explicitly Forbidden State Drift
- `enterprise_status` must not carry:
  - `submitted`
  - `under_review`
  - `revision_required`
  - `approved`
  - `rejected`
- Frontend, `BFF`, and `Server` must not invent separate board-state meanings.

## Formal Path Rule
- Formal app-facing paths must stay inside `/api/app/*`.
- Formal admin-facing paths must stay inside `/server/admin/*`.
- `/bff/*` is implementation only and must not become product truth.

## V1 First-batch App-facing Scope
- V1 first-batch app-facing scope may include only:
  - enterprise list
  - enterprise detail
  - recommendation list
  - application create
  - enterprise basic update
  - company/factory/supplier profile update
  - case create
  - application submit
  - application status read
- A separate `boards` path is not a first-batch requirement because home cards
  already remain inside `GET /api/app/exhibition/home`.

## Frontend Route Rule
- V1 routes must align with the existing exhibition route style.
- Recommended V1 routes are:
  - `/exhibition/companies`
  - `/exhibition/factories`
  - `/exhibition/suppliers`
  - `/exhibition/companies/detail`
  - `/exhibition/factories/detail`
  - `/exhibition/suppliers/detail`
  - `/exhibition/enterprise/apply`
  - `/exhibition/enterprise/application-status`
- V1 must not use `/exhibition/zhanlianku/*` as the first formal route family.

## Permission Boundary
- V1 does not introduce a new app-facing role family by default.
- Enterprise-side access must first reuse:
  - existing login context
  - existing organization scope
  - existing certification handoff
- If the current actor has no organization scope, the flow must hand off back
  to the current profile organization entry.
- If the current actor lacks required certification, the flow must hand off
  back to the current certification flow.
- 当前阶段明确冻结：
  - 真实账号组织上下文尚未完全接入，`enterprise_hub` 相关申请与详情在无组织上下文条件下可出现业务态 `403/404`，该行为需与路由缺失故障区分。
- Review, publish, offline, freeze, and recommendation management remain admin
  or server-admin responsibilities only.

## Recommendation Boundary
- Each board may expose up to three top recommendation slots.
- Board recommendation slots do not automatically redefine the home
  recommendation order.
- The current home recommendation stream may continue to keep
  `优秀公司 / 优秀工厂` in the current province-scoped recommendation area.
- `优秀供应商` V1 may first enter through the fixed home card plus dedicated list
  page, without forcing a new home recommendation section.

## V1 Non-goals
- No online order placement
- No online payment
- No online contract signing
- No IM consultation
- No deep map capability
- No complex ranking system
- No deep review and complaint platform
- No AI recommendation
- No multi-board simultaneous public exposure
- No second enterprise identity truth

## Freeze Conclusion
- `展链库 V1` is now frozen as an exhibition-owned enterprise display and search
  baseline that must fit the current App rather than building a second product
  shell.
- The next contract package must follow this addendum exactly.
