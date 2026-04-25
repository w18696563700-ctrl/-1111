---
title: Project Communication Realtime WebSocket Frontend Freeze
date: 2026-05-18
stage: L5
status: frozen
owner: Codex Control
---

# Project Communication Realtime WebSocket Frontend Freeze

## Flutter Responsibilities

- Resolve `ProjectCommunicationThread` via BFF before connecting.
- Subscribe with `threadId/projectId/counterpartOrganizationId`.
- Append `project_communication.message.created` events into the chat timeline.
- De-duplicate by `messageId` and `clientMessageId`.
- Keep sending through HTTP command.
- Fall back to quiet polling when WebSocket is unavailable.
- Keep manual refresh as a fallback action.

## Flutter Non-Responsibilities

- No Server direct call.
- No local business truth.
- No generic private message UI.
- No offline push.
- No delivery guarantee state machine.

