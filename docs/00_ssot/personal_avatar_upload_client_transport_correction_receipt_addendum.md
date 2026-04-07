---
owner: Codex 总控
status: frozen
purpose: Record the client-side avatar direct-upload transport correction and the remaining avatar crop/rotate UX gap as a separate not-yet-opened package.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/personal_minimal_edit_boundary_freeze_addendum.md
  - docs/00_ssot/personal_minimal_edit_cloud_deployment_repair_execution_receipt_addendum.md
  - apps/mobile/lib/core/api/app_api_client.dart
  - apps/mobile/lib/features/profile/presentation/profile_personal_edit_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_avatar_picker.dart
---

# `personal avatar upload client transport` 纠偏回执

## 1. Scope

- 本回执只记录 `Personal minimal edit` 头像上传的客户端直传 transport 纠偏。
- 本回执不打开：
  - avatar cropper/editor package
  - OCR
  - real-name
  - company / certification / review
  - broader profile editing

## 2. Findings

- 用户提供的真实 JPEG 图片可通过 cloud active ingress 完整走通：
  - login
  - upload init with `businessType=profile` and `fileKind=avatar`
  - direct object-storage `PUT`
  - upload confirm
  - avatar commit
- 因此当前根因不是 cloud BFF / Server / OSS 不支持真实头像图片。
- Flutter 当前头像页仍然是：
  - pick image
  - immediately upload
  - confirm
  - commit
- Flutter 当前没有：
  - crop
  - rotate
  - restore
  - cancel / done confirmation editor

## 3. Correction

- `HttpAppApiTransport.upload()` now sets:
  - `contentLength = bodyBytes.length`
- This avoids chunked-transfer ambiguity during direct object-storage `PUT`.
- The correction is intentionally minimal and does not change:
  - upload route
  - upload truth model
  - `FileAsset` truth
  - avatar commit truth

## 4. Validation

- `flutter analyze` passed for:
  - `lib/core/api/app_api_client.dart`
  - `lib/features/profile/data/profile_personal_edit_consumer_layer.dart`
  - `lib/features/profile/presentation/profile_personal_edit_pages.dart`
  - `test/profile_personal_minimal_edit_test.dart`
- `flutter test test/profile_personal_minimal_edit_test.dart` passed.
- `flutter test test/profile_identity_contract_compat_test.dart` passed.

## 5. Remaining Gap

- Avatar crop/rotate/restore UX is a real product gap.
- It must be opened as a separate bounded package because the existing `Personal minimal edit` freeze explicitly avoided cropper/editor expansion.
- Recommended next package:
  - `Personal avatar edit confirmation`
- Recommended scope:
  - image preview
  - square crop
  - rotate
  - restore
  - cancel
  - done
  - upload only after confirmation

