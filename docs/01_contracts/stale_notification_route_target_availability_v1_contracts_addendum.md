---
owner: Codex 总控
status: frozen
purpose: Freeze the L2 contracts for stale notification routeTarget availability and fallback.
layer: L2 Contracts
---

# Stale Notification RouteTarget Availability V1 Contracts Addendum

## 1. Contract Decision

本 addendum 对齐 `stale_notification_route_target_availability_v1_truth_freeze_addendum.md`：

- `GET /api/app/notifications/list` 的每条通知必须返回 `routeTargetAvailability`。
- `routeTargetAvailability` 由 Server 计算，BFF 只透传，Flutter 只消费展示。
- `AppNotificationRouteTarget.canonicalPath` 必须注册当前 Server 已输出的 `/api/app/message/counterpart-conversation/detail`。
- 失效项目沟通通知的 fallback 只能回到主体项目列表，不代表业务处理成功，也不得自动 mark-read。

## 2. AppNotificationReadModel

`AppNotificationReadModel` 新增必填字段：

| Field | Type | Owner | Meaning |
| --- | --- | --- | --- |
| `routeTargetAvailability` | `AppNotificationRouteTargetAvailability` | Server | 当前通知 routeTarget 的可用性、失效原因和 V1 fallback。 |

`routeTargetAvailability` 不替代 `routeTarget`。`routeTarget` 仍表示原始承接目标；`routeTargetAvailability` 表示该目标在当前 actor / organization 上是否还可安全进入。

## 3. AppNotificationRouteTargetAvailability

字段：

| Field | Required | Values |
| --- | --- | --- |
| `state` | yes | `available`, `unavailable`, `expired`, `forbidden`, `missing_context` |
| `reasonCode` | yes | Server-owned stable code |
| `reasonText` | yes | App-facing Chinese copy |
| `fallbackAction` | yes | `none`, `open_subject_list` |
| `fallbackRouteTarget` | no | `AppNotificationRouteTarget` or `null` |

Rules:

- `state=available` means Flutter may try the original `routeTarget`.
- `state!=available` means Flutter must not call `/api/app/notifications/read` automatically.
- `fallbackAction=open_subject_list` means Flutter may open the fallback target, but fallback success still must not auto clear unread in V1.
- `fallbackRouteTarget` must not point to payment, settlement, wallet, fulfillment, or Admin surfaces.

## 4. Canonical Path Registry

`AppNotificationRouteTarget.canonicalPath` includes:

- `/api/app/message/counterpart-conversation/detail`

This path is the canonical app-facing detail container for counterpart conversation context. It is not a Flutter route name.

## 5. Mark Read Boundary

`POST /api/app/notifications/read` remains unchanged.

Contracts freeze only the prerequisite:

- mark-read may be called after successful navigation to an available target.
- mark-read must not be called for unavailable, expired, forbidden, or missing-context route targets.
- Server must not mark notifications read merely because `/notifications/list` was read.

## 6. Non-Goals

This contract does not define:

- notification cleanup jobs
- push-channel delivery state
- notification preference center
- business todo completion
- project communication read cursor
- forum interaction read cursor
- payment, service-fee, wallet, settlement, invoice
- fulfillment, acceptance, rating, dispute
