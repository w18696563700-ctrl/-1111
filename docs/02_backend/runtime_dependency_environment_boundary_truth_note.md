---
owner: Codex 总控
status: active
purpose: >
  Record the Server-side dependency environment boundary during the runtime
  cleanup so local dependency defaults, isolated runtime defaults, and cloud
  single-host loopback do not drift into each other.
layer: L4 Backend
decision_date_local: 2026-04-23
inputs_canonical:
  - AGENTS.md
  - docs/00_ssot/runtime_environment_entry_boundary_cleanup_freeze_addendum.md
  - apps/server/src/core/runtime-config.service.ts
  - infra/nginx/cloud.conf
---

# Runtime Dependency Environment Boundary Truth Note

## 1. Scope

- This note covers only runtime dependency endpoints used by `Server`, including:
  - PostgreSQL
  - Redis
  - object storage or MinIO-compatible upload endpoints
- This note does not change:
  - schema truth
  - domain truth
  - upload contract semantics

## 2. Frozen Rule

- `Server` may keep loopback-friendly defaults for clearly local or isolated runtime.
- Those defaults must not cause operators to mistake a local or isolated dependency chain for formal cloud runtime.
- Cloud single-host topology may legitimately use loopback for internal process-to-process access.
- Public-facing upload URLs and public-facing app callers must not inherit private local loopback endpoints by accident.

## 3. Cleanup Outcome Requirement

- Startup behavior or wrapper output must reveal whether `Server` is using:
  - local development dependencies
  - isolated runtime dependencies
  - cloud-host internal dependencies
- Local and isolated scripts must stay explicitly marked as such.
- `runtime/package1-isolated/.env.local` remains a local-only ignored file.
- A committed isolated template may exist, but isolated wrappers must not
  silently regenerate `.env.local` during normal start or probe commands.
- Future deploy wrappers must not reuse local dependency defaults without explicit operator intent.
