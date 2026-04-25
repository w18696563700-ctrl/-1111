---
owner: Codex 总控
status: frozen
purpose: Freeze the field table for project communication text-chat, project album, and counterparty rating.
layer: L0 SSOT
freeze_date_local: 2026-04-24
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
---

# 《项目沟通 / 相册 / 互评字段表》

## 1. ProjectCommunicationThread

| Field | Required | Notes |
|---|---:|---|
| `threadId` | yes | Server generated id |
| `projectId` | yes | 强制项目锚点 |
| `ownerOrganizationId` | yes | 项目发布方组织 |
| `counterpartOrganizationId` | yes | 对方组织 |
| `threadState` | yes | `open / closed` |
| `lastMessageId` | no | 最近消息 |
| `lastMessageAt` | no | 最近消息时间 |
| `createdAt` | yes | 创建时间 |
| `updatedAt` | yes | 更新时间 |

Unique:

- `projectId + ownerOrganizationId + counterpartOrganizationId`

## 2. ProjectCommunicationMessage

| Field | Required | Notes |
|---|---:|---|
| `messageId` | yes | Server generated id |
| `threadId` | yes | 沟通线程 |
| `projectId` | yes | 强制项目锚点 |
| `senderUserId` | yes | 发送用户 |
| `senderActorId` | no | 当前 actor |
| `senderOrganizationId` | yes | 发送组织 |
| `messageKind` | yes | 首版固定 `text` |
| `body` | yes | 文字内容 |
| `clientMessageId` | no | Flutter 发送幂等键 |
| `messageState` | yes | `active / removed` |
| `createdAt` | yes | 创建时间 |

Constraints:

- `body` trim 后不能为空。
- 首版不允许附件字段。
- 若存在 `clientMessageId`，同一 `threadId + senderOrganizationId + clientMessageId` 幂等。

## 3. ProjectCommunicationReadCursor

| Field | Required | Notes |
|---|---:|---|
| `threadId` | yes | 沟通线程 |
| `projectId` | yes | 强制项目锚点 |
| `organizationId` | yes | 已读组织 |
| `lastReadMessageId` | no | 最近已读消息 |
| `lastReadAt` | yes | 已读时间 |
| `updatedAt` | yes | 更新时间 |

Unique:

- `threadId + organizationId`

## 4. ProjectAlbumPhoto

| Field | Required | Notes |
|---|---:|---|
| `photoId` | yes | Server generated id |
| `projectId` | yes | 强制项目锚点 |
| `fileAssetId` | yes | FileAsset 真值 |
| `category` | yes | `contract / progress / final / defect` |
| `caption` | no | 照片说明 |
| `mimeType` | yes | 仅 image |
| `sortOrder` | yes | 列表排序 |
| `photoState` | yes | `active / removed` |
| `uploadedByUserId` | yes | 上传用户 |
| `uploadedByActorId` | no | 上传 actor |
| `uploadedByOrganizationId` | yes | 上传组织 |
| `createdAt` | yes | 创建时间 |
| `removedAt` | no | 删除时间 |

Limits:

- 每个 `projectId` 最多 `50` 张 `active` 照片。
- `fileAssetId` 不允许在同一项目 active 重复绑定。

## 5. ProjectCounterpartyRating

| Field | Required | Notes |
|---|---:|---|
| `ratingId` | yes | Server generated id |
| `orderId` | yes | 订单锚点 |
| `projectId` | yes | 项目锚点 |
| `raterOrganizationId` | yes | 评价方 |
| `rateeOrganizationId` | yes | 被评价方 |
| `raterUserId` | yes | 评价用户 |
| `scoreValue` | yes | 1-5 或映射到信用分 |
| `scoreLabel` | yes | `very_satisfied / satisfied / passable / negative` |
| `commentText` | no | 文字评价 |
| `ratingState` | yes | `submitted` |
| `submittedAt` | yes | 提交时间 |

Unique:

- `orderId + raterOrganizationId + rateeOrganizationId`

## 6. Projection Fields

| Surface | Field | Notes |
|---|---|---|
| counterpart detail | `projectCommunication.threadId` | 文本聊天线程 |
| counterpart detail | `projectCommunication.latestMessages[]` | 最近消息 |
| counterpart detail | `projectAlbum.photoCount` | 当前 active 照片数 |
| counterpart detail | `projectAlbum.categories[]` | 四类照片摘要 |
| counterpart detail | `ratingEntry.canRate` | 是否可评价 |
| counterpart detail | `ratingEntry.reason` | 不可评价原因 |
