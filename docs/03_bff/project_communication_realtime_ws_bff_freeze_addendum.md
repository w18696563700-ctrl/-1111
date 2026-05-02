---
title: Project Communication Realtime WebSocket BFF Freeze
date: 2026-05-18
stage: L4
status: frozen
owner: Codex Control
---

# Project Communication Realtime WebSocket BFF Freeze

## BFF Responsibilities

- Expose the app-facing project communication WebSocket channel.
- Authenticate connection using existing app auth context.
- Validate `projectId/threadId` on subscription.
- Forward message-created events to subscribed clients.
- Keep HTTP send/read routes unchanged.
- Provide controlled rejection for invalid or unauthorized subscriptions.

## BFF Non-Responsibilities

- No message persistence.
- No thread truth.
- No business state machine.
- No generic DM routing.
- No offline push.
