---
owner: Codex 总控
status: frozen
purpose: Freeze the stage gate checklist for a frontend-only dev-test-channel minimum implementation round that unblocks manual testing without opening the formal auth or shell boards.
layer: L0 SSOT
gate_basis:
  - AGENTS.md
  - docs/00_ssot/gate_register_v1.md
  - docs/00_ssot/development_test_channel_minimum_closure_freeze_addendum.md
  - docs/00_ssot/project_publish_minimum_corridor_integration_validation_gate_checklist_addendum.md
  - docs/00_ssot/account_login_identity_permission_minimum_freeze_addendum.md
freeze_date_local: 2026-04-02
---

# 开发态测试通道最小实现轮阶段门禁核查表

## 1. Scope

- Current stage object:
  - `开发态测试通道 / frontend-only minimum implementation round`
- This stage applies only to:
  - Flutter debug build behavior
  - the existing login entry page debug button
  - route handoff into:
    - `/exhibition/projects/create`
  - current project-publish minimum corridor continuation only
- This stage does not apply to:
  - formal OTP send/login implementation
  - shell context backend implementation
  - exhibition workbench backend implementation
  - BFF or Server auth implementation
  - production release

## 2. Passed Gates

- Current urgency gate:
  - passed
  - manual testing is presently blocked by unfinished auth and shell runtime
- Current scope-isolation gate:
  - passed
  - the problem can be isolated to a dev-only auxiliary path
- Current mainline-protection gate:
  - passed
  - this round can unblock manual testing without expanding the project-publish
    mainline

## 3. Stage-local Guard Conditions

- This stage must be frontend-only.
- This stage must remain `kDebugMode` only.
- This stage must keep Flutter on app-facing canonical paths only.
- This stage may synthesize only local dev-only shell/session state.
- This stage may bypass only the unavailable:
  - auth send/login
  - shell context bootstrap
  - workbench create guard
- This stage must not bypass:
  - actual create/detail/upload request paths
  - actual BFF/Server runtime responses for the project-publish minimum
    corridor

## 4. Allowed File Scope

- Allowed:
  - `apps/mobile/lib/features/profile/presentation/profile_identity_access_pages.dart`
  - one small local helper or dev-state file if needed
  - one small project-create guard support patch if needed
  - related Flutter tests
- Not allowed:
  - `apps/bff/**`
  - `apps/server/**`
  - `infra/**`
  - `docs/01_contracts/**`

## 5. Failed Gates

- Formal auth board gate:
  - failed for this stage on purpose
  - the current round does not unlock OTP truth implementation
- Formal shell-context board gate:
  - failed for this stage on purpose
- Formal workbench board gate:
  - failed for this stage on purpose

## 6. Veto Gates

- No veto gate blocks this exact frontend-only dev-test-channel round, provided:
  - it stays debug-only
  - it does not create a second public auth family
  - it does not claim product login completion
  - it does not expand beyond the current project-publish minimum corridor

## 7. Stage Go / No-Go

- Stage decision:
  - `Go` for `开发态测试通道 / frontend-only minimum implementation round`
  - `No-Go` for formal auth implementation
  - `No-Go` for shell-context implementation
  - `No-Go` for workbench-board implementation
  - `No-Go` for release

## 8. Next Unique Action

- The next single action is:
  - issue a frontend-only implementation dispatch that converts the current
    debug button into a true dev-only project-publish test-channel entry
