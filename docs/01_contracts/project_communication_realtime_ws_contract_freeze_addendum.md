---
title: Project Communication Realtime WebSocket Contract Freeze
date: 2026-05-18
stage: L2
status: frozen
owner: Codex Control
---

# Project Communication Realtime WebSocket Contract Freeze

## App-Facing Channel

`/api/app/message/project-communication/realtime`

## Client Subscribe Message

```json
{
  "action": "project_communication.subscribe",
  "threadId": "thread-id",
  "projectId": "project-id",
  "counterpartOrganizationId": "org-id"
}
```

## Server/BFF Event Message

```json
{
  "eventId": "event-id",
  "eventType": "project_communication.message.created",
  "messageId": "message-id",
  "threadId": "thread-id",
  "projectId": "project-id",
  "senderOrganizationId": "org-id",
  "messageKind": "text",
  "body": "hello",
  "clientMessageId": "client-id",
  "createdAt": "2026-05-18T00:00:00.000Z"
}
```

## Failure Contract

- Missing `threadId` or `projectId`: reject subscription.
- Unauthorized thread: reject subscription.
- Unknown event type: client ignores with controlled handling.
- WebSocket unavailable: client falls back to HTTP message list.

