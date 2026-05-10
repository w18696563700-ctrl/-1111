---
owner: Codex 总控
status: frozen
purpose: Record the L2 contracts ruling for the 100-point minimum closure of in-app notifications and iOS-only APNs V1.
layer: L2 Contracts
---

# 消息提示 / iOS APNs V1 100 分闭环 Contracts Ruling Addendum

## 1. 总裁决

本轮 contracts 裁决：`Conditional Pass without OpenAPI change`。

现有 OpenAPI / generated contracts 已能承接 `消息提示 / iOS APNs V1 100 分闭环` 的 App-facing 最小闭环：

- device token register
- notification list
- notification mark-read
- source lane filtering
- unread bucket projection
- routeTarget availability
- mark-read read context

本轮不新增 push platform API，不新增 notification preference API，不新增 Android FCM API，不暴露 push delivery attempt app-facing projection。

闭环项：

- `docs/01_contracts/openapi.yaml` 与 `packages/contracts/openapi/openapi.bundle.json` 已有 device-token register schema。
- `packages/contracts/src/generated/app-api.types.ts` 已生成 notification list / read / source lane / unread / routeTargetAvailability 类型，以及 `DevicePushPlatform`、`DevicePushProvider`、`DevicePushTokenRegisterRequest`、`DevicePushTokenRegisterResponse` 投影。
- `pnpm contracts:check` 已验证 OpenAPI bundle、generated types、generated error codes 和 manifest 一致。

## 2. Existing App-Facing Routes

| Path | Method | Ruling |
| --- | --- | --- |
| `/api/app/notifications/device-token/register` | `POST` | Continue as the only App-facing device-token register route. |
| `/api/app/notifications/list` | `GET` | Continue as the only App-facing notification list route. |
| `/api/app/notifications/read` | `POST` | Continue as the only App-facing notification mark-read route. |

APNs system delivery remains Server-side delivery infrastructure. It is not exposed as an App-facing send route.

## 3. Schema Sufficiency

Existing schemas are sufficient:

| Schema | Required for V1 | Current ruling |
| --- | --- | --- |
| `DevicePushTokenRegisterRequest` | `platform`, `provider`, `deviceToken`, `appInstallationId` | OpenAPI and generated projection complete. |
| `DevicePushTokenRegisterResponse` | register acknowledgement | OpenAPI and generated projection complete. |
| `AppNotificationSourceLane` | `all`, `project_communication`, `forum_interaction`, `business_todo`, `system` | Sufficient. |
| `AppNotificationReadModel` | item source, unread, routeTarget, routeTargetAvailability | Sufficient. |
| `AppNotificationUnreadProjection` | explainable buckets and total | Sufficient. |
| `AppNotificationReadRequest` | mark-read ids plus available-route readContext | Sufficient. |
| `AppNotificationReadResponse` | read ids plus updated unread projection | Sufficient. |

The following do not require App-facing schema changes in this round:

- iOS default sound.
- iOS default vibration.
- APNs provider adapter status.
- Server `push_delivery_attempts`.
- forum interaction event ingestion into `app_notifications`.

## 4. Forum Interaction Ruling

`forum_interaction` is already an allowed notification source and notification type.

Therefore, the missing 100-point behavior is not an OpenAPI problem. If forum replies, likes, and follows do not enter the bell, unread buckets, or push, the fix belongs in Server notification truth:

- create or reuse `app_notifications` for forum interaction events
- set `source=forum_interaction`
- set `type=forum_interaction`
- return a controlled `routeTarget` to the forum interaction surface or relevant post detail when available
- return `routeTargetAvailability` for stale / forbidden / missing-context items

`/api/app/forum/interaction/inbox` remains a forum read projection. It must not become the second unread truth.

## 5. Generated Types Ruling

Because this round does not require new APNs OpenAPI paths, generated types must not be hand-edited to fake closure.

Day 3 generated alignment result:

1. `DevicePush*` register types are present in `packages/contracts/src/generated/app-api.types.ts`.
2. `pnpm contracts:check` passed against `packages/contracts/contracts-manifest.json`.
3. No temporary Flutter / BFF APNs register DTO exception is needed for this closure.

Generated files must not be hand-edited to simulate a contract closure.

## 6. Layer Rules

| Layer | Allowed | Forbidden |
| --- | --- | --- |
| Server | own notification truth, unread truth, routeTarget availability, token truth, delivery attempts | expose push provider internals as app-facing truth |
| BFF | forward, shape, validate known source lane, map controlled errors | compute unread, save tokens, own delivery truth |
| Flutter | register token, display list, navigate routeTarget, request mark-read after successful navigation | invent DTOs, compute unread truth, clear stale notifications locally |

## 7. No-Go Items

No contract work in this round may introduce:

- generic notification send APIs
- notification preferences
- do-not-disturb
- marketing push
- Admin push console
- Android FCM setup
- custom vibration configuration
- payment / wallet / settlement / invoice fields
- fulfillment / order / contract state mutation

## 8. Day 2 Closure

Day 2 is `Conditional Pass` when:

1. OpenAPI is confirmed to already contain the required notification V1 fields.
2. No OpenAPI diff is needed.
3. The generated `DevicePush*` gap is closed by the generated projection and contracts check.
4. Server implementation work is correctly routed to Day 4, not hidden in contracts.
