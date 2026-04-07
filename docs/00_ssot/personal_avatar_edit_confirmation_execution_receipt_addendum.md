---
owner: Codex 总控
status: frozen
purpose: Record the bounded frontend execution for `Personal avatar edit confirmation`, including crop / rotate / restore / cancel / done before the existing avatar upload chain.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/personal_minimal_edit_boundary_freeze_addendum.md
  - docs/00_ssot/personal_avatar_upload_client_transport_correction_receipt_addendum.md
  - docs/00_ssot/personal_avatar_edit_confirmation_boundary_freeze_addendum.md
  - apps/mobile/lib/core/api/app_api_client.dart
  - apps/mobile/lib/features/profile/presentation/profile_personal_edit_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_avatar_edit_confirmation_page.dart
  - apps/mobile/test/profile_personal_minimal_edit_test.dart
  - apps/mobile/pubspec.yaml
---

# `Personal avatar edit confirmation` 执行回执

## 1. Scope

- 本回执只记录 `Personal avatar edit confirmation` 的 bounded frontend-only implementation。
- 本轮唯一目标：
  - 用户选择头像图片后先进入确认编辑页
  - 用户点击 `完成` 后才进入既有头像上传链
  - 用户点击 `取消` 时不得触发 upload init / direct upload / confirm / commit
- 本轮没有改变：
  - backend route
  - BFF route
  - object storage route
  - upload truth
  - `FileAsset` truth
  - `users.avatar_file_asset_id`
  - shell/profile readback truth

## 2. Shipped Behavior

- 新增 `个人头像` 的确认编辑面：
  - title: `调整头像`
  - square crop frame
  - `旋转`
  - `还原`
  - `取消`
  - `完成`
- `拍照` 或 `从相册选择` 后不再立即上传。
- `取消` 返回头像页并停止本次上传。
- `完成` 输出编辑后的 image bytes，并继续复用既有：
  - `init`
  - direct upload
  - `confirm`
  - avatar `commit`
  - `reloadShellContext`
- rotate / restore 都只在 Flutter editor 内完成，不改变后端头像业务真相。

## 3. Transport Correction Retained

- `HttpAppApiTransport.upload()` continues to set direct-upload `contentLength`.
- The cloud active ingress proof with the user's real JPEG remains valid:
  - login
  - profile/avatar upload init
  - direct object-storage PUT
  - confirm
  - avatar commit
- The client correction and the confirmation editor solve different layers:
  - direct upload stability
  - user confirmation UX

## 4. Dependencies

- Added bounded Flutter dependencies:
  - `crop_your_image`
  - `image`
- Dependency scope is limited to:
  - square crop
  - image rotation
  - edited image byte output
- No cropper/editor dependency is allowed to expand into:
  - filter framework
  - avatar history
  - AI image processing
  - broader personal-profile editing

## 5. Retained Boundaries

- No backend / BFF changes.
- No object-storage truth changes.
- No upload route changes.
- No nickname behavior changes.
- No OCR.
- No real-name.
- No company editing.
- No certification / review.
- No messages / exhibition scope.
- No payment / billing / `V2.3`.

## 6. Validation Evidence

- `flutter analyze` passed for:
  - `lib/core/api/app_api_client.dart`
  - `lib/features/profile/data/profile_personal_edit_consumer_layer.dart`
  - `lib/features/profile/presentation/profile_avatar_edit_confirmation_page.dart`
  - `lib/features/profile/presentation/profile_avatar_picker.dart`
  - `lib/features/profile/presentation/profile_detail_pages.dart`
  - `lib/features/profile/presentation/profile_personal_edit_pages.dart`
  - `test/profile_personal_minimal_edit_test.dart`
  - `test/profile_identity_contract_compat_test.dart`
- `flutter test test/profile_personal_minimal_edit_test.dart` passed.
- `flutter test test/profile_identity_contract_compat_test.dart` passed.
- Focused avatar test now verifies:
  - editor appears after gallery selection
  - `旋转 / 还原 / 完成` are visible
  - upload init is not called before `完成`
  - `完成` triggers the existing upload chain
  - shell reload updates avatar readback

## 7. Stage Result

- `Personal avatar edit confirmation` frontend implementation is complete at code level.
- The next user action is live app retest after rebuild / hot restart.
- Clearing cache alone is not sufficient if the running Flutter app has not loaded the new code and dependencies.

