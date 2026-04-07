---
owner: Codex 总控
status: draft
purpose: Freeze Flutter App shell and building route map.
layer: L3 Frontend
---

# Flutter Screen Map

## Shell Structure
- `shell/boot`
- `shell/guards`
- `shell/navigation`
- `shell/context`

## Visible Buildings in First Release
- `features/exhibition`
- `features/messages`
- `features/profile`

## Hidden Building Pre-embeds
- `features/renovation`
- `features/custom_furniture`

## Exhibition Building Internal Modules
- `showcase`
- `workbench`
- `forum`
- `project`
- `bidding`
- `order`
- `contract`
- `milestone`
- `inspection`
- `rating_dispute`

## Exhibition Ordered-home Override Rule
- `docs/00_ssot/exhibition_home_ordered_marketplace_unified_addendum.md` now
  owns the first-screen truth for `exhibition`.
- `/exhibition` must now be interpreted as the ordered province marketplace
  home, not as a split-entry hub.
- The current first screen must always expose:
  - top-left location button
  - adjacent refresh button
  - six fixed module containers
  - province-scoped ordered recommendation sections
  - publish-project and return-to-top actions
- `/exhibition/showcase` remains the project-display module page under the home.
- `/exhibition/workbench` remains the private continuation face; it no longer
  owns home first-screen explanation or public discovery layout.
- `forum` remains inside `exhibition`, but it is now one of the six fixed home
  module containers rather than a hidden side concept.
- No new bottom tab is allowed for this override.
- Until dedicated home, showcase, and publish contract families are frozen:
  - the project recommendation section may temporarily reuse
    `GET /api/app/project/list`
  - project detail handoff may temporarily reuse `GET /api/app/project/detail`
  - the private continuation face may continue to reuse
    `GET /api/app/exhibition/workbench`
  - the current publish route may still bridge through
    `POST /api/app/project/create`
- Downstream project, bid, order, contract, milestone, inspection, rating, and
  dispute pages remain valid; they are just no longer the defining behavior of
  the exhibition home itself.

## Messages Building Current-stage Consumption Boundary
- `messages` currently consumes only the frozen `instance_todo` touchpoint
  carrier.
- `messages` currently consumes that touchpoint through
  `GET /api/app/message/index`.
- `messages` may show only:
  - a controlled todo list or empty state
  - the frozen todo title and summary
  - a controlled jump to an existing, signed instance entry via `routeTarget`
- `messages` currently consumes `routeTarget` only as the frozen structure:
  - `canonicalPath`
  - `localEntryKey`
  - `requiredParams`
  - `state`
  - `routeParams`
- `messages` must not show:
  - a general-purpose message center
  - station inbox / conversation threads
  - unread / read management surfaces
  - push, SMS, or email delivery controls
  - cross-object dashboard or workbench panels
  - governance console, platform queue, or control tower surfaces
- `messages` routeTarget consumption is limited to existing signed instance
  entry paths only; it must not invent new routes or arbitrary deep links.
- `GET /api/app/message/index` is the current canonical list/items surface only;
  it must not be reinterpreted as a message center, station inbox, workbench,
  governance console, or new path expansion.
- The old `routeTarget.routeName` target contract has exited the formal
  `messages` consumption boundary and must not be used as a current target
  description here.
- The first batch of allowed `objectType` remains:
  - `contract`
  - `inspection`
  - `rating`
  - `dispute`
- The first batch of allowed `actionKey` remains:
  - `contract.confirm`
  - `contract.amend`
  - `inspection.submit`
  - `rating.submit`
  - `dispute.open`
  - `dispute.withdraw`

## Unified Registered Instance Entry Consumption Boundary
- The current allowed buildings participating in registered instance entry
  consumption are:
  - `messages`
  - `exhibition`
- `messages` is the current consumer-facing building for registered entry list/items.
- `exhibition` remains the existing signed-instance-entry building that hosts the
  already-approved destination pages.
- The following buildings are not allowed to consume registered instance entry
  rows in the current frozen boundary:
  - `renovation`
  - `custom_furniture`
  - `profile`
  - `admin`
- `canonicalPath -> localEntryKey` is a controlled consumer boundary only.
- `canonicalPath` remains the app-facing canonical entry reference.
- `localEntryKey` remains a frontend-local stable consumer key only.
- `requiredParams` remains the frozen minimum parameter shape only.
- `routeTarget.state` remains the registered-entry minimum enabled state only.
- `item.state` remains the `instance_todo` minimum pending state only.
- These two states are not the same layer and must not be mixed.
- Neither field may be reinterpreted here as:
  - a new local route path
  - a global navigation tree node
  - a page layout metadata slot
  - a workbench or governance console route
