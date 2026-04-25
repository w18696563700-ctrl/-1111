---
title: Project Communication Realtime WebSocket Early Candidate Execution Receipt
date: 2026-04-24
stage: execution-receipt
status: candidate-verified-for-uat-prep
owner: Codex Control
---

# Project Communication Realtime WebSocket Early Candidate Execution Receipt

## 1. Scope

This receipt records an early implementation candidate for the planned
2026-05-22 to 2026-05-26 realtime stability work.

It does not claim completion of those future-dated UAT milestones.

## 2. Implemented Candidate Changes

- Flutter WebSocket subscribe now refreshes an expired access token before
  opening the socket.
- Flutter WebSocket headers now include:
  - configured app headers, such as `x-actor-id` and `x-user-id`
  - active session `authorization`
- Cloud Nginx now has a dedicated WebSocket upgrade route for:
  `/api/app/message/project-communication/realtime`
- Cloud BFF and Server were released with the bounded realtime package:
  - BFF gateway:
    `ProjectCommunicationRealtimeGateway`
  - Server event buffer/query:
    `ProjectCommunicationRealtimeEventService`

## 3. Cloud Release

- Release id:
  `20260424222328-project-communication-realtime-ws-r1`
- BFF current:
  `/srv/releases/bff/20260424222328-project-communication-realtime-ws-r1`
- Server current:
  `/srv/releases/server/20260424222328-project-communication-realtime-ws-r1`
- Previous BFF rollback point:
  `/srv/releases/bff/20260424182749-project-communication-day14-day15-r1`
- Previous Server rollback point:
  `/srv/releases/server/20260424182749-project-communication-day14-day15-r1`
- Nginx backup:
  `/etc/nginx/conf.d/exhibition.conf.bak.ws-20260424222050`

## 4. Verification Evidence

### Local

- `corepack pnpm --dir apps/server build`
- `corepack pnpm --dir apps/bff build`
- `flutter test test/counterpart_conversation_chat_test.dart test/messages_instance_todo_test.dart`
- `node --test apps/bff/test/message-interaction-transport.test.cjs apps/bff/test/project-album-transport.test.cjs apps/bff/test/rating-entry-submit.test.cjs`
- `node --test apps/server/test/project-communication-album.test.cjs apps/server/test/rating-entry-submit.test.cjs apps/server/test/message-interaction-bid-carry.test.cjs`

### Cloud / Tunnel

- `GET /health/bff/live` returned `200`.
- `GET /health/server/live` returned `200`.
- `GET /api/app/message/project-communication/messages?threadId=thread-probe&projectId=project-probe`
  returned controlled `401 AUTH_SESSION_INVALID`, not `404`.
- WebSocket probe through `127.0.0.1:8080` returned:
  - `101 Switching Protocols`
  - `project_communication.connected`
- WebSocket subscribe without auth returned controlled:
  - `project_communication.subscription.rejected`
  - `PROJECT_COMMUNICATION_FORBIDDEN`

## 5. Gates

| Gate | Result |
|---|---|
| Local build | pass |
| Local realtime tests | pass |
| Cloud BFF/Server health | pass |
| Cloud Nginx WS upgrade | pass |
| WS controlled rejection | pass |
| Dual-account receive without refresh | blocked |
| Computer-use UAT click run | blocked |
| Production cutover | blocked |

## 6. Residual Risks

- Dual-account UAT still requires two real authenticated accounts and an
  admitted shared `projectId + threadId`.
- The realtime event buffer remains best-effort and in-process; HTTP message
  history remains the recovery truth.
- This package still does not open generic DM, push notification, typing,
  online presence, read receipt fan-out, or media messages.

## 7. Stage Decision

`GO` for UAT preparation.

`NO-GO` for default realtime-chat cutover until dual-account UAT proves:

- A sends through HTTP.
- B receives over WebSocket without tapping manual sync.
- B can recover via HTTP history after disconnect/reconnect.
- HTTP history and WebSocket events remain consistent.
