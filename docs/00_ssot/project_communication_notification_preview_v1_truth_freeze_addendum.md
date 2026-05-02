---
owner: Codex 总控
status: frozen
purpose: Freeze the L0 business truth for the bounded Project Communication Notification And Preview Capability Pack V1.
layer: L0 SSOT
---

# Project Communication Notification And Preview Capability Pack V1 Truth Freeze Addendum

## 1. Current Decision

This addendum admits a bounded capability pack named:

- `Project Communication Notification And Preview Capability Pack V1`
- 中文口径：`项目沟通通知与预览能力包 V1`

The package is not a generic message system, not a generic IM expansion, and
not a general notification platform. It only closes the minimum arrival,
notification aggregation, controlled file preview, and confirmation-card
soft-link gaps around project communication.

Current stage decision:

- `Go` for L2 contracts freeze.
- `No-Go` for implementation until L2 contracts, schema, error codes, and
  implementation prerequisites pass.

## 2. Relationship With Existing Truth

Existing Project Conversation Workbench V1 remains the base truth for project
communication:

- Project communication remains bound to `projectId + threadId`.
- Message kinds remain bounded to existing project-communication message
  families.
- Attachments and images remain anchored by confirmed `FileAsset`.
- `objectKey` remains storage-layer data and never becomes business truth.
- Confirmation cards remain work-communication cards and do not drive order,
  contract, payment, or fulfillment state machines.

This addendum changes only one earlier boundary: system notification, push,
minimal cross-building notification center, file preview, and confirmation
softLink are now admitted only under this bounded V1 package.

All other earlier non-goals remain closed.

## 3. Package Scope

### 3.1 Main Package A: Notification And Push Minimum Loop

Admitted capability:

- `app_notifications` as Server-owned notification truth.
- `device_push_tokens` as Server-owned device token registry.
- `push_delivery_attempts` or push outbox as Server-owned delivery attempt
  record.
- Minimal notification list, unread count, mark-read, and routeTarget jump.
- Minimal system push delivery channel for project communication arrival.
- Minimal App-side notification permission request and device-token
  registration.
- Default OS behavior for sound, vibration, and lock-screen display.

Allowed notification sources:

- `project_communication_message`: new project communication message.
- `project_clarification`: project clarification or clarification-like
  project communication event if the underlying project communication truth
  exists.
- `project_key_reminder`: bounded key reminder derived from project
  communication truth.
- `forum_interaction`: forum-derived reminder carried from the existing forum
  interaction truth, not owned by this package.
- `system_reminder`: bounded platform/system reminder.

The minimal cross-building notification center may aggregate only:

- project communication notifications
- forum interaction reminders
- system reminders

It must live inside the messages building and must not become a second
messages building, a generic notification platform, or a cross-product inbox.

### 3.2 Side Package B: Controlled File Preview

Admitted capability:

- Preview access for project communication file/image attachments.
- Access must be based on confirmed `FileAsset`.
- Access must be authorized by `projectId + threadId` participant permission.
- Preview access must be signed and time-bounded.
- Supported preview types:
  - image
  - PDF
  - text
- Unsupported file types must show controlled fallback:
  - not previewable
  - download/open prompt only when a separately authorized signed access path
    exists

This package does not create a general cloud drive, public file browser, or
online editing surface.

### 3.3 Side Package C: Confirmation Card softLink

Admitted capability:

- Existing confirmation-card families may expose a bounded `softLink`.
- Supported confirmation kinds:
  - `quote`
  - `material`
  - `schedule`
- A softLink may carry only a routeTarget or equivalent jump anchor to an
  existing project/business surface.
- A softLink may record a lightweight open/click audit if required by L2/L3.
- A softLink may show only soft states such as:
  - `pending`
  - `recorded`
  - `unavailable`

The softLink never approves, rejects, confirms, pays, settles, awards, starts
fulfillment, or mutates any order/contract/payment/fulfillment state.

## 4. Ownership Rules

| Object | Truth Owner | BFF Role | Flutter Role |
| --- | --- | --- | --- |
| Notification object | Server | forwarding, shaping, error mapping | render and route |
| Notification unread/read | Server | no unread truth | consume and request mark-read |
| Device push token | Server | forwarding and shape validation | permission request and token registration |
| Push delivery attempt/outbox | Server | none unless app-facing projection is frozen | no delivery truth |
| File preview permission | Server | forwarding and response shaping | preview rendering |
| signed preview URL | Server/storage adapter | response shaping only | time-bounded consumption |
| Confirmation softLink | Server read projection | app-facing shaping | render and jump |

