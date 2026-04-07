---
owner: Codex 总控
status: draft
purpose: Freeze the transitional value of the V1.1 showcase and bidding supplement, while deferring final exhibition-home order, publish flow, and province-marketplace truth to the newer unified addendum.
layer: L0 SSOT
---

# Exhibition Showcase And Bidding Flow V1.1 Upgrade Addendum

## Input Basis
- This addendum is derived from the desktop source input:
  - `/Users/wangweiwei/Desktop/展览项目展示与竞标全量流程_V1.1增补施工包.docx`
- The current final exhibition-home and publish-flow decision is now owned by:
  - `docs/00_ssot/exhibition_home_ordered_marketplace_unified_addendum.md`
- It does not replace the existing V1 baseline.
- It upgrades the current exhibition information architecture and object
  boundaries according to the actual repository and runtime state already in use.

## Current Priority Note
- This file now serves as a transitional V1.1 supplement record only.
- It still governs:
  - why `showcase` and `workbench` were split conceptually
  - why current `project/list`, `project/detail`, and minimum bid continuation
    carriers remain reusable
  - which deferred V1.1 object families are still not approved
- It no longer owns the final truth for:
  - exhibition-home first-screen layout
  - province-scoped home recommendation order
  - the six fixed top module containers
  - the current final publish-project workbench flow
  - publish fee, auto-withdraw, confidentiality-agreement, or watermarked
    download semantics
- Any conflict on those topics is now resolved by:
  - `docs/00_ssot/exhibition_home_ordered_marketplace_unified_addendum.md`

## Why This Addendum Is Required
- The current product confusion does not come from the shell structure being
  wrong.
- The current confusion comes from `exhibition` still mixing three different
  roles into one landing page and one route family:
  - public project discovery
  - private transaction continuation
  - system summary and explanation
- Under the current implementation, users perceive:
  - project display
  - project creation
  - bid submit
  - order continuation
  - fulfillment continuation
  - forum
  as same-level entry parts.
- This makes the exhibition homepage feel like a loose parts tray instead of a
  single guided path.

## Frozen Current-state Diagnosis
- The following current assets remain valid and must be reused:
  - one shell, five buildings
  - first-release visible buildings remain:
    - `exhibition`
    - `messages`
    - `profile`
  - hidden buildings remain:
    - `renovation`
    - `custom_furniture`
  - `forum` remains inside `exhibition`, not a sixth building
  - `GET /api/app/exhibition/workbench` remains the current canonical private
    exhibition summary path
  - current downstream continuation routes remain valid:
    - `project`
    - `bid`
    - `order`
    - `contract`
    - `milestone`
    - `inspection`
    - `rating`
    - `dispute`
- The current actual problem is:
  - `exhibition` has not been split into a public discovery face and a private
    execution face
  - the homepage still carries too much routing responsibility in one page
  - current project and bid related pages are still perceived as flat same-level
    parts rather than one coherent line

## Transitional Upgrade Decision
- No new bottom tab.
- No sixth building.
- No rewrite of the existing mainline.
- The V1.1 split between `showcase` and `workbench` remains valid as a
  transitional internal layering concept.
- `forum` remains an internal exhibition feature family, but it is not one of
  the two primary faces.
- The old split-entry hub interpretation is no longer the final first-screen
  decision.
- The current final first-screen decision is the ordered province marketplace
  page frozen in the unified addendum.

## Adaptation To Current Actual App
- The supplement source uses a conceptual `/shell/exhibition/showcase` and
  `/shell/exhibition/workbench` split.
- In the current Flutter app, that concept must be adapted to the existing route
  style and existing shell rules as:
  - `/exhibition`
    - ordered province marketplace home owned by the unified addendum
  - `/exhibition/showcase`
    - public project-display module page
  - `/exhibition/workbench`
    - private project continuation face
