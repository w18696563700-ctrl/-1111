# Project Communication Notification Preview V1 Day11-Day13 Closeout Receipt

Status: Go for closing the bounded notification-center / preview / softLink loop.

Real system push remains No-Go until APNs/FCM credentials and online real-device conditions are available.

## Scope

This closeout only covers the Day11-Day13收口包:

- Day11 source recovery evidence and patch回流门禁
- Day12 image/PDF/unsupported preview and material/schedule softLink UAT
- Day13 push prerequisite gate and final 8080 smoke

No SSOT truth, contracts, OpenAPI fields, notification types, or business state machines were expanded.

## Day11 Source Recovery Gate

Runtime source of truth observed:

| Item | Result |
| --- | --- |
| Server active | `/srv/releases/server/20260501140152-notification-preview-drift-recovery` |
| BFF active | `/srv/releases/bff/20260501140152-notification-preview-drift-recovery/apps/bff` |
| Recovery mode | dist-only runtime recovery |
| Rollback evidence | `/srv/patches/20260501140152-notification-preview-drift-recovery.rollback` |
| Server source patch | `/srv/patches/project-communication-notification-preview-v1-server-only.patch` |
| BFF source patch | `/srv/patches/project-communication-notification-preview-v1-bff-only.patch` |
| Combined patch evidence | `/srv/patches/project-communication-notification-preview-v1-server-bff.patch` |

Local source recovery:

| Patch | Check |
| --- | --- |
| `project-communication-notification-preview-v1-server-only.patch` under `apps/server` | Applied to local formal source, with `migrations.ts` merged manually to preserve membership/P0Pay migrations |
| `project-communication-notification-preview-v1-bff-only.patch` under `apps/bff` | Applied to local formal source |

Local build and targeted tests:

| Check | Result |
| --- | --- |
| `pnpm --dir apps/server build` | passed |
| `pnpm --dir apps/bff build` | passed |
| `node --test apps/server/test/project-communication-notification-preview.test.cjs` | 4 passed, 0 failed |
| `node --test apps/bff/test/notification-transport.test.cjs apps/bff/test/file-preview-access-transport.test.cjs apps/bff/test/confirmation-softlink-transport.test.cjs` | 6 passed, 0 failed |

Cloud source targeted tests:

| Test | Result |
| --- | --- |
| `apps/server/test/project-communication-notification-preview.test.cjs` | 4 passed, 0 failed |
| `apps/bff/test/notification-transport.test.cjs` | included in BFF targeted run |
| `apps/bff/test/file-preview-access-transport.test.cjs` | included in BFF targeted run |
| `apps/bff/test/confirmation-softlink-transport.test.cjs` | BFF targeted run total: 6 passed, 0 failed |

Day11 decision:

- Patch has been回流 to local formal source without covering current membership/P0Pay runtime changes.
- Current active release remains unchanged.
- Contracts were not changed.

## Day12 Functional Gap UAT

Shared UAT anchors:

- `projectId=6883586a-c8a3-47f4-aded-96450fe8c3fe`
- `threadId=8039f87b-e735-49fd-98d5-21b7c55c300b`

File preview UAT:

| File | Message Kind | FileAssetId | Preview Result |
| --- | --- | --- | --- |
| `codex-day12-image.png` | `image` | `005e97f4-25bc-4a30-ba47-c9cecb3d19c2` | `previewType=image`, `canPreview=true`, no `objectKey` |
| `codex-day12-preview.pdf` | `file` | `304f37d4-6f1d-4838-ab08-de90a4ae569e` | `previewType=pdf`, `canPreview=true`, no `objectKey` |
| `codex-day12-unsupported.zip` | `file` | `5bd747b8-3a9d-4d63-bb46-026363095529` | `previewType=unsupported`, `canPreview=false`, `fallbackReason=unsupported_mime_type`, no `objectKey` |

Confirmation softLink UAT:

| Type | MessageId | Result |
| --- | --- | --- |
| `material_process` | `5b3f9704-c926-43a4-8348-67e2028a4803` | `status=pending`, route target returned |
| `schedule` | `0981e02f-4daa-4162-aa7e-5ff2fa6fef8a` | `status=pending`, route target returned |

Additional observation:

- First image attempt using `messageKind=file` with `category=image` was rejected with controlled `PROJECT_COMMUNICATION_INVALID`.
- Retest used the frozen contract correctly: `messageKind=image` with `category=image`.
- UAT notifications created during Day12 were marked read after validation; final unread returned to `0`.
- softLink detail remained read-only; no order/contract/payment/fulfillment state mutation was observed.

Visual evidence:

- `docs/00_ssot/evidence/project_communication_notification_preview_v1_day12_messages_page.png`

## Day13 Push Gate And Runtime Smoke

Push prerequisite check:

| Item | Result |
| --- | --- |
| APNs environment variables on running Server/BFF process | not found |
| FCM/Firebase environment variables on running Server/BFF process | not found |
| APNs/FCM credential files under inspected cloud paths | not found |
| Flutter connected devices | macOS and Chrome only |
| iPhones | listed offline; not usable for real notification UAT |

Decision:

- Real system push is No-Go.
- Sound, vibration, and lock-screen notification UAT are No-Go.
- This closeout may only close notification center, token registration shape, outbox/degraded channel, file preview, and softLink capability.

Final 8080 smoke:

| Route | Result |
| --- | --- |
| `GET /health/bff/live` | `200`, `status=ok`, `service=exhibition-bff` |
| `GET /health/bff/ready` | `200`, `status=ready`, `service=exhibition-bff` |
| `GET /health/server/live` | `200`, `status=ok`, `service=exhibition-server` |
| `GET /health/server/ready` | `200`, `status=ready`, `service=exhibition-server` |
| `GET /api/app/notifications/list` | `401 AUTH_SESSION_INVALID`, no `404` |
| `POST /api/app/notifications/device-token/register` | `401 AUTH_SESSION_INVALID`, no `404` |
| `POST /api/app/notifications/read` | `401 AUTH_SESSION_INVALID`, no `404` |
| `GET /api/app/file/preview/access?projectId=smoke&threadId=smoke&fileAssetId=smoke` | `401 AUTH_SESSION_INVALID`, no `404` |
| `GET /api/app/confirmation/softlink/detail?projectId=smoke&threadId=smoke&messageId=smoke` | `401 AUTH_SESSION_INVALID`, no `404` |

## Passed Gates

- Day11 patch apply check passed for Server and BFF.
- Day11 Server/BFF targeted tests passed in cloud source worktree.
- Day12 image preview passed.
- Day12 PDF preview passed.
- Day12 unsupported file fallback passed.
- Day12 material/schedule softLink passed.
- Day12 notification cleanup returned unread to `0`.
- Day13 runtime health and route smoke passed.
- BFF remains app-facing shaping only.
- No `objectKey` was exposed in preview responses.
- No business state machine expansion was observed.

## Failed Gates

- Real APNs/FCM push gate failed because credentials were not found.
- Real-device notification gate failed because iPhones were offline and only macOS/Chrome were connected.

## Veto Gates

- Do not claim real system push completion.
- Do not claim sound/vibration/lock-screen notification completion.
- Do not expand notification center into a generic message center.

## Final Completion Estimate

| Scope | Completion |
| --- | --- |
| Runtime drift recovery | 100% |
| Bounded notification center / read / preview / softLink loop | 98% |
| Full system push including real APNs/FCM and real-device notification behavior | No-Go |

## Final Decision

Go for closing Day11-Day13收口包.

No-Go for full real system push until APNs/FCM credentials and online real devices are available.
