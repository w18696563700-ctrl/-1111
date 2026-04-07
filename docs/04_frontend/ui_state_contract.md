---
owner: Codex 总控
status: draft
purpose: Freeze Flutter App UI state consumption and non-domain view state mapping.
layer: L3 Frontend
---

# UI State Contract

## Global Shell States
- booting
- unauthenticated
- session_refreshing
- no_organization
- hidden_building_unavailable
- offline
- maintenance

## Page States
- loading
- empty
- content
- error_retryable
- error_non_retryable
- unauthorized
- forbidden
- not_found

## Upload States
- local_validating
- signed_ready
- uploading
- upload_failed_retryable
- upload_confirming
- upload_confirm_failed
- upload_bound

## Rules
- Flutter App consumes server states and maps them to UI states.
- Flutter App must not invent domain states.
- Hidden building pages must resolve to controlled unavailable states, not missing routes.
- `CONTRACT_ENTRY_UNAVAILABLE` maps to `error_non_retryable` in the current formal
  page-state contract.
- `CONTRACT_CONFIRM_INVALID` maps to `error_non_retryable` in the current formal
  page-state contract.
- `CONTRACT_INVALID_STATE` maps to `error_non_retryable` in the current formal
  page-state contract.
- `CONTRACT_AMEND_INVALID` maps to `error_non_retryable` in the current formal
  page-state contract.
- `CONTRACT_AMEND_LIMIT_REACHED` maps to `error_non_retryable` in the current formal
  page-state contract.
- `INSPECTION_ENTRY_UNAVAILABLE` maps to `error_non_retryable` in the current formal
  page-state contract.
- `INSPECTION_INVALID_STATE` maps to `error_non_retryable` in the current formal
  page-state contract.
- `INSPECTION_RECHECK_INVALID` maps to `error_non_retryable` in the current formal
  page-state contract.
- `INSPECTION_RECHECK_LIMIT_REACHED` maps to `error_non_retryable` in the current formal
  page-state contract.
- `RATING_ENTRY_UNAVAILABLE` maps to `error_non_retryable` in the current formal
  page-state contract.
- `RATING_SUBMIT_INVALID` maps to `error_non_retryable` in the current formal
  page-state contract.
- `RATING_INVALID_STATE` maps to `error_non_retryable` in the current formal
  page-state contract.
- `DISPUTE_OPEN_INVALID` maps to `error_non_retryable` in the current formal
  page-state contract.
- `DISPUTE_WITHDRAW_INVALID` maps to `error_non_retryable` in the current formal
  page-state contract.
- `DISPUTE_INVALID_STATE` maps to `error_non_retryable` in the current formal
  page-state contract.
- `instance_todo` list consumption may resolve to:
  - `loading`
  - `empty`
  - `content`
  - `error_retryable`
  - `error_non_retryable`
- `GET /api/app/message/index` is the current `messages` building carrier for
  the frozen `instance_todo` list/items result above; Flutter App must not
  reinterpret it as a conversation lifecycle, unread/read surface, or a second
  navigation truth.
- `GET /api/app/message/index` carries a controlled projection only; it is not
  a full `RegisteredInstanceEntryItem` exposure surface.
- The formal `routeTarget` structure for this carrier is now fixed to:
  - `canonicalPath`
  - `localEntryKey`
  - `requiredParams`
  - `state`
  - `routeParams`
- The old `routeTarget.routeName` target contract has exited the formal UI
  state boundary and must not be used as a current field semantic.
- `item.state` remains the minimum `instance_todo` pending-state carrier only.
- `routeTarget.state` remains the minimum registered-entry enabled-state
  carrier only.
- These two states belong to different semantic layers and must not be mixed.
- Registered instance entry consumption must not introduce a second entry-state
  machine.
- Registered instance entry consumption must remain inside the existing page
  state set only.
- If a registered item cannot be consumed because the referenced
  `canonicalPath`, `localEntryKey`, `requiredParams`, `routeTarget.state`,
  `consumerBuilding`, or signed-entry boundary is missing, invalid, frozen-out,
  or out of scope, the UI must resolve to `error_non_retryable`.
- A frozen `routeTarget` that is no longer consumable as an existing signed
  instance entry must resolve to `error_non_retryable`; Flutter App must not
  invent fallback deep links or a second navigation truth.
- A registered entry row that points outside the allowed building set or outside
  the frozen first batch must resolve to `error_non_retryable`.
- `instance_todo` currently has no unread / read state machine, no grouped
  thread state, and no delivery-channel UI lifecycle.
- Registered instance entry consumption currently has no:
  - workbench state
  - governance-console state
  - multi-route orchestration state
  - layout-metadata state
- Successful `GET /api/app/exhibition/workbench` resolves to controlled
  `content` rendering from the frozen summary projection only.
- The workbench summary currently freezes only:
  - `project_chain`
  - `order_chain`
  - `fulfillment_chain`
  - `extension_boundary`
- These containers are homepage summary carriers only; Flutter App must not
  reinterpret them as domain-truth states or a second dashboard state machine.
- `extension_boundary.ratingEntryState` and
  `extension_boundary.disputeWithdrawState` are boundary-state carriers only;
  they do not authorize `rating/submit`, `inspection/recheck`, or
  `dispute/withdraw` as homepage actions.
- Successful `rating/submit` resolves to controlled `content` rendering from the
  server-returned projection only; Flutter App must not invent detail, history,
  moderation, or review workflow states.
- Current first-release frontend happy-path acceptance does not require
  `rating/submit` success.
- Current first-release frontend acceptance may still stop at
  `RATING_ENTRY_UNAVAILABLE -> error_non_retryable` on `rating/entry`.
- Successful `inspection/submit` and `inspection/recheck` resolve to controlled
  `content` rendering from the server-returned projection only; Flutter App
  must not invent list, history, governance, or multi-round workflow states.
- Current first-release frontend happy-path acceptance ends at successful
  `inspection/submit` controlled content; `inspection/recheck` success is
  reserved for a separately approved extension round and is not required for
  the current first-release happy path.
- Successful `order/detail` content may use the already frozen `orderId` only
  as controlled local continuation context into the existing
  `contract/detail`, `rating/entry`, and `dispute/open` pages.
- That continuation rule does not freeze a second `Order` continuation model,
  and Flutter App must not infer `dispute/withdraw` entry from `order/detail`
  alone without an existing dispute carrier carrying `disputeId`.
- `dispute/withdraw` also remains outside the current first-release frontend
  happy-path scope.
