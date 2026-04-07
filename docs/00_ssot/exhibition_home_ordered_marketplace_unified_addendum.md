---
owner: Codex 总控
status: draft
purpose: Freeze one unified exhibition-home truth that absorbs the V1 baseline blueprint, the V1.1 showcase and bidding supplement, and the SSOT governance rules, while making the current ordered marketplace interaction the final exhibition-side decision.
layer: L0 SSOT
---

# Exhibition Home Ordered Marketplace Unified Addendum

## Input Basis
- This addendum is derived from the following desktop inputs:
  - `/Users/wangweiwei/Desktop/展览行业基础设施App_V1项目全链路施工图_完整版.docx`
  - `/Users/wangweiwei/Desktop/展览项目展示与竞标全量流程_V1.1增补施工包.docx`
  - `/Users/wangweiwei/Desktop/展览行业基础设施App_SSOT治理制度_V1.docx`
  - `/Users/wangweiwei/Desktop/展览行业基础设施App_V1.2_统一施工蓝图_展览页秩序化重构版_最终.docx`
- It also absorbs the current owner-supplied final interaction decision:
  - exhibition home must become an ordered local marketplace page
  - users may both publish tasks and take tasks
  - the final exhibition-home interaction in this addendum overrides older
    conflicting exhibition-home descriptions

## Scope
- This addendum freezes the current final truth for:
  - exhibition home information architecture
  - province-based recommendation logic
  - top-level exhibition entry modules
  - project publish flow
  - project detail and take-task handoff
  - confidentiality-agreement and watermarked PDF download chain
  - test whitelist policy for the current owner-led testing round
- It does not replace the entire project truth tree.
- It does override older conflicting exhibition-home and publish-flow sections.

## Conflict Priority
- When this addendum conflicts with older exhibition-side descriptions in:
  - `docs/00_ssot/exhibition_showcase_bid_flow_v11_upgrade_addendum.md`
  - desktop V1 / V1.1 / V1.2 blueprint files
- this addendum wins for the following topics only:
  - exhibition home layout and navigation order
  - publish-project entry and workbench flow
  - province recommendation boundary
  - public recommendation section ordering
  - publish-fee and auto-withdraw rule
  - confidentiality-agreement and watermarked download rule
- Unchanged truths remain governed by the existing SSOT tree, including:
  - one shell, five buildings
  - first-release visible buildings
  - hidden-building policy
  - BFF and Server boundary
  - downstream professional order / contract / fulfillment / inspection /
    dispute chain
  - SSOT change order and gate discipline

## Unified One-line Principle
- The exhibition home must feel like an ordered container terminal, not a loose
  parts tray.
- The home page does only four things:
  - determine the current province
  - expose six fixed module entries
  - render ordered province-scoped recommendation sections
  - hand the user into publish or take-task flows
- Complex editing must leave the home page and live in dedicated workbench pages.

## A. Unified Decision and Coverage
- This addendum exists because the current confusion does not come from the
  shell structure being wrong.
- The confusion comes from too many exhibition concerns being mixed into one
  entry page:
  - public discovery
  - private work continuation
  - project publishing
  - downstream trade and fulfillment continuation
  - forum and ranking guidance
- The final decision now becomes:
  - keep the existing shell and building architecture
  - reorder the exhibition home into one province marketplace page
  - keep publish as a real feature
  - keep downstream professional chain outside the home page

## B. Global Architecture Still Kept
- One shell and five buildings remain unchanged.
- First-release visible buildings remain:
  - `exhibition`
  - `messages`
  - `profile`
- Hidden pre-embedded buildings remain:
  - `renovation`
  - `custom_furniture`
- `exhibition` remains the first-release main battlefield.
- `messages` remains a touchpoint and handoff surface, not a second business
  console.
- `profile` remains the place for enterprise identity, certification,
  membership, file center, settings, and testing controls.

## C. Exhibition Building Reordered Shape
- The exhibition building now freezes into three clear layers:
  - public home marketplace
  - private publish and my-project workbench
  - downstream professional trade and delivery chain
