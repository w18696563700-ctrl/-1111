---
owner: Codex 总控
status: frozen
purpose: Record the runtime correction for OTP login failure caused by duplicate device upsert against `idx_devices_user_fingerprint`, preserving the narrow auth-only scope and active cloud validation evidence.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/personal_minimal_edit_cloud_deployment_repair_execution_receipt_addendum.md
  - apps/server/src/modules/auth/auth-session.service.ts
---

# `auth login device upsert` 运行时纠偏回执

## 1. Scope

- 本回执只记录 `P0-1 public login opening` 登录路径上的设备 upsert 运行时纠偏。
- 本回执只涉及：
  - `apps/server/src/modules/auth/auth-session.service.ts`
  - active cloud Server build / restart
  - active ingress login verification
- 本回执不打开：
  - OCR
  - real-name
  - company / certification / review
  - payment / billing / V2.3
  - broader auth system redesign

## 2. Root Cause

- 用户实测中 OTP send 成功，但 OTP login 返回 `AUTH_RESOURCE_UNAVAILABLE`。
- Active cloud logs showed Server upstream `500`.
- Server root cause was a PostgreSQL unique violation:
  - table: `devices`
  - constraint: `idx_devices_user_fingerprint`
  - duplicate key: `(user_id, device_fingerprint)`
- Existing code only looked up a device by primary `id`.
- If an existing row had the same `(userId, deviceFingerprint)` but a different `id`, login attempted to insert a new device row and triggered the unique constraint.

## 3. Correction

- `upsertDevice()` now first looks up by:
  - `id = command.deviceId`
- If no row is found, it then falls back to:
  - `userId`
  - `deviceFingerprint = command.deviceId`
- This preserves the existing device row and updates it instead of inserting a duplicate.

## 4. Cloud Execution

- Local server build passed after the source correction.
- The corrected `auth-session.service.ts` was synced to the active cloud Server release.
- Cloud Server build passed.
- `exhibition-server` was restarted.
- Cloud health check passed:
  - `GET /health/server/live`
  - service `exhibition-server-isolated`
  - port `3001`

## 5. Active Ingress Validation

- Validation was performed through active cloud ingress `:80`.
- Probe used the same stable device identifier visible in the runtime failure:
  - `mobile-local-device`
- Validation result:
  - `POST /api/app/auth/otp/send` returned `200`
  - `POST /api/app/auth/otp/login` returned `200`
  - login response included an access token
  - login response returned `shellBootstrapState=authenticated`
  - `GET /api/app/shell/context` returned `200`
  - shell readback included current `displayName`
  - shell readback included `avatarUrl`

## 6. Retained Boundaries

- No BFF code was changed.
- No frontend code was changed.
- No local runtime path was reopened.
- No business package outside auth login device upsert was changed.

## 7. Stage Decision

- `auth login device upsert runtime correction` is complete.
- User can clear cache / restart the app and retry:
  - send OTP
  - login with `18696563700 + 000000`
  - continue testing nickname and avatar flows

