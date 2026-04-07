---
owner: Codex 总控
status: draft
purpose: Freeze BFF route groups and app-facing responsibility boundaries.
layer: L3 BFF
---

# BFF Routes

## Scope
`BFF` serves Flutter App only.

## Route Groups
| Group | Purpose |
|---|---|
| `auth` | OTP login, session refresh, logout, and app-facing auth consolidation only |
| `shell` | shell context, visible buildings, unread summary, announcements |
| `exhibition` | ordered home aggregation, home refresh, manual location selection, and private workbench summary |
| `forum` | forum feed, topic/post/detail aggregation, publish handoff, drafts, search, and me-subtree summaries |
| `project` | project list and detail aggregation |
| `bid` | bid list, compare, and detail aggregation |
| `order` | order and milestone summary aggregation |
| `contract` | contract workflow aggregation, confirm handoff, and Phase 3 amend handoff only |
| `inspection` | inspection entry aggregation, submit handoff, and Phase 3 recheck handoff only |
| `rating_dispute` | rating entry aggregation, rating submit handoff, and dispute open handoff only |
| `file` | upload init, confirm handoff, preview metadata |
| `message` | instance_todo visibility trimming and jump targets only |
| `profile` | profile index, organization, certification, membership, security, and settings handoff shaping |
| `platform` | capability awareness only, including hidden or future flags |

## Hard Boundaries
- No Admin routes.
- No Server truth duplication.
- No second state machine.
- No provider-specific map logic.
- `auth` for Flutter App must stay under `/api/app/auth/*` only.
- `BFF` must not expose bare `/auth/*`, bare `/organizations/*`, or bare `/security/*` public path families.
- Phase 2.3 freezes entry states only for `contract`, `inspection`, and
  `rating_dispute`; full post-delivery workflows remain outside scope.
- Phase 3 only reopens `contract` at the L3 consumer boundary for:
  - `GET /api/app/contract/detail`
  - `POST /api/app/contract/confirm`
  - `POST /api/app/contract/amend`
- Phase 3 only reopens `inspection` at the L3 consumer boundary for:
  - `GET /api/app/inspection/detail`
  - `POST /api/app/inspection/submit`
  - `POST /api/app/inspection/recheck`
- The next planned `rating` round reopens `rating_dispute` at the L3 consumer
  boundary for:
  - `GET /api/app/rating/entry`
  - `POST /api/app/rating/submit`
- `BFF` must not expose contract clause editors, sign workflow, legal review,
  history, list, or reporting projections.
- `InspectionDecisionApplicationService.applyInspectionDecision` remains
  Server-internal only and must not surface through `BFF`.
- `BFF` must not expose inspection list, history, governance review,
  platform decision panels, or multi-round workflow consoles.
- `BFF` must not expand `message` into a general-purpose message center,
  notification orchestration system, or cross-object workbench.
- `BFF` must not introduce any new app-facing path for `instance_todo` in this
  planning round; only consumption boundaries may be frozen here.
- `forum` is a cross-building feature family, not a sixth shell building.
- `BFF` must not create forum truth, publish workflow truth, moderation truth,
  ranking truth, or search-index truth.

## Auth Boundary
- The minimum current app-facing auth path set is limited to:
  - `POST /api/app/auth/otp/send`
  - `POST /api/app/auth/otp/login`
  - `POST /api/app/auth/refresh`
  - `POST /api/app/auth/logout`
- `BFF` may:
  - normalize request ids, trace ids, and current device metadata
  - forward OTP send, OTP login, refresh, and logout commands to `Server`
  - shape the minimum session bootstrap response required by Flutter App
  - normalize session, auth, rate-limit, and permission failures into the
    unified app-facing error envelope
- `BFF` must not:
  - own OTP truth, session truth, refresh-token truth, or device truth
  - invent a second session state machine
  - expose password login, WeChat login, SSO, or Admin login from this family

