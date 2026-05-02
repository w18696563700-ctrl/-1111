---
title: Project Communication Realtime WebSocket Route Table
date: 2026-05-18
stage: L1
status: frozen
owner: Codex Control
---

# Project Communication Realtime WebSocket Route Table

## Existing HTTP Routes Retained

| Layer | Method | Route | Purpose |
|---|---|---|---|
| BFF | `GET` | `/api/app/message/project-communication/thread` | Resolve project thread. |
| BFF | `GET` | `/api/app/message/project-communication/messages` | Load history and fallback polling. |
| BFF | `POST` | `/api/app/message/project-communication/messages` | Send text command. |
| BFF | `POST` | `/api/app/message/project-communication/read-cursor` | Mark read cursor. |
| Server | `GET` | `/server/project-communication/thread` | Server thread truth. |
| Server | `GET` | `/server/project-communication/messages` | Server message truth read. |
| Server | `POST` | `/server/project-communication/messages` | Server message truth write. |
| Server | `POST` | `/server/project-communication/read-cursor` | Server read cursor truth. |

## New Realtime Surface

| Layer | Transport | Route / Channel | Purpose |
|---|---|---|---|
| BFF | WebSocket | `/api/app/message/project-communication/realtime` | App-facing project communication realtime channel. |
| Client -> BFF | WS message | `project_communication.subscribe` | Subscribe one `threadId + projectId`. |
| BFF -> Client | WS message | `project_communication.message.created` | Forward Server-derived message event. |

## Fallback Rule

If WebSocket connection, subscription, or event parsing fails, Flutter must use:

`GET /api/app/message/project-communication/messages?threadId=...&projectId=...`

The fallback must be quiet by default and must not flash the page into loading
state.