- The current frozen consumer-side boundary is:
  - `/api/app/contract/detail`
    - `registered.contract.confirm`
    - `registered.contract.amend`
  - `/api/app/inspection/detail`
    - `registered.inspection.submit`
  - `/api/app/rating/entry`
    - `registered.rating.submit`
  - `/api/app/order/detail`
    - `registered.dispute.open`
    - `registered.dispute.withdraw`
- These registrations may be consumed only through already-existing signed
  instance-entry pages inside existing buildings.
- They must not expand into:
  - a new navigation tree
  - a new page family
  - a workbench
  - a governance console
  - a control tower
  - a cross-object dashboard

## Messages Current Page Map
| Route | Page name | Building | Phase | Responsibility | Delivery level | Canonical path | Out of scope |
|---|---|---|---|---|---|---|---|
| `/messages` | 消息楼实例待办入口 | messages | Current stage | consume the minimum `instance_todo` list/items projection and expose only controlled handoff to existing signed instance entries | minimal controlled list/items consumer | `GET /api/app/message/index` | no message center, no station inbox, no unread/read lifecycle, no push/SMS/email controls, no dashboard or governance console |

## Exhibition Phase 2A Page Map
| Route | Page name | Building | Phase | Responsibility | Delivery level | Canonical path | Out of scope |
|---|---|---|---|---|---|---|---|
| `/exhibition` | 展览秩序化首页 | exhibition | Phase 2A override | host the ordered province marketplace home with location and refresh controls, six fixed module containers, ordered recommendation sections, and controlled handoff into publish or take-task flows | minimum ordered marketplace home | current first-batch project recommendation section may temporarily reuse `GET /api/app/project/list`; the other five home containers may remain controlled province-scoped placeholders until dedicated home aggregation contracts freeze | no mixed public-private dashboard, no long publish form on the home page, no national mixed feed, no order or fulfillment control surfaces, no governance console |
| `/exhibition/showcase` | 项目展示模块页 | exhibition | Phase 2A override | host the dedicated project-display module page and route from project recommendations into project discovery and project detail | minimum public project module consumer | temporary module carrier reuses `GET /api/app/project/list` and `GET /api/app/project/detail` until dedicated showcase contracts freeze | no ownership of the exhibition home first screen, no private workbench continuation, no order truth, no fulfillment dashboard, no governance console |
| `/exhibition/workbench` | 项目工作台入口 | exhibition | Phase 2A override | host the private continuation face for current project follow-up, my-project context, current create entry, and existing downstream trade or fulfillment continuation | minimum private continuation consumer | `GET /api/app/exhibition/workbench` | no public project display list semantics, no second workbench state machine, no exhibition-home first-screen ownership, no governance console |
| `/exhibition/projects` | 项目列表 | exhibition | Phase 2A override | consume project list aggregation for the project-display module and its controlled loading, empty, content, and error states | minimum consumer layer | `GET /api/app/project/list` | no invited-project collaboration flow, no second list-only project field model, no reinterpretation as the full exhibition-home aggregation |
| `/exhibition/projects/create` | 项目发布工作台 | exhibition | Phase 2A transition | host the dedicated five-step publish workbench transition, permission gate, and controlled submit feedback while current preview and commit contracts are still syncing | minimum publish-workbench transition consumer | current create carrier still reuses `POST /api/app/project/create`; file materials continue to bridge through `POST /api/app/file/upload/init` and `POST /api/app/file/upload/confirm` until dedicated preview, payment, and publish-commit contracts freeze | no long form on the home page, no older review-first publish path, no full `Project` success body, no second project publish state machine, no direct order conversion |
| `/exhibition/projects/detail` | 项目详情 | exhibition | Phase 2A override | consume project detail aggregation, show project materials, and expose the controlled take-task or bid handoff | minimum consumer layer | `GET /api/app/project/detail` | no bid compare, no order conversion flow, no contract details, no second detail-only project field model |
| `/exhibition/bids/submit` | 投标提交 | exhibition | Phase 2A | host the minimum bid submission entry and controlled submit feedback | minimum consumer layer and submit placeholder | `POST /api/app/bid/submit` | no full `Bid` success body, no bid compare, no shortlist or win-loss management, no order truth freeze |
| `/exhibition/orders/detail` | 订单详情 | exhibition | Phase 2A | consume order detail aggregation and use the existing `orderId` only as controlled local continuation context into already frozen canonical entries | minimum consumer layer | `GET /api/app/order/detail` | no acceptance workflow expansion, no `dispute/withdraw` continuation, no rating detail/history, no change-order flow, no second continuation model |
| `/exhibition/milestones` | 里程碑列表 | exhibition | Phase 2A | consume milestone list aggregation and controlled page states | minimum consumer layer | `GET /api/app/milestone/list` | no inspection or approval workflow implementation |
| `/exhibition/milestones/submit` | 里程碑提交 | exhibition | Phase 2A | host milestone submit entry and three-step upload consumption baseline | minimum consumer layer with upload placeholder | `POST /api/app/milestone/submit`, `POST /api/app/file/upload/init`, `POST /api/app/file/upload/confirm` | no full `Milestone` success body, no inspection close-loop, no evidence schema expansion, no server-side rule invention |

