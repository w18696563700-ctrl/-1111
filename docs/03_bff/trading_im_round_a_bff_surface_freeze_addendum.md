---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the L4 BFF app-facing surface boundary for Trading-scoped IM Round A,
  mapping app-facing paths to Server truth, limiting BFF to transport,
  normalization, shaping, visibility trimming, error mapping, and optional
  light idempotency without owning message or thread truth.
layer: L4 BFF
freeze_date_local: 2026-04-16
inputs_canonical:
  - AGENTS.md
  - apps/bff/AGENTS.md
  - docs/00_ssot/trading_im_round_a_truth_freeze_addendum.md
  - docs/01_contracts/trading_im_round_a_contracts_addendum.md
  - docs/02_backend/trading_im_round_a_backend_truth_persistence_freeze_addendum.md
  - apps/bff/src/routes/routes.module.ts
---

# 《交易场景 IM Round A BFF surface freeze》

## 1. Scope

- BFF only owns app-facing transport and response shaping for Round A.
- BFF does not own:
  - clarification truth
  - thread truth
  - message truth
  - confirmation card truth
  - attachment truth
  - audit truth
  - second state machine

## 2. App-facing Surface

Frozen app-facing paths:

- `GET /api/app/project/clarification/list`
- `POST /api/app/project/clarification/create`
- `GET /api/app/bid/thread/detail`
- `POST /api/app/bid/thread/message/send`
- `POST /api/app/bid/thread/confirmation/create`

The paths above must stay bounded to Trading IM Round A and must not become a
generic chat route family.

## 3. Server Mapping Boundary

- BFF must forward to Server-owned Round A routes.
- Exact Server route names may follow Server implementation naming, but BFF
  must not synthesize success if upstream is unavailable.
- BFF must preserve:
  - auth carrier
  - organization scope headers
  - idempotency key only where frozen
  - request id / trace headers where available

## 4. Request Normalization

- BFF may normalize:
  - missing or malformed `projectId`
  - missing or malformed `bidId`
  - body trimming
  - attachment id array shape
- BFF must not decide business permission.
- BFF must not repair unknown fields into apparent success.

## 5. Response Shaping

- BFF may shape Server output to frozen app-facing read models:
  - `ClarificationReadModel`
  - `BidThreadDetailReadModel`
  - `BidThreadMessageReadModel`
  - `ConfirmationCardReadModel`
  - participant / availability projection
- BFF must not add:
  - read receipt
  - delivery status
  - online status
  - typing state
  - push token or notification provider fields

## 6. Error Mapping

Frozen Round A error codes:

- `PROJECT_CLARIFICATION_UNAVAILABLE`
- `PROJECT_CLARIFICATION_FORBIDDEN`
- `BID_THREAD_UNAVAILABLE`
- `BID_THREAD_FORBIDDEN`
- `THREAD_MESSAGE_INVALID`
- `THREAD_ATTACHMENT_INVALID`
- `THREAD_CONFIRMATION_INVALID`

BFF may normalize transport failures to controlled app-facing error shape, but
must not convert unknown critical error codes into success.

## 7. Message Building Handoff

- BFF may expose Round A reminders only through the frozen controlled
  `message/index` projection when Server truth exists.
- BFF must not expose message or thread truth under `message/index`.
- BFF must not reopen the existing `forum interaction inbox` as trading IM.

## 8. BFF No-Go

- No BFF persistence for messages or threads.
- No BFF-owned audit.
- No second state machine.
- No forum route masquerading as Round A route.
- No Admin API.
- No realtime transport.

## 9. Formal Conclusion

- L4 BFF surface boundary is frozen.
- BFF implementation remains blocked until:
  - Server implementation receipt passes
  - cloud implementation prerequisite gate passes
