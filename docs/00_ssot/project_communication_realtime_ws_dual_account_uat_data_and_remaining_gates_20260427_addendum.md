---
title: Project Communication Realtime WebSocket Dual Account UAT Data And Remaining Gates
owner: Codex Control
status: frozen-for-uat-prep
layer: L0 SSOT
authored_at_local: 2026-04-24
target_workday: 2026-04-27
purpose: >
  Freeze the dual-account integration data set and the remaining stage gates
  for the ProjectCommunicationThread realtime WebSocket UAT preparation day.
based_on:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/project_communication_realtime_ws_truth_freeze_addendum.md
  - docs/00_ssot/project_communication_realtime_ws_field_table_addendum.md
  - docs/00_ssot/project_communication_realtime_ws_event_table_addendum.md
  - docs/00_ssot/project_communication_realtime_ws_route_table_addendum.md
  - docs/00_ssot/project_communication_realtime_ws_stability_candidate_gate_addendum.md
  - docs/00_ssot/project_communication_realtime_ws_early_candidate_execution_receipt_addendum.md
  - docs/01_contracts/project_communication_realtime_ws_contract_freeze_addendum.md
  - docs/02_backend/project_communication_realtime_ws_backend_freeze_addendum.md
  - docs/03_bff/project_communication_realtime_ws_bff_freeze_addendum.md
  - docs/04_frontend/project_communication_realtime_ws_frontend_freeze_addendum.md
  - docs/00_ssot/counterpart_conversation_day8_stage_gate_checklist_addendum.md
---

# Project Communication Realtime WebSocket Dual Account UAT Data And Remaining Gates

## 1. Conclusion

The 2026-04-27 preparation gate is frozen as `partial pass / UAT prep only`.

- Current minimum closed loop: A/B enter the same
  `ProjectCommunicationThread`; sending remains HTTP; receiving uses BFF
  WebSocket; HTTP message list remains quiet polling and manual-sync fallback.
- More stable: HTTP command plus WebSocket receive plus HTTP history recovery.
- Lower cost: reuse current BFF, Server, Nginx, PostgreSQL, and the approved SSH
  tunnel; do not introduce an IM service.
- Best fit for the current stage: realtime only inside an opened project
  communication page.
- Higher risk: generic DM, group chat, offline push, typing, online presence,
  read-receipt fan-out, or global unread expansion.

This file does not mark dual-account UAT as passed. It freezes the data set and
remaining gates needed to run that UAT.

## 2. Current Runtime Evidence

| Item | Current Evidence | Decision |
|---|---|---|
| Tunnel | `127.0.0.1:8080 -> 47.108.180.198:80` is listening through SSH | pass for UAT prep |
| BFF live health | `GET /health/bff/live` returned `200`, service `exhibition-bff-isolated-s6`, port `3000` | pass |
| Server live health | `GET /health/server/live` returned `200`, service `exhibition-server-isolated-s6`, port `3001` | pass |
| Protected HTTP route | unauthenticated `GET /api/app/message/project-communication/messages` returned controlled `401`, not `404` | pass |
| WebSocket route | upgrade probe returned `101 Switching Protocols` and `project_communication.connected` | pass |
| Release candidate | `20260424222328-project-communication-realtime-ws-r1` per execution receipt | candidate only |
| A/B read authorization | both sides returned `200` for the same thread and same HTTP message list using ephemeral Server-session-derived access carriers | pass for prep |

## 3. Dual Account Integration Data Table

No password, OTP, access token, or refresh token may be stored in this table.

| Field | Account A / owner side | Account B / counterpart side |
|---|---|---|
| Role in thread | project owner organization side | admitted counterpart organization side |
| User id | `99c99709-3786-4d8a-a0c3-5e1a0e945821` | `ebb8d922-e7da-43fa-897b-360214dfd6e4` |
| Mobile | `186****3700` | `186****1020` |
| Nickname | `重庆海川展览工厂` | `江北嘴嘴帅` |
| Organization id | `e6bf4567-016e-45f9-9420-9c950237690e` | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |
| Organization name | `重庆坤特展览展示有限公司` | `重庆展宏展览展示有限公司` |
| Organization type | `both` | `both` |
| Member role | `buyer_admin` | `supplier_admin` |
| Member status | `active` | `active` |
| Latest DB session status | `valid` | `valid` |
| Server-verifiable access carrier | pass, generated ephemerally from current Server session truth for read probe only | pass, generated ephemerally from current Server session truth for read probe only |
| App bootstrap token stored in docs | not stored | not stored |

Shared project and thread:

| Field | Value |
|---|---|
| `projectId` | `c788eaff-6243-4e97-8be3-c4e174ee7944` |
| Project title | `西洽会 - 泸州` |
| Project state | `published` |
| `threadId` | `afa6f969-66ea-403d-aafc-072fd5cd0f53` |
| Thread state | `open` |
| Owner organization id | `e6bf4567-016e-45f9-9420-9c950237690e` |
| Counterpart organization id | `bdfb4523-aeb7-4b56-89a1-992170fb5d98` |
| Relationship proof | `bid_count=1`, `name_access_count=1`, `clarification_count=0` |
| Existing message count | `4` |
| Existing direction proof | messages exist from both organizations |
| Last message time | `2026-04-24 17:18:35.671 +08:00` |

