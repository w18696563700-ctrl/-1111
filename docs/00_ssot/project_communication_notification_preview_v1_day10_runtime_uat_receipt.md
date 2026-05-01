# Project Communication Notification Preview V1 Day10 Runtime UAT Receipt

## Conclusion

Day10 degraded integration passed.

This receipt only closes the bounded V1 capabilities:

- app notification truth, unread, mark-read, and routeTarget
- device token registration shape
- push delivery attempt outbox with provider-unavailable degradation
- message-building notification center consumption
- project communication file preview signed access
- confirmation-card softLink read projection

This receipt does not close real APNs/FCM delivery, real-device notification UAT, sound, vibration, or lock-screen notification acceptance.

## Runtime Alignment

| Item | Result |
| --- | --- |
| Server current | `/srv/releases/server/20260501045612-notification-preview-v1-rebase` |
| BFF current | `/srv/releases/bff/20260501045612-notification-preview-v1-rebase/apps/bff` |
| Rollback evidence | `/srv/patches/20260501045612-notification-preview-v1-rebase.rollback` |
| Server previous target | `/srv/releases/server/20260501045239-p0-a-enterprise-hub-failclose` |
| BFF previous target | `/srv/releases/bff/20260501032743-membership-read-surface-cleanup/apps/bff` |
| Nginx route gate | added `notifications` and `confirmation` to app-facing allowlist |

## Build And Test Evidence

| Scope | Command Result |
| --- | --- |
| Contracts | `contracts_check=passed` |
| Server targeted | `13 pass / 0 fail` |
| BFF targeted | `20 pass / 0 fail` |
| Flutter targeted | `29 pass / 0 fail` |

## Health And Migration

| Route / Check | Result |
| --- | --- |
| `GET /health/bff/live` | `200`, `service=exhibition-bff` |
| `GET /health/bff/ready` | `200`, `service=exhibition-bff` |
| `GET /health/server/live` | `200`, `service=exhibition-server` |
| `GET /health/server/ready` | `200`, `service=exhibition-server` |
| `server_schema_migration` | `20260501_project_communication_notification_preview_v1_truth` applied |
| Tables | `app_notifications`, `device_push_tokens`, `push_delivery_attempts` present |

## 8080 Route Smoke

| Route | Result |
| --- | --- |
| `GET /api/app/notifications/list` without auth | `401 AUTH_SESSION_INVALID`, not `404` |
| `POST /api/app/notifications/device-token/register` without auth | `401 AUTH_SESSION_INVALID`, not `404` |
| `POST /api/app/notifications/read` without auth | `401 AUTH_SESSION_INVALID`, not `404` |
| `GET /api/app/file/preview/access` without auth | `401 AUTH_SESSION_INVALID`, not `404` |
| `GET /api/app/confirmation/softlink/detail` without auth | `401 AUTH_SESSION_INVALID`, not `404` |

## Dual Account UAT

Two provided test accounts were used. Passwords and tokens were not written to this receipt.

| UAT Item | Result |
| --- | --- |
| Password login, account A | `200`, access token returned |
| Password login, account B | `200`, access token returned |
| Device token register, account A | `200`, `registered=true` |
| Device token register, account B | `200`, `registered=true` |
| Account A sends project communication text | `202`, message persisted |
| Account B notification list after send | `200`, `unread.total=1`, `projectCommunication=1` |
| Notification routeTarget | enabled, points to `/api/app/message/counterpart-conversation/detail` with `projectId + threadId + conversationId` |
| Account B mark read | `200`, unread cleared to `0` |
| Push attempt | `provider=apns`, `attempt_status=provider_unavailable`, `error_code=provider_credentials_unavailable` |

## File Preview UAT

| Step | Result |
| --- | --- |
| Upload init | `200` |
| Direct upload | `200` when using the exact signed headers returned by init |
| Upload confirm | `200`, `fileAssetId=a9700b25-df27-482a-8371-553672ca497f` |
| Send file message | `202`, `messageKind=file` |
| Preview access | `200`, `previewType=text`, `accessUrl` present |
| Object key exposure | not present in App-facing preview response |

## Confirmation SoftLink UAT

| Step | Result |
| --- | --- |
| Send confirmation card | `202`, `messageKind=confirmation_card` |
| SoftLink detail | `200` |
| SoftLink state | `pending` |
| Route target | enabled, bounded to confirmation-card routeTarget |
| Business state machine | not changed |

## Computer Use Visual Check

The running `mobile` app was opened through Computer Use. The messages building shows:

- bounded `通知中心`
- normal empty state after mark-read: `暂无新的通知`
- project communication entry remains in the messages building
- no generic IM, group chat, stranger DM, or second message building was observed

## Cleanup

Removed failed release directories:

- `/srv/releases/server/20260501044903-notification-preview-v1`
- `/srv/releases/bff/20260501044903-notification-preview-v1`
- `/srv/releases/server/20260501045452-notification-preview-v1-fix1`
- `/srv/releases/bff/20260501045452-notification-preview-v1-fix1`

Removed local temporary auth JSON files from `/tmp`.

## Retained No-Go

- Real APNs delivery is not accepted.
- Real FCM delivery is not accepted.
- Real-device notification UAT is not accepted.
- Sound, vibration, and lock-screen notification acceptance are not accepted.
- Complex notification settings, generic notification platform, generic IM, file online editing, and confirmation-card state-machine behavior remain out of scope.

## Gate Decision

Go for degraded close of Project Communication Notification Preview V1.

No-Go for full system push close until APNs/FCM credentials and real devices are available and separately verified.
