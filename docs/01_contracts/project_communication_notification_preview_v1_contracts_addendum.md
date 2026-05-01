---
owner: Codex 总控
status: frozen
purpose: Freeze the L2 app-facing contracts for Project Communication Notification And Preview Capability Pack V1.
layer: L2 Contracts
---

# Project Communication Notification And Preview Capability Pack V1 Contracts Addendum

## 1. Contract Decision

This addendum freezes the L2 contract boundary for:

- notification and push minimum loop
- messages-building notification center
- controlled project communication file preview
- confirmation-card softLink

The L0 truth is:

- `docs/00_ssot/project_communication_notification_preview_v1_truth_freeze_addendum.md`

These contracts are additive. They do not redefine project communication
thread truth, message truth, file truth, forum truth, or order/contract/payment
state machines.

## 2. App-Facing Routes

### Notification And Push

| Route | Method | Owner | Purpose |
| --- | --- | --- | --- |
| `/api/app/notifications/device-token/register` | `POST` | BFF forwards to Server | Register or refresh a device push token. |
| `/api/app/notifications/list` | `GET` | BFF forwards to Server | Read the bounded notification center list. |
| `/api/app/notifications/read` | `POST` | BFF forwards to Server | Mark notification-center items as read. |

### File Preview

| Route | Method | Owner | Purpose |
| --- | --- | --- | --- |
| `/api/app/file/preview/access` | `GET` | BFF forwards to Server | Get controlled preview access for a project communication attachment. |

This route is dedicated to project communication preview. The existing shared
`/api/app/file/access` remains a separate shared access family and must not be
silently broadened into project communication preview without this contract.

### Confirmation softLink

| Route | Method | Owner | Purpose |
| --- | --- | --- | --- |
| `/api/app/confirmation/softlink/detail` | `GET` | BFF forwards to Server | Resolve a confirmation-card softLink for a project communication message. |

The route resolves read projection and routeTarget only. It does not mutate
confirmation, order, contract, payment, fulfillment, or bid state.

## 3. Schema Boundary

The OpenAPI patch freezes these minimum schemas:

- `DevicePushTokenRegisterRequest`
- `DevicePushTokenRegisterResponse`
- `AppNotificationReadModel`
- `AppNotificationListResponse`
- `AppNotificationReadRequest`
- `AppNotificationReadResponse`
- `AppNotificationUnreadProjection`
- `FilePreviewAccessReadModel`
- `ConfirmationSoftLinkReadModel`
- `AppNotificationRouteTarget`

Server-facing `push_delivery_attempts` or outbox projections are not
app-facing in V1. They must not be exposed through BFF unless a later contract
explicitly freezes an app-facing projection.

## 4. Field Rules

### Device Token

`DevicePushTokenRegisterRequest` must include:

- `platform`: `ios | android`
- `provider`: `apns | fcm`
- `deviceToken`
- `appInstallationId`

Optional device metadata may be accepted only as transport metadata. It must
not become notification truth or user identity truth.

### Notification Read Model

`AppNotificationReadModel` must include:

- `notificationId`
- `type`
- `source`
- `title`
- `createdAt`
- `unread`

Optional fields:

- `body`
- `projectId`
- `threadId`
- `routeTarget`
- `readAt`

`routeTarget` is a controlled app-facing jump carrier. It is not a local
Flutter route name and not a second route registry.

### File Preview

`FilePreviewAccessReadModel` must include:

- `fileAssetId`
- `projectId`
- `threadId`
- `previewType`
- `canPreview`
- `fileName`
- `mimeType`
- nullable `accessUrl`
- nullable `expiresAt`

`accessUrl` is a time-bounded signed access URL. `objectKey` must not appear in
the app-facing contract.

### Confirmation softLink

`ConfirmationSoftLinkReadModel` must include:

- `projectId`
- `threadId`
- `messageId`
- `confirmationType`
- `status`
- `title`
- `summary`
- optional `routeTarget`

The `material` softLink kind maps the user-facing material/process lane. It
does not create a new material state machine.

## 5. Error Codes

This package freezes these app-facing controlled errors:

| Code | Owner | Meaning |
| --- | --- | --- |
| `NOTIFICATION_UNAVAILABLE` | Server | Notification center or notification object is unavailable. |
| `NOTIFICATION_FORBIDDEN` | Server | Current actor cannot read or mark the notification. |
| `NOTIFICATION_READ_INVALID` | Server | Mark-read request is malformed or references invalid notification ids. |
| `PUSH_TOKEN_INVALID` | Server | Device-token register request is malformed or unsupported. |
| `PUSH_TOKEN_UNAVAILABLE` | Server | Push token registry or provider adapter is unavailable. |
| `FILE_PREVIEW_FORBIDDEN` | Server | Current actor cannot preview the requested project communication attachment. |
| `FILE_PREVIEW_UNAVAILABLE` | Server | Preview access cannot be generated or the file is not previewable. |
| `CONFIRMATION_SOFTLINK_INVALID` | Server | softLink request is malformed, unsupported, or outside the current project/thread. |

BFF may map upstream errors to these codes but must not invent business truth.

## 6. Compatibility

- Existing project communication messages remain readable.
- Existing project communication file/image/confirmation card payloads remain
  valid.
- Missing `routeTarget` on old confirmation cards must render as controlled
  unavailable, not as fake success.
- Missing notification routes in older runtimes must be treated as capability
  unavailable, not as proof that notification truth is absent forever.
- Permission denial for OS notifications must not block normal App use.

## 7. Explicit Non-Goals

The contract does not define:

- generic `/api/app/messages/*`
- generic notification platform APIs
- notification preference center
- system-wide push settings
- forum private messages
- stranger messages
- group chat
- read-receipt lists
- typing or online state
- file online editing
- objectKey exposure
- confirmation approval workflow
- order/contract/payment/fulfillment mutation
- Admin implementation routes

## 8. Generated Contracts

The synchronized formal inputs are:

- `docs/01_contracts/openapi.yaml`
- `docs/01_contracts/error_codes.yaml`

The expected generated output scope is the existing first-batch scope:

- `packages/contracts/contracts-manifest.json`
- `packages/contracts/openapi.bundle.json`
- `packages/contracts/app-api.types.ts`
- `packages/contracts/error-codes.ts`
- `packages/contracts/index.ts`

After this L2 freeze, `pnpm contracts:generate` and `pnpm contracts:check`
must pass before Stage 3 can be `Go for implementation prerequisite check`.

