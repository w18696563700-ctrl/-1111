---
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-05-18
purpose: Freeze the state machines for bid selection, project order completion, rating, and credit bridge.
---

# 项目交易链路状态机

## 1. Project

| From | To | Trigger | Owner |
|---|---|---|---|
| `published` | `converted_to_order` | `BidAwardWriteService.award` succeeds | Server |

Notes:

- `awarded` may remain a historical/intermediate label, but the accepted production continuation state is `converted_to_order`.
- A converted project must have exactly one effective `ProjectOrder`.

## 2. Bid

| From | To | Trigger | Owner |
|---|---|---|---|
| `submitted` | `awarded` | current bid is winning bid | Server |
| `submitted` | `lost` | another bid wins same project | Server |

Rules:

- All bids under the target project are locked in the award transaction.
- Buyer organization cannot award its own bid.
- A project can have only one effective winning bid.

## 3. ProjectOrder

| From | To | Trigger | Owner |
|---|---|---|---|
| none | `active` | bid award creates order | Server |
| `active` | `completed` | all current milestones completed after inspection pass, or buyer confirms seller completion request | Server |
| `active` | `cancelled` | reserved future cancellation command | Server |
| `completed` | `completed` | idempotent read/re-pass of already completed chain | Server |
| `cancelled` | `cancelled` | idempotent cancelled read | Server |

Rules:

- `ProjectOrder` must always carry `projectId / buyerOrganizationId / sellerOrganizationId`.
- `completedAt` must be set when `state = completed`.
- `completed` orders unlock counterparty rating.
- BFF and Flutter cannot mutate or derive this state.

Completion request substate:

| From | To | Trigger | Owner |
|---|---|---|---|
| `none` | `requested` | seller requests completion | Server |
| `requested` | `confirmed` | buyer confirms completion and `ProjectOrder.state -> completed` | Server |
| `requested` | `rejected` | buyer rejects completion request | Server |
| `requested` | `dispute_reserved` | buyer rejects and reserves dispute handoff | Server |
| `rejected` | `requested` | seller submits a later completion request | Server |
| `dispute_reserved` | `requested` | seller submits a later completion request after resolution | Server |

## 4. Fulfillment

| Object | From | To | Trigger |
|---|---|---|---|
| `Milestone` | `pending_submission` | `submitted` | supplier submits milestone |
| `Inspection` | `draft` | `submitted` | buyer submits inspection |
| `Inspection` | `submitted` | `passed` | buyer passes inspection |
| `Milestone` | `submitted` | `completed` | inspection pass succeeds |

Rules:

- Only supplier can submit milestone.
- Only buyer can submit/pass inspection.
- All milestone rows for the order must be completed before order completion is derived.

## 5. Counterparty Rating

| From | To | Trigger | Owner |
|---|---|---|---|
| none | `submitted` | eligible side submits rating | Server |

Rules:

- Eligibility requires `ProjectOrder.state = completed`.
- Unique direction: `orderId + raterOrganizationId + rateeOrganizationId`.
- One side cannot rate outside the order buyer/seller boundary.

## 6. Credit Shadow

| From | To | Trigger | Owner |
|---|---|---|---|
| pending/no trigger | recompute requested | counterparty rating submitted | Server |
| recompute requested | ledger appended/aggregate refreshed | shadow engine runs | Server |

Rules:

- Credit bridge consumes `ProjectCounterpartyRating` truth only.
- No chat, album, front-end flag, or BFF DTO can trigger credit directly.