- Suggested current route grouping:
  - `/shell/exhibition/home`
    - the public ordered province marketplace home
  - `/shell/exhibition/publish/new`
    - dedicated project publish workbench
  - `/shell/exhibition/my-projects`
    - my drafts, active listings, withdrawn listings, and historical listings
  - `/shell/exhibition/projects/:projectId`
    - project detail and take-task handoff
  - `/shell/exhibition/quotes/:projectId`
    - lightweight take-task or quote workbench
- The home page must not directly become:
  - a long publish form
  - an order continuation dashboard
  - a contract or fulfillment control panel
  - a mixed loose-parts landing page

## D. Exhibition Home Final Ordered Layout

### D1. Top fixed bar
- The far top-left must be a small location button.
- Tapping that button shows the current province and allows province switching.
- Immediately to the right of the location button there must be a small refresh button.
- The rest of the top bar must remain visually restrained.
- The top bar must not accumulate:
  - large multi-filter panels
  - several competing secondary navigations
  - a long mixed control strip

### D1.1 Location and weather display carrier
- The first-screen top card may expand the location area into a real location
  plus weather summary carrier.
- Device location may be supplied by Flutter App and consumed by `BFF` only as
  a current request or current-session carrier.
- Manual province selection may be handled by `BFF` in the current round
  without introducing `Server`-side persisted location truth.
- The displayed weather summary is a `BFF`-normalized read model only.
- The current round must not introduce:
  - a second weather business truth
  - a persisted location-truth object
  - a dedicated `/api/app/weather/*` path family
- Weather refresh remains part of full home refresh only; it must not become an
  independent weather-only refresh action.

### D2. Six fixed module containers
- The home page must always show a fixed two-row by three-column module grid.
- All six containers must be visible on the page.
- The six containers are:
  - first row:
    - `项目展示`
    - `优秀公司`
    - `优秀工厂`
  - second row:
    - `优秀供应商`
    - `展览论坛`
    - `优秀团队员工`
- Each container is a standalone module container.
- In the current first batch:
  - all six containers must exist now
  - `优秀公司`, `优秀工厂`, `优秀供应商`, `展览论坛`, and
    `优秀团队员工` may use placeholder content initially
  - but their containers, titles, click entry behavior, and province-scoped
    recommendation carriers must already exist

### D3. Ordered recommendation sections
- Below the six module containers, the page must render ordered recommendation sections.
- The sections must support infinite downward loading.
- The current fixed order is:
  1. province-scoped exhibition-company posted build-needed projects
  2. province-scoped forum hot posts
  3. province-scoped excellent companies and factories
  4. province-scoped excellent workers or worker teams
- The recommendation stream must not become:
  - a random waterfall collage
  - a national mixed feed
  - an unordered patchwork of unrelated cards

### D4. Floating actions
- A visible return-to-top control must exist beside the main flow.
- A publish-project floating action must exist on the page.
- No third major floating action may compete at this level.

## E. Province Scope and Refresh Rule
- Home recommendations are province-scoped only.
- Current location truth priority is frozen as:
  - manually selected province
  - device-location resolved province
  - enterprise-profile default province
  - system default province
- Once the province changes, the following must all change together:
  - module recommendation carriers
  - project recommendation listings
  - forum hot posts
  - company placeholders or real carriers
  - factory placeholders or real carriers
  - supplier placeholders or real carriers
  - team-worker placeholders or real carriers
- Refresh must only refresh the current province.
- Refresh must not silently jump to another province.
- The first batch must not introduce city-level or district-level ranking complexity on the home page.

## F. Anti-chaos Home Discipline
- The exhibition home handles “look” and “enter”, not “fill” and “sign”.
- The home page must always expose a clear next action from each visible card.
- The home page must not directly carry:
  - current order state panels
  - contract progression panels
  - fulfillment timeline panels
  - inspection or dispute command surfaces
- The home page must not hide any of the six top module containers behind horizontal scrolling or nested drill-down.

## G. Two-sided Publish / Take-task Product Model
- The product mental model is now explicitly frozen as a two-sided marketplace:
  - users may publish tasks
  - users may take tasks
- This is intentionally close to a local idle marketplace mental model.
- The key difference from a casual marketplace is:
  - once a cooperation is selected, the product continues into professional
    delivery, contract, fulfillment, inspection, and dispute chains