## Exhibition Ordered Home Boundary
- `/exhibition` now freezes only the minimum ordered province marketplace home.
- The frozen first-screen containers are:
  - top-left location button
  - adjacent refresh button
  - six fixed module containers
  - ordered province recommendation sections
  - publish-project action
  - return-to-top action
- The six fixed module containers are:
  - `项目展示`
  - `优秀公司`
  - `优秀工厂`
  - `优秀供应商`
  - `展览论坛`
  - `优秀团队员工`
- The first recommendation section may currently reuse
  `GET /api/app/project/list` as the project-display carrier.
- The other five module containers may remain controlled placeholders in the
  current first batch, but their visible containers and click entries must
  already exist.
- Home recommendations are province-scoped only.
- Province switching and refresh must update the full current home state
  together.
- The home page may hand off only into:
  - `showcase`
  - `project/detail`
  - `project/create`
  - `workbench`
- The home page must not become:
  - a long publish form
  - a private continuation summary board
  - an order, contract, fulfillment, inspection, or dispute dashboard
  - a random mixed national feed

## Exhibition Private Continuation Boundary
- `GET /api/app/exhibition/workbench` no longer owns `/exhibition`
  first-screen truth.
- It currently freezes only the minimum private continuation summary
  projection.
- The frozen private containers are:
  - `project_chain`
  - `order_chain`
  - `fulfillment_chain`
  - `extension_boundary`
- `project_chain` may expose only:
  - recent private project context
  - open current publish entry
  - open my-project continuation
  - explicitly hand off to the public project-display module when requested
- `project_chain` must hide:
  - bid submit from the private summary itself
  - publish or award controls
  - collaboration controls
  - second project workbench states
- `order_chain` may expose only:
  - active order context
  - open order detail
  - open contract detail
  - open dispute-open entry
- `order_chain` must hide:
  - rating submit
  - dispute withdraw
  - contract history/list
  - second order workflow actions
- `fulfillment_chain` may expose only:
  - active milestone context
  - open milestone list
  - open milestone submit
  - open inspection detail
  - open inspection submit
- `fulfillment_chain` must hide:
  - inspection recheck
  - inspection list/history
  - governance queue
  - multi-round workflow consoles
- `extension_boundary` may expose only:
  - open contract detail
  - open dispute-open entry
  - controlled rating boundary state
  - frozen dispute-withdraw boundary state
- `extension_boundary` must hide:
  - rating submit
  - inspection recheck
  - dispute withdraw
  - rating/dispute detail, list, history, moderation, escalation, or governance
    surfaces
- Private continuation consumption must not become a second business owner, a
  second state machine, or a second continuation model.

## Project Current Read Boundary
- `GET /api/app/project/list` and `GET /api/app/project/detail` currently share the same frozen minimum `Project` read model.
- The current shared minimum read fields are:
  - `projectId`
  - `projectNo`
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `state`
  - `summary`
- `project/list` adds only the `items` carrier for loading, empty, content, and controlled jump states.
- `project/detail` consumes the same shared `Project` read model plus the existing route-carried `projectId`.
- The ordered exhibition home may temporarily reuse `project/list` for its
  first recommendation section only; that does not make `project/list` the full
  exhibition-home aggregation model.
