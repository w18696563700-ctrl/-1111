---
owner: Codex 总控
status: frozen
purpose: Freeze the cloud-credential and real-device UAT gate for iOS-only APNs V1 before any APNs secret configuration, cloud env mutation, deploy, or real push claim.
layer: L0 SSOT
---

# iOS-only APNs V1 Cloud Credentials And Real Push UAT Gate Addendum

## 1. 总裁决

当前门禁结论：`Conditional Pass for gate freeze`，`No-Go for credential configuration / real push UAT / deploy` until all conditions below are satisfied and explicitly authorized.

本 addendum 只冻结 iOS-only APNs V1 的云端凭据配置和真实系统通知 UAT 门禁。它不新增 OpenAPI，不修改 generated contracts，不改变通知业务真相，不开通 Android，不开通 Firebase / FCM，不做自定义震动，不做通知偏好中心。

## 2. Relationship With Existing Truth

Base truth remains:

- `project_communication_notification_preview_v1_truth_freeze_addendum.md`
- `project_communication_notification_preview_v1_stage_gate_checklist_addendum.md`
- `project_communication_notification_preview_v1_stage4_prerequisite_nogo_addendum.md`
- `project_communication_notification_preview_v1_day10_runtime_uat_receipt.md`

This gate only reopens the previously retained No-Go items for iOS APNs:

- APNs credential availability.
- True iPhone system notification UAT.
- Default iOS sound / vibration / lock-screen notification acceptance.
- Notification tap returning to the existing app-facing `routeTarget`.

It does not reopen FCM, Android, generic notification platform, generic IM, payment, fulfillment, settlement, wallet, or notification-preference work.

## 3. iPhone-Reachable BFF Base URL Gate

The iPhone UAT build must use an iPhone-reachable App-facing BFF base URL.

Required base URL shape:

- Preferred and production-like: `https://<approved-domain>/api/app`
- Temporary UAT-only fallback: `http://47.108.180.198/api/app` only if an explicit iOS ATS exception gate is separately approved.

Current read-only evidence:

- `http://47.108.180.198/health/bff/live` returns `200`.
- `http://47.108.180.198/health/server/live` returns `200`.
- `http://127.0.0.1:8080/health/bff/live` returns `200`.
- `http://127.0.0.1:8080/health/server/live` returns `200`.

Current blocker:

- iPhone cannot use Mac-local `127.0.0.1:8080` as the app API base.
- The current iOS `Info.plist` does not freeze an arbitrary cleartext HTTP allowance.
- Therefore direct HTTP IP is not a formal iOS UAT base unless a separate ATS exception is approved.

Day UAT compile/run command must pass a real reachable base via Dart define, for example:

```bash
flutter run -d <iphone-device-id> \
  --dart-define=APP_RUNTIME_ENTRY_MODE=custom \
  --dart-define=APP_BFF_BASE_URL=<approved-bff-base-url>
```

The approved URL must not be stored as a secret. It may be recorded in UAT receipt if it contains no token, password, or session data.

## 4. APNs Auth Key Storage Gate

APNs credentials are never repository content and must never be printed in receipts.

Allowed storage:

- APNs `.p8` auth key stored outside the repo, e.g. `/etc/exhibition/secrets/apns/AuthKey_<KEY_ID>.p8`.
- File owner and mode must be restricted to the Server runtime user or root-controlled service group.
- The key path may be stored in Server environment as `APNS_AUTH_KEY_PATH`.

Forbidden:

- Commit `.p8`, `.cer`, `.p12`, provisioning-profile private material, private keys, or copied key content.
- Paste APNs key content into chat, docs, shell output, logs, screenshots, or receipts.
- Store APNs key content in Flutter, BFF, Admin, OpenAPI, generated contracts, or build artifacts.

If the credential file is missing, unreadable, or invalid, Server must remain degraded and record `provider_credentials_unavailable`.

## 5. Server Environment Gate

Server APNs env names are frozen as:

| Env name | Meaning | Secret? | Receipt rule |
| --- | --- | --- | --- |
| `APNS_KEY_ID` | Apple APNs key id | no, but operationally sensitive | may show as present/absent only |
| `APNS_TEAM_ID` | Apple Team id | no, but operationally sensitive | may show as present/absent only |
| `APNS_BUNDLE_ID` | iOS bundle id, currently `com.zhanlandingzhijia.mobile` | no | may show exact value |
| `APNS_ENV` | `development` or `production` | no | may show exact value |
| `APNS_AUTH_KEY_PATH` | server-side path to `.p8` key | path sensitive | may show directory class only, not full path if it reveals secret layout |