- Therefore:
  - the home page remains simple
  - downstream professional workflow remains deep and structured

## H. Publish Project Is A Real Feature, Not A Placeholder

### H1. Publish permission gate
- Publishing requires a registered and logged-in real enterprise account.
- Unauthenticated users cannot publish.
- Logged-in but uncertified enterprise users must be accurately blocked and
  guided to certification.
- The publish entry may not be presented as a fake-complete capability when the
  permission gate is not satisfied.

### H2. Dedicated five-step publish workbench
- Publish must not happen on the home page.
- Publish must happen in a dedicated workbench.
- The current frozen five-step flow is:
  1. basic information
  2. address and scope
  3. file materials
  4. text description and AI assistance
  5. preview, payment, and one-click publish

### H3. Required publish fields
- The publish workbench must include at minimum:
  - project title
  - project type
  - budget range
  - time-node or scheduling information
  - province / city / region selection via popup chooser
  - precise text address for the actual build site
  - PDF effect drawing upload
  - PDF construction drawing upload
  - text description up to `1000` Chinese characters
- The home page recommendation uses province only.
- The project detail page may use richer address summary.

### H4. Project type dictionary
- The current recommended first-batch dictionary includes:
  - `活动`
  - `展会`
  - `路演`
  - `美陈`
  - `博物馆`
  - `店面装修`
  - `品牌快闪`
  - `企业展厅`
  - `商场中庭`
  - `发布会`
  - `会议活动`
  - `科技馆`
  - `党建馆`
  - `校史馆`
  - `临展`
  - `导视包装`
  - `灯光音视频配套`
  - `主场搭建`
  - `其他`
- The first batch should use:
  - recommended tags
  - plus free-text custom type

### H5. AI-assisted fill is a reserved upgrade point
- The publish workbench must reserve an AI-assist entry point.
- The current first batch may treat this as:
  - a forward-looking enhancement
  - a product and analytics hook
- AI assist may help draft:
  - text description
  - material checklist hinting
  - scheduling summary
- AI does not replace final enterprise confirmation.

### H6. Preview, payment, and direct publish
- Publish must include a preview step.
- After preview confirmation, the publisher must pay `100 RMB`.
- After successful payment, the project publishes with one action.
- The current final decision does not require manual review before entering display.
- The older “submit review then enter showcase pool” path exits the default path here.

### H7. Auto-withdraw window
- Published projects must not stay in public display forever.
- The current display window is frozen as:
  - `48` hours
- After `48` hours, the project auto-withdraws from public recommendation.
- This auto-withdraw is a formal requirement, not an optional display policy.

## I. Publish Success Rule
- After successful publish:
  - the project must immediately enter the current province recommendation flow
  - the `48` hour countdown begins
  - the project becomes available for take-task discovery in that province
- The success path must not end in a silent draft-only state.

## J. Project Detail and Take-task Boundary
- The project detail page exists to answer one question:
  - should I take this task
- The detail page may show:
  - title
  - project type
  - budget range
  - text description
  - address summary
  - PDF materials
  - publish time
  - countdown state
- The detail page may hand off into:
  - take-task
  - lightweight quote or proposal submission
- The detail page must not expand into:
  - full order dashboard
  - contract control surface
  - fulfillment timeline controller
  - dispute console

## K. Lightweight Take-task First, Advanced Bid Mode Later
- The current first-batch default is a lightweight take-task or quote flow.
- The older heavier V1.1 ideas remain acceptable as future upgrades, including:
  - seat-lock bidding
  - richer bid workspace
  - structured decision and rejection objects
- However those heavier models are not the current home-page default mental model.
- They must be reopened only by later truth freezing.

## L. File Upload, Confidentiality, and Watermarked Download Chain

### L1. Upload chain
- File upload remains a three-step chain:
  - init
  - direct upload
  - confirm
- PDF effect drawings and PDF construction drawings must upload directly into OSS.
- Business truth does not live in raw object keys.
- Business truth must remain on metadata objects such as `FileAsset`.

### L2. Confidentiality agreement before download
- Before any PDF download, the user must explicitly agree to a confidentiality agreement.
- This agreement acceptance must be persisted and auditable.
- The system must know:
  - who agreed
  - when they agreed
  - for which file or project
  - against which agreement version