- Frontend must not reinterpret these two read paths as separate list-vs-detail field models.
- Frontend must not expand the current boundary into invited-project collaboration, bid compare, order conversion, or contract-detail projections.

## Project Create Command Boundary
- `POST /api/app/project/create` currently freezes only the minimum command request and the minimum success continuation body.
- The frozen request fields are:
  - `title`
  - `buildingType`
  - `budgetAmount`
  - `description` optional
- The frozen success body field is:
  - `projectId`
- Frontend currently uses that `projectId` only to continue to the existing `project/detail` and `bid/submit` routes.
- The accepted ordered-marketplace translation for the current page is a
  dedicated five-step publish workbench transition:
  - `基础信息`
  - `地址与范围`
  - `文件资料`
  - `文字说明与 AI 辅助`
  - `预览、支付与一键发布`
- This five-step guidance is the current page-structure truth only until
  dedicated preview, payment, and publish-commit contracts are frozen.
- The current page may collect or guide only:
  - `title`
  - `buildingType`
  - `budgetAmount`
  - schedule or time-node guidance
  - province, city, and region selection guidance
  - precise text address guidance
  - PDF effect-drawing and construction-drawing upload guidance
  - `description`
  - AI-assist entry guidance
- Frontend may explain the continuation order after current create success as:
  - supplement display materials through the existing upload chain
  - review the current project detail
  - continue into the minimum bidding face
- Frontend must not reinterpret `project/create` success as a full `Project` read projection.
- Frontend must not expand this command boundary into bid submission truth, order handoff truth, or a second project-success field model.
- Frontend must not reinterpret the five-step guidance as:
  - a dedicated `ProjectShowcase` write model
  - a second project publish state machine
  - a new attachment-truth family outside the existing upload chain
- Frontend must not reinterpret the page as:
  - the older review-first `提交审核` publish path
  - a paid-order truth owner
  - a local 48-hour countdown state machine

## Bid Submit Command Boundary
- `POST /api/app/bid/submit` currently freezes only the minimum command request and the minimum success continuation body.
- The frozen request fields are:
  - `projectId`
  - `quoteAmount`
  - `proposalSummary`
- The frozen success body field is:
  - `bidId`
- Frontend currently uses that `bidId` only to continue to the existing `order/create` route.
- The accepted V1.1 supplement translation for the current page is the minimum
  bidding continuation face only.
- The current page may explain and collect only:
  - `quoteAmount`
  - `proposalSummary`
  - current submit feedback
  - controlled order handoff continuation
- Frontend must not reinterpret `bid/submit` success as a full `Bid` read projection.
- Frontend must not expand this command boundary into bid compare truth, shortlist or win-loss management, or order truth.
- Frontend must not reinterpret the page as:
  - `BidWorkspace`
  - `MyBidEntry`
  - `BidDecision`
  - `BidRejection`
  - result-transparency or compare consoles

## Order Create Command Boundary
- `POST /api/app/order/create` currently freezes only the minimum command request and the minimum success continuation body.
- The frozen request field is:
  - `bidId`
- The frozen success body fields are:
  - `orderId`
  - `milestones[0].milestoneId` when a continuation milestone is present
- Frontend currently uses `orderId` to continue to the existing `order/detail` and `milestone/list` routes.
- Frontend currently uses only the first continuation `milestoneId` to continue to the existing `milestone/submit` route when that milestone is present.
- Frontend must not reinterpret `order/create` success as a full `Order` read projection.
- Frontend must not expand this command boundary into milestone workflow truth, order accept truth, fulfillment state-machine truth, or a second order-success field model.

## Order Current Read Boundary
- `GET /api/app/order/detail` currently freezes only the minimum `Order` read model required by the Flutter App consumer and current page continuation.
- The frozen order fields are:
  - `orderId`
  - `orderNo`
  - `projectId`
  - `bidId`
  - `state`
  - `summary`
  - `milestones`
- The embedded continuation milestone fields under `milestones[]` are:
  - `milestoneId`
  - `orderId`
  - `title`
  - `amount`
  - `state`
  - `summary`
- Frontend currently uses `orderId` to continue to the existing `milestone/list`, `contract/detail`, `rating/entry`, and `dispute/open` routes.
- Frontend uses that continuation only as local navigation into already frozen canonical entries; it does not freeze a new response carrier for contract, rating, or dispute.
- `dispute/withdraw` does not continue from `order/detail`; it still requires an existing dispute instance carrier with `disputeId`.
- Frontend currently uses embedded milestone `milestoneId` and `title` to render continuation buttons into the existing `milestone/submit` route.
- These embedded milestone item fields are the same current minimum milestone item fields used by `GET /api/app/milestone/list`.
- Frontend must not expand this read boundary into inspection, rating, dispute, contract, or a second `Order` continuation field model.

