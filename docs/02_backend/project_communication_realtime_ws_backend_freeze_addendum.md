---
title: Project Communication Realtime WebSocket Backend Freeze
date: 2026-05-18
stage: L3
status: frozen
owner: Codex Control
---

# Project Communication Realtime WebSocket Backend Freeze

## Server Responsibilities

- Persist `ProjectCommunicationMessage` through existing HTTP command.
- After successful persistence, publish derived event
  `project_communication.message.created`.
- Record audit as before.
- Ensure every event includes `eventId/messageId/threadId/projectId/
  senderOrganizationId/createdAt`.
- Keep event publication best-effort; message persistence remains the source of
  truth.

## Server Non-Responsibilities

- Server does not own app-facing WebSocket sessions in this phase unless BFF
  explicitly calls or subscribes to a Server internal event channel.
- Server does not create IM delivery/read-receipt state.
- Server does not send offline push.

