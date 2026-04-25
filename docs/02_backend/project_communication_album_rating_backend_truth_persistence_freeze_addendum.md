---
owner: Codex 总控
status: frozen
purpose: Freeze L3 Server truth and persistence for project communication, project album, and counterparty rating.
layer: L3 Backend
freeze_date_local: 2026-04-24
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
---

# 《项目沟通 / 相册 / 互评 backend truth persistence freeze》

## 1. Tables

- `project_communication_threads`
- `project_communication_messages`
- `project_communication_read_cursors`
- `project_album_photos`
- `project_counterparty_ratings`

## 2. Server Responsibilities

- 校验项目存在、项目参与方关系、组织权限。
- 创建或读取沟通线程。
- 写入文字消息并审计。
- 维护已读游标。
- 校验相册图片 FileAsset。
- 执行项目相册 `50` 张 active 上限。
- 校验互评开放条件。
- 防止互评重复提交。
- 互评提交后触发信用 shadow recompute 或 ledger trigger。

## 3. Reuse Rules

- 上传必须复用现有三段上传：
  - init
  - direct upload
  - confirm
- `FileAsset` 是文件真值。
- 现有 owner-private `project_attachments` 不作为本轮相册真值。
- 现有 `rating` 可作为信用接入参考，但不得强行复用成双方互评，除非字段和方向性满足 `rater/ratee`。

## 4. Migration Rules

- migration key 必须唯一。
- 表、索引、约束必须 idempotent。
- active 相册数量上限必须在 Server service 层执行，前端限制只是体验。
- `projectId` 字段不得 nullable。

## 5. Audit

- 必须记录：
  - `ProjectCommunicationMessageSent`
  - `ProjectAlbumPhotoBound`
  - `ProjectAlbumPhotoRemoved`
  - `ProjectCounterpartyRatingSubmitted`

## 6. No-Go

- 不得把聊天、相册、评价混写到同一表。
- 不得让 BFF 写入业务真值。
- 不得把互评结果直接写信用 aggregate，必须通过正式触发链。