## Milestone Current List Boundary
- `GET /api/app/milestone/list` currently freezes only the minimum list carrier and milestone item fields required by the Flutter App consumer.
- The frozen query field is:
  - `orderId`
- The frozen list carrier field is:
  - `items`
- The frozen milestone item fields under `items[]` are:
  - `milestoneId`
  - `orderId`
  - `title`
  - `amount`
  - `state`
  - `summary`
- Frontend currently uses `items[]` only to render milestone continuation actions into the existing `milestone/submit` and `inspection/detail` routes.
- Frontend does not currently require top-level `orderId`, top-level `summary`, or any second list carrier fields for `milestone/list` content rendering.
- Frontend must not expand this list boundary into inspection truth, approval truth, evidence truth, or a second standalone milestone workflow model.

## Milestone Submit Command Boundary
- `POST /api/app/milestone/submit` currently freezes only the minimum command request and the minimum success continuation body.
- The frozen request fields are:
  - `milestoneId`
  - `submissionNote` optional
- The frozen success body field is:
  - `milestoneId`
- Frontend currently uses that `milestoneId` only to continue to the existing `inspection/detail` route while preserving the same milestone context.
- Frontend must not reinterpret `milestone/submit` success as a full `Milestone` read projection.
- Frontend must not expand this command boundary into inspection workflow truth, approval flow, or a second milestone-success field model.

## Exhibition Phase 2.3 Entry Page Map
| Route | Page name | Building | Phase | Responsibility | Delivery level | Canonical path | Out of scope |
|---|---|---|---|---|---|---|---|
| `/exhibition/contracts/detail` | 合同入口详情 | exhibition | Phase 2.3 | consume contract entry aggregation and expose controlled contract entry state only | entry-state placeholder | `GET /api/app/contract/detail` | no clause schema, no signature workflow, no amendment flow |
| `/exhibition/contracts/confirm` | 合同确认入口 | exhibition | Phase 2.3 | host the minimum contract confirm entry action and controlled feedback | entry-state command placeholder | `POST /api/app/contract/confirm` | no structured clause editing, no signature or legal review flow |
| `/exhibition/ratings/entry` | 评价入口 | exhibition | Phase 2.3 | expose the rating entry state only and prepare controlled handoff | entry-state placeholder | `GET /api/app/rating/entry` | no full scoring model, no visibility rules, no moderation flow |
| `/exhibition/disputes/open` | 争议开启入口 | exhibition | Phase 2.3 | host the minimum dispute-open entry action and controlled feedback | entry-state command placeholder | `POST /api/app/dispute/open` | no negotiation, no platform review, no escalation or resolution flow |
| `/exhibition/disputes/withdraw` | 争议撤回入口 | exhibition | Next stage | host the minimum dispute-withdraw action and controlled feedback from an existing opened dispute instance only | entry-state command placeholder | `POST /api/app/dispute/withdraw` | no detail, no list, no resolution, no escalation, no history, no governance console |

The `inspection/detail` and `inspection/submit` route responsibilities are now
governed only by the Phase 3 minimum Inspection workflow map below. They are no
longer active Phase 2.3 route-responsibility truth in this screen map.

The `contract/detail` and `contract/confirm` route responsibilities are now
governed only by the Phase 3 minimum Contract workflow map below. They are no
longer active Phase 2.3 route-responsibility truth in this screen map.

The `rating/entry` route responsibility is now governed by the next-stage
minimum Rating workflow map below. The old Phase 2.3 entry-only placeholder is
no longer the current effective route-responsibility truth for the next planned
Rating round.

