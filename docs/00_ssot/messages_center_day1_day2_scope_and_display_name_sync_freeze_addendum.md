---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the Day-1 scope and Day-2 server display-name synchronization boundary
  for the messages building cleanup round, keeping the round limited to
  message-center scope confirmation plus Server-side counterpart displayName
  projection correction.
layer: L0 SSOT
freeze_date_local: 2026-04-26
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/messages_interaction_center_truth_freeze_addendum.md
  - docs/01_contracts/messages_interaction_center_contract_freeze_addendum.md
  - docs/01_contracts/counterpart_conversation_contract_freeze_addendum.md
  - docs/02_backend/messages_interaction_center_and_bidder_carry_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/messages_interaction_center_and_bidder_carry_bff_surface_freeze_addendum.md
  - docs/04_frontend/messages_interaction_center_and_bidder_carry_frontend_consumption_freeze_addendum.md
  - apps/mobile/lib/features/messages/presentation/messages_page.dart
  - apps/mobile/lib/features/messages/presentation/messages_page_support.dart
  - apps/server/src/modules/message_interaction
  - apps/bff/src/routes/message_interaction
---

# 《消息楼 Day-1 / Day-2 范围冻结与名称同步补充单》

## 1. Day-1 Current-State Freeze

当前消息楼真实入口固定为：

- `MessagesPage`
- Shell bottom building:
  - `/messages`
  - bottom label remains `消息`

当前页面仍固定为双 lane：

1. `项目沟通`
   - Flutter consumes `GET /api/app/message/interactions?lane=project_communication`
   - Server aggregates admitted counterpart-conversation seeds.
2. `论坛互动`
   - Flutter consumes the existing forum interaction inbox family.
   - It must not be mixed into `message/interactions`.

当前修改前截图已保留：

- `docs/04_frontend/screenshots/messages_center_day1_before.png`

## 2. Component Inventory

Flutter current entry and components:

- `apps/mobile/lib/features/messages/presentation/messages_page.dart`
  - true messages-building page
  - refreshes project communication and forum interaction inbox separately
- `apps/mobile/lib/features/messages/presentation/messages_page_support.dart`
  - `_MessagesProjectCommunicationSection`
  - `_MessagesProjectCommunicationCard`
  - `_MessagesInboxTabBar`
  - `_MessagesInteractionCard`

BFF current role:

- `apps/bff/src/routes/message_interaction/message-interaction.service.ts`
  - forwards app-facing reads to Server
  - normalizes controlled errors
- `apps/bff/src/routes/message_interaction/message-interaction.read-model.ts`
  - validates `counterpart.displayName` as a required string
  - does not create or prioritize display-name truth
- `apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts`
  - validates detail counterpart display fields
  - does not own naming truth

Server current source family:

- `counterpart-conversation.bid-thread-source.ts`
- `counterpart-conversation.project-name-access-source.ts`
- `counterpart-conversation.clarification-source.ts`
- `counterpart-conversation.projection.service.ts`

## 3. Day-2 Display-Name Synchronization Ruling

当前 `counterpart.displayName` must remain the existing contract field.

No new app-facing field is allowed in this round.

Server-side source priority is frozen as:

1. approved organization certification `legalName`
2. `organizations.name`
3. source-specific fallback text

This applies uniformly to:

- `bid_thread`
- `project_name_access`
- `project_clarification`

The correction is a Server projection correction only. It is not:

- a new DTO field
- a new BFF shaping rule
- a Flutter-side name inference
- a route change
- a state-machine change

## 4. Forbidden Touch List

This Day-1 / Day-2 round must not touch:

- `apps/mobile` UI implementation beyond the screenshot evidence captured in Day 1
- `apps/bff` implementation
- OpenAPI or generated contract outputs
- message route names
- `routeTarget` action keys
- forum interaction route family
- generic DM / group chat / unread / typing / online state
- payment, order adjudication, rating production truth, or settlement paths

## 5. Gate Checklist

Passed gates:

- Day-1 true entry identified.
- Project communication component identified.
- Forum interaction component identified.
- BFF pass-through / validation-only role identified.
- Server display-name source gap identified.
- Modification-before screenshot captured.

Failed gates:

- None for Day-1 / Day-2 scope.

Veto gates:

- No new app-facing field.
- No BFF name-truth ownership.
- No Flutter-side counterpart company-name inference.
- No route or state-machine change.

Next stage allowed:

- Go for Server display-name projection correction and Server tests.

## 6. Current Minimum Closure

The minimum closure for this round is:

- Keep `MessagesPage` as the messages-building entry.
- Keep `项目沟通` and `论坛互动` as separate lanes.
- Correct Server `counterpart.displayName` source priority to approved
  certification legal name first.
- Preserve the existing BFF and Flutter contract surface.

## 7. Retained But Not Opened

The following remain retained but not opened in this round:

- unread counters
- latest-message aggregate badge
- system-notice lane expansion
- generic private message center
- forum inbox merge into message interactions
- certification-company-name dedicated DTO field

## 8. Future Extension Slots

Future rounds may register, but must not silently implement here:

- lightweight messages-building UI cleanup
- forum interaction entrance card
- project communication unread counts
- counterpart enterprise formal-info preview
- system notice lane
