---
owner: Codex 总控
status: active
purpose: Record Day-4 BFF + Server execution receipt for project communication text chat routes and cloud release.
layer: L0 SSOT
schedule_date_local: 2026-04-30
execution_date_local: 2026-04-24
based_on:
  - docs/00_ssot/project_communication_album_rating_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_album_rating_route_table_addendum.md
  - docs/03_bff/project_communication_album_rating_bff_surface_freeze_addendum.md
---

# 《项目沟通文字聊天 Day-4 BFF + Server 执行回执》

## 1. Scope

- Day-4 目标：
  - BFF 新增 app-facing routes：
    - `GET /api/app/message/project-communication/thread`
    - `GET /api/app/message/project-communication/messages`
    - `POST /api/app/message/project-communication/messages`
    - `POST /api/app/message/project-communication/read-cursor`
  - Server/BFF 发版到 current。
  - 保留旧 `bid_thread` fallback。
- 本次不做：
  - Flutter UI 改造。
  - WebSocket / 实时推送。
  - 新统一聊天状态机。

## 2. Implementation Receipt

- BFF controller/read-model/service 已实现。
- BFF 仅做 app-facing DTO shaping、auth carrier 透传、Server 转发。
- Server 继续作为 ProjectCommunicationThread / ProjectCommunicationMessage / read cursor 真值 owner。
- 旧 `GET /api/app/bid/thread/detail` 仍保留为 fallback。

## 3. Cloud Release

- Release id：
  - `20260424155716-project-communication-chat-r1`
- Server current：
  - `/srv/apps/server/current -> /srv/releases/server/20260424155716-project-communication-chat-r1`
- BFF current：
  - `/srv/apps/bff/current -> /srv/releases/bff/20260424155716-project-communication-chat-r1`
- Server health：
  - `GET http://127.0.0.1:3001/health/live` returned `200`
- BFF health：
  - `GET http://127.0.0.1:3000/health/live` returned `200`
- Nginx/BFF tunnel health：
  - `GET http://127.0.0.1:8080/health/bff/live` returned `200`

## 4. Route Materialization Evidence

- BFF boot log confirmed:
  - `Mapped {/api/app/message/project-communication/thread, GET}`
  - `Mapped {/api/app/message/project-communication/messages, GET}`
  - `Mapped {/api/app/message/project-communication/messages, POST}`
  - `Mapped {/api/app/message/project-communication/read-cursor, POST}`
- Local tunnel probes via `127.0.0.1:8080`:
  - `GET /api/app/message/project-communication/messages?threadId=thread-probe&projectId=project-probe` returned `401 AUTH_SESSION_INVALID`, not `404`.
  - `POST /api/app/message/project-communication/messages` with `threadId + projectId + body` returned `401 AUTH_SESSION_INVALID`, not `404`.
  - `GET /api/app/bid/thread/detail?projectId=project-probe&bidId=bid-probe` returned `401 AUTH_SESSION_INVALID`, not `404`.

## 5. Verification

- Local pre-release build:
  - `corepack pnpm --dir apps/server build` passed.
  - `corepack pnpm --dir apps/bff build` passed.
- BFF route/transport test:
  - `node --test apps/bff/test/message-interaction-transport.test.cjs` passed.
- Server migration:
  - `20260428_project_communication_and_album_truth` applied during cloud start.

## 6. Gate Result

- Passed gates:
  - BFF app-facing routes exist.
  - Server remains truth owner.
  - BFF does not own a new state machine.
  - All new chat read/write routes require `projectId`.
  - Old `bid_thread` fallback remains reachable.
  - Current cloud release is healthy.
- Not fully proven in CLI:
  - A real logged-in user can read actual thread messages in Flutter UI.
  - Reason: no reusable authenticated app session token was available to this CLI probe.
- Next allowed stage:
  - Flutter can consume these routes.
  - Real login UI联调 must be completed before UAT pass.
