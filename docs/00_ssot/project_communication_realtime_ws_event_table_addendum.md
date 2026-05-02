---
title: Project Communication Realtime WebSocket Event Table
date: 2026-05-18
stage: L1
status: frozen
owner: Codex Control
---

# Project Communication Realtime WebSocket Event Table

| Event Type | Owner | Trigger | Consumers | Payload |
|---|---|---|---|---|
| `project_communication.message.created` | Server | Successful HTTP message write | BFF, Flutter via BFF WS | `eventId/messageId/threadId/projectId/senderOrganizationId/messageKind/body/clientMessageId/createdAt` |

## Event Rules

- Events are derived from persisted message truth.
- Events do not create message truth.
- Events do not replace HTTP history reads.
- Duplicate events must be de-duplicated by `messageId` or `clientMessageId`.
- Delivery is best-effort in this phase.
- On missed delivery, Flutter must recover via HTTP message list.

## Out Of Scope Events

- Delivery acknowledgement.
- Typing.
- Online presence.
- Read cursor fan-out.
- Push notification delivery.
