# Membership Read Surface Alignment Stage Gate Checklist v2

status: passed
owner: Codex Control
scope: final closeout for membership read/display fee wording cleanup after review fixes and runtime deployment
created_at: 2026-05-01
supersedes:
  - docs/00_ssot/membership_read_surface_alignment_stage_gate_checklist_v1.md
  - docs/00_ssot/membership_read_surface_alignment_runtime_receipt_v1.md
inputs:
  - docs/00_ssot/membership_read_surface_cleanup_deploy_runtime_receipt_v1.md
  - docs/00_ssot/membership_old_fee_rate_drift_cleanup_day1_register_v1.md
  - docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md
  - docs/01_contracts/membership_entitlement_v1_contracts_addendum.md
  - docs/01_contracts/identity_permission_minimum_contracts.yaml
  - docs/01_contracts/openapi.yaml

## 0. Gate Verdict

- Current read/display cleanup source can be reviewed: Yes.
- Current cloud runtime can be considered aligned for membership read/display cleanup: Yes.
- Review finding 1 is closed: Yes.
- Review finding 2 is closed: Yes.
- Purchase/payment can be unlocked: No.
- P0-Pay fee-discount linkage can be unlocked: No.
- Admin/governance/compliance stages can be treated as complete: No.

This v2 checklist supersedes v1's `no_go_runtime_drift` conclusion because the approved read/display cleanup has now been deployed to the active cloud runtime and passed read-only verification.

## 1. Passed Gates

| Gate | Result | Evidence |
|---|---|---|
| SSOT boundary ledger exists | Passed | `docs/00_ssot/membership_old_fee_rate_drift_cleanup_day1_register_v1.md` |
| Unified membership fee ruling frozen | Passed | `docs/00_ssot/membership_entitlement_and_fee_unified_ruling_v1.md` |
| Contracts membership read shape aligned | Passed | `docs/01_contracts/membership_entitlement_v1_contracts_addendum.md`; `docs/01_contracts/openapi.yaml` |
| Identity / permission baseline no longer carries draft status | Passed | `docs/01_contracts/identity_permission_minimum_contracts.yaml` now has `doc_meta.status=frozen` |
| `membershipStatus` separated from paid-membership tier | Passed | `docs/01_contracts/identity_permission_minimum_contracts.yaml`; `docs/01_contracts/membership_entitlement_v1_contracts_addendum.md` |
| Server membership read catalog no longer exposes fixed-rate commitments | Passed | `apps/server/src/modules/membership/membership.catalog.ts` |
| BFF membership read model carries `serviceFeeDiscountSummary` | Passed | `apps/bff/src/routes/profile/profile-membership.read-model.ts` |
| Flutter membership pages no longer render legacy candidate fee fields | Passed | `apps/mobile/lib/features/profile/presentation/profile_membership_pages.dart` |
| Flutter membership homepage test matches current hidden-summary gate | Passed | `apps/mobile/test/profile_page_test.dart` |
| Local build/contracts verification | Passed | `corepack pnpm --dir apps/server build`; `corepack pnpm --dir apps/bff build`; `corepack pnpm contracts:check` |
| Flutter membership regression | Passed | `flutter test test/profile_identity_contract_compat_test.dart --plain-name "membership"`; `flutter test test/profile_page_test.dart --plain-name "my membership"` |
| Cloud deployment / restart | Passed | `docs/00_ssot/membership_read_surface_cleanup_deploy_runtime_receipt_v1.md` |
| Runtime read-only verification | Passed | `GET /api/app/profile/membership/*`; `GET /api/app/profile/payment-and-billing-status/status` |

## 2. Superseded Failed Gates from v1

| v1 Failed Gate | v1 Result | v2 Result | Evidence |
|---|---|---|---|
| Cloud runtime read surface aligned with new source truth | Failed | Passed | Runtime `upgrade-guide` now returns `serviceFeeDiscountSummary` and null legacy candidate fields |
| Cloud `current` carries new discount summary field | Failed | Passed | Runtime `current` now returns `serviceFeeDiscountSummary` field; it is `null` for no paid tier |
| Cloud explanation wording fully de-candidated | Failed | Passed | Runtime `explanation` now describes `平台服务费 9 折 / 8 折` and non-transactional baseFeeAmount wording |

## 3. Veto Gates

| Veto Gate | Status | Evidence | Decision |
|---|---|---|---|
| Runtime must not expose old fixed-rate candidate bands as current truth | Passed | `upgrade-guide` returns `candidateDisplayPrice=null` and `candidateDisplayRateBand=null` | No veto for read/display cleanup |
| Purchase/payment must remain closed | Passed | `GET /api/app/profile/membership/purchase-offers` returned 404; payment/billing returned handoff-only | No purchase unlock |
| P0-Pay runtime charge logic must not be changed this round | Passed | This gate only covers membership read/display cleanup | No P0-Pay unlock |
| Cloud mutation must stay bounded to approved deploy/restart | Passed | No DB write, migration, Nginx change, purchase, payment, bid, or project publish action was executed | No broader runtime unlock |

## 4. Current Minimal Closed Loop

- Formal read/display truth is represented in SSOT, contracts, Server membership read source, BFF read model, Flutter read consumer/pages, and cloud runtime.
- Standard member display truth: `baseFeeAmount × 0.9`.
- Professional member display truth: `baseFeeAmount × 0.8`.
- Deprecated fixed rates `2.5% / 2.0% / 1.5%` are not current display or calculation truth.
- `membershipStatus` remains organization-membership truth only.
- Paid-membership display uses `paidMembershipTier`, `serviceFeeDiscountSummary`, and paid-membership summary fields.

## 5. Must Remain Closed

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
- KA / flagship tier enablement.
- Admin membership governance.

## 6. Runtime Baseline

| Runtime Item | Current Result |
|---|---|
| Server release | `/srv/releases/server/20260501032743-membership-read-surface-cleanup` |
| BFF release | `/srv/releases/bff/20260501032743-membership-read-surface-cleanup/apps/bff` |
| `exhibition-server` | active |
| `exhibition-bff` | active |
| `nginx` | active |
| `GET /api/app/profile/membership/current` | 200 |
| `GET /api/app/profile/membership/explanation` | 200 |
| `GET /api/app/profile/membership/quota` | 200 |
| `GET /api/app/profile/membership/upgrade-guide` | 200 |
| `GET /api/app/profile/membership/purchase-offers` | 404 |
| `GET /api/app/profile/payment-and-billing-status/status` | 200 handoff-only |

## 7. Residual Risk

| Risk | Level | Handling |
|---|---|---|
| Previous BFF rollback target was modified by a pre-switch build probe and should not be blindly reused | Medium | Already recorded in `membership_read_surface_cleanup_deploy_runtime_receipt_v1.md`; validate or rehydrate rollback target before any future rollback |
| P0-Pay fee linkage still has separate old `feeRate` model concerns | High for future P0-Pay stage | Must open a separate planning gate; do not infer readiness from this read/display cleanup |
| Purchase/payment/Admin/compliance are still absent or intentionally closed | High for purchase stage | Keep closed until separately frozen |

## 8. Next Unique Action

Open a separate planning gate for P0-Pay membership discount linkage only if总控 explicitly approves. Do not start implementation from this checklist.
