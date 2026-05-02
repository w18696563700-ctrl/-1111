---
title: Project Communication Realtime WebSocket Truth Freeze
date: 2026-05-18
stage: L0
status: frozen
owner: Codex Control
---

# Project Communication Realtime WebSocket Truth Freeze

This addendum unlocks a bounded realtime channel for project communication text
messages only. It supersedes the previous "no WebSocket" non-goal only for the
scope explicitly listed here.

## 1. Current Minimum Closed Loop

- Realtime applies only to `ProjectCommunicationThread`.
- Every connection, subscription, event, and fallback request must carry:
  - `projectId`
  - `threadId`
  - `counterpartOrganizationId` when the client knows the counterpart boundary.
- Message truth remains `ProjectCommunicationMessage` in Server persistence.
- Sending text messages continues to use the existing HTTP command:
  `POST /api/app/message/project-communication/messages`.
- WebSocket is receive-side realtime transport only.
- BFF may authenticate, authorize, subscribe, and forward events.
- BFF must not persist message truth, own a message state machine, or create a
  second project communication thread model.
- Flutter must connect only after the page has a valid project communication
  thread.
- If WebSocket is unavailable, Flutter must fall back to quiet HTTP polling.

## 2. Retained But Not Opened

- Generic direct messaging.
- Group chat outside a project.
- Offline push notification.
- Typing indicators.
- Online presence.
- Read receipt fan-out.
- Message recall.
- Images, voice, files, and album event streaming.
- Global unread badge and cross-device IM sync.

## 3. Extension Slots

The same project-scoped realtime channel may later carry derived notifications
for:

- `project_name_access.request.created`
- `project_name_access.request.decided`
- `bid_thread.updated`
- `project_album.photo.created`
- `project_album.photo.deleted`
- `project_counterparty_rating.submitted`

Each extension requires a new event-table addendum and must continue to anchor
to the original business truth and `projectId`.

## 4. Stability Choice

- More stable: HTTP command plus WebSocket receive plus polling fallback.
- Lower cost: reuse current BFF/Server deployment and existing HTTP history
  routes; no standalone IM service in this phase.
- Best fit now: project-page realtime for open conversations only.
- Higher risk: building a full IM platform now, because it adds offline push,
  delivery acknowledgements, unread fan-out, and multi-device consistency.

## 5. Vetoes

- Veto if any event lacks `projectId` or `threadId`.
- Veto if BFF stores message body as business truth.
- Veto if Flutter calls Server directly.
- Veto if WebSocket becomes a generic DM entry.
- Veto if HTTP history fallback is removed.
