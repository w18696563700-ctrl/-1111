# Organization Switch And Leave Minimal Closure Execution Receipt

layer: L0 Execution Receipt
status: pass_with_risk
owner: Codex Control
date: 2026-05-01
depends_on:
  - docs/00_ssot/organization_switch_and_leave_minimal_closure_boundary_freeze_addendum.md
  - docs/01_contracts/organization_switch_and_leave_minimal_closure_contracts_addendum.md

## Conclusion

The local source implementation for organization switch confirmation and current-organization self-leave is complete and verified at source/build/test level.

The cloud active runtime is healthy but not aligned with this local source yet: `POST /api/app/profile/organization/current/leave` returns `404` through the `127.0.0.1:8080` tunnel. Therefore this round is `Pass with Risk`, not cloud-complete Go.

## Implemented Scope

- Flutter adds direct switch entry from `公司认证与我的身份`.
- Flutter organization switch page shows current organization, switchable organizations, switch confirmation, and self-leave confirmation.
- Flutter calls only BFF path `POST /api/app/profile/organization/current/leave`.
- BFF exposes app-facing leave route and forwards to `POST /server/profile/organization/current/leave`.
- Server owns self-leave truth:
  - verifies current organization scope
  - verifies active membership
  - blocks last active organization administrator
  - marks current membership as `removed`
  - writes `OrganizationMemberLeft` audit
  - rebinds valid sessions for the same user to the next app-facing organization, or clears organization scope

## Out Of Scope Preserved

- Organization deletion.
- Company cancellation.
- Organization merge.
- Ownership transfer.
- Certification cleanup.
- Historical projects, bids, messages, files, orders, or audit deletion.
- Local fake BFF / Server truth.

## Verification

### Contracts

- `pnpm contracts:generate` passed.
- `pnpm contracts:check` passed.

### Server

- `pnpm --dir apps/server build` passed.
- `node --test test/profile-organization-self-leave.test.cjs` passed:
  - ordinary member self-leave removes membership and rebinds valid sessions
  - last active admin is blocked

### BFF

- `pnpm --dir apps/bff build` passed.
- `node --test test/profile-organization-self-leave-transport.test.cjs` passed:
  - BFF forwards app call to Server
  - BFF shapes success response only
  - BFF maps last-admin and missing-scope errors without owning business truth

### Flutter

- Targeted analyze passed:
  - `lib/features/profile/data/profile_identity_consumer_layer.dart`
  - `lib/features/profile/presentation/profile_organization_switch_page.dart`
  - `lib/features/profile/presentation/profile_organization_switch_widgets.dart`
  - `lib/features/profile/presentation/profile_identity_access_pages.dart`
  - `test/profile_page_test.dart`
- Focused widget tests passed:
  - organization switch list rendering
  - switch confirmation with read-back verification
  - organization handoff route round trip
  - leave current organization and reload next organization

### Full Flutter Analyze

`flutter analyze` did not pass: `41 issues found`. The reported issues are pre-existing unrelated findings outside this round, including exhibition support warnings and existing test/support lint findings. No reported issue pointed at this round's touched profile organization files.

### File Length Gate

- `apps/mobile/lib/features/profile/presentation/profile_organization_switch_page.dart` -> `437` lines.
- `apps/mobile/lib/features/profile/presentation/profile_organization_switch_widgets.dart` -> `307` lines.
- `apps/bff/src/routes/profile/profile-organization-leave.service.ts` -> `77` lines.
- `apps/bff/src/routes/profile/profile-organization-leave-error.service.ts` -> `113` lines.
- `apps/server/src/modules/profile/profile-organization-self-leave.service.ts` -> `255` lines.

The new and refactored handwritten files remain under the `450` line responsibility gate.

### Cloud Tunnel

The configured tunnel is active:

```text
ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198
```

Read-only cloud smoke:

- `GET http://127.0.0.1:8080/health/bff/live` -> `200`
- `GET http://127.0.0.1:8080/health/server/live` -> `200`
- `GET http://127.0.0.1:8080/api/app/profile/organization/mine` without auth -> `401 AUTH_SESSION_INVALID`
- `POST http://127.0.0.1:8080/api/app/profile/organization/current/leave` without auth -> `404 Cannot POST /api/app/profile/organization/current/leave`

The `404` means the cloud active BFF artifact has not been updated with this new route.

## Dirty File Note

The repository already contains many unrelated modified and untracked files across Admin, BFF, Server, Mobile, docs, contracts, and infra. This receipt only claims the organization switch/self-leave files and generated contracts touched by this round.

## Final Gate

- Local source/build/test: `Pass`
- Cloud active runtime alignment: `No-Go`
- Overall: `Pass with Risk`

## Next Single Action

Authorize a cloud release/alignment step with backup and rollback evidence, then rerun:

- BFF/Server health
- `POST /api/app/profile/organization/current/leave` auth-gated route materialization
- dual-organization account switch and self-leave UAT
- last-admin rejection UAT
