---
title: Project Communication Realtime WebSocket Stability Candidate Gate
date: 2026-04-24
stage: gate
status: go-for-early-candidate-implementation
owner: Codex Control
---

# Project Communication Realtime WebSocket Stability Candidate Gate

## 1. Date Ruling

The requested delivery plan names 2026-05-22, 2026-05-25, and 2026-05-26.
The current execution date is 2026-04-24.

This file does not mark those future dates as completed. It authorizes an
early candidate implementation and verification package for the same bounded
scope.

## 2. Current Minimum Closed Loop

- Flutter opens `CounterpartConversationPage`.
- Flutter resolves `ProjectCommunicationThread` through BFF HTTP.
- Text send remains HTTP:
  `POST /api/app/message/project-communication/messages`.
- Realtime receive uses BFF WebSocket:
  `/api/app/message/project-communication/realtime`.
- Every subscribe and event remains anchored to `projectId + threadId`.
- If WebSocket fails, Flutter continues quiet HTTP polling against:
  `GET /api/app/message/project-communication/messages`.
- Manual sync remains available only as a low-priority fallback action.

## 3. Candidate Stability Fixes

- Flutter WebSocket headers must include the same active auth/session boundary
  as HTTP calls: `authorization`, plus configured actor/user headers.
- Flutter may refresh an expired access token before opening WebSocket.
- BFF/Server remain unchanged as truth owners:
  - Server owns `ProjectCommunicationMessage`.
  - BFF owns only app-facing WebSocket session and forwarding.
- Cloud Nginx must forward WebSocket upgrade headers for the realtime route.

## 4. Retained But Not Opened

- Generic direct message.
- Offline push notification.
- Typing indicator.
- Online presence.
- Delivery/read receipt fan-out.
- Image, voice, file, or album event streaming.
- Global unread badge.

## 5. Verification Gates

| Gate | Required Evidence | Current Decision |
|---|---|---|
| Local build | Server and BFF build pass | required |
| Local tests | Server/BFF/Flutter realtime tests pass | required |
| Tunnel HTTP probe | HTTP fallback routes return authenticated business data or controlled `401`, not `404` | required |
| Tunnel WS probe | WebSocket route upgrades or fails with controlled auth/subscribe behavior, not Nginx route failure | required before UAT |
| Dual-account UAT | A sends, B receives without tapping refresh | blocked until real test accounts are supplied |
| Production cutover | UAT pass plus rollback plan | blocked |

## 6. Risk Ruling

- More stable: HTTP send + WebSocket receive + HTTP polling recovery.
- Lower cost: reuse existing BFF/Server/Nginx runtime.
- Best fit now: realtime only inside the opened project communication page.
- Higher risk: treating the in-memory realtime event buffer as reliable IM
  delivery or expanding this into generic chat.

## 7. Stage Decision

`GO` for early candidate implementation, local verification, and cloud route
smoke.

`NO-GO` for declaring 2026-05-22/25/26 acceptance complete on 2026-04-24.

`NO-GO` for hiding the HTTP fallback or deleting the manual sync fallback
before UAT.