BFF must not own notification truth, unread truth, device-token truth,
preview-permission truth, delivery state, audit truth, or a second state
machine.

Flutter must not define business truth, notification truth, unread truth,
preview permission, or softLink semantics.

## 5. Notification Semantics

### 5.1 Notification Object

A notification is an app-visible arrival item anchored by:

- `notificationId`
- `recipientUserId` or equivalent current actor
- `recipientOrganizationId` when organization context is required
- optional `projectId`
- optional `threadId`
- `type`
- `title`
- optional `body`
- optional `routeTarget`
- `createdAt`
- `readAt`

The exact schema must be frozen in L2 contracts before implementation.

### 5.2 Unread And Mark Read

Notification unread is Server truth.

Notification mark-read only marks notification center items as read. It does
not replace project communication `read-cursor`, and it does not create
message-level read-receipt lists.

Project communication thread unread remains governed by the existing project
communication read-cursor boundary unless a later contract explicitly changes
that boundary.

### 5.3 Push Delivery

Push is a delivery channel, not a business truth owner.

Push success or failure must never decide whether a project message,
notification object, or business action exists.

If APNs or FCM credentials are missing, implementation may still close:

- notification truth
- notification center
- mark-read
- token registration shape
- outbox or adapter-mock tests

But it must not claim real system push UAT passed.

Permission denial by the OS must not block normal App use.

## 6. File Preview Semantics

File preview is allowed only for project communication attachments that are
already represented by a confirmed `FileAsset`.

Preview permission must verify:

- the current actor/session
- the current organization when organization context is required
- the target `projectId`
- the target `threadId`
- the requested `fileAssetId`
- the attachment belongs to that project communication context

The response may carry a time-bounded signed access URL, but must not expose
`objectKey` as business truth or as an app-facing contract field.

Preview rendering belongs to Flutter. Permission and signed access belong to
Server.

## 7. Confirmation softLink Semantics

Confirmation softLink is a read-projection and navigation bridge only.

Allowed softLink targets must be existing bounded business surfaces, such as:

- quote-related project communication or bid surface
- material/process-related project communication or project material surface
- schedule-related project communication or schedule surface

If a target surface is not available, the softLink must render as controlled
unavailable. It must not invent a target page, fake route, or local-only
business state.

## 8. Explicit Non-Goals

This package does not admit:

- generic IM
- generic private messages
- stranger messages
- group chat
- forum private messages
- customer-service arbitration console
- message recall
- voice or video messages
- typing state
- online state
- read-receipt lists
- complex notification settings
- notification category preference center
- notification platform generalization
- push success as business truth
- BFF-owned unread or notification truth
- file online editing
- general file-drive browsing
- `objectKey` as app-facing business truth
- confirmation cards driving approval, order, contract, payment, settlement, or
  fulfillment state
- risk punishment or contact-blocking governance
- Admin implementation work in this round

## 9. Implementation Order

The required order remains:

1. L0 truth freeze.
2. L2 contracts, schema, and error-code freeze.
3. Total-control Go / No-Go decision.
4. Implementation prerequisite check.
5. Main package A implementation.
6. Side package B implementation.
7. Side package C implementation.
8. Independent result verification.
9. Independent integration/release validation.
10. Closeout.

No implementation may start before stages 1 through 4 pass.

## 10. Evidence From Prior Truth

Current prior evidence:

- `docs/00_ssot/project_conversation_workbench_v1_truth_freeze_addendum.md`
  froze project communication as `projectId + threadId`, admitted
  `text/image/file/confirmation_card`, and previously excluded system push,
  sound/vibration/lock-screen notification, and cross-building notification
  center.
- `docs/01_contracts/project_conversation_workbench_v1_contract_addendum.md`
  froze message payloads, upload flow, attachment payload, confirmation payload,
  and App-local contact soft prompt.
- `docs/01_contracts/counterpart_conversation_message_building_readability_contract_addendum.md`
  froze `unreadSummary.messages` as App-internal badge summary, not system
  notification truth.
- `docs/01_contracts/openapi.yaml` already contains shared
  `/api/app/file/access`, but that shared access path is not by itself the
  project communication preview truth for this package.
- `docs/01_contracts/forum_interaction_inbox_materialization_contract_addendum.md`
  freezes only the forum-derived interaction inbox and must not be treated as
  the notification owner for this package.