- Existing approved downstream routes continue under this layered relationship
  and are not discarded:
  - `/exhibition/projects`
  - `/exhibition/projects/create`
  - `/exhibition/projects/detail`
  - `/exhibition/bids/submit`
  - `/exhibition/orders/detail`
  - `/exhibition/contracts/detail`
  - `/exhibition/contracts/confirm`
  - `/exhibition/contracts/amend`
  - `/exhibition/milestones`
  - `/exhibition/milestones/submit`
  - `/exhibition/inspections/detail`
  - `/exhibition/inspections/submit`
  - `/exhibition/inspections/recheck`
  - `/exhibition/ratings/entry`
  - `/exhibition/ratings/submit`
  - `/exhibition/disputes/open`
  - `/exhibition/disputes/withdraw`

## Current Homepage Ownership Change
- The older V1.1 split-entry homepage rule is now superseded.
- `/exhibition` is no longer owned by this file as a simple dual-entry hub.
- The final current homepage truth is:
  - ordered province marketplace home
  - location button + refresh button
  - six fixed top module containers
  - ordered recommendation sections
  - publish-project and return-to-top actions
- This file now governs only the transitional relationship between:
  - the home marketplace page
  - the `showcase` project-display module page
  - the private continuation `workbench` page

## Frozen Showcase vs Workbench Boundary
- `showcase`
  - current project-display module page inside `exhibition`
  - used for:
    - project discovery after the user enters from the ordered home marketplace
    - project display detail
    - deciding whether to enter bidding
  - must not own:
    - order truth
    - contract truth
    - fulfillment truth
    - governance truth
- `workbench`
  - private execution face inside `exhibition`
  - used for:
    - continue my current project work
    - manage my published projects
    - continue the current bidding chain
    - continue my orders
    - continue fulfillment and acceptance
  - must not be presented as a public discovery surface
- Neither `showcase` nor `workbench` now owns the full first-screen home-page
  layout truth; that belongs to the unified addendum.

## Immediate Upgrade Strategy Under Current Truth
- The repository does not yet have a dedicated showcase contract family.
- Therefore the first practical upgrade step must reuse current valid carriers:
  - `GET /api/app/project/list`
    - temporary first-step carrier for showcase listing
  - `GET /api/app/project/detail`
    - temporary first-step carrier for showcase detail
  - `GET /api/app/exhibition/workbench`
    - current workbench summary carrier for the private face
- This means the first upgrade is an information architecture upgrade before it
  becomes a full object-family expansion.
- Under the newer unified addendum, those same carriers remain reusable for the
  project-display module page while the home page itself grows into an ordered
  province marketplace.

## Deferred Upgrade Objects
- The following objects are accepted as V1.1 upgrade direction, but are not
  automatically activated by this addendum alone:
  - `ProjectShowcase`
  - `BidSeatLock`
  - `BidWorkspace`
  - `BidDecision`
  - `BidRejection`
  - `ContractVersion`
  - `DailyProgressLog`
  - `AcceptanceArchive`
  - `MyBidEntry`
- These objects require later truth freezing across:
  - `L1 Domain`
  - `L2 Contracts`
  - `L3 Backend / BFF / Frontend`
  before implementation can be signed as complete.

## Current Repository Realization Snapshot
- The desktop supplement has already been partially adapted into the current
  repository and must be treated as an incremental upgrade, not a fresh rebuild.
- The currently reused carriers are:
  - `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/exhibition_hub_page.dart`
    - current legacy hub carrier that must now yield first-screen truth to the
      ordered-home addendum
  - `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_list_page.dart`
    - current first-step project-display list carrier
  - `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_detail_page.dart`
    - current first-step project-display detail carrier and controlled handoff into
      the minimum bidding continuation
  - `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/project_create_page.dart`
    - current publish entry carrier pending the dedicated five-step publish
      workbench alignment
  - `/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/lib/features/exhibition/presentation/pages/bid_submit_page.dart`
    - current minimum bidding continuation carrier
- The current frontend test evidence already covers the accepted first-step V1.1
  subset:
  - formal showcase wording
  - minimum bid continuation wording
  - current project -> bid continuation handoff
