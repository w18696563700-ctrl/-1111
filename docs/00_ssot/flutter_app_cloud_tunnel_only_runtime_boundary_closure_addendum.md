---
owner: Codex 总控
status: active
purpose: >
  Freeze the Flutter App runtime boundary after the local-backend overreach
  cleanup so local execution can only target the Aliyun BFF through the
  approved SSH tunnel unless an operator intentionally selects an explicit
  cloud-direct entry.
layer: L0 SSOT
decision_date_local: 2026-04-24
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/current_cloud_execution_baseline_freeze_addendum.md
  - docs/04_frontend/runtime_entrypoint_environment_alignment_truth_note.md
  - apps/mobile/lib/core/api/app_api_entry_mode.dart
  - apps/mobile/lib/core/api/app_api_client.dart
  - apps/mobile/scripts/run_macos_formal.sh
  - apps/mobile/scripts/run_macos_local_dev.sh
  - apps/mobile/scripts/run_local_membership_app.sh
  - infra/scripts/run_local_membership_stack.sh
  - apps/bff/scripts/run_local_membership_bff.sh
  - apps/server/scripts/run_local_membership_server.sh
---

# Flutter App Cloud Tunnel Only Runtime Boundary Closure Addendum

## 1. Scope

- This addendum covers only Flutter App local execution boundaries.
- This addendum does not change:
  - BFF business responsibilities
  - Server business truth
  - Admin runtime policy

## 2. Frozen Runtime Rule

- The approved local execution chain for Flutter App is:
  - `ssh -N -L 8080:127.0.0.1:80 root@47.108.180.198`
  - `http://127.0.0.1:8080/api/app`
  - `apps/mobile/scripts/run_macos_ssh_tunnel.sh`
- `apps/mobile/scripts/run_macos_formal.sh` must default to `ssh_tunnel`.
- Flutter App runtime must not start against a local BFF on `127.0.0.1:3000`.
- Flutter App runtime must not start against a local Server on `127.0.0.1:3001`.
- Explicit cloud-direct entry may remain available only when the operator
  selects it on purpose.

## 3. Required Code-Level Closure

- `AppApiEntryTarget` and `AppApiConfig` must reject `local_dev` runtime
  resolution and any loopback base URL that infers to local backend mode.
- The disabled local wrappers must fail loudly instead of silently starting:
  - `apps/mobile/scripts/run_macos_local_dev.sh`
  - `apps/mobile/scripts/run_local_membership_app.sh`
  - `infra/scripts/run_local_membership_stack.sh`
  - `apps/bff/scripts/run_local_membership_bff.sh`
  - `apps/server/scripts/run_local_membership_server.sh`
- Runtime messaging must continue to distinguish:
  - SSH tunnel
  - explicit cloud
  - disabled local mode

## 4. Anti-Revert Rule

- Later threads must not reintroduce a runnable Flutter App `local_dev` mode.
- Later threads must not re-enable a local membership stack as a normal app
  development path.
- Later threads must not change the default local entry away from the approved
  SSH tunnel without a new SSOT decision.
