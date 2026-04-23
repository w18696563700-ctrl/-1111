---
owner: Codex 总控
status: frozen
purpose: >
  Record the refreshed live fact base for `Trading IM participant-card minimum`
  through the ali-cloud tunnel so the next reentry gate no longer relies on the
  expired `formal-info = 404` runtime observation.
layer: L0 SSOT
freeze_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/source_of_truth_map.md
  - docs/00_ssot/trading_im_participant_card_minimal_g0b_reentry_stage_gate_checklist_addendum.md
  - docs/00_ssot/trading_im_participant_card_minimal_stop_line_reentry_gate_path_addendum.md
  - docs/00_ssot/messages_interaction_center_bid_trigger_chat_blueprint_addendum.md
  - apps/bff/src/routes/enterprise_hub/app-enterprise-hub.controller.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub-formal-info.service.ts
---

# 《Trading IM participant-card minimum live fact-base refresh receipt》

## 1. Scope

- 本文书只更新当前 `participant-card minimum` 重开所需的 live fact base。
- 本文书不是：
  - implementation unlock
  - implementation dispatch send
  - result verification pass
  - release judgment

## 2. Verification Target

Through the user-provided ali-cloud tunnel:

- `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`

The following app-facing runtime paths were rechecked at local time
`2026-04-24 03:24 CST`:

- `GET /api/app/exhibition/enterprise-hub/enterprises/enterprise-factory-1/formal-info`
- `GET /api/app/exhibition/trading/participant-card?projectId=project-1&bidId=bid-1`

## 3. Refreshed Live Facts

### 3.1 formal-info

- Response:
  - `HTTP/1.1 401 Unauthorized`
  - `code = AUTH_SESSION_INVALID`
  - `source = bff`
- Conclusion:
  - `formal-info` app-facing route family is live.
  - The remaining gap is auth-gated access, not router absence.

### 3.2 participant-card

- Response:
  - `HTTP/1.1 404 Not Found`
  - body:
    - `Cannot GET /api/app/exhibition/trading/participant-card?...`
- Conclusion:
  - `participant-card` app-facing route family is still not materialized in the
    live runtime.

## 4. Superseded Runtime Fact

The earlier `G0B reentry` baseline stated:

- `formal-info live = router 404`

That statement is no longer current for reentry use.

The refreshed runtime baseline is now:

- `formal-info live = 401 AUTH_SESSION_INVALID`
- `participant-card live = 404 Cannot GET`

## 5. Boundaries

- This receipt does not convert `participant-card` into an admitted
  implementation object.
- This receipt does not rewrite the retained non-goal:
  - `participant-card`
- This receipt only removes the expired runtime premise from future reentry
  authoring.

## 6. Formal Conclusion

- `participant-card minimum` fresh reentry may no longer rely on
  `formal-info = 404`.
- Any next reentry gate must use:
  - `formal-info = 401 AUTH_SESSION_INVALID`
  - `participant-card = 404 Cannot GET`
- `Go for fresh participant-card minimum reentry stage gate checklist authoring`
- `No-Go for implementation unlock by this receipt alone`
