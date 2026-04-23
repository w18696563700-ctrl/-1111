---
owner: Codex 总控
status: active
purpose: >
  Record the allowed BFF-side upstream environment boundary during the runtime
  cleanup so the repository does not confuse cloud-host loopback with local-only
  development chains.
layer: L4 BFF
decision_date_local: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/runtime_environment_entry_boundary_cleanup_freeze_addendum.md
  - infra/nginx/cloud.conf
  - apps/bff/src/core/runtime/runtime-config.service.ts
  - apps/bff/src/core/http/server-client.service.ts
---

# Runtime Upstream Environment Boundary Truth Note

## 1. Current BFF Boundary

- `BFF` remains an app-facing aggregation layer.
- This cleanup round may change:
  - runtime config defaults
  - startup guards
  - log clarity
  - local or isolated script naming
- This cleanup round may not change:
  - app-facing route semantics
  - aggregation responsibility
  - truth ownership

## 2. Allowed Upstream Shapes

- `cloud_host_internal_loopback`
  - allowed example:
    - `SERVER_BASE_URL=http://127.0.0.1:3001`
  - only valid when the process is part of the cloud single-host topology
- `explicit_local_development`
  - allowed only in clearly named local scripts or explicit local env injection
- `explicit_isolated_runtime`
  - allowed only in clearly named isolated package scripts

## 3. Forbidden Drift

- `BFF` must not silently look like a formal cloud process while using an accidental local upstream.
- A plain source default is acceptable only if startup behavior makes the active mode visible and rejects ambiguous combinations when needed.
- Local or isolated startup wrappers must not be mistaken for formal deploy wrappers.

## 4. Cleanup Outcome Requirement

- Runtime output must make the active upstream class visible.
- Local and isolated wrappers must say `local` or `isolated`.
- Formal cloud-host loopback must stay available and must not be mechanically replaced by a public cloud URL inside the host.