Read authorization probe:

| Probe | Result |
|---|---|
| A `GET /api/app/message/project-communication/thread` | `200`, returned `threadId=afa6f969-66ea-403d-aafc-072fd5cd0f53` |
| B `GET /api/app/message/project-communication/thread` | `200`, returned `threadId=afa6f969-66ea-403d-aafc-072fd5cd0f53` |
| A `GET /api/app/message/project-communication/messages` | `200`, returned `4` messages anchored to the same `projectId/threadId` |
| B `GET /api/app/message/project-communication/messages` | `200`, returned `4` messages anchored to the same `projectId/threadId` |
| A `GET /api/app/message/interactions?lane=project_communication` | `200`, one `counterpart_conversation.open` item, `conversationId=bdfb4523-aeb7-4b56-89a1-992170fb5d98` |
| B `GET /api/app/message/interactions?lane=project_communication` | `200`, one `counterpart_conversation.open` item, `conversationId=e6bf4567-016e-45f9-9420-9c950237690e` |

The read probe did not execute `POST /api/app/message/project-communication/messages`.

## 4. Required Entry And Route

Flutter must enter through BFF and must not call Server directly.

Primary UAT entry:

Account A:

`/exhibition/messages/counterpart-conversation?conversationId=bdfb4523-aeb7-4b56-89a1-992170fb5d98&projectId=c788eaff-6243-4e97-8be3-c4e174ee7944`

Account B:

`/exhibition/messages/counterpart-conversation?conversationId=e6bf4567-016e-45f9-9420-9c950237690e&projectId=c788eaff-6243-4e97-8be3-c4e174ee7944`

Preferred route source:

- `GET /api/app/message/interactions?lane=project_communication`
- Use the returned `routeTarget` for `counterpart_conversation.open`

Page-level route sequence:

1. `GET /api/app/message/counterpart-conversation/detail`
2. `GET /api/app/message/project-communication/thread`
3. `GET /api/app/message/project-communication/messages`
4. `POST /api/app/message/project-communication/messages`
5. `POST /api/app/message/project-communication/read-cursor`
6. WebSocket `/api/app/message/project-communication/realtime`

## 5. Remaining Gate Table

| Gate | Required Evidence | Current Status | Decision |
|---|---|---|---|
| Truth chain | L0-L5 realtime WS documents frozen | available | pass |
| BFF boundary | BFF forwards and lightly checks only; no message truth | frozen in BFF addendum | pass |
| Server truth | `ProjectCommunicationMessage` remains persistence truth | frozen and deployed as candidate | pass |
| Flutter boundary | Flutter talks only to BFF | frozen; route scan aligned | pass |
| Cloud route | HTTP protected route and WS upgrade reachable through tunnel | probed | pass |
| A/B data | two active organizations, same project/thread, existing relationship | frozen in this table | pass for prep |
| A/B app session | current Server session truth can verify A/B access carriers | read-probe pass; runnable two-window App bootstrap still pending | partial pass |
| A sends | Account A sends through HTTP command | not rerun in this gate | pending |
| B receives | Account B receives over WS without manual sync | not run | pending |
| History recovery | after disconnect, HTTP history and WS events stay consistent | not run | pending |
| Computer-use click UAT | actual two-account UI click evidence | not run | pending |
| Production cutover | UAT pass plus rollback plan | not available | blocked |

## 6. Veto Gates

Current veto state:

| Veto | Status |
|---|---|
| Generic direct message introduced | not triggered |
| BFF stores message body as business truth | not triggered |
| BFF creates second message state machine | not triggered |
| Event missing `projectId/threadId` | not triggered by frozen contract |
| Flutter direct-to-Server call | not triggered |
| HTTP history fallback removed | not triggered |
| Password, OTP, access token, or refresh token written into docs | not triggered |

Any future trigger above makes the next stage `No-Go`.

## 7. Allowed Next Step

Allowed:

- `Go` for 2026-04-28 cloud stability复核 and UAT-token preparation.
- `Go` for obtaining or refreshing two real app login sessions through normal
  login or approved controlled test-session flow.
- `Go` for running the dual-account UAT after both Account A and Account B have
  usable app-side credentials.

Not allowed:

- No production default realtime-chat cutover.
- No hiding or deleting manual sync.
- No old HTTP message list deletion.
- No generic IM expansion.
- No claim that A/B UAT has passed before the actual two-account receive test.

## 8. UAT Run Sheet To Execute Next

When app-side credentials are available, run:

1. Open Account B on
   `CounterpartConversationPage` for the shared project/thread.
2. Confirm B subscribes with `projectId`, `threadId`, and
   `counterpartOrganizationId`.
3. Open Account A in the same project communication thread.
4. A sends a unique text message through HTTP.
5. B must see the message without tapping manual sync.
6. Restart network or close/reopen the app, then verify quiet HTTP history
   recovery.
7. Confirm message list contains one canonical `messageId` and no duplicate
   UI item.

The UAT receipt must record screenshots or logs, `messageId`,
`clientMessageId`, timestamps, and whether manual sync was touched.
