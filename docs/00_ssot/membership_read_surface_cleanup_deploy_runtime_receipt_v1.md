# Membership Read Surface Cleanup Deploy Runtime Receipt v1

status: passed
owner: Codex Control
scope: membership read/display cleanup deployment and read-only runtime recheck
created_at: 2026-05-01

## 0. Verdict

- Review findings fixed: passed.
- Local source verification: passed.
- Cloud deployment / restart: passed.
- Read-only runtime recheck: passed.
- Purchase / payment unlock: no.
- P0-Pay discount linkage unlock: no.

This receipt supersedes the earlier `runtime_drift` conclusion for the membership read/display cleanup only. It does not unlock membership purchase, payment, refund, invoice, Admin governance, or P0-Pay runtime discount linkage.

## 1. Review Fixes

| Finding | Resolution | Evidence |
|---|---|---|
| Upgrade guide rendered legacy candidate price / fee-rate fields when `serviceFeeDiscountSummary` was absent | Flutter upgrade-guide now displays only `serviceFeeDiscountSummary`; legacy `candidateDisplayPrice` / `candidateDisplayRateBand` remain parsed compatibility fields only, not visible fallback | `apps/mobile/lib/features/profile/presentation/profile_membership_pages.dart` |
| Membership homepage test expected summary while `_profileHomeStatusVisible=false` hides home summaries | Test now asserts the homepage paid-membership summary is hidden under the current home-status gate | `apps/mobile/test/profile_page_test.dart` |

## 2. Local Verification

| Check | Result |
|---|---|
| `corepack pnpm --dir apps/server build` | Passed |
| `corepack pnpm --dir apps/bff build` | Passed |
| `corepack pnpm contracts:check` | Passed |
| `flutter test test/profile_identity_contract_compat_test.dart --plain-name "membership"` | Passed |
| `flutter test test/profile_page_test.dart --plain-name "my membership"` | Passed |

## 3. Cloud Deployment

Host: `47.108.180.198`

Release: `20260501032743-membership-read-surface-cleanup`

| Item | Value |
|---|---|
| Previous Server release | `/srv/releases/server/20260501013500-project-conversation-workbench-v1` |
| Previous BFF release | `/srv/releases/bff/20260501013500-project-conversation-workbench-v1/apps/bff` |
| Current Server release | `/srv/releases/server/20260501032743-membership-read-surface-cleanup` |
| Current BFF release | `/srv/releases/bff/20260501032743-membership-read-surface-cleanup/apps/bff` |
| Server restart | `systemctl restart exhibition-server` |
| BFF restart | `systemctl restart exhibition-bff` |
| Nginx restart | Not executed |
| Database / migration action | Not executed |

Rollback note:

- The previous Server pointer was recorded before switch.
- The previous BFF pointer was recorded before switch, but should not be used blindly as a rollback target because a pre-switch build probe changed its `dist` shape from the systemd-expected `dist/apps/bff/src/main.js` layout to a flat `dist/main.js` layout.
- No rollback was executed in this round because the new Server and BFF releases both restarted successfully.
- If rollback is required later, first validate or rehydrate the target BFF release shape before switching `/srv/apps/bff/current`.

## 4. Service Health

| Check | Result |
|---|---|
| `systemctl is-active exhibition-server` | `active` |
| `systemctl is-active exhibition-bff` | `active` |
| `systemctl is-active nginx` | `active` |
| `GET /health/bff/live` through `127.0.0.1:8080` | 200 |
| `GET /health/server/live` through `127.0.0.1:8080` | 200 |

## 5. Read-only Runtime Recheck

Base URL: `http://127.0.0.1:8080`

Auth action: `POST /api/app/auth/password/login` with test account only.

No purchase, payment, pre-authorization, project publish, bid submit, refund, invoice, or DB write action was executed.

| Endpoint | Status | Result |
|---|---:|---|
| `GET /api/app/profile/membership/current` | 200 | returns `serviceFeeDiscountSummary=null` for no paid tier and keeps `rateBand=null` |
| `GET /api/app/profile/membership/explanation` | 200 | standard/professional highlights now show `平台服务费 9 折 / 8 折` |
| `GET /api/app/profile/membership/quota` | 200 | quota read surface available |
| `GET /api/app/profile/membership/upgrade-guide` | 200 | available tiers return `serviceFeeDiscountSummary`; `candidateDisplayPrice=null`; `candidateDisplayRateBand=null` |
| `GET /api/app/profile/membership/purchase-offers` | 404 | purchase remains closed |
| `GET /api/app/profile/payment-and-billing-status/status` | 200 | payment and billing remain handoff-only |

## 6. Remaining Closed Capabilities

- Membership purchase.
- Membership renewal.
- Membership cancellation.
- Refund.
- Invoice.
- Payment init.
- Payment callback.
- Entitlement writeback from payment.
- P0-Pay runtime service-fee discount linkage.
- KA / flagship tier.
- Admin membership governance.

## 7. Next Unique Action

Do not enter purchase or P0-Pay implementation from this receipt. The next unique action is to submit the now-deployed read/display cleanup for final review and decide whether to open a separate planning gate for P0-Pay membership discount linkage.