### L3. Watermarked download result
- The system must not directly hand out the original PDF as the user-facing download artifact.
- The download result must be a watermarked copy.
- The watermarked copy should at minimum include:
  - viewer account identity
  - viewer enterprise identity
  - current time
  - project number or project identity
  - internal-use restriction hint

### L4. Minimum file-side object set
- The current first-batch minimum object set includes:
  - `FileAsset`
  - `ConfidentialityAgreementVersion`
  - `FileDownloadConsent`
  - `FileWatermarkTicket`

## M. Test Whitelist Rule
- The current owner asked for one test whitelist system.
- The current first-batch test whitelist account is:
  - account: `wangweiwei`
  - password: `6261215`
- This whitelist exists for testing only.
- The whitelist may hold special privileges such as:
  - publish fee bypass
  - publish-frequency bypass
  - direct real publish testing rights
- This whitelist must not remain as plaintext production truth.
- Before production release:
  - move it into secure configuration
  - rotate credentials
  - remove plaintext visibility from user-facing or checked-in assets

## N. Data Objects Needed For This Unified Direction
- The following first-batch objects are currently justified by this addendum:
  - `GeoProvinceContext`
  - `ExhibitionHomeModule`
  - `ProvinceRecommendationBundle`
  - `PublishedProjectListing`
  - `ProjectPublishDraft`
  - `ProjectPublishPreview`
  - `PublishFeeOrder`
  - `PublishWhitelistAccount`
  - `ConfidentialityAgreementVersion`
  - `FileDownloadConsent`
  - `FileWatermarkTicket`

## O. Minimum Interface Direction
- The following first-batch interface directions are justified by this addendum:
  - `GET /api/app/exhibition/home`
    - province-scoped home aggregation
  - `POST /api/app/exhibition/home/location/select`
    - manual province selection
  - `POST /api/app/exhibition/home/refresh`
    - refresh current province data
  - `GET /api/app/project/list`
    - project recommendation list under province filtering
  - `GET /api/app/project/detail`
    - project detail with file handoff
  - `POST /api/app/project/publish/preview`
    - preview before commit
  - `POST /api/app/project/publish/commit`
    - fee-confirmed direct publish
  - existing file upload init and confirm interfaces
  - download-consent and watermark-ticket interfaces for PDF download control

## P. Keep / Remove Rule

### P1. Keep
- Keep:
  - one shell, five buildings
  - first-release visible buildings
  - hidden-building policy
  - downstream professional chain
  - BFF and Server boundaries
  - OSS and file metadata pattern
  - SSOT-first change order

### P2. Remove or exit default path
- Remove from the current exhibition-home default path:
  - mixed homepage workbench summary
  - long publish form on the home page
  - contract and fulfillment control surfaces on the home page
  - national mixed recommendation flow
  - the older default “review first, then display” publish path
  - heavy bid-workspace mental model as the first home-page behavior

## Q. Acceptance Baseline
- Before this direction is considered complete:
  - the first screen must show:
    - location button
    - refresh button
    - six module containers
  - province switching must update all six recommendation families together
  - return-to-top and publish-project actions must exist
  - publish must be a dedicated workbench, not an in-home long form
  - uncertified enterprises must be blocked accurately from publish
  - real enterprises must be able to upload PDF files to OSS
  - preview -> `100 RMB` payment -> one-click publish must work
  - publish success must immediately enter province recommendation
  - `48` hour auto-withdraw must work
  - PDF download must require confidentiality consent first
  - user-facing download must be watermarked

## R. Implementation Order Reminder
- This addendum freezes truth only.
- The correct next order remains:
  1. update SSOT and conflict references
  2. update contracts
  3. update backend and BFF truth specs
  4. update frontend truth specs
  5. implement code

## S. Relationship To The Generated DOCX Output
- The latest merged DOCX output exists at:
  - `/Users/wangweiwei/Desktop/展览装修之家总控/output/doc/展览行业基础设施App_V1.3_展览页秩序化统一真源_单文件最终版.docx`
- That DOCX is a deliverable projection for reading and sharing.
- This Markdown addendum is the maintainable repository SSOT form.
