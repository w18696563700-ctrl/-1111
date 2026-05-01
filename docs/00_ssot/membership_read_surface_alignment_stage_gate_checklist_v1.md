# Membership Read Surface Alignment Stage Gate Checklist v1

status: no_go_runtime_drift
owner: Codex Control
scope: Day 6 closeout for membership read/display fee wording cleanup
created_at: 2026-05-01

## 0. Gate Verdict

- Whether current source can be reviewed: Yes.
- Whether current source can be merged after review: Conditional, subject to repository owner review because the worktree contains unrelated dirty changes.
- Whether current cloud runtime can be considered aligned: No.
- Whether purchase/payment can be unlocked: No.
- Whether P0-Pay fee-discount linkage can be unlocked: No.
- Whether Admin/governance/compliance stages can be treated as complete: No.

## 1. Passed Gates

| Gate | Result | Evidence |
|---|---|---|
| SSOT boundary ledger created | Passed | `docs/00_ssot/membership_old_fee_rate_drift_cleanup_day1_register_v1.md` |
| Unified ruling frozen for read/display truth | Passed | `docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md` |
| Contracts membership read shape aligned | Passed | `docs/01_contracts/membership_entitlement_v1_contracts_addendum.md`; `docs/01_contracts/openapi.yaml` |
| `membershipStatus` separated from paid membership tier | Passed | `docs/01_contracts/identity_permission_minimum_contracts.yaml`; Flutter shell consumer test |
| Server membership read catalog no longer exposes fixed-rate commitments | Passed | `apps/server/src/modules/membership/membership.catalog.ts` |
| BFF membership read model carries `serviceFeeDiscountSummary` | Passed | `apps/bff/src/routes/profile/profile-membership.read-model.ts` |
| Flutter membership read consumer/pages carry new summary field | Passed | `apps/mobile/lib/features/profile/data/profile_membership_consumer_layer.dart`; `apps/mobile/lib/features/profile/presentation/profile_membership_pages.dart` |
| Local build/contracts verification | Passed | Server build, BFF build, `contracts_check=passed` |
| Flutter membership consumer regression | Passed | `flutter test test/profile_identity_contract_compat_test.dart --plain-name "membership"` |

## 2. Failed Gates

| Gate | Result | Evidence | Impact |
|---|---|---|---|
| Cloud runtime read surface aligned with new source truth | Failed | `GET /api/app/profile/membership/upgrade-guide` returned deprecated `2.5% / 2.0%` fields | Blocks runtime release confirmation |
| Cloud `current` carries new discount summary field | Failed | `GET /api/app/profile/membership/current` returned no `serviceFeeDiscountSummary` | Blocks release confirmation |
| Cloud explanation wording fully de-candidated | Failed | `GET /api/app/profile/membership/explanation` still uses candidate commercial wording | Blocks release confirmation |

## 3. Veto Gates

| Veto Gate | Status | Evidence | Decision |
|---|---|---|---|
| Runtime still exposes old fixed-rate candidate bands | Failed | `GET /api/app/profile/membership/upgrade-guide` returned `candidateDisplayRateBand=2.5% / 2.0%` | Veto release |
| Purchase/payment must remain closed | Passed | `GET /api/app/profile/membership/purchase-offers` returned 404; payment/billing returned handoff-only | No purchase unlock |
| P0-Pay runtime charge logic must not be changed this round | Passed | No P0-Pay source/runtime write action executed | No P0-Pay unlock |
| Cloud mutation must not happen without approval | Passed | Only login and GET read probes were executed | No cloud write |

## 4. Verification Noise

| Noise | Evidence | Decision |
|---|---|---|
| Broad profile page test still expects home status summaries while the app hides them | `apps/mobile/lib/features/profile/presentation/profile_page.dart` keeps `_profileHomeStatusVisible = false` | Not used as the membership cleanup acceptance gate |
| Some identity compatibility tests still exercise disabled local-dev URLs | `apps/mobile/lib/core/api/app_api_entry_mode.dart` rejects local-dev base URLs | Not used as the membership cleanup acceptance gate |

## 5. Current Minimal Closed Loop

- Formal read/display truth is now represented in SSOT, contracts, Server membership read source, BFF read model, and Flutter read consumer/pages.
- Standard member display truth: `baseFeeAmount × 0.9`.
- Professional member display truth: `baseFeeAmount × 0.8`.
- Deprecated fixed rates `2.5% / 2.0% / 1.5%` are not current display or calculation truth.
- Current loop is source-level only until cloud deployment and read-only runtime recheck pass.

## 6. Must Remain Closed

- Membership direct purchase.
- Renewal.
- Cancellation.
- Refund.
- Invoice.
- Order-create.
- Pay-init.
- Payment callback.
- Entitlement writeback from payment.
- P0-Pay runtime service-fee discount linkage.
- KA / flagship tier.
- Admin membership governance.

## 7. Next Stage Entry Conditions

| Future Stage | Entry Condition | Current Status |
|---|---|---|
| Source review / merge | Reviewer confirms unrelated dirty worktree changes are separated from this patch | Pending |
| Cloud deployment of read/display cleanup | 总控 explicitly approves deploy/sync path | Not approved |
| Runtime read-only recheck | Cloud has deployed the approved read/display cleanup | Blocked by no deploy |
| P0-Pay linkage planning | Runtime read/display cleanup has passed | Blocked |
| Purchase/payment planning | Admin, compliance, payment channel, callback, refund, invoice prerequisites are separately frozen | Blocked |

## 8. Next Unique Action

Submit this read/display cleanup patch for review and, after approval, run a separate deployment-and-readonly-runtime-verification gate.
