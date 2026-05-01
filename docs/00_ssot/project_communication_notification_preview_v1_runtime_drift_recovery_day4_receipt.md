# Project Communication Notification Preview V1 Runtime Drift Recovery Day4 Receipt

Status: Go for runtime drift recovery close, with real system push still No-Go.

## Scope

This receipt only records recovery of previously accepted runtime capabilities:

- app-facing notification center routes
- project communication notification unread/read behavior
- project communication file preview access
- confirmation-card softLink detail

No SSOT, contracts, OpenAPI, generated contracts, or Flutter feature scope was expanded in this recovery.

## Runtime Alignment

| Item | Result |
| --- | --- |
| Server active | `/srv/releases/server/20260501140152-notification-preview-drift-recovery` |
| BFF active | `/srv/releases/bff/20260501140152-notification-preview-drift-recovery/apps/bff` |
| Rollback evidence | `/srv/patches/20260501140152-notification-preview-drift-recovery.rollback` |
| Recovery method | dist-level minimum rebase from current active release because the active release was deployed artifacts only |
| Previous server target | `/srv/releases/server/20260501055524-membership-purchase-p0pay-linkage` |
| Previous BFF target | `/srv/releases/bff/20260501055524-membership-purchase-p0pay-linkage/apps/bff` |

## 8080 Smoke

| Route | Result |
| --- | --- |
| `GET /health/bff/live` | `200`, `status=ok`, `service=exhibition-bff` |
| `GET /health/bff/ready` | `200`, `status=ready`, `service=exhibition-bff` |
| `GET /health/server/live` | `200`, `status=ok`, `service=exhibition-server` |
| `GET /health/server/ready` | `200`, `status=ready`, `service=exhibition-server` |
| `GET /api/app/notifications/list` | `401 AUTH_SESSION_INVALID`, no longer `404` |
| `POST /api/app/notifications/device-token/register` | `401 AUTH_SESSION_INVALID`, no longer `404` |
| `POST /api/app/notifications/read` | `401 AUTH_SESSION_INVALID`, no longer `404` |
| `GET /api/app/file/preview/access?projectId=smoke&threadId=smoke&fileAssetId=smoke` | `401 AUTH_SESSION_INVALID`, no longer `404` |
| `GET /api/app/confirmation/softlink/detail?projectId=smoke&threadId=smoke&messageId=smoke` | `401 AUTH_SESSION_INVALID`, no longer `404` |

## Double-Account UAT

Test project/thread:

- `projectId=6883586a-c8a3-47f4-aded-96450fe8c3fe`
- `threadId=8039f87b-e735-49fd-98d5-21b7c55c300b`

| Check | Result |
| --- | --- |
| Both accounts login | Passed |
| Both accounts resolve same `projectId + threadId` | Passed |
| Device token register shape | Passed for both accounts |
| Account A sends text message | Passed, message persisted |
| Account B notification center receives project communication unread | Passed, unread changed from `0` to `1` |
| Mark read | Passed, unread returned to `0` |
| Confirmation card send | Passed |
| Confirmation softLink detail | Passed, `status=pending`, route target returned |
| File upload three-step flow | Passed: `init -> direct upload -> confirm` |
| File message send | Passed |
| File preview access | Passed: `previewType=text`, `canPreview=true` |
| `objectKey` exposure | Passed: preview response did not expose `objectKey` |
| UAT unread cleanup | Passed: remaining UAT notifications marked read, final unread `0` |

UAT evidence identifiers:

- text message: `6f8a26b5-693e-4f80-8a27-c97e17b7a748`
- confirmation message: `3254fad9-546e-47c4-ab1d-bf4bdeb864a1`
- file message: `cd97ebe0-5b25-491f-8c00-7c49f4bf64a6`
- confirmed file asset: `751f53c0-01b5-411f-bfa9-fdccb55ad37d`

## Visual Check

Computer Use observation:

- Mobile app messages tab displays `互动中心`.
- `通知中心` remains a bounded block inside messages.
- Empty state is `暂无新的通知`.
- Project communication and forum interaction remain separate blocks.
- No generic private-message center, group chat, or broad notification platform UI appeared.

Screenshot evidence:

- `docs/00_ssot/evidence/project_communication_notification_preview_v1_runtime_drift_day4_messages_page.png`

## Retained No-Go

The following remain explicitly not accepted by this recovery:

- real APNs delivery UAT
- real FCM delivery UAT
- sound notification UAT
- vibration notification UAT
- lock-screen notification UAT
- complex notification settings
- generic notification platform expansion

## Gate Decision

Passed gates:

- runtime drift scope remained bounded to restoring existing V1 routes
- Server/BFF health passed after alignment
- five app-facing routes recovered from `404` to controlled auth behavior
- double-account notification/read/file-preview/softLink UAT passed
- rollback target is recorded

Failed gates:

- none for runtime drift recovery

Veto gates:

- real system push remains No-Go until APNs/FCM credentials and real-device conditions are available

Final decision:

- Go for closing runtime drift recovery.
- Do not claim full system push completion.
