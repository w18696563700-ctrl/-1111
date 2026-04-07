---
owner: Codex 总控
status: frozen
purpose: Freeze the bounded `Personal avatar edit confirmation` package so avatar crop / rotate / restore / cancel / done may be added before upload without changing backend truth, upload truth, or broader profile scope.
layer: L0 SSOT
freeze_date_local: 2026-04-06
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/personal_minimal_edit_boundary_freeze_addendum.md
  - docs/00_ssot/personal_avatar_upload_client_transport_correction_receipt_addendum.md
  - apps/mobile/lib/features/profile/presentation/profile_personal_edit_pages.dart
  - apps/mobile/lib/features/profile/presentation/profile_avatar_picker.dart
  - apps/mobile/lib/features/profile/data/profile_personal_edit_consumer_layer.dart
  - apps/mobile/pubspec.yaml
---

# `Personal avatar edit confirmation` 边界冻结单

## 1. Scope

- 本轮唯一对象只限：
  - `个人头像` 页面
  - image picked from camera / gallery
  - upload-before-confirmation UX correction
- 本轮唯一目标只限：
  - 用户选择图片后先进入确认编辑面
  - 用户确认后才进入 existing avatar upload chain
- 本轮不改变：
  - backend route
  - BFF route
  - upload truth
  - `FileAsset` truth
  - `users.avatar_file_asset_id`
  - shell/profile readback truth

## 2. Current Accepted Baseline

- `Personal minimal edit` 已实现：
  - avatar row
  - `个人头像` page
  - `更换头像`
  - camera / gallery picker
  - `init -> direct upload -> confirm -> commit -> reloadShellContext`
- `personal avatar upload client transport` 已修正：
  - direct upload now sets content length
- Active cloud ingress has already proven real JPEG upload can pass through:
  - upload init
  - direct object-storage PUT
  - confirm
  - commit
- 当前用户体验缺口是真实存在的：
  - pick image 后立即上传
  - 没有裁切
  - 没有旋转
  - 没有还原
  - 没有取消 / 完成确认

## 3. Frozen UX Object

- 新增的最小编辑确认面必须包含：
  - image preview
  - square crop frame
  - rotate
  - restore
  - cancel
  - done
- 只有用户点击 `完成` 后，才允许调用现有 avatar upload chain。
- 用户点击 `取消` 后：
  - 不得 init upload
  - 不得 direct upload
  - 不得 confirm
  - 不得 commit avatar

## 4. Allowed Implementation Surface

- 本轮只允许修改：
  - `apps/mobile/lib/features/profile/presentation/profile_personal_edit_pages.dart`
  - `apps/mobile/lib/features/profile/presentation/profile_avatar_picker.dart`
  - `apps/mobile/lib/features/profile/presentation/**` 中头像确认编辑所需的最小新文件
  - `apps/mobile/test/profile_personal_minimal_edit_test.dart`
  - `apps/mobile/pubspec.yaml`
- 如引入依赖，只允许引入一个用于 image crop / rotate 的最小 Flutter dependency。
- 不允许引入：
  - full photo editor
  - filter framework
  - AI image processing
  - avatar history library

## 5. Explicit Out-of-scope

- backend / BFF changes
- object storage changes
- upload route changes
- nickname changes
- real-name
- OCR
- company editing
- certification / review
- messages / exhibition
- payment / billing
- `V2.3`

## 6. Acceptance Standard

- Selecting `拍照` or `从相册选择` opens a confirmation editor before upload.
- Confirmation editor exposes:
  - `旋转`
  - `还原`
  - `取消`
  - `完成`
- `取消` does not call upload init.
- `完成` calls the existing avatar upload chain using the edited image bytes.
- Upload still uses:
  - `businessType=profile`
  - `fileKind=avatar`
  - `FileAsset` truth
  - shell context readback
- Existing avatar fail-closed behavior remains intact.

## 7. Stage Gate Checklist

### Passed gates

- `Personal minimal edit` avatar upload chain exists.
- Cloud ingress upload proof exists.
- Client transport content-length correction exists.
- UX gap has been isolated to avatar confirmation editing.

### Failed gates

- Avatar crop / rotate / restore UX not yet implemented.
- Current selected image uploads immediately after pick.

### Veto gates

- If this package changes backend / BFF, veto.
- If this package changes upload truth, veto.
- If this package expands into OCR / real-name / certification / review, veto.
- If this package adds filters / AI / avatar history, veto.

## 8. Stage Decision

- `Go for bounded frontend-only avatar edit confirmation execution`

## 9. Next Unique Action

- Execute `Personal avatar edit confirmation` in Flutter only.

