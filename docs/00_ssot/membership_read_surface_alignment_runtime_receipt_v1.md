# Membership Read Surface Alignment Runtime Receipt v1

status: review_required_runtime_drift
owner: Codex Control
scope: membership read/display surface only
created_at: 2026-05-01

## 0. Verdict

- Local source alignment: Passed for the bounded membership read/display surface.
- Contracts check: Passed.
- Cloud runtime alignment: Not passed. The Aliyun runtime still returns deprecated candidate fee fields on `upgrade-guide`.
- Purchase/payment unlock: No. `purchase-offers` remains 404 and no purchase, payment, pre-authorization, bid, or project write action was executed.
- Runtime classification: deployment drift / runtime drift, not docs truth override.

## 1. Local Verification

| Check | Result | Evidence |
|---|---|---|
| Server build | Passed | `corepack pnpm --dir apps/server build` |
| BFF build | Passed | `corepack pnpm --dir apps/bff build` |
| Contracts check | Passed | `corepack pnpm contracts:check`, `contracts_check=passed` |
| Flutter membership consumer tests | Passed | `flutter test test/profile_identity_contract_compat_test.dart --plain-name "membership"` |
| Old fixed-rate scan in bounded source files | Passed | `rg "3.0%|2.5%|2.0%|1.5%|当前规划费率档|更低费率档位|预计年费|费率档位" apps/server/src/modules/membership apps/bff/src/routes/profile apps/mobile/lib/features/profile/...` returned no matches |

## 2. Cloud Runtime Read-only Verification

Base URL: `http://127.0.0.1:8080`

Auth action: `POST /api/app/auth/password/login`

Write-sensitive actions executed: none except test login.

| Endpoint | Method | Status | Result | Classification |
|---|---|---:|---|---|
| `/api/app/profile/membership/current` | GET | 200 | `paidMembershipTier=null`, `rateBand=null`, no `serviceFeeDiscountSummary` | runtime behind source |
| `/api/app/profile/membership/explanation` | GET | 200 | still says candidate price/rate parameters are only planning display | runtime drift |
| `/api/app/profile/membership/quota` | GET | 200 | empty quota summary | read surface available |
| `/api/app/profile/membership/upgrade-guide` | GET | 200 | still returns `candidateDisplayRateBand=2.5% / 2.0%` and candidate annual prices | runtime drift, deprecated fields still deployed |
| `/api/app/profile/membership/purchase-offers` | GET | 404 | purchase offers closed | expected closed surface |
| `/api/app/profile/payment-and-billing-status/status` | GET | 200 | `paymentStatus=handoff_required`, billing reference unavailable | payment/billing still handoff-only |

## 3. Runtime Drift Items

| Drift | Evidence | Expected Source Truth | Blocker |
|---|---|---|---:|
| `upgrade-guide` still exposes old fixed-rate candidate bands | Runtime `GET /api/app/profile/membership/upgrade-guide` returned `2.5%` and `2.0%` | `membership_entitlement_and_fee_unified_ruling_v1.md`; `membership.catalog.ts` now uses `baseFeeAmount × 0.9 / 0.8` summary and nullable legacy fields | Yes for runtime release |
| `current` lacks `serviceFeeDiscountSummary` | Runtime `GET /api/app/profile/membership/current` returned no summary field | `membership_entitlement_v1_contracts_addendum.md`; `openapi.yaml`; local Server/BFF/Flutter source | Yes for runtime release |
| `explanation` still uses candidate commercial wording | Runtime `GET /api/app/profile/membership/explanation` returned candidate disclaimer | Local `membership.catalog.ts` changed disclosure to non-transactional read-only explanation | Yes for runtime release |

## 4. Safety Confirmation

- No cloud file, database, code, config, or deployment change was made.
- No member purchase, renewal, cancellation, refund, invoice, payment init, pre-authorization, project publish, bid submit, or order-create action was executed.
- Runtime drift does not override SSOT/contracts/source truth.

## 5. Verification Noise / Known Non-blocking Findings

| Finding | Evidence | Classification |
|---|---|---|
| Broad `profile_page_test.dart` remains noisy because profile home status summaries are globally hidden | `apps/mobile/lib/features/profile/presentation/profile_page.dart` has `_profileHomeStatusVisible = false` | Existing frontend test/surface mismatch, outside fee-cleanup scope |
| Broad `profile_identity_contract_compat_test.dart` includes cases that instantiate disabled local-dev base URL | `AppApiEntryTarget.requireApprovedBaseUrl` rejects local-dev URLs | Existing runtime-entry gate noise, outside fee-cleanup scope |

## 6. Next Gate

Do not enter purchase/payment/P0-Pay implementation from this receipt.

The next stage can only be a controlled source-review and deployment/readonly-runtime verification gate for the membership read/display cleanup, after总控 approval.