## Profile Identity Boundary
- The minimum current app-facing profile identity path set is limited to:
  - `GET /api/app/profile/index`
  - `POST /api/app/profile/organization/create`
  - `POST /api/app/profile/organization/join-by-code`
  - `POST /api/app/profile/organization/switch`
  - `GET /api/app/profile/organization/mine`
  - `GET /api/app/profile/organization/members`
  - `PATCH /api/app/profile/organization/members/{memberId}/role`
  - `PATCH /api/app/profile/organization/members/{memberId}/disable`
  - `POST /api/app/profile/certification/submit`
  - `GET /api/app/profile/certification/current`
  - `POST /api/app/profile/certification/resubmit`
  - `GET /api/app/profile/security/devices`
  - `POST /api/app/profile/security/devices/{deviceId}/revoke`
  - `POST /api/app/profile/block`
  - `POST /api/app/profile/unblock`
  - `GET /api/app/profile/block/status`
- `BFF` may:
  - shape organization, certification, membership, and device read models for
    Flutter App
  - forward create, join, switch, member role change, member disable,
    certification submit or resubmit, and device revoke commands to `Server`
  - forward minimum Block P0 block, unblock, and single-target block-status
    commands to `Server`
  - reload shell context after organization switch through the existing shell
    carrier instead of creating a second bootstrap model
- `BFF` must not:
  - own organization, membership, certification, invitation, or device truth
  - own block relation truth or a second block state machine
  - move final permission judgement from `Server` to Flutter App
  - create Admin review or governance routes through the profile family

## Forum Boundary
- `forum` is the only current app-facing route group for community aggregation.
- The minimum current path set is limited to:
  - `GET /api/app/forum/feed`
  - `GET /api/app/forum/topic/list`
  - `GET /api/app/forum/topic/detail`
  - `GET /api/app/forum/post/detail`
  - `POST /api/app/forum/publish`
  - `GET /api/app/forum/draft/list`
  - `GET /api/app/forum/search`
  - `GET /api/app/forum/me/index`
- `BFF` may:
  - normalize auth with the existing app-facing session boundary
  - shape feed, topic, post, draft, search, and `me` read models
  - expose publish only as a handoff for an existing Server-owned draft
  - forward only confirmed file truth references from the existing upload
    init -> direct upload -> confirm chain
  - apply the existing common response envelope head and the frozen cursor
    pagination structure
- `BFF` must not:
  - expose forum authoring truth creation, moderation consoles, operator tools,
    or ranking control panels
  - treat object storage `objectKey` as forum business truth
  - create a second draft lifecycle, publish state machine, or search
    eligibility system
  - reopen forum upload as a second path family instead of reusing the
    existing upload-signing surface

## Exhibition Ordered Home Boundary
- `GET /api/app/exhibition/home` is the current app-facing exhibition
  first-screen aggregation path.
- `POST /api/app/exhibition/home/refresh` refreshes the full current home
  aggregation only.
- `POST /api/app/exhibition/home/location/select` is the only current manual
  location-selection handoff inside the exhibition app-facing family.
- `BFF` may:
  - normalize auth and the current actor shell context
  - consume the current request or current-session device location carrier
  - project one normalized location and weather card only
  - reuse the current `project/list` projection as the first recommendation
    section carrier
  - shape controlled placeholders or real carriers for the other five module
    families without inventing a second truth root
  - call upstream weather or reverse-geocode providers only through normalized
    adapters and timeout-guarded aggregation
  - expose only front-end friendly location, weather, module, and
    recommendation read models
- `BFF` must:
  - refresh the entire home aggregation, not only the weather card
  - return explicit non-persistent location-selection semantics when the
    current round does not persist selection to `Server`
  - normalize upstream provider failures into controlled home error codes
- `BFF` must not:
  - add `/api/app/weather/*`
  - expose provider-native weather or reverse-geocode payloads directly
  - create persisted weather truth, persisted location truth, or a second
    recommendation state machine
  - reinterpret `objectKey`, provider cache keys, or temporary location tokens
    as business truth
