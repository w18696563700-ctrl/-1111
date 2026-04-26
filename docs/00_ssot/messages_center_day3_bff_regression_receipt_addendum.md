---
owner: Codex 总控
status: frozen
purpose: >
  Record the Day-3 BFF regression check for the messages building display-name
  synchronization round, proving BFF keeps the existing app-facing response
  shape and does not own counterpart naming truth.
layer: L4 BFF
freeze_date_local: 2026-04-26
inputs_canonical:
  - docs/00_ssot/messages_center_day1_day2_scope_and_display_name_sync_freeze_addendum.md
  - apps/bff/src/routes/message_interaction/message-interaction.service.ts
  - apps/bff/src/routes/message_interaction/message-interaction.read-model.ts
  - apps/bff/src/routes/message_interaction/counterpart-conversation.read-model.ts
  - apps/bff/test/message-interaction-transport.test.cjs
---

# 《消息楼 Day-3 BFF 回归校验回执》

## 1. Regression Scope

Day 3 only verifies BFF behavior for:

- `GET /api/app/message/interactions`
- `counterpart.displayName`
- counterpart response-shape stability

Day 3 does not modify:

- OpenAPI
- generated contracts
- Server route contracts
- Flutter UI
- message route names
- `routeTarget`
- any message state machine

## 2. BFF Role

BFF remains a controlled pass-through and validation layer:

- forwards to `/server/message/interactions`
- builds auth / organization / actor headers
- validates the returned read model
- trims unknown fields
- normalizes controlled errors

BFF does not:

- generate `counterpart.displayName`
- choose legal-name priority
- read `legalName`, `certifiedCompanyName`, or `nickname` to derive a display name
- add a new app-facing company-name field

## 3. Regression Assertion

The BFF transport test now proves that when Server returns:

- `counterpart.displayName`
- extra non-contract naming fields such as `legalName`, `certifiedCompanyName`, `nickname`

BFF output still contains only:

- `organizationId`
- `displayName`
- `avatarUrl`
- `role`

and the value of `displayName` is preserved from Server.

The controller route test also returns a non-empty `items` list to prove the
HTTP route remains materialized for the existing counterpart-conversation shape.

## 4. Verification Command

```bash
cd apps/bff
node --test test/message-interaction-transport.test.cjs
```

Expected result:

- all message-interaction transport tests pass
- response shape remains unchanged
- BFF does not own naming truth

## 5. Formal Conclusion

Day 3 passes if the target BFF transport test passes and no OpenAPI or
generated-contract file changes are present.