## Exhibition Contract Phase 3 Page Map
| Route | Page name | Building | Phase | Responsibility | Delivery level | Canonical path | Out of scope |
|---|---|---|---|---|---|---|---|
| `/exhibition/contracts/detail` | 合同闭环详情 | exhibition | Phase 3 | consume the minimum contract workflow projection and display the current server-returned contract state only | minimal workflow read page | `GET /api/app/contract/detail` | no clause editor, no sign flow, no legal review, no history/list/reporting |
| `/exhibition/contracts/confirm` | 合同确认 | exhibition | Phase 3 | host the first contract workflow handoff and controlled feedback for confirmation only | minimal workflow command page | `POST /api/app/contract/confirm` | no clause editor, no sign flow, no legal review |
| `/exhibition/contracts/amend` | 合同改单提交 | exhibition | Phase 3 | host the single allowed amendment handoff after contract activation only | minimal workflow command page | `POST /api/app/contract/amend` | no multi-version amendment system, no sign flow, no history/list/reporting |

## Contract Phase 3 Consumption Boundary
- Frontend may show only:
  - the current server-returned contract state
  - the minimum `summary`
  - the currently available confirm or amend action
  - controlled success and failure containers
- Frontend must not show:
  - clause editor surfaces
  - sign workflow UI
  - legal review panels
  - contract history or list views
  - reporting dashboards
  - cross-object Phase 3 expansion surfaces
- `contract/amend` enters only from the controlled active-contract path; it is
  not a free-form route for repeated amendments.
- Success handling:
  - `contract/confirm` success returns to controlled content using the
    server-returned projection.
  - `contract/amend` success returns to controlled content using the
    server-returned `amended` projection.
- Failure handling:
  - `CONTRACT_ENTRY_UNAVAILABLE`
  - `CONTRACT_CONFIRM_INVALID`
  - `CONTRACT_INVALID_STATE`
  - `CONTRACT_AMEND_INVALID`
  - `CONTRACT_AMEND_LIMIT_REACHED`
  all resolve through the existing controlled failure contract and must not
  create list, history, sign, or legal-review states.

## Exhibition Rating Next-stage Page Map
| Route | Page name | Building | Phase | Responsibility | Delivery level | Canonical path | Out of scope |
|---|---|---|---|---|---|---|---|
| `/exhibition/ratings/entry` | 评价入口 | exhibition | Next stage | consume the minimum rating workflow projection only; current first-release frontend acceptance may still stop at controlled unavailable on this page | minimal workflow read page | `GET /api/app/rating/entry` | not part of the current first-release happy-path, no rating detail, no history/list, no moderation, no review workflow |
| `/exhibition/ratings/submit` | 评价提交 | exhibition | Next stage | host the single allowed rating submit handoff for an existing draft rating only in a separately approved extension round | minimal workflow command page | `POST /api/app/rating/submit` | outside the current first-release happy-path, no truth creation, no score-model editing, no resubmit flow, no moderation |

## Rating Next-stage Consumption Boundary
- Frontend may show only:
  - the current server-returned rating state
  - the minimum `summary`
  - the currently available submit action
  - controlled success and failure containers
- `rating/entry -> rating/submit` is not part of the current first-release
  frontend happy-path bundle.
- Current first-release frontend acceptance may remain at controlled
  `RATING_ENTRY_UNAVAILABLE` on `rating/entry` and still count as acceptable for
  the current release-happy-path scope.
- Frontend must not show:
  - rating detail or history pages
  - moderation or review panels
  - list or reporting dashboards
  - cross-object expansion surfaces
- `rating/submit` enters only from the controlled completed-order path with an
  existing persisted draft rating truth; it is not a create flow or resubmit
  flow.
- Success handling:
  - `rating/submit` success returns to controlled content using the
    server-returned `submitted` projection.
- Failure handling:
  - `RATING_ENTRY_UNAVAILABLE`
  - `RATING_SUBMIT_INVALID`
  - `RATING_INVALID_STATE`
  all resolve through the existing controlled failure contract and must not
  expand into detail, history, moderation, or review states.

## Exhibition Dispute Next-stage Page Map
| Route | Page name | Building | Phase | Responsibility | Delivery level | Canonical path | Out of scope |
|---|---|---|---|---|---|---|---|
| `/exhibition/disputes/withdraw` | 争议撤回入口 | exhibition | Next stage | host the single allowed withdraw handoff for an existing opened dispute instance only | minimal workflow command page | `POST /api/app/dispute/withdraw` | no detail, no list, no resolution, no escalation, no history, no platform governance console |

## Dispute Next-stage Consumption Boundary
- Frontend may show only:
  - the current server-returned dispute state
  - the minimum `summary`
  - the currently available `open` or `withdraw` action
  - controlled success and failure containers
- Current first-release frontend happy-path does not include
  `dispute/withdraw`.