- Current failure handling must stay limited to controlled propagation of:
  - `LOCATION_REQUIRED`
  - `LOCATION_PERMISSION_UNAVAILABLE`
  - `HOME_WEATHER_UPSTREAM_UNAVAILABLE`
  - `HOME_REFRESH_TIMEOUT`
  - `HOME_AGGREGATION_UNAVAILABLE`

## Exhibition Workbench Summary Boundary
- `GET /api/app/exhibition/workbench` is the only current app-facing exhibition
  private-continuation summary path.
- `BFF` may shape only the frozen summary containers:
  - `project_chain`
  - `order_chain`
  - `fulfillment_chain`
  - `extension_boundary`
- `BFF` may project only the current summary carriers needed by the private
  workbench:
  - recent project context
  - current order context
  - current fulfillment context
  - controlled extension-boundary states
- `BFF` may expose workbench actions only through the frozen booleans for:
  - create project
  - open project pool
  - open order detail
  - open contract detail
  - open dispute-open entry
  - open milestone list
  - open milestone submit
  - open inspection detail
  - open inspection submit
- `BFF` must keep the following outside the workbench action set:
  - `rating/submit`
  - `inspection/recheck`
  - `dispute/withdraw`
- `BFF` must not:
  - become the owner of any business truth
  - turn the workbench summary into a second dashboard state machine
  - emit detail, list, history, governance, moderation, or reporting
    projections through this path
  - create a second extension carrier instead of reusing the current order
    context

## Contract Phase 3 Boundary
- `contract/amend` is the only new Phase 3 app-facing contract handoff.
- `BFF` may forward `contractId`, normalize auth, and shape the minimum
  success or failure response only.
- `BFF` must not invent contract workflow states, clause deltas, legal-review
  projections, or sign-flow status.
- Success handling stays limited to controlled handoff of the returned:
  - `contractId`
  - `orderId`
  - `state`
  - `summary`
- Failure handling stays limited to controlled propagation of:
  - `CONTRACT_ENTRY_UNAVAILABLE`
  - `CONTRACT_CONFIRM_INVALID`
  - `CONTRACT_INVALID_STATE`
  - `CONTRACT_AMEND_INVALID`
  - `CONTRACT_AMEND_LIMIT_REACHED`

## Inspection Phase 3 Boundary
- `inspection/recheck` is the only new Phase 3 app-facing inspection handoff.
- That handoff remains outside the current first-release frontend happy-path
  acceptance bundle.
- Current first-release frontend acceptance may stop at successful
  `inspection/submit` with the controlled server-returned projection.
- `BFF` may forward `inspectionId`, normalize auth, and shape the minimum
  success or failure response only.
- `BFF` must not invent inspection workflow states, rectification counters, or
  governance-side projections.
- Success handling stays limited to controlled handoff of the returned
  `inspectionId`, `milestoneId`, `state`, and `summary`.
- Failure handling stays limited to controlled propagation of:
  - `INSPECTION_ENTRY_UNAVAILABLE`
  - `INSPECTION_INVALID_STATE`
  - `INSPECTION_RECHECK_INVALID`
  - `INSPECTION_RECHECK_LIMIT_REACHED`

## Rating Next-stage Boundary
- `rating/submit` is the only new app-facing rating handoff.
- That handoff remains outside the current first-release frontend happy-path
  acceptance bundle.
- Current first-release frontend acceptance may keep the rating side at the
  controlled `rating/entry` unavailable boundary and does not require
  `rating/submit` success.
- `BFF` may forward `orderId`, normalize auth, and shape the minimum success or
  failure response only.
- `BFF` must not create rating truth, invent rating workflow states, or expose
  review, moderation, detail, history, or list projections.
- Success handling stays limited to controlled handoff of the returned:
  - `ratingId`
  - `orderId`
  - `state`
  - `summary`
- Failure handling stays limited to controlled propagation of:
  - `RATING_ENTRY_UNAVAILABLE`
  - `RATING_SUBMIT_INVALID`
  - `RATING_INVALID_STATE`

## Order Current Continuation Boundary
- `GET /api/app/order/detail` remains the current active order container read
  path only.