- It does not yet prove the final ordered-home first screen or the final
  five-step publish workbench truth.
- This means the supplement is already partially landed as:
  - information architecture truth
  - route truth
  - minimum frontend carrier truth
  and not merely as an external desktop memo.

## Current Execution Ceiling For This Input
- The accepted first-step realization ceiling is frozen as:
  - public project-display module page separated from the private continuation
    workbench
  - project detail that explains the project first and only then continues to
    the minimum bidding face
  - minimum bid continuation only, not a full bidding workspace
- Publish-page final semantics are no longer frozen in this file.
- The current publish final semantics now belong to:
  - `docs/00_ssot/exhibition_home_ordered_marketplace_unified_addendum.md`
- Therefore this file must not be used to justify:
  - a four-step submit-review publish path
  - a review-before-display default publish model
  - a second publish workflow state machine
- The current `/exhibition/bids/submit` route is accepted only as the minimum
  continuation face for:
  - quote amount
  - proposal summary
  - submit action
  - order handoff continuation
- The current route must not be re-expanded into:
  - `BidWorkspace`
  - `MyBidEntry`
  - `BidDecision`
  - `BidRejection`
  - result transparency consoles
  - a second bidding state machine

## Required Corrections Before Stable Sign-off
- The current homepage private-entry copy still overstates the active scope by
  saying `跟进我的竞标`.
- That wording must be corrected to a boundary-safe expression such as:
  - continue current project work
  - continue the current bidding chain
- This is a wording correction only.
- It must not be used as a reason to reopen or implement `MyBidEntry`.
- Stable sign-off for the first-step V1.1 supplement also still requires real
  tunnel-based cloud read evidence for the current canonical reads:
  - `GET /api/app/project/list`
  - `GET /api/app/project/detail`
- If private continuation remains active in the current batch, then
  `GET /api/app/exhibition/workbench` also remains a required verification path.

## Current-stage Upgrade Order
1. Freeze the ordered exhibition-home marketplace truth in the unified addendum.
2. Update frontend route truth so `/exhibition` becomes the ordered marketplace
   page and `showcase` / `workbench` become subordinate faces.
3. Re-map current project list and project detail into the project-display
   module experience.
4. Keep the private continuation face available without letting it own the
   public home page.
5. Freeze the next-stage V1.1 object family expansions only after the new home
   order is stable.

## Incremental Dispatch Order After This Landing
1. Frontend Agent:
   - align the ordered home marketplace page with the new unified truth
   - provide tunnel-based read verification evidence
2. Backend Agent:
   - complete cloud-side inventory for the currently reused project and file
     carriers
3. BFF Agent:
   - complete cloud-side inventory for the current home, project, and file read
     aggregations
4. Codex 总控:
   - decide which deferred V1.1 objects are next eligible for L1/L2 truth
     freezing
5. 结果校验 Agent:
   - independently confirm no duplicate workspace, parallel home page, or
     hidden-page reopening was introduced

## Explicit Non-goals
- No new bottom navigation item.
- No conversion of `forum` into a primary exhibition face.
- No reopening of hidden buildings.
- No direct activation of seat lock, compare, decision, rejection, daily
  progress, or archive logic by this file alone.
- No replacement of current `Project -> Bid -> Order -> Contract -> Milestone -> Inspection`
  mainline truth.

## Authority Map
- Exhibition current mainline remains owned by:
  - `/Users/wangweiwei/Desktop/展览装修之家总控/docs/00_ssot/current_stage_mainline_blueprint_addendum.md`
- Current Flutter route and page truth remains owned by:
  - `/Users/wangweiwei/Desktop/展览装修之家总控/docs/04_frontend/flutter_screen_map.md`
- Current BFF route truth remains owned by:
  - `/Users/wangweiwei/Desktop/展览装修之家总控/docs/03_bff/bff_routes.md`
- This file is the controlling `L0` addendum for the transitional V1.1
  showcase and workbench layering decision only.
