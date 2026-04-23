---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimum L4 BFF surface for Trading IM participant-card, limiting
  BFF to app-facing transport, auth carrier forwarding, bounded shaping, and
  controlled error mapping while preserving the existing formal-info route
  family.
layer: L4 BFF
freeze_date_local: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/trading_im_participant_card_minimal_truth_freeze_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
  - docs/02_backend/trading_im_participant_card_minimal_backend_truth_persistence_freeze_addendum.md
  - docs/03_bff/trading_im_round_a_bff_surface_freeze_addendum.md
  - apps/bff/src/routes/trading_im/trading-im.service.ts
  - apps/bff/src/routes/enterprise_hub/enterprise-hub-formal-info.service.ts
---

# 《Trading IM participant-card minimum BFF surface freeze》

## 1. Scope

- BFF only owns app-facing transport and response shaping for `participant-card minimum`。
- BFF does not own:
  - participant-card truth
  - thread truth
  - enterprise truth
  - review truth
  - formal-info truth
  - second state machine

## 2. App-facing Surface

- Frozen app-facing path:
  - `GET /api/app/exhibition/trading/participant-card`
- BFF must require:
  - `projectId`
  - `bidId`
  - `participantOrganizationId`

## 3. Server Mapping Boundary

- BFF must forward to a Server-owned participant-card read route.
- Frozen canonical server mapping family:
  - `GET /server/trading-im/bid/thread/participant-card`
- BFF must preserve:
  - auth carrier
  - organization scope headers
  - request id / trace headers where available

## 4. Response Shaping

- BFF may shape Server output only to the frozen read model:
  - `participantRole`
  - `enterpriseSummary`
  - `reviewSummary`
  - `formalInfoSummary`
- BFF must not add:
  - raw credit score
  - raw review rows
  - contact info expansion
  - extra formal-info fields outside the frozen summary

## 5. Error Mapping

- Frozen app-facing error codes:
  - `THREAD_PARTICIPANT_CARD_INVALID`
  - `THREAD_PARTICIPANT_CARD_FORBIDDEN`
  - `THREAD_PARTICIPANT_CARD_UNAVAILABLE`
  - `AUTH_SESSION_INVALID`
- BFF may normalize transport failure into controlled app-facing shape, but must not synthesize success if upstream is unavailable.

## 6. Existing formal-info Path Continuity

- Existing canonical path remains unchanged:
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`
- D18 formal-info alignment only means:
  - keep this path canonical
  - close cloud/runtime exposure gap on this same path
  - do not invent a new parallel route

## 7. BFF No-Go

- No BFF persistence.
- No BFF-owned participant cache as truth.
- No profile-building takeover.
- No synthetic fallback from router `404` to fake success.

## 8. Formal Conclusion

- `participant-card minimum` L4 BFF surface boundary is frozen.
- Current status:
  - `No-Go for implementation until next execution gate passes`
