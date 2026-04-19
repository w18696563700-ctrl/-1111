---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L2 app-facing contract boundary for Trading-scoped IM Round A,
  covering project public clarification, project-bid private thread, minimum
  confirmation cards, attachment binding, participant projection, lifecycle
  projection, messages-building reminder handoff, and the minimum error-code
  family.
layer: L2 Contracts
freeze_date_local: 2026-04-16
inputs_canonical:
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/00_ssot/trading_im_round_a_stage_gate_checklist_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
  - docs/00_ssot/source_of_truth_map.md
---

# 《交易场景 IM Round A contract freeze》

## 1. Scope

- 本冻结单只覆盖 Trading-scoped IM Round A app-facing contracts。
- 本冻结单不授权 implementation、integration、release-prep。
- 本冻结单不定义通用聊天中心、forum DM、stranger DM、group chat、
  WebSocket/SSE/push、read receipt、typing、online status。

## 2. Canonical App-facing Path Family

### 2.1 Project Public Clarification

- 当前冻结 app-facing paths:
  - `GET /api/app/project/clarification/list`
  - `POST /api/app/project/clarification/create`
- These paths are project-scoped and must require `projectId`.
- They must not become forum comment, project attachment list, or generic
  message center routes.

### 2.2 Project-Bid Private Thread

- 当前冻结 app-facing paths:
  - `GET /api/app/bid/thread/detail`
  - `POST /api/app/bid/thread/message/send`
- These paths are project-bid scoped and must require `projectId + bidId`.
- They must not become order/contract/dispute conversation routes.

### 2.3 Confirmation Card

- 当前冻结 app-facing path:
  - `POST /api/app/bid/thread/confirmation/create`
- Confirmation card is a child object of project-bid private thread.
- It must not become a generic confirmation system or contract confirmation.

### 2.4 Messages Building Reminder Projection

- Round A reminder handoff may be represented only as controlled
  `message/index` registered-entry projection.
- The projection may reference:
  - `project_clarification.open`
  - `bid_thread.open`
- It must not expose message/thread truth through `message/index`.
- It must not become a chat list API or station inbox.

## 3. Schema Freeze

### 3.1 ClarificationReadModel

- Minimum fields:
  - `clarificationId`
  - `projectId`
  - `authorRole`
  - `body`
  - `attachmentFileAssetIds`
  - `state`
  - `createdAt`
- `state` enum:
  - `active`
  - `hidden`
  - `archived`
- `hidden` and `archived` are lifecycle projections only in Round A; their
  commands remain No-Go until later governance freeze.

### 3.2 ProjectClarificationCreateRequest

- Minimum fields:
  - `projectId`
  - `body`
  - `attachmentFileAssetIds`
- `attachmentFileAssetIds` must contain confirmed `FileAssetId` only.

### 3.3 BidThreadDetailReadModel

- Minimum fields:
  - `threadId`
  - `projectId`
  - `bidId`
  - `participants`
  - `state`
  - `availability`
  - `messages`
  - `confirmationCards`
- `state` enum:
  - `open`
  - `restricted`
  - `archived`

### 3.4 BidThreadMessageSendRequest

- Minimum fields:
  - `projectId`
  - `bidId`
  - `body`
  - `attachmentFileAssetIds`
- `attachmentFileAssetIds` must contain confirmed `FileAssetId` only.

### 3.5 BidThreadMessageReadModel

- Minimum fields:
  - `messageId`
  - `threadId`
  - `projectId`
  - `bidId`
  - `senderRole`
  - `body`
  - `attachmentFileAssetIds`
  - `createdAt`
- No read receipt, typing, online status, or delivery state is admitted.

### 3.6 ConfirmationCardCreateRequest

- Minimum fields:
  - `projectId`
  - `bidId`
  - `confirmationType`
  - `summary`
  - `sourceMessageId`
- `confirmationType` enum:
  - `quote`
  - `craft_material`
  - `schedule`

### 3.7 ConfirmationCardReadModel

- Minimum fields:
  - `confirmationId`
  - `threadId`
  - `projectId`
  - `bidId`
  - `confirmationType`
  - `summary`
  - `sourceMessageId`
  - `createdAt`
- No revoke, void, edit, or workbench state is admitted in Round A.

### 3.8 Participant Projection

- Minimum fields per participant:
  - `participantRole`
  - `organizationId`
- `participantRole` enum:
  - `project_owner`
  - `bidder`
- Participant projection is visibility information only and is not permission
  truth outside Server.

### 3.9 Availability Projection

- Minimum fields:
  - `canSendMessage`
  - `canCreateConfirmation`
  - `reason`
- Availability is display guidance only. Server remains final permission owner.

## 4. Error Code Freeze

- Current Round A error codes:
  - `PROJECT_CLARIFICATION_UNAVAILABLE`
  - `PROJECT_CLARIFICATION_FORBIDDEN`
  - `BID_THREAD_UNAVAILABLE`
  - `BID_THREAD_FORBIDDEN`
  - `THREAD_MESSAGE_INVALID`
  - `THREAD_ATTACHMENT_INVALID`
  - `THREAD_CONFIRMATION_INVALID`
- Error owners remain Server unless a later BFF surface freeze explicitly
  narrows a controlled-unavailable projection.

## 5. Attachment Contract

- All Round A attachment references are `fileAssetId` references.
- The app-facing contract must not expose `objectKey`.
- Upload remains the shared three-step corridor:
  - init
  - direct upload
  - confirm
- Confirmed `FileAsset` must exist before any clarification/message business
  row binds an attachment.

## 6. Generated Contract Boundary

- `pnpm contracts:generate` is the only legal generated-contract update entry.
- Required generated outputs:
  - `packages/contracts/contracts-manifest.json`
  - `packages/contracts/openapi/openapi.bundle.json`
  - `packages/contracts/src/generated/app-api.types.ts`
  - `packages/contracts/src/generated/error-codes.ts`
  - `packages/contracts/src/generated/index.ts`
- Generated output remains projection only and must not be treated as active
  runtime.

## 7. Formal Conclusion

- `Trading-scoped IM Round A` L2 contract boundary is frozen for docs-only
  continuation.
- Current status:
  - `Go for L3 backend truth / persistence freeze`
  - `Go for L4 BFF surface freeze`
  - `Go for L5 Flutter consumption freeze`
  - `No-Go for implementation until L3/L4/L5 and cloud prerequisites pass`
