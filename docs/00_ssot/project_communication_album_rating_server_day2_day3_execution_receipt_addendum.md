---
owner: Codex 总控
status: completed
purpose: Record Day-2 and Day-3 Server execution receipt for project communication text chat and project album.
layer: L0 SSOT
updated_at: 2026-04-24
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/02_backend/project_communication_album_rating_backend_truth_persistence_freeze_addendum.md
---

# 《项目沟通 / 相册 Day-2 Day-3 Server 执行回执》

## 1. Completed Scope

- `ProjectCommunicationThread` 已落地为 Server truth entity。
- `ProjectCommunicationMessage` 已落地为 Server truth entity。
- `ProjectCommunicationReadCursor` 已落地为 Server truth entity。
- `ProjectAlbumPhoto` 已落地为 Server truth entity。
- migration 已新增：
  - `project_communication_threads`
  - `project_communication_messages`
  - `project_communication_read_cursors`
  - `project_album_photos`
- Server route 已新增：
  - `GET /server/project-communication/thread`
  - `GET /server/project-communication/messages`
  - `POST /server/project-communication/messages`
  - `POST /server/project-communication/read-cursor`
  - `GET /server/projects/:projectId/album/photos`
  - `POST /server/projects/:projectId/album/photos`
  - `DELETE /server/projects/:projectId/album/photos/:photoId`

## 2. Guardrails Verified

- 聊天线程不允许变成 generic DM。
- 发送消息必须携带 `projectId`。
- 相册照片必须携带 `projectId`。
- 相册 active 照片上限 `50` 在 Server service 层执行。
- 相册绑定只接受 `FileAsset.businessType = project`。
- 相册绑定只接受 `FileAsset.fileKind = project_album_photo`。
- 相册绑定只接受 image mime。
- 上传 init 已允许 `project/project_album_photo`，且拒绝非图片。

## 3. Regression Commands

- `corepack pnpm --dir apps/server build`
- `node --test apps/server/test/project-communication-album.test.cjs apps/server/test/upload-transport.test.cjs apps/server/test/project-attachment-corridor.test.cjs apps/server/test/message-interaction-bid-carry.test.cjs`

Result:

- build passed.
- 36 tests passed.

## 4. Explicit No-Go / Not Yet Done

- BFF app-facing route 尚未实现。
- Flutter 项目沟通页、输入框、项目相册 UI 尚未实现。
- `ProjectCounterpartyRating` 尚未进入本轮代码实现，只完成文书冻结。
- 云上后端/BFF 尚未发版。
- 本回执只证明本地 Server source implementation 可构建、可测试。

## 5. Next Gate

- 下一阶段允许进入：
  - BFF route mapping。
  - Flutter consumption implementation。
  - 云上发版前的 Server migration dry-run / staging probe。
- 下一阶段仍禁止：
  - 生产切主入口。
  - 不经 BFF 让 Flutter 直连 Server。
  - 在没有 `projectId` 的情况下创建聊天、相册或评价。
