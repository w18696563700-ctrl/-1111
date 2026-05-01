---
owner: Codex 总控
status: frozen
purpose: Record the Stage 4 implementation prerequisite No-Go for Project Communication Notification And Preview Capability Pack V1.
layer: L0 SSOT
---

# Project Communication Notification And Preview Capability Pack V1 Stage 4 Prerequisite No-Go Addendum

## A. 一句话结论

Stage 4 implementation prerequisite check is `No-Go`: cloud runtime is healthy
and the cloud git workspace is identifiable, but the implementation return
mechanism, clean working state, push credentials, and true-device notification
UAT prerequisites are not proven.

## B. 当前阶段

Stage 4: implementation prerequisite check.

## C. 本轮目标

Confirm whether the project may enter Server/BFF/Flutter implementation for:

- notification and push minimum loop
- controlled file preview
- confirmation-card softLink

## D. 已完成项

### Cloud Runtime Baseline

- SSH read-only access to `47.108.180.198` is available.
- Active Server release:
  - `/srv/releases/server/20260501013500-project-conversation-workbench-v1`
- Active BFF release:
  - `/srv/releases/bff/20260501013500-project-conversation-workbench-v1/apps/bff`
- `exhibition-server`, `exhibition-bff`, and `nginx` are active.
- `WorkingDirectory` remains:
  - `/srv/apps/server/current`
  - `/srv/apps/bff/current`
- 8080 tunnel health smoke passes:
  - `/health/bff/live`
  - `/health/bff/ready`
  - `/health/server/live`
  - `/health/server/ready`

### Cloud Workspace Inventory

- A cloud git workspace exists:
  - `/srv/git/exhibition-infra-monorepo`
- Current branch observed:
  - `feature/trading-im-round-a`
- Tooling observed:
  - Ruby available
  - Node available
  - npm available
  - pnpm available
- Package scripts are visible for Server and BFF build/start surfaces.

### Existing Procedure Baseline

- Deploy / rollback procedure baseline exists as a procedure bundle:
  - `systemd + /srv/apps/*/current + /srv/releases/**`
- Restart anchors exist:
  - `systemctl restart exhibition-server`
  - `systemctl restart exhibition-bff`

## E. 未完成项

The following prerequisites are missing or not proven:

1. Cloud git return mechanism is not proven.
2. Cloud workspace has unrelated dirty changes and untracked files.
3. Cloud git workspace has no visible `origin` remote.
4. Branch strategy for this package is not frozen.
5. Current-round deploy/update procedure for this package is not proven.
6. APNs credential availability is not proven.
7. FCM credential availability is not proven.
8. True-device notification UAT condition is not proven.
9. Mobile notification SDK/bootstrap is not present in the current local client.

## F. 风险/冲突

### Veto Risks

- Implementing in the dirty cloud workspace risks mixing this package with
  unrelated enterprise-hub and other work.
- Without a remote/return mechanism, cloud implementation cannot be safely
  brought back into the formal repository.
- Without APNs/FCM evidence, real system push, sound, vibration, and lock-screen
  UAT cannot be claimed.
- Without true-device UAT evidence, simulator or macOS checks cannot close real
  notification delivery.

### Non-Veto Observations

- Cloud runtime health is currently good.
- Existing release/current symlink topology is valid.
- Existing deploy/rollback procedure baseline remains useful for a later
  reentry once the blocking prerequisites are closed.

## G. 证据清单

Local formal baseline:

- `docs/00_ssot/current_cloud_execution_baseline_freeze_addendum.md:42-44`
  freezes host, tunnel, and local 8080 URL.
- `docs/00_ssot/current_cloud_execution_baseline_freeze_addendum.md:50-57`
  freezes active workdir and service names for read-only checks.
- `docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md:42-53`
  freezes current pointers and restart/check anchors.
- `docs/00_ssot/current_cloud_deploy_rollback_procedure_baseline_addendum.md:55-75`
  freezes deploy as a procedure baseline.

Cloud read-only evidence:

- `readlink -f /srv/apps/server/current` returned
  `/srv/releases/server/20260501013500-project-conversation-workbench-v1`.
- `readlink -f /srv/apps/bff/current` returned
  `/srv/releases/bff/20260501013500-project-conversation-workbench-v1/apps/bff`.
- `systemctl is-active exhibition-server exhibition-bff nginx` returned
  `active` for all three services.
- `systemctl show` returned:
  - `WorkingDirectory=/srv/apps/server/current`
  - `WorkingDirectory=/srv/apps/bff/current`
- `curl http://127.0.0.1:8080/health/bff/live` returned `status=ok`.
- `curl http://127.0.0.1:8080/health/bff/ready` returned `status=ready`.
- `curl http://127.0.0.1:8080/health/server/live` returned `status=ok`.
- `curl http://127.0.0.1:8080/health/server/ready` returned `status=ready`.

Cloud workspace blockers:

- `/srv/git/exhibition-infra-monorepo` exists.
- `git branch --show-current` returned `feature/trading-im-round-a`.
- `git status --short` showed many modified and untracked files unrelated to
  this package.
- `git remote -v` returned no remote.
- `git ls-remote --heads origin` failed because `origin` is not configured.

Push credential and true-device blockers:

- Filtered `systemctl show ... Environment` and `/proc/<pid>/environ` checks
  found no `APNS`, `FCM`, `FIREBASE`, `PUSH`, or `NOTIFICATION` environment
  names for Server/BFF.
- `find apps/mobile ... GoogleService-Info.plist/google-services.json/*.p8`
  returned no Firebase/APNs credential files.
- `docs/00_ssot/profile_settings_p0_privacy_location_notification_day3_day5_boundary_freeze_addendum.md:76-83`
  states that the existing system-notification entry is only a settings jump
  and does not introduce push SDK, APNs/FCM token registration, background
  notification chain, or BFF/Server notification preferences.
- `apps/mobile/android/app/src/main/AndroidManifest.xml:1-5` shows current
  Android permissions do not include Android notification permission.
- `apps/mobile/ios/Runner/AppDelegate.swift:4-16` shows only Flutter plugin
  registration and no notification registration bootstrap.

## H. 是否通过本阶段门禁

No.

Stage 4 fails because implementation prerequisites are incomplete.

## I. 下一步建议

Before implementation can reenter, one of the following must happen:

1. Provide a clean cloud implementation workspace or clean branch dedicated to
   this package.
2. Freeze the cloud branch strategy and change-return mechanism:
   - remote push + PR, or
   - patch bundle, or
   - explicit cherry-pick procedure.
3. Confirm what unrelated dirty cloud changes belong to and isolate them from
   this package.
4. Provide APNs/FCM credential availability and true-device UAT conditions, or
   explicitly freeze a degraded path that may close only notification-center,
   token-shape, outbox/adapter-mock, file-preview, and softLink capability
   while leaving real system push UAT blocked.

## J. Go / No-Go 裁决

`No-Go for implementation`.

Allowed next action:

- prerequisite remediation and recheck only.

Blocked actions:

- Server implementation
- BFF implementation
- Flutter implementation
- cloud runtime mutation
- release/current switching
- real push UAT claim