Current V1 alignment:

- Current iOS entitlement uses `aps-environment=development`.
- Therefore first UAT must use APNs sandbox, i.e. `APNS_ENV=development`.
- Production APNs is a later gate and must align with a production entitlement/provisioning profile.

Server env configuration must be done through a controlled runtime config mechanism, such as a systemd drop-in or approved environment file. Any service restart, daemon reload, or env write requires explicit user approval.

## 6. Rollback Gate

Before APNs env configuration or deploy, record:

- current Server active release path
- current BFF active release path
- current systemd `exhibition-server` and `exhibition-bff` status
- current `/health/server/live` and `/health/bff/live`
- rollback command or symlink target
- current APNs env presence/absence only

Rollback minimum:

- remove or disable the APNs env drop-in / env file
- reload systemd only if the env mechanism requires it
- restart only the affected Server service if approved
- restore previous Server release if deploy caused the regression
- verify health after rollback

BFF should not need APNs env and must not own token truth, unread truth, notification truth, or delivery truth.

## 7. True iPhone UAT Steps

The UAT must use a real iPhone and must not use simulator evidence for system push acceptance.

### 7.1 Permission And Token

1. Install / run the iOS app on the real iPhone with the approved BFF base URL.
2. Log in using an approved test account.
3. Trigger notification bootstrap.
4. Observe iOS notification permission prompt on first run or confirm existing permission status.
5. User allows notification.
6. Flutter obtains APNs device token through the native iOS bridge.
7. Flutter calls `POST /api/app/notifications/device-token/register`.
8. Server stores token under the current user / organization / app installation with `provider=apns`, `platform=ios`.

Receipt rules:

- Do not print token.
- Do not print access token.
- Do not print password or session cookie.
- It is allowed to state `token obtained: yes/no` and `register status: 200 registered=true`.

### 7.2 Real Push Generation

Allowed event sources for V1 UAT:

- project communication message
- bid participation request notification

The event must create:

- `app_notifications` row
- `push_delivery_attempts` row
- APNs provider attempt with status `success` or controlled failure

APNs delivery success does not create business truth and does not mark notification read.

### 7.3 iPhone Notification Acceptance

UAT must verify:

- App foreground behavior is controlled and does not duplicate fake alerts.
- App background receives system notification.
- Lock screen receives system notification.
- Default sound follows iOS system settings.
- Default vibration follows iOS system settings.
- Notification tap opens the App.
- Notification tap attempts the existing `routeTarget`.
- If `routeTarget` is unavailable, Flutter shows Chinese fallback and does not mutate business state.

Receipt evidence may include screenshots or screen recording, but must not expose token, credential, phone number, password, or private message content beyond minimal test strings.

## 8. Explicit Non-Goals

This gate does not allow:

- Android FCM.
- Firebase iOS.
- custom vibration pattern.
- notification preference center.
- do-not-disturb.
- marketing push.
- admin push console.
- group push.
- generic notification platform.
- payment, settlement, wallet, invoice, fulfillment, dispute, or contract amount mutation.
- storing APNs credentials in repo.
- printing tokens, private keys, or passwords.

## 9. Go / No-Go Matrix

| Gate item | Current state | Decision |
| --- | --- | --- |
| iOS-only APNs code path | local implementation exists, not yet committed in this gate | conditional |
| iPhone device | device detected locally in previous code construction receipt | conditional |
| iPhone-reachable BFF base | direct HTTP IP health passes; HTTPS formal base not proven | No-Go until approved |
| APNs key file | not configured in this gate | No-Go until provided through secret path |
| Server APNs env | not configured in this gate | No-Go until approved |
| BFF APNs env | not needed | Pass |
| Real push UAT | not executed | No-Go |
| Android | out of scope | No-Go |

## 10. Next Allowed Step

Next step may be only one of:

1. Commit the local iOS-only APNs V1 code package after commit review.
2. Provide and approve the iPhone-reachable HTTPS BFF base URL.
3. Approve a temporary UAT-only HTTP IP + ATS exception gate.
4. Approve APNs credential placement and Server env configuration plan.
5. Approve a Server-only deploy plan for APNs adapter plus true-device UAT.

No env write, deploy, restart, real push, or credential upload is allowed until the corresponding next gate is explicitly approved.
