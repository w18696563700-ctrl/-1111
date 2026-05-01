# Project Communication Notification Preview V1 Runtime Drift Recovery Day1 Gate

## Conclusion

Go for runtime drift recovery.

This recovery is not a new feature implementation. It only restores the previously
validated notification, file preview, and confirmation softLink capability onto the
current cloud active runtime.

## Current Active Runtime

| Item | Current Target |
| --- | --- |
| Server current | `/srv/releases/server/20260501055524-membership-purchase-p0pay-linkage` |
| BFF current | `/srv/releases/bff/20260501055524-membership-purchase-p0pay-linkage/apps/bff` |
| Server health | ready |
| BFF health | ready |
| Migration record | `20260501_project_communication_notification_preview_v1_truth` exists |

## Drift Gap

| Capability | Current Runtime Result | Gap |
| --- | --- | --- |
| Server notification routes | `/server/notifications/list` returns `404` | Server notification module is not active |
| BFF notification routes | `/api/app/notifications/*` returns `404` | BFF notification route module is not active |
| File preview route | `/api/app/file/preview/access` returns `404` | BFF/Server preview route is not active |
| Confirmation softLink route | `/api/app/confirmation/softlink/detail` returns `404` | BFF/Server softLink route is not active |
| Nginx allowlist | Request reaches BFF and returns Nest `404` | Nginx is not the current blocker |

## Rebase Inputs

| Artifact | Status |
| --- | --- |
| Server-only patch | `/srv/patches/project-communication-notification-preview-v1-server-only.patch` exists |
| BFF-only patch | `/srv/patches/project-communication-notification-preview-v1-bff-only.patch` exists |
| Previous validated release | `/srv/releases/server/20260501045612-notification-preview-v1-rebase` and BFF peer exist |
| Current active release shape | dist-only, no `src/test` folders |

## Recovery Boundary

This recovery will:

- create a new release from current active runtime
- preserve current membership / P0Pay runtime content
- add compiled notification, preview, and softLink modules back into Server/BFF
- minimally register the missing modules in compiled runtime files
- run health, route smoke, and dual-account UAT

This recovery will not:

- add new contracts
- add new SSOT truth
- change Flutter code
- change Admin
- claim real APNs / FCM delivery
- claim true-device sound, vibration, or lock-screen notification UAT

## Rollback Targets

Rollback must return to the active targets captured immediately before runtime switching:

- Server: current `/srv/apps/server/current`
- BFF: current `/srv/apps/bff/current`

The concrete rollback file must be written during release preparation.

## Day1 Gate Decision

Go for Day2 minimum runtime rebase.

Reason: contracts and SSOT are already frozen, the current failure is runtime drift,
and current release is dist-only. Source-level build/test is not available directly
inside the active release, so Day2 must use a dist-level recovery with runtime smoke
and UAT as the acceptance gate.