- Frontend must not show:
  - dispute detail or history pages
  - list or reporting dashboards
  - escalation, resolution, or governance workflow panels
  - platform-side adjudication controls
- `dispute/withdraw` enters only from an existing opened dispute instance
  action path; it is not a free-form detail, list, or governance route.
- Success handling:
  - `dispute/open` and `dispute/withdraw` success resolve to controlled content
    using the server-returned projection only.
- Failure handling:
  - `DISPUTE_OPEN_INVALID`
  - `DISPUTE_WITHDRAW_INVALID`
  - `DISPUTE_INVALID_STATE`
  all resolve through the existing controlled failure contract and must not
  expand into detail, history, escalation, resolution, or governance states.

## Exhibition Inspection Phase 3 Page Map
| Route | Page name | Building | Phase | Responsibility | Delivery level | Canonical path | Out of scope |
|---|---|---|---|---|---|---|---|
| `/exhibition/inspections/detail` | 验收闭环详情 | exhibition | Phase 3 | consume the minimum inspection workflow projection and display the current server-returned inspection state only | minimal workflow read page | `GET /api/app/inspection/detail` | no inspection list, no history page, no governance queue, no platform decision console |
| `/exhibition/inspections/submit` | 验收提交 | exhibition | Phase 3 | host the initial inspection submit action and controlled feedback for the first submission only | minimal workflow command page | `POST /api/app/inspection/submit` | no decision matrix UI, no buyer-side governance panels |
| `/exhibition/inspections/recheck` | 整改后复检提交 | exhibition | Phase 3 | host the single allowed rectification recheck handoff for supplier-side resubmission only in a separately approved extension round | minimal workflow command page | `POST /api/app/inspection/recheck` | outside the current first-release happy-path, no multi-round console, no list/history, no platform adjudication, no cross-object expansion |

## Inspection Phase 3 Consumption Boundary
- Frontend may show only:
  - the current server-returned inspection state
  - the minimum `summary`
  - the currently available submit or recheck action
  - controlled success and failure containers
- `inspection/recheck` is not part of the current first-release frontend
  happy-path bundle.
- Current first-release frontend acceptance may stop at successful
  `inspection/submit` on the fresh chain and the controlled returned
  projection.
- Frontend must not show:
  - inspection list or history views
  - governance review panels
  - platform-side decision controls
  - multi-round rectification consoles
  - cross-object dashboards or Phase 3 expansion surfaces
- `inspection/recheck` enters only from the controlled supplier-side
  rectification path; it is not a free-form route for arbitrary retries.
- Success handling:
  - `inspection/submit` success returns to controlled content using the
    server-returned projection.
  - `inspection/recheck` success returns to controlled content using the
    server-returned `rechecked` projection.
- Failure handling:
  - `INSPECTION_ENTRY_UNAVAILABLE`
  - `INSPECTION_INVALID_STATE`
  - `INSPECTION_RECHECK_INVALID`
  - `INSPECTION_RECHECK_LIMIT_REACHED`
  all resolve through the existing controlled failure contract and must not
  expand into custom governance states.
- `dispute/withdraw` also remains outside the current first-release frontend
  happy-path scope even though its separate next-stage page truth stays frozen.

## Routing Rules
- Hidden buildings must keep route registrations and unavailable-entry placeholders.
- `messages` currently consumes only `instance_todo` touchpoints through
  `GET /api/app/message/index` and may jump only to existing signed
  instance-entry routes.
- `messages` consumes the frozen `routeTarget` structure only through
  `canonicalPath -> localEntryKey` controlled mapping and must not reinterpret
  `canonicalPath` as a Flutter-local route.
- `messages` does not edit truth directly.
- `profile` hosts the compact current-user hub, bounded company and identity detail, certification, one bounded `我的项目` entry handoff, one first-level `我的论坛` handoff, and bottom-anchored settings.
- The `我的项目` handoff does not make `profile` the project truth owner; it remains an entry-side building carrier only.
- Exhibition Phase 2A pages stay in the pre-trade half-flow consumer boundary only.
- Exhibition Phase 2A pages must consume app-facing canonical paths only and must not call `Server` directly.
- Exhibition Phase 2.3 pages freeze entry-state placeholders only; they must not promise
  full post-delivery workflows before downstream truth is frozen.
- Exhibition Phase 3 currently reopens only the minimum `inspection`
  self-workflow boundary; it must not expand into list, history, governance
  extensions, or multi-round consoles.