- `BFF` may shape only the frozen `OrderDetailReadModel` and its embedded
  milestone continuation items.
- `BFF` may allow Flutter App to reuse the already frozen `orderId` only as a
  controlled local continuation context into the already existing canonical:
  - `GET /api/app/contract/detail`
  - `GET /api/app/rating/entry`
  - `POST /api/app/dispute/open`
- `BFF` must not:
  - freeze or emit a second order continuation model
  - add new contract, rating, or dispute carrier fields to `order/detail`
  - reinterpret `order/detail` as `dispute/withdraw` entry truth
  - expose `dispute/withdraw` from `order/detail` without an existing dispute
    carrier carrying `disputeId`
- `dispute/withdraw` also remains outside the current first-release frontend
  happy-path bundle.

## Instance Todo Boundary
- `message` currently consumes only the frozen `instance_todo` touchpoint
  carrier.
- `GET /api/app/message/index` is the current app-facing aggregation surface for
  `instance_todo` list/items in Flutter App.
- `GET /api/app/message/index` is a controlled projection carrier only; it is
  not a full `RegisteredInstanceEntryItem` exposure surface.
- `BFF` may consume the frozen `RegisteredInstanceEntryItem` registry only as an
  upstream contract truth used to shape the current `instance_todo` projection.
- That registry consumption is limited to:
  - aggregation
  - visibility trimming
  - frozen response shaping
  - frozen projection of already-approved `canonicalPath`, `requiredParams`,
    `consumerBuilding`, and `localEntryKey`
- `BFF` may:
  - project the minimum `instance_todo` item skeleton
  - project `routeTarget` only with:
    - `canonicalPath`
    - `localEntryKey`
    - `requiredParams`
    - `state`
    - `routeParams`
  - apply visibility trimming according to the existing `L1` permission truth
  - forward the frozen `routeTarget` only when it already points to an existing,
    signed instance entry
  - shape the response for Flutter App consumption
- `item.state` remains the minimum `instance_todo` pending-state carrier only.
- `routeTarget.state` remains the minimum registered-entry enabled-state
  carrier only.
- These two states belong to different layers and must not be mixed.
- `BFF` must not:
  - own a second registered-entry truth layer
  - create a second todo or message truth
  - preserve or emit the old `routeTarget.routeName` target contract
  - reinterpret `canonicalPath` as a local frontend route
  - reinterpret `localEntryKey` as a second app-facing path
  - invent unread / read lifecycle states
  - invent delivery-channel states
  - expand `routeTarget` to unfrozen pages or arbitrary deep links
  - expose governance dashboards, operator queues, or platform consoles
  - turn `GET /api/app/message/index` into a message center, station inbox,
    workbench, governance console, or control tower entry
  - add any new app-facing path for unified instance entry registration
  - become a route-generation engine or a second routing system
- The first batch of `instance_todo` object anchors remains limited to:
  - `contract`
  - `inspection`
  - `rating`
  - `dispute`
- The first batch of `actionKey` remains limited to:
  - `contract.confirm`
  - `contract.amend`
  - `inspection.submit`
  - `rating.submit`
  - `dispute.open`
  - `dispute.withdraw`

## Unified Registered Instance Entry Boundary
- The current `RegisteredInstanceEntryItem` registry is an `L2` contract truth
  only.
- `BFF` consumes that registry only to preserve the existing signed-entry
  boundary while shaping `instance_todo` output for Flutter App.
- `BFF` does not own:
  - a second entry registry truth
  - a second path inventory
  - a second navigation system
  - a second role-eligibility system
- `BFF` must not expand this capability into:
  - a new message path family
  - a workbench
  - a governance console
  - a route compiler
  - a local-entry orchestration engine

## Platform Pre-embed Guidance
- `platform.live.enabled`, `platform.geo.enabled`, and `platform.map.gaode.enabled` are config-driven only in Phase 0.
- `BFF` may expose normalized capability flags to the Flutter App shell, but must not expose unfinished user-facing flows.
