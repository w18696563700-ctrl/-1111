---
owner: Codex 总控 Agent
status: frozen
layer: L0 SSOT receipt
freeze_date_local: 2026-05-06
purpose: Record the minimum reserve closure for `组织信用评分` canonical contracts, generated types, payload parity gate, and current/reserve isolation without activating current V2.1 scoring.
inputs_canonical:
  - AGENTS.md
  - docs/01_contracts/order_rating_driven_org_credit_scoring_contract_freeze_addendum_v1.md
  - docs/01_contracts/order_rating_driven_org_credit_scoring_contract_read_surface_patch_addendum_v1.md
  - docs/00_ssot/order_rating_driven_org_credit_scoring_current_v21_non_pollution_verification_addendum_v1.md
  - docs/00_ssot/project_transaction_lifecycle_day35_day36_full_chain_cloud_uat_preflight_receipt_addendum.md
  - docs/01_contracts/openapi.yaml
  - packages/contracts/src/generated/app-api.types.ts
---

# 组织信用评分 reserve 最小闭环 Receipt Addendum

## 1. Conclusion

`组织信用评分` remains a future-mainline reserve read surface.

This receipt records the minimum closure for the existing read-only chain:

- Flutter consumes `GET /api/app/profile/organization-credit-scoring/status`.
- Flutter consumes `GET /api/app/profile/organization-credit-scoring/explanation`.
- Flutter consumes `GET /api/app/profile/organization-credit-scoring/handoff`.
- BFF forwards the three App-facing reads to Server `server/profile/organization-credit-scoring/*`.
- Server source remains `credit_scoring_shadow` shadow aggregation.
- Canonical OpenAPI and generated app-api types now carry the three reserve paths and reserve response schemas.
- Payload parity is guarded by a reusable runtime check and a manual GitHub Actions workflow.

This closure does not make organization credit scoring current V2.1 truth.

## 2. Current / Reserve Boundary

Current V2.1 remains:

- `GET /api/app/profile/credit-and-constraints/status`
- `GET /api/app/profile/credit-and-constraints/explanation`
- `GET /api/app/profile/credit-and-constraints/handoff`

Reserve remains:

- `GET /api/app/profile/organization-credit-scoring/status`
- `GET /api/app/profile/organization-credit-scoring/explanation`
- `GET /api/app/profile/organization-credit-scoring/handoff`

The reserve family must not back-write into current `credit-and-constraints/*`.

## 3. Field Mapping

| Flutter field | BFF field | Server field | OpenAPI schema field |
|---|---|---|---|
| `score` | `score` | `score` | `ProfileOrganizationCreditScoringReserveStatusResponse.score` |
| `tierCode` | `tierCode` | `tierCode` | `ProfileOrganizationCreditScoringReserveStatusResponse.tierCode` |
| `tierLabel` | `tierLabel` | `tierLabel` | `ProfileOrganizationCreditScoringReserveStatusResponse.tierLabel` |
| `sampleStatus` | `sampleStatus` | `sampleStatus` | `*.sampleStatus` |
| `riskPosture` | `riskPosture` | `riskPosture` | `*.riskPosture` |
| `ratedCompletedOrderCount` | `ratedCompletedOrderCount` | `ratedCompletedOrderCount` | `*.ratedCompletedOrderCount` |
| `positiveRate` | `positiveRate` | `positiveRate` | `*.positiveRate` |
| `negativeRate` | `negativeRate` | `negativeRate` | `*.negativeRate` |
| `verySatisfiedCount` | `verySatisfiedCount` | `verySatisfiedCount` | `*.verySatisfiedCount` |
| `satisfiedCount` | `satisfiedCount` | `satisfiedCount` | `*.satisfiedCount` |
| `passableCount` | `passableCount` | `passableCount` | `*.passableCount` |
| `negativeCount` | `negativeCount` | `negativeCount` | `*.negativeCount` |
| `actionableState` | `actionableState` | `actionableState` | `Status/Handoff.actionableState` |
| `updatedAt` | `updatedAt` | `updatedAt` | `*.updatedAt` |
| `reasonSummary` | `reasonSummary` | `reasonSummary` | `Explanation.reasonSummary` |
| `reasonCodes` | `reasonCodes` | `reasonCodes` | `Explanation.reasonCodes` |
| `primaryActionCode` | `primaryActionCode` | presenter-derived | `Handoff.primaryActionCode` |
| `primaryActionLabel` | `primaryActionLabel` | presenter-derived | `Handoff.primaryActionLabel` |
| `handoffMessage` | `handoffMessage` | presenter-derived | `Handoff.handoffMessage` |

`sampleStatus` is frozen as `UNAVAILABLE | INSUFFICIENT | SUFFICIENT`.

`riskPosture` is frozen as `UNAVAILABLE | LOW | MEDIUM | HIGH | null`.

## 4. Explicit Non-goals

This closure does not implement or open:

- formal organization credit scoring system
- score algorithm or scoring weights
- credit grade rules
- deduction, addition, recovery, or appeal rules
- Admin credit governance
- penalty or complaint governance linkage
- bidding eligibility impact
- exposure ranking impact
- deposit, guarantee, service-fee, payment, refund, settlement, or freeze execution
- migration, database write, cloud deployment, or runtime restart

## 5. Runtime Boundary

Anonymous runtime probing may return `401`; that proves route materialization and auth or future-visibility gating only.

Logged-in runtime payload parity must validate:

- all three reserve endpoints return `200`
- `contractErrors = 0`
- `extraFields = 0`
- no token, cookie, phone number, password, key, or verification code is printed

## 6. Formal Conclusion

Go for reserve read-surface contract and payload parity closure.

No-Go for current V2.1 organization credit scoring activation.

No-Go for Admin, payment, deposit, ranking, bidding, migration, deployment, or database mutation.
