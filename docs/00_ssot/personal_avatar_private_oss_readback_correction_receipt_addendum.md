---
owner: Codex 总控
status: frozen
purpose: Record the bounded Server correction for private OSS avatar readback, where app-facing avatarUrl must be a readable access URL rather than a private-bucket static object URL.
layer: L0 SSOT
freeze_date_local: 2026-04-07
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/personal_avatar_completion_readback_correction_receipt_addendum.md
  - apps/server/src/modules/upload/upload-public-url.service.ts
  - apps/server/src/modules/profile/profile-personal.write.service.ts
  - apps/server/src/modules/profile/profile-query.service.ts
  - apps/server/src/modules/shell/shell-query.service.ts
  - apps/server/src/modules/shell/shell.module.ts
---

# `Personal avatar private OSS readback` 纠偏回执

## 1. Scope

- 本回执只记录头像展示 URL 的 bounded Server correction。
- 本轮没有改变：
  - upload init / direct upload / confirm / commit truth
  - `FileAsset` truth
  - `users.avatar_file_asset_id`
  - object storage bucket ACL
  - BFF route family
  - Flutter crop / rotate UX

## 2. Root Cause

- `shell/context` and `profile/index` had already returned `avatarUrl`.
- The returned URL was a static OSS object URL.
- The active OSS bucket is private.
- Direct access to the static object URL returned `403 Forbidden`.
- Flutter `Image.network` correctly fell back to the placeholder avatar after image load failure.
- Therefore the visible old/fallback avatar was caused by unreadable avatar projection, not by missing avatar commit.

## 3. Correction

- `UploadPublicUrlService` now supports signed object access URL generation.
- Server still stores the stable avatar projection in `users.avatar_url`.
- App-facing readback now returns a readable signed access URL for:
  - `shell/context`
  - `profile/index`
  - personal avatar command response
- The correction preserves:
  - file content in OSS
  - file truth in `FileAsset`
  - user avatar truth in `users.avatar_file_asset_id`

## 4. Cloud Deployment

- The bounded Server correction was copied into the active cloud Server release.
- Cloud Server build passed.
- `exhibition-server` was restarted and returned `active`.
- BFF was not changed.
- Flutter was not changed in this correction.

## 5. Validation Evidence

- Local `apps/server` `npm run build` passed.
- Active cloud `shell/context` returned an avatar URL with signed access query parameters.
- Active cloud `profile/index` returned the same signed avatar projection.
- Direct `GET` of the returned signed avatar URL returned:
  - HTTP `200`
  - JPEG bytes
- `HEAD` against a GET-signed URL is not valid evidence because the signed HTTP method differs.

## 6. Stage Result

- `Personal avatar private OSS readback` correction is complete at active cloud runtime level.
- Next user action:
  - restart / reload the app so it fetches a fresh `shell/context`
  - retest avatar display

