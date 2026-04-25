---
owner: Codex 总控
status: frozen
layer: L0 SSOT
freeze_date_local: 2026-05-18
purpose: Freeze the field table for the project transaction lifecycle.
---

# 项目交易链路字段表

## 1. BidAward

| Field | Required | Notes |
|---|---:|---|
| `bidAwardId` | yes | Server generated |
| `projectId` | yes | 项目锚点 |
| `winningBidId` | yes | 赢家 bid |
| `winningOrganizationId` | yes | 赢家组织 |
| `reasonCode` | yes | 选择原因码 |
| `reasonText` | yes | 选择说明 |
| `state` | yes | `converted_to_order` for accepted continuation |
| `orderId` | yes | 同事务生成 |
| `contractId` | yes | 同事务生成 |
| `decidedAt` | yes | Server time |

## 2. ProjectOrder

| Field | Required | Notes |
|---|---:|---|
| `orderId` | yes | Server generated |
| `orderNo` | yes | Display number |
| `projectId` | yes | 强制项目锚点 |
| `bidId` | yes | 来源 bid |
| `buyerOrganizationId` | yes | 发布方组织 |
| `sellerOrganizationId` | yes | 承接方组织；storage compatibility column may be `supplier_organization_id` |
| `title` | yes | Derived from project title/projectNo |
| `totalAmount` | yes | Derived from winning bid quote |
| `state` | yes | `active / completed / cancelled` |
| `activatedAt` | yes | Order created time |
| `completedAt` | no | Required when completed |
| `completionRequestState` | yes | `none / requested / rejected / dispute_reserved / confirmed` |
| `completionRequestedAt` | no | Seller request time |
| `completionRequestedBy` | no | Request actor/user |
| `completionRequestedByOrganizationId` | no | Seller organization |
| `completionRequestNote` | no | Seller completion note |
| `completionConfirmedAt` | no | Buyer confirm time |
| `completionConfirmedBy` | no | Confirm actor/user |
| `completionConfirmedByOrganizationId` | no | Buyer organization |
| `completionRejectedAt` | no | Buyer reject time |
| `completionRejectedBy` | no | Reject actor/user |
| `completionRejectedByOrganizationId` | no | Buyer organization |
| `completionRejectionReason` | no | Reject/dispute reserve reason |
| `createdAt` | yes | DB time |
| `updatedAt` | yes | DB time |

Unique:

- `projectId`
- `bidId` when present

## 3. Milestone

| Field | Required | Notes |
|---|---:|---|
| `milestoneId` | yes | Server generated |
| `orderId` | yes | 订单锚点 |
| `sequenceNo` | yes | 当前最小闭环默认 `1` |
| `title` | yes | 履约节点标题 |
| `amount` | yes | 默认等于订单金额 |
| `state` | yes | `pending_submission / submitted / completed` |
| `submittedAt` | no | Supplier submit time |
| `submittedBy` | no | Actor/user id |

## 4. Inspection

| Field | Required | Notes |
|---|---:|---|
| `inspectionId` | yes | Server generated |
| `milestoneId` | yes | 节点锚点 |
| `orderId` | yes | 订单锚点 |
| `state` | yes | `draft / submitted / passed` plus legacy `rechecked` |
| `submittedAt` | no | Buyer submit time |
| `submittedBy` | no | Actor/user id |
| `passedAt` | no | Buyer pass time |
| `passedBy` | no | Actor/user id |

## 5. ProjectCounterpartyRating

| Field | Required | Notes |
|---|---:|---|
| `ratingId` | yes | Server generated |
| `orderId` | yes | 订单锚点 |
| `projectId` | yes | 项目锚点 |
| `raterOrganizationId` | yes | 评价方 |
| `rateeOrganizationId` | yes | 被评价方 |
| `raterUserId` | yes | 评价用户 |
| `raterActorId` | no | 当前 actor |
| `scoreValue` | yes | Server mapping |
| `scoreLabel` | yes | `very_satisfied / satisfied / passable / negative` |
| `commentText` | no | 文字备注 |
| `ratingState` | yes | `submitted` |
| `submittedAt` | yes | Server time |

## 6. Credit Bridge

| Field | Required | Notes |
|---|---:|---|
| `organizationId` | yes | 被影响组织 |
| `sourceType` | yes | `project_counterparty_rating` |
| `sourceId` | yes | rating id |
| `orderId` | yes | completed order |
| `projectId` | yes | source project |
| `triggerState` | yes | recompute/ledger trigger state |
