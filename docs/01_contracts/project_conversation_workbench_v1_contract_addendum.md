---
owner: Codex 总控
status: accepted
purpose: Freeze additive contracts for Project Conversation Workbench V1 messages, attachments, confirmation cards, and App soft reminder boundaries.
layer: L2 Contracts
---

# 《项目沟通工作台 V1 Contracts Addendum》

## 1. Contract Scope

This addendum extends the existing project communication App contract without replacing the thread truth.

Canonical App-facing routes:

- `GET /api/app/message/project-communication/thread`
- `GET /api/app/message/project-communication/messages`
- `POST /api/app/message/project-communication/messages`
- `POST /api/app/message/project-communication/read-cursor`
- `POST /api/app/file/upload/init`
- direct upload to signed URL
- `POST /api/app/file/upload/confirm`

All project communication messages remain bound to:

- `projectId`
- `threadId`

## 2. Message Kind

Allowed values:

```ts
type ProjectCommunicationMessageKind =
  | 'text'
  | 'image'
  | 'file'
  | 'confirmation_card';
```

Compatibility:

- Missing `messageKind` from old clients is treated as `text`.
- Existing text messages with no `payload` remain valid.
- Unknown `messageKind` must return controlled `PROJECT_COMMUNICATION_INVALID`.

## 3. Send Message Request

Route:

```http
POST /api/app/message/project-communication/messages
```

Base fields:

```ts
type ProjectCommunicationSendMessageRequest = {
  threadId: string;
  projectId: string;
  messageKind?: ProjectCommunicationMessageKind;
  body?: string;
  clientMessageId?: string | null;
  payload?: ProjectCommunicationMessagePayload | null;
};
```

### 3.1 Text Payload

```ts
type TextMessageRequest = {
  messageKind?: 'text';
  body: string;
  payload?: null;
};
```

Rules:

- `body` is required.
- `body` max length: existing project communication body max.
- `payload` is optional and ignored when null.

### 3.2 Image Payload

```ts
type ImageMessageRequest = {
  messageKind: 'image';
  body?: string;
  payload: {
    attachment: {
      fileAssetId: string;
      fileName: string;
      mimeType: string;
      size: number;
      category: 'image';
    };
  };
};
```

Rules:

- `fileAssetId` must point to confirmed `FileAsset`.
- `FileAsset.businessType` must be `project`.
- `FileAsset.businessId` must equal request `projectId`.
- `FileAsset.organizationId` must match sender organization.
- `mimeType` must start with `image/`.
- `objectKey` must not appear in App-facing message payload.

### 3.3 File Payload

```ts
type FileMessageRequest = {
  messageKind: 'file';
  body?: string;
  payload: {
    attachment: {
      fileAssetId: string;
      fileName: string;
      mimeType: string;
      size: number;
      category: 'file';
    };
  };
};
```

Rules:

- Same `FileAsset` binding rules as image.
- `mimeType` may be document/image/spreadsheet-compatible according to upload policy.
- Files are displayed as work attachments, not as project album photos.

### 3.4 Confirmation Card Payload

```ts
type ConfirmationCardMessageRequest = {
  messageKind: 'confirmation_card';
  body?: string;
  payload: {
    confirmation: {
      confirmationType: 'quote' | 'material_process' | 'schedule';
      title: string;
      summary: string;
      status?: 'proposed';
    };
  };
};
```

Rules:

- `confirmationType` must be in the whitelist.
- `title` and `summary` are required.
- `status` defaults to `proposed`.
- Confirmation cards do not mutate order, contract, audit, or fulfillment state in V1.

## 4. Message Response

```ts
type ProjectCommunicationMessageView = {
  messageId: string;
  threadId: string;
  projectId: string;
  senderUserId: string;
  senderActorId: string | null;
  senderOrganizationId: string;
  messageKind: ProjectCommunicationMessageKind;
  body: string;
  payload: ProjectCommunicationMessagePayload | null;
  clientMessageId: string | null;
  messageState: 'active' | string;
  createdAt: string;
};
```

For old text messages, response must include:

```json
{
  "messageKind": "text",
  "payload": null
}
```

## 5. Message List Response

```ts
type ProjectCommunicationMessageListView = {
  items: ProjectCommunicationMessageView[];
  nextCursor: string | null;
};
```

The list order stays ascending by `createdAt`, then `id`.

## 6. Upload Contract Usage

Image / file sending flow:

1. `POST /api/app/file/upload/init`
2. direct upload to returned signed URL
3. `POST /api/app/file/upload/confirm`
4. `POST /api/app/message/project-communication/messages`

Upload init for this workbench must use:

```json
{
  "businessType": "project",
  "businessId": "<projectId>",
  "fileKind": "project_communication_attachment",
  "mimeType": "<mime>",
  "size": 123,
  "checksum": "<checksum>"
}
```

Images and files are uploaded as dedicated project communication attachments in this workbench. The message payload category decides image vs file presentation.

## 7. Error Codes

| Code | When |
| --- | --- |
| `PROJECT_COMMUNICATION_INVALID` | Invalid body, unsupported message kind, invalid payload shape, invalid confirmation type |
| `PROJECT_COMMUNICATION_FORBIDDEN` | Sender is not allowed in this `projectId + threadId` |
| `PROJECT_COMMUNICATION_UNAVAILABLE` | Thread/message route or dependency unavailable |
| `AUTH_SESSION_INVALID` | Login/session invalid |
| `FILE_UPLOAD_INIT_FAILED` | Upload init failed |
| `FILE_UPLOAD_CONFIRM_REQUIRED` | Upload confirm failed or missing FileAsset truth |

Server may include more specific internal messages, but BFF must normalize to controlled App-facing errors.

## 8. Contact Soft Prompt

The contact soft prompt is an App-local UX contract.

No Server/BFF route is added for V1.

Detection tokens:

- phone-like number
- `微信`
- `QQ`
- `联系我`
- `加我`
- `电话多少`

User choices:

- `返回修改`: dismiss modal and keep draft.
- `继续发送`: send original content.

## 9. Backward Compatibility

- Old clients may continue sending `{ threadId, projectId, body, clientMessageId }`.
- Server and BFF must treat missing `messageKind` as `text`.
- Flutter must handle `payload: null`.
- Realtime event payload must remain compatible with text messages and may include `payload` for new kinds.

## 10. Explicit Non-Goals

The contract does not define:

- generic DM
- group chat
- push notification
- server-side contact blocking
- confirmation-card approval workflow
- order/contract/fulfillment state mutation
- message deletion or recall
