---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimum L3 Server truth boundary for Trading IM participant-card,
  defining it as a bounded query projection over existing thread participant,
  enterprise listing, review summary, and formal-info truth without introducing
  a new persistence object.
layer: L3 Backend
freeze_date_local: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/trading_im_participant_card_minimal_truth_freeze_addendum.md
  - docs/01_contracts/trading_im_participant_card_minimal_contract_freeze_addendum.md
  - docs/02_backend/trading_im_round_a_backend_truth_persistence_freeze_addendum.md
  - apps/server/src/modules/trading_im/trading-im.service.ts
  - apps/server/src/modules/enterprise_hub/enterprise-hub-formal-info.query.service.ts
  - apps/server/src/modules/enterprise_hub/entities/enterprise-listing.entity.ts
  - apps/server/src/modules/enterprise_hub/entities/enterprise-review-summary.entity.ts
---

# 《Trading IM participant-card minimum backend truth freeze》

## 1. Scope

- 本冻结单只覆盖 Server-owned `participant-card minimum` query truth。
- Server remains the only business truth owner.
- 本冻结单不授权 implementation until next execution gate passes。

## 2. Truth Nature

- `participant-card` is not a new persistence carrier.
- It is a bounded query projection assembled from existing truth:
  - bid-thread participant relation
  - enterprise listing summary
  - enterprise review summary
  - target-enterprise formal-info truth

## 3. Query Anchor

- Canonical query anchor:
  - `projectId`
  - `bidId`
  - `participantOrganizationId`
- Server must first prove:
  - current actor is an admitted participant of the targeted bid thread
  - target `participantOrganizationId` is one of the two admitted participants of the thread

## 4. Source Truth Family

- Participant relation source:
  - existing bid-thread relation truth under `projectId + bidId`
- Enterprise summary source:
  - published / visible enterprise listing bound to `participantOrganizationId`
- Review summary source:
  - bounded aggregate summary bound to `enterpriseId`
- Formal-info summary source:
  - target organization approved certification current truth

## 5. Persistence Boundary

- Round A No-Go:
  - new `participant_card` table
  - participant-card write command
  - participant-card lifecycle state
  - participant-card audit family
- If any source truth is missing or target participant is not admitted, Server must fail closed.

## 6. Permission Truth

- Minimum checks:
  - current session is valid
  - current organization scope is valid
  - current actor is admitted thread participant
  - target participant organization is admitted in the same thread
- No unrelated actor may read the card.

## 7. Output Boundary

- Server may output only the frozen bounded fields:
  - participant role
  - enterprise summary
  - bounded review summary
  - bounded formal-info summary
- Server must not output:
  - private contacts
  - raw credit scoring
  - raw review rows
  - attachment truth
  - order / contract / dispute truth

## 8. Existing formal-info Path Continuity

- Existing canonical formal-info read remains:
  - `GET /server/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`
- `participant-card` may reuse the same target-enterprise formal truth or a bounded internal helper, but must not fork a second formal-info truth family.

## 9. Formal Conclusion

- `participant-card minimum` L3 backend truth boundary is frozen.
- Current status:
  - `Go for L4 BFF surface freeze`
  - `No-Go for implementation until next execution gate passes`
