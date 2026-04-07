---
owner: Codex 总控
status: frozen
purpose: Record the bounded Flutter correction for avatar completion readback, where successful commit plus matching shell projection must not be misclassified as failure merely because the avatar URL did not change.
layer: L0 SSOT
freeze_date_local: 2026-04-07
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/personal_avatar_edit_confirmation_execution_receipt_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_personal_edit_pages.dart
  - apps/mobile/test/profile_personal_minimal_edit_test.dart
---

# `Personal avatar completion readback` 纠偏回执

## 1. Scope

- 本回执只记录 `Personal avatar edit confirmation` 最后一步 `完成` 后的 Flutter readback 判定纠偏。
- 本轮没有改变：
  - backend
  - BFF
  - object storage
  - upload truth
  - `FileAsset` truth
  - `users.avatar_file_asset_id`
  - crop / rotate / restore UX

## 2. Root Cause

- Cloud active runtime 日志显示用户点击 `完成` 后，头像链路已经到达并通过：
  - upload init
  - upload confirm
  - avatar commit
  - shell context reload
- 失败点不是云端 route / OSS / `FileAsset` truth。
- 失败点是 Flutter 侧成功判定过严：
  - 旧逻辑要求 `reloadedAvatarUrl` 必须存在且必须不同于上传前 `previousAvatarUrl`
  - 这会把连续测试、缓存投影、同 URL 投影等真实成功场景误判为 `头像回读当前未更新`

## 3. Correction

- Avatar completion now validates against the commit response projection:
  - read `commitResult.data.avatarUrl`
  - call `reloadShellContext()`
  - accept success when shell `avatarUrl` is present and, if commit returned an `avatarUrl`, shell readback equals the committed projection
- The correction keeps fail-closed behavior:
  - missing shell `avatarUrl` still fails
  - shell `avatarUrl` drifting away from committed projection still fails
  - local-only fake success remains disallowed

## 4. Validation Evidence

- `flutter analyze lib/features/profile/presentation/profile_personal_edit_pages.dart test/profile_personal_minimal_edit_test.dart` passed.
- `flutter test test/profile_personal_minimal_edit_test.dart --plain-name "avatar save reloads shell context and updates hub plus summary"` passed.
- `flutter test test/profile_personal_minimal_edit_test.dart` passed.
- `flutter test test/profile_identity_contract_compat_test.dart` passed.
- The avatar test now covers the exact regression:
  - initial shell avatar URL already equals the committed avatar URL
  - upload / commit / reload still must be accepted as success when shell readback matches the committed projection

## 5. Stage Result

- `Personal avatar completion readback` correction is complete at code level.
- Next user action:
  - rebuild / hot restart Flutter app
  - rerun live avatar completion test

