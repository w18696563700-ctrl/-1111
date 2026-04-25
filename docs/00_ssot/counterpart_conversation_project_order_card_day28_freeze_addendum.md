---
owner: Codex 总控
status: frozen
layer: L0-L5 addendum
scheduled_day: 2026-05-28
freeze_recorded_at_local: 2026-04-25
purpose: Freeze the bounded counterpart-conversation ProjectOrder business card expansion for messages and project communication.
---

# Counterpart Conversation ProjectOrder Card Day28 Freeze

## 1. Scope

This addendum admits one bounded expansion inside the existing `counterpart_conversation` container:

- `project_order` may appear as a business card in `projectGroups[].cards[]`.
- The messages list may use `summary.latestCardType = project_order`.
- The project communication page may open the order carrier through `order_detail.open`.
- Every order card must anchor to both `projectId` and `orderId`.

This addendum does not create a new conversation type, order state machine, or message-owned order truth.

## 2. Current Minimum Closure

- `GET /api/app/message/interactions` remains the single messages entry.
- `interactionType` remains `counterpart_conversation`.
- `GET /api/app/message/counterpart-conversation/detail` remains the single detail container.
- `projectGroups[]` remains sliced by `projectId`.
- The order card opens the existing order carrier:
  - `objectType = order`
  - `actionKey = order_detail.open`
  - `canonicalPath = /api/app/order/detail`
  - `params.projectId`
  - `params.orderId`

The steadier option is this narrow card expansion because it reuses the existing `ProjectOrder` truth and route family. The cheaper option is keeping only `orderSummary`; that is already partially done but does not satisfy the Day28 "business card" requirement. The riskier option is creating a separate order thread or a new counterpart order status machine, and it remains forbidden.

## 3. Field Addendum

`CounterpartConversationBusinessCard.cardType` now additionally admits:

- `project_order`

`CounterpartConversationTruthAnchor.truthType` now additionally admits:

- `project_order`

`truthAnchor` for `project_order` must include:

- `projectId`
- `orderId`

`CounterpartConversationProjectGroup.orderSummary` remains an optional display accelerator and may include:

- `orderId`
- `projectId`
- `buyerOrganizationId`
- `sellerOrganizationId`
- `state`
- `completionRequestState`

`orderSummary` is not a replacement for the `project_order` business card when the server intends to expose an actionable order entry.

## 4. Route Addendum

The following registered entry is admitted for counterpart conversation detail card handoff:

| objectType | actionKey | canonicalPath | required params |
|---|---|---|---|
| `order` | `order_detail.open` | `/api/app/order/detail` | `projectId + orderId` |

The route opens the existing Flutter order detail page with `orderId`. `projectId` is still mandatory in the route target because the card lives inside a project-sliced conversation container and the truth anchor must remain auditable.

## 5. BFF Boundary

- BFF may validate and pass through `project_order` cards.
- BFF may validate and pass through `orderSummary`.
- BFF must fail closed on an order card missing `truthAnchor.projectId`, `truthAnchor.orderId`, `detailRouteTarget.params.projectId`, or `detailRouteTarget.params.orderId`.
- BFF must not decide order state, completion eligibility, or rating eligibility.

## 6. Flutter Boundary

- Flutter may render `project_order` as a normal counterpart business card.
- Flutter may open `order_detail.open` through the existing registered route.
- Flutter may continue showing the separate `OrderStatusCard` when `orderSummary` or a rating order anchor exists.
- Flutter must not infer completed state, eligibility, or final role permissions from the message card.

## 7. Need To Keep But Not Open

- No standalone `order_thread`.
- No generic message order center.
- No merged cross-project order status.
- No local order completion state.
- No Server direct call from Flutter.

## 8. Later Extension Slot

If later needed, `project_order` can be extended with a richer read model by Server/BFF, but only by adding a new frozen projection. The extension must still keep `ProjectOrder` as Server truth and must keep `projectId/orderId` on every action.

## 9. Stage Gate

Passed gates:

- Single messages entry is preserved.
- Project grouping is preserved.
- Order truth remains Server-owned.
- BFF remains a shaping and validation layer.
- Flutter remains BFF-only.

Veto gates:

- Do not introduce an order conversation state machine.
- Do not drop `projectId`.
- Do not accept `project_order` without `orderId`.
- Do not claim cloud release or dual-account UAT from local source changes.

Decision:

- Go for bounded BFF and Flutter implementation of the Day28 ProjectOrder business card.
- No-Go for production acceptance until Aliyun BFF/Server are aligned and dual-account tunnel UAT passes.
