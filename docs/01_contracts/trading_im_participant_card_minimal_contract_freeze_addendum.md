---
owner: Codex 总控
status: frozen
purpose: >
  Freeze the minimum L2 app-facing contract for Trading IM participant-card,
  admitting only one bounded read route and a compact read-only response model
  for admitted bid-thread participants.
layer: L2 Contracts
freeze_date_local: 2026-04-23
inputs_canonical:
  - docs/00_ssot/trading_im_participant_card_minimal_truth_freeze_addendum.md
  - docs/00_ssot/trading_im_participant_card_minimal_g0b_reentry_stage_gate_checklist_addendum.md
  - docs/01_contracts/trading_im_round_a_contracts_addendum.md
  - docs/01_contracts/openapi.yaml
  - docs/01_contracts/error_codes.yaml
  - docs/00_ssot/source_of_truth_map.md
---

# 《Trading IM participant-card minimum contract freeze》

## 1. Scope

- 本冻结单只覆盖 `participant-card minimum` 的 app-facing contract。
- 本冻结单不授权 implementation、integration、release-prep。

## 2. Canonical App-facing Path

- 当前冻结唯一 app-facing path：
  - `GET /api/app/exhibition/trading/participant-card`
- Required query params:
  - `projectId`
  - `bidId`
  - `participantOrganizationId`
- 当前 path 不得偷换为：
  - profile route
  - enterprise public detail route
  - generic organization card route

## 3. Response Schema Freeze

- Minimum top-level fields:
  - `projectId`
  - `bidId`
  - `participantOrganizationId`
  - `participantRole`
  - `enterpriseSummary`
  - `reviewSummary`
  - `formalInfoSummary`

### 3.1 participantRole

- Enum:
  - `project_owner`
  - `bidder`

### 3.2 enterpriseSummary

- Minimum fields:
  - `enterpriseId`
  - `displayName`
  - `logoUrl`
  - `primaryBoardType`
  - `provinceName`
  - `cityName`
  - `verificationStatus`
- `logoUrl` is display projection only and must not be treated as file truth.

### 3.3 reviewSummary

- Minimum fields:
  - `avgScore`
  - `reviewCount`
  - `keywordTags`
- `keywordTags` must be a string array.
- No raw review rows are admitted.

### 3.4 formalInfoSummary

- Minimum fields:
  - `legalName`
  - `businessType`
  - `registeredCapital`
  - `establishedAt`
  - `businessScope`
  - `certificationStatus`
- No `licenseFileId`
- No private contact data
- No current-viewer certification data

## 4. Error Code Freeze

- Current participant-card error codes:
  - `THREAD_PARTICIPANT_CARD_INVALID`
  - `THREAD_PARTICIPANT_CARD_FORBIDDEN`
  - `THREAD_PARTICIPANT_CARD_UNAVAILABLE`
- Existing auth error remains:
  - `AUTH_SESSION_INVALID`

## 5. Existing formal-info Path Continuity

- This freeze does not replace or rename the existing canonical path:
  - `GET /api/app/exhibition/enterprise-hub/enterprises/{enterpriseId}/formal-info`
- `participant-card` only consumes a bounded summary projection of the same truth family.

## 6. Formal Conclusion

- `Trading IM participant-card minimum` L2 contract boundary is frozen.
- Current status:
  - `Go for L3 backend truth freeze`
  - `Go for L4 BFF surface freeze`
  - `No-Go for implementation until next execution gate passes`
