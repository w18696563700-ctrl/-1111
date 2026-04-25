---
owner: Codex 总控
status: frozen
purpose: Freeze L2 app-facing contracts for project communication text-chat, project album, and counterparty rating.
layer: L2 Contracts
freeze_date_local: 2026-04-24
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_field_table_addendum.md
  - docs/00_ssot/project_communication_album_rating_route_table_addendum.md
---

# 《项目沟通 / 相册 / 互评 contracts freeze》

## 1. Project Communication Contracts

- `GET /api/app/message/project-communication/thread`
  - query:
    - `projectId`
    - `counterpartOrganizationId`
  - response:
    - `threadId`
    - `projectId`
    - `counterpartOrganizationId`
    - `threadState`
- `GET /api/app/message/project-communication/messages`
  - query:
    - `threadId`
    - `projectId`
    - `cursor?`
    - `limit?`
  - response:
    - `items[]`
    - `nextCursor`
- `POST /api/app/message/project-communication/messages`
  - body:
    - `threadId`
    - `projectId`
    - `body`
    - `clientMessageId?`
  - response:
    - `messageId`
    - `threadId`
    - `projectId`
    - `body`
    - `createdAt`

## 2. Project Album Contracts

- `GET /api/app/project/:projectId/album/photos`
  - response:
    - `projectId`
    - `limit = 50`
    - `items[]`
- `POST /api/app/project/:projectId/album/photos`
  - body:
    - `fileAssetId`
    - `category`
    - `caption?`
    - `sortOrder?`
  - response:
    - `photoId`
    - `projectId`
    - `fileAssetId`
    - `category`
    - `photoState`
- `DELETE /api/app/project/:projectId/album/photos/:photoId`
  - response:
    - `projectId`
    - `photoId`
    - `photoState = removed`

## 3. Counterparty Rating Contracts

- `GET /api/app/project-counterparty-rating/entry`
  - query:
    - `orderId`
    - `projectId`
    - `rateeOrganizationId`
  - response:
    - `canRate`
    - `reason`
    - `existingRatingId?`
- `POST /api/app/project-counterparty-rating/submit`
  - body:
    - `orderId`
    - `projectId`
    - `rateeOrganizationId`
    - `scoreLabel`
    - `commentText?`
  - response:
    - `ratingId`
    - `orderId`
    - `projectId`
    - `ratingState`

## 4. Error Codes

- `PROJECT_COMMUNICATION_INVALID`
- `PROJECT_COMMUNICATION_FORBIDDEN`
- `PROJECT_COMMUNICATION_UNAVAILABLE`
- `PROJECT_ALBUM_INVALID`
- `PROJECT_ALBUM_FORBIDDEN`
- `PROJECT_ALBUM_LIMIT_EXCEEDED`
- `PROJECT_ALBUM_UNAVAILABLE`
- `PROJECT_COUNTERPARTY_RATING_INVALID`
- `PROJECT_COUNTERPARTY_RATING_FORBIDDEN`
- `PROJECT_COUNTERPARTY_RATING_DUPLICATE`
- `PROJECT_COUNTERPARTY_RATING_UNAVAILABLE`
