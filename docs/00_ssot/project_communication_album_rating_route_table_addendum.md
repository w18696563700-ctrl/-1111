---
owner: Codex 总控
status: frozen
purpose: Freeze the route/actionKey table for project communication, project album, and counterparty rating.
layer: L0 SSOT
freeze_date_local: 2026-04-24
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
---

# 《项目沟通 / 相册 / 互评路由表》

## 1. Server Routes

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/server/project-communication/thread` | 获取或创建项目沟通线程 |
| `GET` | `/server/project-communication/messages` | 读取文字消息 |
| `POST` | `/server/project-communication/messages` | 发送文字消息 |
| `POST` | `/server/project-communication/read-cursor` | 更新已读游标 |
| `GET` | `/server/projects/:projectId/album/photos` | 读取项目相册 |
| `POST` | `/server/projects/:projectId/album/photos` | 绑定项目相册照片 |
| `DELETE` | `/server/projects/:projectId/album/photos/:photoId` | 删除项目相册照片 |
| `GET` | `/server/project-counterparty-rating/entry` | 读取互评入口 |
| `POST` | `/server/project-counterparty-rating/submit` | 提交互评 |

## 2. App-Facing BFF Routes

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/app/message/project-communication/thread` | 获取项目沟通线程 |
| `GET` | `/api/app/message/project-communication/messages` | 读取文字消息 |
| `POST` | `/api/app/message/project-communication/messages` | 发送文字消息 |
| `POST` | `/api/app/message/project-communication/read-cursor` | 更新已读游标 |
| `GET` | `/api/app/project/:projectId/album/photos` | 读取项目相册 |
| `POST` | `/api/app/project/:projectId/album/photos` | 绑定项目相册照片 |
| `DELETE` | `/api/app/project/:projectId/album/photos/:photoId` | 删除项目相册照片 |
| `GET` | `/api/app/project-counterparty-rating/entry` | 读取互评入口 |
| `POST` | `/api/app/project-counterparty-rating/submit` | 提交互评 |

## 3. actionKey

| Object Type | actionKey | Required Params |
|---|---|---|
| `project_communication_thread` | `project_communication.open` | `projectId + counterpartOrganizationId` |
| `project_communication_message` | `project_communication.message.send` | `threadId + projectId` |
| `project_album` | `project_album.open` | `projectId` |
| `project_album_photo` | `project_album_photo.bind` | `projectId + fileAssetId + category` |
| `project_counterparty_rating` | `project_counterparty_rating.open` | `orderId + projectId + rateeOrganizationId` |
| `project_counterparty_rating` | `project_counterparty_rating.submit` | `orderId + projectId + raterOrganizationId + rateeOrganizationId` |

## 4. Compatibility Routes

- `project_name_access_thread.open` remains old carrier detail.
- `bid_thread.open` remains old carrier detail.
- Existing `GET /api/app/message/counterpart-conversation/detail` remains the unified container detail.

## 5. Veto

- No route may accept chat, album, or rating commands without `projectId`.
- Rating submit may not rely only on avatar/counterpart id.
- Album bind may not rely only on `objectKey`.
