---
owner: Codex 总控
status: active
purpose: >
  Record the frontend-side runtime entry alignment rule for the repository-wide
  environment cleanup so Flutter App and Admin do not silently fall back to a
  local backend while appearing to target the cloud runtime.
layer: L5 Frontend
decision_date_local: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/runtime_environment_entry_boundary_cleanup_freeze_addendum.md
  - docs/04_frontend/exhibition_d1_d2_smoke_checklist_and_tunnel_runbook.md
  - apps/mobile/lib/core/api/app_api_client.dart
  - apps/mobile/scripts/run_macos_formal.sh
  - apps/mobile/scripts/run_macos_cloud.sh
  - apps/admin/src/core/config/env.ts
---

# Runtime Entrypoint Environment Alignment Truth Note

## 1. Scope

- This note covers only frontend-facing runtime entry selection:
  - Flutter App app-facing BFF entry
  - Admin Server Admin API entry
- This note does not alter:
  - route semantics
  - UI behavior
  - auth or business truth

## 2. Frozen Frontend Rule

- `Flutter App` may support:
  - explicit tunnel mode
  - explicit cloud mode
  - explicit local mode
- `Flutter App` must not hide tunnel mode as an invisible default that looks like formal cloud mode.
- `Admin` must not silently assume local `127.0.0.1:3001/server/admin` when no explicit target has been provided.

## 3. Required Cleanup Outcome

- Runtime entry scripts must self-identify the chosen mode.
- If a mode depends on an SSH tunnel, the script output must say so.
- If a mode is cloud-direct, the script output must say so.
- If a mode is local-only, the script or entry name must say `local`.
- Missing admin target configuration must fail loudly instead of quietly drifting to localhost.
- `infra/env/formal_cloud_target.env` is the canonical formal cloud target
  register for frontend runtime entry resolution.
- `Flutter App`, `Admin`, and frontend smoke scripts must derive formal cloud
  base URLs from that register or an explicit env override instead of carrying a
  repeated raw host or IP in each entrypoint.

## 4. Anti-Revert Rule

- Later threads must not reintroduce:
  - silent localhost fallback into Admin
  - ambiguous Flutter startup messages that hide whether the app is on cloud or tunnel
  - runtime defaults that make tunnel and formal cloud behavior indistinguishable
