---
owner: Codex 总控
status: frozen
purpose: Record the completed cloud-only runtime repair for `Personal minimal edit`, including active ingress validation for nickname and avatar chains, while preserving that this was not local runtime repair and not an infra-platform rewrite.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/personal_minimal_edit_boundary_freeze_addendum.md
  - docs/00_ssot/personal_minimal_edit_cloud_runtime_gap_audit_addendum.md
  - docs/00_ssot/personal_minimal_edit_cloud_deployment_repair_boundary_freeze_addendum.md
  - apps/server/src/core/migrations/migrations.ts
---

# `Personal minimal edit cloud deployment repair` 执行回执

## 1. Scope

- 本回执只记录 `Personal minimal edit` 的 cloud-only runtime repair。
- 本回执只覆盖：
  - active cloud ingress `:80`
  - active BFF `:3000`
  - active Server `:3001`
  - active object-storage transport
  - nickname live chain
  - avatar live chain
- 本回执不表示：
  - local runtime reopened
  - infra-platform rewrite
  - full BFF / Server containerization migration
  - OCR / real-name / company / certification / review package opening

## 2. Root Cause

- 用户实测失败的直接原因不是 `Personal minimal edit` 源码缺失。
- 直接原因是 cloud active runtime 与当前 repo package 曾经存在 drift：
  - active BFF 缺少 `personal/nickname` and `personal/avatar` route family
  - active Server upload init remained on the old `businessType=project` limitation
  - active BFF upstream was not aligned with active Server `:3001`
- 本轮修复后，active ingress now verifies against:
  - `nginx :80 -> BFF :3000`
  - `BFF :3000 -> Server :3001`

## 3. Repair Actions Recorded

- Aligned active BFF upstream to active Server `:3001`.
- Aligned active Server runtime identity for the isolated auth path.
- Aligned active Server auth secret material from the already-running cloud runtime into the active env without recording or exposing secret values in SSOT.
- Repaired active DB carrier compatibility for auth event materialization:
  - `audit_logs.actor_id` is nullable
  - `audit_logs.occurred_at` has `DEFAULT now()`
- Recorded matching migration hardening in:
  - `apps/server/src/core/migrations/migrations.ts`

## 4. Object Storage Decision

- The boundary freeze allowed cloud `MinIO Docker` deployment if required for upload transport.
- Execution found that the active cloud Server already uses a real S3-compatible OSS endpoint for avatar upload.
- The live avatar chain passed through that object-storage transport:
  - upload init
  - direct `PUT`
  - confirm
  - avatar commit
- Therefore this repair did not switch the active runtime to MinIO Docker.
- This is intentional:
  - the goal was bounded cloud active repair
  - not object-storage architecture replacement
  - not full platform containerization

## 5. Active Ingress Validation

All validation below was performed through active cloud ingress `:80`.

### 5.1 Health

- `GET /health/bff/live` returned `200`.
- `GET /health/server/live` returned `200`.
- `exhibition-bff` service was active.
- `exhibition-server` service was active.

### 5.2 Auth

- `POST /api/app/auth/otp/login` with the controlled test account returned `200`.
- Response included an access token.
- Response shell state was:
  - `authenticated`

### 5.3 Nickname

- Invalid nickname probe:
  - `POST /api/app/profile/personal/nickname`
  - invalid nickname `A1`
  - returned `400`
  - returned code `PERSONAL_NICKNAME_INVALID`
- Valid nickname probe:
  - `POST /api/app/profile/personal/nickname`
  - valid nickname `重庆海川展览工厂`
  - returned `200`
  - returned `ok=true`
- Shell readback after nickname:
  - `GET /api/app/shell/context`
  - returned `displayName=重庆海川展览工厂`

### 5.4 Avatar

- Invalid avatar init probe:
  - `POST /api/app/file/upload/init`
  - `businessType=profile`
  - `fileKind=avatar`
  - `mimeType=text/plain`
  - returned `400`
  - returned code `FILE_UPLOAD_INIT_INVALID`
- Valid avatar init probe:
  - `POST /api/app/file/upload/init`
  - `businessType=profile`
  - `fileKind=avatar`
  - `mimeType=image/png`
  - returned `200`
  - returned an upload session
  - returned a direct upload directive
  - returned confirm endpoint `/api/app/file/upload/confirm`
- Direct upload probe:
  - direct `PUT` to object storage returned `200`
- Confirm probe:
  - `POST /api/app/file/upload/confirm`
  - returned `200`
  - returned `fileAssetId`
- Invalid avatar commit probe:
  - `POST /api/app/profile/personal/avatar`
  - invalid all-zero `fileAssetId`
  - returned `404`
  - returned code `PERSONAL_AVATAR_FILE_UNAVAILABLE`
- Valid avatar commit probe:
  - `POST /api/app/profile/personal/avatar`
  - confirmed `fileAssetId`
  - returned `200`
  - returned `ok=true`
  - returned an app-facing `avatarUrl`
- Shell / profile readback after avatar:
  - `GET /api/app/shell/context` returned `avatarUrl`
  - `GET /api/app/profile/index` returned `avatarUrl`

## 6. Retained Boundaries

- No local runtime repair was reopened.
- No local Docker / local MinIO path is authoritative.
- No OCR package was opened.
- No real-name package was opened.
- No company editing package was opened.
- No certification simplification package was opened.
- No review-console package was opened.
- No `payment / billing / V2.3` package was opened.
- No full BFF / Server containerization rewrite was performed.

## 7. Stage Decision

- `Personal minimal edit cloud deployment repair` is complete for code-level and active cloud ingress validation.
- Current next action:
  - user clears app cache / restarts the app
  - user reruns live UI tests for nickname and avatar
- If UI live tests still fail after cache cleanup, the next package must be a narrow UI/runtime integration correction, not another cloud deployment rewrite by default.

