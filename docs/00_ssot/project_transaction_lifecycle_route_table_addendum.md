---
owner: Codex 总控
status: frozen
layer: L2-L4 SSOT
freeze_date_local: 2026-05-18
purpose: Freeze app-facing and server-facing route boundaries for the project transaction lifecycle.
---

# 项目交易链路路由表

## 1. App-Facing Routes

| App route | Method | BFF target | Truth owner | Notes |
|---|---|---|---|---|
| `/api/app/bid/award` | POST | `/server/bid/award` | Server | 发布方选定合作方并生成订单 |
| `/api/app/bid/select-bid-and-create-order` | POST | `/server/bid/select-bid-and-create-order` | Server | 显式命名的选择合作方并生成订单命令，复用 award 真值 |
| `/api/app/bid/result` | GET | `/server/bid/result` | Server | 赢家/输家结果读取 |
| `/api/app/order/detail` | GET | `/server/order/detail` | Server | 订单详情读取 |
| `/api/app/contract/detail` | GET | `/server/contract/detail` | Server | 合同详情读取 |
| `/api/app/contract/confirm` | POST | `/server/contract/confirm` | Server | 合同确认 |
| `/api/app/contract/amend` | POST | `/server/contract/amend` | Server | 合同修订占位 |
| `/api/app/milestone/list` | GET | `/server/milestone/list` | Server | 履约节点读取 |
| `/api/app/milestone/submit` | POST | `/server/milestone/submit` | Server | 承接方提交履约 |
| `/api/app/inspection/detail` | GET | `/server/inspection/detail` | Server | 验收详情读取 |
| `/api/app/inspection/submit` | POST | `/server/inspection/submit` | Server | 发布方提交验收 |
| `/api/app/inspection/pass` | POST | `/server/inspection/pass` | Server | 发布方通过验收，可能派生 order completed |
| `/api/app/order/complete/request` | POST | `/server/order/complete/request` | Server | 承接方发起完工申请，订单仍 active |
| `/api/app/order/complete/confirm` | POST | `/server/order/complete/confirm` | Server | 发布方确认完工，订单进入 completed |
| `/api/app/order/complete/reject` | POST | `/server/order/complete/reject` | Server | 发布方拒绝完工，可保留争议入口 |
| `/api/app/project-counterparty-rating/entry` | GET | `/server/project-counterparty-rating/entry` | Server | completed order 后开放 |
| `/api/app/project-counterparty-rating/submit` | POST | `/server/project-counterparty-rating/submit` | Server | 双方互评提交 |

## 2. Route Target / Action Key

| Surface | `routeTarget` | `actionKey` | Required params |
|---|---|---|---|
| bid card | `bid.award` | `bid_award.submit` | `projectId / winningBidId` |
| bid card | `bid.select_bid_and_create_order` | `bid_select_create_order.submit` | `projectId / winningBidId` |
| bid result | `bid.result` | `bid_result.open` | `projectId` |
| order card | `order.detail` | `order_detail.open` | `orderId` |
| milestone card | `milestone.submit` | `milestone_submit.open` | `milestoneId` |
| inspection card | `inspection.detail` | `inspection_detail.open` | `milestoneId` or `inspectionId` |
| inspection pass | `inspection.pass` | `inspection_pass.submit` | `inspectionId` |
| order completion request | `order.complete.request` | `order_completion_request.submit` | `orderId` |
| order completion confirm | `order.complete.confirm` | `order_completion_confirm.submit` | `orderId` |
| order completion reject | `order.complete.reject` | `order_completion_reject.submit` | `orderId` |
| rating entry | `project_counterparty_rating.entry` | `counterparty_rating.open` | `orderId / projectId / rateeOrganizationId` |
| rating submit | `project_counterparty_rating.submit` | `counterparty_rating.submit` | `orderId / projectId / rateeOrganizationId` |

## 3. BFF Rules

- BFF must not store bid, order, fulfillment, rating, or credit truth.
- BFF must preserve `projectId / bidId / orderId / rateeOrganizationId`.
- BFF must not convert a 401/403/409 into a successful UI state.
- BFF may shape copy and display labels only after Server returns truth state.

## 4. Flutter Rules

- Flutter must call only app-facing routes.
- Flutter must navigate by `routeTarget/actionKey`.
- Flutter must not call `/server/*`.
- Flutter must not show rating submit as available unless Server/BFF entry says eligible.
